import { SilentWindowCommunicationPage } from './SilentWindowCommunicationPage'
import { SilentWindowHomePage } from './SilentWindowHomePage'

@Preview({
  title: '无声窗口',
  deviceType: 'phone',
  width: 390,
  height: 844
})
@Entry
@Component
struct Index {
  @State screen: string = 'home'
  @State selectedScenarioId: string = 'hospital'

  build() {
    if (this.screen === 'communication') {
      SilentWindowCommunicationPage({
        scenarioId: this.selectedScenarioId,
        onBack: () => {
          this.screen = 'home'
        }
      })
    } else {
      SilentWindowHomePage({
        onStart: (scenarioId: string) => {
          this.selectedScenarioId = scenarioId
          this.screen = 'communication'
        }
      })
    }
  }
}
