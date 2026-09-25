const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const studio = process.env.DEVECO_APP || '/Applications/DevEco-Studio.app';
const ts = require(process.env.TYPESCRIPT_PATH || `${studio}/Contents/tools/hvigor/hvigor/node_modules/typescript/lib/typescript.js`);
const root = path.resolve(__dirname, '..');
function compile(file, dependencies = {}) {
  const source = fs.readFileSync(path.join(root, file), 'utf8');
  const result = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 } });
  const exports = {};
  vm.runInNewContext(result.outputText, { exports, require(name) {
    if (!(name in dependencies)) throw Error(`Unexpected dependency ${name}`);
    return dependencies[name];
  } });
  return exports;
}
const model = compile('entry/src/main/ets/model/Observation.ts');
const plain = value => JSON.parse(JSON.stringify(value));
const record = (id = 'one') => ({ id, createdAt: 1789911000000, task: '叶缘', place: '公园', features: ['边缘看起来平滑'] });
const archive = records => JSON.stringify({ version: 1, records });
function storage(initial = '', failureCount = 0) {
  let cache = initial, disk = initial, failures = failureCount, writeCount = 0;
  const prefs = {
    getSync() { return cache; },
    putSync(key, value) { cache = value; writeCount++; },
    async flush() { if (failures-- > 0) throw Error('disk unavailable'); disk = cache; }
  };
  const { ObservationStore } = compile('entry/src/main/ets/storage/ObservationStore.ets', {
    '@kit.ArkData': { preferences: { getPreferencesSync() { return prefs; } } },
    '../model/Observation': model
  });
  const store = new ObservationStore({});
  return { store, prefs, disk: () => disk, cache: () => cache, writes: () => writeCount, fail: count => failures = count };
}

test('all task/environment combinations accept every valid feature and reject incomplete input', () => {
  for (const task of model.TASKS) for (const place of model.PLACES) {
    for (const feature of model.optionsFor(task)) assert.ok(model.validSelection(task, place, [feature]));
    assert.equal(model.validSelection(task, place, []), false);
  }
  assert.equal(model.validSelection('', '公园', ['暂时看不清']), false);
  assert.equal(model.validSelection('叶缘', '具体地址', ['暂时看不清']), false);
  assert.equal(model.validSelection('叶缘', '公园', ['看到花或花苞']), false);
  assert.equal(model.validSelection('叶缘', '公园', null), false);
});
test('uncertain observation is exclusive in both directions; deselection works', () => {
  for (const task of model.TASKS) {
    const first = model.optionsFor(task)[0];
    assert.deepEqual(plain(model.toggleFeature(task, [first], model.UNCLEAR)), [model.UNCLEAR]);
    assert.deepEqual(plain(model.toggleFeature(task, [model.UNCLEAR], first)), [first]);
    assert.deepEqual(plain(model.toggleFeature(task, [first], first)), []);
    assert.equal(model.validSelection(task, '公园', [first, model.UNCLEAR]), false);
    assert.equal(model.validSelection(task, '公园', [first, first]), false);
  }
});
test('flower and fruit may coexist but not with absent or unclear', () => {
  const [flower, fruit] = model.optionsFor('花果');
  assert.deepEqual(plain(model.toggleFeature('花果', [flower], fruit)), [flower, fruit]);
  assert.deepEqual(plain(model.toggleFeature('花果', [flower, fruit], model.ABSENT)), [model.ABSENT]);
  assert.deepEqual(plain(model.toggleFeature('花果', [model.ABSENT], fruit)), [fruit]);
  assert.equal(model.validSelection('花果', '公园', [model.ABSENT, flower]), false);
});
test('versioned archive restores records without retaining unknown fields', () => {
  const r = { ...record(), extra: 'not a supported field' };
  assert.deepEqual(plain(model.decodeArchive(model.encodeArchive([r]))), [record()]);
  assert.deepEqual(plain(model.decodeArchive('')), []);
});
test('malformed, future versions and invalid records are refused', () => {
  for (const raw of ['{', 'null', '[]', '{"version":2,"records":[]}', '{"version":1,"records":{}}', archive([null]),
    archive([{ ...record(), createdAt: -1 }]), archive([{ ...record(), createdAt: 9000000000000000 }]),
    archive([{ ...record(), id: '' }]), archive([{ ...record(), features: '叶缘' }]), archive([record(), record()])]) {
    assert.throws(() => model.decodeArchive(raw), undefined, raw);
  }
});
test('capacity is bounded and worst-case valid payload fits application 8192-byte budget', () => {
  const records = Array.from({ length: model.MAX_RECORDS }, (_, i) => ({ ...record(`${i}`.padEnd(80, 'x')), features: model.optionsFor('叶缘').slice(0, 3) }));
  assert.ok(Buffer.byteLength(model.encodeArchive(records), 'utf8') < 8192);
  assert.throws(() => model.encodeArchive([...records, record('overflow')]));
});
test('save/restore then deletion survive a fresh storage instance', async () => {
  const first = storage(); first.store.load();
  await first.store.save([record()]);
  const second = storage(first.disk());
  assert.deepEqual(plain(second.store.load()), [record()]);
  await second.store.save([]);
  assert.deepEqual(plain(storage(second.disk()).store.load()), []);
});
test('failed save rolls cache and disk back, then permits a successful retry', async () => {
  const f = storage(archive([record()]), 1); f.store.load();
  await assert.rejects(f.store.save([record('two'), record()]));
  assert.deepEqual(plain(model.decodeArchive(f.cache())), [record()]);
  assert.deepEqual(plain(model.decodeArchive(f.disk())), [record()]);
  await f.store.save([record('two'), record()]);
  assert.equal(model.decodeArchive(f.disk()).length, 2);
});
test('failed delete retains prior records, including after reopening storage', async () => {
  const f = storage(archive([record()]), 1); f.store.load();
  await assert.rejects(f.store.save([]));
  assert.deepEqual(plain(storage(f.disk()).store.load()), [record()]);
});
test('rollback failure blocks further writes and reads until a new session', async () => {
  const f = storage(archive([record()]), 2); f.store.load();
  await assert.rejects(f.store.save([]));
  assert.equal(f.store.isReady(), false);
  const writes = f.writes();
  await assert.rejects(f.store.save([]));
  assert.throws(() => f.store.load());
  assert.equal(f.writes(), writes);
});
test('corrupt data cannot be overwritten; a read exception remains retryable', async () => {
  const f = storage('{');
  assert.throws(() => f.store.load());
  await assert.rejects(f.store.save([]));
  assert.equal(f.writes(), 0);
  const g = storage();
  const read = g.prefs.getSync;
  g.prefs.getSync = () => { throw Error('read error'); };
  assert.throws(() => g.store.load());
  g.prefs.getSync = read;
  assert.deepEqual(plain(g.store.load()), []);
});
test('concurrent writes and reads cannot race an in-flight flush', async () => {
  const f = storage(); f.store.load();
  let release;
  f.prefs.flush = () => new Promise(resolve => { release = resolve; });
  const pending = f.store.save([record()]);
  await assert.rejects(f.store.save([]));
  assert.throws(() => f.store.load());
  release(); await pending;
  assert.equal(f.store.isReady(), true);
});

test('reserved all ID cannot enter a selectable history record or reach storage', async () => {
  assert.throws(() => model.decodeArchive(archive([record('all')])));
  const f = storage(); f.store.load();
  await assert.rejects(f.store.save([record('all')]));
  assert.equal(f.writes(), 0);
});
test('UTF-8 and JSON escaping expansion cannot exceed the application archive budget', async () => {
  const tooLarge = Array.from({ length: 10 }, (_, i) => ({ ...record(`${i}${'\u0000'.repeat(79)}`), extra: '\u0000'.repeat(40), features: model.optionsFor('叶缘').slice(0, 3) }));
  assert.ok(Buffer.byteLength(archive(tooLarge), 'utf8') > 8192);
  assert.throws(() => model.encodeArchive(tooLarge));
  const f = storage(); f.store.load();
  await assert.rejects(f.store.save(tooLarge));
  assert.equal(f.writes(), 0);
  const padded = JSON.stringify({ version: 1, records: [], extra: '叶'.repeat(3000) });
  assert.ok(padded.length < 8192 && Buffer.byteLength(padded, 'utf8') > 8192);
  assert.throws(() => model.decodeArchive(padded));
});
test('archive limit counts ASCII, multibyte and supplementary codepoints exactly', () => {
  for (const value of ['x', '叶', 'é', '🌱']) {
    const base = JSON.stringify({ version: 1, records: [], note: '' });
    const budget = 8192 - Buffer.byteLength(base);
    const note = value.repeat(Math.floor(budget / Buffer.byteLength(value)));
    const raw = JSON.stringify({ version: 1, records: [], note });
    assert.deepEqual(plain(model.decodeArchive(raw)), []);
    assert.throws(() => model.decodeArchive(JSON.stringify({ version: 1, records: [], note: note + value })));
  }
});
