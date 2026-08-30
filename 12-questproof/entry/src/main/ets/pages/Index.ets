import { PrivacyChoiceStore, PRIVACY_ACCEPTED } from '../data/PrivacyChoiceStore';

const STATE_PUBLISHED: string = 'published';
const STATE_SUBMITTED: string = 'submitted';
const STATE_MARKED: string = 'marked';
const STATE_REVOKED: string = 'revoked';
const DEMO_OPERATOR: string = '本机演示操作（不是真实审核人）';

@Entry
@Component
struct Index {
  private readonly privacyStore: PrivacyChoiceStore = new PrivacyChoiceStore();
  @State private cardState: string = STATE_PUBLISHED;
  @State private lastChangedAt: string = '';
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;
  @State private actionError: string = '';

  aboutToAppear(): void {
    this.loadPrivacy();
  }

  onBackPress(): boolean {
    if (this.showPolicy && this.privacyChoice === PRIVACY_ACCEPTED) {
      this.showPolicy = false;
      return true;
    }
    return false;
  }

  private hostContext(): Context {
    return getContext(this);
  }

  private stamp(): string {
    const date = new Date();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    return `${date.getFullYear()}-${month}-${day} ${hour}:${minute}`;
  }

  private stateTitle(): string {
    if (this.cardState === STATE_SUBMITTED) {
      return '已提交演示回执';
    }
    if (this.cardState === STATE_MARKED) {
      return '本机已标记确认';
    }
    if (this.cardState === STATE_REVOKED) {
      return '演示回执已撤销';
    }
    return '演示任务已发布';
  }

  private stateNote(): string {
    if (this.cardState === STATE_SUBMITTED) {
      return '下一步可退回发布态，或仅在本机标记确认。这不是管理员审核，也不会生成公开回执。';
    }
    if (this.cardState === STATE_MARKED) {
      return '标记可以撤销。撤销后不保留任何凭证效力，也没有链上记录。';
    }
    if (this.cardState === STATE_REVOKED) {
      return '当前没有有效回执。可重新开始本机演示，不会恢复已撤销内容。';
    }
    return '下一步可提交一条仅存在于本页的演示回执。没有地点、照片或真实身份。';
  }

  private nextActionLabel(): string {
    if (this.cardState === STATE_SUBMITTED) {
      return '退回或标记确认';
    }
    if (this.cardState === STATE_MARKED) {
      return '撤销本机标记';
    }
    if (this.cardState === STATE_REVOKED) {
      return '重新开始本机演示';
    }
    return '提交本机演示回执';
  }

  private async loadPrivacy(): Promise<void> {
    this.actionError = '';
    try {
      this.privacyChoice = await this.privacyStore.load(this.hostContext());
    } catch {
      this.actionError = '无法读取本机隐私选择。请重试；演示状态不会保存到本机。';
    } finally {
      this.privacyReady = true;
    }
  }

  private async acceptPrivacy(): Promise<void> {
    try {
      await this.privacyStore.saveAccepted(this.hostContext());
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.actionError = '';
    } catch {
      this.actionError = '无法保存“已阅读”标记。请重试；不会生成真实回执或身份证明。';
    }
  }

  private moveTo(next: string): void {
    this.cardState = next;
    this.lastChangedAt = this.stamp();
  }

  @Builder
  private policyView() {
    Column({ space: 16 }) {
      Text('隐私说明')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('可信任务贴 · com.harmonyradar.questproof')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
      Column({ space: 8 }) {
        Text('本版本只是本机任务状态演示，不是真实完成回执、身份证明、社区审核或链上凭证。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_notice'))
        Text('状态只存在于本次会话，离开页面即消失。本机仅可能保存你已阅读本说明的标记。')
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
      }
      .padding(16)
      .backgroundColor($r('app.color.notice'))
      .borderRadius(18)
      .width('100%')
      Column({ space: 8 }) {
        Text('不申请位置、相机、麦克风或联系人权限，也不接入网络、账号、代币、排行、支付或第三方 SDK。')
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text('没有真实发起方、审核人或公开回执。页面上的“确认”只改变本机演示状态。')
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text('开发者主体名称以华为应用市场登记信息为准。公开隐私政策网址尚未提供，因此本页是当前唯一完整说明。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .padding(20)
      .backgroundColor($r('app.color.card'))
      .borderRadius(20)
      .width('100%')
      Button('已阅读并继续')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action'))
        .fontColor($r('app.color.on_action'))
        .borderRadius(15)
        .accessibilityText('已阅读隐私说明并继续使用本机演示状态机')
        .onClick(() => this.acceptPrivacy())
      Text('如暂不使用，请停留在本页。')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Button('返回')
          .fontSize(16)
          .fontColor($r('app.color.action'))
          .backgroundColor(Color.Transparent)
          .accessibilityText('返回任务演示页')
          .onClick(() => this.showPolicy = false)
      }
      if (this.actionError.length > 0) {
        Column({ space: 8 }) {
          Text(this.actionError)
            .fontSize(14)
            .fontColor($r('app.color.text_notice'))
          Button('重试读取本机状态')
            .fontSize(15)
            .fontColor($r('app.color.action'))
            .backgroundColor(Color.Transparent)
            .accessibilityText('重新读取已阅读标记')
            .onClick(() => this.loadPrivacy())
        }
        .padding(14)
        .backgroundColor($r('app.color.notice'))
        .borderRadius(14)
        .width('100%')
      }
    }
    .padding({ left: 20, right: 20, top: 28, bottom: 36 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .constraintSize({ maxWidth: 640 })
  }

  @Builder
  private mainView() {
    Column({ space: 16 }) {
      Text('可信任务贴')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('本机任务状态演示 · 不是真实回执')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))

      Column({ space: 6 }) {
        Text('没有代币、排行、押金、链上结算或不可撤销凭证。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_notice'))
        Text('本页不采集地点、照片或身份。离开页面后演示状态消失。')
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
      }
      .padding(16)
      .backgroundColor($r('app.color.notice'))
      .borderRadius(18)
      .width('100%')

      Column({ space: 8 }) {
        Text('演示任务：社区清洁准备')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text(`当前状态：${this.stateTitle()}`)
          .fontSize(18)
          .fontColor($r('app.color.text_notice'))
        Text(this.stateNote())
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
        Text(`最近一次本机操作：${this.lastChangedAt.length > 0 ? this.lastChangedAt : '尚未操作'}`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Text(`操作记录：${DEMO_OPERATOR}`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Text(`当前可做：${this.nextActionLabel()}`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .padding(20)
      .backgroundColor($r('app.color.card'))
      .borderRadius(20)
      .width('100%')

      if (this.cardState === STATE_PUBLISHED) {
        Button('提交本机演示回执')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 54 })
          .fontColor($r('app.color.on_action'))
          .backgroundColor($r('app.color.action'))
          .borderRadius(15)
          .accessibilityText('提交仅存在于本页的演示回执')
          .onClick(() => this.moveTo(STATE_SUBMITTED))
      } else if (this.cardState === STATE_SUBMITTED) {
        Button('退回发布态')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 54 })
          .fontColor($r('app.color.on_action'))
          .backgroundColor($r('app.color.action'))
          .borderRadius(15)
          .accessibilityText('把演示任务退回已发布状态')
          .onClick(() => this.moveTo(STATE_PUBLISHED))
        Button('仅在本机标记确认')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 54 })
          .fontColor($r('app.color.on_action'))
          .backgroundColor($r('app.color.action'))
          .borderRadius(15)
          .accessibilityText('仅在本机标记确认，不生成真实凭证')
          .onClick(() => this.moveTo(STATE_MARKED))
      } else if (this.cardState === STATE_MARKED) {
        Button('撤销本机标记')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 54 })
          .fontColor($r('app.color.on_action'))
          .backgroundColor($r('app.color.action'))
          .borderRadius(15)
          .accessibilityText('撤销本机确认标记，不保留凭证效力')
          .onClick(() => this.moveTo(STATE_REVOKED))
      } else {
        Button('重新开始本机演示')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 54 })
          .fontColor($r('app.color.on_action'))
          .backgroundColor($r('app.color.action'))
          .borderRadius(15)
          .accessibilityText('清除当前演示并回到已发布状态')
          .onClick(() => this.moveTo(STATE_PUBLISHED))
      }

      if (this.actionError.length > 0) {
        Text(this.actionError)
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
          .padding(14)
          .backgroundColor($r('app.color.notice'))
          .borderRadius(14)
          .width('100%')
      }

      Column({ space: 8 }) {
        Text('能力边界')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Text('真实发起方、审核人、地点范围、照片证据和公开回执均未接入。在这些规则确认前，本应用不能作为上架凭证产品。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Button('查看隐私说明')
          .fontSize(15)
          .fontColor($r('app.color.action'))
          .backgroundColor(Color.Transparent)
          .accessibilityText('查看当前版本隐私说明')
          .onClick(() => this.showPolicy = true)
      }
      .padding(16)
      .backgroundColor($r('app.color.card'))
      .borderRadius(16)
      .width('100%')
    }
    .padding({ left: 20, right: 20, top: 28, bottom: 36 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .constraintSize({ maxWidth: 640 })
  }

  build() {
    Scroll() {
      Column() {
        if (!this.privacyReady) {
          Text('正在读取本机状态…')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .padding(28)
        } else if (this.privacyChoice !== PRIVACY_ACCEPTED || this.showPolicy) {
          this.policyView()
        } else {
          this.mainView()
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.canvas'))
    .align(Alignment.Top)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .scrollBar(BarState.Auto)
  }
}
