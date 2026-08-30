interface Lesson { id: string; title: string; explanation: string; question: string; options: string[]; answer: number; }
const LESSONS: Lesson[] = [
  { id: 'orbit', title: '什么是近地天体？', explanation: '近地天体是轨道会接近地球轨道区域的天体类别。这个概念本身不说明某个对象当前是否有风险。', question: '“近地”这个分类能直接证明什么？', options: ['它一定会撞击地球', '它的轨道接近地球轨道区域', '它一定肉眼可见'], answer: 1 },
  { id: 'scale', title: '距离与尺度', explanation: '天文学常用不同尺度描述距离。学习时应先看单位、数据日期和来源，再比较数字。', question: '阅读距离数据前，最应先确认什么？', options: ['单位、来源和数据日期', '标题是否惊人', '颜色是否醒目'], answer: 0 },
  { id: 'risk', title: '风险表达', explanation: '轨道预测会随观测数据更新。可靠表达必须说明数据来源、时间和不确定性，不能用恐慌性标题代替证据。', question: '本离线模块为什么不显示风险等级？', options: ['因为不需要数据', '因为当前风险需要带日期的权威数据', '因为风险从不变化'], answer: 1 }
];

@Entry
@Component
struct Index {
  @State private selectedId: string = LESSONS[0].id;
  @State private chosenAnswer: number = -1;
  private lesson(): Lesson { for (let index = 0; index < LESSONS.length; index += 1) if (LESSONS[index].id === this.selectedId) return LESSONS[index]; return LESSONS[0]; }
  private chooseLesson(id: string): void { this.selectedId = id; this.chosenAnswer = -1; }
  build() {
    Scroll() { Column({ space: 16 }) {
      Text('近地天体探索').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('离线基础学习，不是实时轨道或风险服务。').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) { Text('当前天体位置、距离和风险等级必须以带数据日期的权威来源为准。').fontSize(15).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice')); Text('本页只提供稳定的基础概念；不生成预警或撞击判断。').fontSize(14).fontColor($r('app.color.text_notice')) }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 8 }) { Text('选择学习卡').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')); ForEach(LESSONS, (item: Lesson) => { Button(item.title).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).width('100%').padding(14).borderRadius(14).backgroundColor(this.selectedId === item.id ? $r('app.color.surface_active') : $r('app.color.surface_card')).onClick(() => this.chooseLesson(item.id)) }, (item: Lesson) => item.id) }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      Column({ space: 10 }) { Text(this.lesson().title).fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')); Text(this.lesson().explanation).fontSize(17).fontColor($r('app.color.text_primary')); Text('来源边界：NASA CNEOS 等权威机构可用于未来实时数据核验；本页当前未加载任何实时数据。').fontSize(14).fontColor($r('app.color.text_secondary')) }.padding(20).backgroundColor($r('app.color.surface_active')).borderRadius(20).width('100%')
      Column({ space: 10 }) { Text('自检问题').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')); Text(this.lesson().question).fontSize(17).fontColor($r('app.color.text_primary')); ForEach(this.lesson().options, (option: string, index: number) => { Button(option).fontSize(16).fontColor($r('app.color.text_primary')).width('100%').padding(14).borderRadius(14).backgroundColor(this.chosenAnswer === index ? $r('app.color.surface_choice') : $r('app.color.surface_card')).onClick(() => this.chosenAnswer = index) }, (option: string) => option); if (this.chosenAnswer >= 0) { Text(this.chosenAnswer === this.lesson().answer ? '理解正确：继续下一张学习卡。' : '可以再读一次解释；错误并不代表能力不足。').fontSize(15).fontColor(this.chosenAnswer === this.lesson().answer ? $r('app.color.text_success') : $r('app.color.text_notice')) } }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%') }.width('100%').height('100%').backgroundColor($r('app.color.surface_canvas'))
  }
}
