import { PantryItem, PantryStore } from '../data/PantryStore';

const INVALID_SORT: number = 99999999;

@Entry
@Component
struct Index {
  private readonly store: PantryStore = new PantryStore();
  @State private items: PantryItem[] = [];
  @State private name: string = '';
  @State private notedDate: string = '';
  @State private place: string = '';
  @State private pickedId: number = 0;
  @State private confirmDeleteId: number = 0;
  @State private loading: boolean = true;
  @State private errorText: string = '';

  aboutToAppear(): void {
    this.load();
  }

  onBackPress(): boolean {
    if (this.confirmDeleteId !== 0) {
      this.confirmDeleteId = 0;
      return true;
    }
    return false;
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        this.header()
        this.boundaryNotice()
        this.addForm()
        if (this.errorText.length > 0) {
          this.errorBanner()
        }
        if (this.hasPicked()) {
          this.todayHint()
        }
        this.pantryList()
      }
      .padding({ left: 20, right: 20, top: 28, bottom: 36 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .constraintSize({ maxWidth: 640 })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Auto)
    .backgroundColor($r('app.color.canvas'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  private header() {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text('食材管家')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(34)
        Text('本机清单 · 按你记下的日期排列')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .lineHeight(24)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text('非安全建议')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .padding({ left: 10, right: 10, top: 8, bottom: 8 })
        .backgroundColor($r('app.color.notice'))
        .borderRadius(8)
        .accessibilityText('不提供食品安全判断')
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private boundaryNotice() {
    Column({ space: 8 }) {
      Text('日期由你填写。列表只按日历远近排列，不是保质期鉴定，也不表示可以或不可以食用。')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_notice'))
        .lineHeight(24)
      Text('不接收据、条码、购物或营养建议。记录只留在本机，不使用网络。')
        .fontSize(16)
        .fontColor($r('app.color.text_notice'))
        .lineHeight(24)
    }
    .padding(16)
    .backgroundColor($r('app.color.notice'))
    .borderRadius(16)
    .width('100%')
  }

  @Builder
  private addForm() {
    Column({ space: 12 }) {
      Text('添加本机食材')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Text('食材名称（必填）')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
      TextInput({ placeholder: '例如 菠菜', text: this.name })
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .placeholderColor($r('app.color.text_secondary'))
        .backgroundColor($r('app.color.canvas'))
        .border({ width: 1, color: $r('app.color.border_subtle') })
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.name = value;
        })

      Text('你记下的日期（必填）')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
      TextInput({ placeholder: '格式 YYYY-MM-DD，例如 2026-09-10', text: this.notedDate })
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .placeholderColor($r('app.color.text_secondary'))
        .backgroundColor($r('app.color.canvas'))
        .border({ width: 1, color: $r('app.color.border_subtle') })
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.notedDate = value;
        })
      Text('请用年-月-日。无法识别的日期仍会保存，但排在列表后面。')
        .fontSize(14)
        .lineHeight(22)
        .fontColor($r('app.color.text_secondary'))

      Text('存放位置（可选）')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
      TextInput({ placeholder: '例如 冷藏室上层', text: this.place })
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .placeholderColor($r('app.color.text_secondary'))
        .backgroundColor($r('app.color.canvas'))
        .border({ width: 1, color: $r('app.color.border_subtle') })
        .borderRadius(12)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.place = value;
        })

      if (!this.canSave()) {
        Text('填写名称和日期后即可保存。')
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_secondary'))
      }

      Button('保存本机食材')
        .width('100%')
        .constraintSize({ minHeight: 52 })
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.on_action'))
        .backgroundColor($r('app.color.action'))
        .borderRadius(14)
        .enabled(this.canSave() && !this.loading)
        .accessibilityText('保存仅在本机保留的食材记录')
        .onClick(() => {
          this.save();
        })
    }
    .padding(20)
    .backgroundColor($r('app.color.card'))
    .borderRadius(20)
    .width('100%')
  }

  @Builder
  private errorBanner() {
    Column({ space: 8 }) {
      Text(this.errorText)
        .fontSize(16)
        .lineHeight(24)
        .fontColor($r('app.color.text_notice'))
      Button('重试读取本机食材')
        .fontSize(16)
        .fontColor($r('app.color.action'))
        .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
        .accessibilityText('重新读取本机食材记录')
        .onClick(() => {
          this.load();
        })
    }
    .padding(16)
    .backgroundColor($r('app.color.notice'))
    .borderRadius(16)
    .width('100%')
  }

  @Builder
  private todayHint() {
    Column({ space: 8 }) {
      Text('今日本地提示')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_success'))
      Text(`可优先考虑使用「${this.pickedName()}」。这是你点选的条目，不是菜谱或安全建议。`)
        .fontSize(16)
        .lineHeight(24)
        .fontColor($r('app.color.text_primary'))
      Button('清除选择')
        .fontSize(16)
        .fontColor($r('app.color.action'))
        .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
        .accessibilityText('清除今日优先消耗的选择，不删除食材记录')
        .onClick(() => {
          this.pickedId = 0;
        })
    }
    .padding(20)
    .backgroundColor($r('app.color.active'))
    .borderRadius(20)
    .width('100%')
  }

  @Builder
  private pantryList() {
    Column({ space: 12 }) {
      Text('按记下日期排列')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      if (this.loading) {
        Text('正在读取或保存本机记录…')
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_secondary'))
      } else if (this.items.length === 0) {
        Text('还没有本机食材记录。先在上方填写名称和你记下的日期，再保存。')
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_secondary'))
      } else {
        Text(`共 ${this.items.length} 条，仅保存在本机。`)
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_secondary'))
        ForEach(this.sortedItems(), (item: PantryItem) => {
          this.pantryRow(item)
        }, (item: PantryItem) => item.id.toString())
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card'))
    .borderRadius(20)
    .width('100%')
  }

  @Builder
  private pantryRow(item: PantryItem) {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Text(item.name)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .lineHeight(24)
        if (this.isSoonest(item)) {
          Text('更近')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_notice'))
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor($r('app.color.card'))
            .borderRadius(8)
            .accessibilityText(`${item.name}的记下日期在可排序条目中更近`)
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Text(this.dateCaption(item))
        .fontSize(16)
        .lineHeight(24)
        .fontColor($r('app.color.text_notice'))
      if (item.place.length > 0) {
        Text(`位置：${item.place}`)
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_secondary'))
      }

      Button(this.pickedId === item.id ? `${item.name} · 已选择` : `选择 ${item.name}`)
        .width('100%')
        .constraintSize({ minHeight: 48 })
        .fontSize(16)
        .fontColor($r('app.color.text_primary'))
        .backgroundColor(this.pickedId === item.id ? $r('app.color.active') : $r('app.color.card'))
        .border({
          width: 1,
          color: this.pickedId === item.id ? $r('app.color.action') : $r('app.color.border_subtle')
        })
        .borderRadius(12)
        .accessibilityText(this.pickedId === item.id ? `已选择${item.name}` : `选择${item.name}作为今日优先消耗`)
        .onClick(() => {
          this.pickedId = item.id;
        })

      if (this.confirmDeleteId === item.id) {
        Text('删除后无法从本应用恢复这条记录。没有上传。')
          .fontSize(16)
          .lineHeight(24)
          .fontColor($r('app.color.text_danger'))
        Button('确认删除这条食材')
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .fontSize(16)
          .fontColor($r('app.color.text_danger'))
          .backgroundColor(Color.Transparent)
          .border({ width: 1, color: $r('app.color.text_danger') })
          .borderRadius(12)
          .accessibilityText(`确认删除${item.name}，此操作不能撤销`)
          .onClick(() => {
            this.remove(item.id);
          })
        Button('取消删除')
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .fontSize(16)
          .fontColor($r('app.color.action'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.confirmDeleteId = 0;
          })
      } else {
        Button('删除这条食材')
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .fontSize(16)
          .fontColor($r('app.color.action'))
          .backgroundColor(Color.Transparent)
          .accessibilityText(`准备删除${item.name}，下一步需要确认`)
          .onClick(() => {
            this.remove(item.id);
          })
      }
    }
    .padding(16)
    .backgroundColor(this.pickedId === item.id ? $r('app.color.active') : $r('app.color.notice'))
    .borderRadius(16)
    .width('100%')
  }

  private hostContext(): Context {
    return getContext(this);
  }

  private canSave(): boolean {
    return this.name.trim().length > 0 && this.notedDate.trim().length > 0;
  }

  private hasPicked(): boolean {
    return this.pickedId !== 0 && this.pickedName().length > 0;
  }

  private pickedName(): string {
    const match: PantryItem[] = this.items.filter((item: PantryItem) => item.id === this.pickedId);
    return match.length > 0 ? match[0].name : '';
  }

  private sortedItems(): PantryItem[] {
    const copy: PantryItem[] = this.items.slice();
    copy.sort((left: PantryItem, right: PantryItem) => {
      const keyDiff: number = this.sortKey(left) - this.sortKey(right);
      if (keyDiff !== 0) {
        return keyDiff;
      }
      return left.id - right.id;
    });
    return copy;
  }

  private sortKey(item: PantryItem): number {
    const ymd: number = this.ymdNumber(item.notedDate);
    return ymd === 0 ? INVALID_SORT : ymd;
  }

  private ymdNumber(dateText: string): number {
    const parts: string[] = dateText.trim().split('-');
    if (parts.length !== 3) {
      return 0;
    }
    const year: number = Number.parseInt(parts[0], 10);
    const month: number = Number.parseInt(parts[1], 10);
    const day: number = Number.parseInt(parts[2], 10);
    if (Number.isNaN(year) || Number.isNaN(month) || Number.isNaN(day)) {
      return 0;
    }
    if (year < 1000 || month < 1 || month > 12 || day < 1 || day > 31) {
      return 0;
    }
    return year * 10000 + month * 100 + day;
  }

  private isSoonest(item: PantryItem): boolean {
    if (this.sortKey(item) >= INVALID_SORT) {
      return false;
    }
    const sorted: PantryItem[] = this.sortedItems();
    return sorted.length > 0 && sorted[0].id === item.id;
  }

  private dateCaption(item: PantryItem): string {
    const ymd: number = this.ymdNumber(item.notedDate);
    if (ymd === 0) {
      return `记下：${item.notedDate} · 格式无法参与排序`;
    }
    const today: Date = new Date();
    const year: number = Math.floor(ymd / 10000);
    const month: number = Math.floor((ymd % 10000) / 100);
    const day: number = ymd % 100;
    const noted: Date = new Date(year, month - 1, day);
    const start: Date = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const days: number = Math.round((noted.getTime() - start.getTime()) / 86400000);
    if (days === 0) {
      return `记下：${item.notedDate} · 日历距离是今天，不是可否食用的判断`;
    }
    if (days > 0) {
      return `记下：${item.notedDate} · 日历上还有 ${days} 天，不是可否食用的判断`;
    }
    return `记下：${item.notedDate} · 日历上已过 ${-days} 天，不是可否食用的判断`;
  }

  private async load(): Promise<void> {
    this.loading = true;
    this.errorText = '';
    try {
      this.items = await this.store.load(this.hostContext());
    } catch {
      this.errorText = '无法读取本机食材记录。请重试；不会影响任何外部服务。';
    } finally {
      this.loading = false;
    }
  }

  private async save(): Promise<void> {
    if (!this.canSave() || this.loading) {
      return;
    }
    const item: PantryItem = {
      id: Date.now(),
      name: this.name.trim(),
      notedDate: this.notedDate.trim(),
      place: this.place.trim()
    };
    this.loading = true;
    this.errorText = '';
    try {
      const updated: PantryItem[] = [item, ...this.items];
      await this.store.save(this.hostContext(), updated);
      this.items = updated;
      this.name = '';
      this.notedDate = '';
      this.place = '';
    } catch {
      this.errorText = '无法保存本机食材。请保留填写内容后重试；没有上传数据。';
    } finally {
      this.loading = false;
    }
  }

  private async remove(id: number): Promise<void> {
    if (this.confirmDeleteId !== id) {
      this.confirmDeleteId = id;
      return;
    }
    this.loading = true;
    this.errorText = '';
    try {
      const updated: PantryItem[] = this.items.filter((item: PantryItem) => item.id !== id);
      await this.store.save(this.hostContext(), updated);
      this.items = updated;
      this.confirmDeleteId = 0;
      if (this.pickedId === id) {
        this.pickedId = 0;
      }
    } catch {
      this.errorText = '无法删除本机食材。请重试；没有上传数据。';
    } finally {
      this.loading = false;
    }
  }
}
