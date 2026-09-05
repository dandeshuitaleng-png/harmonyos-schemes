import { CareEvent, Garment, GarmentStore } from '../data/local/GarmentStore';

@Entry
@Component
struct Index {
  private readonly garmentStore: GarmentStore = new GarmentStore();
  @State private garments: Garment[] = [];
  @State private name: string = '';
  @State private category: string = '';
  @State private statusText: string = '';
  @State private nextActionDate: string = '';
  @State private careAgreement: string = '';
  @State private repairPrep: string = '';
  @State private eventType: string = '';
  @State private eventDate: string = '';
  @State private eventNote: string = '';
  @State private eventGarmentId: number = 0;
  @State private failedEventGarmentId: number = 0;
  @State private editingGarmentId: number = 0;
  @State private isLoading: boolean = true;
  @State private errorText: string = '';
  @State private confirmDeleteId: number = 0;

  aboutToAppear(): void { this.loadGarments(); }
  onBackPress(): boolean {
    if (this.confirmDeleteId !== 0) {
      this.confirmDeleteId = 0;
      return true;
    }
    return false;
  }
  private context(): Context { return getContext(this); }
  private canSave(): boolean { return this.name.trim().length > 0 && this.category.trim().length > 0 && this.statusText.trim().length > 0 && this.careAgreement.trim().length > 0; }
  private canSaveEvent(): boolean { return this.eventGarmentId !== 0 && this.eventType.trim().length > 0 && this.eventDate.trim().length > 0; }
  private eventsFor(garment: Garment): CareEvent[] { return garment.events ?? []; }
  private garmentWithEvent(garment: Garment, event: CareEvent): Garment {
    const events: CareEvent[] = [event];
    this.eventsFor(garment).forEach((existing: CareEvent) => events.push(existing));
    return { id: garment.id, name: garment.name, category: garment.category, statusText: garment.statusText, nextActionDate: garment.nextActionDate, careAgreement: garment.careAgreement, repairPrep: garment.repairPrep, events: events };
  }
  private async loadGarments(): Promise<void> {
    this.isLoading = true; this.errorText = '';
    try { this.garments = await this.garmentStore.load(this.context()); }
    catch { this.errorText = '无法读取本机衣物卡。请重试；不会影响任何外部服务。'; }
    finally { this.isLoading = false; }
  }
  private clearForm(): void { this.name = ''; this.category = ''; this.statusText = ''; this.nextActionDate = ''; this.careAgreement = ''; this.repairPrep = ''; this.editingGarmentId = 0; }
  private async saveGarment(): Promise<void> {
    if (!this.canSave() || this.isLoading) { return; }
    const existing = this.garments.find((item: Garment) => item.id === this.editingGarmentId);
    const garment: Garment = { id: existing ? existing.id : Date.now(), name: this.name.trim(), category: this.category.trim(), statusText: this.statusText.trim(), nextActionDate: this.nextActionDate.trim(), careAgreement: this.careAgreement.trim(), repairPrep: this.repairPrep.trim(), events: existing?.events ?? [] };
    this.isLoading = true; this.errorText = '';
    try { const updated = existing ? this.garments.map((item: Garment) => item.id === garment.id ? garment : item) : [garment, ...this.garments]; await this.garmentStore.save(this.context(), updated); this.garments = updated; this.clearForm(); }
    catch { this.errorText = '无法保存本机衣物卡。请保留填写内容后重试；没有上传数据。'; }
    finally { this.isLoading = false; }
  }
  private async deleteGarment(id: number): Promise<void> {
    if (this.confirmDeleteId !== id) {
      this.confirmDeleteId = id;
      return;
    }
    this.isLoading = true; this.errorText = '';
    try { const updated = this.garments.filter((garment: Garment) => garment.id !== id); await this.garmentStore.save(this.context(), updated); this.garments = updated; this.confirmDeleteId = 0; if (this.eventGarmentId === id) { this.cancelEvent(); } if (this.editingGarmentId === id) { this.clearForm(); } }
    catch { this.errorText = '无法删除本机衣物卡。请重试；没有上传数据。'; }
    finally { this.isLoading = false; }
  }
  private beginEvent(garment: Garment): void {
    this.eventGarmentId = garment.id; this.failedEventGarmentId = 0; this.errorText = '';
    this.eventType = ''; this.eventDate = ''; this.eventNote = '';
  }
  private beginEdit(garment: Garment): void {
    this.editingGarmentId = garment.id; this.confirmDeleteId = 0; this.cancelEvent();
    this.name = garment.name; this.category = garment.category; this.statusText = garment.statusText;
    this.nextActionDate = garment.nextActionDate; this.careAgreement = garment.careAgreement; this.repairPrep = garment.repairPrep;
  }
  private cancelEvent(): void { this.eventGarmentId = 0; this.failedEventGarmentId = 0; this.eventType = ''; this.eventDate = ''; this.eventNote = ''; }
  private async saveEvent(): Promise<void> {
    if (!this.canSaveEvent() || this.isLoading) { return; }
    const garmentId = this.eventGarmentId;
    const event: CareEvent = { id: Date.now(), eventType: this.eventType.trim(), occurredAt: this.eventDate.trim(), note: this.eventNote.trim() };
    this.isLoading = true; this.errorText = ''; this.failedEventGarmentId = 0;
    try {
      const updated = this.garments.map((garment: Garment) => garment.id === garmentId ? this.garmentWithEvent(garment, event) : garment);
      await this.garmentStore.save(this.context(), updated); this.garments = updated; this.cancelEvent();
    } catch { this.failedEventGarmentId = garmentId; this.errorText = '无法保存本机照看事件。输入内容仍保留，可再次保存；没有上传数据。'; }
    finally { this.isLoading = false; }
  }

  @Builder
  private eventPanel(garment: Garment) {
    if (this.eventGarmentId === garment.id) {
      Column({ space: 8 }) {
        Text('记录本机照看事件').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
        Text('只记录你填写的事件、日期和备注；应用不判断方法是否正确。').fontSize(13).fontColor($r('app.color.text_secondary'))
        TextInput({ placeholder: '事件类型，例如 清洁、缝补、送修或收回（必填）', text: this.eventType }).onChange((value: string) => this.eventType = value)
        TextInput({ placeholder: '发生日期（必填）', text: this.eventDate }).onChange((value: string) => this.eventDate = value)
        TextInput({ placeholder: '本机备注（可选）', text: this.eventNote }).onChange((value: string) => this.eventNote = value)
        if (!this.canSaveEvent()) { Text('填写事件类型和发生日期后即可保存。').fontSize(13).fontColor($r('app.color.text_secondary')) }
        Button(this.failedEventGarmentId === garment.id ? '再次保存该照看事件' : '保存本机照看事件').width('100%').constraintSize({ minHeight: 48 }).backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(14).enabled(this.canSaveEvent() && !this.isLoading).accessibilityText('保存仅在本机保留的照看事件').onClick(() => this.saveEvent())
        Button('取消记录事件').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText('取消记录本机照看事件，不保存输入').onClick(() => this.cancelEvent())
      }.padding(12).backgroundColor($r('app.color.surface_card')).borderRadius(12).width('100%')
    }
  }

  @Builder
  private eventTimeline(garment: Garment) {
    Column({ space: 6 }) {
      Text('照看时间线').fontSize(15).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
      if (this.eventsFor(garment).length === 0) { Text('尚未记录照看事件。需要时可仅在本机添加一条。').fontSize(14).fontColor($r('app.color.text_secondary')) }
      else { ForEach(this.eventsFor(garment), (event: CareEvent) => { Column({ space: 3 }) { Text(`${event.occurredAt} · ${event.eventType}`).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')); if (event.note.length > 0) { Text(`备注：${event.note}`).fontSize(13).fontColor($r('app.color.text_secondary')) } }.padding(10).backgroundColor($r('app.color.surface_card')).borderRadius(10).width('100%') }, (event: CareEvent) => event.id.toString()) }
    }.padding(12).backgroundColor($r('app.color.surface_warning')).borderRadius(12).width('100%')
  }

  build() {
    Scroll() { Column({ space: 16 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('织日').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
          Text('为值得继续穿的一件衣物，留下下一步。').fontSize(17).fontColor($r('app.color.text_secondary')).lineHeight(24)
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('非鉴定')
          .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.surface_warning')).borderRadius(8)
          .accessibilityText('不鉴定、不提供洗护建议')
      }.width('100%').alignItems(VerticalAlign.Top)
      Column({ space: 6 }) {
        Text('本机衣物照看卡 · 不鉴定、不提供洗护建议').fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_warning'))
        Text('本切片仅保存文字卡片与用户自定约定。照片、Picker、提醒、分享、服务卡片和网络尚未实现。').fontSize(14).fontColor($r('app.color.text_secondary'))
      }.padding(16).backgroundColor($r('app.color.surface_warning')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text(this.editingGarmentId === 0 ? '记录一件待照看衣物' : '编辑本机衣物卡').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        TextInput({ placeholder: '衣物个人称呼（必填）', text: this.name }).onChange((value: string) => this.name = value)
        TextInput({ placeholder: '类别，例如 外套（必填）', text: this.category }).onChange((value: string) => this.category = value)
        TextInput({ placeholder: '当下状态文字（必填）', text: this.statusText }).onChange((value: string) => this.statusText = value)
        TextInput({ placeholder: '下一步日期（可选，例如 周六）', text: this.nextActionDate }).onChange((value: string) => this.nextActionDate = value)
        TextInput({ placeholder: '我的照看约定（必填）', text: this.careAgreement }).onChange((value: string) => this.careAgreement = value)
        TextInput({ placeholder: '送修或清洁前准备项（可选）', text: this.repairPrep }).onChange((value: string) => this.repairPrep = value)
        if (!this.canSave()) { Text('填写称呼、类别、状态和照看约定后即可保存。').fontSize(14).fontColor($r('app.color.text_secondary')) }
        Button(this.editingGarmentId === 0 ? '保存本机衣物卡' : '保存修改').width('100%').constraintSize({ minHeight: 52 }).backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(14).enabled(this.canSave() && !this.isLoading).accessibilityText(this.editingGarmentId === 0 ? '保存仅在本机保留的衣物照看卡' : '保存对本机衣物卡的修改').onClick(() => this.saveGarment())
        if (this.editingGarmentId !== 0) { Button('取消编辑').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).constraintSize({ minHeight: 48 }).accessibilityText('取消编辑，不修改原衣物卡').onClick(() => this.clearForm()) }
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      if (this.errorText.length > 0) { Column({ space: 8 }) { Text(this.errorText).fontSize(14).fontColor($r('app.color.text_warning')); Button('重试读取本机衣物卡').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.loadGarments()) }.padding(16).backgroundColor($r('app.color.surface_warning')).borderRadius(16).width('100%') }
      Column({ space: 10 }) {
        Text('待照看衣物').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        if (this.isLoading) { Text('正在读取本机衣物卡…').fontSize(15).fontColor($r('app.color.text_secondary')) }
        else if (this.garments.length === 0) { Text('还没有衣物卡。记录第一件需要照看的衣物即可开始。').fontSize(15).fontColor($r('app.color.text_secondary')) }
        else { ForEach(this.garments, (garment: Garment) => { Column({ space: 5 }) {
          Text(`${garment.name} · ${garment.category}`).fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
          Text(`状态：${garment.statusText}`).fontSize(14).fontColor($r('app.color.text_secondary'))
          Text(`照看约定：${garment.careAgreement}`).fontSize(14).fontColor($r('app.color.text_secondary'))
          if (garment.nextActionDate.length > 0) { Text(`下一步日期：${garment.nextActionDate} · 未创建系统提醒`).fontSize(13).fontColor($r('app.color.text_warning')) }
          else { Text('尚未填写下一步日期 · 未创建系统提醒').fontSize(13).fontColor($r('app.color.text_warning')) }
          if (garment.repairPrep.length > 0) { Text(`准备项：${garment.repairPrep}`).fontSize(13).fontColor($r('app.color.text_secondary')) }
          this.eventTimeline(garment)
          Button('编辑这张衣物卡').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
            .constraintSize({ minHeight: 48 }).accessibilityText(`编辑${garment.name}的本机衣物卡`).onClick(() => this.beginEdit(garment))
          Button(this.eventGarmentId === garment.id ? '收起事件表单' : '记录照看事件').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText(`为${garment.name}记录本机照看事件`).onClick(() => this.eventGarmentId === garment.id ? this.cancelEvent() : this.beginEvent(garment))
          this.eventPanel(garment)
          Text('仅本机保存 · 未附图、未分享').fontSize(13).fontColor($r('app.color.text_success'))
          if (this.confirmDeleteId === garment.id) {
            Text('删除后无法从本应用恢复这张衣物卡和照看事件。没有上传。').fontSize(13).fontColor($r('app.color.text_danger'))
            Button('确认删除这张衣物卡').fontColor($r('app.color.text_danger')).backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 }).accessibilityText(`确认删除${garment.name}的本机衣物记录，此操作不能撤销`).onClick(() => this.deleteGarment(garment.id))
            Button('取消删除').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 }).onClick(() => this.confirmDeleteId = 0)
          } else {
            Button('删除这张衣物卡').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 }).accessibilityText(`准备删除${garment.name}的本机衣物记录，下一步需要确认`).onClick(() => this.deleteGarment(garment.id))
          }
        }.padding(16).backgroundColor($r('app.color.surface_success')).borderRadius(16).width('100%') }, (garment: Garment) => garment.id.toString()) }
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%') }.width('100%').height('100%').backgroundColor($r('app.color.surface_canvas'))
  }
}
