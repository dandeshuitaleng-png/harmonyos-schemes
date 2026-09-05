@Component
export struct EmptyState {
  build() {
    Column() {
      Text('还没有求助记录')
        .fontSize(17)
        .fontColor('#4B5563')
    }
    .width('100%')
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: '#D1D5DB' })
  }
}
