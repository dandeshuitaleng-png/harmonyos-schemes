// Read-only project audit; writes evidence only when the caller redirects stdout.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const cp = require('child_process');
const json5 = require('/Applications/DevEco-Studio.app/Contents/tools/hvigor/hvigor-ohos-plugin/node_modules/json5');
const root = path.resolve(__dirname, '../../../..');
const required = ['AppScope/app.json5', 'AppScope/resources/base/element/string.json',
  'build-profile.json5', 'oh-package.json5', 'hvigorfile.ts', 'hvigor/hvigor-config.json5',
  'entry/build-profile.json5', 'entry/oh-package.json5', 'entry/hvigorfile.ts',
  'entry/src/main/module.json5', 'entry/src/main/ets/EntryAbility.ets',
  'entry/src/main/ets/pages/Index.ets', 'entry/src/main/resources/base/profile/main_pages.json',
  'entry/src/main/resources/base/element/color.json', 'entry/src/main/resources/base/media/app_icon.svg'];
const read = p => json5.parse(fs.readFileSync(p, 'utf8'));
const schemes = fs.readdirSync(root).filter(n => /^\d+-/.test(n) && fs.statSync(path.join(root,n)).isDirectory()).sort((a,b) => parseInt(b)-parseInt(a));
console.log('RUN', new Date().toISOString(), 'ROOT', root);
for (const n of schemes) {
  const p = path.join(root, n);
  const absentConventionalPaths = required.filter(f => !fs.existsSync(path.join(p,f)));
  const alternatives = {};
  // An existing project may use a .ts ability or an AppScope PNG icon.
  // Resolve its declared files before reporting a real missing skeleton file.
  if (absentConventionalPaths.includes('entry/src/main/ets/EntryAbility.ets')) {
    const mod=read(path.join(p,'entry/src/main/module.json5')).module;
    const ability=(mod.abilities || []).find(a=>a.name===mod.mainElement);
    if (ability && fs.existsSync(path.join(p,'entry/src/main',ability.srcEntry))) alternatives['entry/src/main/ets/EntryAbility.ets']=path.normalize('entry/src/main/'+ability.srcEntry);
  }
  if (absentConventionalPaths.includes('entry/src/main/resources/base/media/app_icon.svg')) {
    const icon=read(path.join(p,'AppScope/app.json5')).app.icon?.replace('$media:','');
    for (const media of ['AppScope/resources/base/media','entry/src/main/resources/base/media']) {
      const dir=path.join(p,media);
      const match=fs.existsSync(dir) && fs.readdirSync(dir).find(f=>path.parse(f).name===icon);
      if (match) alternatives['entry/src/main/resources/base/media/app_icon.svg']=media+'/'+match;
    }
  }
  const missing=absentConventionalPaths.filter(f=>!alternatives[f]);
  console.log('INVENTORY', n, JSON.stringify({required: required.length, missing, alternatives, workflow: fs.existsSync(path.join(p,'docs/workflow'))}));
}
let failures = 0;
for (const n of schemes.slice(0,3)) {
  const p = path.join(root,n);
  const parsed = {};
  for (const f of required.filter(f => /\.json5?$/.test(f))) {
    try { parsed[f] = read(path.join(p,f)); console.log('PARSE_PASS', n, f); }
    catch(e) { failures++; console.log('PARSE_FAIL',n,f,e.message); }
  }
  const mod = parsed['entry/src/main/module.json5'].module;
  const config = parsed['build-profile.json5'];
  const ability = mod.abilities.find(a => a.name === mod.mainElement);
  const hasHomeSkill = (ability.skills || []).some(s => (s.actions || []).includes('ohos.want.action.home') && (s.entities || []).includes('entity.system.home'));
  const pages = parsed['entry/src/main/resources/base/profile/main_pages.json'].src;
  const entryExists = fs.existsSync(path.join(p,'entry/src/main',ability.srcEntry));
  const routesExist = pages.every(page => fs.existsSync(path.join(p,'entry/src/main/ets',page+'.ets')));
  const stageMode = parsed['entry/build-profile.json5'].apiType === 'stageMode';
  const moduleTarget = (config.modules || []).some(m => m.name === 'entry' && m.srcPath === './entry');
  console.log('CONFIG',n,JSON.stringify({stageMode,moduleTarget,entryExists,routesExist,pages,hasHomeSkill,deviceTypes:mod.deviceTypes,permissions:mod.requestPermissions || [],signingConfigCount:(config.app.signingConfigs || []).length,products:config.app.products.map(x=>({name:x.name,compileSdkVersion:x.compileSdkVersion,compatibleSdkVersion:x.compatibleSdkVersion,runtimeOS:x.runtimeOS}))}));
  if (!hasHomeSkill) { failures++; console.log('CONFIG_FAIL',n,'No launcher home action/entity skill on main ability; compare installed DevEco Empty Ability template.'); }
  if (!stageMode || !moduleTarget || !entryExists || !routesExist) failures++;
}
const target = path.join(root,'23-repairpassport');
const walk = dir => fs.readdirSync(dir).sort().flatMap(n => {
  const f=path.join(dir,n); return fs.statSync(f).isDirectory()?walk(f):[f];
});
const files = [...new Set(required.map(f=>path.join(target,f)).concat(walk(path.join(target,'entry/src')),walk(path.join(target,'AppScope'))))].sort();
const hashes = files.map(f=>[path.relative(target,f),crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex')]);
console.log('SOURCE_MANIFEST', JSON.stringify(hashes));
for (const f of walk(path.join(target,'entry/src/main/ets'))) {
  const text=fs.readFileSync(f,'utf8');
  console.log('IMPORTS',path.relative(target,f),JSON.stringify(text.match(/import[^;]+;/g)||[]));
}
function run(command,args,timeout=10000) {
  const r=cp.spawnSync(command,args,{cwd:root,encoding:'utf8',timeout,killSignal:'SIGKILL',env:{...process.env,GIT_OPTIONAL_LOCKS:'0'}});
  console.log('COMMAND',JSON.stringify([command,...args]));
  console.log(JSON.stringify({status:r.status,signal:r.signal,error:r.error?.code,stdout:r.stdout,stderr:r.stderr}));
}
run('git',['status','--short']);
run('git',['log','-3','--format=%h %s %cI','--name-only']);
run('git',['log','-1','--format=%H %s %cI','--','23-repairpassport']);
run('/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc',['list','targets'],8000);
console.log('CONFIG_FAILURE_COUNT',failures);
process.exitCode=failures?2:0;
