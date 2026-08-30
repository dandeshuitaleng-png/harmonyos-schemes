import { NewObservation, Observation, ObservationStore } from '../data/ObservationStore';

const OBSTACLE_TYPES: string[] = ['路缘坡', '台阶', '临时障碍', '路面破损'];
const ASSISTIVE_CONTEXTS: string[] = ['轮椅', '助行器', '婴儿车', '低视力出行'];
const PASSAGE_FEELINGS: string[] = ['可以独立通过', '需要他人协助', '当前不建议通过'];

@Entry
@Component
struct Index {
  private readonly observationStore: ObservationStore = new ObservationStore();
  @State private obstacleType: string = '';
  @State private assistiveContext: string = '';
  @State private passageFeeling: string = '';
  @State private observations: Observation[] = [];
  @State private isLoading: boolean = true;
  @State private storageError: string = '';

  aboutToAppear(): void {
    this.loadObservations();
  }

  private hostContext(): Context {
    return getContext(this);
  }

  private canCreate(): boolean {
    return this.obstacleType !== '' && this.assistiveContext !== '' && this.passageFeeling !== '';
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
    this.isLoading = true;
    this.storageError = '';
    try {
      await this.observationStore.remove(this.hostContext(), id);
      this.observations = await this.observationStore.load(this.hostContext());
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

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('步道通')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Text('记录本人当下的步道通行感受')
          .fontSize(17)
          .fontColor($r('app.color.text_secondary'))

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

        if (this.storageError.length > 0) {
          Column({ space: 8 }) {
            Text(this.storageError)
              .fontSize(14)
              .fontColor($r('app.color.text_warning'))
            Button('重试读取本机观察')
              .fontSize(15)
              .fontColor($r('app.color.action_primary'))
              .backgroundColor(Color.Transparent)
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
          } else {
            ForEach(this.observations, (observation: Observation) => {
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
                Button('删除这条本机观察')
                  .fontSize(15)
                  .fontColor($r('app.color.action_primary'))
                  .backgroundColor(Color.Transparent)
                  .accessibilityText(`删除${observation.createdAt}创建的本机观察`)
                  .onClick(() => this.removeObservation(observation.id))
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
