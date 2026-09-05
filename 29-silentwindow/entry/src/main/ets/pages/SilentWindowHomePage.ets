import { CommunicationSession, SilentWindowScenario } from '../models/SilentWindowModels'
import { SilentWindowMockRepository } from '../repositories/SilentWindowMockRepository'

@Component
export struct SilentWindowHomePage {
  onStart: (scenarioId: string) => void = () => {}
  @State scenarios: SilentWindowScenario[] = []
  @State recentSessions: CommunicationSession[] = []
  @State selectedScenarioId: string = 'hospital'
  private repository: SilentWindowMockRepository = new SilentWindowMockRepository()

  aboutToAppear(): void {
    this.scenarios = this.repository.getScenarios()
    this.recentSessions = this.repository.getRecentSessions()
  }

  build() {
    Column() {
      Column({ space: 8 }) {
        Text('无声窗口')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')
        Text('选择窗口场景，把关键信息用大字给对方看。')
          .fontSize(16)
          .fontColor('#4B5563')
          .lineHeight(22)
          .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 20, right: 20, top: 28, bottom: 20 })

      Grid() {
        ForEach(this.scenarios, (item: SilentWindowScenario) => {
          GridItem() {
            this.scenarioCard(item)
          }
        }, (item: SilentWindowScenario) => item.id)
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .padding({ left: 20, right: 20 })

      Button('开始沟通')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .height(64)
        .width('100%')
        .borderRadius(8)
        .backgroundColor('#005E5A')
        .margin({ left: 20, right: 20, top: 20 })
        .onClick(() => this.onStart(this.selectedScenarioId))

      Column({ space: 12 }) {
        Text('最近记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')
        ForEach(this.recentSessions, (item: CommunicationSession) => {
          this.recentRow(item)
        }, (item: CommunicationSession) => item.id)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 20, right: 20, top: 28 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  @Builder
  scenarioCard(item: SilentWindowScenario) {
    Column({ space: 8 }) {
      Text(item.title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedScenarioId === item.id ? '#FFFFFF' : '#111827')
        .width('100%')
      Text(item.description)
        .fontSize(16)
        .fontColor(this.selectedScenarioId === item.id ? '#E5F7F5' : '#4B5563')
        .lineHeight(22)
        .maxLines(2)
        .width('100%')
    }
    .height(118)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .padding(20)
    .borderRadius(8)
    .backgroundColor(this.selectedScenarioId === item.id ? '#005E5A' : '#FFFFFF')
    .border({ width: 1, color: this.selectedScenarioId === item.id ? '#005E5A' : '#D1D5DB' })
    .onClick(() => {
      this.selectedScenarioId = item.id
    })
  }

  @Builder
  recentRow(item: CommunicationSession) {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(this.repository.getScenarioTitle(item.scenario))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
          .width('100%')
        Text(item.createdAt + ' · ' + item.nextStep)
          .fontSize(16)
          .fontColor('#4B5563')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(item.status === 'draft' ? '草稿' : '已确认')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(item.status === 'draft' ? '#B45309' : '#166534')
    }
    .width('100%')
    .height(72)
    .alignItems(VerticalAlign.Center)
    .padding(16)
    .borderRadius(8)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#D1D5DB' })
  }
}
