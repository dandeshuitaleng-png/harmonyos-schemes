/* DevEco native Previewer capture. No browser rendering or production fixtures.
 * node scripts/native-preview.cjs --out /tmp/leafmate-preview --theme light --width 1080 --height 2340 --steps /tmp/steps.json
 * Steps: [{tap:[x,y]}, {text:'...'}, {swipe:[x1,y1,x2,y2]}, {wait:500}, {snapshot:'name'}]. Coordinates: physical pixels.
 */
const fs = require('node:fs'), net = require('node:net'), cp = require('node:child_process'), path = require('node:path');
const crypto = require('node:crypto');
const dev = process.env.DEVECO_STUDIO || '/Applications/DevEco-Studio.app/Contents';
const WS = require(path.join(dev, 'tools/hvigor/hvigor/node_modules/ws'));
const argv = process.argv.slice(2);
const option = (name, fallback) => { const i = argv.indexOf('--' + name); return i >= 0 ? argv[i + 1] : fallback; };
const project = path.resolve(__dirname, '..');
const run = path.resolve(option('out', fs.mkdtempSync('/tmp/plantrelay-native-')));
const theme = option('theme', 'light'), width = Number(option('width', 1080)), height = Number(option('height', 2340));
const density = Number(option('density', 480));
if (!['light','dark'].includes(theme) || ![width,height,density].every(n => Number.isFinite(n) && n > 0)) throw new Error('Invalid display options');
if (option('font-scale', '1') !== '1') throw new Error('Previewer font-scale command not verified; use device for font-scale coverage');
fs.mkdirSync(run, { recursive: true });
const steps = option('steps') ? JSON.parse(fs.readFileSync(option('steps'), 'utf8')) : [];
const sdk = path.join(dev, 'sdk/default'), engine = path.join(sdk, 'openharmony/previewer/common/bin');
const prefix = 'leafmate_' + process.pid + '_' + Date.now(), sock = '/tmp/' + prefix + '_commandPipe';
const output = fs.createWriteStream(path.join(run, 'engine.log'));
const abc = path.join(project, 'entry/build/default/intermediates/loader_out/default/ets/modules.abc');
const config = path.join(run, 'device-config.json');
fs.copyFileSync(path.join(dev, 'plugins/openharmony/openharmony-preview-server/deviceConfigJson/phoneSettingConfig.json'), config);
let child, ws, channel, latest, connected = false, started = false, finished = false, frameCount = 0, commandId = 0;
const trace = [], wait = ms => new Promise(resolve => setTimeout(resolve, ms));
function command(name, args) { const message = { version:'1.0.1', command:name, type:'action', args }; channel.write(JSON.stringify(message) + '\0'); trace.push(message); }
async function tap(x,y) { command('MousePress', { x,y,duration:0 }); await wait(80); command('MouseRelease',{x,y,duration:80}); await wait(500); }
async function runStep(step) {
  if (step.command) { command(step.command, step.args || {}); await wait(400); }
  if (step.keys) {
    for (const char of step.keys) {
      const upper=char.toUpperCase(), point=upper.codePointAt(0);
      const keyCode=point>=65&&point<=90?2017+point-65:point>=48&&point<=57?2000+point-48:char===' '?2050:2055;
      command('KeyPress',{isInputMethod:false,keyCode,keyAction:0,keyString:char,pressedCodes:[keyCode]});
      command('KeyPress',{isInputMethod:false,keyCode,keyAction:1,keyString:char,pressedCodes:[]});
    }
    await wait(600);
  }
  if (step.tap) await tap(...step.tap);
  if (step.text !== undefined) { for (const char of step.text) command('KeyPress',{isInputMethod:true,codePoint:char.codePointAt(0)}); await wait(500); }
  if (step.swipe) {
    const [x1,y1,x2,y2] = step.swipe;
    command('MousePress',{x:x1,y:y1,duration:0});
    for (let n=1;n<=12;n++) { await wait(25); command('MouseMove',{x:Math.round(x1+(x2-x1)*n/12),y:Math.round(y1+(y2-y1)*n/12),duration:n*25}); }
    command('MouseRelease',{x:x2,y:y2,duration:300}); await wait(700);
  }
  if (step.wait) await wait(step.wait);
  if (step.snapshot) snapshot(step.snapshot);
}
async function execute() {
  await wait(1200); snapshot('initial');
  for (const step of steps) await runStep(step);
  if (argv.includes('--interactive')) {
    const input = require('node:readline').createInterface({ input:process.stdin, terminal:false });
    console.log('READY');
    for await (const line of input) {
      const step=JSON.parse(line);
      if (step.quit) break;
      if (Array.isArray(step)) { for (const part of step) await runStep(part); } else await runStep(step);
      console.log('READY');
    }
  }
  await wait(700); snapshot('final'); finish();
}
function snapshot(name) {
  if (!latest) throw new Error('No native frame received');
  if (!/^[a-zA-Z0-9_-]+$/.test(name)) throw new Error('Invalid snapshot name');
  fs.writeFileSync(path.join(run,name+'.jpg'), latest); console.log('CAPTURE', name);
}
function connect(port) {
  if (connected || finished) return; connected=true;
  ws = new WS('ws://127.0.0.1:'+port);
  ws.on('message', data => {
    const buf=Buffer.from(data), start=buf.indexOf(Buffer.from([0xff,0xd8,0xff]));
    if (start < 0) return;
    latest=buf.subarray(start); frameCount++;
    if (!started) { started=true; execute().catch(e => { console.error(e); process.exitCode=1; finish(); }); }
  });
  ws.on('error', e => { connected=false; if (!finished) setTimeout(()=>connect(port),300); });
}
const server = net.createServer(socket => {
  channel=socket; let pending='';
  socket.on('data', data => {
    pending+=data.toString(); const messages=pending.split('\0'); pending=messages.pop();
    for (const text of messages) {
      try { const msg=JSON.parse(text); trace.push(msg); if (msg.MessageType==='imageWebsocket') connect(msg.args.port); } catch {}
    }
  });
});
server.on('error', e => { console.error(e); process.exitCode=1; finish(); });
server.listen(sock, async () => {
  const wsPort = await new Promise((resolve, reject) => {
    const probe = net.createServer(); probe.on('error', reject);
    probe.listen(0, '127.0.0.1', () => { const port = probe.address().port; probe.close(() => resolve(port)); });
  });
  const args=['-refresh','full','-projectID','22','-ts',prefix+'_trace','-j',path.dirname(abc),'-s',prefix,'-cpm','false','-device','phone','-shape','rect','-sd',String(density),'-or',String(width),String(height),'-cr',String(width),String(height),'-f',config,'-n','entry','-av','ACE_2_0','-url','pages/Index','-pages','main_pages','-arp',path.join(project,'entry/build/default/intermediates/res/default'),'-pm','Stage','-l','zh_CN','-cm',theme,'-o',width>height?'landscape':'portrait','-ljPath',path.join(project,'entry/build/default/intermediates/loader/default/loader.json'),'-lws',String(wsPort),'-hsp',path.join(sdk,'hms/previewer'),'-ilt','true'];
  const manifest={timestamp:new Date().toISOString(),project,abcSha256:crypto.createHash('sha256').update(fs.readFileSync(abc)).digest('hex'),width,height,density,theme,locale:'zh_CN',fontScale:1,renderer:'DevEco native Previewer',executable:path.join(engine,'Previewer'),args};
  fs.writeFileSync(path.join(run,'manifest.json'),JSON.stringify(manifest,null,2));
  console.log('RUN',run);
  child=cp.spawn(manifest.executable,args,{cwd:engine}); child.stdout.pipe(output); child.stderr.pipe(output);
  child.on('error', e=>{console.error(e);process.exitCode=1;finish();});
  child.on('exit', (code,signal)=>{ if (!finished) { console.error('Previewer exited',code,signal);process.exitCode=1;finish(); } });
});
function finish() {
  if (finished) return; finished=true;
  fs.writeFileSync(path.join(run,'trace.json'),JSON.stringify({frameCount,commands:trace},null,2));
  try { ws?.close(); channel?.destroy(); child?.kill('SIGTERM'); } catch {}
  server.close(); try { fs.unlinkSync(sock); } catch {}
  setTimeout(()=>process.exit(process.exitCode || 0),200);
}
setTimeout(()=>{ if (!finished) { console.error('Native preview timed out');process.exitCode=1;finish(); } },argv.includes('--interactive') ? 600000 : Math.max(25000,steps.length*1300+15000));
process.on('SIGTERM',finish); process.on('SIGINT',finish);
