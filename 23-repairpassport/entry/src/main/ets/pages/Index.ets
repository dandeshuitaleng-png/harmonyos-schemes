import { DeviceCard, DeviceStore, RepairEvent } from '../data/DeviceStore';

@Entry
@Component
struct Index {
  private readonly store: DeviceStore = new DeviceStore();
  @State private cards: DeviceCard[] = [];
  @State private category: string = '';
  @State private model: string = '';
  @State private purchaseDate: string = '';
  @State private warrantyDate: string = '';
  @State private eventType: string = '';
  @State private eventDate: string = '';
  @State private eventNote: string = '';
  @State private eventCardId: number = 0;
  @State private failedEventCardId: number = 0;
  @State private exportCardId: number = 0;
  @State private includeCategory: boolean = true;
  @State private includeModel: boolean = false;
  @State private includePurchaseDate: boolean = true;
  @State private includeWarrantyDate: boolean = true;
  @State private includeEvents: boolean = true;
  @State private loading: boolean = true;
  @State private errorText: string = '';
  @State private confirmDeleteId: number = 0;

  aboutToAppear(): void { this.load(); }
  onBackPress(): boolean {
    if (this.confirmDeleteId !== 0) {
      this.confirmDeleteId = 0;
      return true;
    }
    return false;
  }
  private context(): Context { return getContext(this); }
  private canSave(): boolean { return this.category.trim().length > 0 && this.model.trim().length > 0 && this.purchaseDate.trim().length > 0; }
  private canSaveEvent(): boolean { return this.eventCardId !== 0 && this.eventType.trim().length > 0 && this.eventDate.trim().length > 0; }
  private eventsFor(card: DeviceCard): RepairEvent[] { return card.events ?? []; }
  private cardWithEvent(card: DeviceCard, event: RepairEvent): DeviceCard {
    const events: RepairEvent[] = [event];
    this.eventsFor(card).forEach((existing: RepairEvent) => events.push(existing));
    return { id: card.id, category: card.category, model: card.model, purchaseDate: card.purchaseDate, warrantyDate: card.warrantyDate, events: events };
  }
  private async load(): Promise<void> {
    this.loading = true; this.errorText = '';
    try { this.cards = await this.store.load(this.context()); }
    catch { this.errorText = '无法读取本机设备卡。请重试；不会影响外部服务。'; }
    finally { this.loading = false; }
  }
  private async save(): Promise<void> {
    if (!this.canSave() || this.loading) { return; }
    const card: DeviceCard = { id: Date.now(), category: this.category.trim(), model: this.model.trim(), purchaseDate: this.purchaseDate.trim(), warrantyDate: this.warrantyDate.trim(), events: [] };
    this.loading = true; this.errorText = '';
    try { const updated = [card, ...this.cards]; await this.store.save(this.context(), updated); this.cards = updated; this.category = ''; this.model = ''; this.purchaseDate = ''; this.warrantyDate = ''; }
    catch { this.errorText = '无法保存本机设备卡。请保留填写内容后重试；没有上传数据。'; }
    finally { this.loading = false; }
  }
  private async remove(id: number): Promise<void> {
    if (this.confirmDeleteId !== id) {
      this.confirmDeleteId = id;
      return;
    }
    this.loading = true; this.errorText = '';
    try { const updated = this.cards.filter((card: DeviceCard) => card.id !== id); await this.store.save(this.context(), updated); this.cards = updated; this.confirmDeleteId = 0; if (this.eventCardId === id) { this.cancelEvent(); } if (this.exportCardId === id) { this.cancelExportSelection(); } }
    catch { this.errorText = '无法删除本机设备卡。请重试；没有上传数据。'; }
    finally { this.loading = false; }
  }
  private beginEvent(card: DeviceCard): void {
    this.eventCardId = card.id; this.exportCardId = 0; this.failedEventCardId = 0; this.errorText = '';
    this.eventType = ''; this.eventDate = ''; this.eventNote = '';
  }
  private cancelEvent(): void {
    this.eventCardId = 0; this.failedEventCardId = 0;
    this.eventType = ''; this.eventDate = ''; this.eventNote = '';
  }
  private beginExportSelection(card: DeviceCard): void {
    this.exportCardId = card.id;
    this.includeCategory = true; this.includeModel = false; this.includePurchaseDate = true;
    this.includeWarrantyDate = card.warrantyDate.length > 0; this.includeEvents = this.eventsFor(card).length > 0;
  }
  private cancelExportSelection(): void { this.exportCardId = 0; }
  private async saveEvent(): Promise<void> {
    if (!this.canSaveEvent() || this.loading) { return; }
    const cardId = this.eventCardId;
    const event: RepairEvent = { id: Date.now(), eventType: this.eventType.trim(), eventDate: this.eventDate.trim(), note: this.eventNote.trim() };
    this.loading = true; this.errorText = ''; this.failedEventCardId = 0;
    try {
      const updated = this.cards.map((card: DeviceCard) => card.id === cardId ? this.cardWithEvent(card, event) : card);
      await this.store.save(this.context(), updated); this.cards = updated; this.cancelEvent();
    } catch {
      this.failedEventCardId = cardId;
      this.errorText = '无法保存本机维修事件。输入内容仍保留，可再次保存；没有上传数据。';
    } finally { this.loading = false; }
  }

  @Builder
  private exportFieldPanel(card: DeviceCard) {
    if (this.exportCardId === card.id) {
      Column({ space: 8 }) {
        Text('选择本地摘要字段').fontSize(16).fontWeight(FontWeight.Medium)
        Text('仅在此处预览；不会导出、发送或写入你的选择。型号默认隐藏。').fontSize(13)
        Button(`设备类别 · ${this.includeCategory ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeCategory = !this.includeCategory)
        Button(`用户填写型号 · ${this.includeModel ? '已包含' : '默认隐藏'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeModel = !this.includeModel)
        Button(`购买日期 · ${this.includePurchaseDate ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includePurchaseDate = !this.includePurchaseDate)
        if (card.warrantyDate.length > 0) { Button(`保修日期 · ${this.includeWarrantyDate ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeWarrantyDate = !this.includeWarrantyDate) }
        if (this.eventsFor(card).length > 0) { Button(`维修事件与备注 · ${this.includeEvents ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeEvents = !this.includeEvents) }
        if (!this.includeCategory && !this.includeModel && !this.includePurchaseDate && !this.includeWarrantyDate && !this.includeEvents) { Text('请保留至少一个字段，才能形成摘要。').fontSize(13) }
        else {
          Text(`${this.includeCategory ? `设备类别：${card.category}\n` : ''}${this.includeModel ? `用户填写型号：${card.model}\n` : ''}${this.includePurchaseDate ? `购买日期：${card.purchaseDate}\n` : ''}${this.includeWarrantyDate && card.warrantyDate.length > 0 ? `保修到期日：${card.warrantyDate}\n` : ''}${this.includeEvents ? this.eventsFor(card).map((event: RepairEvent) => `${event.eventDate} · ${event.eventType}${event.note.length > 0 ? ` · 备注：${event.note}` : ''}`).join('\n') : ''}`.trim()).fontSize(14)
          Text('此摘要仅在本地预览，未生成文件或导出内容。').fontSize(13)
        }
        Button('取消字段选择').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText('取消本地摘要字段选择，不导出或发送任何数据').onClick(() => this.cancelExportSelection())
      }.padding(12).backgroundColor($r('app.color.surface_card')).borderRadius(12).width('100%')
    }
  }

  @Builder
  private eventPanel(card: DeviceCard) {
    if (this.eventCardId === card.id) {
      Column({ space: 8 }) {
        Text('记录本机维修事件').fontSize(16).fontWeight(FontWeight.Medium)
        Text('只记录你填写的类型、日期和备注；不附加文件，也不做诊断或报价。').fontSize(13)
        TextInput({ placeholder: '事件类型，例如 送修、已修或报废（必填）', text: this.eventType }).onChange((value: string) => this.eventType = value)
        TextInput({ placeholder: '发生日期（必填）', text: this.eventDate }).onChange((value: string) => this.eventDate = value)
        TextInput({ placeholder: '本机备注（可选）', text: this.eventNote }).onChange((value: string) => this.eventNote = value)
        if (!this.canSaveEvent()) { Text('填写事件类型和发生日期后即可保存。').fontSize(13) }
        Button(this.failedEventCardId === card.id ? '再次保存该维修事件' : '保存本机维修事件').width('100%').constraintSize({ minHeight: 48 }).enabled(this.canSaveEvent() && !this.loading).accessibilityText('保存仅在本机保留的维修事件').onClick(() => this.saveEvent())
        Button('取消记录事件').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText('取消记录本机维修事件，不保存输入').onClick(() => this.cancelEvent())
      }.padding(12).backgroundColor($r('app.color.surface_card')).borderRadius(12).width('100%')
    }
  }

  @Builder
  private eventTimeline(card: DeviceCard) {
    Column({ space: 6 }) {
      Text('维修时间线').fontSize(15).fontWeight(FontWeight.Medium)
      if (this.eventsFor(card).length === 0) { Text('尚未记录维修事件。需要时可仅在本机添加一条。').fontSize(14) }
      else { ForEach(this.eventsFor(card), (event: RepairEvent) => { Column({ space: 3 }) { Text(`${event.eventDate} · ${event.eventType}`).fontSize(14).fontWeight(FontWeight.Medium); if (event.note.length > 0) { Text(`备注：${event.note}`).fontSize(13) } }.padding(10).backgroundColor($r('app.color.surface_card')).borderRadius(10).width('100%') }, (event: RepairEvent) => event.id.toString()) }
    }.padding(12).backgroundColor($r('app.color.surface_timeline')).borderRadius(12).width('100%')
  }

  build() {
    Scroll() { Column({ space: 16 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('修物志').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
          Text('整理自己的设备保修与送修资料').fontSize(17).fontColor($r('app.color.text_secondary')).lineHeight(24)
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('非诊断')
          .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.surface_warning')).borderRadius(8)
          .accessibilityText('不诊断、不报价、不教拆机')
      }.width('100%').alignItems(VerticalAlign.Top)
      Column({ space: 6 }) {
        Text('本机资料索引 · 不诊断、不报价、不教拆机').fontSize(16)
        Text('本切片保存设备卡与用户手动填写的维修事件；文件、导出和诊断尚未实现。').fontSize(14)
      }.padding(16).backgroundColor($r('app.color.surface_warning')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text('新建设备卡').fontSize(20).fontWeight(FontWeight.Bold)
        TextInput({ placeholder: '设备类别（必填）', text: this.category }).onChange((value: string) => this.category = value)
        TextInput({ placeholder: '用户填写型号（必填）', text: this.model }).onChange((value: string) => this.model = value)
        TextInput({ placeholder: '购买日期（必填）', text: this.purchaseDate }).onChange((value: string) => this.purchaseDate = value)
        TextInput({ placeholder: '保修到期日（可选）', text: this.warrantyDate }).onChange((value: string) => this.warrantyDate = value)
        if (!this.canSave()) { Text('填写类别、型号和购买日期后即可保存。').fontSize(14) }
        Button('保存本机设备卡').width('100%').constraintSize({ minHeight: 52 }).enabled(this.canSave() && !this.loading).accessibilityText('保存仅在本机保留的设备卡').onClick(() => this.save())
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      if (this.errorText.length > 0) { Column({ space: 8 }) { Text(this.errorText); Button('重试读取本机设备卡').onClick(() => this.load()) }.padding(16).backgroundColor($r('app.color.surface_warning')).borderRadius(16).width('100%') }
      Column({ space: 10 }) {
        Text('我的设备卡').fontSize(20).fontWeight(FontWeight.Bold)
        if (this.loading) { Text('正在读取或保存本机资料…') }
        else if (this.cards.length === 0) { Text('还没有设备卡。文件选择取消或文件不可用时，核心卡片仍可继续使用。') }
        else { ForEach(this.cards, (card: DeviceCard) => { Column({ space: 7 }) {
          Text(`${card.category} · ${card.model}`).fontSize(17).fontWeight(FontWeight.Medium)
          Text(`购买：${card.purchaseDate}${card.warrantyDate.length > 0 ? ` · 保修至：${card.warrantyDate}` : ''}`).fontSize(14)
          Text('仅本机保存 · 未附加文件').fontSize(13)
          this.eventTimeline(card)
          Button(this.eventCardId === card.id ? '收起事件表单' : '记录维修事件').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText(`为${card.model}记录本机维修事件`).onClick(() => this.eventCardId === card.id ? this.cancelEvent() : this.beginEvent(card))
          this.eventPanel(card)
          Button(this.exportCardId === card.id ? '取消摘要字段选择' : '选择导出前字段').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText(`为${card.category}选择本地摘要字段，默认隐藏型号且不会导出`).onClick(() => this.exportCardId === card.id ? this.cancelExportSelection() : this.beginExportSelection(card))
          this.exportFieldPanel(card)
          if (this.confirmDeleteId === card.id) {
            Text('删除后无法从本应用恢复这张设备卡及其维修事件。没有上传。').fontSize(14).fontColor($r('app.color.text_danger'))
            Button('确认删除这张设备卡').fontColor($r('app.color.text_danger')).backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 }).accessibilityText(`确认删除${card.model}及其本机维修事件，此操作不能撤销`).onClick(() => this.remove(card.id))
            Button('取消删除').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 }).onClick(() => this.confirmDeleteId = 0)
          } else {
            Button('删除这张设备卡').backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 48 }).accessibilityText(`准备删除${card.model}及其本机维修事件，下一步需要确认`).onClick(() => this.remove(card.id))
          }
        }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(16).width('100%') }, (card: DeviceCard) => card.id.toString()) }
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).width('100%') }.width('100%').height('100%')
  }
}
