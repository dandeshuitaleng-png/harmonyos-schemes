import { preferences, relationalStore } from '@kit.ArkData';
import { ObservationDraft, decodeRecords, encodeRecords, validateRecords } from './Observation';
import { SnapshotIO } from './ObservationRepository';
import { DATABASE_NAME, DATABASE_VERSION, CREATE_META, CREATE_OBSERVATIONS, SELECT_VERSION,
  INSERT_VERSION, SELECT_RECORDS, INSERT_RECORD, DELETE_RECORDS, recordValues } from './ObservationSchema';

// Instantiated only after privacy acceptance. Names are injectable for isolated native integration tests.
export class RdbSnapshotIO implements SnapshotIO {
  private context: Context;
  private databaseName: string;
  private legacyName: string;
  private database: relationalStore.RdbStore | undefined = undefined;
  private initialized: boolean = false;

  constructor(context: Context, databaseName: string = DATABASE_NAME,
    legacyName: string = 'tidewatch-observation-drafts') {
    this.context = context;
    this.databaseName = databaseName;
    this.legacyName = legacyName;
  }

  private async open(): Promise<relationalStore.RdbStore> {
    if (this.database === undefined) {
      const config: relationalStore.StoreConfig = { name: this.databaseName, securityLevel: relationalStore.SecurityLevel.S2 };
      this.database = await relationalStore.getRdbStore(this.context, config);
    }
    return this.database;
  }

  private recordsFrom(result: relationalStore.ResultSet): ObservationDraft[] {
    const records: ObservationDraft[] = [];
    try {
      while (result.goToNextRow()) {
        records.push({ id: result.getLong(0), source: result.getString(1), collectedAt: result.getString(2),
          expiresAt: result.getString(3), status: result.getString(4), title: result.getString(5),
          place: result.getString(6), description: result.getString(7), kind: result.getString(8),
          risk: result.getString(9), updatedAt: result.getString(10) });
      }
    } finally { result.close(); }
    validateRecords(records);
    return records;
  }

  private async versionOf(transaction: relationalStore.Transaction): Promise<string> {
    const result = await transaction.querySql(SELECT_VERSION);
    try { return result.goToNextRow() ? result.getString(0) : ''; }
    finally { result.close(); }
  }

  private async insertAll(transaction: relationalStore.Transaction, records: ObservationDraft[]): Promise<void> {
    for (let index = 0; index < records.length; index += 1) {
      await transaction.execute(INSERT_RECORD, recordValues(records[index], index));
    }
  }

  async read(): Promise<string> {
    this.initialized = false;
    const database = await this.open();
    const transaction = await database.createTransaction({ transactionType: relationalStore.TransactionType.IMMEDIATE });
    let migratedRaw: string = '';
    try {
      await transaction.execute(CREATE_META);
      await transaction.execute(CREATE_OBSERVATIONS);
      const version = await this.versionOf(transaction);
      if (version.length === 0) {
        const existing = this.recordsFrom(await transaction.querySql(SELECT_RECORDS));
        if (existing.length > 0) throw new Error('数据库缺少版本标记，已保护现有记录');
        const legacy = await preferences.getPreferences(this.context, this.legacyName);
        const raw = await legacy.get('drafts', '');
        if (typeof raw !== 'string') throw new Error('旧草稿格式异常，迁移未完成');
        const records = decodeRecords(raw);
        await this.insertAll(transaction, records);
        await transaction.execute(INSERT_VERSION, [DATABASE_VERSION]);
        migratedRaw = encodeRecords(records);
        await transaction.execute("INSERT INTO observation_meta (key, value) VALUES ('migration_expected', ?)", [migratedRaw]);
      } else if (version !== DATABASE_VERSION) {
        throw new Error('不支持此数据库版本，请保留应用数据');
      }
      const expected = await transaction.querySql("SELECT value FROM observation_meta WHERE key = 'migration_expected'");
      try { if (expected.goToNextRow()) migratedRaw = expected.getString(0); } finally { expected.close(); }
      await transaction.commit();
    } catch (error) {
      try { await transaction.rollback(); } catch { /* Preserve the original failure; never acknowledge success. */ }
      throw new Error((error as Error).message);
    }
    const records = this.recordsFrom(await database.querySql(SELECT_RECORDS));
    const raw = encodeRecords(records);
    if (migratedRaw.length > 0 && raw !== migratedRaw) throw new Error('迁移读回校验失败，旧草稿已保留');
    // Always flush deletion, even if a previous failed flush has already removed the key from cache.
    const legacy = await preferences.getPreferences(this.context, this.legacyName);
    await legacy.delete('drafts');
    await legacy.flush();
    // Keep the expected snapshot durable until readback AND removal of the legacy copy have succeeded.
    await database.executeSql("DELETE FROM observation_meta WHERE key = 'migration_expected'");
    this.initialized = true;
    return raw;
  }

  async write(value: string): Promise<void> {
    if (!this.initialized) throw new Error('请先完成数据读取与迁移');
    const records = decodeRecords(value);
    const database = await this.open();
    const transaction = await database.createTransaction({ transactionType: relationalStore.TransactionType.IMMEDIATE });
    try {
      if (await this.versionOf(transaction) !== DATABASE_VERSION) throw new Error('数据库版本发生变化，请重新读取');
      // Validate stored data before any destructive statement, including the empty-set delete case.
      this.recordsFrom(await transaction.querySql(SELECT_RECORDS));
      await transaction.execute(DELETE_RECORDS);
      await this.insertAll(transaction, records);
      await transaction.commit();
    } catch (error) {
      this.initialized = false;
      try { await transaction.rollback(); } catch { /* The caller must reload after any uncertain outcome. */ }
      throw new Error((error as Error).message);
    }
  }
}
