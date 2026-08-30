import { common, Want } from '@kit.AbilityKit';
import { PrivacyChoiceStore, PRIVACY_ACCEPTED } from '../data/PrivacyChoiceStore';

interface ToolTemplate { id: string; title: string; detail: string; }

const TOOLS: ToolTemplate[] = [
  { id: 'large-text', title: '文字辅助模板', detail: '规划用于短标签或说明文字；当前未接入相机或朗读能力。' },
  { id: 'color', title: '颜色描述模板', detail: '规划用于单个物品；当前未接入相机，不会输出颜色结果。' },
  { id: 'medicine', title: '药盒标签模板', detail: '规划用于包装文字；当前不读取内容，也不提供药品、剂量或诊断建议。' }
];

@Entry
@Component
struct Index {
  private readonly privacyStore: PrivacyChoiceStore = new PrivacyChoiceStore();
  @State private selectedId: string = TOOLS[0].id;
  @State private sessionMessage: string = '尚未开始查看模板。当前版本不会调用相机或模型。';
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;
  @State private actionError: string = '';

  aboutToAppear(): void { this.loadPrivacy(); }

  onBackPress(): boolean {
    if (this.showPolicy && this.privacyChoice === PRIVACY_ACCEPTED) {
      this.showPolicy = false;
      return true;
    }
    return false;
  }

  private selectedTool(): ToolTemplate {
    for (let index = 0; index < TOOLS.length; index += 1) if (TOOLS[index].id === this.selectedId) return TOOLS[index];
    return TOOLS[0];
  }

  private async loadPrivacy(): Promise<void> {
    try {
      this.privacyChoice = await this.privacyStore.load(getContext(this));
    } catch {
      this.actionError = '无法读取本机隐私选择。请重试；不会保存任何素材。';
    } finally {
      this.privacyReady = true;
    }
  }

  private async acceptPrivacy(): Promise<void> {
    try {
      await this.privacyStore.saveAccepted(getContext(this));
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.actionError = '';
    } catch {
      this.actionError = '无法保存“已阅读”标记。请重试；不会保存相机或识别素材。';
    }
  }

  private beginSafeCheck(): void {
    const tool = this.selectedTool();
    this.sessionMessage = `无法确认：${tool.title} 尚未接入相机或识别服务。请重新检查实物，或联系可信的人协助。`;
  }

  private async openSystemDialer(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const want: Want = { action: 'ohos.want.action.dial', uri: 'tel:' };
      await context.startAbility(want);
    } catch {
      this.actionError = '无法打开系统电话。请退出本应用，咨询医生、药师或当地急救服务。';
    }
  }

  @Builder
  policyView() {
    Column({ space: 16 }) {
      Text('隐私说明').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('盲行工坊 · com.harmonyradar.sensecraft').fontSize(16).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('当前版本没有相机、OCR、AI 或云端服务，也不会保存任何素材。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('药盒模板不提供医疗建议。本机仅可能保存你已阅读本说明的标记。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Text('开发者主体名称以华为应用市场登记信息为准。公开隐私政策网址尚未提供。').fontSize(14).fontColor($r('app.color.text_secondary'))
      Button('已阅读并继续').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
        .accessibilityText('确认已阅读隐私说明并继续').onClick(() => this.acceptPrivacy())
      Text('如暂不使用，请停留在本页。不会开始任何采集。').fontSize(14).fontColor($r('app.color.text_secondary'))
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Button('返回').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.showPolicy = false)
      }
      if (this.actionError.length > 0) {
        Text(this.actionError).fontSize(14).fontColor($r('app.color.text_notice')).padding(14).backgroundColor($r('app.color.surface_notice')).borderRadius(14).width('100%')
      }
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%').constraintSize({ maxWidth: 640 })
  }

  @Builder
  mainView() {
    Column({ space: 16 }) {
      Text('盲行工坊').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('受控的低视力辅助工具模板').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('无法确认时，不会猜测或生成建议').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('本版本没有相机、OCR、AI、云端服务或人脸识别；不会保存任何素材。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text('选择一个辅助工具').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(TOOLS, (tool: ToolTemplate) => {
          Button() {
            Column({ space: 5 }) {
              Text(tool.title).fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
              Text(tool.detail).fontSize(14).fontColor($r('app.color.text_secondary')).maxLines(2)
            }.alignItems(HorizontalAlign.Start).width('100%')
          }.width('100%').padding(15).borderRadius(15)
           .backgroundColor(this.selectedId === tool.id ? $r('app.color.surface_choice') : $r('app.color.surface_card'))
           .onClick(() => { this.selectedId = tool.id; this.sessionMessage = `已选择：${tool.title}。尚未调用相机或识别服务。`; })
        }, (tool: ToolTemplate) => tool.id)
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Button('查看当前模板不可用说明').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 54 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
        .accessibilityText('查看当前模板不可用说明，不会启动相机').onClick(() => this.beginSafeCheck())
      Column({ space: 8 }) {
        Text('当前不可用状态').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        Text(this.sessionMessage).fontSize(16).fontColor($r('app.color.text_selected'))
        Text('人工替代路径：再次查看实物、开启设备辅助功能，或联系可信的人。').fontSize(14).fontColor($r('app.color.text_secondary'))
      }.padding(20).backgroundColor($r('app.color.surface_choice')).borderRadius(20).width('100%')
      Text('药盒工具不会提供医疗建议；在紧急或用药不确定时，请咨询医生、药师或当地急救服务。').fontSize(14).fontColor($r('app.color.text_secondary'))
      Button('打开系统电话').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .accessibilityText('打开系统电话拨号界面').onClick(() => this.openSystemDialer())
      if (this.actionError.length > 0) {
        Text(this.actionError).fontSize(14).fontColor($r('app.color.text_notice')).padding(14).backgroundColor($r('app.color.surface_notice')).borderRadius(14).width('100%')
      }
      Button('查看隐私说明').fontSize(15).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.showPolicy = true)
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%').constraintSize({ maxWidth: 640 })
  }

  build() {
    Scroll() {
      Column() {
        if (!this.privacyReady) {
          Text('正在读取本机状态…').fontSize(16).fontColor($r('app.color.text_secondary')).padding(28)
        } else if (this.privacyChoice !== PRIVACY_ACCEPTED || this.showPolicy) {
          this.policyView()
        } else {
          this.mainView()
        }
      }.width('100%').alignItems(HorizontalAlign.Center)
    }.width('100%').height('100%').backgroundColor($r('app.color.surface_canvas')).align(Alignment.Top)
     .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]).scrollBar(BarState.Auto)
  }
}
