import { PrivacyChoiceStore, PRIVACY_ACCEPTED } from '../data/PrivacyChoiceStore';

interface FarmNote {
  id: number;
  kind: string;
  day: string;
  time: string;
}

const KINDS: string[] = ['播种', '浇灌', '观察'];

@Entry
@Component
struct Index {
  private readonly privacyStore: PrivacyChoiceStore = new PrivacyChoiceStore();
  @State private kind: string = '播种';
  @State private notes: FarmNote[] = [];
  @State private filterToday: boolean = true;
  @State private showSummary: boolean = false;
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;
  @State private confirmClear: boolean = false;
  @State private actionError: string = '';

  aboutToAppear(): void {
    this.loadPrivacy();
  }

  onBackPress(): boolean {
    if (this.showPolicy && this.privacyChoice === PRIVACY_ACCEPTED) {
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

  private today(): string {
    const date = new Date();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${date.getFullYear()}-${month}-${day}`;
  }

  private nowTime(): string {
    const date = new Date();
    const hour = date.getHours().toString().padStart(2, '0');
    const minute = date.getMinutes().toString().padStart(2, '0');
    return `${hour}:${minute}`;
  }

  private visibleNotes(): FarmNote[] {
    if (!this.filterToday) {
      return this.notes;
    }
    const day = this.today();
    return this.notes.filter((note: FarmNote) => note.day === day);
  }

  private countByKind(kind: string): number {
    let total = 0;
    const items = this.visibleNotes();
    for (let index = 0; index < items.length; index += 1) {
      if (items[index].kind === kind) {
        total += 1;
      }
    }
    return total;
  }

  private async loadPrivacy(): Promise<void> {
    this.actionError = '';
    try {
      this.privacyChoice = await this.privacyStore.load(this.hostContext());
    } catch {
      this.actionError = '无法读取本机隐私选择。请重试；农事记录不会保存到本机。';
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
      this.actionError = '无法保存“已阅读”标记。请重试；不会录音、落盘或上传农事内容。';
    }
  }

  private addNote(): void {
    const note: FarmNote = {
      id: Date.now(),
      kind: this.kind,
      day: this.today(),
      time: this.nowTime()
    };
    this.notes = [note, ...this.notes];
    this.showSummary = false;
  }

  private clearSession(): void {
    if (!this.confirmClear) {
      this.confirmClear = true;
      return;
    }
    this.notes = [];
    this.showSummary = false;
    this.confirmClear = false;
  }

  @Builder
  private policyView() {
    Column({ space: 16 }) {
      Text('隐私说明')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('农事口述簿 · com.harmonyradar.farmvoice')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
      Column({ space: 8 }) {
        Text('本版本只提供无网手动记录。不录音、不转写，也不根据记录给出种植、施药或贷款建议。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_notice'))
        Text('作业记录只存在于本次会话，离开页面即消失。本机仅可能保存你已阅读本说明的标记。')
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
      }
      .padding(16)
      .backgroundColor($r('app.color.notice'))
      .borderRadius(18)
      .width('100%')
      Column({ space: 8 }) {
        Text('不申请麦克风、位置、联系人或存储权限，也不接入网络、账号、云同步或第三方 SDK。')
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text('页面内的“摘要”只是当前会话的文字汇总，不会生成文件或向外发送。')
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
        .borderRadius(14)
        .accessibilityText('已阅读隐私说明并继续使用会话内农事记录')
        .onClick(() => this.acceptPrivacy())
      Text('如暂不使用，请停留在本页。')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Button('返回')
          .fontSize(16)
          .fontColor($r('app.color.action'))
          .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
          .accessibilityText('返回农事记录页')
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
        .constraintSize({ minHeight: 48 })
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
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('农事口述簿')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .lineHeight(34)
          Text('无网手动记录切片 · 不录音、不上传')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .lineHeight(24)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('非建议')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.notice'))
          .borderRadius(8)
          .accessibilityText('记录不会变成种植或施药建议')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Column({ space: 6 }) {
        Text('记录不会变成种植、施药或贷款建议。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_notice'))
        Text('本页没有麦克风、转写、地点、联系人或文件导出。离开页面后作业记录消失。')
          .fontSize(14)
          .fontColor($r('app.color.text_notice'))
      }
      .padding(16)
      .backgroundColor($r('app.color.notice'))
      .borderRadius(18)
      .width('100%')

      Column({ space: 10 }) {
        Text('作业类型')
          .fontSize(19)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        ForEach(KINDS, (item: string) => {
          Button(this.kind === item ? `${item} · 已选择` : item)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .width('100%')
            .constraintSize({ minHeight: 48 })
            .padding(15)
            .borderRadius(15)
            .backgroundColor(this.kind === item ? $r('app.color.active') : $r('app.color.card'))
            .border({
              width: this.kind === item ? 0 : 1,
              color: $r('app.color.border_subtle')
            })
            .accessibilityText(this.kind === item ? `已选择作业类型 ${item}` : `选择作业类型 ${item}`)
            .onClick(() => this.kind = item)
        }, (item: string) => item)
      }
      .padding(18)
      .backgroundColor($r('app.color.card'))
      .borderRadius(18)
      .width('100%')

      Button(`添加今天的${this.kind}记录`)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: 52 })
        .fontColor($r('app.color.on_action'))
        .backgroundColor($r('app.color.action'))
        .borderRadius(14)
        .accessibilityText(`在本次会话添加一条${this.kind}记录`)
        .onClick(() => this.addNote())

      Column({ space: 10 }) {
        Text(this.filterToday ? `今天（${this.today()}）` : '本次会话全部记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text(`当前显示 ${this.visibleNotes().length} 笔。筛选只作用于本次会话，没有历史存档。`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Button(this.filterToday ? '查看本次会话全部记录' : '只看今天')
          .fontSize(16)
          .fontColor($r('app.color.action'))
          .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
          .accessibilityText(this.filterToday ? '取消仅今天筛选' : '只显示今天的会话记录')
          .onClick(() => {
            this.filterToday = !this.filterToday;
            this.showSummary = false;
          })
        if (this.visibleNotes().length === 0) {
          Text(this.notes.length === 0
            ? '还没有会话记录。添加后只留在本页，不会写入本机存储。'
            : '今天没有记录。可切换到本次会话全部记录查看其他时刻添加的条目。')
            .fontSize(15)
            .fontColor($r('app.color.text_secondary'))
        } else {
          ForEach(this.visibleNotes(), (note: FarmNote) => {
            Column({ space: 4 }) {
              Text(note.kind)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
              Text(`${note.day} ${note.time} · 仅本次会话`)
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
            }
            .padding(14)
            .backgroundColor($r('app.color.active'))
            .borderRadius(14)
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }, (note: FarmNote) => note.id.toString())
        }
      }
      .padding(20)
      .backgroundColor($r('app.color.card'))
      .borderRadius(20)
      .width('100%')

      Button('生成本次会话摘要')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .fontColor($r('app.color.on_action'))
        .backgroundColor($r('app.color.action'))
        .borderRadius(14)
        .accessibilityText('在页面内显示当前筛选结果的文字摘要，不生成文件')
        .onClick(() => this.showSummary = true)

      if (this.showSummary) {
        Column({ space: 8 }) {
          Text('页面内摘要 · 未生成文件')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_notice'))
          Text(`筛选范围内共 ${this.visibleNotes().length} 笔：播种 ${this.countByKind('播种')}，浇灌 ${this.countByKind('浇灌')}，观察 ${this.countByKind('观察')}。`)
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
          Text('该摘要不会导出、上传，也不构成种植建议。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .padding(16)
        .backgroundColor($r('app.color.notice'))
        .borderRadius(16)
        .width('100%')
      }

      if (this.notes.length > 0) {
        if (this.confirmClear) {
          Text('清除后无法从本页恢复这些会话记录。没有写入本机存储，也没有上传。')
            .fontSize(14)
            .lineHeight(22)
            .fontColor($r('app.color.text_danger'))
          Button('确认清除本次会话记录')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .constraintSize({ minHeight: 48 })
            .backgroundColor($r('app.color.notice'))
            .fontColor($r('app.color.text_danger'))
            .borderRadius(12)
            .accessibilityText('确认清除本次会话全部农事记录，此操作不能撤销')
            .onClick(() => this.clearSession())
          Button('取消清除')
            .fontSize(16)
            .fontColor($r('app.color.action'))
            .backgroundColor(Color.Transparent)
            .constraintSize({ minHeight: 48 })
            .onClick(() => this.confirmClear = false)
        } else {
          Button('清除本次会话记录')
            .fontSize(15)
            .fontColor($r('app.color.action'))
            .backgroundColor(Color.Transparent)
            .constraintSize({ minHeight: 48 })
            .accessibilityText('准备清除本次会话农事记录，下一步需要确认')
            .onClick(() => this.clearSession())
        }
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
        Text('录音、转写、加密数据库、文件导出和逐字段移除须在保留期确认后再实现。本切片不假装这些能力已经可用。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Button('查看隐私说明')
          .fontSize(15)
          .fontColor($r('app.color.action'))
          .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
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
