import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { accessibility } from '@kit.AccessibilityKit';
import { ClayPlant } from '../components/ClayPlant';
import { PlantCard, parseCards, taskStatus, acceptCard, finishCard, recolorCard } from '../model/PlantCard';

@Entry
@Component
struct Index {
  @State private cards: PlantCard[] = [];
  @State private tab: number = 0;
  @State private filter: number = 0;
  @State private panel: string = '';
  @State private selectedId: number = 0;
  @State private panelCardId: number = 0;
  @State private name: string = '';
  @State private room: string = '';
  @State private task: string = '';
  @State private carer: string = '';
  @State private draftPalette: number = 0;
  @State private completionDate: string = '';
  @State private completionNote: string = '';
  @State private includePlantName: boolean = true;
  @State private includeRoom: boolean = false;
  @State private includeTask: boolean = true;
  @State private includeCarer: boolean = false;
  @State private includeConfirmation: boolean = true;
  @State private includeCompletionTime: boolean = false;
  @State private includeCompletionNote: boolean = false;
  @State private loading: boolean = true;
  @State private saving: boolean = false;
  @State private loadFailed: boolean = false;
  @State private errorText: string = '';
  @State private feedback: string = '';
  @State private celebration: boolean = false;
  @State private pulse: number = 0;
  @State private playCount: number = 0;
  @State private waitingAcceptCount: number = 0;
  @State private waitingCompleteCount: number = 0;
  @State private completedCount: number = 0;
  @State private reduceMotion: boolean = false;
  @State private systemReduceMotion: boolean = false;
  private scroll: Scroller = new Scroller();
  private motionListener = (enabled: boolean): void => { this.systemReduceMotion = enabled; };

  aboutToAppear(): void {
    this.load();
    try {
      this.systemReduceMotion = accessibility.isAnimationReduceEnabledSync();
      accessibility.onAnimationReduceStateChange(this.motionListener);
    } catch { this.systemReduceMotion = true; }
  }

  aboutToDisappear(): void {
    try { accessibility.offAnimationReduceStateChange(this.motionListener); } catch {}
  }

  onBackPress(): boolean {
    if (this.saving) { return true; }
    if (this.panel.length > 0) { this.closePanel(); return true; }
    if (this.tab !== 0) { this.switchTab(0); return true; }
    return false;
  }

  private ctx(): common.UIAbilityContext { return this.getUIContext().getHostContext() as common.UIAbilityContext; }
  private available(): boolean { return !this.loading && !this.saving && !this.loadFailed; }
  private motionEnabled(): boolean { return !this.reduceMotion && !this.systemReduceMotion; }
  private ready(): boolean { return this.name.trim().length > 0 && this.task.trim().length > 0 && this.carer.trim().length > 0; }
  private selected(): PlantCard { return this.cards.find((card: PlantCard) => card.id === this.selectedId) ?? this.cards[0]; }
  private panelCard(): PlantCard { return this.cards.find((card: PlantCard) => card.id === this.panelCardId) ?? this.cards[0]; }
  private refreshCounts(cards: PlantCard[]): void {
    this.waitingAcceptCount = cards.filter((card: PlantCard) => card.completed !== true && card.confirmed !== true).length;
    this.waitingCompleteCount = cards.filter((card: PlantCard) => card.completed !== true && card.confirmed === true).length;
    this.completedCount = cards.filter((card: PlantCard) => card.completed === true).length;
  }
  private visibleCards(): PlantCard[] {
    return this.cards.filter((card: PlantCard) => this.tab === 2 ? card.completed === true :
      card.completed !== true && (this.filter === 0 || (this.filter === 1 ? card.confirmed !== true : card.confirmed === true)));
  }
  private toTop(): void {
    setTimeout((): void => { this.scroll.scrollTo({ xOffset: 0, yOffset: 0 }); }, 40);
  }
  private switchTab(tab: number): void {
    this.tab = tab; this.panel = ''; this.feedback = ''; this.celebration = false; this.errorText = this.loadFailed ? this.errorText : '';
    this.toTop();
  }
  private openCreate(): void { this.panel = 'create'; this.feedback = ''; this.errorText = ''; this.toTop(); }
  private closePanel(): void {
    if (this.saving) { return; }
    this.panel = ''; this.panelCardId = 0; this.errorText = this.loadFailed ? this.errorText : '';
    this.completionDate = ''; this.completionNote = '';
    this.toTop();
  }
  private play(): void {
    this.playCount++;
    const words: string[] = ['接住你的小招呼啦。', '叶子晃一晃，心情松一松。', '陪你，把平常的一天过好。'];
    this.feedback = words[(this.playCount - 1) % words.length]; this.celebration = false;
  }

  private async load(): Promise<void> {
    if (this.saving) { return; }
    this.loading = true; this.errorText = '';
    try {
      const p = await preferences.getPreferences(this.ctx(), 'leafmate');
      this.cards = parseCards(await p.get('cards', '') as string);
      this.refreshCounts(this.cards);
      this.reduceMotion = await p.get('reduceMotion', false) as boolean;
      this.loadFailed = false;
    } catch { this.loadFailed = true; this.errorText = '花园暂时没能打开。原有记录未被覆盖，请重试读取。'; }
    finally { this.loading = false; }
  }

  private async persist(next: PlantCard[]): Promise<boolean> {
    const previous = JSON.stringify(this.cards);
    try {
      const p = await preferences.getPreferences(this.ctx(), 'leafmate');
      try { await p.put('cards', JSON.stringify(next)); await p.flush(); }
      catch {
        // Restore the Preferences cache as well as the visible list after a failed write.
        try { await p.put('cards', previous); await p.flush(); } catch {}
        throw new Error('Write failed');
      }
      this.cards = next;
      this.refreshCounts(next);
      return true;
    } catch { this.errorText = '这次没能确认保存成功。填写内容还在，请重试。'; return false; }
  }

  private async save(): Promise<void> {
    if (!this.ready() || !this.available()) { return; }
    this.saving = true; this.errorText = '';
    let id = Date.now();
    while (this.cards.some((card: PlantCard) => card.id === id)) { id++; }
    const card: PlantCard = { id: id, name: this.name.trim(), room: this.room.trim(), task: this.task.trim(),
      carer: this.carer.trim(), confirmed: false, completed: false, completedAt: '', completionNote: '', palette: this.draftPalette };
    if (await this.persist([card, ...this.cards])) {
      this.selectedId = id; this.name = ''; this.room = ''; this.task = ''; this.carer = '';
      this.panel = ''; this.tab = 0; this.feedback = '新的牵挂，已经放进花园。'; this.celebration = false;
      this.toTop();
    }
    this.saving = false;
  }

  private async confirm(card: PlantCard): Promise<void> {
    if (!this.available() || card.confirmed === true || card.completed === true) { return; }
    this.saving = true; this.errorText = '';
    if (await this.persist(this.cards.map((item: PlantCard) => item.id === card.id ? acceptCard(item) : item))) {
      this.selectedId = card.id; this.feedback = '已接手，做完后再来留个脚印。'; this.celebration = false;
    }
    this.saving = false;
  }

  private beginComplete(card: PlantCard): void {
    this.panelCardId = card.id; this.panel = 'complete'; this.completionDate = ''; this.completionNote = '';
    this.errorText = ''; this.toTop();
  }
  private fillCurrentTime(): void {
    const now = new Date();
    const pad = (value: number): string => value < 10 ? `0${value}` : `${value}`;
    this.completionDate = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}`;
  }
  private async complete(): Promise<void> {
    if (!this.available() || this.completionDate.trim().length === 0) { return; }
    const card = this.panelCard();
    if (!card || card.confirmed !== true || card.completed === true) { return; }
    this.saving = true; this.errorText = '';
    const finished = finishCard(card, this.completionDate, this.completionNote);
    if (await this.persist(this.cards.map((item: PlantCard) => item.id === card.id ? finished : item))) {
      this.selectedId = card.id; this.panel = ''; this.tab = 0; this.completionDate = ''; this.completionNote = '';
      this.feedback = '又一份照护，被好好记住了。'; this.celebration = true; this.pulse++;
      this.toTop();
    }
    this.saving = false;
  }
  private async changePalette(palette: number): Promise<void> {
    if (!this.available()) { return; }
    if (this.cards.length === 0) { this.draftPalette = palette; return; }
    const card = this.selected();
    if (card.palette === palette) { return; }
    this.saving = true; this.errorText = '';
    if (await this.persist(this.cards.map((item: PlantCard) => item.id === card.id ? recolorCard(item, palette) : item))) {
      this.feedback = '换个小花盆，今天也有新心情。'; this.celebration = false;
    }
    this.saving = false;
  }
  private async toggleMotion(): Promise<void> {
    if (!this.available()) { return; }
    this.saving = true; this.errorText = '';
    try {
      const p = await preferences.getPreferences(this.ctx(), 'leafmate');
      await p.put('reduceMotion', !this.reduceMotion); await p.flush(); this.reduceMotion = !this.reduceMotion;
    } catch { this.errorText = '动效偏好未保存，请重试。'; }
    this.saving = false;
  }
  private beginSummary(card: PlantCard): void {
    this.panelCardId = card.id; this.panel = 'summary'; this.errorText = '';
    this.includePlantName = true; this.includeRoom = card.room.length > 0; this.includeTask = true;
    this.includeCarer = false; this.includeConfirmation = true;
    this.includeCompletionTime = card.completed === true; this.includeCompletionNote = false;
    this.toTop();
  }
  private summary(card: PlantCard): string {
    const lines: string[] = [];
    if (this.includePlantName) { lines.push(`植物昵称：${card.name}`); }
    if (this.includeRoom && card.room.length > 0) { lines.push(`房间：${card.room}`); }
    if (this.includeTask) { lines.push(`交接任务：${card.task}`); }
    if (this.includeCarer) { lines.push(`照护人昵称：${card.carer}`); }
    if (this.includeConfirmation) { lines.push(`确认状态：${card.confirmed === true ? '已确认' : '未确认'} · ${taskStatus(card)}`); }
    if (this.includeCompletionTime && card.completed === true) { lines.push(`完成时间：${card.completedAt ?? ''}`); }
    if (this.includeCompletionNote && (card.completionNote ?? '').length > 0) { lines.push(`完成备注：${card.completionNote}`); }
    return lines.join('\n');
  }

  private buttonReady(gate: number): boolean {
    return this.available() && (gate === 1 ? this.ready() : gate === 2 ? this.completionDate.trim().length > 0 : true);
  }
  @Builder
  private primary(label: string, gate: number, action: () => void) {
    Button(gate === 1 ? (this.saving ? '正在放进花园…' : '放进小花园') : gate === 2 ? (this.saving ? '正在保存足迹…' : '确认完成，留个脚印') : gate === 3 ? (this.reduceMotion ? '恢复轻动效' : '减少动态效果') : label, { type: ButtonType.Normal }).fontSize(16).fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_on_primary')).backgroundColor($r('app.color.action_primary'))
      .width('100%').constraintSize({ minHeight: 52 }).padding({ top: 14, bottom: 14, left: 16, right: 16 })
      .borderRadius(18).enabled(this.buttonReady(gate)).opacity(this.buttonReady(gate) ? 1 : 0.45).onClick(action)
  }
  @Builder
  private secondary(label: string, action: () => void) {
    Button(label, { type: ButtonType.Normal }).fontSize(16).fontColor($r('app.color.action_primary'))
      .backgroundColor($r('app.color.surface_chip')).constraintSize({ minHeight: 48 })
      .padding({ top: 12, bottom: 12, left: 16, right: 16 }).borderRadius(16)
      .enabled(!this.saving).onClick(action)
  }
  @Builder
  private tag(label: string, done: boolean = false) {
    Text(label).fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
      .padding({ top: 6, bottom: 6, left: 12, right: 12 })
      .backgroundColor(done ? $r('app.color.surface_notice') : $r('app.color.surface_warning')).borderRadius(12)
  }
  @Builder
  private heading(eyebrow: string, title: string, subtitle: string) {
    Column({ space: 8 }) {
      Text(eyebrow).fontSize(12).fontWeight(FontWeight.Bold).letterSpacing(2).fontColor($r('app.color.text_secondary'))
      Text(title).fontSize(28).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text(subtitle).fontSize(16).lineHeight(24).fontColor($r('app.color.text_secondary'))
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
  @Builder
  private header() {
    Row({ space: 8 }) {
      if (this.panel.length > 0) {
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.icon_back')).width(24).height(24).fillColor($r('app.color.text_primary'))
        }.width(48).height(48).borderRadius(16).backgroundColor($r('app.color.surface_card'))
          .accessibilityText('返回上一页').enabled(!this.saving).onClick(() => this.closePanel())
        Text(this.panel === 'create' ? '新建交接' : this.panel === 'complete' ? '留下照护足迹' : this.panel === 'summary' ? '交接小纸条' : '花园设置')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).layoutWeight(1)
      } else {
        Row({ space: 8 }) {
          Image($r('app.media.nav_garden')).width(28).height(28).fillColor($r('app.color.action_primary')).accessibilityLevel('no')
          Text('叶伴').fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
        }.layoutWeight(1)
        Button('关于', { type: ButtonType.Normal }).fontSize(14).fontColor($r('app.color.text_secondary'))
          .backgroundColor(Color.Transparent).constraintSize({ minWidth: 48, minHeight: 48 }).onClick(() => { this.panel = 'about'; this.toTop(); })
        Button({ type: ButtonType.Normal }) {
          Image($r('app.media.icon_plus')).width(24).height(24).fillColor($r('app.color.text_on_primary'))
        }.width(48).height(48).borderRadius(16).backgroundColor($r('app.color.action_primary'))
          .accessibilityText('新建植物交接卡').enabled(this.available()).opacity(this.available() ? 1 : 0.45).onClick(() => this.openCreate())
      }
    }.width('100%').padding({ top: 4, bottom: 8 })
  }
  @Builder
  private notices() {
    if (this.loading || this.saving) {
      Row({ space: 12 }) {
        LoadingProgress().width(24).height(24).color($r('app.color.action_primary'))
        Text(this.loading ? '正在打开你的小花园…' : '正在保存，请稍等…').fontSize(16).fontColor($r('app.color.text_secondary'))
      }.width('100%').padding(16).backgroundColor($r('app.color.surface_card')).borderRadius(20)
    }
    if (this.errorText.length > 0) {
      Column({ space: 12 }) {
        Text(this.errorText).fontSize(16).lineHeight(24).fontColor($r('app.color.text_danger'))
        if (this.loadFailed) { this.secondary('重试打开花园', () => this.load()) }
      }.alignItems(HorizontalAlign.Start).width('100%').padding(20).backgroundColor($r('app.color.surface_error')).borderRadius(20)
    }
    if (this.feedback.length > 0 && this.panel.length === 0 && (this.celebration || this.tab === 1)) {
      Row({ space: 10 }) {
        Image(this.celebration ? $r('app.media.icon_check') : $r('app.media.icon_spark')).width(24).height(24)
          .fillColor($r('app.color.action_primary')).accessibilityLevel('no')
        Text(this.feedback).fontSize(16).lineHeight(24).fontColor($r('app.color.text_primary')).layoutWeight(1)
      }.width('100%').padding(16).backgroundColor($r('app.color.surface_notice')).borderRadius(20)
    }
  }
  private activePalette(draft: boolean): number {
    return draft || this.cards.length === 0 ? this.draftPalette : (this.selected().palette ?? 0);
  }
  @Builder
  private paletteChip(label: string, value: number, selected: number, draft: boolean) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 6 }) {
        Circle().width(14).height(14).fill(value === 0 ? $r('app.color.accent_peach') : value === 1 ? $r('app.color.surface_garden') : $r('app.color.accent_lilac'))
        Text(label).fontSize(14).fontWeight(this.activePalette(draft) === value ? FontWeight.Bold : FontWeight.Normal).fontColor($r('app.color.text_primary'))
      }
    }.layoutWeight(1).constraintSize({ minHeight: 48 }).padding(8).borderRadius(16)
      .backgroundColor(this.activePalette(draft) === value ? $r('app.color.surface_card') : Color.Transparent)
      .border({ width: this.activePalette(draft) === value ? 1.5 : 0, color: $r('app.color.action_primary'), radius: 16 })
      .accessibilityText(`${label}花盆${this.activePalette(draft) === value ? '，已选' : ''}`).accessibilitySelected(this.activePalette(draft) === value)
      .enabled(this.available()).onClick(() => { if (draft) { this.draftPalette = value; } else { this.changePalette(value); } })
  }
  @Builder
  private palettePicker(selected: number, draft: boolean) {
    Row({ space: 8 }) {
      this.paletteChip('陶土', 0, selected, draft)
      this.paletteChip('鼠尾草', 1, selected, draft)
      this.paletteChip('淡紫', 2, selected, draft)
    }.width('100%')
  }
  @Builder
  private gardenHero() {
    Column({ space: 12 }) {
      Row() {
        Text(this.cards.length > 0 ? '我的小小绿洲' : '给生活留一点绿').fontSize(14).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).layoutWeight(1)
        Image($r('app.media.icon_spark')).width(24).height(24).fillColor($r('app.color.text_secondary')).accessibilityLevel('no')
      }.width('100%')
      ClayPlant({ palette: this.cards.length > 0 ? (this.selected().palette ?? 0) : this.draftPalette,
        happy: this.cards.length > 0 && this.selected().completed === true, motionEnabled: this.motionEnabled(), pulse: this.pulse,
        onPlay: () => this.play() }).width('100%').height(182)
      Text(this.feedback.length > 0 && !this.celebration ? this.feedback : '点点打招呼，左右拖动晃一晃').fontSize(14).fontColor($r('app.color.text_secondary'))
      if (this.cards.length > 0) {
        Text(this.selected().name).fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).textAlign(TextAlign.Center)
        Text(this.selected().room.length > 0 ? this.selected().room : '小花园的一角').fontSize(16).fontColor($r('app.color.text_secondary'))
      } else {
        Text('第一份牵挂，从这里开始').fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).textAlign(TextAlign.Center)
      }
      this.palettePicker(this.cards.length > 0 ? (this.selected().palette ?? 0) : this.draftPalette, false)
    }.padding(20).width('100%').borderRadius(32)
      .linearGradient({ angle: 145, colors: [[$r('app.color.surface_garden'), 0], [$r('app.color.surface_notice'), 1]] })
  }
  @Builder
  private taskAction(card: PlantCard) {
    if (card.completed === true) { this.secondary('查看照护足迹', () => this.switchTab(2)) }
    else if (card.confirmed === true) { this.primary('做好了，记一笔', 0, () => this.beginComplete(card)) }
    else { this.primary('这件事，我接手了', 0, () => this.confirm(card)) }
  }
  @Builder
  private featuredTask(card: PlantCard) {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        Text('这一份小牵挂').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).layoutWeight(1)
        this.tag(taskStatus(card), card.completed === true)
      }.width('100%')
      Text(card.task).fontSize(20).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).width('100%')
      Text(`交给 ${card.carer}${card.completed === true ? ` · ${card.completedAt ?? ''}` : ''}`).fontSize(16).fontColor($r('app.color.text_secondary')).width('100%')
      this.taskAction(card)
    }.padding(20).width('100%').backgroundColor($r('app.color.surface_card')).borderRadius(24)
  }
  @Builder
  private cardSelector(card: PlantCard) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 12 }) {
        ClayPlant({ palette: card.palette ?? 0, compact: true, happy: card.completed === true, motionEnabled: false }).width(64).height(64).accessibilityLevel('no')
        Column({ space: 5 }) {
          Text(card.name).fontSize(17).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`${taskStatus(card)} · ${card.carer}`).fontSize(14).fontColor($r('app.color.text_secondary')).maxLines(2)
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        if (this.selected().id === card.id) { Image($r('app.media.icon_check')).width(22).height(22).fillColor($r('app.color.action_primary')) }
      }.width('100%')
    }.width('100%').padding(12).borderRadius(20).backgroundColor($r('app.color.surface_card'))
      .border({ width: this.selected().id === card.id ? 1.5 : 0, color: $r('app.color.action_primary'), radius: 20 })
      .accessibilityText(`查看${card.name}的交接卡，${taskStatus(card)}`).accessibilitySelected(this.selected().id === card.id)
      .onClick(() => { this.selectedId = card.id; this.feedback = ''; this.celebration = false; this.toTop(); })
  }
  @Builder
  private gardenPage() {
    this.heading('A LITTLE GREEN, EVERY DAY', '把小日子，养成绿意。', '有人照顾植物，也有人接住牵挂。')
    this.gardenHero()
    if (this.cards.length > 0) {
      ForEach([this.selected()], (card: PlantCard) => { this.featuredTask(card) }, (card: PlantCard) => `${card.id}-${card.confirmed}-${card.completed}-${card.palette}`)
      Row() {
        Text('花园里的牵挂').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).layoutWeight(1)
        Text(`${this.cards.length} 张交接卡`).fontSize(14).fontColor($r('app.color.text_secondary'))
      }.width('100%')
      ForEach(this.cards, (card: PlantCard) => { this.cardSelector(card) }, (card: PlantCard) => `${card.id}-${card.confirmed}-${card.completed}-${card.palette}`)
    } else if (!this.loading && !this.loadFailed) {
      Column({ space: 12 }) {
        this.primary('创建第一张交接卡', 0, () => this.openCreate())
        Text('取个昵称，写下要做的事，再交给关心它的人。').fontSize(16).lineHeight(24).fontColor($r('app.color.text_secondary')).textAlign(TextAlign.Center)
      }.width('100%')
    }
    Text('只记录你们的照护，不判断植物健康。').fontSize(14).fontColor($r('app.color.text_secondary')).width('100%')
  }
  @Builder
  private filterButton(label: string, value: number) {
    Button(label, { type: ButtonType.Normal }).fontSize(14).fontWeight(this.filter === value ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.filter === value ? $r('app.color.text_on_primary') : $r('app.color.text_secondary'))
      .backgroundColor(this.filter === value ? $r('app.color.action_primary') : $r('app.color.surface_sunken'))
      .layoutWeight(1).constraintSize({ minHeight: 48 }).borderRadius(16).padding(8)
      .accessibilitySelected(this.filter === value).onClick(() => this.filter = value)
  }
  @Builder
  private relayCard(card: PlantCard) {
    Column({ space: 16 }) {
      Row({ space: 12 }) {
        ClayPlant({ palette: card.palette ?? 0, compact: true, happy: card.completed === true, motionEnabled: false }).width(72).height(72).accessibilityLevel('no')
        Column({ space: 6 }) {
          Text(card.name).fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          Text(card.room.length > 0 ? card.room : '未填写房间').fontSize(14).fontColor($r('app.color.text_secondary'))
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      }.width('100%')
      this.tag(taskStatus(card), card.completed === true)
      Text(card.task).fontSize(18).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary')).width('100%')
      Text(`照护人 · ${card.carer}`).fontSize(16).fontColor($r('app.color.text_secondary')).width('100%')
      if (card.completed === true) {
        Text(`完成于 ${card.completedAt ?? ''}`).fontSize(16).fontColor($r('app.color.text_secondary')).width('100%')
        if ((card.completionNote ?? '').length > 0) {
          Text(card.completionNote ?? '').fontSize(16).lineHeight(24).fontColor($r('app.color.text_primary')).padding(16)
            .width('100%').backgroundColor($r('app.color.surface_notice')).borderRadius(16)
        }
      } else { this.taskAction(card) }
      this.secondary('整理交接小纸条', () => this.beginSummary(card))
    }.width('100%').alignItems(HorizontalAlign.Start).padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(24)
  }
  @Builder
  private emptyList() {
    Column({ space: 16 }) {
      Image(this.tab === 2 ? $r('app.media.nav_journal') : $r('app.media.nav_relay')).width(44).height(44).fillColor($r('app.color.action_primary')).accessibilityLevel('no')
      Text(this.tab === 2 ? '每一次照护，都值得记住' : this.cards.length === 0 ? '先种下一份小牵挂' : '这里暂时没有待办').fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).textAlign(TextAlign.Center)
      Text(this.tab === 2 ? '完成一件照护后，时间和备注会留在这里。' : this.filter === 0 ? '有了要做的事，就新建一张交接卡。' : '试试查看全部待办，或安排新的照护。').fontSize(16).lineHeight(24).fontColor($r('app.color.text_secondary')).textAlign(TextAlign.Center)
      if (this.tab === 2) { this.secondary('去看看交接', () => this.switchTab(1)) }
      else if (this.filter !== 0) { this.secondary('查看全部待办', () => this.filter = 0) }
      else { this.primary('安排一件小事', 0, () => this.openCreate()) }
    }.width('100%').padding(24).backgroundColor($r('app.color.surface_card')).borderRadius(28)
  }
  @Builder
  private listPage() {
    if (this.tab === 1) {
      this.heading('CARE, TOGETHER', '小事有人接，绿意慢慢续。', `${this.waitingAcceptCount} 件待接手 · ${this.waitingCompleteCount} 件待完成`)
      Row({ space: 8 }) {
        this.filterButton('全部待办', 0)
        this.filterButton('待接手', 1)
        this.filterButton('待完成', 2)
      }.width('100%')
    } else {
      this.heading('LITTLE MOMENTS', '照护留下的，小小足迹。', `好好记住了 ${this.completedCount} 次照护`)
    }
    if (this.available() && this.visibleCards().length === 0) { this.emptyList() }
    ForEach(this.visibleCards(), (card: PlantCard) => { this.relayCard(card) }, (card: PlantCard) => `${card.id}-${card.confirmed}-${card.completed}-${card.palette}`)
  }
  @Builder
  private fieldLabel(label: string, hint: string) {
    Column({ space: 4 }) {
      Text(label).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
      if (hint.length > 0) { Text(hint).fontSize(14).fontColor($r('app.color.text_secondary')) }
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
  @Builder
  private createPage() {
    this.heading('MAKE ROOM FOR GREEN', '给牵挂，安一个家。', '先认识它，再安排一件需要接手的小事。')
    Column({ space: 12 }) {
      ClayPlant({ palette: this.draftPalette, motionEnabled: this.motionEnabled(), onPlay: () => {} }).width('100%').height(150)
      this.palettePicker(this.draftPalette, true)
    }.width('100%').padding(16).backgroundColor($r('app.color.surface_garden')).borderRadius(28)
    Column({ space: 12 }) {
      this.fieldLabel('01  它叫什么？', '植物昵称 · 必填')
      TextInput({ text: this.name, placeholder: '你给它取的名字' }).fontSize(16).height(52).maxLength(60)
        .fontColor($r('app.color.text_primary')).backgroundColor($r('app.color.surface_sunken')).borderRadius(16)
        .accessibilityText('植物昵称，必填').enabled(!this.saving).onChange((value: string) => this.name = value)
      this.fieldLabel('住在哪个角落？', '房间 · 可选')
      TextInput({ text: this.room, placeholder: '记下它的位置' }).fontSize(16).height(52).maxLength(60)
        .fontColor($r('app.color.text_primary')).backgroundColor($r('app.color.surface_sunken')).borderRadius(16)
        .accessibilityText('房间，可选').enabled(!this.saving).onChange((value: string) => this.room = value)
      this.fieldLabel('02  这次要做什么？', '按你们的约定填写，不会生成照护建议 · 必填')
      TextArea({ text: this.task, placeholder: '写下具体的小事' }).fontSize(16).height(100).maxLength(300)
        .fontColor($r('app.color.text_primary')).backgroundColor($r('app.color.surface_sunken')).borderRadius(16)
        .accessibilityText('交接任务，必填').enabled(!this.saving).onChange((value: string) => this.task = value)
      this.fieldLabel('03  交给谁照顾？', '照护人昵称 · 必填')
      TextInput({ text: this.carer, placeholder: '用熟悉的昵称就好' }).fontSize(16).height(52).maxLength(60)
        .fontColor($r('app.color.text_primary')).backgroundColor($r('app.color.surface_sunken')).borderRadius(16)
        .accessibilityText('照护人昵称，必填').enabled(!this.saving).onChange((value: string) => this.carer = value)
    }.padding(20).width('100%').backgroundColor($r('app.color.surface_card')).borderRadius(24)
    if (!this.ready()) { Text('填好植物昵称、要做的事和照护人，就可以放进花园。').fontSize(14).lineHeight(22).fontColor($r('app.color.text_secondary')) }
    this.primary(this.saving ? '正在放进花园…' : '放进小花园', 1, () => this.save())
    Text('只保存在这台设备，不会通知或发送给照护人。').fontSize(14).lineHeight(22).fontColor($r('app.color.text_secondary'))
  }
  @Builder
  private completePage(card: PlantCard) {
    this.heading('A LITTLE CARE COUNTS', '做过的小事，值得记一笔。', `${card.name} · ${card.task}`)
    Column({ space: 16 }) {
      this.fieldLabel('什么时候完成的？', '完成时间 · 必填，可以写实际日期或你熟悉的表述')
      TextInput({ text: this.completionDate, placeholder: '填写实际完成时间' }).fontSize(16).height(56).maxLength(80)
        .fontColor($r('app.color.text_primary')).backgroundColor($r('app.color.surface_sunken')).borderRadius(16)
        .accessibilityText('实际完成时间，必填').enabled(!this.saving).onChange((value: string) => this.completionDate = value)
      this.secondary('填入现在的时间', () => this.fillCurrentTime())
      this.fieldLabel('留句话吧', '完成备注 · 可选')
      TextArea({ text: this.completionNote, placeholder: '给下一位照护人的小提示' }).fontSize(16).height(128).maxLength(500)
        .fontColor($r('app.color.text_primary')).backgroundColor($r('app.color.surface_sunken')).borderRadius(16)
        .accessibilityText('完成备注，可选').enabled(!this.saving).onChange((value: string) => this.completionNote = value)
    }.padding(20).width('100%').backgroundColor($r('app.color.surface_card')).borderRadius(24)
    this.primary(this.saving ? '正在保存足迹…' : '确认完成，留个脚印', 2, () => this.complete())
    this.secondary('暂时不记录', () => this.closePanel())
    Text('请在实际照护完成后记录。取消不会改变任务状态。').fontSize(14).lineHeight(22).fontColor($r('app.color.text_secondary'))
  }
  private fieldIncluded(field: number): boolean {
    return field === 0 ? this.includePlantName : field === 1 ? this.includeRoom : field === 2 ? this.includeTask :
      field === 3 ? this.includeCarer : field === 4 ? this.includeConfirmation : field === 5 ? this.includeCompletionTime : this.includeCompletionNote;
  }
  @Builder
  private summaryField(label: string, field: number, action: () => void) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 12 }) {
        Text(label).fontSize(16).fontColor($r('app.color.text_primary')).layoutWeight(1).textAlign(TextAlign.Start)
        Text(this.fieldIncluded(field) ? '已包含' : '已隐藏').fontSize(14).fontColor($r('app.color.text_secondary'))
        if (this.fieldIncluded(field)) { Image($r('app.media.icon_check')).width(20).height(20).fillColor($r('app.color.action_primary')) }
      }.width('100%')
    }.width('100%').constraintSize({ minHeight: 52 }).padding(12).borderRadius(14)
      .backgroundColor(this.fieldIncluded(field) ? $r('app.color.surface_notice') : $r('app.color.surface_sunken'))
      .accessibilityText(`${label}，${this.fieldIncluded(field) ? '已包含，点按隐藏' : '已隐藏，点按包含'}`).accessibilitySelected(this.fieldIncluded(field)).onClick(action)
  }
  @Builder
  private summaryPage(card: PlantCard) {
    this.heading('A NOTE FOR THE NEXT ONE', '想说的，才放进纸条。', '本地摘要预览 · 照护人和备注默认隐藏')
    Column({ space: 8 }) {
      this.summaryField('植物昵称', 0, () => this.includePlantName = !this.includePlantName)
      if (card.room.length > 0) { this.summaryField('房间', 1, () => this.includeRoom = !this.includeRoom) }
      this.summaryField('交接任务', 2, () => this.includeTask = !this.includeTask)
      this.summaryField('照护人昵称', 3, () => this.includeCarer = !this.includeCarer)
      this.summaryField('确认状态', 4, () => this.includeConfirmation = !this.includeConfirmation)
      if (card.completed === true) { this.summaryField('完成时间', 5, () => this.includeCompletionTime = !this.includeCompletionTime) }
      if ((card.completionNote ?? '').length > 0) { this.summaryField('完成备注', 6, () => this.includeCompletionNote = !this.includeCompletionNote) }
    }.width('100%')
    Column({ space: 16 }) {
      Text('交接小纸条').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text(this.summary(card).length > 0 ? this.summary(card) : '至少保留一个字段，纸条才有内容。').fontSize(16).lineHeight(28).fontColor($r('app.color.text_primary')).width('100%')
      Text('仅在这里预览，未生成文件或发送内容。').fontSize(14).fontColor($r('app.color.text_secondary'))
    }.alignItems(HorizontalAlign.Start).padding(24).width('100%').backgroundColor($r('app.color.surface_warning')).borderRadius(24)
    this.secondary('收起纸条，取消选择', () => this.closePanel())
  }
  @Builder
  private aboutPage() {
    this.heading('YOUR QUIET LITTLE GARDEN', '小花园，也有自己的节奏。', '叶伴 · 本地家庭植物照护交接板')
    Column({ space: 16 }) {
      Text('轻一点的动效').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text(this.systemReduceMotion ? '系统已开启减少动态效果，植物会保持静态回应。' : '关闭摇摆和庆祝动画，点按仍会收到文字回应。').fontSize(16).lineHeight(24).fontColor($r('app.color.text_secondary'))
      this.primary(this.reduceMotion ? '恢复轻动效' : '减少动态效果', 3, () => this.toggleMotion())
    }.alignItems(HorizontalAlign.Start).padding(20).width('100%').backgroundColor($r('app.color.surface_card')).borderRadius(24)
    Column({ space: 12 }) {
      Text('关于这份牵挂').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
      Text('植物昵称、照护任务与足迹只保存在这台设备。照护人是你填写的昵称，不是账号；交接不会自动通知对方。').fontSize(16).lineHeight(26).fontColor($r('app.color.text_secondary'))
      Text('卡通表情只为陪伴，不代表植物健康。叶伴不识别、不诊断，也不提供施肥或农药建议。').fontSize(16).lineHeight(26).fontColor($r('app.color.text_secondary'))
      Text('当前支持文字交接和摘要预览。照片、系统提醒、文件导出及跨设备同步暂未提供。').fontSize(16).lineHeight(26).fontColor($r('app.color.text_secondary'))
    }.alignItems(HorizontalAlign.Start).padding(20).width('100%').backgroundColor($r('app.color.surface_card')).borderRadius(24)
  }
  @Builder
  private navItem(label: string, icon: Resource, value: number) {
    Button({ type: ButtonType.Normal }) {
      Column({ space: 4 }) {
        Image(icon).width(24).height(24).fillColor(this.tab === value ? $r('app.color.action_primary') : $r('app.color.text_secondary')).accessibilityLevel('no')
        Text(label).fontSize(14).fontWeight(this.tab === value ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.tab === value ? $r('app.color.action_primary') : $r('app.color.text_secondary'))
      }.padding({ top: 10, bottom: 10 }).width('100%')
    }.layoutWeight(1).constraintSize({ minHeight: 64 }).borderRadius(20)
      .backgroundColor(this.tab === value ? $r('app.color.surface_notice') : Color.Transparent)
      .accessibilityText(`${label}${this.tab === value ? '，当前页面' : ''}`).accessibilitySelected(this.tab === value)
      .enabled(!this.saving).onClick(() => this.switchTab(value))
  }

  build() {
    Column() {
      Scroll(this.scroll) {
        Column({ space: 20 }) {
          this.header()
          this.notices()
          if (this.panel === 'create') { this.createPage() }
          else if (this.panel === 'complete' && this.cards.length > 0) { this.completePage(this.panelCard()) }
          else if (this.panel === 'summary' && this.cards.length > 0) { this.summaryPage(this.panelCard()) }
          else if (this.panel === 'about') { this.aboutPage() }
          else if (this.tab === 0) { this.gardenPage() }
          else { this.listPage() }
        }.width('100%').constraintSize({ maxWidth: 760 }).padding({ left: 20, right: 20, top: 16, bottom: 28 })
      }.layoutWeight(1).width('100%').scrollBar(BarState.Off).align(Alignment.Top)
      if (this.panel.length === 0) {
        Row({ space: 8 }) {
          this.navItem('花园', $r('app.media.nav_garden'), 0)
          this.navItem('交接', $r('app.media.nav_relay'), 1)
          this.navItem('足迹', $r('app.media.nav_journal'), 2)
        }.width('100%').constraintSize({ maxWidth: 760 }).padding({ left: 20, right: 20, top: 10, bottom: 12 })
          .backgroundColor($r('app.color.surface_card'))
      }
    }.width('100%').height('100%').backgroundColor($r('app.color.surface_canvas'))
  }
}
