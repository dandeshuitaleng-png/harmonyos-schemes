import { BarrierItem, BarrierSeverity, PlaceCheck, ReviewStatus } from '../models/AccessibilityModels';
import { AccessibilityMockRepository } from '../repositories/AccessibilityMockRepository';

const BACKGROUND_COLOR: string = '#F7F8FA';
const SURFACE_COLOR: string = '#FFFFFF';
const PRIMARY_TEXT_COLOR: string = '#111827';
const SECONDARY_TEXT_COLOR: string = '#4B5563';
const PRIMARY_ACTION_COLOR: string = '#005E5A';
const WARNING_COLOR: string = '#B45309';
const BORDER_COLOR: string = '#D1D5DB';
const SUCCESS_COLOR: string = '#166534';

@Component
export struct PlaceChecklistPage {
  private repository: AccessibilityMockRepository = new AccessibilityMockRepository();
  @State private placeChecks: PlaceCheck[] = this.repository.getPlaceChecks();
  @State private selectedPlaceId: string = 'place-001';

  private getSelectedPlace(): PlaceCheck {
    const matches: PlaceCheck[] = this.placeChecks.filter((place: PlaceCheck) => place.id === this.selectedPlaceId);
    return matches.length > 0 ? matches[0] : this.placeChecks[0];
  }

  private getStatusLabel(status: ReviewStatus): string {
    switch (status) {
      case ReviewStatus.DRAFT:
        return '草稿';
      case ReviewStatus.PENDING:
        return '待处理';
      case ReviewStatus.DONE:
        return '已完成';
      case ReviewStatus.DEFERRED:
        return '已延期';
      case ReviewStatus.SAVED:
        return '已保存';
      default:
        return '已删除';
    }
  }

  private getStatusColor(status: ReviewStatus): string {
    if (status === ReviewStatus.DONE) {
      return SUCCESS_COLOR;
    }
    if (status === ReviewStatus.DEFERRED || status === ReviewStatus.DRAFT) {
      return WARNING_COLOR;
    }
    return PRIMARY_ACTION_COLOR;
  }

  private getSeverityLabel(severity: BarrierSeverity): string {
    switch (severity) {
      case BarrierSeverity.HIGH:
        return '重点';
      case BarrierSeverity.MEDIUM:
        return '一般';
      default:
        return '提示';
    }
  }

  build() {
    Column() {
      Row() {
        Column() {
          Text('无障碍窗口检查表')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_TEXT_COLOR)
          Text('记录医院、银行、政务窗口的具体阻断点。')
            .fontSize(17)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 12 })

      Text('此记录只供你个人整理，不是官方凭证。你可以随时删除本地记录。')
        .fontSize(15)
        .fontColor(SECONDARY_TEXT_COLOR)
        .backgroundColor(SURFACE_COLOR)
        .border({ width: 1, color: BORDER_COLOR, radius: 8 })
        .padding(12)
        .margin({ left: 20, right: 20, bottom: 12 })

      List({ space: 12 }) {
        ListItem() {
          Text('地点列表')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(PRIMARY_TEXT_COLOR)
            .padding({ left: 20, right: 20, top: 4 })
        }

        ForEach(this.placeChecks, (place: PlaceCheck) => {
          ListItem() {
            this.PlaceCard(place)
          }
        }, (place: PlaceCheck) => place.id)

        ListItem() {
          this.ChecklistPanel(this.getSelectedPlace())
        }
      }
      .layoutWeight(1)
      .padding({ left: 20, right: 20, bottom: 20 })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BACKGROUND_COLOR)
  }

  @Builder
  private PlaceCard(place: PlaceCheck) {
    Column() {
      Row() {
        Column() {
          Text(place.placeName)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(PRIMARY_TEXT_COLOR)
          Text(place.serviceWindow + ' · ' + place.address)
            .fontSize(15)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 4 })
          Text(place.lastCheckedAt)
            .fontSize(15)
            .fontColor(SECONDARY_TEXT_COLOR)
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text(this.getStatusLabel(place.status))
          .fontSize(15)
          .fontColor(this.getStatusColor(place.status))
          .padding({ left: 10, right: 10, top: 6, bottom: 6 })
          .border({ width: 1, color: this.getStatusColor(place.status), radius: 8 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(SURFACE_COLOR)
    .border({
      width: this.selectedPlaceId === place.id ? 2 : 1,
      color: this.selectedPlaceId === place.id ? PRIMARY_ACTION_COLOR : BORDER_COLOR,
      radius: 8
    })
    .onClick(() => {
      this.selectedPlaceId = place.id;
    })
  }

  @Builder
  private ChecklistPanel(place: PlaceCheck) {
    Column() {
      Text('检查表')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .width('100%')
      Text(place.placeName + ' / ' + place.template.name)
        .fontSize(17)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ top: 8 })
        .width('100%')

      Column() {
        ForEach(place.template.items, (item: BarrierItem) => {
          this.CheckItemRow(item)
        }, (item: BarrierItem) => item.id)
      }
      .margin({ top: 16 })
      .width('100%')

      Text('下一步')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .margin({ top: 20 })
        .width('100%')
      Text(place.nextStep)
        .fontSize(17)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ top: 8 })
        .width('100%')

      Text('备注')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(PRIMARY_TEXT_COLOR)
        .margin({ top: 20 })
        .width('100%')
      Text(place.note)
        .fontSize(17)
        .fontColor(SECONDARY_TEXT_COLOR)
        .margin({ top: 8 })
        .width('100%')

      Button('先记录这一步')
        .fontSize(20)
        .fontColor(Color.White)
        .backgroundColor(PRIMARY_ACTION_COLOR)
        .height(56)
        .width('100%')
        .borderRadius(8)
        .margin({ top: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor(SURFACE_COLOR)
    .border({ width: 1, color: BORDER_COLOR, radius: 8 })
  }

  @Builder
  private CheckItemRow(item: BarrierItem) {
    Row() {
      Text(item.checked ? '✓' : '□')
        .fontSize(20)
        .fontColor(item.checked ? SUCCESS_COLOR : WARNING_COLOR)
        .width(32)
      Column() {
        Row() {
          Text(item.title)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor(PRIMARY_TEXT_COLOR)
            .layoutWeight(1)
          Text(this.getSeverityLabel(item.severity))
            .fontSize(15)
            .fontColor(SECONDARY_TEXT_COLOR)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .border({ width: 1, color: BORDER_COLOR, radius: 8 })
        }
        .width('100%')
        Text(item.description)
          .fontSize(15)
          .fontColor(SECONDARY_TEXT_COLOR)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .border({ width: { bottom: 1 }, color: BORDER_COLOR })
  }
}
