import { common, Want } from '@kit.AbilityKit';
import {
  DrillKind,
  DrillRecord,
  DrillRecordStore,
  PRIVACY_ACCEPTED,
  PRIVACY_DECLINED,
  drillKindLabel
} from '../data/DrillRecordStore';

@Entry
@Component
struct Index {
  private readonly recordStore: DrillRecordStore = new DrillRecordStore();
  @State private records: DrillRecord[] = [];
  @State private latestMessage: string = '尚未创建本次演练记录。';
  @State private isLoading: boolean = true;
  @State private storageError: string = '';
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;
  @State private selectedKind: DrillKind = 'sos';
  @State private previewRecordId: number = 0;

  aboutToAppear(): void {
    this.bootstrap();
  }

  onBackPress(): boolean {
    if (this.showPolicy && this.privacyChoice.length > 0) {
      this.showPolicy = false;
      return true;
    }
    return false;
  }

  private hostContext(): Context {
    return getContext(this);
  }

  private formatDateTime(): string {
    const now: Date = new Date();
    const year: string = now.getFullYear().toString();
    const month: string = (now.getMonth() + 1).toString().padStart(2, '0');
    const day: string = now.getDate().toString().padStart(2, '0');
    const hour: string = now.getHours().toString().padStart(2, '0');
    const minute: string = now.getMinutes().toString().padStart(2, '0');
    return `${year}-${month}-${day} ${hour}:${minute}`;
  }

  private async bootstrap(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      this.privacyChoice = await this.recordStore.loadPrivacyChoice(this.hostContext());
      this.privacyReady = true;
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        await this.loadRecords();
        return;
      }
      this.records = [];
      this.latestMessage = this.privacyChoice === PRIVACY_DECLINED
        ? '未保存本机演练记录。紧急情况请使用系统电话。'
        : '请先阅读隐私说明。';
    } catch {
      this.privacyReady = true;
      this.storageError = '无法读取本机隐私选择。请重试；不会影响任何外部服务。';
      this.latestMessage = '本机状态尚未加载。';
    } finally {
      this.isLoading = false;
    }
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      this.records = await this.recordStore.load(this.hostContext());
      this.latestMessage = this.records.length === 0
        ? '尚未创建本地演练记录。'
        : `已从本机恢复 ${this.records.length} 条演练记录；未向外发送数据。`;
    } catch {
      this.storageError = '无法读取本机演练记录。请重试；不会影响任何外部服务。';
      this.latestMessage = '本机记录尚未加载。';
    } finally {
      this.isLoading = false;
    }
  }

  private async acceptPrivacy(): Promise<void> {
    try {
      await this.recordStore.savePrivacyChoice(this.hostContext(), PRIVACY_ACCEPTED);
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.storageError = '';
      await this.loadRecords();
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传任何内容。';
    }
  }

  private async declinePrivacy(): Promise<void> {
    try {
      await this.recordStore.savePrivacyChoice(this.hostContext(), PRIVACY_DECLINED);
      this.privacyChoice = PRIVACY_DECLINED;
      this.showPolicy = false;
      this.records = [];
      this.storageError = '';
      this.latestMessage = '未保存本机演练记录。紧急情况请使用系统电话。';
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传任何内容。';
    }
  }

  private async createDrillRecord(): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }

    const record: DrillRecord = {
      id: Date.now(),
      createdAt: this.formatDateTime(),
      kind: this.selectedKind,
      label: `${drillKindLabel(this.selectedKind)}本地演练记录`,
      locationPrecision: '未添加位置',
      source: '本机演练',
      reviewStatus: '未提交'
    };
    const updatedRecords: DrillRecord[] = [record, ...this.records];
    try {
      await this.recordStore.save(this.hostContext(), updatedRecords);
      this.records = updatedRecords;
      this.storageError = '';
      this.latestMessage = `已于 ${record.createdAt} 保存${drillKindLabel(record.kind)}记录；未发送给任何联系人或服务。`;
    } catch {
      this.storageError = '无法保存本机演练记录。请重试；记录没有上传。';
      this.latestMessage = '创建未保存。';
    }
  }

  private async clearRecords(): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    try {
      await this.recordStore.clear(this.hostContext());
      this.records = [];
      this.storageError = '';
      this.latestMessage = '已清除本机演练记录；没有向外发送任何数据。';
    } catch {
      this.storageError = '无法清除本机演练记录。请重试；没有上传任何内容。';
    }
  }

  private async openSystemDialer(): Promise<void> {
    try {
      const context = this.hostContext() as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.dial',
        uri: 'tel:'
      };
      await context.startAbility(want);
    } catch {
      this.storageError = '无法打开系统电话。请退出本应用，使用系统电话应用拨打 110/119/120。';
    }
  }

  @Builder
  private policyView() {
    Column({ space: 16 }) {
      Text('隐私说明')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('北斗邻援 · com.harmonyradar.neighboraid')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
      Column({ space: 8 }) {
        Text('本应用当前版本只提供离线 SOS 演练记录，不是官方报警，也不替代 110/119/120。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_warning'))
        Text('不申请定位、联系人、短信、相机或麦克风权限，也不接入网络、账号、推送、支付或第三方 SDK。')
          .fontSize(14)
          .fontColor($r('app.color.text_warning'))
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_warning'))
      .borderRadius(16)
      .width('100%')
      Column({ space: 8 }) {
        Text('若你选择同意并继续，本机可能保存：事件的本地标识、创建时间、固定类型、来源、未提交状态，以及你对隐私说明的选择。')
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text('不保存精确坐标、联系人、音频、身份证件或报警内容。你可以随时清除全部本机演练记录。')
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text('开发者主体名称以华为应用市场登记信息为准。公开隐私政策网址尚未提供，因此本页是当前唯一完整说明。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(20)
      .width('100%')
      Button('同意并继续')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary'))
        .fontColor($r('app.color.text_on_primary'))
        .borderRadius(14)
        .accessibilityText('同意隐私说明并继续使用本机演练记录')
        .onClick(() => this.acceptPrivacy())
      Button('仅使用系统电话，不保存记录')
        .fontSize(16)
        .fontColor($r('app.color.action_primary'))
        .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
        .accessibilityText('拒绝保存本机记录，仅保留系统电话入口')
        .onClick(() => this.declinePrivacy())
      if (this.privacyChoice.length > 0) {
        Button('返回')
          .fontSize(16)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.showPolicy = false)
      }
      if (this.storageError.length > 0) {
        Text(this.storageError)
          .fontSize(14)
          .fontColor($r('app.color.text_warning'))
          .padding(14)
          .backgroundColor($r('app.color.surface_warning'))
          .borderRadius(14)
          .width('100%')
      }
    }
    .padding({ left: 20, right: 20, top: 28, bottom: 36 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .constraintSize({ maxWidth: 640 })
  }

  @Builder
  private mainView() {
    Column({ space: 16 }) {
      Text('北斗邻援')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('离线优先的应急互助演练')
        .fontSize(18)
        .fontColor($r('app.color.text_secondary'))

      Column({ space: 8 }) {
        Text('紧急情况请直接使用系统电话求助')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_warning'))
        Text('本页只用于演练记录，不会报警、通知联系人或上传数据。')
          .fontSize(14)
          .fontColor($r('app.color.text_warning'))
        Button('打开系统电话')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .backgroundColor($r('app.color.action_primary'))
          .fontColor($r('app.color.text_on_primary'))
          .borderRadius(14)
          .accessibilityText('打开系统电话拨号界面，不由本应用拨出号码')
          .onClick(() => this.openSystemDialer())
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_warning'))
      .borderRadius(16)
      .width('100%')

      Column({ space: 10 }) {
        Text('当前演练')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('离线状态：没有网络请求，也不会上传。')
          .fontSize(15)
          .fontColor($r('app.color.text_secondary'))
        Text(this.isLoading ? '正在读取本机状态…' : this.latestMessage)
          .fontSize(14)
          .fontColor(this.storageError.length > 0
            ? $r('app.color.text_warning')
            : (this.records.length === 0 ? $r('app.color.text_muted') : $r('app.color.text_success')))
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_status'))
      .borderRadius(20)
      .width('100%')

      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Column({ space: 10 }) {
          Text('选择本次本地事件类型')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Row({ space: 8 }) {
            Button(this.selectedKind === 'sos' ? 'SOS 演练 · 已选择' : 'SOS 演练')
              .fontSize(14)
              .layoutWeight(1)
              .constraintSize({ minHeight: 46 })
              .backgroundColor(this.selectedKind === 'sos' ? $r('app.color.action_primary') : $r('app.color.surface_status'))
              .fontColor(this.selectedKind === 'sos' ? $r('app.color.text_on_primary') : $r('app.color.text_primary'))
              .borderRadius(12)
              .accessibilityText('选择 SOS 演练事件类型')
              .onClick(() => this.selectedKind = 'sos')
            Button(this.selectedKind === 'shelter' ? '避险点 · 已选择' : '避险点')
              .fontSize(14)
              .layoutWeight(1)
              .constraintSize({ minHeight: 46 })
              .backgroundColor(this.selectedKind === 'shelter' ? $r('app.color.action_primary') : $r('app.color.surface_status'))
              .fontColor(this.selectedKind === 'shelter' ? $r('app.color.text_on_primary') : $r('app.color.text_primary'))
              .borderRadius(12)
              .accessibilityText('选择避险点事件类型')
              .onClick(() => this.selectedKind = 'shelter')
          }
          .width('100%')
          Row({ space: 8 }) {
            Button(this.selectedKind === 'roadblock' ? '道路障碍 · 已选择' : '道路障碍')
              .fontSize(14)
              .layoutWeight(1)
              .constraintSize({ minHeight: 46 })
              .backgroundColor(this.selectedKind === 'roadblock' ? $r('app.color.action_primary') : $r('app.color.surface_status'))
              .fontColor(this.selectedKind === 'roadblock' ? $r('app.color.text_on_primary') : $r('app.color.text_primary'))
              .borderRadius(12)
              .accessibilityText('选择道路障碍事件类型')
              .onClick(() => this.selectedKind = 'roadblock')
            Button(this.selectedKind === 'supplies' ? '物资点 · 已选择' : '物资点')
              .fontSize(14)
              .layoutWeight(1)
              .constraintSize({ minHeight: 46 })
              .backgroundColor(this.selectedKind === 'supplies' ? $r('app.color.action_primary') : $r('app.color.surface_status'))
              .fontColor(this.selectedKind === 'supplies' ? $r('app.color.text_on_primary') : $r('app.color.text_primary'))
              .borderRadius(12)
              .accessibilityText('选择物资点事件类型')
              .onClick(() => this.selectedKind = 'supplies')
          }
          .width('100%')
        }
        .padding(16)
        .backgroundColor($r('app.color.surface_card'))
        .borderRadius(16)
        .width('100%')
        Button(`创建${drillKindLabel(this.selectedKind)}本地记录`)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 52 })
          .backgroundColor($r('app.color.action_primary'))
          .fontColor($r('app.color.text_on_primary'))
          .borderRadius(14)
          .enabled(!this.isLoading)
          .accessibilityText(`创建一条仅保存在本机的${drillKindLabel(this.selectedKind)}记录`)
          .onClick(() => this.createDrillRecord())
      } else {
        Text('你选择不保存本机记录。如需演练存档，请先阅读并同意隐私说明。')
          .fontSize(15)
          .fontColor($r('app.color.text_secondary'))
        Button('阅读隐私说明并允许保存')
          .fontSize(16)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.showPolicy = true)
      }

      if (this.storageError.length > 0) {
        Column({ space: 8 }) {
          Text(this.storageError)
            .fontSize(14)
            .fontColor($r('app.color.text_warning'))
          Button('重试读取本机状态')
            .fontSize(15)
            .fontColor($r('app.color.action_primary'))
            .backgroundColor(Color.Transparent)
            .onClick(() => this.bootstrap())
        }
        .padding(16)
        .backgroundColor($r('app.color.surface_warning'))
        .borderRadius(16)
        .width('100%')
      }

      Column({ space: 10 }) {
        Text('本次演练记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        if (this.privacyChoice !== PRIVACY_ACCEPTED) {
          Text('当前未开启本机保存，因此不读取或显示演练记录。')
            .fontSize(15)
            .fontColor($r('app.color.text_muted'))
        } else if (this.isLoading) {
          Text('正在读取本机记录，请稍候。')
            .fontSize(15)
            .fontColor($r('app.color.text_muted'))
        } else if (this.records.length === 0) {
          Text('尚无记录。创建后会保存在本机；本切片不上传任何数据。')
            .fontSize(15)
            .fontColor($r('app.color.text_muted'))
        } else {
          ForEach(this.records, (record: DrillRecord) => {
            Column({ space: 8 }) {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(record.label)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                  Text(`${record.createdAt} · ${record.source} · ${record.locationPrecision} · ${record.reviewStatus}`)
                    .fontSize(13)
                    .fontColor($r('app.color.text_secondary'))
                }
                .layoutWeight(1)
                Text('仅本机')
                  .fontSize(13)
                  .fontColor($r('app.color.text_success'))
              }
              .justifyContent(FlexAlign.SpaceBetween)
              Button(this.previewRecordId === record.id ? '收起字段预览' : '查看字段预览')
                .fontSize(15)
                .fontColor($r('app.color.action_primary'))
                .backgroundColor(Color.Transparent)
                .accessibilityText(`查看${record.createdAt}创建的本机记录字段预览`)
                .onClick(() => this.previewRecordId = this.previewRecordId === record.id ? 0 : record.id)
              if (this.previewRecordId === record.id) {
                Column({ space: 4 }) {
                  Text('本机字段预览 · 未生成导出文件')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                  Text(`类型：${drillKindLabel(record.kind)}\n时间：${record.createdAt}\n位置精度：${record.locationPrecision}\n来源：${record.source}\n审核状态：${record.reviewStatus}`)
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                  Text('导出与人工确认上传尚未实现；本预览没有向外发送任何数据。')
                    .fontSize(13)
                    .fontColor($r('app.color.text_warning'))
                }
                .padding(12)
                .backgroundColor($r('app.color.surface_status'))
                .borderRadius(12)
                .width('100%')
              }
            }
            .padding(14)
            .backgroundColor($r('app.color.surface_success'))
            .borderRadius(14)
            .width('100%')
          }, (record: DrillRecord) => record.id.toString())
          Button('清除全部本机演练记录')
            .fontSize(15)
            .fontColor($r('app.color.action_primary'))
            .backgroundColor(Color.Transparent)
            .accessibilityText('清除全部保存在本机的演练记录')
            .onClick(() => this.clearRecords())
        }
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(20)
      .width('100%')

      Column({ space: 8 }) {
        Text('能力边界')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Text('本切片仅保存事件类型、时间、来源与未提交状态；未请求定位、联系人或短信权限。地图、近场通信和确认上传仍待单独实现与验证。')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Button('查看隐私说明')
          .fontSize(15)
          .fontColor($r('app.color.action_primary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => this.showPolicy = true)
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(16)
      .width('100%')
    }
    .padding({ left: 20, right: 20, top: 28, bottom: 36 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .constraintSize({ maxWidth: 640 })
  }

  build() {
    Scroll() {
      Column() {
        if (!this.privacyReady) {
          Text('正在读取本机状态…')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .padding(28)
        } else if (this.privacyChoice.length === 0 || this.showPolicy) {
          this.policyView()
        } else {
          this.mainView()
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface_canvas'))
    .align(Alignment.Top)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .scrollBar(BarState.Auto)
  }
}
