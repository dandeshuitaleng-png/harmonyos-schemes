const FEATURE_TASKS: string[] = ['叶缘', '叶脉', '花果', '树皮'];
const PLACES: string[] = ['公园', '街边', '校园', '社区'];
const LEAF_EDGE_OPTIONS: string[] = ['边缘看起来平滑', '边缘有明显锯齿', '边缘有分裂或裂片', '暂时看不清'];
const LEAF_VEIN_OPTIONS: string[] = ['可见一条主脉', '可见多条分叉脉', '可见大致平行的脉', '暂时看不清'];
const FLOWER_FRUIT_OPTIONS: string[] = ['看到花或花苞', '看到果实或种子结构', '未见花果', '暂时看不清'];
const BARK_OPTIONS: string[] = ['表面较平滑', '表面粗糙有纹理', '有片状脱落或裂纹', '暂时看不清'];

@Entry
@Component
struct Index {
  @State private task: string = '';
  @State private place: string = '';
  @State private selectedVisibleFeatures: string[] = [];
  @State private reviewCreated: boolean = false;
  @State private deletedNotice: boolean = false;

  private visibleOptions(): string[] {
    if (this.task === '叶缘') { return LEAF_EDGE_OPTIONS; }
    if (this.task === '叶脉') { return LEAF_VEIN_OPTIONS; }
    if (this.task === '花果') { return FLOWER_FRUIT_OPTIONS; }
    if (this.task === '树皮') { return BARK_OPTIONS; }
    return [];
  }
  private hasVisibleFeature(option: string): boolean { return this.selectedVisibleFeatures.indexOf(option) >= 0; }
  private canConfirm(): boolean { return this.task.length > 0 && this.place.length > 0 && this.selectedVisibleFeatures.length > 0; }
  private selectTask(task: string): void { this.task = task; this.selectedVisibleFeatures = []; this.reviewCreated = false; this.deletedNotice = false; }
  private selectPlace(place: string): void { this.place = place; this.reviewCreated = false; this.deletedNotice = false; }
  private toggleVisibleFeature(option: string): void {
    const next: string[] = [];
    let existed = false;
    this.selectedVisibleFeatures.forEach((item: string) => { if (item === option) { existed = true; } else { next.push(item); } });
    if (!existed) { next.push(option); }
    this.selectedVisibleFeatures = next; this.reviewCreated = false; this.deletedNotice = false;
  }
  private removeSessionReview(): void { this.reviewCreated = false; this.selectedVisibleFeatures = []; this.deletedNotice = true; }

  build() {
    Scroll() { Column({ space: 16 }) {
      Text('城市自然观察').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('城市植物特征观察 · 不识别、不定位、不上传').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('个人观察 · 未鉴定').fontSize(17).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_notice'))
        Text('请只记录肉眼可见特征；本页不推断物种、健康状况或生态结论。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.notice')).borderRadius(18).width('100%')
      Column({ space: 8 }) {
        Text('1. 选择观察任务').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(FEATURE_TASKS, (item: string) => {
          Button(this.task === item ? `${item} · 已选择` : item).width('100%').constraintSize({ minHeight: 48 }).borderRadius(14).backgroundColor(this.task === item ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).accessibilityText(this.task === item ? `已选择${item}观察任务` : `选择${item}观察任务`).onClick(() => this.selectTask(item))
        }, (item: string) => item)
      }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
      Column({ space: 8 }) {
        Text('2. 选择粗略环境').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(PLACES, (item: string) => {
          Button(this.place === item ? `${item} · 已选择` : item).width('100%').constraintSize({ minHeight: 48 }).borderRadius(14).backgroundColor(this.place === item ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).accessibilityText(this.place === item ? `已选择${item}粗略环境` : `选择${item}粗略环境，不记录定位`).onClick(() => this.selectPlace(item))
        }, (item: string) => item)
      }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
      if (this.task.length > 0) {
        Column({ space: 8 }) {
          Text(`3. 勾选肉眼可见的${this.task}特征`).fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          Text('可选择多个；“暂时看不清”也是有效观察，不表示鉴定失败。').fontSize(14).fontColor($r('app.color.text_secondary'))
          ForEach(this.visibleOptions(), (item: string) => {
            Button(this.hasVisibleFeature(item) ? `${item} · 已勾选` : item).width('100%').constraintSize({ minHeight: 48 }).borderRadius(14).backgroundColor(this.hasVisibleFeature(item) ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).accessibilityText(this.hasVisibleFeature(item) ? `已勾选可见特征${item}` : `勾选可见特征${item}`).onClick(() => this.toggleVisibleFeature(item))
          }, (item: string) => item)
        }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
      }
      if (!this.canConfirm()) { Text(this.task.length === 0 ? '先选择一项观察任务。' : this.place.length === 0 ? '选择粗略环境后继续；不会记录定位。' : '至少勾选一个肉眼可见特征后才能确认观察。').fontSize(14).fontColor($r('app.color.text_secondary')) }
      Button('确认本次个人观察').width('100%').height(54).backgroundColor($r('app.color.action')).fontColor($r('app.color.on_action')).borderRadius(15).enabled(this.canConfirm()).accessibilityText(this.canConfirm() ? '确认本次个人观察，未鉴定且不保存上传' : '请先选择任务、环境和至少一个可见特征').onClick(() => { this.reviewCreated = true; this.deletedNotice = false; })
      if (this.reviewCreated) {
        Column({ space: 8 }) {
          Text('个人观察，未鉴定').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_success'))
          Text(`${this.place} · 观察任务：${this.task}`).fontSize(16).fontColor($r('app.color.text_primary'))
          Text(`肉眼可见：${this.selectedVisibleFeatures.join('；')}`).fontSize(15).fontColor($r('app.color.text_primary'))
          Text('仅保留在当前会话；不保存、不上传，也不生成物种结论。').fontSize(14).fontColor($r('app.color.text_secondary'))
          Button('删除本次个人观察').fontColor($r('app.color.action')).backgroundColor(Color.Transparent).accessibilityText('删除本次会话内个人观察').onClick(() => this.removeSessionReview())
        }.padding(20).backgroundColor($r('app.color.active')).borderRadius(20).width('100%')
      }
      if (this.deletedNotice) { Text('已删除本次会话观察；没有任何内容被保存或上传。').fontSize(14).fontColor($r('app.color.text_secondary')) }
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%') }.width('100%').height('100%').backgroundColor($r('app.color.canvas'))
  }
}
