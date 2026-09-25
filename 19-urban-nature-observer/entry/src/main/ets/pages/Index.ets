import { common } from '@kit.AbilityKit';
import { TASKS, PLACES, MAX_RECORDS, Observation, optionsFor, guidanceFor, toggleFeature, validSelection } from '../model/Observation';
import { ObservationStore } from '../storage/ObservationStore';

@Entry
@Component
struct Index {
  @State private task: string = '';
  @State private place: string = '';
  @State private features: string[] = [];
  @State private records: Observation[] = [];
  @State private ready: boolean = false;
  @State private busy: boolean = false;
  @State private message: string = '';
  @State private storageError: string = '';
  @State private pendingDelete: string = '';
  private scroller: Scroller = new Scroller();
  private store: ObservationStore | undefined = undefined;

  aboutToAppear(): void { this.loadRecords(); }

  private loadRecords(): void {
    this.ready = false;
    this.storageError = '';
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      if (!this.store) { this.store = new ObservationStore(context); }
      this.records = this.store.load();
      this.ready = true;
    } catch (error) {
      this.storageError = '本机记录暂时无法读取。请重试；已有数据不会被自动清空。';
    }
  }

  private canSave(): boolean {
    return this.ready && !this.busy && this.records.length < MAX_RECORDS && validSelection(this.task, this.place, this.features);
  }

  private selectTask(task: string): void {
    if (this.task !== task) { this.features = []; }
    this.task = task;
    this.message = '';
    this.pendingDelete = '';
  }

  private selectPlace(place: string): void {
    this.place = place;
    this.message = '';
    this.pendingDelete = '';
  }

  private selectFeature(feature: string): void {
    this.features = toggleFeature(this.task, this.features, feature);
    this.message = '';
    this.pendingDelete = '';
  }

  private async saveObservation(): Promise<void> {
    if (!this.canSave() || !this.store) { return; }
    this.busy = true;
    this.pendingDelete = '';
    const now: number = Date.now();
    const record: Observation = {
      id: `${now}-${Math.random().toString(36).slice(2, 10)}`,
      createdAt: now, task: this.task, place: this.place, features: this.features.slice()
    };
    const next: Observation[] = [record, ...this.records];
    try {
      await this.store.save(next);
      this.records = next;
      this.features = [];
      this.message = '已保存到本机，可在下方回顾。下次打开应用仍可查看。';
    } catch (error) {
      this.message = '保存失败，尚未确认写入本机。你的选择已保留，请重试。';
      this.checkStorageHealth();
    } finally { this.busy = false; }
  }

  private async deleteRecords(): Promise<void> {
    if (!this.ready || this.busy || !this.store || this.pendingDelete === '') { return; }
    const next: Observation[] = this.pendingDelete === 'all' ? [] :
      this.records.filter((item: Observation) => item.id !== this.pendingDelete);
    this.busy = true;
    try {
      await this.store.save(next);
      this.records = next;
      this.pendingDelete = '';
      this.message = '已从本机删除所选观察记录。';
    } catch (error) {
      this.message = '删除未完成，列表暂时保留。请重试。';
      this.checkStorageHealth();
    } finally { this.busy = false; }
  }

  private checkStorageHealth(): void {
    if (this.store && !this.store.isReady()) {
      this.ready = false;
      this.storageError = '存储状态暂时无法确认，已暂停写入。请关闭应用后重新打开，检查记录是否保存。';
    }
  }

  private revisit(record: Observation): void {
    this.task = record.task;
    this.place = record.place;
    this.features = [];
    this.pendingDelete = '';
    this.message = '已选择同类任务和环境，请重新观察并勾选特征。原记录保持不变。';
    this.scroller.scrollEdge(Edge.Top);
  }

  private dateLabel(timestamp: number): string {
    const date: Date = new Date(timestamp);
    const minute: string = date.getMinutes() < 10 ? `0${date.getMinutes()}` : `${date.getMinutes()}`;
    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日 ${date.getHours()}:${minute}`;
  }

  onBackPress(): boolean {
    if (this.busy) { return true; }
    if (this.pendingDelete !== '') { this.pendingDelete = ''; return true; }
    return false;
  }

  private isSelected(label: string): boolean {
    return this.task === label || this.place === label || this.features.indexOf(label) >= 0;
  }

  @Builder
  option(label: string, action: () => void) {
    Button(this.isSelected(label) ? `${label} · 已选择` : label)
      .width('100%').constraintSize({ minHeight: 48 }).padding(12).borderRadius(14)
      .backgroundColor(this.isSelected(label) ? $r('app.color.active') : $r('app.color.canvas'))
      .fontColor($r('app.color.text_primary')).fontSize(16)
      .accessibilityText(`${label}，${this.isSelected(label) ? '已选择' : '未选择'}`)
      .enabled(!this.busy).onClick(action)
  }

  @Builder
  deletionConfirmation(label: string) {
    Column({ space: 8 }) {
      Text(label).fontSize(16).fontColor($r('app.color.text_danger'))
      Button(this.busy ? '正在删除…' : '确认删除')
        .constraintSize({ minHeight: 48 }).width('100%').fontColor($r('app.color.text_danger'))
        .backgroundColor($r('app.color.card')).enabled(!this.busy).onClick(() => this.deleteRecords())
      Button('取消').constraintSize({ minHeight: 48 }).width('100%').fontColor($r('app.color.action'))
        .backgroundColor($r('app.color.card')).enabled(!this.busy).onClick(() => this.pendingDelete = '')
    }.width('100%')
  }

  build() {
    Scroll(this.scroller) {
      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text('城市自然观察').fontSize(26).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          Text('发现身边植物，留下自己的观察').fontSize(17).fontColor($r('app.color.text_secondary'))
        }.width('100%').alignItems(HorizontalAlign.Start)
        Column({ space: 8 }) {
          Text('个人观察 · 未鉴定').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_notice'))
          Text('记录肉眼所见，不推断物种或健康状况。观察时不采摘、不品尝、不打扰。')
            .fontSize(16).fontColor($r('app.color.text_notice'))
          Text('仅在你点击保存后写入本机；不拍照、不定位、不上传。')
            .fontSize(16).fontColor($r('app.color.text_notice'))
        }.padding(16).backgroundColor($r('app.color.notice')).borderRadius(18).width('100%')
        if (!this.ready) {
          Column({ space: 8 }) {
            Text(this.storageError).fontSize(16).fontColor($r('app.color.text_danger'))
            Button('重新读取本机记录').constraintSize({ minHeight: 48 }).onClick(() => this.loadRecords())
          }.padding(16).backgroundColor($r('app.color.card')).borderRadius(18).width('100%')
        }
        Column({ space: 8 }) {
          Text('1. 选择观察任务').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          ForEach(TASKS, (item: string) => { this.option(item, () => this.selectTask(item)); }, (item: string) => item)
          Text(guidanceFor(this.task)).fontSize(16).fontColor($r('app.color.text_secondary'))
        }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
        Column({ space: 8 }) {
          Text('2. 选择粗略环境').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          Text('只记环境类别，不记录具体地点。').fontSize(16).fontColor($r('app.color.text_secondary'))
          ForEach(PLACES, (item: string) => { this.option(item, () => this.selectPlace(item)); }, (item: string) => item)
        }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
        if (this.task !== '') {
          Column({ space: 8 }) {
            Text(`3. 观察${this.task}特征`).fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
            Text('可多选。“暂时看不清”会替换其他选项；花果“未见”与“看到”不能同时选择。')
              .fontSize(16).fontColor($r('app.color.text_secondary'))
            ForEach(optionsFor(this.task), (item: string) => {
              this.option(item, () => this.selectFeature(item));
            }, (item: string) => item)
          }.padding(20).backgroundColor($r('app.color.card')).borderRadius(20).width('100%')
        }
        if (this.records.length >= MAX_RECORDS) {
          Text('本机已保存10条观察。请先删除不需要的记录，再保存新的观察。').fontSize(16).fontColor($r('app.color.text_notice'))
        } else if (!validSelection(this.task, this.place, this.features)) {
          Text(this.task === '' ? '先选择一项观察任务。' : this.place === '' ? '再选择观察环境。' : '至少选择一个可见特征，也可以选择暂时看不清。')
            .fontSize(16).fontColor($r('app.color.text_secondary'))
        }
        Button(this.busy ? '正在处理…' : '保存本次观察到本机')
          .width('100%').constraintSize({ minHeight: 54 }).padding(14).borderRadius(15)
          .backgroundColor($r('app.color.action')).fontColor($r('app.color.on_action')).fontSize(17)
          .enabled(this.canSave()).onClick(() => this.saveObservation())
        if (this.message !== '') {
          Text(this.message).fontSize(16).fontColor($r('app.color.text_primary')).width('100%')
        }
        Column({ space: 12 }) {
          Text(`本机观察 · ${this.records.length}/10`).fontSize(22).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          Text('按保存时间回顾；可逐条删除或清空。未保存的选择在退出后丢弃。卸载或清除应用数据后记录不可恢复。')
            .fontSize(16).fontColor($r('app.color.text_secondary'))
          if (this.ready && this.records.length === 0) {
            Text('还没有保存的观察。从一株身边的植物开始吧。').fontSize(17).fontColor($r('app.color.text_secondary'))
          }
          ForEach(this.records, (record: Observation) => {
            Column({ space: 10 }) {
              Text(`${record.place} · ${record.task}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
              Text('个人观察，未鉴定').fontSize(16).fontColor($r('app.color.text_success'))
              Text(this.dateLabel(record.createdAt)).fontSize(16).fontColor($r('app.color.text_secondary'))
              Text(record.features.join('；')).fontSize(17).fontColor($r('app.color.text_primary'))
              Text(guidanceFor(record.task)).fontSize(16).fontColor($r('app.color.text_secondary'))
              Button('再次观察同类特征').constraintSize({ minHeight: 48 }).width('100%')
                .fontColor($r('app.color.action')).backgroundColor($r('app.color.card')).enabled(!this.busy)
                .onClick(() => this.revisit(record))
              if (this.pendingDelete === record.id) {
                this.deletionConfirmation(`删除这条${record.place}的${record.task}观察？删除后无法恢复。`)
              } else {
                Button('删除这条观察').constraintSize({ minHeight: 48 }).width('100%')
                  .fontColor($r('app.color.text_danger')).backgroundColor($r('app.color.card')).enabled(!this.busy && this.ready)
                  .accessibilityText(`删除${this.dateLabel(record.createdAt)}的${record.place}${record.task}观察，需要确认`)
                  .onClick(() => { this.pendingDelete = record.id; this.message = ''; })
              }
            }.padding(18).backgroundColor($r('app.color.active')).borderRadius(18).width('100%').alignItems(HorizontalAlign.Start)
          }, (record: Observation) => record.id)
          if (this.records.length > 0) {
            if (this.pendingDelete === 'all') {
              this.deletionConfirmation(`清空全部${this.records.length}条本机观察？此操作无法恢复。`)
            } else {
              Button('清空全部本机观察').constraintSize({ minHeight: 48 }).width('100%')
                .fontColor($r('app.color.text_danger')).backgroundColor($r('app.color.card')).enabled(!this.busy && this.ready)
                .onClick(() => { this.pendingDelete = 'all'; this.message = ''; })
            }
          }
        }.width('100%').alignItems(HorizontalAlign.Start)
      }.padding({ left: 20, right: 20, top: 28, bottom: 36 }).alignItems(HorizontalAlign.Start).width('100%')
    }.width('100%').height('100%').backgroundColor($r('app.color.canvas'))
  }
}
