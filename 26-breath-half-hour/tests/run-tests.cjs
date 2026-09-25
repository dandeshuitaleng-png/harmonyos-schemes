const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const ts = require('/Applications/DevEco-Studio.app/Contents/tools/arktsdoc/node_modules/typescript/lib/typescript.js');
const root = path.resolve(__dirname, '..');
function load(file, requireFn = require) {
  const js = ts.transpileModule(fs.readFileSync(path.join(root, file), 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 }
  }).outputText;
  const exports = {};
  vm.runInNewContext(js, { exports, require: requireFn, Date, Math, JSON, Number, Error });
  return exports;
}
const d = load('entry/src/main/ets/models/RequestDomain.ts');
let count = 0;
function test(name, run) { run(); count++; console.log('PASS ' + name); }
const item = { ...d.emptyRequest(), id: 'qa', contactId: 'c1', contactName: '亲友', date: '2030-12-31', time: '23:45', createdAt: 1, updatedAt: 1 };
test('跨年结束时间自动延后30分钟', () => assert.match(d.timeRange(item), /2031-01-01 00:15$/));
test('无效日期不能被Date自动归一化接受', () => assert.ok(Number.isNaN(d.startAt({ ...item, date: '2030-02-30' }))));
test('拒绝25点', () => assert.ok(Number.isNaN(d.startAt({ ...item, time: '25:00' }))));
test('闰年日期有效', () => assert.ok(Number.isFinite(d.startAt({ ...item, date: '2032-02-29' }))));
test('过去时间不可发送', () => assert.match(d.validateRequest(item, true, d.startAt(item) + 1), /已过/));
test('完整请求必须有联系人', () => assert.match(d.validateRequest({ ...item, contactName: ' ' }, true, 0), /联系人/));
test('完整请求必须有事项', () => assert.match(d.validateRequest({ ...item, task: ' ' }, true, 0), /事项/));
test('未完成请求允许存草稿', () => assert.equal(d.validateRequest({ ...item, date: '', time: '', contactName: '', task: '' }, false), ''));
test('空标题不能保存草稿', () => assert.match(d.validateRequest({ ...item, title: ' ' }, false), /标题/));
test('备注长度限制', () => assert.match(d.validateRequest({ ...item, note: 'x'.repeat(301) }, false), /过长/));
test('有效完整请求校验通过', () => assert.equal(d.validateRequest(item, true, 0), ''));
test('正常状态链完整', () => {
  assert.equal(d.canTransition('draft', 'pending'), true);
  assert.equal(d.canTransition('pending', 'accepted'), true);
  assert.equal(d.canTransition('accepted', 'done'), true);
});
test('不允许跳过接受直接完成', () => assert.equal(d.canTransition('draft', 'done'), false));
test('结束状态不能直接恢复或发送', () => {
  for (const state of ['done', 'cancelled', 'deferred']) assert.equal(d.canTransition(state, 'pending'), false);
});
test('活动请求可延期和取消', () => {
  for (const state of ['pending', 'accepted']) for (const next of ['deferred', 'cancelled']) assert.equal(d.canTransition(state, next), true);
});
test('请求文案包含联系人时间事项备注且不修改状态', () => {
  const next = { ...item, note: '测试补充' }; const before = JSON.stringify(next);
  const message = d.requestMessage(next);
  for (const text of ['亲友', '30分钟', '23:45', '00:15', next.task, '测试补充', '不方便']) assert.ok(message.includes(text));
  assert.equal(JSON.stringify(next), before);
});
const adapter = {
  OpenMode: { CREATE: 0, READ_WRITE: 0, TRUNC: 0 },
  accessSync: fs.existsSync, readTextSync: p => fs.readFileSync(p, 'utf8'),
  openSync: p => ({ fd: fs.openSync(p, 'w') }), writeSync: fs.writeSync,
  fsyncSync: fs.fsyncSync, closeSync: file => fs.closeSync(file.fd), renameSync: fs.renameSync
};
const { LocalRepository } = load('entry/src/main/ets/repositories/LocalRepository.ets', name => {
  if (name === '@kit.CoreFileKit') return { fileIo: adapter };
  throw Error('Unexpected import ' + name);
});
const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'breath-storage-test-'));
const repo = new LocalRepository();
const data = { version: 1, contacts: [{ id: 'c1', name: '亲友', relation: '家人' }], requests: [item] };
test('第一次启动没有演示记录', () => assert.equal(repo.load(dir).requests.length, 0));
test('保存后新实例可读取联系人和请求', () => {
  repo.save(data); assert.equal(JSON.stringify(new LocalRepository().load(dir)), JSON.stringify(data));
});
test('持久化支持大于8KB的数据', () => {
  const large = { ...data, requests: Array.from({ length: 40 }, (_, i) => ({ ...item, id: 'r' + i, note: '备'.repeat(300) })) };
  repo.save(large); assert.equal(new LocalRepository().load(dir).requests.length, 40); repo.save(data);
});
test('原子替换失败不会损坏已保存的数据', () => {
  adapter.renameSync = () => { throw Error('Simulated IO failure'); };
  assert.throws(() => repo.save({ ...data, requests: [] }));
  adapter.renameSync = fs.renameSync;
  assert.equal(new LocalRepository().load(dir).requests.length, 1);
});
test('读到损坏文件后禁止覆盖', () => {
  const p = path.join(dir, 'breath-data-v1.json'); fs.writeFileSync(p, '{broken');
  const broken = new LocalRepository(); assert.throws(() => broken.load(dir));
  assert.throws(() => broken.save(data)); assert.equal(fs.readFileSync(p, 'utf8'), '{broken');
});
test('不支持的数据版本保持不动', () => {
  fs.writeFileSync(path.join(dir, 'breath-data-v1.json'), JSON.stringify({ ...data, version: 99 }));
  assert.throws(() => new LocalRepository().load(dir));
});
console.log(`${count} tests passed. Temporary fixtures: ${dir}`);
