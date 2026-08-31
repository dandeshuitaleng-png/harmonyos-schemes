interface Food {
  name: string;
  days: number;
}

const FOODS: Food[] = [
  { name: '菠菜', days: 1 },
  { name: '酸奶', days: 2 },
  { name: '胡萝卜', days: 5 }
];

@Entry
@Component
struct Index {
  @State private picked: string = '';

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text('食材管家').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
            Text('本地演示 · 按临期程度整理').fontSize(17).fontColor($r('app.color.text_secondary')).lineHeight(24)
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          Text('非安全建议')
            .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
            .padding({ left: 10, right: 10, top: 8, bottom: 8 })
            .backgroundColor($r('app.color.notice')).borderRadius(8)
            .accessibilityText('不提供食品安全判断')
        }.width('100%').alignItems(VerticalAlign.Top)

        Column({ space: 7 }) {
          Text('样例食材与日期均为固定演示内容。').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_notice')).lineHeight(24)
          Text('不代表你的真实库存，也不提供食品安全判断。').fontSize(14).fontColor($r('app.color.text_notice')).lineHeight(22)
        }.padding(17).backgroundColor($r('app.color.notice')).borderRadius(20).width('100%')

        Column({ space: 10 }) {
          Text('优先处理').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          ForEach(FOODS, (item: Food) => {
            Button(this.picked === item.name ? `${item.name} · 演示剩余 ${item.days} 天 · 已选择` : `${item.name} · 演示剩余 ${item.days} 天`)
              .width('100%').constraintSize({ minHeight: 48 }).padding(16).borderRadius(15)
              .backgroundColor(this.picked === item.name ? $r('app.color.active') : $r('app.color.card'))
              .fontColor($r('app.color.text_primary'))
              .border({ width: this.picked === item.name ? 0 : 1, color: $r('app.color.border_subtle') })
              .accessibilityText(this.picked === item.name ? `已选择${item.name}` : `选择${item.name}`)
              .onClick(() => this.picked = item.name)
          }, (item: Food) => item.name)
        }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')

        if (this.picked !== '') {
          Column({ space: 8 }) {
            Text('今日本地提示').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_success'))
            Text(`可优先考虑使用“${this.picked}”。这是演示排序，不是菜谱或安全建议。`).fontSize(16).lineHeight(24).fontColor($r('app.color.text_primary'))
            Button('清除选择').fontColor($r('app.color.action')).backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 }).onClick(() => this.picked = '')
          }.padding(20).backgroundColor($r('app.color.active')).borderRadius(20).width('100%')
        }
      }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%').constraintSize({ maxWidth: 640 })
    }.width('100%').height('100%').backgroundColor($r('app.color.canvas'))
  }
}
