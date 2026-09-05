import { router } from '@kit.ArkUI';
import { ReliefRequest, RequestTemplate, TrustedContact } from '../models/ReliefModels';
import { ReliefMockRepository } from '../repositories/ReliefMockRepository';

const repo = new ReliefMockRepository();

@Entry
@Component
struct Index {
  @State private currentPage: string = 'home';
  @State private selectedContactId: string = repo.getTrustedContacts()[0].id;
  @State private selectedTemplateId: string = repo.getRequestTemplates()[0].id;
  @State private timeWindow: string = '今天 18:30-19:00';
  @State private note: string = '';
  private contacts: TrustedContact[] = repo.getTrustedContacts();
  private templates: RequestTemplate[] = repo.getRequestTemplates();
  private recentRequests: ReliefRequest[] = repo.getRecentRequests();

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      if (this.currentPage === 'home') {
        this.HomePage();
      } else {
        this.CreatePage();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }

  @Builder
  HomePage() {
    Column({ space: 24 }) {
      Column({ space: 8 }) {
        Text('喘息半小时')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text('向可信亲友发出边界清晰的 30 分钟替班请求。')
          .fontSize(17)
          .fontColor('#4B5563')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Button('先记录这一步')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .height(58)
        .width('100%')
        .backgroundColor('#005E5A')
        .borderRadius(8)
        .onClick(() => {
          this.currentPage = 'create';
        })
        .accessibilityText('创建 30 分钟喘息请求')

      Column({ space: 12 }) {
        Text('最近记录')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .width('100%')

        ForEach(this.recentRequests, (item: ReliefRequest) => {
          this.RecordCard(item);
        }, (item: ReliefRequest) => item.id)
      }
      .width('100%')

      Text('本 MVP 使用 Mock 联系人与请求模板；此记录只供个人整理，不是官方凭证。')
        .fontSize(15)
        .fontColor('#4B5563')
        .lineHeight(22)
        .padding(12)
        .border({ width: 1, color: '#D1D5DB' })
        .borderRadius(8)
        .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 32, bottom: 20 })
  }

  @Builder
  CreatePage() {
    Column() {
      Column({ space: 20 }) {
        Row({ space: 8 }) {
          Button('返回')
            .fontSize(17)
            .fontColor('#005E5A')
            .backgroundColor('#00000000')
            .onClick(() => {
              this.currentPage = 'home';
            })
          Text('创建喘息请求')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#111827')
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)

        Text('选一个可信联系人和模板，先形成一条可发送的 30 分钟请求。')
          .fontSize(17)
          .fontColor('#4B5563')
          .lineHeight(24)
          .width('100%')

        this.SectionTitle('可信联系人')
        ForEach(this.contacts, (contact: TrustedContact) => {
          this.SelectableRow(contact.id, `${contact.name} · ${contact.relation}`, contact.reachableTime, this.selectedContactId === contact.id, () => {
            this.selectedContactId = contact.id;
          });
        }, (contact: TrustedContact) => contact.id)

        this.SectionTitle('请求模板')
        ForEach(this.templates, (template: RequestTemplate) => {
          this.SelectableRow(template.id, template.title, template.message, this.selectedTemplateId === template.id, () => {
            this.selectedTemplateId = template.id;
          });
        }, (template: RequestTemplate) => template.id)

        this.SectionTitle('时间与备注')
        TextInput({ text: this.timeWindow, placeholder: '例如：今天 18:30-19:00' })
          .fontSize(17)
          .height(56)
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#D1D5DB' })
          .borderRadius(8)
          .onChange((value: string) => {
            this.timeWindow = value;
          })
        TextArea({ text: this.note, placeholder: '可选：只写对方必须知道的一句补充。' })
          .fontSize(17)
          .height(96)
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#D1D5DB' })
          .borderRadius(8)
          .onChange((value: string) => {
            this.note = value;
          })
      }
      .width('100%')
      .layoutWeight(1)

      Button('保存为本地草稿')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .height(58)
        .width('100%')
        .backgroundColor('#005E5A')
        .borderRadius(8)
        .onClick(() => {
          this.currentPage = 'home';
        })
        .accessibilityText('保存当前喘息请求为本地草稿')
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 28, bottom: 20 })
  }

  @Builder
  RecordCard(item: ReliefRequest) {
    Column({ space: 8 }) {
      Row() {
        Text(item.title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .layoutWeight(1)
        Text(this.statusLabel(item.status))
          .fontSize(15)
          .fontColor(this.statusColor(item.status))
      }
      .width('100%')

      Text(`${item.timeWindow} · ${item.contactName}`)
        .fontSize(15)
        .fontColor('#4B5563')
        .width('100%')
      Text(item.task)
        .fontSize(15)
        .fontColor('#4B5563')
        .width('100%')
    }
    .padding(12)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#D1D5DB' })
    .borderRadius(8)
    .width('100%')
  }

  @Builder
  SectionTitle(title: string) {
    Text(title)
      .fontSize(20)
      .fontWeight(FontWeight.Medium)
      .fontColor('#111827')
      .width('100%')
      .margin({ top: 4 })
  }

  @Builder
  SelectableRow(id: string, title: string, subtitle: string, selected: boolean, action: () => void) {
    Column({ space: 6 }) {
      Row() {
        Text(title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor('#111827')
          .layoutWeight(1)
        Text(selected ? '已选' : '选择')
          .fontSize(15)
          .fontColor(selected ? '#166534' : '#005E5A')
      }
      .width('100%')
      Text(subtitle)
        .fontSize(15)
        .fontColor('#4B5563')
        .lineHeight(21)
        .width('100%')
    }
    .padding(12)
    .backgroundColor('#FFFFFF')
    .border({ width: selected ? 2 : 1, color: selected ? '#005E5A' : '#D1D5DB' })
    .borderRadius(8)
    .width('100%')
    .onClick(action)
    .accessibilityText(`选择 ${title}`)
  }

  private statusLabel(status: string): string {
    if (status === 'pending') {
      return '待处理';
    }
    if (status === 'done') {
      return '已完成';
    }
    if (status === 'deferred') {
      return '已延期';
    }
    return '草稿';
  }

  private statusColor(status: string): string {
    if (status === 'done') {
      return '#166534';
    }
    if (status === 'deferred') {
      return '#B45309';
    }
    return '#005E5A';
  }
}
