import { VisitCard, VisitCardStore } from '../data/VisitCardStore';

@Entry
@Component
struct Index {
  private readonly cardStore: VisitCardStore = new VisitCardStore();
  @State private cards: VisitCard[] = [];
  @State private placeName: string = '';
  @State private visitTime: string = '';
  @State private addressText: string = '';
  @State private companionName: string = '';
  @State private checklist: string = '';
  @State private needs: string = '';
  @State private avoids: string = '';
  @State private leavingPlan: string = '';
  @State private reminderDate: string = '';
  @State private isLoading: boolean = true;
  @State private errorText: string = '';
  @State private editingCardId: number = 0;
  @State private previewCardId: number = 0;
  @State private sharingCardId: number = 0;
  @State private includePlaceName: boolean = true;
  @State private includeVisitTime: boolean = true;
  @State private includeCompanionName: boolean = true;
  @State private includeChecklist: boolean = true;
  @State private includeAddressText: boolean = false;
  @State private includeNeeds: boolean = false;
  @State private includeAvoids: boolean = false;
  @State private includeLeavingPlan: boolean = false;

  aboutToAppear(): void { this.loadCards(); }
  private context(): Context { return getContext(this); }
  private canSave(): boolean { return this.placeName.trim().length > 0 && this.visitTime.trim().length > 0 && this.checklist.trim().length > 0; }
  private async loadCards(): Promise<void> {
    this.isLoading = true; this.errorText = '';
    try { this.cards = await this.cardStore.load(this.context()); } catch { this.errorText = '无法读取本机预访卡。请重试；不会影响任何外部服务。'; }
    finally { this.isLoading = false; }
  }
  private async saveCard(): Promise<void> {
    if (!this.canSave() || this.isLoading) { return; }
    const card: VisitCard = { id: Date.now(), placeName: this.placeName.trim(), visitTime: this.visitTime.trim(), addressText: this.addressText.trim(), companionName: this.companionName.trim(), checklist: this.checklist.trim(), needs: this.needs.trim(), avoids: this.avoids.trim(), leavingPlan: this.leavingPlan.trim(), reminderDate: this.reminderDate.trim() };
    this.isLoading = true; this.errorText = '';
    try {
      const updated: VisitCard[] = this.editingCardId === 0 ? [card, ...this.cards] : this.cards.map((item: VisitCard) => item.id === this.editingCardId ? { id: item.id, placeName: card.placeName, visitTime: card.visitTime, addressText: card.addressText, companionName: card.companionName, checklist: card.checklist, needs: card.needs, avoids: card.avoids, leavingPlan: card.leavingPlan, reminderDate: card.reminderDate } : item);
      await this.cardStore.save(this.context(), updated); this.cards = updated; this.placeName = ''; this.visitTime = ''; this.addressText = ''; this.companionName = ''; this.checklist = ''; this.needs = ''; this.avoids = ''; this.leavingPlan = ''; this.reminderDate = ''; this.editingCardId = 0;
    }
    catch { this.errorText = '无法保存本机预访卡。请重试；本应用没有上传任何数据。'; }
    finally { this.isLoading = false; }
  }
  private async deleteCard(id: number): Promise<void> {
    this.isLoading = true; this.errorText = '';
    try { const updated = this.cards.filter((card: VisitCard) => card.id !== id); await this.cardStore.save(this.context(), updated); this.cards = updated; if (this.editingCardId === id) { this.cancelEdit(); } if (this.previewCardId === id) { this.previewCardId = 0; } if (this.sharingCardId === id) { this.cancelShareSelection(); } }
    catch { this.errorText = '无法删除本机预访卡。请重试；本应用没有上传任何数据。'; }
    finally { this.isLoading = false; }
  }
  private beginEdit(card: VisitCard): void { this.editingCardId = card.id; this.previewCardId = 0; this.sharingCardId = 0; this.placeName = card.placeName; this.visitTime = card.visitTime; this.addressText = card.addressText ?? ''; this.companionName = card.companionName; this.checklist = card.checklist; this.needs = card.needs ?? ''; this.avoids = card.avoids ?? ''; this.leavingPlan = card.leavingPlan ?? ''; this.reminderDate = card.reminderDate ?? ''; }
  private cancelEdit(): void { this.editingCardId = 0; this.placeName = ''; this.visitTime = ''; this.addressText = ''; this.companionName = ''; this.checklist = ''; this.needs = ''; this.avoids = ''; this.leavingPlan = ''; this.reminderDate = ''; }
  private beginShareSelection(card: VisitCard): void {
    this.sharingCardId = card.id; this.previewCardId = 0;
    this.includePlaceName = true; this.includeVisitTime = true;
    this.includeCompanionName = card.companionName.length > 0; this.includeChecklist = true;
    this.includeAddressText = false; this.includeNeeds = false;
    this.includeAvoids = false; this.includeLeavingPlan = false;
  }
  private cancelShareSelection(): void { this.sharingCardId = 0; }

  @Builder
  private reminderStatus(card: VisitCard) {
    Column({ space: 3 }) {
      if ((card.reminderDate ?? '').length > 0) {
        Text(`本地提醒日期：${card.reminderDate}`).fontSize(13).fontColor($r('app.color.text_secondary'))
        Text('未创建系统提醒；通知未接入或被拒绝时，仍请以此日期自行安排。').fontSize(13).fontColor($r('app.color.text_warning'))
      } else {
        Text('尚未填写本地提醒日期 · 未创建系统提醒。').fontSize(13).fontColor($r('app.color.text_warning'))
      }
    }.padding(10).backgroundColor($r('app.color.surface_warning')).borderRadius(12).width('100%')
  }

  @Builder
  private shareFieldPanel(card: VisitCard) {
    if (this.sharingCardId === card.id) {
      Column({ space: 8 }) {
        Text('选择本地摘要字段').fontSize(15).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
        Text('这里只准备本地摘要；系统分享尚未接入，不会发送数据。').fontSize(13).fontColor($r('app.color.text_warning'))
        Button(`场所昵称 · ${this.includePlaceName ? '已包含' : '已移除'}`).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.includePlaceName = !this.includePlaceName)
        Button(`访问时间 · ${this.includeVisitTime ? '已包含' : '已移除'}`).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.includeVisitTime = !this.includeVisitTime)
        if ((card.addressText ?? '').length > 0) { Button(`地址文本 · ${this.includeAddressText ? '已包含' : '默认隐藏'}`).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.includeAddressText = !this.includeAddressText) }
        if (card.companionName.length > 0) { Button(`同行人昵称 · ${this.includeCompanionName ? '已包含' : '已移除'}`).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.includeCompanionName = !this.includeCompanionName) }
        Button(`准备清单 · ${this.includeChecklist ? '已包含' : '已移除'}`).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.includeChecklist = !this.includeChecklist)
        if ((card.needs ?? '').length > 0) { Button(`我需要 · ${this.includeNeeds ? '已包含' : '默认隐藏'}`).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.includeNeeds = !this.includeNeeds) }
        if ((card.avoids ?? '').length > 0) { Button(`我避免 · ${this.includeAvoids ? '已包含' : '默认隐藏'}`).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.includeAvoids = !this.includeAvoids) }
        if ((card.leavingPlan ?? '').length > 0) { Button(`离开计划 · ${this.includeLeavingPlan ? '已包含' : '默认隐藏'}`).fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.includeLeavingPlan = !this.includeLeavingPlan) }
        if (!this.includePlaceName && !this.includeVisitTime && !this.includeAddressText && !this.includeCompanionName && !this.includeChecklist && !this.includeNeeds && !this.includeAvoids && !this.includeLeavingPlan) { Text('请保留至少一个字段，才能形成摘要。').fontSize(13).fontColor($r('app.color.text_warning')) }
        else { Text(`${this.includePlaceName ? `场所昵称：${card.placeName}\n` : ''}${this.includeVisitTime ? `访问时间：${card.visitTime}\n` : ''}${this.includeAddressText && (card.addressText ?? '').length > 0 ? `地址文本：${card.addressText}\n` : ''}${this.includeCompanionName && card.companionName.length > 0 ? `同行人：${card.companionName}\n` : ''}${this.includeChecklist ? `准备清单：${card.checklist}\n` : ''}${this.includeNeeds && (card.needs ?? '').length > 0 ? `我需要：${card.needs}\n` : ''}${this.includeAvoids && (card.avoids ?? '').length > 0 ? `我避免：${card.avoids}\n` : ''}${this.includeLeavingPlan && (card.leavingPlan ?? '').length > 0 ? `离开时我会做什么：${card.leavingPlan}` : ''}`.trim()).fontSize(14).fontColor($r('app.color.text_secondary')) }
        Button('取消并返回只读摘要').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).accessibilityText('取消本地摘要字段选择，不发送任何数据').onClick(() => this.cancelShareSelection())
      }.padding(12).backgroundColor($r('app.color.surface_card')).borderRadius(12).width('100%')
    }
  }
  build() {
    Scroll() { Column({ space: 16 }) {
      Text('从容赴约').fontSize(30).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('离线准备一张只属于自己的访问卡').fontSize(17).fontColor($r('app.color.text_secondary'))
      Column({ space: 6 }) {
        Text('私密准备 · 非认证或医疗服务').fontSize(17).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_warning'))
        Text('地址仅作本地文本保存，不请求定位。可保存本地提醒日期，但不会创建系统提醒；附件和系统分享尚未接入。').fontSize(14).fontColor($r('app.color.text_secondary'))
      }.padding(16).backgroundColor($r('app.color.surface_warning')).borderRadius(18).width('100%')
      Column({ space: 10 }) {
        Text(this.editingCardId === 0 ? '新建预访卡' : '编辑本机预访卡').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        TextInput({ placeholder: '场所昵称（必填）', text: this.placeName }).onChange((value: string) => this.placeName = value)
        TextInput({ placeholder: '访问时间，例如 周六 14:00（必填）', text: this.visitTime }).onChange((value: string) => this.visitTime = value)
        TextInput({ placeholder: '地址文本（可选，不请求定位）', text: this.addressText }).onChange((value: string) => this.addressText = value)
        TextInput({ placeholder: '同行人昵称（可选）', text: this.companionName }).onChange((value: string) => this.companionName = value)
        TextInput({ placeholder: '准备清单（必填）', text: this.checklist }).onChange((value: string) => this.checklist = value)
        TextInput({ placeholder: '我需要（可选）', text: this.needs }).onChange((value: string) => this.needs = value)
        TextInput({ placeholder: '我避免（可选）', text: this.avoids }).onChange((value: string) => this.avoids = value)
        TextInput({ placeholder: '离开时我会做什么（可选）', text: this.leavingPlan }).onChange((value: string) => this.leavingPlan = value)
        TextInput({ placeholder: '本地提醒日期（可选，例如 周六 12:00）', text: this.reminderDate }).onChange((value: string) => this.reminderDate = value)
        if (!this.canSave()) { Text('填写场所昵称、访问时间和准备清单后即可保存。').fontSize(14).fontColor($r('app.color.text_secondary')) }
        Button(this.editingCardId === 0 ? '保存本机预访卡' : '保存修改').width('100%').constraintSize({ minHeight: 52 }).backgroundColor($r('app.color.action_primary')).fontColor($r('app.color.text_on_primary')).borderRadius(14).enabled(this.canSave() && !this.isLoading).accessibilityText(this.editingCardId === 0 ? '保存仅在本机保留的预访卡' : '保存对本机预访卡的修改').onClick(() => this.saveCard())
        if (this.editingCardId !== 0) { Button('取消编辑').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).accessibilityText('取消编辑并恢复新建预访卡表单').onClick(() => this.cancelEdit()) }
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
      if (this.errorText.length > 0) { Column({ space: 8 }) { Text(this.errorText).fontSize(14).fontColor($r('app.color.text_warning')); Button('重试读取本机预访卡').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).onClick(() => this.loadCards()) }.padding(16).backgroundColor($r('app.color.surface_warning')).borderRadius(16).width('100%') }
      Column({ space: 10 }) {
        Text('我的预访卡').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        if (this.isLoading) { Text('正在读取本机预访卡…').fontSize(15).fontColor($r('app.color.text_secondary')) }
        else if (this.cards.length === 0) { Text('尚无预访卡。通知关闭或附件取消时，本机保存仍可继续使用。').fontSize(15).fontColor($r('app.color.text_secondary')) }
        else { ForEach(this.cards, (card: VisitCard) => { Column({ space: 5 }) { Text(card.placeName).fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')); Text(`${card.visitTime}${card.companionName.length > 0 ? ` · 同行：${card.companionName}` : ''}`).fontSize(14).fontColor($r('app.color.text_secondary')); Text(`准备：${card.checklist}`).fontSize(14).fontColor($r('app.color.text_secondary')); Text('仅本机保存 · 未发送或分享').fontSize(13).fontColor($r('app.color.text_success')); this.reminderStatus(card); Button(this.previewCardId === card.id ? '收起只读摘要' : '查看只读摘要').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).accessibilityText(`查看${card.placeName}的只读摘要`).onClick(() => this.previewCardId = this.previewCardId === card.id ? 0 : card.id); if (this.previewCardId === card.id) { Column({ space: 4 }) { Text('分享前只读摘要').fontSize(15).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')); Text(`场所昵称：${card.placeName}\n访问时间：${card.visitTime}\n地址文本：${(card.addressText ?? '').length > 0 ? card.addressText : '未填写'}\n同行人：${card.companionName.length > 0 ? card.companionName : '未填写'}\n准备清单：${card.checklist}\n我需要：${(card.needs ?? '').length > 0 ? card.needs : '未填写'}\n我避免：${(card.avoids ?? '').length > 0 ? card.avoids : '未填写'}\n离开时我会做什么：${(card.leavingPlan ?? '').length > 0 ? card.leavingPlan : '未填写'}`).fontSize(14).fontColor($r('app.color.text_secondary')); Text('系统分享尚未接入；本摘要没有发送给任何人。').fontSize(13).fontColor($r('app.color.text_warning')) }.padding(12).backgroundColor($r('app.color.surface_card')).borderRadius(12).width('100%') } Button(this.sharingCardId === card.id ? '取消摘要字段选择' : '选择分享前字段').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).accessibilityText(`为${card.placeName}选择本地摘要字段，不会发送数据`).onClick(() => this.sharingCardId === card.id ? this.cancelShareSelection() : this.beginShareSelection(card)); this.shareFieldPanel(card); Button('编辑这张预访卡').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).accessibilityText(`编辑${card.placeName}的本机预访卡`).onClick(() => this.beginEdit(card)); Button('删除这张预访卡').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent).accessibilityText(`删除${card.placeName}的本机预访卡`).onClick(() => this.deleteCard(card.id)) }.padding(16).backgroundColor($r('app.color.surface_success')).borderRadius(16).width('100%') }, (card: VisitCard) => card.id.toString()) }
      }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')
    }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%') }.width('100%').height('100%').backgroundColor($r('app.color.surface_canvas'))
  }
}
