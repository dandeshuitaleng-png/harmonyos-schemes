import { EmptyState } from '../components/EmptyState';
import { HelpRequestForm } from '../components/HelpRequestForm';
import { PrivacyNotice } from '../components/PrivacyNotice';
import { RequestCard } from '../components/RequestCard';
import { HelpRequest } from '../models/HelpRequestModels';
import { HelpRequestMockRepository } from '../repositories/HelpRequestMockRepository';

@Entry
@Component
struct Index {
  @State requests: HelpRequest[] = HelpRequestMockRepository.list();
  @State showForm: boolean = false;

  private todayFollowCount(): number {
    return this.requests.filter((item: HelpRequest) => item.status === 'followed' && item.dueAt && item.dueAt.indexOf('今日') >= 0).length;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Column({ space: 8 }) {
          Text('社区转介跟进卡')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .width('100%')
          Text('把一次求助记录成可跟进的本地台账')
            .fontSize(17)
            .fontColor('#4B5563')
            .width('100%')
        }
        .width('100%')

        Row() {
          Column({ space: 6 }) {
            Text('今日待回访')
              .fontSize(17)
              .fontColor('#4B5563')
            Text(`${this.todayFollowCount()} 条`)
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827')
          }
          .layoutWeight(1)

          Button('快速登记')
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
            .height(56)
            .backgroundColor('#005E5A')
            .borderRadius(8)
            .onClick(() => {
              this.showForm = true;
            })
            .accessibilityText('快速登记求助')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 1, color: '#D1D5DB' })
        .alignItems(VerticalAlign.Center)

        PrivacyNotice()

        if (this.showForm) {
          HelpRequestForm({ requests: $requests, showForm: $showForm })
        }

        Row() {
          Text('最近求助卡')
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
            .layoutWeight(1)
          Text(`${this.requests.length} 条`)
            .fontSize(16)
            .fontColor('#4B5563')
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        if (this.requests.length === 0) {
          EmptyState()
        } else {
          ForEach(this.requests, (item: HelpRequest) => {
            RequestCard({ request: item })
          }, (item: HelpRequest) => item.id)
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }
}
