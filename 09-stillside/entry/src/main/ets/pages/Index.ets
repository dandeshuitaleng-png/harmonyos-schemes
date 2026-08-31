import { common, Want } from '@kit.AbilityKit';
import { PracticeStore, PRIVACY_ACCEPTED, PRIVACY_DECLINED } from '../data/PracticeStore';

const DURATIONS: number[] = [2, 5, 10];

@Entry
@Component
struct Index {
  private readonly practiceStore: PracticeStore = new PracticeStore();
  private timerId: number = -1;
  @State private selectedMinutes: number = 2;
  @State private remainingSeconds: number = 120;
  @State private isRunning: boolean = false;
  @State private isPaused: boolean = false;
  @State private completed: boolean = false;
  @State private saveCountEnabled: boolean = false;
  @State private savedCount: number = 0;
  @State private storageError: string = '';
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;
  @State private confirmClear: boolean = false;

  aboutToAppear(): void {
    this.bootstrap();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

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

  private hostContext(): Context {
    return getContext(this);
  }

  private formatTime(): string {
    const minutes = Math.floor(this.remainingSeconds / 60).toString().padStart(2, '0');
    const seconds = (this.remainingSeconds % 60).toString().padStart(2, '0');
    return `${minutes}:${seconds}`;
  }

  private statusTitle(): string {
    if (this.completed) {
      return '本次安静练习已完成';
    }
    if (this.isRunning) {
      return '正在安静练习';
    }
    if (this.isPaused) {
      return '练习已暂停';
    }
    return '准备开始';
  }

  private async bootstrap(): Promise<void> {
    this.storageError = '';
    try {
      this.privacyChoice = await this.practiceStore.loadPrivacyChoice(this.hostContext());
      this.privacyReady = true;
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        await this.loadCount();
        return;
      }
      this.savedCount = 0;
      this.saveCountEnabled = false;
    } catch {
      this.privacyReady = true;
      this.storageError = '无法读取本机隐私选择。请重试；计时仍可离线使用，也不会上传。';
    }
  }

  private async loadCount(): Promise<void> {
    try {
      this.savedCount = await this.practiceStore.loadCount(this.hostContext());
      this.storageError = '';
    } catch {
      this.storageError = '无法读取本机练习次数；计时仍可离线使用。';
    }
  }

  private async acceptPrivacy(): Promise<void> {
    try {
      await this.practiceStore.savePrivacyChoice(this.hostContext(), PRIVACY_ACCEPTED);
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.storageError = '';
      await this.loadCount();
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传任何内容。';
    }
  }

  private async declinePrivacy(): Promise<void> {
    try {
      await this.practiceStore.savePrivacyChoice(this.hostContext(), PRIVACY_DECLINED);
      this.privacyChoice = PRIVACY_DECLINED;
      this.showPolicy = false;
      this.savedCount = 0;
      this.saveCountEnabled = false;
      this.storageError = '';
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传任何内容。';
    }
  }

  private chooseMinutes(minutes: number): void {
    if (this.isRunning || this.isPaused) {
      return;
    }
    this.selectedMinutes = minutes;
    this.remainingSeconds = minutes * 60;
    this.completed = false;
  }

  private startOrResume(): void {
    if (this.isRunning) {
      return;
    }
    if (this.remainingSeconds <= 0) {
      this.remainingSeconds = this.selectedMinutes * 60;
    }
    this.isRunning = true;
    this.isPaused = false;
    this.completed = false;
    this.timerId = setInterval(() => this.tick(), 1000);
  }

  private tick(): void {
    if (this.remainingSeconds <= 1) {
      this.remainingSeconds = 0;
      this.stopTimer();
      this.completed = true;
      this.recordCompletion();
      return;
    }
    this.remainingSeconds -= 1;
  }

  private pause(): void {
    this.stopTimer();
    this.isPaused = true;
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    this.isRunning = false;
  }

  private endSession(): void {
    this.stopTimer();
    this.isPaused = false;
    this.completed = false;
    this.remainingSeconds = this.selectedMinutes * 60;
  }

  private async recordCompletion(): Promise<void> {
    if (this.privacyChoice !== PRIVACY_ACCEPTED || !this.saveCountEnabled) {
      return;
    }
    try {
      const next = this.savedCount + 1;
      await this.practiceStore.saveCount(this.hostContext(), next);
      this.savedCount = next;
      this.storageError = '';
    } catch {
      this.storageError = '本次练习已完成，但本机次数未能保存。可重试清除或稍后再次保存。';
    }
  }

  private async clearSavedCount(): Promise<void> {
    if (this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    if (!this.confirmClear) {
      this.confirmClear = true;
      return;
    }
    try {
      await this.practiceStore.clearCount(this.hostContext());
      this.savedCount = 0;
      this.confirmClear = false;
      this.storageError = '';
    } catch {
      this.storageError = '无法清除本机练习次数。请重试；没有上传任何内容。';
    }
  }

  private async openSystemDialer(): Promise<void> {
    try {
      const context = this.hostContext() as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.dial',
        uri: 'tel:'
      };
      await context.startAbility(want);
    } catch {
      this.storageError = '无法打开系统电话。请退出本应用，使用系统电话应用联系当地紧急求助渠道。';
    }
  }

  @Builder
  private policyView() {
    Column({ space: 16 }) {
      Text('隐私说明')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('静伴空间 · com.harmonyradar.stillside')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
      Column({ space: 8 }) {
        Text('这不是心理治疗、危机干预或情绪评估，也不替代当地紧急求助渠道。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_notice'))
        Text('不申请麦克风、相机、位置、联系人或通知权限，也不接入网络、账号、推送、支付或第三方 SDK。')
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_notice'))
      .borderRadius(18)
      .width('100%')
      Column({ space: 8 }) {
        Text('若你选择同意并继续，本机可能保存：你主动开启后的完成次数，以及你对隐私说明的选择。')
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text('不保存练习内容、精确时间、音频、位置或身份。你可以随时关闭保存并清除次数。拒绝后仍可离线计时，但不会读取或写入练习次数。')
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text('开发者主体名称以华为应用市场登记信息为准。公开隐私政策网址尚未提供，因此本页是当前唯一完整说明。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(20)
      .width('100%')
      Button('同意并继续')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary'))
        .fontColor($r('app.color.text_on_primary'))
        .borderRadius(15)
        .accessibilityText('同意隐私说明并允许可选保存本机练习次数')
        .onClick(() => this.acceptPrivacy())
      Button('仅离线计时，不保存次数')
        .fontSize(16)
        .fontColor($r('app.color.action_primary'))
        .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
        .accessibilityText('拒绝保存本机次数，仅使用离线计时')
        .onClick(() => this.declinePrivacy())
      if (this.privacyChoice.length > 0) {
        Button('返回')
          .fontSize(16)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
          .accessibilityText('返回安静练习页')
          .onClick(() => this.showPolicy = false)
      }
      if (this.storageError.length > 0) {
        Text(this.storageError)
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
          .padding(14)
          .backgroundColor($r('app.color.surface_notice'))
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
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('静伴空间')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .lineHeight(34)
          Text('离线、非医疗的安静练习')
            .fontSize(17)
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(24)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('非治疗')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.surface_notice'))
          .borderRadius(8)
          .accessibilityText('这不是心理治疗或危机干预')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Column({ space: 6 }) {
        Text('这不是心理治疗、危机干预或情绪评估。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_notice'))
        Text('没有账号、匿名房间、音频、位置或身份数据。紧急情况请使用当地紧急求助渠道。')
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
        Button('打开系统电话')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .backgroundColor($r('app.color.action_primary'))
          .fontColor($r('app.color.text_on_primary'))
          .borderRadius(15)
          .accessibilityText('打开系统电话拨号界面，不由本应用拨出号码')
          .onClick(() => this.openSystemDialer())
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_notice'))
      .borderRadius(18)
      .width('100%')

      Column({ space: 10 }) {
        Text('选择安静时长')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        ForEach(DURATIONS, (minutes: number) => {
          Button(this.selectedMinutes === minutes ? `${minutes} 分钟 · 已选择` : `${minutes} 分钟`)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .constraintSize({ minHeight: 48 })
            .padding(15)
            .borderRadius(15)
            .backgroundColor(this.selectedMinutes === minutes ? $r('app.color.surface_active') : $r('app.color.surface_card'))
            .border({
              width: this.selectedMinutes === minutes ? 0 : 1,
              color: $r('app.color.border_subtle')
            })
            .enabled(!this.isRunning && !this.isPaused)
            .accessibilityText(this.selectedMinutes === minutes ? `已选择 ${minutes} 分钟` : `选择 ${minutes} 分钟安静练习`)
            .onClick(() => this.chooseMinutes(minutes))
        }, (minutes: number) => minutes.toString())
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(20)
      .width('100%')

      Column({ space: 8 }) {
        Text(this.statusTitle())
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_active'))
        Text(this.formatTime())
          .fontSize(46)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text(this.completed ? '完成不代表任何健康或治疗结论。' : '你可以随时暂停或结束；提前结束不会保存练习记录。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_active'))
      .borderRadius(20)
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      if (this.isRunning) {
        Button('暂停')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .height(54)
          .backgroundColor($r('app.color.action_primary'))
          .fontColor($r('app.color.text_on_primary'))
          .borderRadius(15)
          .accessibilityText('暂停当前安静练习')
          .onClick(() => this.pause())
      } else {
        Button(this.isPaused ? '继续安静练习' : '开始安静练习')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .height(54)
          .backgroundColor($r('app.color.action_primary'))
          .fontColor($r('app.color.text_on_primary'))
          .borderRadius(15)
          .accessibilityText(this.isPaused ? '继续当前安静练习' : '开始安静练习')
          .onClick(() => this.startOrResume())
      }

      if (this.isRunning || this.isPaused) {
        Button('结束本次练习')
          .fontSize(15)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
          .accessibilityText('结束本次练习且不保存未完成记录')
          .onClick(() => this.endSession())
      }

      Column({ space: 8 }) {
        Text('本机练习次数（可选）')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        if (this.privacyChoice === PRIVACY_ACCEPTED) {
          Toggle({ type: ToggleType.Switch, isOn: this.saveCountEnabled })
            .accessibilityText(this.saveCountEnabled ? '关闭后完成练习不再增加本机次数' : '开启后仅保存完成次数')
            .onChange((enabled: boolean) => this.saveCountEnabled = enabled)
          Text(this.saveCountEnabled
            ? `仅保存完成次数：${this.savedCount} 次。不会保存内容、时间、位置或身份。`
            : (this.savedCount > 0
              ? `未开启本次保存。本机仍有 ${this.savedCount} 次记录，可随时清除。`
              : '未开启保存；完成练习不会留下任何本机记录。'))
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          if (this.savedCount > 0) {
            if (this.confirmClear) {
              Text('清除后无法从本应用恢复这些次数。没有向外发送任何数据。')
                .fontSize(14)
                .lineHeight(22)
                .fontColor($r('app.color.text_danger'))
              Button('确认清除本机练习次数')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .constraintSize({ minHeight: 48 })
                .backgroundColor($r('app.color.surface_notice'))
                .fontColor($r('app.color.text_danger'))
                .borderRadius(12)
                .accessibilityText('确认清除全部本机练习次数，此操作不能撤销')
                .onClick(() => this.clearSavedCount())
              Button('取消清除')
                .fontSize(16)
                .fontColor($r('app.color.action_primary'))
                .backgroundColor(Color.Transparent)
                .constraintSize({ minHeight: 48 })
                .onClick(() => this.confirmClear = false)
            } else {
              Button('清除本机练习次数')
                .fontSize(15)
                .fontColor($r('app.color.action_primary'))
                .backgroundColor(Color.Transparent)
                .constraintSize({ minHeight: 48 })
                .accessibilityText('准备清除全部本机练习次数，下一步需要确认')
                .onClick(() => this.clearSavedCount())
            }
          }
        } else {
          Text('你选择不保存本机次数。计时仍可离线使用；如需保存次数，请先阅读并同意隐私说明。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          Button('阅读隐私说明并允许保存')
            .fontSize(15)
            .fontColor($r('app.color.action_primary'))
            .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
            .accessibilityText('打开隐私说明')
            .onClick(() => this.showPolicy = true)
        }
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(20)
      .width('100%')

      if (this.storageError.length > 0) {
        Column({ space: 8 }) {
          Text(this.storageError)
            .fontSize(14)
            .fontColor($r('app.color.text_notice'))
          Button('重试读取本机状态')
            .fontSize(15)
            .fontColor($r('app.color.action_primary'))
            .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
            .accessibilityText('重新读取本机隐私选择和练习次数')
            .onClick(() => this.bootstrap())
        }
        .padding(14)
        .backgroundColor($r('app.color.surface_notice'))
        .borderRadius(14)
        .width('100%')
      }

      Column({ space: 8 }) {
        Text('能力边界')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Text('匿名房间、账号、远程提醒和任何网络能力均未实现。本切片只提供离线计时与可选本机次数。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Button('查看隐私说明')
          .fontSize(15)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
          .accessibilityText('查看当前版本隐私说明')
          .onClick(() => this.showPolicy = true)
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_card'))
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
        } else if (this.privacyChoice.length === 0 || this.showPolicy) {
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
    .backgroundColor($r('app.color.surface_canvas'))
    .align(Alignment.Top)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .scrollBar(BarState.Auto)
  }
}
