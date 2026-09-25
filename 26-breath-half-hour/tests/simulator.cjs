// Small HDC UI helper: node tests/simulator.cjs dump|click|input|swipe|back|shot ...
const { execFileSync } = require('node:child_process');
const fs = require('node:fs');
const hdc = '/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc';
function run(...args) { return execFileSync(hdc, ['-t', '127.0.0.1:5555', ...args], { encoding: 'utf8' }); }
function nodes() {
  run('shell', 'uitest', 'dumpLayout', '-p', '/data/local/tmp/breath-layout.json');
  run('file', 'recv', '/data/local/tmp/breath-layout.json', '/tmp/breath-layout.json');
  const all = [];
  function walk(n) { if (n.attributes) all.push(n.attributes); (n.children || []).forEach(walk); }
  walk(JSON.parse(fs.readFileSync('/tmp/breath-layout.json', 'utf8')));
  return all;
}
const [action, label, value] = process.argv.slice(2);
if (action === 'dump') console.log(nodes().filter(a => a.text || a.type === 'TextInput' || a.type === 'TextArea').map(a => `${a.type} ${a.text} ${a.bounds}`).join('\n'));
if (action === 'click' || action === 'input') {
  const n = nodes().find(a => a.text === label);
  if (!n) throw Error('Not visible: ' + label);
  const [x1, y1, x2, y2] = n.bounds.match(/\d+/g).map(Number);
  if (action === 'click') console.log(run('shell', 'uitest', 'uiInput', 'click', String((x1 + x2) >> 1), String((y1 + y2) >> 1)));
  else console.log(run('shell', 'uitest', 'uiInput', 'inputText', String((x1 + x2) >> 1), String((y1 + y2) >> 1), value));
}
if (action === 'swipe') console.log(run('shell', 'uitest', 'uiInput', 'swipe', '1100', label === 'down' ? '650' : '2350', '1100', label === 'down' ? '2350' : '650', '2000'));
if (action === 'back') console.log(run('shell', 'uitest', 'uiInput', 'keyEvent', 'Back'));
if (action === 'shot') {
  run('shell', 'snapshot_display', '-f', '/data/local/tmp/breath-qa.jpeg');
  console.log(run('file', 'recv', '/data/local/tmp/breath-qa.jpeg', value || '/tmp/breath-qa.jpeg'));
}
