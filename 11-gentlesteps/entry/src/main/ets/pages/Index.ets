import { HabitState, HabitStore, PRIVACY_ACCEPTED, PRIVACY_DECLINED } from '../data/HabitStore';

interface HabitOption {
  id: string;
  title: string;
  detail: string;
}

const HABITS: HabitOption[] = [
  { id: 'water', title: '喝一杯水', detail: '按自己的需要补充水分。' },
  { id: 'stretch', title: '做一次轻柔伸展', detail: '以舒适为准，任何不适都可以跳过。' },
  { id: 'screen-break', title: '离开屏幕片刻', detail: '给眼睛和注意力一个短暂休息。' },
  { id: 'reach-out', title: '联系一位信任的人', detail: '可选择一句简单问候，不要求回复。' }
];

@Entry
@Component
struct Index {
  private readonly habitStore: HabitStore = new HabitStore();
  @State private state: HabitState = { day: '', selectedIds: [], completedIds: [], skippedIds: [] };
  @State private isLoading: boolean = true;
  @State private storageError: string = '';
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;

  aboutToAppear(): void {
    this.bootstrap();
  }

  onBackPress(): boolean {
    if (this.showPolicy && this.privacyChoice.length > 0) {
      this.showPolicy = false;
      return true;
    }
    return false;
  }

  private hostContext(): Context {
    return getContext(this);
  }

  private today(): string {
    const date = new Date();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${date.getFullYear()}-${month}-${day}`;
  }

  private emptyState(day: string): HabitState {
    return { day, selectedIds: [], completedIds: [], skippedIds: [] };
  }

  private has(values: string[], id: string): boolean {
    return values.indexOf(id) >= 0;
  }

  private without(values: string[], id: string): string[] {
    return values.filter((value: string) => value !== id);
  }

  private habitTitle(id: string): string {
    for (let index = 0; index < HABITS.length; index += 1) {
      if (HABITS[index].id === id) {
        return HABITS[index].title;
      }
    }
    return '已移除的任务';
  }

  private async bootstrap(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      this.privacyChoice = await this.habitStore.loadPrivacyChoice(this.hostContext());
      this.privacyReady = true;
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        await this.loadState();
        return;
      }
      this.state = this.emptyState(this.today());
    } catch {
      this.privacyReady = true;
      this.storageError = '无法读取本机隐私选择。请重试；不会上传任何内容。';
    } finally {
      this.isLoading = false;
    }
  }

  private async loadState(): Promise<void> {
    this.isLoading = true;
    try {
      this.state = await this.habitStore.load(this.hostContext(), this.today());
      this.storageError = '';
    } catch {
      this.storageError = '无法读取本机练习状态。请重试；不会上传任何内容。';
    } finally {
      this.isLoading = false;
    }
  }

  private async acceptPrivacy(): Promise<void> {
    try {
      await this.habitStore.savePrivacyChoice(this.hostContext(), PRIVACY_ACCEPTED);
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.storageError = '';
      await this.loadState();
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传任何内容。';
    }
  }

  private async declinePrivacy(): Promise<void> {
    try {
      await this.habitStore.savePrivacyChoice(this.hostContext(), PRIVACY_DECLINED);
      this.privacyChoice = PRIVACY_DECLINED;
      this.showPolicy = false;
      this.state = this.emptyState(this.today());
      this.storageError = '';
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传任何内容。';
    }
  }

  private async persist(next: HabitState): Promise<void> {
    if (this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    try {
      await this.habitStore.save(this.hostContext(), next);
      this.state = next;
      this.storageError = '';
    } catch {
      this.storageError = '无法保存本机练习状态。请重试；没有上传任何内容。';
    }
  }

  private toggle(id: string): void {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    if (this.has(this.state.selectedIds, id)) {
      this.persist({
        day: this.today(),
        selectedIds: this.without(this.state.selectedIds, id),
        completedIds: this.without(this.state.completedIds, id),
        skippedIds: this.without(this.state.skippedIds, id)
      });
    } else if (this.state.selectedIds.length >= 3) {
      this.storageError = '每天最多选择三项微任务。先取消一项，再做新的选择。';
    } else {
      this.persist({
        day: this.today(),
        selectedIds: [...this.state.selectedIds, id],
        completedIds: this.state.completedIds,
        skippedIds: this.state.skippedIds
      });
    }
  }

  private mark(id: string, completed: boolean): void {
    if (this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    const completedIds = completed
      ? [...this.without(this.state.completedIds, id), id]
      : this.without(this.state.completedIds, id);
    const skippedIds = completed
      ? this.without(this.state.skippedIds, id)
      : [...this.without(this.state.skippedIds, id), id];
    this.persist({
      day: this.today(),
      selectedIds: this.state.selectedIds,
      completedIds,
      skippedIds
    });
  }

  private reset(id: string): void {
    if (this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    this.persist({
      day: this.today(),
      selectedIds: this.state.selectedIds,
      completedIds: this.without(this.state.completedIds, id),
      skippedIds: this.without(this.state.skippedIds, id)
    });
  }

  private async clearState(): Promise<void> {
    if (this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    try {
      await this.habitStore.clear(this.hostContext());
      this.state = this.emptyState(this.today());
      this.storageError = '';
    } catch {
      this.storageError = '无法清除本机练习状态。请重试；没有上传任何内容。';
    }
  }

  @Builder
  private policyView() {
    Column({ space: 16 }) {
      Text('隐私说明')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('微光习惯 · com.harmonyradar.gentlesteps')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
      Column({ space: 8 }) {
        Text('不记录连续天数，不因跳过而惩罚，也不评判健康状态。这不是心理测评或诊疗。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_notice'))
        Text('不申请位置、联系人、相机或麦克风权限，也不接入网络、账号、社交排名、付费解锁或第三方 SDK。')
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_notice'))
      .borderRadius(18)
      .width('100%')
      Column({ space: 8 }) {
        Text('若你选择同意并继续，本机可能保存：当天日期、最多三项任务 ID、完成或跳过状态，以及你对隐私说明的选择。')
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text('不保存自由文本、健康指标、联系人或位置。跨日后不会把昨天的任务显示为今天的记录。你可以随时清除本机练习状态。')
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
        .accessibilityText('同意隐私说明并允许保存当天练习状态')
        .onClick(() => this.acceptPrivacy())
      Button('仅浏览说明，不保存练习')
        .fontSize(16)
        .fontColor($r('app.color.action_primary'))
        .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
        .accessibilityText('拒绝保存本机练习状态')
        .onClick(() => this.declinePrivacy())
      if (this.privacyChoice.length > 0) {
        Button('返回')
          .fontSize(16)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
          .accessibilityText('返回微习惯练习页')
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
      Text('微光习惯')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('离线、非竞争的微习惯练习')
        .fontSize(17)
        .fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('不记录连续天数，不因跳过而惩罚，也不评判健康状态。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_notice'))
        Text('所有选择只保存在本机；没有社交排名、付费解锁、位置或联系人读取。')
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_notice'))
      .borderRadius(18)
      .width('100%')

      Column({ space: 10 }) {
        Text(`今天选择（${this.state.selectedIds.length}/3）`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        if (this.privacyChoice !== PRIVACY_ACCEPTED) {
          Text('你选择不保存本机练习。仍可阅读任务说明；如需选择和记录，请先阅读并同意隐私说明。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
          Button('阅读隐私说明并允许保存')
            .fontSize(15)
            .fontColor($r('app.color.action_primary'))
            .backgroundColor(Color.Transparent)
            .accessibilityText('打开隐私说明')
            .onClick(() => this.showPolicy = true)
        }
        ForEach(HABITS, (habit: HabitOption) => {
          Button() {
            Column({ space: 5 }) {
              Text(habit.title)
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
              Text(habit.detail)
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .maxLines(2)
              Text(this.has(this.state.selectedIds, habit.id) ? '已选择，可再次点击取消' : '点击选择')
                .fontSize(13)
                .fontColor($r('app.color.text_choice'))
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }
          .width('100%')
          .padding(15)
          .borderRadius(15)
          .backgroundColor(this.has(this.state.selectedIds, habit.id) ? $r('app.color.surface_choice') : $r('app.color.surface_card'))
          .enabled(!this.isLoading && this.privacyChoice === PRIVACY_ACCEPTED)
          .accessibilityText(`${habit.title}，${this.has(this.state.selectedIds, habit.id) ? '已选择' : '未选择'}`)
          .onClick(() => this.toggle(habit.id))
        }, (habit: HabitOption) => habit.id)
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(20)
      .width('100%')

      if (this.privacyChoice === PRIVACY_ACCEPTED && !this.isLoading && this.state.selectedIds.length > 0) {
        Column({ space: 10 }) {
          Text('今天的微任务')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          ForEach(this.state.selectedIds, (id: string) => {
            Column({ space: 7 }) {
              Text(this.habitTitle(id))
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
              if (this.has(this.state.completedIds, id)) {
                Text('已完成 · 仅本机记录')
                  .fontSize(14)
                  .fontColor($r('app.color.text_done'))
                Button('撤销完成')
                  .fontSize(15)
                  .fontColor($r('app.color.action_primary'))
                  .backgroundColor(Color.Transparent)
                  .accessibilityText(`撤销完成 ${this.habitTitle(id)}`)
                  .onClick(() => this.reset(id))
              } else if (this.has(this.state.skippedIds, id)) {
                Text('已跳过 · 不影响任何连续记录')
                  .fontSize(14)
                  .fontColor($r('app.color.text_choice'))
                Button('撤销跳过')
                  .fontSize(15)
                  .fontColor($r('app.color.action_primary'))
                  .backgroundColor(Color.Transparent)
                  .accessibilityText(`撤销跳过 ${this.habitTitle(id)}`)
                  .onClick(() => this.reset(id))
              } else {
                Row({ space: 12 }) {
                  Button('完成')
                    .fontSize(15)
                    .fontColor($r('app.color.text_on_primary'))
                    .backgroundColor($r('app.color.action_primary'))
                    .borderRadius(12)
                    .accessibilityText(`标记完成 ${this.habitTitle(id)}`)
                    .onClick(() => this.mark(id, true))
                  Button('今天跳过')
                    .fontSize(15)
                    .fontColor($r('app.color.action_primary'))
                    .backgroundColor(Color.Transparent)
                    .accessibilityText(`今天跳过 ${this.habitTitle(id)}`)
                    .onClick(() => this.mark(id, false))
                }
              }
            }
            .padding(16)
            .backgroundColor($r('app.color.surface_choice'))
            .borderRadius(16)
            .width('100%')
          }, (id: string) => id)
        }
        .padding(20)
        .backgroundColor($r('app.color.surface_card'))
        .borderRadius(20)
        .width('100%')
      }

      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Button('清除全部本机练习状态')
          .fontSize(15)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
          .accessibilityText('清除保存在本机的选择、完成和跳过记录')
          .onClick(() => this.clearState())
      }

      if (this.storageError.length > 0) {
        Column({ space: 8 }) {
          Text(this.storageError)
            .fontSize(14)
            .fontColor($r('app.color.text_notice'))
          Button('重试读取本机状态')
            .fontSize(15)
            .fontColor($r('app.color.action_primary'))
            .backgroundColor(Color.Transparent)
            .accessibilityText('重新读取本机隐私选择和练习状态')
            .onClick(() => this.bootstrap())
        }
        .padding(16)
        .backgroundColor($r('app.color.surface_notice'))
        .borderRadius(16)
        .width('100%')
      }

      Column({ space: 8 }) {
        Text('能力边界')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Text('没有导出、排行榜、植物成长可视化或付费解锁。本切片只保存当天任务 ID 与完成/跳过状态。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Button('查看隐私说明')
          .fontSize(15)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
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
