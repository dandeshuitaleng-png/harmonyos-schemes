import { HelpRequest } from '../models/HelpRequestModels';
import { StatusTag } from './StatusTag';

@Component
export struct RequestCard {
  request: HelpRequest = {
    id: '',
    alias: '',
    category: '',
    description: '',
    status: 'draft',
    createdAt: '',
    urgency: '普通'
  };

  build() {
    Column({ space: 10 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.request.alias)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${this.request.category} · ${this.request.createdAt}`)
            .fontSize(15)
            .fontColor('#4B5563')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)

        StatusTag({ status: this.request.status })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text(this.request.description)
        .fontSize(17)
        .fontColor('#374151')
        .lineHeight(24)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (this.request.dueAt) {
        Text(`下一步：${this.request.dueAt}`)
          .fontSize(16)
          .fontColor('#B45309')
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: '#D1D5DB' })
  }
}
