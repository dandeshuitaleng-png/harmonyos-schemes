const FEELINGS: string[] = ['我需要被倾听', '我想暂时安静', '我希望得到具体帮助'];

@Entry
@Component
struct Index {
  @State private selected: string = '';
  @State private card: string = '';
  @State private confirmDelete: boolean = false;

  onBackPress(): boolean {
    if (this.confirmDelete) {
      this.confirmDelete = false;
      return true;
    }
    return false;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text('共情回声').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
            Text('本地沟通卡 · 不登录、不上传、不建社区').fontSize(16).fontColor($r('app.color.text_secondary')).lineHeight(24)
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          Text('非诊疗')
            .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .backgroundColor($r('app.color.active')).borderRadius(8)
            .accessibilityText('这不是诊断或治疗')
        }.width('100%').alignItems(VerticalAlign.Top)

        Column({ space: 8 }) {
          Text('选择此刻想表达的需求').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          ForEach(FEELINGS, (item: string) => {
            Button(this.selected === item ? `${item} · 已选择` : item)
              .width('100%').constraintSize({ minHeight: 48 }).padding(15)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor(this.selected === item ? $r('app.color.active') : $r('app.color.card'))
              .border({ width: this.selected === item ? 0 : 1, color: $r('app.color.border_subtle') })
              .borderRadius(15)
              .accessibilityText(this.selected === item ? `已选择：${item}` : `选择：${item}`)
              .onClick(() => {
                this.selected = item;
                this.card = '';
                this.confirmDelete = false;
              })
          }, (item: string) => item)
        }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')

        Button('创建本地沟通卡')
          .width('100%').height(54).fontColor($r('app.color.on_action')).backgroundColor($r('app.color.action')).borderRadius(15)
          .enabled(this.selected !== '')
          .onClick(() => this.card = this.selected)

        if (this.card !== '') {
          Column({ space: 8 }) {
            Text('本地预览').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
            Text(`我想说：${this.card}。`).fontSize(17).lineHeight(26).fontColor($r('app.color.text_primary'))
            Text('这张卡只存在于当前会话；尚未通过系统渠道分享。').fontSize(14).lineHeight(22).fontColor($r('app.color.text_secondary'))
            if (this.confirmDelete) {
              Text('删除后无法从本页恢复这张会话卡。没有上传。')
                .fontSize(14).lineHeight(22).fontColor($r('app.color.text_danger'))
              Button('确认删除本地卡')
                .width('100%').constraintSize({ minHeight: 48 })
                .fontColor($r('app.color.text_danger')).backgroundColor($r('app.color.active')).borderRadius(12)
                .onClick(() => {
                  this.card = '';
                  this.confirmDelete = false;
                })
              Button('取消删除').fontColor($r('app.color.action')).backgroundColor(Color.Transparent)
                .constraintSize({ minHeight: 48 }).onClick(() => this.confirmDelete = false)
            } else {
              Button('删除本地卡').fontColor($r('app.color.action')).backgroundColor(Color.Transparent)
                .constraintSize({ minHeight: 48 }).onClick(() => this.confirmDelete = true)
            }
          }.padding(20).backgroundColor($r('app.color.active')).borderRadius(20).width('100%')
        }
      }.padding(20).alignItems(HorizontalAlign.Start).width('100%').constraintSize({ maxWidth: 640 })
    }.width('100%').height('100%').backgroundColor($r('app.color.canvas'))
  }
}
