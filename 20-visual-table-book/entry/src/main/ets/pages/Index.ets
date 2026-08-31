interface Table { id: string; seats: number; available: boolean; }
const TABLES: Table[] = [{ id: 'A1', seats: 2, available: true }, { id: 'A2', seats: 2, available: false }, { id: 'B1', seats: 4, available: true }, { id: 'B2', seats: 4, available: true }];
const DEMO_DATES: string[] = ['演示日期：周五', '演示日期：周六', '演示日期：周日'];

@Entry
@Component
struct Index {
  @State private selected: string = '';
  @State private people: number = 2;
  @State private selectedDate: string = '';
  @State private drafted: boolean = false;

  private table(): Table | undefined { for (let index = 0; index < TABLES.length; index += 1) { if (TABLES[index].id === this.selected) { return TABLES[index]; } } return undefined; }
  private canDraft(): boolean { return this.selectedDate.length > 0 && this.table() !== undefined; }
  private clearDraft(): void { this.drafted = false; }

  build() {
    Scroll() { Column({ space: 16 }) {
      Text('可视化订桌').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('演示模式：不连接真实餐厅、库存或支付。').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('任何草稿都不会发送给商家，也不是确认预约。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice'))
        Text('日期、桌位和人数均为本地演示选择。').fontSize(14).fontColor($r('app.color.text_notice'))
      }.padding(16).backgroundColor($r('app.color.notice')).borderRadius(18).width('100%')
      Column({ space: 8 }) {
        Text('选择演示日期').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(DEMO_DATES, (date: string) => {
          Button(this.selectedDate === date ? `${date} · 已选择` : date).width('100%').constraintSize({ minHeight: 48 }).borderRadius(15).backgroundColor(this.selectedDate === date ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).accessibilityText(this.selectedDate === date ? `已选择${date}` : `选择${date}`).onClick(() => { this.selectedDate = date; this.clearDraft(); })
        }, (date: string) => date)
      }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
      Column({ space: 8 }) {
        Text('演示人数').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        Row({ space: 12 }) {
          Button(this.people === 2 ? '2 人 · 已选择' : '2 人').backgroundColor(this.people === 2 ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).accessibilityText(this.people === 2 ? '已选择2人演示人数' : '选择2人演示人数').onClick(() => { this.people = 2; this.clearDraft(); })
          Button(this.people === 4 ? '4 人 · 已选择' : '4 人').backgroundColor(this.people === 4 ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).accessibilityText(this.people === 4 ? '已选择4人演示人数' : '选择4人演示人数').onClick(() => { this.people = 4; this.clearDraft(); })
        }
      }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
      Column({ space: 10 }) {
        Text('选择演示桌位').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        ForEach(TABLES, (item: Table) => {
          Button(`${item.id} · ${item.seats} 座 · ${item.available ? '可选演示桌' : '不可用演示桌'}${this.selected === item.id ? ' · 已选择' : ''}`).width('100%').padding(15).borderRadius(15).backgroundColor(this.selected === item.id ? $r('app.color.active') : $r('app.color.card')).fontColor($r('app.color.text_primary')).enabled(item.available && item.seats >= this.people).accessibilityText(`${item.id}，${item.seats}座，${item.available && item.seats >= this.people ? (this.selected === item.id ? '已选择演示桌' : '可选择演示桌') : '当前不可用演示桌'}`).onClick(() => { this.selected = item.id; this.clearDraft(); })
        }, (item: Table) => item.id)
      }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
      if (!this.canDraft()) { Text(this.selectedDate.length === 0 ? '先选择一个演示日期，再选择可用演示桌位。' : '选择一张可用演示桌位后，才能创建本地草稿。').fontSize(14).fontColor($r('app.color.text_secondary')) }
      Button('创建本地预约草稿').width('100%').height(54).backgroundColor($r('app.color.action')).fontColor($r('app.color.on_action')).borderRadius(15).enabled(this.canDraft()).accessibilityText(this.canDraft() ? '创建仅在本机保存的演示预约草稿' : '请先选择演示日期和可用演示桌位').onClick(() => this.drafted = true)
      if (this.drafted) {
        Column({ space: 8 }) {
          Text('本地草稿已创建').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_success'))
          Text(`${this.selectedDate} · ${this.selected} · ${this.people} 人。未发送给商家，未占用真实桌位。`).fontSize(16).fontColor($r('app.color.text_primary'))
          Button('取消本地草稿').fontColor($r('app.color.action')).backgroundColor(Color.Transparent).accessibilityText('取消本地演示预约草稿，不发送任何信息').onClick(() => this.drafted = false)
        }.padding(20).backgroundColor($r('app.color.active')).borderRadius(20).width('100%')
      }
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%') }.width('100%').height('100%').backgroundColor($r('app.color.canvas'))
  }
}
