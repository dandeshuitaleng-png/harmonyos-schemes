// Run with DevEco's bundled Node. Exercise the production ArkTS data functions.
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const path = require('node:path');
const ts = require('/Applications/DevEco-Studio.app/Contents/tools/hvigor/hvigor/node_modules/typescript');
const source = fs.readFileSync(path.join(__dirname, '../entry/src/main/ets/model/PlantCard.ets'), 'utf8');
const output = ts.transpileModule(source, { compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2020 } }).outputText;
const moduleScope = { exports: {} };
vm.runInNewContext(output, { exports: moduleScope.exports, module: moduleScope });
const { parseCards, taskStatus, acceptCard, finishCard, recolorCard } = moduleScope.exports;
let checks = 0;
function check(name, run) { run(); checks++; process.stdout.write(`PASS ${name}\n`); }
const legacy = { id: 11, name: '窗边的绿萝', room: '客厅', task: '看看托盘', carer: '小林' };
check('legacy records load as pending without losing content', () => {
  const [card] = parseCards(JSON.stringify([legacy]));
  for (const key of Object.keys(legacy)) assert.equal(card[key], legacy[key]);
  assert.equal(taskStatus(card), '待接手');
  assert.equal(card.palette, 0);
});
check('corrupt or duplicate storage fails closed', () => {
  for (const text of ['{', '{}', '[null]', JSON.stringify([{ ...legacy, task: 7 }]), JSON.stringify([legacy, legacy])]) {
    assert.throws(() => parseCards(text));
  }
});
check('cannot complete a task before acceptance or without time', () => {
  assert.throws(() => finishCard(legacy, '今天 10:00', ''));
  assert.throws(() => finishCard(acceptCard(legacy), '  ', ''));
});
check('acceptance is separate from completion', () => {
  const accepted = acceptCard(legacy);
  assert.equal(taskStatus(accepted), '待完成');
  assert.equal(accepted.completed, false);
  assert.equal(legacy.confirmed, undefined);
});
check('completion stores the entered time and note exactly once', () => {
  const completed = finishCard(acceptCard(legacy), ' 2026-09-07 10:00 ', ' 托盘已擦干 ');
  assert.equal(taskStatus(completed), '已完成');
  assert.equal(completed.completedAt, '2026-09-07 10:00');
  assert.equal(completed.completionNote, '托盘已擦干');
  assert.throws(() => finishCard(completed, '次日', ''));
});
check('playful recoloring cannot accept or complete a task', () => {
  const colored = recolorCard(legacy, 2);
  assert.equal(colored.palette, 2);
  assert.equal(taskStatus(colored), '待接手');
  assert.equal(colored.completionNote, '');
  assert.equal(legacy.palette, undefined);
});
check('completed history and palette survive serialization', () => {
  const original = recolorCard(finishCard(acceptCard(legacy), '昨天傍晚', '原有备注'), 1);
  const [restored] = parseCards(JSON.stringify([original]));
  assert.equal(JSON.stringify(restored), JSON.stringify(original));
});
process.stdout.write(`${checks} data-contract checks passed\n`);
