import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
export default class EntryAbility extends UIAbility { onWindowStageCreate(stage: window.WindowStage): void { stage.loadContent('pages/Index', (err) => { if (err) { console.error(`Load page failed: ${JSON.stringify(err)}`); } }); } }
