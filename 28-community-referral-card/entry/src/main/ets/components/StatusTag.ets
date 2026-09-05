import { RequestStatus, statusLabel } from '../models/HelpRequestModels';

@Component
export struct StatusTag {
  status: RequestStatus = 'draft';

  private getBackground(): string {
    if (this.status === 'followed') {
      return '#FEF3C7';
    }
    if (this.status === 'closed') {
      return '#E5E7EB';
    }
    if (this.status === 'draft') {
      return '#F3F4F6';
    }
    return '#E6F4F1';
  }

  private getTextColor(): string {
    if (this.status === 'followed') {
      return '#92400E';
    }
    if (this.status === 'closed') {
      return '#374151';
    }
    if (this.status === 'draft') {
      return '#4B5563';
    }
    return '#005E5A';
  }

  build() {
    Text(statusLabel(this.status))
      .fontSize(15)
      .fontColor(this.getTextColor())
      .fontWeight(FontWeight.Medium)
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .backgroundColor(this.getBackground())
      .borderRadius(8)
  }
}
