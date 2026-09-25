import { pasteboard } from '@kit.BasicServicesKit';
import { LocalRepository } from '../repositories/LocalRepository';
import { Contact, RequestItem, LocalData, RequestStatus, Template, TEMPLATES, emptyRequest, statusLabel,
  timeRange, validateRequest, canTransition, requestMessage } from '../models/RequestDomain';

@Entry
@Component
struct Index {
  @State @Watch('pageChanged') private page: string = 'home';
  @State private requests: RequestItem[] = [];
  @State private contacts: Contact[] = [];
  @State private filter: string = '全部';
  @State private selected: RequestItem = emptyRequest();
  @State private editId: string = '';
  @State private title: string = '';
  @State private contactId: string = '';
  @State private contactName: string = '';
  @State private date: string = '';
  @State private time: string = '';
  @State private task: string = '';
  @State private note: string = '';
  @State private contactEditId: string = '';
  @State private nameInput: string = '';
  @State private relationInput: string = '';
  @State private error: string = '';
  @State private ready: boolean = false;
  @State private busy: boolean = false;
  private baseline: string = '';
  private repo: LocalRepository = new LocalRepository();
  private contactReturn: string = 'home';
  private scroller: Scroller = new Scroller();
  private pageChanged(): void { this.scroller.scrollTo({ xOffset: 0, yOffset: 0 }); }

  aboutToAppear(): void { this.load(); }
  private load(): void {
    try {
      const context = this.getUIContext().getHostContext();
      if (!context) throw new Error('No context');
      const data = this.repo.load(context.filesDir);
      this.requests = data.requests;
      this.contacts = data.contacts;
      this.ready = true;
      this.error = '';
    } catch (_) {
      this.ready = false;
      this.error = '本机数据读取失败，暂时不能保存。请重试；原文件已保留。';
    }
  }
  private toast(text: string): void { this.getUIContext().getPromptAction().showToast({ message: text }); }
  private commit(requests: RequestItem[], contacts: Contact[]): boolean {
    if (!this.ready || this.busy) return false;
    this.busy = true;
    try {
      const data: LocalData = { version: 1, requests: requests, contacts: contacts };
      this.repo.save(data);
      this.requests = requests;
      this.contacts = contacts;
      this.error = '';
      return true;
    } catch (_) {
      this.error = '保存失败，请检查设备存储空间后重试。你的输入仍保留在页面中。';
      return false;
    } finally { this.busy = false; }
  }
  private formKey(): string { return JSON.stringify([this.title, this.contactId, this.contactName, this.date, this.time, this.task, this.note]); }
  private beginEdit(item: RequestItem): void {
    this.editId = item.id;
    this.title = item.title;
    this.contactId = item.contactId;
    this.contactName = item.contactName;
    this.date = item.date;
    this.time = item.time;
    this.task = item.task;
    this.note = item.note;
    this.error = '';
    this.baseline = this.formKey();
    this.page = 'form';
  }
  private formItem(): RequestItem {
    const previous = this.requests.find((item: RequestItem) => item.id === this.editId);
    const now = Date.now();
    return { id: this.editId || `r-${now}-${Math.floor(Math.random() * 1000000)}`, title: this.title.trim(),
      contactId: this.contactId, contactName: this.contactName.trim(), date: this.date.trim(), time: this.time.trim(),
      task: this.task.trim(), note: this.note.trim(), status: 'draft', createdAt: previous ? previous.createdAt : now, updatedAt: now };
  }
  private saveRequest(complete: boolean): void {
    if (this.page !== 'form' || this.busy) return;
    const item = this.formItem();
    this.error = validateRequest(item, complete);
    if (this.error) return;
    if (this.commit([item, ...this.requests.filter((r: RequestItem) => r.id !== item.id)], this.contacts)) {
      this.selected = item;
      this.page = 'detail';
      this.toast(complete ? '请求已保存，可以复制给亲友' : '草稿已保存到本机');
    }
  }
  private back(): void {
    if (this.busy) return;
    if (this.page === 'form' && this.formKey() !== this.baseline) {
      AlertDialog.show({ title: '放弃未保存的修改？', message: '已保存的记录不会受影响。',
        primaryButton: { value: '继续编辑', action: () => {} },
        secondaryButton: { value: '放弃修改', action: () => { this.error = ''; this.page = 'home'; } } });
      return;
    }
    if (this.page === 'contacts' && (this.nameInput || this.relationInput)) {
      AlertDialog.show({ title: '放弃联系人修改？', message: '联系人尚未保存。',
        primaryButton: { value: '继续编辑', action: () => {} },
        secondaryButton: { value: '放弃修改', action: () => { this.clearContact(); this.page = this.contactReturn; this.error = ''; } } });
      return;
    }
    this.error = '';
    this.page = this.page === 'contacts' ? this.contactReturn : 'home';
  }
  onBackPress(): boolean {
    if (this.page !== 'home') { this.back(); return true; }
    return false;
  }
  private clearContact(): void { this.contactEditId = ''; this.nameInput = ''; this.relationInput = ''; }
  private openContacts(): void { this.contactReturn = this.page; this.clearContact(); this.error = ''; this.page = 'contacts'; }
  private saveContact(): void {
    const name = this.nameInput.trim();
    if (!name) { this.error = '请填写联系人称呼'; return; }
    const c: Contact = { id: this.contactEditId || `c-${Date.now()}`, name: name, relation: this.relationInput.trim() };
    if (this.commit(this.requests, [c, ...this.contacts.filter((item: Contact) => item.id !== c.id)])) {
      if (this.contactReturn === 'form') { this.contactId = c.id; this.contactName = c.name; }
      this.clearContact(); this.toast('联系人已保存');
    }
  }
  private deleteContact(contact: Contact): void {
    AlertDialog.show({ title: `删除“${contact.name}”？`, message: '已保存请求中的联系人称呼会保留。',
      primaryButton: { value: '保留', action: () => {} }, secondaryButton: { value: '删除', action: () => {
        if (this.commit(this.requests, this.contacts.filter((c: Contact) => c.id !== contact.id))) {
          if (this.contactEditId === contact.id) this.clearContact();
          this.toast('联系人已删除');
        }
      } } });
  }
  private deleteRequest(): void {
    AlertDialog.show({ title: '删除这条请求？', message: '删除后无法恢复，也不会撤回你已发给亲友的消息。',
      primaryButton: { value: '保留', action: () => {} }, secondaryButton: { value: '删除', action: () => {
        if (this.commit(this.requests.filter((r: RequestItem) => r.id !== this.selected.id), this.contacts)) {
          this.page = 'home'; this.toast('记录已删除');
        }
      } } });
  }
  private changeStatus(status: RequestStatus): void {
    if (!canTransition(this.selected.status, status)) return;
    if (status === 'pending') { this.error = validateRequest(this.selected, true); if (this.error) return; }
    AlertDialog.show({ title: `标记为${statusLabel(status)}？`, message: status === 'pending' ? '请确认你已自行发送给亲友。应用不会代发消息。' : '这是你手动记录的结果，不会通知对方；时间变更或取消请另行沟通。',
      primaryButton: { value: '返回', action: () => {} }, secondaryButton: { value: '确认', action: () => {
        const next = JSON.parse(JSON.stringify(this.selected)) as RequestItem;
        next.status = status;
        next.updatedAt = Date.now();
        if (this.commit(this.requests.map((r: RequestItem) => r.id === next.id ? next : r), this.contacts)) {
          this.selected = next; this.toast('状态已保存');
        }
      } } });
  }
  private async copyRequest(): Promise<void> {
    if (this.busy) return;
    this.error = validateRequest(this.selected, true);
    if (this.error) return;
    this.busy = true;
    try {
      await pasteboard.getSystemPasteboard().setData(pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, requestMessage(this.selected)));
      this.toast('文案已复制，请到聊天应用粘贴发送');
    } catch (_) { this.error = '复制失败，请重试；也可以长按文案选择复制。'; }
    finally { this.busy = false; }
  }
  private filtered(): RequestItem[] {
    return this.requests.filter((r: RequestItem) => this.filter === '全部' ||
      (this.filter === '进行中' && (r.status === 'pending' || r.status === 'accepted')) ||
      (this.filter === '草稿' && r.status === 'draft') ||
      (this.filter === '已结束' && (r.status === 'done' || r.status === 'cancelled' || r.status === 'deferred')))
      .sort((a: RequestItem, b: RequestItem) => b.updatedAt - a.updatedAt);
  }
  build() {
    Column() {
      Row() {
        if (this.page !== 'home') { Button('返回').onClick(() => this.back()).backgroundColor('#E6F1EE').fontColor('#155E56') }
        Text(this.page === 'home' ? '喘息半小时' : this.page === 'form' ? '整理一条请求' : this.page === 'contacts' ? '可信联系人' : '请求详情')
          .fontSize(22).fontWeight(FontWeight.Bold).fontColor('#193D37').layoutWeight(1).margin({ left: this.page === 'home' ? 0 : 12 })
      }.width('100%').padding({ left: 20, right: 20, top: 16, bottom: 12 })
      if (this.error) { Text(this.error).fontSize(15).fontColor('#9C352D').width('100%').padding(12).backgroundColor('#FFF0ED') }
      if (!this.ready) {
        Column({ space: 20 }) { Text('正在准备本机数据').fontSize(18); Button('重新读取').onClick(() => this.load()) }.padding(32)
      } else {
        Scroll(this.scroller) {
          Column({ space: 18 }) {
            if (this.page === 'home') { this.Home() }
            else if (this.page === 'form') { this.Form() }
            else if (this.page === 'contacts') { this.Contacts() }
            else { this.Detail() }
          }.width('100%').padding({ left: 20, right: 20, top: 8, bottom: 36 })
        }.layoutWeight(1).width('100%').align(Alignment.Top).scrollBar(BarState.Auto)
      }
    }.width('100%').height('100%').backgroundColor('#F5F7F3')
  }
  @Builder
  Action(label: string, action: () => void, primary: boolean = false) {
    Button(label).width('100%').height(48).fontSize(17).fontWeight(FontWeight.Medium)
      .backgroundColor(primary ? '#16685C' : '#E5EDE7').fontColor(primary ? '#FFFFFF' : '#193D37')
      .borderRadius(14).enabled(!this.busy).onClick(action)
  }
  @Builder
  Label(text: string) { Text(text).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#193D37').width('100%') }
  @Builder
  Home() {
    Column({ space: 10 }) {
      Text('留半小时，给自己').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#193D37').width('100%')
      Text('把需要的帮助说清楚，和可信亲友约好一段短暂的替班时间。').fontSize(16).lineHeight(25).fontColor('#597068')
      this.Action('创建半小时请求', () => this.beginEdit(emptyRequest()), true)
    }.padding(20).backgroundColor('#E5EFE6').borderRadius(22)
    this.Action(`管理联系人 · ${this.contacts.length}人`, () => this.openContacts())
    Row({ space: 6 }) {
      ForEach(['全部', '草稿', '进行中', '已结束'], (f: string) => {
        Button(f).layoutWeight(1).fontSize(14).height(38).backgroundColor(this.filter === f ? '#16685C' : '#FFFFFF')
          .fontColor(this.filter === f ? '#FFFFFF' : '#466157').onClick(() => { this.filter = f; })
      })
    }.width('100%')
    if (this.filtered().length === 0) {
      Column({ space: 10 }) {
        Text(this.requests.length === 0 ? '从第一条请求开始' : '这里还没有记录').fontSize(20).fontWeight(FontWeight.Medium)
        Text(this.requests.length === 0 ? '可以先保存为草稿，准备好了再发给亲友。' : '试试其他筛选，或创建一条新请求。').fontSize(15).fontColor('#597068')
      }.width('100%').padding(28).backgroundColor('#FFFFFF').borderRadius(18)
    }
    ForEach(this.filtered(), (item: RequestItem) => {
      Column({ space: 10 }) {
        Row() { Text(item.title).fontSize(19).fontWeight(FontWeight.Bold).layoutWeight(1); Text(statusLabel(item.status)).fontSize(14).fontColor('#16685C') }.width('100%')
        Text(item.contactName || '联系人待补充').fontSize(16).width('100%')
        Text(timeRange(item)).fontSize(14).fontColor('#597068').width('100%')
        Text(item.task || '事项待补充').fontSize(15).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
        Text('查看详情 ›').fontSize(14).fontColor('#16685C').width('100%')
      }.padding(18).backgroundColor('#FFFFFF').borderRadius(18).width('100%')
        .onClick(() => { this.selected = item; this.error = ''; this.page = 'detail'; })
    }, (item: RequestItem) => `${item.id}-${item.updatedAt}`)
    Text('数据仅保存在本机，卸载会清除。应用不会自动发送请求、获取对方回应或提供照护服务。').fontSize(13).lineHeight(20).fontColor('#64776E')
  }
  @Builder
  Form() {
    Text('约定30分钟，写清时间与事项。未填完也可以存草稿。').fontSize(15).fontColor('#597068').width('100%')
    this.Label('从一个模板开始')
    Row({ space: 6 }) {
      ForEach(TEMPLATES, (t: Template) => {
        Button(t.title).layoutWeight(1).fontSize(13).height(42).backgroundColor('#E5EDE7').fontColor('#193D37')
          .onClick(() => { this.title = t.title; this.task = t.task; })
      })
    }
    this.Label('请求标题')
    TextInput({ text: this.title, placeholder: '例如：短暂休息' }).maxLength(40).height(48).onChange((v: string) => { this.title = v; })
    this.Label(`联系人${this.contactName ? ' · 已选' + this.contactName : ''}`)
    if (this.contacts.length === 0) { Text('先添加一位可信亲友；也可稍后补充。').fontSize(15).width('100%').fontColor('#597068') }
    ForEach(this.contacts, (c: Contact) => {
      Button(`${this.contactId === c.id ? '✓ ' : ''}${c.name}${c.relation ? ' · ' + c.relation : ''}`)
        .width('100%').height(44).backgroundColor(this.contactId === c.id ? '#CDE7DC' : '#FFFFFF').fontColor('#193D37')
        .onClick(() => { this.contactId = c.id; this.contactName = c.name; })
    }, (c: Contact) => c.id + c.name)
    this.Action('添加 / 管理联系人', () => this.openContacts())
    this.Label('日期（YYYY-MM-DD）')
    TextInput({ text: this.date, placeholder: '2026-09-21' }).maxLength(10).height(48).onChange((v: string) => { this.date = v; })
    this.Label('开始时间（24小时制 HH:mm）')
    TextInput({ text: this.time, placeholder: '18:30' }).maxLength(5).height(48).onChange((v: string) => { this.time = v; })
    Text('约定时间：' + timeRange(this.formItem())).fontSize(14).fontColor('#16685C').width('100%')
    this.Label('需要帮忙的事项')
    TextArea({ text: this.task, placeholder: '只写需要对方帮忙的具体事项' }).maxLength(300).height(100).onChange((v: string) => { this.task = v; })
    this.Label('补充说明（选填）')
    TextArea({ text: this.note, placeholder: '例如：有情况请直接打我电话' }).maxLength(300).height(90).onChange((v: string) => { this.note = v; })
    this.Action('保存并预览请求', () => this.saveRequest(true), true)
    this.Action('先保存草稿', () => this.saveRequest(false))
  }
  @Builder
  Detail() {
    Column({ space: 14 }) {
      Text(statusLabel(this.selected.status)).fontColor('#16685C').fontSize(15).width('100%')
      Text(this.selected.title).fontSize(26).fontWeight(FontWeight.Bold).fontColor('#193D37').width('100%')
      Text('联系人：' + (this.selected.contactName || '待补充')).fontSize(17).width('100%')
      Text(timeRange(this.selected)).fontSize(16).fontColor('#597068').width('100%')
      Text(this.selected.task || '事项待补充').fontSize(17).lineHeight(26).width('100%')
      if (this.selected.note) { Text('补充：' + this.selected.note).fontSize(15).lineHeight(24).width('100%') }
      Text('更新于 ' + new Date(this.selected.updatedAt).toLocaleString()).fontSize(12).fontColor('#64776E').width('100%')
    }.padding(20).width('100%').backgroundColor('#FFFFFF').borderRadius(20)
    if (this.selected.status === 'draft' || this.selected.status === 'pending' || this.selected.status === 'accepted') {
      this.Label('发给亲友的文案')
      Text(requestMessage(this.selected)).fontSize(16).lineHeight(26).copyOption(CopyOptions.LocalDevice)
        .padding(16).width('100%').backgroundColor('#E5EFE6').borderRadius(14)
      this.Action('复制请求文案', () => { this.copyRequest(); }, true)
      Text('复制后请自行粘贴发送。状态均由你手动记录。').fontSize(13).fontColor('#597068').width('100%')
    }
    if (this.selected.status === 'draft' || this.selected.status === 'deferred') {
      this.Action(this.selected.status === 'deferred' ? '重新约时间（存为草稿）' : '继续编辑', () => this.beginEdit(this.selected))
    }
    if (this.selected.status === 'draft') { this.Action('我已发送，标记待回应', () => this.changeStatus('pending')) }
    if (this.selected.status === 'pending') { this.Action('对方已接受', () => this.changeStatus('accepted'), true) }
    if (this.selected.status === 'accepted') { this.Action('替班已完成', () => this.changeStatus('done'), true) }
    if (this.selected.status === 'pending' || this.selected.status === 'accepted') { this.Action('标记延期', () => this.changeStatus('deferred')) }
    if (this.selected.status === 'draft' || this.selected.status === 'pending' || this.selected.status === 'accepted') { this.Action('取消这次请求', () => this.changeStatus('cancelled')) }
    this.Action('删除记录', () => this.deleteRequest())
  }
  @Builder
  Contacts() {
    Text('记录你信任的亲友称呼，不读取手机通讯录。历史请求保留当时的称呼。').fontSize(15).lineHeight(24).fontColor('#597068')
    this.Label(this.contactEditId ? '编辑联系人' : '新增联系人')
    TextInput({ text: this.nameInput, placeholder: '称呼，例如：二姐' }).maxLength(24).height(48).onChange((v: string) => { this.nameInput = v; })
    TextInput({ text: this.relationInput, placeholder: '关系或说明（选填）' }).maxLength(40).height(48).onChange((v: string) => { this.relationInput = v; })
    this.Action('保存联系人', () => this.saveContact(), true)
    if (this.contactEditId) { this.Action('取消编辑', () => { this.clearContact(); this.error = ''; }) }
    this.Label(`已保存 ${this.contacts.length} 位联系人`)
    ForEach(this.contacts, (c: Contact) => {
      Column({ space: 12 }) {
        Text(c.name).fontSize(20).fontWeight(FontWeight.Medium).width('100%')
        if (c.relation) { Text(c.relation).fontSize(15).fontColor('#597068').width('100%') }
        Row({ space: 12 }) {
          Button('编辑').layoutWeight(1).onClick(() => { this.contactEditId = c.id; this.nameInput = c.name; this.relationInput = c.relation; })
          Button('删除').layoutWeight(1).backgroundColor('#F9E8E5').fontColor('#9C352D').onClick(() => this.deleteContact(c))
        }
      }.padding(18).backgroundColor('#FFFFFF').borderRadius(16).width('100%')
    }, (c: Contact) => c.id + c.name + c.relation)
  }
}
