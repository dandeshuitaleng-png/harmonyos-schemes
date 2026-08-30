import { common, Want } from '@kit.AbilityKit';
import { HelpCard, HelpCardStore, PRIVACY_ACCEPTED, PRIVACY_DECLINED } from '../data/HelpCardStore';

interface HelpTemplate { id: string; title: string; message: string; }

const TEMPLATES: HelpTemplate[] = [
  { id: 'need-assistance', title: '我需要协助', message: '我现在需要协助，请与我确认是否安全。' },
  { id: 'need-quiet-space', title: '我需要安静空间', message: '我现在不方便说话，需要一个安静、可停留的地方。' },
  { id: 'please-stay', title: '请先陪伴我', message: '我现在感到不安，请先留在我身边并确认我的状态。' }
];

@Entry
@Component
struct Index {
  private readonly cardStore: HelpCardStore = new HelpCardStore();
  @State private selectedTemplateId: string = TEMPLATES[0].id;
  @State private activeCard: HelpCard | undefined = undefined;
  @State private isLoading: boolean = true;
  @State private storageError: string = '';
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;

  aboutToAppear(): void { this.bootstrap(); }

  onBackPress(): boolean {
    if (this.showPolicy && this.privacyChoice.length > 0) {
      this.showPolicy = false;
      return true;
    }
    return false;
  }

  private currentTemplate(): HelpTemplate {
    for (let index = 0; index < TEMPLATES.length; index += 1) {
      if (TEMPLATES[index].id === this.selectedTemplateId) return TEMPLATES[index];
    }
    return TEMPLATES[0];
  }

  private isKnownCard(card: HelpCard): boolean {
    for (let index = 0; index < TEMPLATES.length; index += 1) {
      const template = TEMPLATES[index];
      if (template.id === card.templateId && template.message === card.message) return true;
    }
    return false;
  }

  private now(): string {
    const date = new Date();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    return `${date.getFullYear()}-${month}-${day} ${hour}:${minute}`;
  }

  private async bootstrap(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      this.privacyChoice = await this.cardStore.loadPrivacyChoice(getContext(this));
      this.privacyReady = true;
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        await this.loadCard();
        return;
      }
      this.activeCard = undefined;
    } catch {
      this.privacyReady = true;
      this.storageError = '无法读取本机隐私选择。请重试；没有向外发送任何信息。';
    } finally {
      this.isLoading = false;
    }
  }

  private async loadCard(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      const loaded = await this.cardStore.load(getContext(this));
      if (loaded !== undefined && !this.isKnownCard(loaded)) {
        this.activeCard = undefined;
        this.storageError = '发现无法确认来源的本机卡片，未显示或发送该内容。请重新选择模板。';
      } else {
        this.activeCard = loaded;
      }
    } catch {
      this.storageError = '无法读取本机求助卡。请重试；没有向外发送任何信息。';
    } finally {
      this.isLoading = false;
    }
  }

  private async acceptPrivacy(): Promise<void> {
    try {
      await this.cardStore.savePrivacyChoice(getContext(this), PRIVACY_ACCEPTED);
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.storageError = '';
      await this.loadCard();
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有向外发送任何信息。';
    }
  }

  private async declinePrivacy(): Promise<void> {
    try {
      await this.cardStore.savePrivacyChoice(getContext(this), PRIVACY_DECLINED);
      this.privacyChoice = PRIVACY_DECLINED;
      this.showPolicy = false;
      this.activeCard = undefined;
      this.storageError = '';
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有向外发送任何信息。';
    }
  }

  private async createCard(): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) return;
    const selected = this.currentTemplate();
    const card: HelpCard = { templateId: selected.id, message: selected.message, createdAt: this.now() };
    try {
      await this.cardStore.save(getContext(this), card);
      this.activeCard = card;
      this.storageError = '';
    } catch {
      this.storageError = '无法保存本机求助卡。请重试；信息没有被发送。';
    }
  }

  private async cancelCard(): Promise<void> {
    if (this.isLoading) return;
    try {
      await this.cardStore.clear(getContext(this));
      this.activeCard = undefined;
      this.storageError = '';
    } catch {
      this.storageError = '无法取消本机求助卡。请重试；没有向外发送任何信息。';
    }
  }

  private async openSystemDialer(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const want: Want = { action: 'ohos.want.action.dial', uri: 'tel:' };
      await context.startAbility(want);
    } catch {
      this.storageError = '无法打开系统电话。请退出本应用，使用系统电话或线下求助。';
    }
  }

  @Builder
  policyView() {
    Column({ space: 16 }) {
      Text('隐私说明').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('静默信标 · com.harmonyradar.quietbeacon').fontSize(16).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('本应用只在本机生成可读求助卡，不是报警平台，也不表示已通知任何机构。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('不申请短信、联系人、位置、相机或麦克风权限，也不接入网络、账号或第三方 SDK。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 8 }) {
        Text('若你同意并继续，本机可能保存：所选模板编号、预设文案、创建时间，以及你对隐私说明的选择。').fontSize(15).fontColor($r('app.color.text_primary'))
        Text('不保存位置、联系人或发送记录。你可以随时取消当前求助卡。开发者主体名称以应用市场登记信息为准。').fontSize(15).fontColor($r('app.color.text_primary'))
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Button('同意并继续').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
        .accessibilityText('同意隐私说明并允许保存本机求助卡').onClick(() => this.acceptPrivacy())
      Button('仅查看模板，不保存求助卡').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .accessibilityText('拒绝保存本机求助卡').onClick(() => this.declinePrivacy())
      if (this.privacyChoice.length > 0) {
        Button('返回').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.showPolicy = false)
      }
      if (this.storageError.length > 0) {
        Text(this.storageError).fontSize(14).fontColor($r('app.color.text_notice')).padding(14).backgroundColor($r('app.color.surface_notice')).borderRadius(14).width('100%')
      }
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%').constraintSize({ maxWidth: 640 })
  }

  @Builder
  mainView() {
    Column({ space: 16 }) {
      Text('静默信标').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('为不便语音表达的时刻准备一张本机求助卡。').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('紧急情况请直接使用系统电话或线下求助').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('本页不会发送短信、联系联系人、读取位置，也不表示已通知任何机构。').fontSize(14).fontColor($r('app.color.text_notice'))
        Button('打开系统电话').fontSize(16).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 48 })
          .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
          .accessibilityText('打开系统电话拨号界面').onClick(() => this.openSystemDialer())
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text('选择一句你想表达的话').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(TEMPLATES, (item: HelpTemplate) => {
          Button() {
            Column({ space: 5 }) {
              Text(item.title).fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
              Text(item.message).fontSize(14).fontColor($r('app.color.text_secondary')).maxLines(2)
            }.alignItems(HorizontalAlign.Start).width('100%')
          }.width('100%').padding(15).borderRadius(15)
           .backgroundColor(this.selectedTemplateId === item.id ? $r('app.color.action_selected') : $r('app.color.surface_card'))
           .onClick(() => this.selectedTemplateId = item.id)
        }, (item: HelpTemplate) => item.id)
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Button(this.isLoading ? '正在读取本机状态…' : '生成本机求助卡')
          .fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 54 })
          .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
          .enabled(!this.isLoading).accessibilityText('生成本机求助卡，不向外发送')
          .onClick(() => this.createCard())
      } else {
        Text('你选择不保存本机求助卡。仍可查看模板，或打开系统电话。').fontSize(15).fontColor($r('app.color.text_secondary'))
        Button('阅读隐私说明并允许保存').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
          .onClick(() => this.showPolicy = true)
      }
      Column({ space: 9 }) {
        Text('当前求助卡').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        if (this.privacyChoice !== PRIVACY_ACCEPTED) {
          Text('当前未开启本机保存，因此不读取或显示求助卡。').fontSize(15).fontColor($r('app.color.text_muted'))
        } else if (this.isLoading) {
          Text('正在读取本机保存的状态。').fontSize(15).fontColor($r('app.color.text_muted'))
        } else if (this.activeCard === undefined) {
          Text('尚未生成求助卡。选择模板后即可在本机生成，并且可随时取消。').fontSize(15).fontColor($r('app.color.text_muted'))
        } else {
          Text(this.activeCard.message).fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
          Text(`${this.activeCard.createdAt} · 仅保存在本机，未发送`).fontSize(14).fontColor($r('app.color.text_success'))
          Button('取消这张本机求助卡').fontSize(15).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
            .accessibilityText('取消并删除本机求助卡').onClick(() => this.cancelCard())
        }
      }.padding(20).backgroundColor(this.activeCard === undefined ? $r('app.color.surface_card') : $r('app.color.surface_success')).borderRadius(20).width('100%')
      if (this.storageError.length > 0) {
        Column({ space: 8 }) {
          Text(this.storageError).fontSize(14).fontColor($r('app.color.text_notice'))
          Button('重试读取本机状态').fontSize(15).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.bootstrap())
        }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(16).width('100%')
      }
      Button('查看隐私说明').fontSize(15).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.showPolicy = true)
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%').constraintSize({ maxWidth: 640 })
  }

  build() {
    Scroll() {
      Column() {
        if (!this.privacyReady) {
          Text('正在读取本机状态…').fontSize(16).fontColor($r('app.color.text_secondary')).padding(28)
        } else if (this.privacyChoice.length === 0 || this.showPolicy) {
          this.policyView()
        } else {
          this.mainView()
        }
      }.width('100%').alignItems(HorizontalAlign.Center)
    }.width('100%').height('100%').backgroundColor($r('app.color.surface_canvas')).align(Alignment.Top)
     .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]).scrollBar(BarState.Auto)
  }
}
