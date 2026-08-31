import { preferences } from '@kit.ArkData';

interface PlantCard {
  id: number;
  name: string;
  room: string;
  task: string;
  carer: string;
  confirmed?: boolean;
  completed?: boolean;
  completedAt?: string;
  completionNote?: string;
}

@Entry
@Component
struct Index {
  @State private cards: PlantCard[] = [];
  @State private name: string = '';
  @State private room: string = '';
  @State private task: string = '';
  @State private carer: string = '';
  @State private completionDate: string = '';
  @State private completionNote: string = '';
  @State private completingCardId: number = 0;
  @State private retryCardId: number = 0;
  @State private retryKind: string = '';
  @State private exportCardId: number = 0;
  @State private includePlantName: boolean = true;
  @State private includeRoom: boolean = false;
  @State private includeTask: boolean = true;
  @State private includeCarer: boolean = false;
  @State private includeConfirmation: boolean = true;
  @State private includeCompletionTime: boolean = false;
  @State private includeCompletionNote: boolean = false;
  @State private loading: boolean = true;
  @State private errorText: string = '';

  aboutToAppear(): void { this.load(); }
  private ctx(): Context { return getContext(this); }
  private ready(): boolean { return this.name.trim().length > 0 && this.task.trim().length > 0 && this.carer.trim().length > 0; }
  private readyToComplete(): boolean { return this.completingCardId !== 0 && this.completionDate.trim().length > 0; }
  private normalize(card: PlantCard): PlantCard {
    return { id: card.id, name: card.name, room: card.room, task: card.task, carer: card.carer, confirmed: card.confirmed === true, completed: card.completed === true, completedAt: card.completedAt ?? '', completionNote: card.completionNote ?? '' };
  }
  private cardCount(completed: boolean): number {
    let count = 0;
    this.cards.forEach((card: PlantCard) => { if (card.completed === completed) { count++; } });
    return count;
  }
  private async persist(cards: PlantCard[]): Promise<boolean> {
    try {
      const p = await preferences.getPreferences(this.ctx(), 'leafmate');
      await p.put('cards', JSON.stringify(cards)); await p.flush(); this.cards = cards;
      return true;
    } catch { return false; }
  }
  private async load(): Promise<void> {
    this.loading = true; this.errorText = '';
    try {
      const p = await preferences.getPreferences(this.ctx(), 'leafmate');
      const value = await p.get('cards', '') as string;
      const raw = value.length > 0 ? JSON.parse(value) as PlantCard[] : [];
      this.cards = raw.map((card: PlantCard) => this.normalize(card));
    } catch { this.errorText = '无法读取本机交接板。请重试；不会影响外部服务。'; }
    finally { this.loading = false; }
  }
  private async save(): Promise<void> {
    if (!this.ready() || this.loading) { return; }
    const card: PlantCard = { id: Date.now(), name: this.name.trim(), room: this.room.trim(), task: this.task.trim(), carer: this.carer.trim(), confirmed: false, completed: false, completedAt: '', completionNote: '' };
    this.loading = true; this.errorText = '';
    if (await this.persist([card, ...this.cards])) { this.name = ''; this.room = ''; this.task = ''; this.carer = ''; }
    else { this.errorText = '无法保存本机任务。请保留填写内容后重试；未推定任务已完成。'; }
    this.loading = false;
  }
  private updateCard(card: PlantCard, confirmed: boolean, completed: boolean, completedAt: string, completionNote: string): PlantCard {
    return { id: card.id, name: card.name, room: card.room, task: card.task, carer: card.carer, confirmed: confirmed, completed: completed, completedAt: completedAt, completionNote: completionNote };
  }
  private async confirm(card: PlantCard): Promise<void> {
    if (this.loading || card.confirmed === true) { return; }
    this.loading = true; this.errorText = ''; this.retryCardId = 0; this.retryKind = '';
    const next = this.cards.map((item: PlantCard) => item.id === card.id ? this.updateCard(item, true, false, '', '') : item);
    if (!(await this.persist(next))) { this.retryCardId = card.id; this.retryKind = 'confirm'; this.errorText = '无法确认本机交接任务。请再次确认；未推定任务已完成。'; }
    this.loading = false;
  }
  private beginComplete(card: PlantCard): void {
    this.completingCardId = card.id; this.exportCardId = 0; this.retryCardId = 0; this.retryKind = ''; this.errorText = '';
    this.completionDate = ''; this.completionNote = '';
  }
  private cancelComplete(): void { this.completingCardId = 0; this.retryCardId = 0; this.retryKind = ''; this.completionDate = ''; this.completionNote = ''; }
  private async complete(card: PlantCard): Promise<void> {
    if (!this.readyToComplete() || this.loading || card.completed === true) { return; }
    this.loading = true; this.errorText = ''; this.retryCardId = 0; this.retryKind = '';
    const next = this.cards.map((item: PlantCard) => item.id === card.id ? this.updateCard(item, true, true, this.completionDate.trim(), this.completionNote.trim()) : item);
    if (await this.persist(next)) { this.cancelComplete(); }
    else { this.retryCardId = card.id; this.retryKind = 'complete'; this.errorText = '无法保存本机完成信息。输入仍保留，可再次保存；未推定任务已完成。'; }
    this.loading = false;
  }
  private retry(card: PlantCard): void { if (this.retryKind === 'confirm') { this.confirm(card); } else if (this.retryKind === 'complete') { this.complete(card); } }
  private beginExportSelection(card: PlantCard): void {
    this.exportCardId = card.id; this.completingCardId = 0;
    this.includePlantName = true; this.includeRoom = card.room.length > 0; this.includeTask = true;
    this.includeCarer = false; this.includeConfirmation = true;
    this.includeCompletionTime = card.completed === true; this.includeCompletionNote = false;
  }
  private cancelExportSelection(): void { this.exportCardId = 0; }

  @Builder
  private completionPanel(card: PlantCard) {
    if (this.completingCardId === card.id && card.completed !== true) {
      Column({ space: 8 }) {
        Text('保存完成信息').fontSize(16).fontWeight(FontWeight.Medium)
        Text('完成时间必填，备注可选；只保存在本机。').fontSize(13)
        TextInput({ placeholder: '完成时间，例如 今天 18:30（必填）', text: this.completionDate }).onChange((value: string) => this.completionDate = value)
        TextInput({ placeholder: '完成备注（可选）', text: this.completionNote }).onChange((value: string) => this.completionNote = value)
        if (!this.readyToComplete()) { Text('填写完成时间后即可标记完成。').fontSize(13) }
        Button(this.retryCardId === card.id && this.retryKind === 'complete' ? '再次保存完成信息' : '标记已完成').width('100%').constraintSize({ minHeight: 48 }).enabled(this.readyToComplete() && !this.loading).accessibilityText('保存本机任务完成时间和备注').onClick(() => this.complete(card))
        Button('取消完成记录').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText('取消完成记录，不保存输入').onClick(() => this.cancelComplete())
      }.padding(12).backgroundColor($r('app.color.surface_card')).borderRadius(12).width('100%')
    }
  }

  @Builder
  private exportFieldPanel(card: PlantCard) {
    if (this.exportCardId === card.id) {
      Column({ space: 8 }) {
        Text('选择本地摘要字段').fontSize(16).fontWeight(FontWeight.Medium)
        Text('这里只预览，不会导出、发送或保存你的选择。照护人昵称和备注默认隐藏。').fontSize(13)
        Button(`植物昵称 · ${this.includePlantName ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includePlantName = !this.includePlantName)
        if (card.room.length > 0) { Button(`房间 · ${this.includeRoom ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeRoom = !this.includeRoom) }
        Button(`交接任务 · ${this.includeTask ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeTask = !this.includeTask)
        Button(`照护人昵称 · ${this.includeCarer ? '已包含' : '默认隐藏'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeCarer = !this.includeCarer)
        Button(`确认状态 · ${this.includeConfirmation ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeConfirmation = !this.includeConfirmation)
        if (card.completed === true) { Button(`完成时间 · ${this.includeCompletionTime ? '已包含' : '已移除'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeCompletionTime = !this.includeCompletionTime) }
        if ((card.completionNote ?? '').length > 0) { Button(`完成备注 · ${this.includeCompletionNote ? '已包含' : '默认隐藏'}`).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).onClick(() => this.includeCompletionNote = !this.includeCompletionNote) }
        if (!this.includePlantName && !this.includeRoom && !this.includeTask && !this.includeCarer && !this.includeConfirmation && !this.includeCompletionTime && !this.includeCompletionNote) { Text('请保留至少一个字段，才能形成摘要。').fontSize(13) }
        else {
          Text(`${this.includePlantName ? `植物昵称：${card.name}\n` : ''}${this.includeRoom && card.room.length > 0 ? `房间：${card.room}\n` : ''}${this.includeTask ? `交接任务：${card.task}\n` : ''}${this.includeCarer ? `照护人昵称：${card.carer}\n` : ''}${this.includeConfirmation ? `确认状态：${card.confirmed === true ? '已确认' : '未确认'}\n` : ''}${this.includeCompletionTime && card.completed === true ? `完成时间：${card.completedAt ?? ''}\n` : ''}${this.includeCompletionNote && (card.completionNote ?? '').length > 0 ? `完成备注：${card.completionNote}` : ''}`.trim()).fontSize(14)
          Text('此摘要仅在本地预览，未生成导出或发送内容。').fontSize(13)
        }
        Button('取消字段选择').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText('取消本地摘要字段选择，不导出或发送任何数据').onClick(() => this.cancelExportSelection())
      }.padding(12).backgroundColor($r('app.color.surface_card')).borderRadius(12).width('100%')
    }
  }

  @Builder
  private taskState(card: PlantCard) {
    if (card.completed === true) {
      Text(`已完成 · ${card.completedAt ?? ''}`).fontSize(13)
      if ((card.completionNote ?? '').length > 0) { Text(`备注：${card.completionNote}`).fontSize(13) }
    } else if (card.confirmed === true) {
      Text('已确认 · 待完成').fontSize(13)
      Button(this.completingCardId === card.id ? '收起完成信息' : '填写完成信息').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText(`为${card.name}填写本机完成信息`).onClick(() => this.completingCardId === card.id ? this.cancelComplete() : this.beginComplete(card))
      this.completionPanel(card)
    } else {
      Text('未确认 · 未推定已完成').fontSize(13)
      Button(this.retryCardId === card.id && this.retryKind === 'confirm' ? '再次确认任务' : '确认已接手').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText(`确认已接手${card.name}的本机交接任务`).enabled(!this.loading).onClick(() => this.confirm(card))
    }
  }

  build() {
    Scroll() { Column({ space: 16 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text('叶伴').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).lineHeight(34)
          Text('本地植物照护交接板').fontSize(17).fontColor($r('app.color.text_secondary')).lineHeight(24)
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('非诊断')
          .fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.surface_notice')).borderRadius(8)
          .accessibilityText('不识别、不诊断、不提供建议')
      }.width('100%').alignItems(VerticalAlign.Top)
      Column({ space: 6 }) {
        Text('仅记录交接 · 不识别、不诊断、不提供建议').fontSize(16)
        Text('本切片保存植物任务的确认与完成信息；照片、提醒、导出与跨设备同步尚未实现。').fontSize(14)
      }.padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text('安排下一件事').fontSize(20).fontWeight(FontWeight.Bold)
        TextInput({ placeholder: '植物昵称（必填）', text: this.name }).onChange((value: string) => this.name = value)
        TextInput({ placeholder: '房间（可选）', text: this.room }).onChange((value: string) => this.room = value)
        TextInput({ placeholder: '用户自定任务（必填）', text: this.task }).onChange((value: string) => this.task = value)
        TextInput({ placeholder: '照护人昵称（必填）', text: this.carer }).onChange((value: string) => this.carer = value)
        if (!this.ready()) { Text('填写昵称、任务和照护人后即可安排。').fontSize(14) }
        Button('保存本机交接任务').width('100%').constraintSize({ minHeight: 52 }).enabled(this.ready() && !this.loading).accessibilityText('保存仅在本机保留的植物交接任务').onClick(() => this.save())
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      if (this.errorText.length > 0) { Column({ space: 8 }) { Text(this.errorText); Button('重试读取本机交接板').onClick(() => this.load()) }.padding(16).backgroundColor($r('app.color.surface_warning')).borderRadius(16).width('100%') }
      Column({ space: 10 }) {
        Text('植物交接任务').fontSize(20).fontWeight(FontWeight.Bold)
        if (this.loading) { Text('正在读取或保存本机任务…') }
        else if (this.cards.length === 0) { Text('还没有任务。创建第一盆植物的交接卡即可开始。') }
        else {
          if (this.cardCount(false) === 0) { Text('当前没有未确认任务。').fontSize(14) }
          if (this.cardCount(true) === 0) { Text('尚无已完成任务。').fontSize(14) }
          ForEach(this.cards, (card: PlantCard) => { Column({ space: 5 }) {
            Text(`${card.name}${card.room.length > 0 ? ` · ${card.room}` : ''}`).fontSize(17).fontWeight(FontWeight.Medium)
            Text(`${card.task} · 归 ${card.carer}`).fontSize(14)
            this.taskState(card)
            Button(this.exportCardId === card.id ? '取消摘要字段选择' : '选择导出前字段').backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText(`为${card.name}选择本地摘要字段，不会导出或发送`).onClick(() => this.exportCardId === card.id ? this.cancelExportSelection() : this.beginExportSelection(card))
            this.exportFieldPanel(card)
          }.padding(16).backgroundColor(card.completed === true ? $r('app.color.surface_notice') : $r('app.color.surface_card')).borderRadius(16).width('100%') }, (card: PlantCard) => card.id.toString())
        }
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
    }.padding(20).width('100%') }.width('100%').height('100%')
  }
}
