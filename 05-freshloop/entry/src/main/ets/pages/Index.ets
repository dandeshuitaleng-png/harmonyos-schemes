import { PrivacyChoiceStore, PRIVACY_ACCEPTED } from '../data/PrivacyChoiceStore';

interface SafetyOption { id: string; name: string; outcome: string; detail: string; blocked: boolean; }

const OPTIONS: SafetyOption[] = [
  { id: 'sealed-labelled', name: '带标签的密封食品', outcome: '仅具备人工审核准备条件', detail: '仍需由工作人员补全过敏原、制作/到期时间和数量；本页不提供提交入口，更不表示可转赠。', blocked: false },
  { id: 'unlabelled-bulk', name: '未注明过敏原的散装高风险食品', outcome: '不可进入后续流程', detail: '缺少过敏原信息的散装高风险食品不能发布、预约或领取。', blocked: true },
  { id: 'alcohol-or-medicine', name: '药品或酒精', outcome: '不可进入后续流程', detail: '药品和酒精不属于本服务允许的食物转赠范围。', blocked: true }
];

@Entry
@Component
struct Index {
  private readonly privacyStore: PrivacyChoiceStore = new PrivacyChoiceStore();
  @State private selectedId: string = OPTIONS[0].id;
  @State private checked: boolean = false;
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
  private selectedOption(): SafetyOption {
    for (let index = 0; index < OPTIONS.length; index += 1) if (OPTIONS[index].id === this.selectedId) return OPTIONS[index];
    return OPTIONS[0];
  }
  private async loadPrivacy(): Promise<void> {
    try { this.privacyChoice = await this.privacyStore.load(getContext(this)); }
    catch { this.actionError = '无法读取本机隐私选择。请重试；本页不保存食物信息。'; }
    finally { this.privacyReady = true; }
  }
  private async acceptPrivacy(): Promise<void> {
    try {
      await this.privacyStore.saveAccepted(getContext(this));
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.actionError = '';
    } catch { this.actionError = '无法保存“已阅读”标记。请重试；不会保存食物或领取信息。'; }
  }

  @Builder
  policyView() {
    Column({ space: 16 }) {
      Text('隐私说明').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('食光循环 · com.harmonyradar.freshloop').fontSize(16).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('本页只做本地安全规则说明，不发布食物、不接受预约、不显示领取点。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('不申请相机、位置或联系人权限。检查结果不保存。本机仅可能保存你已阅读本说明的标记。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Text('通过筛选不等于食品安全。开发者主体名称以应用市场登记信息为准。').fontSize(14).fontColor($r('app.color.text_secondary'))
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
      Text('食光循环').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('社区食物转赠的本地安全筛选草稿').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('通过筛选不等于食品安全、商家资质或可领取').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('本页不发布食物、不接受预约、不显示领取点，也不会对食品作平台背书。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text('选择拟处理的品类').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(OPTIONS, (item: SafetyOption) => {
          Button() {
            Column({ space: 5 }) {
              Text(item.name).fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
              Text(item.blocked ? '硬规则：直接拒绝' : '需要补全信息后人工审核').fontSize(14).fontColor(item.blocked ? $r('app.color.text_blocked') : $r('app.color.text_safe'))
            }.alignItems(HorizontalAlign.Start).width('100%')
          }.width('100%').padding(15).borderRadius(15)
           .backgroundColor(this.selectedId === item.id ? $r('app.color.surface_notice') : $r('app.color.surface_card'))
           .onClick(() => { this.selectedId = item.id; this.checked = false; })
        }, (item: SafetyOption) => item.id)
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Button('检查基础安全规则').fontSize(17).fontWeight(FontWeight.Medium).width('100%').constraintSize({ minHeight: 54 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(15).onClick(() => this.checked = true)
      if (this.checked) {
        Column({ space: 8 }) {
          Text('基础信息检查结果').fontSize(15).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_secondary'))
          Text(this.selectedOption().outcome).fontSize(20).fontWeight(FontWeight.Bold).fontColor(this.selectedOption().blocked ? $r('app.color.text_blocked') : $r('app.color.text_safe'))
          Text(this.selectedOption().detail).fontSize(16).fontColor($r('app.color.text_primary'))
          Text(this.selectedOption().blocked ? '此草稿不保存、不发布，也不能进入预约或领取。' : '这不是食品安全结论；此草稿不保存、不发布，工作人员可另行决定是否审核。').fontSize(14).fontColor($r('app.color.text_secondary'))
        }.padding(20).backgroundColor(this.selectedOption().blocked ? $r('app.color.surface_blocked') : $r('app.color.surface_safe')).borderRadius(20).width('100%')
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
