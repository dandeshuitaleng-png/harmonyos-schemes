import { common, Want } from '@kit.AbilityKit';
import { ObservationStore, PRIVACY_ACCEPTED, PRIVACY_DECLINED } from '../data/ObservationStore';
import { ObservationDraft, ObservationInput, createObservation, editObservation, filterObservations, isExpired, validateInput } from '../data/Observation';

@Entry
@Component
struct Index {
  private readonly store: ObservationStore = new ObservationStore();
  private timer: number = -1;
  private scroller: Scroller = new Scroller();
  @State private drafts: ObservationDraft[] = [];
  @State private busy: boolean = false;
  @State private ready: boolean = false;
  @State private privacyReady: boolean = false;
  @State private privacyChoice: string = '';
  @State private showPolicy: boolean = false;
  @State private error: string = '';
  @State private notice: string = '';
  @State private now: number = Date.now();
  @State private query: string = '';
  @State private filter: string = '全部';
  @State private deleteId: number = 0;
  @State private editorOpen: boolean = false;
  @State private editId: number = 0;
  @State private title: string = '';
  @State private place: string = '';
  @State private description: string = '';
  @State private kind: string = '潮位异常';
  @State private risk: string = '未评估';
  @State private hours: number = 2;
  @State private formError: string = '';
  @State private confirmDiscard: boolean = false;

  aboutToAppear(): void {
    this.bootstrap();
    this.timer = setInterval(() => { this.now = Date.now(); }, 30000);
  }
  aboutToDisappear(): void { if (this.timer >= 0) clearInterval(this.timer); }
  onPageShow(): void { this.now = Date.now(); }
  onBackPress(): boolean {
    if (this.busy) return true;
    if (this.showPolicy && this.privacyChoice.length > 0) { this.showPolicy = false; this.scroller.scrollEdge(Edge.Top); return true; }
    if (this.editorOpen) { this.confirmDiscard = true; return true; }
    if (this.deleteId !== 0) { this.deleteId = 0; return true; }
    return false;
  }
  private hostContext(): common.UIAbilityContext {
    const context = this.getUIContext().getHostContext();
    if (context === undefined) throw new Error('页面上下文不可用');
    return context as common.UIAbilityContext;
  }
  private writable(): boolean { return this.ready && !this.busy && this.privacyChoice === PRIVACY_ACCEPTED; }
  private formatTime(value: string): string {
    const date = new Date(value);
    return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
  private async bootstrap(): Promise<void> {
    if (this.busy) return;
    this.busy = true;
    this.ready = false;
    this.error = '';
    try {
      this.privacyChoice = await this.store.loadPrivacyChoice(this.hostContext());
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        this.drafts = await this.store.load(this.hostContext());
        this.ready = true;
      } else { this.drafts = []; }
      this.now = Date.now();
    } catch {
      this.error = '读取失败或本机数据格式异常，已暂停修改以保护原记录。请重试；若持续失败，请保留应用数据进行排查。';
    } finally { this.privacyReady = true; this.busy = false; }
  }
  private async choosePrivacy(choice: string): Promise<void> {
    if (this.busy) return;
    this.busy = true;
    this.error = '';
    try {
      await this.store.savePrivacyChoice(this.hostContext(), choice);
      this.privacyChoice = choice;
      this.ready = false;
      this.showPolicy = false;
      this.scroller.scrollEdge(Edge.Top);
      this.editorOpen = false;
      this.deleteId = 0;
      this.drafts = [];
      if (choice === PRIVACY_ACCEPTED) {
        this.drafts = await this.store.load(this.hostContext());
        this.ready = true;
      }
    } catch { this.error = '隐私设置或草稿读取未完成，请重试读取确认状态。'; this.ready = false; }
    finally { this.busy = false; }
  }
  private beginCreate(): void {
    if (!this.writable()) return;
    this.editId = 0;
    this.title = ''; this.place = ''; this.description = '';
    this.kind = '潮位异常'; this.risk = '未评估'; this.hours = 2;
    this.formError = ''; this.confirmDiscard = false; this.deleteId = 0;
    this.notice = ''; this.editorOpen = true; this.scroller.scrollEdge(Edge.Top);
  }
  private beginEdit(item: ObservationDraft): void {
    if (!this.writable() || isExpired(item, Date.now())) { this.now = Date.now(); return; }
    this.editId = item.id;
    this.title = item.title; this.place = item.place; this.description = item.description;
    this.kind = item.kind; this.risk = item.risk;
    this.formError = ''; this.confirmDiscard = false; this.deleteId = 0;
    this.notice = ''; this.editorOpen = true; this.scroller.scrollEdge(Edge.Top);
  }
  private async saveForm(): Promise<void> {
    if (!this.writable()) return;
    const input: ObservationInput = { title: this.title, place: this.place, description: this.description, kind: this.kind, risk: this.risk };
    this.formError = validateInput(input);
    if (this.formError.length > 0) return;
    let updated: ObservationDraft[] = [];
    try {
      if (this.editId === 0) {
        updated = [createObservation(input, this.hours, Date.now(), this.drafts), ...this.drafts];
      } else {
        const item = this.drafts.find((record: ObservationDraft) => record.id === this.editId);
        if (item === undefined) { this.formError = '原记录不存在，请取消后重新查看'; return; }
        const replacement = editObservation(item, input, Date.now());
        updated = this.drafts.map((record: ObservationDraft) => record.id === this.editId ? replacement : record);
      }
    } catch (cause) { this.formError = (cause as Error).message; return; }
    this.busy = true;
    this.error = '';
    try {
      await this.store.save(this.hostContext(), updated);
      this.drafts = updated;
      this.editorOpen = false;
      this.scroller.scrollEdge(Edge.Top);
      this.notice = '已保存到本机 · 未上传';
      this.now = Date.now();
    } catch {
      this.ready = false;
      this.error = '保存未确认成功，输入仍保留。请先重试读取，再核对记录；不要卸载应用。';
    } finally { this.busy = false; }
  }
  private async confirmDelete(): Promise<void> {
    if (!this.writable() || this.deleteId === 0) return;
    const updated = this.deleteId === -1 ? [] : this.drafts.filter((item: ObservationDraft) => item.id !== this.deleteId);
    this.busy = true;
    this.error = '';
    try {
      await this.store.save(this.hostContext(), updated);
      this.drafts = updated;
      this.deleteId = 0;
      this.notice = '已删除本机记录';
    } catch { this.ready = false; this.error = '删除未确认成功，请重试读取以确认本机状态。'; }
    finally { this.busy = false; }
  }
  private async openDialer(): Promise<void> {
    try {
      const context = this.hostContext() as common.UIAbilityContext;
      const want: Want = { action: 'ohos.want.action.dial', uri: 'tel:' };
      await context.startAbility(want);
    } catch { this.error = '无法打开系统电话，请使用设备自带电话应用。'; }
  }

  @Builder
  errorView() {
    if (this.error.length > 0) {
      Column({ space: 8 }) {
        Text(this.error).fontSize(16).fontColor($r('app.color.text_danger'))
        Button('重试读取').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(!this.busy).onClick(() => this.bootstrap())
      }.width('100%').padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(12)
    }
  }
  @Builder
  policyView() {
    Column({ space: 16 }) {
      Text('隐私说明').fontSize(28).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('潮汐守望 · 离线观察簿').fontSize(18).fontColor($r('app.color.text_secondary'))
      Text('同意后，本机保存观察标题、地点概述、现场描述、类型、风险等级、来源、采集与修改时间、有效期、待审核状态和隐私选择。').fontSize(16).lineHeight(26).fontColor($r('app.color.text_primary'))
      Text('当前不接入网络、账号或第三方SDK，不申请相机或定位权限，不保存照片和自动定位坐标。文字中请勿填写个人住址、联系方式或受保护地点信息。').fontSize(16).lineHeight(26).fontColor($r('app.color.text_primary'))
      Text('所有记录仅保存在本机；没有审核服务，尚无审核人，不上传、不公开，也不是实时预报。过期记录会保留在历史中，可单条删除或清空。').fontSize(16).lineHeight(26).fontColor($r('app.color.text_primary'))
      Text('应用升级时会自动迁移本机记录；确认内容完整后清理旧版草稿副本，无需手动复制。').fontSize(16).lineHeight(26).fontColor($r('app.color.text_primary'))
      Text('选择不保存后将隐藏记录；已有记录不会自动删除。可再次同意后在观察簿中清除。清除或卸载应用后无法通过本应用恢复。开发者主体以应用市场登记信息为准。').fontSize(16).lineHeight(26).fontColor($r('app.color.text_primary'))
      Button('同意并进入观察簿').width('100%').constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary'))
        .enabled(!this.busy).onClick(() => this.choosePrivacy(PRIVACY_ACCEPTED))
      Button('不保存，仅查看说明').width('100%').constraintSize({ minHeight: 48 })
        .enabled(!this.busy).onClick(() => this.choosePrivacy(PRIVACY_DECLINED))
      if (this.privacyChoice.length > 0) {
        Button('返回').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(!this.busy).onClick(() => { this.showPolicy = false; this.scroller.scrollEdge(Edge.Top); })
      }
      this.errorView()
    }.alignItems(HorizontalAlign.Start).width('100%')
  }
  @Builder
  editorView() {
    Column({ space: 14 }) {
      Text(this.editId === 0 ? '新建现场观察' : '编辑现场观察').fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('仅本机可见。请记录亲眼所见，避免填写私人地址及个人信息。').fontSize(16).fontColor($r('app.color.text_secondary'))
      Text('观察类型').fontSize(16).fontColor($r('app.color.text_primary'))
      Select([{ value: '潮位异常' }, { value: '道路积水' }, { value: '避险物资' }, { value: '未分类' }]).value(this.kind)
        .onSelect((index: number, value: string) => { this.kind = value; }).width('100%').height(48).enabled(!this.busy)
      Text('标题（2–40字）').fontSize(16).fontColor($r('app.color.text_primary'))
      TextInput({ text: this.title, placeholder: '例如：东侧步道出现积水' }).maxLength(40).fontSize(16).height(52)
        .accessibilityText('观察标题，2到40字').enabled(!this.busy).onChange((value: string) => this.title = value)
      Text('地点概述（2–80字）').fontSize(16).fontColor($r('app.color.text_primary'))
      TextInput({ text: this.place, placeholder: '填写公共区域概述，不含私人地址' }).maxLength(80).fontSize(16).height(52)
        .accessibilityText('地点概述，2到80字').enabled(!this.busy).onChange((value: string) => this.place = value)
      Text('现场描述（5–500字）').fontSize(16).fontColor($r('app.color.text_primary'))
      TextArea({ text: this.description, placeholder: '记录观察到的现象、范围与变化' }).maxLength(500).fontSize(16).height(156)
        .accessibilityText('现场描述，5到500字').enabled(!this.busy).onChange((value: string) => this.description = value)
      Text('风险等级（个人现场判断）').fontSize(16).fontColor($r('app.color.text_primary'))
      Select([{ value: '未评估' }, { value: '低' }, { value: '中' }, { value: '高' }]).value(this.risk)
        .onSelect((index: number, value: string) => { this.risk = value; }).width('100%').height(48).enabled(!this.busy)
      if (this.editId === 0) {
        Text('有效期').fontSize(16).fontColor($r('app.color.text_primary'))
        Select([{ value: '1小时' }, { value: '2小时' }, { value: '6小时' }, { value: '12小时' }, { value: '24小时' }]).value(`${this.hours}小时`)
          .onSelect((index: number) => { this.hours = [1, 2, 6, 12, 24][index]; }).width('100%').height(48).enabled(!this.busy)
      } else {
        Text('编辑保留原采集时间和有效期。新的现场情况请新建观察。').fontSize(16).fontColor($r('app.color.text_secondary'))
      }
      if (this.formError.length > 0) { Text(this.formError).fontSize(16).fontColor($r('app.color.text_danger')) }
      this.errorView()
      Button(this.busy ? '正在处理…' : '保存到本机').width('100%').constraintSize({ minHeight: 52 })
        .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary'))
        .enabled(this.writable()).onClick(() => this.saveForm())
      if (this.confirmDiscard) {
        Text('放弃尚未保存的输入？').fontSize(16).fontColor($r('app.color.text_danger'))
        Button('确认放弃').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(!this.busy)
          .onClick(() => { this.editorOpen = false; this.confirmDiscard = false; this.scroller.scrollEdge(Edge.Top); })
        Button('继续编辑').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(!this.busy).onClick(() => this.confirmDiscard = false)
      } else {
        Button('取消').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(!this.busy).onClick(() => this.confirmDiscard = true)
      }
    }.alignItems(HorizontalAlign.Start).width('100%')
  }
  @Builder
  recordCard(item: ObservationDraft) {
    Column({ space: 8 }) {
      Text(item.title).fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text(`${item.kind} · 风险：${item.risk} · ${isExpired(item, this.now) ? '已过期' : '有效期内'}`).fontSize(16).fontColor($r('app.color.text_pending'))
      Text(item.place).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
      Text(item.description).fontSize(16).lineHeight(24).fontColor($r('app.color.text_primary'))
      Text(`来源：${item.source}`).fontSize(14).fontColor($r('app.color.text_secondary'))
      Text(`采集：${this.formatTime(item.collectedAt)}`).fontSize(14).fontColor($r('app.color.text_secondary'))
      Text(`有效至：${this.formatTime(item.expiresAt)}`).fontSize(14).fontColor($r('app.color.text_secondary'))
      Text('待审核 · 尚无审核人\n仅本机可见 · 未上传').fontSize(14).lineHeight(22).fontColor($r('app.color.text_muted'))
      Row({ space: 12 }) {
        Button('编辑').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(this.writable() && !isExpired(item, this.now))
          .accessibilityText(`编辑${item.title}`).onClick(() => this.beginEdit(item))
        Button('删除').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(this.writable())
          .accessibilityText(`删除${item.title}，需要再次确认`).onClick(() => this.deleteId = item.id)
      }
      if (this.deleteId === item.id) { this.deleteConfirmation() }
    }.alignItems(HorizontalAlign.Start).padding(18).width('100%').backgroundColor($r('app.color.surface_card')).borderRadius(16)
  }
  @Builder
  deleteConfirmation() {
    Column({ space: 8 }) {
      Text(this.deleteId === -1 ? '确认删除全部记录（含过期历史）？此操作不可恢复。' : '确认删除这条记录？此操作不可恢复。')
        .fontSize(16).fontColor($r('app.color.text_danger'))
      Button('确认删除').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(this.writable()).onClick(() => this.confirmDelete())
      Button('取消删除').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(!this.busy).onClick(() => this.deleteId = 0)
    }.alignItems(HorizontalAlign.Start).width('100%')
  }
  @Builder
  mainView() {
    Column({ space: 16 }) {
      Text('潮汐守望').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('离线观察簿 · 非实时预报').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 8 }) {
        Text('现场观察仅供记录，未经人工复核。').fontSize(16).fontColor($r('app.color.text_notice'))
        Text('遇紧急情况，请使用官方应急渠道。').fontSize(16).fontColor($r('app.color.text_notice'))
        Button('打开系统电话').constraintSize({ minHeight: 48 }).onClick(() => this.openDialer())
      }.alignItems(HorizontalAlign.Start).padding(16).width('100%').backgroundColor($r('app.color.surface_notice')).borderRadius(16)
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        Button('＋ 新建现场观察').width('100%').constraintSize({ minHeight: 54 })
          .backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary'))
          .enabled(this.writable() && this.drafts.length < 200).onClick(() => this.beginCreate())
        Text(`本机记录 ${this.drafts.length}/200 · 过期历史持续保留`).fontSize(16).fontColor($r('app.color.text_secondary'))
        Search({ value: this.query, placeholder: '搜索标题、地点或描述' }).onChange((value: string) => this.query = value).height(52)
        Select([{ value: '全部' }, { value: '有效期内' }, { value: '已过期' }]).value(this.filter).height(48)
          .onSelect((index: number, value: string) => { this.filter = value; this.deleteId = 0; })
        if (this.notice.length > 0) { Text(this.notice).fontSize(16).fontColor($r('app.color.text_pending')) }
        this.errorView()
        if (this.busy) {
          Text('正在准备本机记录…').fontSize(16).fontColor($r('app.color.text_secondary'))
        } else if (this.ready && this.drafts.length === 0) {
          Text('还没有现场观察。新建一条记录，断网也能保存在本机。').fontSize(16).fontColor($r('app.color.text_secondary')).padding(20)
        } else if (this.ready && filterObservations(this.drafts, this.query, this.filter, this.now).length === 0) {
          Text('没有匹配记录，试试其他关键词或切换“全部”。').fontSize(16).fontColor($r('app.color.text_secondary'))
        }
        ForEach(filterObservations(this.drafts, this.query, this.filter, this.now), (item: ObservationDraft) => {
          this.recordCard(item)
        }, (item: ObservationDraft) => `${item.id}-${item.updatedAt}-${isExpired(item, this.now)}`)
        if (this.drafts.length > 0) {
          if (this.deleteId === -1) { this.deleteConfirmation() }
          else {
            Button('清除全部本机记录').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(this.writable())
              .onClick(() => this.deleteId = -1)
          }
        }
      } else {
        Text('你选择不保存观察。本机历史已隐藏，可以在隐私说明中重新开启。').fontSize(16).fontColor($r('app.color.text_secondary'))
        this.errorView()
      }
      Button('隐私说明与保存设置').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.surface_pending')).fontColor($r('app.color.action_primary')).enabled(!this.busy).onClick(() => { this.showPolicy = true; this.scroller.scrollEdge(Edge.Top); })
    }.alignItems(HorizontalAlign.Start).width('100%')
  }
  build() {
    Scroll(this.scroller) {
      Column() {
        if (!this.privacyReady) {
          Text('正在读取本机状态…').fontSize(16).fontColor($r('app.color.text_secondary'))
        } else if (this.privacyChoice.length === 0 || this.showPolicy) {
          this.policyView()
        } else if (this.editorOpen) {
          this.editorView()
        } else { this.mainView() }
      }.padding(20).width('100%').constraintSize({ maxWidth: 640 }).alignItems(HorizontalAlign.Start)
    }.width('100%').height('100%').backgroundColor($r('app.color.surface_canvas')).align(Alignment.Top).scrollBar(BarState.Auto)
  }
}
