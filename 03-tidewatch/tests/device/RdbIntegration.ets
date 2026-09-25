import { common } from '@kit.AbilityKit';
import { preferences, relationalStore } from '@kit.ArkData';
import { fileIo as fs } from '@kit.CoreFileKit';
import { RdbSnapshotIO } from '../data/RdbSnapshotIO';
import { ObservationDraft, ObservationInput, createObservation, encodeRecords, decodeRecords } from '../data/Observation';
import { CREATE_META, CREATE_OBSERVATIONS, SELECT_VERSION } from '../data/ObservationSchema';

interface NativeResult { name: string; passed: boolean; detail: string; }
interface NativeReport { passed: number; failed: number; cases: NativeResult[]; }
class NativeSuite {
  private context: common.UIAbilityContext;
  private prefix: string = `native_${Date.now()}`;
  private results: NativeResult[] = [];
  constructor(context: common.UIAbilityContext) { this.context = context; }
  private assert(value: boolean, message: string): void { if (!value) throw new Error(message); }
  private async rejects(action: () => Promise<void>): Promise<void> {
    let rejected = false;
    try { await action(); } catch { rejected = true; }
    this.assert(rejected, 'Expected operation to reject');
  }
  private async check(name: string, action: () => Promise<void>): Promise<void> {
    try { await action(); this.results.push({ name: name, passed: true, detail: 'PASS' }); }
    catch (error) { this.results.push({ name: name, passed: false, detail: (error as Error).message }); }
  }
  private io(name: string): RdbSnapshotIO { return new RdbSnapshotIO(this.context, `${this.prefix}_${name}.db`, `${this.prefix}_${name}`); }
  private async db(name: string): Promise<relationalStore.RdbStore> {
    return relationalStore.getRdbStore(this.context, { name: `${this.prefix}_${name}.db`, securityLevel: relationalStore.SecurityLevel.S2 });
  }
  private async pref(name: string): Promise<preferences.Preferences> { return preferences.getPreferences(this.context, `${this.prefix}_${name}`); }
  private record(offset: number = 0): ObservationDraft {
    const input: ObservationInput = { title: '原生迁移测试', place: '模拟公共步道', description: "中文和引号 '); DELETE FROM observations; -- 都应作为普通文字保存", kind: '道路积水', risk: '未评估' };
    return createObservation(input, 2, Date.parse('2026-09-20T00:00:00.000Z') + offset, []);
  }
  async run(): Promise<NativeReport> {
    await this.check('fresh-save-close-reopen-and-sql-binding', async () => {
      const io = this.io('fresh');
      this.assert(decodeRecords(await io.read()).length === 0, 'new database not empty');
      const records: ObservationDraft[] = [this.record(2), this.record(1)];
      await io.write(encodeRecords(records));
      await (await this.db('fresh')).close();
      this.assert(await this.io('fresh').read() === encodeRecords(records), 'fields/order changed after close');
    });
    await this.check('legacy-json-migration-expired-kept-and-privacy-preserved', async () => {
      const pref = await this.pref('legacy');
      const record = this.record();
      const raw = JSON.stringify([{ id: record.id, source: record.source, collectedAt: record.collectedAt,
        expiresAt: record.expiresAt, status: record.status }]);
      await pref.put('drafts', raw); await pref.put('privacy-choice', 'accepted'); await pref.flush();
      const actual = decodeRecords(await this.io('legacy').read());
      this.assert(actual.length === 1 && actual[0].id === record.id && actual[0].collectedAt === record.collectedAt &&
        actual[0].expiresAt === record.expiresAt && actual[0].kind === '未分类', 'legacy metadata changed');
      this.assert(!await pref.has('drafts'), 'legacy copy was not removed');
      this.assert(await pref.get('privacy-choice', '') === 'accepted', 'privacy choice was changed');
    });
    await this.check('version2-and-delimited-migrations', async () => {
      const record = this.record();
      const pref = await this.pref('v2'); await pref.put('drafts', encodeRecords([record])); await pref.flush();
      this.assert(await this.io('v2').read() === encodeRecords([record]), 'v2 fields changed');
      const old = await this.pref('line');
      await old.put('drafts', [record.id.toString(), record.source, record.collectedAt, record.expiresAt, record.status].join('|')); await old.flush();
      this.assert(decodeRecords(await this.io('line').read())[0].id === record.id, 'line migration changed ID');
    });
    await this.check('invalid-legacy-kept-and-write-blocked', async () => {
      const pref = await this.pref('invalid'); await pref.put('drafts', '[null]'); await pref.flush();
      const io = this.io('invalid');
      await this.rejects(async () => { await io.read(); });
      await this.rejects(async () => { await io.write(encodeRecords([])); });
      this.assert(await pref.get('drafts', '') === '[null]', 'invalid original was removed');
    });
    await this.check('unknown-schema-rejected', async () => {
      const db = await this.db('future');
      await db.executeSql(CREATE_META); await db.executeSql(CREATE_OBSERVATIONS);
      await db.executeSql("INSERT INTO observation_meta (key,value) VALUES ('schema_version','99')");
      await this.rejects(async () => { await this.io('future').read(); });
      const rows = await db.querySql(SELECT_VERSION);
      try { this.assert(rows.goToNextRow() && rows.getString(0) === '99', 'unknown schema overwritten'); } finally { rows.close(); }
    });
    await this.check('failed-replacement-rolls-back-real-transaction', async () => {
      const io = this.io('rollback'); await io.read();
      const original = encodeRecords([this.record()]); await io.write(original);
      const db = await this.db('rollback');
      await db.executeSql("CREATE TRIGGER stop_insert BEFORE INSERT ON observations BEGIN SELECT RAISE(ABORT, 'test fault'); END");
      await this.rejects(async () => { await io.write(encodeRecords([this.record(1)])); });
      await this.rejects(async () => { await io.write(encodeRecords([])); });
      await db.executeSql('DROP TRIGGER stop_insert');
      this.assert(await io.read() === original, 'delete escaped rollback');
      await io.write(encodeRecords([this.record(1)]));
      this.assert(decodeRecords(await io.read())[0].id === this.record(1).id, 'retry failed');
    });
    await this.check('failed-migration-keeps-source-and-retries', async () => {
      const pref = await this.pref('migrateFail'); const original = encodeRecords([this.record()]);
      await pref.put('drafts', original); await pref.flush();
      const db = await this.db('migrateFail'); await db.executeSql(CREATE_META); await db.executeSql(CREATE_OBSERVATIONS);
      await db.executeSql("CREATE TRIGGER stop_migration BEFORE INSERT ON observations BEGIN SELECT RAISE(ABORT, 'test migration fault'); END");
      await this.rejects(async () => { await this.io('migrateFail').read(); });
      this.assert(await pref.get('drafts', '') === original, 'migration failure removed source');
      const marker = await db.querySql(SELECT_VERSION);
      try { this.assert(!marker.goToNextRow(), 'failed migration committed marker'); } finally { marker.close(); }
      await db.executeSql('DROP TRIGGER stop_migration');
      this.assert(await this.io('migrateFail').read() === original, 'migration retry failed');
    });
    await this.check('readback-mismatch-stays-blocked-after-reopen', async () => {
      const pref = await this.pref('readback'); const original = encodeRecords([this.record()]);
      await pref.put('drafts', original); await pref.flush();
      const db = await this.db('readback'); await db.executeSql(CREATE_META); await db.executeSql(CREATE_OBSERVATIONS);
      await db.executeSql("CREATE TRIGGER change_title AFTER INSERT ON observations BEGIN UPDATE observations SET title = '模拟不一致' WHERE id = NEW.id; END");
      await this.rejects(async () => { await this.io('readback').read(); });
      await this.rejects(async () => { await this.io('readback').read(); });
      this.assert(await pref.get('drafts', '') === original, 'reopen bypassed readback verification');
      await db.executeSql('DROP TRIGGER change_title');
      await db.executeSql('UPDATE observations SET title = ?', [this.record().title]);
      this.assert(await this.io('readback').read() === original, 'verification recovery failed');
    });
    await this.check('deleted-records-never-reimported-from-stale-preferences', async () => {
      const pref = await this.pref('deleted'); const original = encodeRecords([this.record()]);
      await pref.put('drafts', original); await pref.flush();
      const io = this.io('deleted'); await io.read(); await io.write(encodeRecords([]));
      await pref.put('drafts', original); await pref.flush();
      this.assert(decodeRecords(await this.io('deleted').read()).length === 0, 'deleted record resurrected');
      this.assert(!await pref.has('drafts'), 'stale personal copy remains');
    });
    await this.check('corrupt-database-does-not-fall-back-to-empty', async () => {
      const io = this.io('corrupt'); await io.read(); await io.write(encodeRecords([this.record()]));
      const db = await this.db('corrupt'); await db.executeSql("UPDATE observations SET title = ''");
      await this.rejects(async () => { await io.read(); });
      await this.rejects(async () => { await io.write(encodeRecords([])); });
      const rows = await db.querySql('SELECT COUNT(*) FROM observations');
      try { this.assert(rows.goToNextRow() && rows.getLong(0) === 1, 'corrupt evidence erased'); } finally { rows.close(); }
    });
    await this.check('two-hundred-record-capacity-native-reopen', async () => {
      const io = this.io('capacity'); await io.read();
      const records: ObservationDraft[] = [];
      for (let index = 0; index < 200; index += 1) records.push(this.record(index));
      await io.write(encodeRecords(records)); await (await this.db('capacity')).close();
      this.assert(await this.io('capacity').read() === encodeRecords(records), 'capacity roundtrip mismatch');
    });
    const passed = this.results.filter((item: NativeResult) => item.passed).length;
    return { passed: passed, failed: this.results.length - passed, cases: this.results };
  }
}

@Entry
@Component
struct Index {
  @State report: string = 'RUNNING native database tests';
  aboutToAppear(): void { this.run(); }
  private async run(): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      const result = await new NativeSuite(context).run();
      this.report = JSON.stringify(result);
      const file = fs.openSync(`${context.filesDir}/rdb-report.json`, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      try { fs.writeSync(file.fd, this.report); } finally { fs.closeSync(file); }
    } catch (error) { this.report = `HARNESS ERROR ${(error as Error).message}`; }
  }
  build() { Scroll() { Text(this.report).fontSize(16).padding(20) }.width('100%').height('100%') }
}
