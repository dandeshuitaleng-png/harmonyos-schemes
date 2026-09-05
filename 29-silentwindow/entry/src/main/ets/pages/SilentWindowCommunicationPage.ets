import { PhraseTemplate } from '../models/SilentWindowModels'
import { SilentWindowMockRepository } from '../repositories/SilentWindowMockRepository'

@Component
export struct SilentWindowCommunicationPage {
  scenarioId: string = 'general'
  onBack: () => void = () => {}
  @State phrases: PhraseTemplate[] = []
  @State currentIndex: number = 0
  @State isConfirmed: boolean = false
  @State fontLevel: number = 0
  @State highContrast: boolean = false
  private repository: SilentWindowMockRepository = new SilentWindowMockRepository()

  aboutToAppear(): void {
    this.phrases = this.repository.getPhrases(this.scenarioId)
    this.currentIndex = 0
    this.isConfirmed = false
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Button('‹')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryColor())
          .width(56)
          .height(56)
          .borderRadius(8)
          .backgroundColor(this.surfaceColor())
          .border({ width: 1, color: this.edgeColor() })
          .onClick(() => this.onBack())

        Column({ space: 2 }) {
          Text(this.repository.getScenarioTitle(this.scenarioId))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textColor())
            .maxLines(1)
            .width('100%')
          Text(this.currentPhrase().speaker === 'staff' ? '窗口人员回复' : '我的表达')
            .fontSize(16)
            .fontColor(this.secondaryColor())
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button('字')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.primaryColor())
          .width(56)
          .height(56)
          .borderRadius(8)
          .backgroundColor(this.surfaceColor())
          .border({ width: 1, color: this.edgeColor() })
          .onClick(() => {
            this.fontLevel = (this.fontLevel + 1) % 3
          })

        Button('对比')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.highContrast ? '#FFFFFF' : this.primaryColor())
          .width(72)
          .height(56)
          .borderRadius(8)
          .backgroundColor(this.highContrast ? '#111827' : this.surfaceColor())
          .border({ width: 1, color: this.edgeColor() })
          .onClick(() => {
            this.highContrast = !this.highContrast
          })
      }
      .width('100%')
      .height(76)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 20, right: 20, top: 12, bottom: 8 })

      Column({ space: 20 }) {
        Text(this.currentPhrase().text)
          .fontSize(this.phraseFontSize())
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textColor())
          .textAlign(TextAlign.Center)
          .lineHeight(this.phraseLineHeight())
          .width('100%')

        Text(this.isConfirmed ? '对方已确认' : '待出示')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isConfirmed ? '#166534' : '#B45309')
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .borderRadius(8)
          .backgroundColor(this.isConfirmed ? '#DCFCE7' : '#FEF3C7')
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding(20)
      .backgroundColor(this.surfaceColor())
      .border({ width: 1, color: this.edgeColor() })

      Column({ space: 12 }) {
        Button('给对方看')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .height(64)
          .width('100%')
          .borderRadius(8)
          .backgroundColor(this.primaryColor())
          .onClick(() => {
            this.isConfirmed = false
          })

        Row({ space: 12 }) {
          Button('对方已确认')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#166534')
            .height(60)
            .layoutWeight(1)
            .borderRadius(8)
            .backgroundColor('#DCFCE7')
            .onClick(() => {
              this.isConfirmed = true
            })

          Button('换一句')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.primaryColor())
            .height(60)
            .layoutWeight(1)
            .borderRadius(8)
            .backgroundColor(this.surfaceColor())
            .border({ width: 1, color: this.edgeColor() })
            .onClick(() => this.nextPhrase())
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBackgroundColor())
  }

  private currentPhrase(): PhraseTemplate {
    if (this.phrases.length === 0) {
      const fallback = new PhraseTemplate()
      fallback.text = '请告诉我下一步要做什么。'
      fallback.scenario = 'general'
      fallback.speaker = 'user'
      return fallback
    }
    return this.phrases[this.currentIndex]
  }

  private nextPhrase(): void {
    if (this.phrases.length === 0) {
      return
    }
    this.currentIndex = (this.currentIndex + 1) % this.phrases.length
    this.isConfirmed = false
  }

  private phraseFontSize(): number {
    if (this.fontLevel === 2) {
      return 42
    }
    if (this.fontLevel === 1) {
      return 38
    }
    return 34
  }

  private phraseLineHeight(): number {
    return this.phraseFontSize() + 10
  }

  private pageBackgroundColor(): string {
    return this.highContrast ? '#000000' : '#F7F8FA'
  }

  private surfaceColor(): string {
    return '#FFFFFF'
  }

  private textColor(): string {
    return this.highContrast ? '#000000' : '#111827'
  }

  private secondaryColor(): string {
    return this.highContrast ? '#111827' : '#4B5563'
  }

  private primaryColor(): string {
    return this.highContrast ? '#000000' : '#005E5A'
  }

  private edgeColor(): string {
    return this.highContrast ? '#000000' : '#D1D5DB'
  }
}
