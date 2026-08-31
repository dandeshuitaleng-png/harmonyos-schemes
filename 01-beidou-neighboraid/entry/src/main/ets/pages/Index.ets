import { common, Want } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import {
  DrillKind,
  DrillPack,
  DrillRecord,
  DrillRecordStore,
  LOCAL_DRILL_PACKS,
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
  @State private selectedDrillPackId: string = '';
  @State private previewRecordId: number = 0;
  @State private confirmClear: boolean = false;
  @State private showSharePreview: boolean = false;
  @State private sharePreviewTitle: string = '';
  @State private sharePreviewText: string = '';

  aboutToAppear(): void {
    this.bootstrap();
  }

  onBackPress(): boolean {
    if (this.showPolicy && this.privacyChoice.length > 0) {
      this.showPolicy = false;
      return true;
    }
    if (this.confirmClear) {
      this.confirmClear = false;
      return true;
    }
    if (this.showSharePreview) {
      this.showSharePreview = false;
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

  private statusColor(): ResourceColor {
    if (this.storageError.length > 0) {
      return $r('app.color.text_warning');
    }
    if (this.records.length === 0) {
      return $r('app.color.text_muted');
    }
    return $r('app.color.text_success');
  }

  private drillPackTitle(): string {
    for (let index = 0; index < LOCAL_DRILL_PACKS.length; index += 1) {
      if (LOCAL_DRILL_PACKS[index].id === this.selectedDrillPackId) {
        return LOCAL_DRILL_PACKS[index].title;
      }
    }
    return '未启用本机演练包';
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
      this.selectedDrillPackId = '';
      this.confirmClear = false;
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
      this.selectedDrillPackId = await this.recordStore.loadSelectedDrillPackId(this.hostContext());
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
      this.selectedDrillPackId = '';
      this.confirmClear = false;
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

    const createdId: number = Date.now();
    const createdAt: string = this.formatDateTime();
    const record: DrillRecord = {
      id: createdId,
      createdAt,
      kind: this.selectedKind,
      label: `${drillKindLabel(this.selectedKind)}本地演练记录`,
      sourceVersionId: `local-${createdId}`,
      receivedAt: createdAt,
      conflictGroupId: '',
      conflictStatus: '当前无冲突版本',
      drillPackId: this.selectedDrillPackId,
      drillPackTitle: this.drillPackTitle(),
      locationPrecision: '未添加位置',
      source: '本机演练',
      reviewStatus: '未提交'
    };
    const updatedRecords: DrillRecord[] = [record, ...this.records];
    try {
      await this.recordStore.save(this.hostContext(), updatedRecords);
      this.records = updatedRecords;
      this.confirmClear = false;
      this.storageError = '';
      this.latestMessage = `已于 ${record.createdAt} 保存${drillKindLabel(record.kind)}记录；未发送给任何联系人或服务。`;
    } catch {
      this.storageError = '无法保存本机演练记录。请重试；记录没有上传。';
      this.latestMessage = '创建未保存。';
    }
  }

  private async selectDrillPack(drillPack: DrillPack): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    try {
      await this.recordStore.saveSelectedDrillPackId(this.hostContext(), drillPack.id);
      this.selectedDrillPackId = drillPack.id;
      this.storageError = '';
      this.latestMessage = `已启用${drillPack.title}；内容仅保存在本机，不含地图或下载。`;
    } catch {
      this.storageError = '无法保存本机演练包选择。请重试；没有下载或上传任何内容。';
    }
  }

  private async clearRecords(): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    if (!this.confirmClear) {
      this.confirmClear = true;
      return;
    }
    try {
      await this.recordStore.clear(this.hostContext());
      this.records = [];
      this.confirmClear = false;
      this.previewRecordId = 0;
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

  private shareText(record: DrillRecord): string {
    return `北斗邻援 · 本机演练记录\n\n类型：${drillKindLabel(record.kind)}\n时间：${record.createdAt}\n演练包：${record.drillPackTitle}\n位置精度：${record.locationPrecision}\n来源：${record.source}\n接收时间：${record.receivedAt}\n冲突状态：${record.conflictStatus}\n审核状态：${record.reviewStatus}\n\n说明：这是一条仅保存在本机的演练记录，不代表已报警、已通知联系人、已上传或已获人工审核。`;
  }

  private openSharePreview(record: DrillRecord): void {
    this.sharePreviewTitle = `${drillKindLabel(record.kind)}本机演练记录`;
    this.sharePreviewText = this.shareText(record);
    this.showSharePreview = true;
  }

  private async sharePreview(): Promise<void> {
    if (this.sharePreviewText.length === 0) {
      return;
    }
    try {
      const shareData = new systemShare.SharedData({
        utd: utd.UniformDataType.TEXT,
        content: this.sharePreviewText,
        title: this.sharePreviewTitle
      });
      const controller = new systemShare.ShareController(shareData);
      const context = this.hostContext() as common.UIAbilityContext;
      await controller.show(context, {});
      this.latestMessage = '已打开系统分享面板。由你选择接收目标；本应用没有上传或代发。';
    } catch {
      this.storageError = '无法打开系统分享面板。可返回后重试；本机记录没有被修改或上传。';
    }
  }

  @Builder
  private kindChip(kind: DrillKind, title: string) {
    Button(this.selectedKind === kind ? `${title} · 已选择` : title)
      .fontSize(14)
      .fontWeight(this.selectedKind === kind ? FontWeight.Medium : FontWeight.Regular)
      .layoutWeight(1)
      .constraintSize({ minHeight: 48 })
      .backgroundColor(this.selectedKind === kind ? $r('app.color.action_primary') : $r('app.color.surface_status'))
      .fontColor(this.selectedKind === kind ? $r('app.color.text_on_primary') : $r('app.color.text_primary'))
      .border({
        width: this.selectedKind === kind ? 0 : 1,
        color: $r('app.color.border_subtle')
      })
      .borderRadius(12)
      .accessibilityText(this.selectedKind === kind ? `已选择${title}事件类型` : `选择${title}事件类型`)
      .onClick(() => {
        this.selectedKind = kind;
      })
  }

  @Builder
  private drillPackButton(drillPack: DrillPack) {
    Button(this.selectedDrillPackId === drillPack.id ? `${drillPack.title} · 已启用` : `启用${drillPack.title}`)
      .fontSize(16)
      .fontWeight(this.selectedDrillPackId === drillPack.id ? FontWeight.Medium : FontWeight.Regular)
      .width('100%')
      .constraintSize({ minHeight: 48 })
      .backgroundColor(this.selectedDrillPackId === drillPack.id ? $r('app.color.action_primary') : $r('app.color.surface_status'))
      .fontColor(this.selectedDrillPackId === drillPack.id ? $r('app.color.text_on_primary') : $r('app.color.text_primary'))
      .border({ width: this.selectedDrillPackId === drillPack.id ? 0 : 1, color: $r('app.color.border_subtle') })
      .borderRadius(12)
      .accessibilityText(this.selectedDrillPackId === drillPack.id ? `已启用${drillPack.title}` : `启用${drillPack.title}，${drillPack.description}`)
      .onClick(() => this.selectDrillPack(drillPack))
  }

  @Builder
  private fieldLine(label: string, value: string) {
    Text(`${label}：${value}`)
      .fontSize(14)
      .lineHeight(22)
      .fontColor($r('app.color.text_secondary'))
      .width('100%')
  }

  @Builder
  private textButton(label: string, access: string, onTap: () => void) {
    Button(label)
      .fontSize(16)
      .fontColor($r('app.color.action_primary'))
      .backgroundColor(Color.Transparent)
      .constraintSize({ minHeight: 48 })
      .padding({ left: 8, right: 8 })
      .accessibilityText(access)
      .onClick(onTap)
  }

  @Builder
  private policyView() {
    Column({ space: 16 }) {
      Text('隐私说明')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .lineHeight(34)
      Text('北斗邻援 · 离线演练记录')
        .fontSize(16)
        .lineHeight(24)
        .fontColor($r('app.color.text_secondary'))
      Column({ space: 8 }) {
        Text('本应用当前版本提供本机离线演练记录和内置演练提示，不是官方报警，也不替代 110/119/120。')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .lineHeight(24)
          .fontColor($r('app.color.text_warning'))
        Text('不申请定位、联系人、短信、相机或麦克风权限，也不接入网络、账号、推送、支付或第三方 SDK。')
          .fontSize(14)
          .lineHeight(22)
          .fontColor($r('app.color.text_warning'))
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_warning'))
      .borderRadius(16)
      .width('100%')
      Column({ space: 8 }) {
        Text('若你选择同意并继续，本机可能保存：事件的本地标识、创建时间、固定类型、已选演练包、来源、未提交状态，以及你对隐私说明的选择。')
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_primary'))
        Text('不保存精确坐标、联系人、音频、身份证件或报警内容。你可以随时清除全部本机演练记录。')
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_primary'))
        Text('开发者主体名称以华为应用市场登记信息为准。公开隐私政策网址尚未提供，因此本页是当前唯一完整说明。')
          .fontSize(14)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_card'))
      .borderRadius(16)
      .width('100%')
      Button('同意并继续')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .backgroundColor($r('app.color.action_primary'))
        .fontColor($r('app.color.text_on_primary'))
        .borderRadius(12)
        .accessibilityText('同意隐私说明并继续使用本机演练记录')
        .onClick(() => this.acceptPrivacy())
      this.textButton('仅使用系统电话，不保存记录', '拒绝保存本机记录，仅保留系统电话入口', () => this.declinePrivacy())
      if (this.privacyChoice.length > 0) {
        this.textButton('返回', '返回演练主页面', () => {
          this.showPolicy = false;
        })
      }
      if (this.storageError.length > 0) {
        Text(this.storageError)
          .fontSize(14)
          .lineHeight(22)
          .fontColor($r('app.color.text_warning'))
          .padding(14)
          .backgroundColor($r('app.color.surface_warning'))
          .borderRadius(12)
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
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('北斗邻援')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .lineHeight(34)
          Text('离线优先的应急互助演练，不是官方报警。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor($r('app.color.text_secondary'))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Text('演练')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .constraintSize({ minHeight: 32 })
          .backgroundColor($r('app.color.surface_status'))
          .borderRadius(8)
          .accessibilityText('当前为演练模式，不是官方报警')
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Column({ space: 8 }) {
        Text('紧急情况请直接使用系统电话求助')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .lineHeight(24)
          .fontColor($r('app.color.text_warning'))
        Text('本页只用于演练记录。打开系统电话后由你自行拨号；本应用不会报警、通知联系人或上传数据。')
          .fontSize(14)
          .lineHeight(22)
          .fontColor($r('app.color.text_warning'))
        Button('打开系统电话')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .backgroundColor($r('app.color.action_primary'))
          .fontColor($r('app.color.text_on_primary'))
          .borderRadius(12)
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
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_secondary'))
        Text(this.isLoading ? '正在读取本机状态…' : this.latestMessage)
          .fontSize(16)
          .lineHeight(24)
          .fontColor(this.statusColor())
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_status'))
      .borderRadius(16)
      .width('100%')

      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Column({ space: 10 }) {
          Text('本机演练包')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Text('以下是应用内置的演练提示，用于组织本机记录；不是已下载地图、官方预警或救援指引。')
            .fontSize(14)
            .lineHeight(22)
            .fontColor($r('app.color.text_secondary'))
          ForEach(LOCAL_DRILL_PACKS, (drillPack: DrillPack) => {
            Column({ space: 6 }) {
              Text(drillPack.description)
                .fontSize(14)
                .lineHeight(22)
                .fontColor($r('app.color.text_secondary'))
              this.drillPackButton(drillPack)
            }
            .width('100%')
          }, (drillPack: DrillPack) => drillPack.id)
        }
        .padding(16)
        .backgroundColor($r('app.color.surface_card'))
        .border({ width: 1, color: $r('app.color.border_subtle') })
        .borderRadius(16)
        .width('100%')
        Column({ space: 10 }) {
          Text('选择本次本地事件类型')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
          Row({ space: 8 }) {
            this.kindChip('sos', 'SOS 演练')
            this.kindChip('shelter', '避险点')
          }
          .width('100%')
          Row({ space: 8 }) {
            this.kindChip('roadblock', '道路障碍')
            this.kindChip('supplies', '物资点')
          }
          .width('100%')
        }
        .padding(16)
        .backgroundColor($r('app.color.surface_card'))
        .border({ width: 1, color: $r('app.color.border_subtle') })
        .borderRadius(16)
        .width('100%')
        Button(`创建${drillKindLabel(this.selectedKind)}本地记录`)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .backgroundColor($r('app.color.action_primary'))
          .fontColor($r('app.color.text_on_primary'))
          .borderRadius(12)
          .enabled(!this.isLoading)
          .accessibilityText(`创建一条仅保存在本机的${drillKindLabel(this.selectedKind)}记录`)
          .onClick(() => this.createDrillRecord())
      } else {
        Text('你选择不保存本机记录。如需演练存档，请先阅读并同意隐私说明。')
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_secondary'))
        this.textButton('阅读隐私说明并允许保存', '打开隐私说明以允许保存本机演练记录', () => {
          this.showPolicy = true;
        })
      }

      if (this.storageError.length > 0) {
        Column({ space: 8 }) {
          Text(this.storageError)
            .fontSize(14)
            .lineHeight(22)
            .fontColor($r('app.color.text_warning'))
          this.textButton('重试读取本机状态', '重新读取本机隐私选择和演练记录', () => this.bootstrap())
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
            .fontSize(16)
            .lineHeight(24)
            .fontColor($r('app.color.text_muted'))
        } else if (this.isLoading) {
          Text('正在读取本机记录，请稍候。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor($r('app.color.text_muted'))
        } else if (this.records.length === 0) {
          Text('尚无记录。创建后会保存在本机；本切片不上传任何数据。')
            .fontSize(16)
            .lineHeight(24)
            .fontColor($r('app.color.text_muted'))
        } else {
          ForEach(this.records, (record: DrillRecord) => {
            Column({ space: 8 }) {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(drillKindLabel(record.kind))
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                  Text(record.label)
                    .fontSize(14)
                    .lineHeight(22)
                    .fontColor($r('app.color.text_secondary'))
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Text('仅本机')
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_success'))
                  .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                  .backgroundColor($r('app.color.surface_success'))
                  .borderRadius(8)
                  .accessibilityText('该记录仅保存在本机，没有向外发送')
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
              this.fieldLine('时间', record.createdAt)
              this.fieldLine('演练包', record.drillPackTitle)
              this.fieldLine('来源', record.source)
              this.fieldLine('冲突状态', record.conflictStatus)
              this.fieldLine('位置精度', record.locationPrecision)
              this.fieldLine('审核状态', record.reviewStatus)
              Button(this.previewRecordId === record.id ? '收起字段预览' : '查看字段预览')
                .fontSize(16)
                .fontColor($r('app.color.action_primary'))
                .backgroundColor(Color.Transparent)
                .constraintSize({ minHeight: 48 })
                .accessibilityText(`查看${record.createdAt}创建的本机记录字段预览`)
                .onClick(() => {
                  this.previewRecordId = this.previewRecordId === record.id ? 0 : record.id;
                })
              this.textButton('预览后使用系统分享', `预览${record.createdAt}创建的本机记录并决定是否使用系统分享`, () => {
                this.openSharePreview(record);
              })
              if (this.previewRecordId === record.id) {
                Column({ space: 4 }) {
                  Text('本机字段预览 · 未生成导出文件')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                  this.fieldLine('类型', drillKindLabel(record.kind))
                  this.fieldLine('时间', record.createdAt)
                  this.fieldLine('演练包', record.drillPackTitle)
                  this.fieldLine('位置精度', record.locationPrecision)
                  this.fieldLine('来源', record.source)
                  this.fieldLine('接收时间', record.receivedAt)
                  this.fieldLine('来源版本', record.sourceVersionId)
                  this.fieldLine('冲突组', record.conflictGroupId.length > 0 ? record.conflictGroupId : '尚未归入冲突组')
                  this.fieldLine('冲突状态', record.conflictStatus)
                  this.fieldLine('审核状态', record.reviewStatus)
                  Text('导出与人工确认上传尚未实现；本预览没有向外发送任何数据。')
                    .fontSize(13)
                    .lineHeight(20)
                    .fontColor($r('app.color.text_warning'))
                }
                .padding(12)
                .backgroundColor($r('app.color.surface_status'))
                .borderRadius(12)
                .width('100%')
              }
            }
            .padding(14)
            .backgroundColor($r('app.color.surface_card'))
            .border({ width: 1, color: $r('app.color.border_subtle') })
            .borderRadius(14)
            .width('100%')
          }, (record: DrillRecord) => record.id.toString())
          if (this.confirmClear) {
            Text('清除后无法从本应用恢复这些本机记录。没有向外发送任何数据。')
              .fontSize(14)
              .lineHeight(22)
              .fontColor($r('app.color.text_danger'))
            Button('确认清除全部本机演练记录')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .width('100%')
              .constraintSize({ minHeight: 48 })
              .backgroundColor($r('app.color.surface_warning'))
              .fontColor($r('app.color.text_danger'))
              .borderRadius(12)
              .accessibilityText('确认清除全部保存在本机的演练记录，此操作不能撤销')
              .onClick(() => this.clearRecords())
            this.textButton('取消清除', '取消清除本机演练记录', () => {
              this.confirmClear = false;
            })
          } else {
            this.textButton('清除全部本机演练记录', '准备清除全部保存在本机的演练记录，下一步需要确认', () => this.clearRecords())
          }
        }
      }
      .padding(20)
      .backgroundColor($r('app.color.surface_card'))
      .border({ width: 1, color: $r('app.color.border_subtle') })
      .borderRadius(16)
      .width('100%')

      Column({ space: 8 }) {
        Text('能力边界')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Text('本切片仅保存事件类型、时间、演练包选择、来源与未提交状态；未请求定位、联系人或短信权限。内置演练包不等于离线地图；地图、近场通信和确认上传仍待单独实现与验证。')
          .fontSize(14)
          .lineHeight(22)
          .fontColor($r('app.color.text_secondary'))
        this.textButton('查看隐私说明', '打开隐私说明', () => {
          this.showPolicy = true;
        })
      }
      .padding(16)
      .backgroundColor($r('app.color.surface_card'))
      .border({ width: 1, color: $r('app.color.border_subtle') })
      .borderRadius(16)
      .width('100%')
    }
    .padding({ left: 20, right: 20, top: 28, bottom: 36 })
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .constraintSize({ maxWidth: 640 })
  }

  @Builder
  private sharePreviewView() {
    Column({ space: 16 }) {
      Text('分享前预览')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .lineHeight(34)
        .fontColor($r('app.color.text_primary'))
      Text('以下文本会交给系统分享面板。请确认内容；取消不会改变本机记录。')
        .fontSize(16)
        .lineHeight(24)
        .fontColor($r('app.color.text_secondary'))
      Text(this.sharePreviewText)
        .fontSize(16)
        .lineHeight(24)
        .fontColor($r('app.color.text_primary'))
        .padding(16)
        .backgroundColor($r('app.color.surface_card'))
        .border({ width: 1, color: $r('app.color.border_subtle') })
        .borderRadius(16)
        .width('100%')
      Text('系统分享可能把文本交给你选定的应用或设备；这不是向北斗邻援服务上传，也不会改变审核状态。')
        .fontSize(14)
        .lineHeight(22)
        .fontColor($r('app.color.text_warning'))
        .padding(16)
        .backgroundColor($r('app.color.surface_warning'))
        .borderRadius(16)
        .width('100%')
      Button('打开系统分享面板')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .backgroundColor($r('app.color.action_primary'))
        .fontColor($r('app.color.text_on_primary'))
        .borderRadius(12)
        .accessibilityText('确认内容并打开系统分享面板')
        .onClick(() => this.sharePreview())
      this.textButton('取消，不分享', '取消系统分享并返回演练记录', () => {
        this.showSharePreview = false;
      })
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
            .lineHeight(24)
            .fontColor($r('app.color.text_secondary'))
            .padding(28)
        } else if (this.privacyChoice.length === 0 || this.showPolicy) {
          this.policyView()
        } else if (this.showSharePreview) {
          this.sharePreviewView()
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
