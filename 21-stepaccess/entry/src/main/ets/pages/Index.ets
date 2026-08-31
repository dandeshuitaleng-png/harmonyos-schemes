import { NewObservation, Observation, ObservationStore } from '../data/ObservationStore';

const OBSTACLE_TYPES: string[] = ['路缘坡', '台阶', '临时障碍', '路面破损'];
const ASSISTIVE_CONTEXTS: string[] = ['轮椅', '助行器', '婴儿车', '低视力出行'];
const PASSAGE_FEELINGS: string[] = ['可以独立通过', '需要他人协助', '当前不建议通过'];
const OBSTACLE_FILTER_TYPES: string[] = ['全部', '路缘坡', '台阶', '临时障碍', '路面破损'];
const CONTEXT_FILTER_TYPES: string[] = ['全部', '轮椅', '助行器', '婴儿车', '低视力出行'];
const FEELING_FILTER_TYPES: string[] = ['全部', '可以独立通过', '需要他人协助', '当前不建议通过'];

@Entry
@Component
struct Index {
  private readonly observationStore: ObservationStore = new ObservationStore();
  @State private obstacleType: string = '';
  @State private assistiveContext: string = '';
  @State private passageFeeling: string = '';
  @State private observations: Observation[] = [];
  @State private obstacleFilter: string = '全部';
  @State private contextFilter: string = '全部';
  @State private feelingFilter: string = '全部';
  @State private isLoading: boolean = true;
  @State private storageError: string = '';
  @State private confirmDeleteId: number = 0;

  aboutToAppear(): void {
    this.loadObservations();
  }

  onBackPress(): boolean {
    if (this.confirmDeleteId !== 0) {
      this.confirmDeleteId = 0;
      return true;
    }
    return false;
  }

  private hostContext(): Context {
    return getContext(this);
  }

  private canCreate(): boolean {
    return this.obstacleType !== '' && this.assistiveContext !== '' && this.passageFeeling !== '';
  }

  private hasActiveFilters(): boolean {
    return this.obstacleFilter !== '全部' || this.contextFilter !== '全部' || this.feelingFilter !== '全部';
  }

  private clearFilters(): void {
    this.obstacleFilter = '全部'; this.contextFilter = '全部'; this.feelingFilter = '全部';
  }

  private filteredObservations(): Observation[] {
    return this.observations.filter((observation: Observation) =>
      (this.obstacleFilter === '全部' || observation.obstacleType === this.obstacleFilter) &&
      (this.contextFilter === '全部' || observation.assistiveContext === this.contextFilter) &&
      (this.feelingFilter === '全部' || observation.passageFeeling === this.feelingFilter)
    );
  }

  private formatDateTime(): string {
    const now: Date = new Date();
    const month: string = (now.getMonth() + 1).toString().padStart(2, '0');
    const day: string = now.getDate().toString().padStart(2, '0');
    const hour: string = now.getHours().toString().padStart(2, '0');
    const minute: string = now.getMinutes().toString().padStart(2, '0');
    return `${now.getFullYear()}-${month}-${day} ${hour}:${minute}`;
  }

  private async loadObservations(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      this.observations = await this.observationStore.load(this.hostContext());
    } catch {
      this.storageError = '无法读取本机观察记录。请重试；不会影响任何外部服务。';
    } finally {
      this.isLoading = false;
    }
  }

  private async createObservation(): Promise<void> {
    if (!this.canCreate() || this.isLoading) {
      return;
    }
    this.isLoading = true;
    this.storageError = '';
    try {
      const observation: NewObservation = {
        obstacleType: this.obstacleType,
        assistiveContext: this.assistiveContext,
        passageFeeling: this.passageFeeling,
        createdAt: this.formatDateTime(),
        visibility: '仅自己可见',
        reviewStatus: '未经审核'
      };
      await this.observationStore.create(this.hostContext(), observation);
      this.obstacleType = '';
      this.assistiveContext = '';
      this.passageFeeling = '';
      this.observations = await this.observationStore.load(this.hostContext());
    } catch {
      this.storageError = '无法保存本机观察。请重试；本应用没有上传任何数据。';
    } finally {
      this.isLoading = false;
    }
  }

  private async removeObservation(id: number): Promise<void> {
    if (this.isLoading) {
      return;
    }
    if (this.confirmDeleteId !== id) {
      this.confirmDeleteId = id;
      return;
    }
    this.isLoading = true;
    this.storageError = '';
    try {
      await this.observationStore.remove(this.hostContext(), id);
      this.observations = await this.observationStore.load(this.hostContext());
      this.confirmDeleteId = 0;
    } catch {
      this.storageError = '无法删除本机观察。请重试；本应用没有上传任何数据。';
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  private selectionGroup(title: string, choices: string[], selected: string, prefix: string, onSelect: (item: string) => void) {
    Column({ space: 10 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      ForEach(choices, (item: string) => {
        Button(selected === item ? `${item} · 已选择` : item)
          .width('100%')
          .constraintSize({ minHeight: 50 })
          .borderRadius(15)
          .backgroundColor(selected === item ? $r('app.color.surface_selected') : $r('app.color.surface_control'))
          .fontColor($r('app.color.text_primary'))
          .accessibilityText(selected === item ? `已选择${prefix}${item}` : `选择${prefix}${item}`)
          .onClick(() => onSelect(item))
      }, (item: string) => item)
    }
    .padding(20)
    .backgroundColor($r('app.color.surface_card'))
    .borderRadius(20)
    .width('100%')
  }

  @Builder
  private filterGroup(title: string, choices: string[], selected: string, prefix: string, onSelect: (item: string) => void) {
    Column({ space: 8 }) {
      Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('app.color.text_primary'))
      ForEach(choices, (item: string) => {
        Button(selected === item ? `${item} · 已筛选` : item)
          .width('100%')
          .constraintSize({ minHeight: 48 })
          .borderRadius(14)
          .backgroundColor(selected === item ? $r('app.color.surface_selected') : $r('app.color.surface_control'))
          .fontColor($r('app.color.text_primary'))
          .accessibilityText(selected === item ? `当前${prefix}筛选为${item}` : `按${prefix}${item}筛选本机观察`)
          .onClick(() => onSelect(item))
      }, (item: string) => item)
    }.padding(14).backgroundColor($r('app.color.surface_card')).borderRadius(18).width('100%')
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('步道通')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .lineHeight(34)
        Text('记录本人当下的步道通行感受')
          .fontSize(17)
          .fontColor($r('app.color.text_secondary'))
          .lineHeight(24)
        Text('非导航')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .padding({ left: 10, right: 10, top: 8, bottom: 8 })
          .backgroundColor($r('app.color.surface_warning'))
          .borderRadius(8)
          .alignSelf(ItemAlign.Start)
          .accessibilityText('不代表官方无障碍认证或实时导航')

        Column({ space: 6 }) {
          Text('个人观察 · 未经审核')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_warning'))
          Text('不代表官方无障碍认证、路线安全或对所有人都可通行。')
            .fontSize(15)
            .fontColor($r('app.color.text_warning'))
          Text('本切片只保存手动选择与时间到本机关系型数据库；不添加位置、照片或网络权限。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .padding(18)
        .backgroundColor($r('app.color.surface_warning'))
        .borderRadius(20)
        .width('100%')

        this.selectionGroup('1. 观察到什么？', OBSTACLE_TYPES, this.obstacleType, '障碍类型', (item: string) => this.obstacleType = item)
        this.selectionGroup('2. 当时使用什么方式？', ASSISTIVE_CONTEXTS, this.assistiveContext, '出行情境', (item: string) => this.assistiveContext = item)
        this.selectionGroup('3. 本人的通行感受', PASSAGE_FEELINGS, this.passageFeeling, '通行感受', (item: string) => this.passageFeeling = item)

        if (!this.canCreate()) {
          Text('依次选择障碍、出行情境和通行感受后，才能创建观察。')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        Button('创建本机观察')
          .width('100%')
          .constraintSize({ minHeight: 56 })
          .borderRadius(16)
          .backgroundColor($r('app.color.action_primary'))
          .fontColor($r('app.color.text_on_primary'))
          .enabled(this.canCreate() && !this.isLoading)
          .accessibilityText(this.canCreate() && !this.isLoading ? '创建一条仅保存在本机的未经审核步道观察' : '请先完成三个选择或等待本机记录读取完成')
          .onClick(() => this.createObservation())

        Column({ space: 10 }) {
          Text('筛选本机观察').fontSize(20).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary'))
          Text('筛选只改变当前列表，不会修改本机观察数据。').fontSize(14).fontColor($r('app.color.text_secondary'))
          this.filterGroup('障碍类型', OBSTACLE_FILTER_TYPES, this.obstacleFilter, '障碍类型', (item: string) => this.obstacleFilter = item)
          this.filterGroup('出行情境', CONTEXT_FILTER_TYPES, this.contextFilter, '出行情境', (item: string) => this.contextFilter = item)
          this.filterGroup('本人通行感受', FEELING_FILTER_TYPES, this.feelingFilter, '通行感受', (item: string) => this.feelingFilter = item)
          if (this.hasActiveFilters()) { Button('清除筛选').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText('清除全部本机观察筛选').onClick(() => this.clearFilters()) }
        }.padding(20).backgroundColor($r('app.color.surface_card')).borderRadius(20).width('100%')

        if (this.storageError.length > 0) {
          Column({ space: 8 }) {
            Text(this.storageError)
              .fontSize(14)
              .fontColor($r('app.color.text_warning'))
            Button('重试读取本机观察')
              .fontSize(15)
              .fontColor($r('app.color.action_primary'))
              .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 })
              .onClick(() => this.loadObservations())
          }
          .padding(16)
          .backgroundColor($r('app.color.surface_warning'))
          .borderRadius(16)
          .width('100%')
        }

        Column({ space: 10 }) {
          Text('我的本机观察')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          if (this.isLoading) {
            Text('正在读取本机观察记录…')
              .fontSize(15)
              .fontColor($r('app.color.text_secondary'))
          } else if (this.observations.length === 0) {
            Text('尚无本机观察。创建后会保留到你主动删除；不会上传或用于评分。')
              .fontSize(15)
              .fontColor($r('app.color.text_secondary'))
          } else if (this.filteredObservations().length === 0) {
            Text('没有符合当前筛选的本机观察。清除筛选后可查看全部记录。')
              .fontSize(15)
              .fontColor($r('app.color.text_secondary'))
            Button('清除筛选并查看全部').fontColor($r('app.color.action_primary')).backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 48 }).accessibilityText('清除筛选并查看全部本机观察').onClick(() => this.clearFilters())
          } else {
            ForEach(this.filteredObservations(), (observation: Observation) => {
              Column({ space: 6 }) {
                Text(`${observation.obstacleType} · ${observation.assistiveContext}`)
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                Text(observation.passageFeeling)
                  .fontSize(15)
                  .fontColor($r('app.color.text_primary'))
                Text(`${observation.createdAt} · ${observation.visibility} · ${observation.reviewStatus}`)
                  .fontSize(13)
                  .fontColor($r('app.color.text_secondary'))
                if (this.confirmDeleteId === observation.id) {
                  Text('删除后无法从本应用恢复这条本机观察。没有向外发送任何数据。')
                    .fontSize(14)
                    .lineHeight(22)
                    .fontColor($r('app.color.text_danger'))
                  Button('确认删除这条本机观察')
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_danger'))
                    .backgroundColor($r('app.color.surface_warning'))
                    .constraintSize({ minHeight: 48 })
                    .accessibilityText(`确认删除${observation.createdAt}创建的本机观察，此操作不能撤销`)
                    .onClick(() => this.removeObservation(observation.id))
                  Button('取消删除')
                    .fontSize(15)
                    .fontColor($r('app.color.action_primary'))
                    .backgroundColor(Color.Transparent)
                    .constraintSize({ minHeight: 48 })
                    .onClick(() => this.confirmDeleteId = 0)
                } else {
                  Button('删除这条本机观察')
                    .fontSize(15)
                    .fontColor($r('app.color.action_primary'))
                    .backgroundColor(Color.Transparent)
                    .constraintSize({ minHeight: 48 })
                    .accessibilityText(`准备删除${observation.createdAt}创建的本机观察，下一步需要确认`)
                    .onClick(() => this.removeObservation(observation.id))
                }
              }
              .padding(16)
              .backgroundColor($r('app.color.surface_success'))
              .borderRadius(16)
              .width('100%')
            }, (observation: Observation) => observation.id.toString())
          }
        }
        .padding(20)
        .backgroundColor($r('app.color.surface_card'))
        .borderRadius(20)
        .width('100%')
      }
      .padding({ left: 20, right: 20, top: 28, bottom: 36 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.surface_canvas'))
  }
}
