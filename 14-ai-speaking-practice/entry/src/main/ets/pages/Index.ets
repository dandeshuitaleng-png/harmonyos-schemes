const PHRASES: string[] = ['Could I have a coffee, please?', 'Where is the nearest station?', 'I need to check in.'];
@Entry @Component struct Index {
  @State private selected: string = '';
  @State private reviewed: boolean = false;
  build() { Scroll() { Column({ space: 16 }) {
    Text('口语情境练习').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
    Text('咖啡店 · 离线文本练习').fontSize(17).fontColor($r('app.color.text_secondary'))
    Column({ space: 7 }) { Text('这是预置表达对照，不是 AI 对话或发音评测。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice')); Text('不会录音、上传或判断你的语言水平。').fontSize(14).fontColor($r('app.color.text_notice')) }.padding(17).backgroundColor($r('app.color.notice')).borderRadius(20).width('100%')
    Column({ space: 10 }) { Text('你想怎么点一杯咖啡？').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')); ForEach(PHRASES, (item: string) => { Button(item).width('100%').padding(16).borderRadius(15).backgroundColor(this.selected === item ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).onClick(() => { this.selected = item; this.reviewed = false }) }, (item: string) => item) }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
    Button('查看预置复习提示').width('100%').height(54).backgroundColor($r('app.color.action')).fontColor($r('app.color.on_action')).borderRadius(15).enabled(this.selected !== '').onClick(() => this.reviewed = true)
    if (this.reviewed) { Column({ space: 8 }) { Text('复习提示').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_success')); Text(this.selected === PHRASES[0] ? '“Could I have …, please?” 是一个礼貌点单句式。' : '此选项不对应本题的咖啡点单表达；可试试带有 coffee 的句子。').fontSize(16).fontColor($r('app.color.text_primary')); Text('这是固定内容，不代表自动评测结果。').fontSize(14).fontColor($r('app.color.text_secondary')) }.padding(20).backgroundColor($r('app.color.active')).borderRadius(20).width('100%') }
  }.padding({ left:20,right:20,top:28,bottom:36 }).alignItems(HorizontalAlign.Start).width('100%') }.width('100%').height('100%').backgroundColor($r('app.color.canvas')) }
}
