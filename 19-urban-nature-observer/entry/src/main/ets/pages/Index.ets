const FEATURES: string[] = ['叶缘形状', '叶脉走向', '花果特征', '树皮纹理'];
const PLACES: string[] = ['公园', '街边', '校园', '社区'];
@Entry @Component struct Index {
  @State private feature: string = FEATURES[0]; @State private place: string = PLACES[0]; @State private confirmed: boolean = false;
  build() { Scroll() { Column({ space: 16 }) {
    Text('城市自然观察').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
    Text('城市植物特征观察 · 不识别、不定位、不上传').fontSize(17).fontColor($r('app.color.text_secondary'))
    Column({ space: 6 }) { Text('这是一条个人观察记录，不是物种鉴定或生态结论。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice')); Text('不拍摄照片、不记录精确位置，也不公开敏感物种地点。').fontSize(14).fontColor($r('app.color.text_notice')) }.padding(16).backgroundColor($r('app.color.notice')).borderRadius(18).width('100%')
    Column({ space: 8 }) { Text('今天想观察什么？').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')); ForEach(FEATURES, (item: string) => { Button(item).width('100%').padding(14).borderRadius(14).backgroundColor(this.feature === item ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).onClick(() => { this.feature = item; this.confirmed = false; }) }, (item: string) => item) }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
    Column({ space: 8 }) { Text('粗略环境').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')); ForEach(PLACES, (item: string) => { Button(item).width('100%').padding(12).borderRadius(14).backgroundColor(this.place === item ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).onClick(() => { this.place = item; this.confirmed = false; }) }, (item: string) => item) }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
    Button('确认本次观察范围').width('100%').height(54).backgroundColor($r('app.color.action')).fontColor($r('app.color.on_action')).borderRadius(15).onClick(() => this.confirmed = true)
    if (this.confirmed) { Column({ space: 8 }) { Text('个人观察已准备').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_success')); Text(`在${this.place}留意${this.feature}。请只记录肉眼可见特征，不推断物种或健康状况。`).fontSize(16).fontColor($r('app.color.text_primary')); Text('本页不保存、不上传，也不生成鉴定结果。').fontSize(14).fontColor($r('app.color.text_secondary')) }.padding(20).backgroundColor($r('app.color.active')).borderRadius(20).width('100%') }
  }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%') }.width('100%').height('100%').backgroundColor($r('app.color.canvas')) }
}
