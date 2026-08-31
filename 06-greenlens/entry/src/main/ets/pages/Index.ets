import { PrivacyChoiceStore, PRIVACY_ACCEPTED } from '../data/PrivacyChoiceStore';

interface ObservationTopic { id: string; title: string; privacy: string; }
const TOPICS: ObservationTopic[] = [
  { id: 'waste', title: '垃圾分类点观察', privacy: '不拍摄个人、车牌或住址；本轮不采集图片。' },
  { id: 'water', title: '积水感受观察', privacy: '不记录精确位置；本轮不采集照片或传感器读数。' },
  { id: 'tree', title: '树木状况观察', privacy: '不记录受保护物种地点；本轮不进行图像分类。' }
];

@Entry
@Component
struct Index {
  private readonly privacyStore: PrivacyChoiceStore = new PrivacyChoiceStore();
  @State private selectedId: string = TOPICS[0].id;
  @State private confirmed: boolean = false;
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
  private selectedTopic(): ObservationTopic {
    for (let index = 0; index < TOPICS.length; index += 1) if (TOPICS[index].id === this.selectedId) return TOPICS[index];
    return TOPICS[0];
  }
  private async loadPrivacy(): Promise<void> {
    try { this.privacyChoice = await this.privacyStore.load(getContext(this)); }
    catch { this.actionError = '无法读取本机隐私选择。请重试；不会创建观察记录。'; }
    finally { this.privacyReady = true; }
  }
  private async acceptPrivacy(): Promise<void> {
    try {
      await this.privacyStore.saveAccepted(getContext(this));
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.actionError = '';
    } catch { this.actionError = '无法保存“已阅读”标记。请重试；不会保存地点或照片。'; }
  }

  @Builder
  policyView() {
    Column({ space: 16 }) {
      Text('隐私说明').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('青眼巡查 · com.harmonyradar.greenlens').fontSize(16).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('本页只确认观察范围，不产生环境事实或执法结论。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('没有相机、定位、传感器或上传。确认结果不保存。本机仅可能保存你已阅读本说明的标记。').fontSize(14).fontColor($r('app.color.text_notice'))
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
          Text('青眼巡查').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
          Text('社区环境观察的范围确认').fontSize(17).fontColor($r('app.color.text_secondary')).lineHeight(24)
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('非执法')
          .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.surface_notice')).borderRadius(8)
          .accessibilityText('本页不产生环境事实或执法结论')
      }.width('100%').alignItems(VerticalAlign.Top)
      Column({ space: 6 }) {
        Text('本页不产生环境事实或执法结论').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('没有相机、定位、传感器、AI 分类或上传；不会公开任何素材或地点。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text('选择观察主题').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(TOPICS, (topic: ObservationTopic) => {
          Button() {
            Column({ space: 5 }) {
              Text(this.selectedId === topic.id ? `${topic.title} · 已选择` : topic.title)
                .fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).lineHeight(24)
              Text(topic.privacy).fontSize(14).fontColor($r('app.color.text_secondary')).lineHeight(22)
            }.alignItems(HorizontalAlign.Start).width('100%')
          }.width('100%').constraintSize({ minHeight: 48 }).padding(15).borderRadius(15)
           .backgroundColor(this.selectedId === topic.id ? $r('app.color.surface_notice') : $r('app.color.surface_card'))
           .border({
             width: this.selectedId === topic.id ? 0 : 1,
             color: $r('app.color.border_subtle')
           })
           .accessibilityText(this.selectedId === topic.id ? `已选择${topic.title}` : `选择${topic.title}`)
           .onClick(() => { this.selectedId = topic.id; this.confirmed = false; })
        }, (topic: ObservationTopic) => topic.id)
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Button('确认本次仅做范围观察').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 54 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15).onClick(() => this.confirmed = true)
      if (this.confirmed) {
        Column({ space: 8 }) {
          Text('页面确认完成：不生成记录').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_confirm'))
          Text(`${this.selectedTopic().title} 仅作为本地范围说明，不会创建观察记录或做任何自动判断。`).fontSize(16).fontColor($r('app.color.text_primary'))
          Text('将来接入采集前，需要独立验证公开范围、位置模糊、人工复核与保留期。').fontSize(14).fontColor($r('app.color.text_secondary'))
        }.padding(20).backgroundColor($r('app.color.surface_confirm')).borderRadius(20).width('100%')
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
