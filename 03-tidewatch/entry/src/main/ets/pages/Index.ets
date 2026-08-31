import { common, Want } from '@kit.AbilityKit';
import { ObservationDraft, ObservationStore, PRIVACY_ACCEPTED, PRIVACY_DECLINED } from '../data/ObservationStore';

@Entry
@Component
struct Index {
  private readonly observationStore: ObservationStore = new ObservationStore();
  @State private drafts: ObservationDraft[] = [];
  @State private isLoading: boolean = true;
  @State private storageError: string = '';
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;
  @State private confirmClear: boolean = false;

  aboutToAppear(): void { this.bootstrap(); }

  onBackPress(): boolean {
    if (this.showPolicy && this.privacyChoice.length > 0) {
      this.showPolicy = false;
      return true;
    }
    if (this.confirmClear) {
      this.confirmClear = false;
      return true;
    }
    return false;
  }

  private timestampAt(offsetMinutes: number): string {
    return new Date(Date.now() + offsetMinutes * 60 * 1000).toISOString();
  }

  private formatTimestamp(timestamp: string): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }

  private isSafeActiveDraft(draft: ObservationDraft): boolean {
    if (draft.id <= 0 || draft.source !== '现场巡查员本地记录' || draft.status !== '待审核 · 不公开') return false;
    const collectedAt = new Date(draft.collectedAt).getTime();
    const expiresAt = new Date(draft.expiresAt).getTime();
    return Number.isFinite(collectedAt) && Number.isFinite(expiresAt) && collectedAt <= expiresAt && expiresAt > Date.now();
  }

  private async bootstrap(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      this.privacyChoice = await this.observationStore.loadPrivacyChoice(getContext(this));
      this.privacyReady = true;
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        await this.loadDrafts();
        return;
      }
      this.drafts = [];
      this.confirmClear = false;
    } catch {
      this.privacyReady = true;
      this.storageError = '无法读取本机隐私选择。请重试；不会上传或公开任何信息。';
    } finally {
      this.isLoading = false;
    }
  }

  private async loadDrafts(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      const loaded = await this.observationStore.load(getContext(this));
      const activeDrafts = loaded.filter((draft: ObservationDraft) => this.isSafeActiveDraft(draft));
      this.drafts = activeDrafts;
      if (activeDrafts.length !== loaded.length) {
        this.storageError = '已忽略过期、时间不完整或字段无法确认的本机草稿；不会上传或公开任何信息。';
      }
    } catch {
      this.storageError = '无法读取本地草稿。请重试；不会上传或公开任何信息。';
    } finally {
      this.isLoading = false;
    }
  }

  private async acceptPrivacy(): Promise<void> {
    try {
      await this.observationStore.savePrivacyChoice(getContext(this), PRIVACY_ACCEPTED);
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.storageError = '';
      await this.loadDrafts();
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传或公开任何信息。';
    }
  }

  private async declinePrivacy(): Promise<void> {
    try {
      await this.observationStore.savePrivacyChoice(getContext(this), PRIVACY_DECLINED);
      this.privacyChoice = PRIVACY_DECLINED;
      this.showPolicy = false;
      this.drafts = [];
      this.confirmClear = false;
      this.storageError = '';
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传或公开任何信息。';
    }
  }

  private async createDraft(): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) return;
    const draft: ObservationDraft = {
      id: Date.now(),
      source: '现场巡查员本地记录',
      collectedAt: this.timestampAt(0),
      expiresAt: this.timestampAt(120),
      status: '待审核 · 不公开'
    };
    const updated: ObservationDraft[] = [draft, ...this.drafts];
    try {
      await this.observationStore.save(getContext(this), updated);
      this.drafts = updated;
      this.confirmClear = false;
      this.storageError = '';
    } catch {
      this.storageError = '无法保存本地草稿。请重试；该信息没有上传或公开。';
    }
  }

  private async clearDrafts(): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) return;
    if (!this.confirmClear) {
      this.confirmClear = true;
      return;
    }
    try {
      await this.observationStore.clear(getContext(this));
      this.drafts = [];
      this.confirmClear = false;
      this.storageError = '';
    } catch {
      this.storageError = '无法清除本机草稿。请重试；没有上传或公开任何信息。';
    }
  }

  private async openSystemDialer(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      const want: Want = { action: 'ohos.want.action.dial', uri: 'tel:' };
      await context.startAbility(want);
    } catch {
      this.storageError = '无法打开系统电话。请退出本应用，使用官方应急电话渠道。';
    }
  }

  @Builder
  policyView() {
    Column({ space: 16 }) {
      Text('隐私说明').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
      Text('潮汐守望 · com.harmonyradar.tidewatch').fontSize(16).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('本页不是实时预报或公共公告；未审草稿不会上传、不会公开。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('不申请相机、定位或麦克风权限，也不接入网络、账号或第三方 SDK。权威潮汐数据未接入。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 8 }) {
        Text('若你同意并继续，本机可能保存：草稿标识、来源标签、采集时间、有效期、待审核状态，以及你对隐私说明的选择。').fontSize(15).fontColor($r('app.color.text_primary'))
        Text('不保存照片、精确位置或个人信息。过期或字段无法确认的草稿不会显示。开发者主体名称以应用市场登记信息为准。').fontSize(15).fontColor($r('app.color.text_primary'))
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Button('同意并继续').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
        .accessibilityText('同意隐私说明并允许保存本机观察草稿').onClick(() => this.acceptPrivacy())
      Button('仅查看说明，不保存草稿').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
        .onClick(() => this.declinePrivacy())
      if (this.privacyChoice.length > 0) {
        Button('返回').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
          .constraintSize({ minHeight: 48 })
          .onClick(() => this.showPolicy = false)
      }
      if (this.storageError.length > 0) {
        Text(this.storageError).fontSize(14).fontColor($r('app.color.text_notice')).padding(14).backgroundColor($r('app.color.surface_notice')).borderRadius(14).width('100%')
      }
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%').constraintSize({ maxWidth: 640 })
  }

  @Builder
  mainView() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('潮汐守望').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
          Text('离线现场观察与人工复核，不是实时预报。').fontSize(16).lineHeight(24).fontColor($r('app.color.text_secondary'))
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('非预报')
          .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.surface_pending')).borderRadius(8)
          .accessibilityText('当前记录不是实时预报或公共公告')
      }.width('100%').alignItems(VerticalAlign.Top)
      Column({ space: 6 }) {
        Text('遇紧急情况请使用官方应急渠道').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('本页不是实时预报或公共公告；未审草稿不会上传、不会公开。').fontSize(14).lineHeight(22).fontColor($r('app.color.text_notice'))
        Button('打开系统电话').fontSize(16).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 48 })
          .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
          .accessibilityText('打开系统电话拨号界面').onClick(() => this.openSystemDialer())
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 8 }) {
        Text('本次离线观察').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        Text('来源将标为现场巡查员本地记录；有效期为创建后两小时，状态固定为待审核。').fontSize(15).fontColor($r('app.color.text_secondary'))
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Button(this.isLoading ? '正在读取本地草稿…' : '创建本地观察草稿')
          .fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 54 })
          .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
          .enabled(!this.isLoading).onClick(() => this.createDraft())
      } else {
        Text('你选择不保存本机草稿。紧急情况请使用系统电话。').fontSize(15).fontColor($r('app.color.text_secondary'))
        Button('阅读隐私说明并允许保存').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
          .constraintSize({ minHeight: 48 })
          .onClick(() => this.showPolicy = true)
      }
      Column({ space: 10 }) {
        Text('待审核的本机草稿').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        if (this.privacyChoice !== PRIVACY_ACCEPTED) {
          Text('当前未开启本机保存，因此不读取或显示草稿。').fontSize(15).fontColor($r('app.color.text_muted'))
        } else if (this.isLoading) {
          Text('正在读取本机保存的草稿。').fontSize(15).fontColor($r('app.color.text_muted'))
        } else if (this.drafts.length === 0) {
          Text('尚无草稿。创建后仅保存在本机，居民端和公众均不可见。').fontSize(15).fontColor($r('app.color.text_muted'))
        } else {
          ForEach(this.drafts, (draft: ObservationDraft) => {
            Column({ space: 6 }) {
              Text(draft.status).fontSize(16).fontWeight(FontWeight.Medium).lineHeight(24).fontColor($r('app.color.text_pending'))
              Text(`来源：${draft.source}`).fontSize(16).lineHeight(24).fontColor($r('app.color.text_primary'))
              Text(`采集：${this.formatTimestamp(draft.collectedAt)}`).fontSize(14).lineHeight(22).fontColor($r('app.color.text_secondary'))
              Text(`有效至：${this.formatTimestamp(draft.expiresAt)}`).fontSize(14).lineHeight(22).fontColor($r('app.color.text_secondary'))
              Text('仅本机 · 不公开').fontSize(14).lineHeight(22).fontColor($r('app.color.text_muted'))
            }.padding(16).backgroundColor($r('app.color.surface_pending')).borderRadius(12).width('100%')
          }, (draft: ObservationDraft) => draft.id.toString())
          if (this.confirmClear) {
            Text('清除后无法从本应用恢复这些本机草稿。没有上传或公开任何信息。')
              .fontSize(14).lineHeight(22).fontColor($r('app.color.text_danger'))
            Button('确认清除全部本机草稿')
              .fontSize(16).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 48 })
              .backgroundColor($r('app.color.surface_notice')).fontColor($r('app.color.text_danger')).borderRadius(12)
              .accessibilityText('确认清除全部本机观察草稿，此操作不能撤销')
              .onClick(() => this.clearDrafts())
            Button('取消清除').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 }).onClick(() => this.confirmClear = false)
          } else {
            Button('清除全部本机草稿').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 })
              .accessibilityText('准备清除全部本机草稿，下一步需要确认')
              .onClick(() => this.clearDrafts())
          }
        }
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      if (this.storageError.length > 0) {
        Column({ space: 8 }) {
          Text(this.storageError).fontSize(14).fontColor($r('app.color.text_notice'))
          Button('重试读取本机草稿').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
            .constraintSize({ minHeight: 48 }).onClick(() => this.bootstrap())
        }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(16).width('100%')
      }
      Button('查看隐私说明').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.showPolicy = true)
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
