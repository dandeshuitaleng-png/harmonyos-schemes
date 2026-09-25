const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const os = require('node:os');
const path = require('node:path');
const domain = require(path.join(process.env.TIDEWATCH_TEST_BUILD, 'Observation.js'));
const { ObservationRepository } = require(path.join(process.env.TIDEWATCH_TEST_BUILD, 'ObservationRepository.js'));
const now = Date.parse('2026-09-21T01:00:00.000Z');
const input = { title: '东侧步道积水', place: '公共步道东侧', description: '步道上有一片积水，范围没有扩大。', kind: '道路积水', risk: '未评估' };
const record = (time = now) => domain.createObservation(input, 2, time, []);
const legacy = () => {
  const { id, source, collectedAt, expiresAt, status } = record();
  return { id, source, collectedAt, expiresAt, status };
};
class MemoryIO {
  raw = '';
  writes = 0;
  failRead = false;
  failWrite = false;
  async read() { if (this.failRead) throw Error('read failed'); return this.raw; }
  async write(raw) { if (this.failWrite) throw Error('disk full'); this.writes++; this.raw = raw; }
}

test('creates a real observation with private status and bounded lifetime', () => {
  const item = record();
  assert.equal(item.description, input.description);
  assert.equal(item.status, '待审核 · 不公开');
  assert.equal(Date.parse(item.expiresAt) - Date.parse(item.collectedAt), 7200000);
  assert.equal(domain.validateInput(input), '');
});
test('input boundaries reject blank, short, long and invalid enum fields', () => {
  for (const field of ['title', 'place', 'description']) {
    assert.notEqual(domain.validateInput({ ...input, [field]: '  ' }), '');
    assert.notEqual(domain.validateInput({ ...input, [field]: '字'.repeat(501) }), '');
  }
  assert.notEqual(domain.validateInput({ ...input, kind: '官方预报' }), '');
  assert.notEqual(domain.validateInput({ ...input, risk: 'approved' }), '');
  assert.equal(domain.validateInput({ ...input, title: '字'.repeat(40), place: '字'.repeat(80), description: '字'.repeat(500) }), '');
});
test('creation trims text and rejects invalid hours, clock and capacity', () => {
  assert.equal(domain.createObservation({ ...input, title: '  观察标题  ' }, 1, now, []).title, '观察标题');
  for (const hours of [-1, 0, 3, NaN, 48]) assert.throws(() => domain.createObservation(input, hours, now, []));
  assert.throws(() => domain.createObservation(input, 2, NaN, []));
  assert.throws(() => domain.createObservation(input, 2, now, Array(200).fill(record())));
});
test('same millisecond IDs remain unique', () => {
  const a = record();
  const b = domain.createObservation(input, 2, now, [a]);
  const c = domain.createObservation(input, 2, now, [a, b]);
  assert.equal(new Set([a.id, b.id, c.id]).size, 3);
});
test('editing preserves evidence age and expiry', () => {
  const a = record();
  const b = domain.editObservation(a, { ...input, description: '再次查看，积水范围基本没有变化。' }, now + 1000);
  assert.equal(b.id, a.id);
  assert.equal(b.collectedAt, a.collectedAt);
  assert.equal(b.expiresAt, a.expiresAt);
  assert.notEqual(b.updatedAt, a.updatedAt);
  assert.notEqual(b.description, a.description);
  assert.throws(() => domain.editObservation(a, input, now - 1));
  assert.throws(() => domain.editObservation(a, input, Date.parse(a.expiresAt)));
});
test('expiry is inclusive at the exact cutoff', () => {
  const a = record();
  assert.equal(domain.isExpired(a, Date.parse(a.expiresAt) - 1), false);
  assert.equal(domain.isExpired(a, Date.parse(a.expiresAt)), true);
});
test('JSON legacy migration preserves age without inventing a classification', () => {
  const a = legacy();
  const migrated = domain.decodeRecords(JSON.stringify([a]));
  assert.equal(migrated[0].kind, '未分类');
  assert.equal(migrated[0].risk, '未评估');
  assert.equal(migrated[0].collectedAt, a.collectedAt);
  assert.deepEqual(domain.decodeRecords(domain.encodeRecords(migrated)), migrated);
});
test('delimited legacy migration is supported', () => {
  const a = legacy();
  assert.equal(domain.decodeRecords([a.id, a.source, a.collectedAt, a.expiresAt, a.status].join('|'))[0].id, a.id);
});
test('corrupted, null, unknown version and ambiguous legacy records fail closed', () => {
  for (const raw of [' ', '{', 'null', '[null]', '[{}]', '{"version":99,"records":[]}', '{"version":2,"records":null}', 'abc|x|x|x|x']) {
    assert.throws(() => domain.decodeRecords(raw), raw);
  }
  const a = legacy();
  assert.throws(() => domain.decodeRecords(JSON.stringify([{ ...a, collectedAt: '09月21日' }])));
  assert.throws(() => domain.decodeRecords(JSON.stringify([{ ...a, collectedAt: '2026-02-30T01:00:00.000Z' }])));
});
test('duplicate, invalid chronology or non-private stored records are rejected', () => {
  const a = record();
  for (const records of [[a, a], [{ ...a, expiresAt: a.collectedAt }], [{ ...a, status: 'approved' }], [{ ...a, updatedAt: 'invalid' }], [{ ...a, id: -1 }]]) {
    assert.throws(() => domain.encodeRecords(records));
  }
});
test('snapshot round trip retains expired history when adding a new record', () => {
  const old = record(now - 86400000);
  const list = domain.decodeRecords(domain.encodeRecords([record(), old]));
  assert.equal(list.length, 2);
  assert.equal(list[1].id, old.id);
  assert.equal(domain.isExpired(list[1], now), true);
});
test('search/filter changes neither the underlying collection nor history', () => {
  const list = [record(), record(now - 86400000)];
  const before = domain.encodeRecords(list);
  assert.equal(domain.filterObservations(list, '', '有效期内', now).length, 1);
  assert.equal(domain.filterObservations(list, ' 步道 ', '已过期', now).length, 1);
  assert.equal(domain.filterObservations(list, '没有扩大', '全部', now).length, 2);
  assert.equal(domain.filterObservations(list, '不存在', '全部', now).length, 0);
  assert.equal(domain.encodeRecords(list), before);
});
test('repository refuses write before a successful load', async () => {
  const io = new MemoryIO();
  const repo = new ObservationRepository(io);
  await assert.rejects(repo.save([record()]));
  io.failRead = true;
  await assert.rejects(repo.load());
  await assert.rejects(repo.save([]));
  assert.equal(io.writes, 0);
});
test('corrupt data is not silently reset or overwritten', async () => {
  const io = new MemoryIO(); io.raw = '[null]';
  const repo = new ObservationRepository(io);
  await assert.rejects(repo.load());
  await assert.rejects(repo.save([]));
  assert.equal(io.raw, '[null]');
});
test('failed persistence requires reload before another mutation', async () => {
  const io = new MemoryIO(); const repo = new ObservationRepository(io);
  await repo.load(); await repo.save([record()]);
  io.failWrite = true;
  await assert.rejects(repo.save([]));
  io.failWrite = false;
  await assert.rejects(repo.save([]));
  assert.equal((await repo.load()).length, 1);
  await repo.save([]);
  assert.deepEqual(await repo.load(), []);
});
test('concurrent write and read cannot overtake an in-flight save', async () => {
  let complete;
  let raw = '';
  const repo = new ObservationRepository({ read: async () => raw, write: value => new Promise(resolve => { complete = () => { raw = value; resolve(); }; }) });
  await repo.load();
  const first = repo.save([record()]);
  await assert.rejects(repo.save([]));
  await assert.rejects(repo.load());
  complete(); await first;
  assert.equal((await repo.load()).length, 1);
});
test('repository survives recreation using a file-backed test adapter', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'tidewatch-test-'));
  const file = path.join(dir, 'snapshot.json');
  const io = { read: async () => { try { return await fs.readFile(file, 'utf8'); } catch (e) { if (e.code === 'ENOENT') return ''; throw e; } }, write: value => fs.writeFile(file, value) };
  try {
    const first = new ObservationRepository(io); await first.load(); await first.save([record(), record(now - 86400000)]);
    const second = new ObservationRepository(io);
    assert.equal((await second.load()).length, 2);
    await second.save([]);
    assert.deepEqual(await new ObservationRepository(io).load(), []);
  } finally { await fs.rm(dir, { recursive: true, force: true }); }
});
