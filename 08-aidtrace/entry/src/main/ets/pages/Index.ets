import { PrivacyChoiceStore, PRIVACY_ACCEPTED } from '../data/PrivacyChoiceStore';

interface BatchType { id: string; title: string; }
interface SessionDraft { id: number; title: string; }
const TYPES: BatchType[] = [
  { id: 'hygiene', title: '清洁卫生物资' },
  { id: 'warmth', title: '保暖生活物资' },
  { id: 'emergency', title: '应急基础物资' }
];

@Entry
@Component
struct Index {
  private readonly privacyStore: PrivacyChoiceStore = new PrivacyChoiceStore();
  @State private selectedId: string = TYPES[0].id;
  @State private sessionDrafts: SessionDraft[] = [];
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
  private selectedType(): BatchType {
    for (let index = 0; index < TYPES.length; index += 1) if (TYPES[index].id === this.selectedId) return TYPES[index];
    return TYPES[0];
  }
  private createDraft(): void {
    const selected = this.selectedType();
    const draft: SessionDraft = { id: this.sessionDrafts.length + 1, title: selected.title };
    this.sessionDrafts = [draft, ...this.sessionDrafts];
  }
  private async loadPrivacy(): Promise<void> {
    const context = this.getUIContext().getHostContext();
    if (!context) { this.actionError = '当前页面上下文不可用。请返回后重新进入；不会创建草稿。'; this.privacyReady = true; return; }
    try { this.privacyChoice = await this.privacyStore.load(context); }
    catch { this.actionError = '无法读取本机隐私选择。请重试；草稿离开页面即清除。'; }
    finally { this.privacyReady = true; }
  }
  private async acceptPrivacy(): Promise<void> {
    const context = this.getUIContext().getHostContext();
    if (!context) { this.actionError = '当前页面上下文不可用。请返回后重新进入；不会保存任何选择。'; return; }
    try {
      await this.privacyStore.saveAccepted(context);
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.actionError = '';
    } catch { this.actionError = '无法保存“已阅读”标记。请重试；不会记录捐赠者或金额。'; }
  }

  @Builder
  policyView() {
    Column({ space: 16 }) {
      Text('隐私说明').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('善款明细 · com.harmonyradar.aidtrace').fontSize(16).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('本页不记录捐赠者、受助者、联系方式或款项金额，也没有导出或公开账本。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('会话草稿离开页面即清除。本机仅可能保存你已阅读本说明的标记。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Text('本应用不提供募资、代币或链上交易。开发者主体名称以应用市场登记信息为准。').fontSize(14).fontColor($r('app.color.text_secondary'))
      Button('已阅读并继续').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
        .onClick(() => this.acceptPrivacy())
      Text('如暂不使用，请停留在本页。').fontSize(14).fontColor($r('app.color.text_secondary'))
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
      Text('善款明细').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('隐私优先的物资批次会话草稿').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('本页不记录捐赠者、受助者或联系方式').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('不记录款项金额，也没有附件、签名、公开页面、导出或异常判定；所有异常必须以后续人工复核处理。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text('选择物资批次类别').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(TYPES, (type: BatchType) => {
          Button(type.title).fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).width('100%').padding(15).borderRadius(15)
            .backgroundColor(this.selectedId === type.id ? $r('app.color.surface_notice') : $r('app.color.surface_card'))
            .onClick(() => this.selectedId = type.id)
        }, (type: BatchType) => type.id)
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Button('创建本次会话草稿').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 54 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15).onClick(() => this.createDraft())
      Column({ space: 8 }) {
        Text('草稿状态').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        if (this.sessionDrafts.length === 0) {
          Text('尚未创建会话草稿。不会生成资金、捐助者或受助者账目。').fontSize(16).fontColor($r('app.color.text_draft'))
        } else {
          Text(`本次会话内已有 ${this.sessionDrafts.length} 条去身份化草稿。`).fontSize(16).fontColor($r('app.color.text_draft'))
          ForEach(this.sessionDrafts, (draft: SessionDraft) => {
            Text(`草稿 ${draft.id} · ${draft.title} · 数量待人工填写与复核`).fontSize(14).fontColor($r('app.color.text_primary'))
          }, (draft: SessionDraft) => draft.id.toString())
        }
        Text('离开本页后草稿不会保留。未来若接入保存，仍只能由工作人员补全数量和处理阶段，并进入人工复核；不能公开或导出。').fontSize(14).fontColor($r('app.color.text_secondary'))
      }.padding(20).backgroundColor($r('app.color.surface_draft')).borderRadius(20).width('100%')
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
