import { HelpRequest } from '../models/HelpRequestModels';

@Component
export struct HelpRequestForm {
  @Link requests: HelpRequest[];
  @Link showForm: boolean;
  @State alias: string = '';
  @State category: string = '养老照护';
  @State urgency: string = '普通';
  @State description: string = '';
  @State errorMessage: string = '';

  private categories: string[] = ['养老照护', '残障支持', '困难家庭', '就业咨询'];
  private urgencyLevels: string[] = ['普通', '较急'];

  private saveDraft(): void {
    if (!this.alias.trim() || !this.description.trim()) {
      this.errorMessage = '请填写对象代号和诉求描述';
      return;
    }

    const now: Date = new Date();
    const item: HelpRequest = {
      id: `HR-MOCK-${now.getTime()}`,
      alias: this.alias.trim(),
      category: this.category,
      description: this.description.trim(),
      status: 'registered',
      createdAt: '刚刚',
      dueAt: '待设置回访',
      urgency: this.urgency
    };
    this.requests = [item, ...this.requests];
    this.alias = '';
    this.description = '';
    this.errorMessage = '';
    this.showForm = false;
  }

  @Builder
  private optionChip(label: string, selected: boolean, onTap: () => void) {
    Button(label)
      .fontSize(17)
      .fontColor(selected ? '#FFFFFF' : '#005E5A')
      .backgroundColor(selected ? '#005E5A' : '#FFFFFF')
      .border({ width: 1, color: '#005E5A' })
      .borderRadius(8)
      .height(56)
      .padding({ left: 14, right: 14 })
      .onClick(onTap)
      .accessibilityText(`${label}${selected ? '，已选择' : ''}`)
  }

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('求助登记')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .layoutWeight(1)
        Button('关闭')
          .fontSize(17)
          .fontColor('#005E5A')
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#D1D5DB' })
          .borderRadius(8)
          .height(56)
          .onClick(() => {
            this.showForm = false;
          })
          .accessibilityText('关闭求助登记表单')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('对象代号')
        .fontSize(17)
        .fontColor('#111827')
        .width('100%')
      TextInput({ placeholder: '例如：朝阳里 03', text: this.alias })
        .fontSize(17)
        .height(56)
        .backgroundColor('#F7F8FA')
        .borderRadius(8)
        .onChange((value: string) => {
          this.alias = value;
        })
        .accessibilityText('对象代号输入框')

      Text('诉求类型')
        .fontSize(17)
        .fontColor('#111827')
        .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.categories, (item: string) => {
          this.optionChip(item, this.category === item, () => {
            this.category = item;
          })
        })
      }
      .width('100%')

      Text('紧急程度')
        .fontSize(17)
        .fontColor('#111827')
        .width('100%')
      Row({ space: 8 }) {
        ForEach(this.urgencyLevels, (item: string) => {
          this.optionChip(item, this.urgency === item, () => {
            this.urgency = item;
          })
        })
      }
      .width('100%')

      Text('诉求描述')
        .fontSize(17)
        .fontColor('#111827')
        .width('100%')
      TextArea({ placeholder: '只记录事实和下一步，不做资格判断。', text: this.description })
        .fontSize(17)
        .height(120)
        .backgroundColor('#F7F8FA')
        .borderRadius(8)
        .onChange((value: string) => {
          this.description = value;
        })
        .accessibilityText('诉求描述输入框')

      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(16)
          .fontColor('#B45309')
          .width('100%')
      }

      Button('先记录诉求')
        .fontSize(20)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .height(56)
        .backgroundColor('#005E5A')
        .borderRadius(8)
        .onClick(() => {
          this.saveDraft();
        })
        .accessibilityText('保存求助登记')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: '#D1D5DB' })
  }
}
