@Component
export struct PrivacyNotice {
  build() {
    Column({ space: 6 }) {
      Text('本地可信记录')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#111827')
      Text('这是社区服务跟进记录，不是官方承诺或资格判断。紧急情况请联系主管部门或紧急服务。')
        .fontSize(15)
        .fontColor('#4B5563')
        .lineHeight(22)
    }
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: '#D1D5DB' })
  }
}
