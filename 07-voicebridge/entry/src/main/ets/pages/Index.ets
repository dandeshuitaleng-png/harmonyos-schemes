import { PrivacyChoiceStore, PRIVACY_ACCEPTED } from '../data/PrivacyChoiceStore';

interface PracticeLesson { id: string; title: string; script: string; }
const LESSONS: PracticeLesson[] = [
  { id: 'service', title: '客服沟通', script: '你好，我愿意先了解你的需求。请给我一点时间确认信息，再向你说明下一步。' },
  { id: 'guide', title: '社区导览', script: '你好，我可以说明这条路线的起点和下一处明显标识。如果不确定，我会先查证。' },
  { id: 'office', title: '基础办公', script: '我已记录当前任务。完成前我会复核名称、日期和需要交接的内容。' }
];

@Entry
@Component
struct Index {
  private readonly privacyStore: PrivacyChoiceStore = new PrivacyChoiceStore();
  @State private selectedId: string = LESSONS[0].id;
  @State private completed: boolean = false;
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
  private selectedLesson(): PracticeLesson {
    for (let index = 0; index < LESSONS.length; index += 1) if (LESSONS[index].id === this.selectedId) return LESSONS[index];
    return LESSONS[0];
  }
  private async loadPrivacy(): Promise<void> {
    try { this.privacyChoice = await this.privacyStore.load(getContext(this)); }
    catch { this.actionError = '无法读取本机隐私选择。请重试；练习标记不会保留。'; }
    finally { this.privacyReady = true; }
  }
  private async acceptPrivacy(): Promise<void> {
    try {
      await this.privacyStore.saveAccepted(getContext(this));
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.actionError = '';
    } catch { this.actionError = '无法保存“已阅读”标记。请重试；不会生成能力卡或投递记录。'; }
  }

  @Builder
  policyView() {
    Column({ space: 16 }) {
      Text('隐私说明').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('语桥求职 · com.harmonyradar.voicebridge').fontSize(16).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('练习完成不等于就业资格或机构认证。本版本没有音频、AI 评价、分享或投递。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('练习标记只存在于本次会话，离开页面即消失。本机仅可能保存你已阅读本说明的标记。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Text('开发者主体名称以应用市场登记信息为准。').fontSize(14).fontColor($r('app.color.text_secondary'))
      Button('已阅读并继续').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15)
        .onClick(() => this.acceptPrivacy())
      Text('如暂不使用，请停留在本页。').fontSize(14).fontColor($r('app.color.text_secondary'))
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Button('返回').fontSize(16).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.showPolicy = false)
      }
      if (this.actionError.length > 0) {
        Text(this.actionError).fontSize(14).fontColor($r('app.color.text_notice')).padding(14).backgroundColor($r('app.color.surface_notice')).borderRadius(14).width('100%')
      }
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%').constraintSize({ maxWidth: 640 })
  }

  @Builder
  mainView() {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('语桥求职').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
          Text('离线、可读的场景练习').fontSize(17).fontColor($r('app.color.text_secondary')).lineHeight(24)
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('非认证')
          .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.surface_notice')).borderRadius(8)
          .accessibilityText('练习完成不等于就业资格或机构认证')
      }.width('100%').alignItems(VerticalAlign.Top)
      Column({ space: 6 }) {
        Text('练习完成不等于就业资格或机构认证').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('本版本没有音频、AI 评价、能力卡、分享或投递；文字稿是全部学习内容。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text('选择练习场景').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(LESSONS, (lesson: PracticeLesson) => {
          Button(this.selectedId === lesson.id ? `${lesson.title} · 已选择` : lesson.title)
            .fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
            .width('100%').constraintSize({ minHeight: 48 }).padding(15).borderRadius(15)
            .backgroundColor(this.selectedId === lesson.id ? $r('app.color.surface_done') : $r('app.color.surface_card'))
            .border({
              width: this.selectedId === lesson.id ? 0 : 1,
              color: $r('app.color.border_subtle')
            })
            .accessibilityText(this.selectedId === lesson.id ? `已选择${lesson.title}` : `选择${lesson.title}`)
            .onClick(() => { this.selectedId = lesson.id; this.completed = false; })
        }, (lesson: PracticeLesson) => lesson.id)
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Column({ space: 8 }) {
        Text('本次文字稿').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        Text(this.selectedLesson().script).fontSize(18).fontColor($r('app.color.text_primary'))
        Text('你可以使用读屏朗读这段文字，再按自己的节奏练习。').fontSize(14).fontColor($r('app.color.text_secondary'))
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Button('仅标记本次本人练习').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 54 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15).onClick(() => this.completed = true)
      if (this.completed) {
        Column({ space: 7 }) {
          Text('本次会话已标记为本人练习').fontSize(19).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_done'))
          Text('离开页面后该标记不会保留；没有生成能力卡、不会分享给机构或联系人，也不代表就业资格。').fontSize(15).fontColor($r('app.color.text_primary'))
        }.padding(20).backgroundColor($r('app.color.surface_done')).borderRadius(20).width('100%')
      }
      Button('查看隐私说明').fontSize(15).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.showPolicy = true)
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
