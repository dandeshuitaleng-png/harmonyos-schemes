// Read-only skeleton/configuration audit for the three newest schemes.
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const json5 = require('/Applications/DevEco-Studio.app/Contents/tools/hvigor/hvigor-ohos-plugin/node_modules/json5');

const root = path.resolve(__dirname, '../../../..');
const targetName = '24-visitready';
const target = path.join(root, targetName);
const required = [
  'AppScope/app.json5', 'AppScope/resources/base/element/string.json',
  'build-profile.json5', 'oh-package.json5', 'hvigorfile.ts', 'hvigor/hvigor-config.json5',
  'entry/build-profile.json5', 'entry/oh-package.json5', 'entry/hvigorfile.ts',
  'entry/src/main/module.json5', 'entry/src/main/ets/EntryAbility.ets',
  'entry/src/main/ets/pages/Index.ets', 'entry/src/main/resources/base/profile/main_pages.json',
  'entry/src/main/resources/base/element/color.json', 'entry/src/main/resources/base/media/app_icon.svg'
];
const parse = file => json5.parse(fs.readFileSync(file, 'utf8'));
const walk = dir => fs.readdirSync(dir).sort().flatMap(name => {
  const file = path.join(dir, name);
  return fs.statSync(file).isDirectory() ? walk(file) : [file];
});
const schemes = fs.readdirSync(root)
  .filter(name => /^\d+-/.test(name) && fs.statSync(path.join(root, name)).isDirectory())
  .sort((a, b) => parseInt(b) - parseInt(a));
let failures = 0;

console.log('RUN', new Date().toISOString(), 'ROOT', root, 'SCHEME_COUNT', schemes.length);
for (const name of schemes) {
  const project = path.join(root, name);
  const absent = required.filter(file => !fs.existsSync(path.join(project, file)));
  const alternatives = {};
  if (absent.includes('entry/src/main/ets/EntryAbility.ets')) {
    const module = parse(path.join(project, 'entry/src/main/module.json5')).module;
    const ability = module.abilities.find(item => item.name === module.mainElement);
    const declared = ability && path.join(project, 'entry/src/main', ability.srcEntry);
    if (declared && fs.existsSync(declared)) alternatives['entry/src/main/ets/EntryAbility.ets'] = path.relative(project, declared);
  }
  if (absent.includes('entry/src/main/resources/base/media/app_icon.svg')) {
    const app = parse(path.join(project, 'AppScope/app.json5')).app;
    const iconName = (app.icon || '').replace('$media:', '');
    for (const mediaPath of ['AppScope/resources/base/media', 'entry/src/main/resources/base/media']) {
      const media = path.join(project, mediaPath);
      const match = fs.existsSync(media) && fs.readdirSync(media).find(file => path.parse(file).name === iconName);
      if (match) alternatives['entry/src/main/resources/base/media/app_icon.svg'] = path.join(mediaPath, match);
    }
  }
  const missing = absent.filter(file => !alternatives[file]);
  console.log('INVENTORY', name, JSON.stringify({ required: required.length, missing, alternatives, workflow: fs.existsSync(path.join(project, 'docs/workflow')) }));
  if (missing.length > 0) failures += missing.length;
}

for (const name of schemes.slice(0, 3)) {
  const project = path.join(root, name);
  const module = parse(path.join(project, 'entry/src/main/module.json5')).module;
  const appBuild = parse(path.join(project, 'build-profile.json5'));
  const entryBuild = parse(path.join(project, 'entry/build-profile.json5'));
  const pages = parse(path.join(project, 'entry/src/main/resources/base/profile/main_pages.json')).src;
  const ability = module.abilities.find(item => item.name === module.mainElement);
  const skills = ability.skills || [];
  const homeActions = skills.flatMap(skill => skill.actions || []).filter(action => action === 'action.system.home' || action === 'ohos.want.action.home');
  const homeEntity = skills.some(skill => (skill.entities || []).includes('entity.system.home'));
  const routesExist = pages.every(page => fs.existsSync(path.join(project, 'entry/src/main/ets', `${page}.ets`)));
  const abilityExists = fs.existsSync(path.join(project, 'entry/src/main', ability.srcEntry));
  const moduleTarget = (appBuild.modules || []).some(item => item.name === 'entry' && item.srcPath === './entry');
  const result = {
    mainElement: module.mainElement, stageMode: entryBuild.apiType === 'stageMode', moduleTarget,
    abilityExists, routesExist, pages, homeActions, homeEntity, exported: ability.exported,
    deviceTypes: module.deviceTypes, permissions: module.requestPermissions || [],
    signingConfigCount: (appBuild.app.signingConfigs || []).length,
    products: appBuild.app.products.map(item => ({ name: item.name, compileSdkVersion: item.compileSdkVersion, compatibleSdkVersion: item.compatibleSdkVersion, targetSdkVersion: item.targetSdkVersion, runtimeOS: item.runtimeOS }))
  };
  console.log('CONFIG', name, JSON.stringify(result));
  if (!result.stageMode || !result.moduleTarget || !abilityExists || !routesExist || homeActions.length === 0 || !homeEntity || ability.exported !== true) failures++;
  if (homeActions.length === 1 && homeActions[0] === 'action.system.home') console.log('CONFIG_NOTE', name, 'legacy Home action accepted by current package-entry rules; consider current action on a future authorized config task');
}

const sourceRoots = ['AppScope', 'entry/src', 'build-profile.json5', 'oh-package.json5', 'hvigorfile.ts', 'hvigor'];
const files = sourceRoots.flatMap(relative => {
  const file = path.join(target, relative);
  return fs.statSync(file).isDirectory() ? walk(file) : [file];
}).sort();
const manifest = files.map(file => [path.relative(target, file), crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex')]);
console.log('SOURCE_MANIFEST', JSON.stringify(manifest));

const etsText = walk(path.join(target, 'entry/src/main/ets')).map(file => fs.readFileSync(file, 'utf8')).join('\n');
const restricted = ['@kit.LocationKit', '@kit.CameraKit', '@kit.PushKit', '@kit.NetworkKit', '@ohos.net.http', 'DocumentViewPicker', 'PhotoViewPicker', 'systemShare'];
console.log('RESTRICTED_IMPORT_MATCHES', JSON.stringify(restricted.filter(item => etsText.includes(item))));
console.log('CONFIG_FAILURE_COUNT', failures);
process.exitCode = failures === 0 ? 0 : 2;
