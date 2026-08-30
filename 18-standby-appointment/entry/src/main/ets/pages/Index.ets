const TIMES: string[] = ['上午 10:00', '下午 14:00', '傍晚 18:00'];

@Entry @Component struct Index {
  @State private selectedTime: string = '';
  @State private drafted: boolean = false;
  build() { Scroll() { Column({ space: 16 }) {
    Text('候补预约').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
    Text('演示模式：不连接商家日历、通知或真实服务。').fontSize(17).fontColor($r('app.color.text_secondary'))
    Column({ space: 7 }) {
      Text('虚构取消空档').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_notice'))
      Text('演示服务 · 明天 · 下午 14:00 · 45 分钟').fontSize(17).fontColor($r('app.color.text_primary'))
      Text('这不是商家真实可用时段，也不会保留给任何人。').fontSize(14).fontColor($r('app.color.text_notice'))
    }.padding(18).backgroundColor($r('app.color.notice')).borderRadius(20).width('100%')
    Column({ space: 10 }) {
      Text('你的候补偏好（仅本地）').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      ForEach(TIMES, (item: string) => {
        Button(item).width('100%').padding(15).borderRadius(15).backgroundColor(this.selectedTime === item ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).onClick(() => { this.selectedTime = item; this.drafted = false })
      }, (item: string) => item)
    }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
    Button('生成本地候补邀约草稿').width('100%').height(54).backgroundColor($r('app.color.action')).fontColor($r('app.color.on_action')).borderRadius(15).enabled(this.selectedTime !== '').onClick(() => this.drafted = true)
    if (this.drafted) { Column({ space: 8 }) {
      Text('本地邀约草稿已生成').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_success'))
      Text(`候补偏好：${this.selectedTime}。尚未通知商家或用户，未锁定任何真实时段。`).fontSize(16).fontColor($r('app.color.text_primary'))
      Button('撤销本地草稿').fontColor($r('app.color.action')).backgroundColor(Color.Transparent).onClick(() => this.drafted = false)
    }.padding(20).backgroundColor($r('app.color.active')).borderRadius(20).width('100%') }
  }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%') }.width('100%').height('100%').backgroundColor($r('app.color.canvas')) }
}
