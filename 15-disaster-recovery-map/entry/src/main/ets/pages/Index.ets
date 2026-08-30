import { common, Want } from '@kit.AbilityKit';
import {
  ObservationRecord,
  ObservationStore,
  ObservationType,
  PRIVACY_ACCEPTED,
  PRIVACY_DECLINED
} from '../data/ObservationStore';

const phenomenonKinds: string[] = ['风暴', '天空', '水域', '地貌', '生灵'];

@Entry
@Component
struct Index {
  private readonly observationStore: ObservationStore = new ObservationStore();
  @State private activePage: string = '观测';
  @State private selectedKind: string = '风暴';
  @State private scannerOpen: boolean = false;
  @State private scannerStep: number = 0;
  @State private selectedResult: ObservationType = '暴雨云团';
  @State private observationPlace: string = '';
  @State private observationNote: string = '';
  @State private records: ObservationRecord[] = [];
  @State private profileOpen: boolean = false;
  @State private sourceOpen: boolean = false;
  @State private isLoading: boolean = true;
  @State private storageError: string = '';
  @State private privacyChoice: string = '';
  @State private privacyReady: boolean = false;
  @State private showPolicy: boolean = false;

  aboutToAppear(): void {
    this.bootstrap();
  }

  onBackPress(): boolean {
    if (this.sourceOpen) {
      this.sourceOpen = false;
      return true;
    }
    if (this.scannerOpen) {
      this.closeScanner();
      return true;
    }
    if (this.profileOpen) {
      this.profileOpen = false;
      return true;
    }
    if (this.showPolicy && this.privacyChoice.length > 0) {
      this.showPolicy = false;
      return true;
    }
    return false;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        if (!this.privacyReady) {
          this.loadingView()
        } else if (this.privacyChoice.length === 0 || this.showPolicy) {
          this.policyView()
        } else if (this.activePage === '观测') {
          this.observationPage()
        } else {
          this.learnPage()
        }
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r('app.color.page_background'))

      if (this.privacyReady && this.privacyChoice.length > 0 && !this.showPolicy) {
        this.bottomNavigation()
      }

      if (this.scannerOpen) {
        this.scannerSheet()
      }
      if (this.profileOpen) {
        this.profileSheet()
      }
      if (this.sourceOpen) {
        this.sourceSheet()
      }
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  private loadingView() {
    Column() {
      Text('正在读取本机状态…')
        .fontSize(16)
        .fontColor($r('app.color.ink_muted'))
        .padding(28)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private policyView() {
    Scroll() {
      Column({ space: 16 }) {
        Text('隐私说明')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink'))
        Text('地球 Online · 观测站 · com.naturalcollect.app')
          .fontSize(15)
          .fontColor($r('app.color.ink_muted'))
        Column({ space: 8 }) {
          Text('本应用用于在本机留下未核验的自然目击线索，不是预报、图像识别或官方应急服务。')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.notice_ink'))
          Text('紧急情况请使用系统电话。本页不提供避险指引，也不替代 110 / 119 / 120。')
            .fontSize(14)
            .fontColor($r('app.color.notice_ink'))
        }
        .padding(16)
        .backgroundColor($r('app.color.notice_surface'))
        .borderRadius(16)
        .width('100%')
        Column({ space: 8 }) {
          Text('若你选择同意并继续，本机可能保存：你确认的现象类型、可选地点与备注、记录时间、来源分级「未核验公众线索」，以及你对隐私说明的选择。')
            .fontSize(15)
            .fontColor($r('app.color.ink'))
          Text('本版使用内置示例照片，不申请相机、相册、定位、麦克风或联系人权限，也不接入网络、账号、推送或第三方识别服务。')
            .fontSize(15)
            .fontColor($r('app.color.ink'))
          Text('开发者主体名称以华为应用市场登记信息为准。公开隐私政策网址尚未提供，因此本页是当前唯一完整说明。')
            .fontSize(14)
            .fontColor($r('app.color.ink_muted'))
        }
        .padding(20)
        .backgroundColor($r('app.color.surface'))
        .borderRadius(20)
        .width('100%')
        Button('同意并继续')
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .constraintSize({ minHeight: 52 })
          .backgroundColor($r('app.color.ice'))
          .fontColor($r('app.color.ink_on_ice'))
          .borderRadius(14)
          .accessibilityText('同意隐私说明并继续在本机保存目击线索')
          .onClick(() => this.acceptPrivacy())
        Button('仅浏览科普，不保存记录')
          .fontSize(16)
          .fontColor($r('app.color.accent'))
          .backgroundColor(Color.Transparent)
          .constraintSize({ minHeight: 48 })
          .accessibilityText('拒绝保存本机记录，仅浏览科普')
          .onClick(() => this.declinePrivacy())
        if (this.privacyChoice.length > 0) {
          Button('返回')
            .fontSize(16)
            .fontColor($r('app.color.accent'))
            .backgroundColor(Color.Transparent)
            .constraintSize({ minHeight: 44 })
            .onClick(() => this.showPolicy = false)
        }
        if (this.storageError.length > 0) {
          Text(this.storageError)
            .fontSize(14)
            .fontColor($r('app.color.notice_ink'))
            .padding(14)
            .backgroundColor($r('app.color.notice_surface'))
            .borderRadius(14)
            .width('100%')
        }
      }
      .padding({ left: 20, right: 20, top: 28, bottom: 36 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .constraintSize({ maxWidth: 640 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    .align(Alignment.Top)
  }

  @Builder
  private observationPage() {
    Scroll() {
      Column({ space: 24 }) {
        this.header()

        Column({ space: 8 }) {
          Text('地球 Online')
            .fontSize(34)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.ink'))
          Text('观测站')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.accent'))
          Text('用示例照片留下一条本机目击线索。')
            .fontSize(15)
            .fontColor($r('app.color.ink_muted'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        this.exploreHero()

        Column({ space: 12 }) {
          Text('你正在观察什么？')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.ink'))
          Scroll() {
            Row({ space: 8 }) {
              ForEach(phenomenonKinds, (kind: string) => {
                Button(kind)
                  .fontSize(14)
                  .fontWeight(this.selectedKind === kind ? FontWeight.Medium : FontWeight.Regular)
                  .fontColor(this.selectedKind === kind ? $r('app.color.ink') : $r('app.color.ink_muted'))
                  .backgroundColor(this.selectedKind === kind ? $r('app.color.accent_soft') : $r('app.color.surface'))
                  .border({
                    width: 1,
                    color: this.selectedKind === kind ? $r('app.color.accent') : $r('app.color.line')
                  })
                  .borderRadius(18)
                  .constraintSize({ minHeight: 38 })
                  .padding({ left: 16, right: 16 })
                  .onClick((): void => {
                    this.selectedKind = kind;
                  })
              }, (kind: string) => kind)
            }
            .padding({ right: 20 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        }
        .width('100%')

        this.quietNotice()

        if (this.storageError.length > 0) {
          Column({ space: 8 }) {
            Text(this.storageError)
              .fontSize(14)
              .fontColor($r('app.color.notice_ink'))
            Button('重试读取本机状态')
              .fontSize(15)
              .fontColor($r('app.color.accent'))
              .backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 40 })
              .onClick(() => this.bootstrap())
          }
          .padding(16)
          .backgroundColor($r('app.color.notice_surface'))
          .borderRadius(16)
          .width('100%')
        }
      }
      .width('100%')
      .constraintSize({ maxWidth: 640 })
      .padding({ left: 20, right: 20, top: 18, bottom: 104 })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .layoutWeight(1)
    .align(Alignment.Top)
  }

  @Builder
  private header() {
    Row() {
      Column({ space: 3 }) {
        Text('NATURAL OBSERVATION')
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.ink_subtle'))
          .letterSpacing(1.5)
        Text('眼前的地球')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.ink'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button('N')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ink'))
        .width(42)
        .constraintSize({ minHeight: 42 })
        .backgroundColor($r('app.color.surface_elevated'))
        .border({ width: 1, color: $r('app.color.line') })
        .borderRadius(21)
        .accessibilityText('打开我的观测记录')
        .onClick((): void => {
          this.profileOpen = true;
        })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private exploreHero() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image($r('app.media.typhoon_coast_unsplash'))
        .width('100%')
        .height(338)
        .objectFit(ImageFit.Cover)
        .borderRadius(24)
        .accessibilityText('示例风暴海岸照片，摄影 Marcus Woodbridge')

      Column()
        .width('100%')
        .height(338)
        .borderRadius(24)
        .backgroundColor($r('app.color.photo_overlay'))

      Column({ space: 14 }) {
        Column({ space: 5 }) {
          Text('把一瞬间留下来')
            .fontSize(27)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.photo_title'))
          Text('本版没有相机或识别，只用这张示例照片。')
            .fontSize(14)
            .fontColor($r('app.color.photo_caption'))
        }
        .alignItems(HorizontalAlign.Start)

        Button(this.privacyChoice === PRIVACY_ACCEPTED ? '用示例记录' : '阅读隐私说明后记录')
          .constraintSize({ minWidth: 132, minHeight: 44 })
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.ink_on_ice'))
          .backgroundColor($r('app.color.ice'))
          .borderRadius(22)
          .padding({ left: 18, right: 18 })
          .accessibilityText(this.privacyChoice === PRIVACY_ACCEPTED
            ? '用内置示例照片创建一条本机目击线索'
            : '先阅读隐私说明，再保存本机目击线索')
          .onClick((): void => {
            this.startRecordFlow();
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding(22)
    }
    .width('100%')
    .height(338)
    .borderRadius(24)
  }

  @Builder
  private quietNotice() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Text('注意')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.notice_ink'))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor($r('app.color.notice_surface'))
          .borderRadius(8)
        Text('观测站用于记录和认识自然，不提供灾害影响评估或避险指引。')
          .fontSize(13)
          .lineHeight(20)
          .fontColor($r('app.color.ink_muted'))
          .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Button('打开系统电话')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .constraintSize({ minHeight: 44 })
        .backgroundColor($r('app.color.accent_soft'))
        .fontColor($r('app.color.ink'))
        .borderRadius(14)
        .accessibilityText('打开系统电话拨号界面，不由本应用拨出号码')
        .onClick(() => this.openSystemDialer())

      Text('示例照片：Marcus Woodbridge / Unsplash。正式发布前仍需复核使用方式。')
        .fontSize(12)
        .lineHeight(18)
        .fontColor($r('app.color.ink_subtle'))
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .border({ width: 1, color: $r('app.color.line') })
    .borderRadius(18)
  }

  @Builder
  private learnPage() {
    Scroll() {
      Column({ space: 22 }) {
        this.header()

        Column({ space: 7 }) {
          Text('自然小课')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.ink'))
          Text('从你看到的现象开始理解自然。')
            .fontSize(15)
            .fontColor($r('app.color.ink_muted'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Stack({ alignContent: Alignment.BottomStart }) {
          Image($r('app.media.typhoon_coast_unsplash'))
            .width('100%')
            .height(230)
            .objectFit(ImageFit.Cover)
            .borderRadius(24)
            .accessibilityText('示例风暴海岸照片')
          Column()
            .width('100%')
            .height(230)
            .borderRadius(24)
            .backgroundColor($r('app.color.photo_overlay'))
          Text('积雨云与强对流')
            .fontSize(23)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.photo_title'))
            .padding(20)
        }
        .width('100%')
        .height(230)

        Column({ space: 16 }) {
          this.factBlock('它是什么', '积雨云是垂直发展很强的云体，底部常显得低沉而厚重。')
          this.factBlock('可以观察什么', '云底是否压低、边缘是否翻滚、光线是否突然变暗。')
          this.factBlock('容易混淆什么', '层积云覆盖范围更广，但通常没有明显向上翻涌的轮廓。')
        }
        .width('100%')
        .padding(20)
        .backgroundColor($r('app.color.surface'))
        .border({ width: 1, color: $r('app.color.line') })
        .borderRadius(22)

        Button(this.privacyChoice === PRIVACY_ACCEPTED ? '用示例继续记录' : '阅读隐私说明后记录')
          .width('100%')
          .constraintSize({ minHeight: 52 })
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.ink_on_ice'))
          .backgroundColor($r('app.color.ice'))
          .borderRadius(16)
          .onClick((): void => {
            this.startRecordFlow();
          })
      }
      .width('100%')
      .constraintSize({ maxWidth: 640 })
      .padding({ left: 20, right: 20, top: 18, bottom: 104 })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .layoutWeight(1)
    .align(Alignment.Top)
  }

  @Builder
  private factBlock(title: string, content: string) {
    Column({ space: 5 }) {
      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.accent'))
      Text(content)
        .fontSize(15)
        .lineHeight(22)
        .fontColor($r('app.color.ink'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private bottomNavigation() {
    Row() {
      this.navItem('观测', '◉')

      Button('记录')
        .width(86)
        .constraintSize({ minHeight: 50 })
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ink_on_ice'))
        .backgroundColor($r('app.color.ice'))
        .borderRadius(25)
        .accessibilityText('开始用示例照片记录目击线索')
        .onClick((): void => {
          this.startRecordFlow();
        })

      this.navItem('科普', '✦')
    }
    .width('100%')
    .constraintSize({ minHeight: 82 })
    .padding({ left: 32, right: 32, top: 10, bottom: 14 })
    .backgroundColor($r('app.color.nav_background'))
    .border({ width: { top: 1 }, color: $r('app.color.line') })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  private navItem(label: string, symbol: string) {
    Button() {
      Column({ space: 3 }) {
        Text(symbol)
          .fontSize(18)
          .fontColor(this.activePage === label ? $r('app.color.ice') : $r('app.color.ink_subtle'))
        Text(label)
          .fontSize(12)
          .fontWeight(this.activePage === label ? FontWeight.Medium : FontWeight.Regular)
          .fontColor(this.activePage === label ? $r('app.color.ink') : $r('app.color.ink_muted'))
      }
    }
    .width(58)
    .constraintSize({ minHeight: 54 })
    .backgroundColor(Color.Transparent)
    .accessibilityText(label === '观测' ? '打开观测页' : '打开科普页')
    .onClick((): void => {
      this.activePage = label;
    })
  }

  @Builder
  private scannerSheet() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.overlay_dim'))
        .onClick((): void => {
          this.closeScanner();
        })

      Scroll() {
        Column({ space: 18 }) {
          Row() {
            Column({ space: 4 }) {
              Text(this.scannerTitle())
                .fontSize(25)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.ink'))
              Text(this.scannerSubtitle())
                .fontSize(13)
                .fontColor($r('app.color.ink_muted'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Button('关闭')
              .fontSize(13)
              .fontColor($r('app.color.accent'))
              .backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 40 })
              .onClick((): void => {
                this.closeScanner();
              })
          }
          .width('100%')

          if (this.scannerStep === 0) {
            this.captureStep()
          } else if (this.scannerStep === 1) {
            this.confirmStep()
          } else {
            this.savedStep()
          }

          if (this.storageError.length > 0 && this.scannerStep === 1) {
            Text(this.storageError)
              .fontSize(14)
              .fontColor($r('app.color.notice_ink'))
              .padding(14)
              .backgroundColor($r('app.color.notice_surface'))
              .borderRadius(14)
              .width('100%')
          }
        }
        .width('100%')
        .constraintSize({ maxWidth: 640 })
        .padding(22)
      }
      .width('100%')
      .constraintSize({ maxHeight: '88%' })
      .backgroundColor($r('app.color.surface_elevated'))
      .border({ width: { top: 1 }, color: $r('app.color.line') })
      .borderRadius({ topLeft: 28, topRight: 28 })
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private captureStep() {
    Column({ space: 14 }) {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.typhoon_coast_unsplash'))
          .width('100%')
          .height(168)
          .objectFit(ImageFit.Cover)
          .borderRadius(18)
          .accessibilityText('示例现场照片')
        Text('示例现场照片')
          .fontSize(14)
          .fontColor($r('app.color.photo_title'))
          .padding({ left: 12, right: 12, top: 7, bottom: 7 })
          .backgroundColor($r('app.color.photo_overlay'))
          .borderRadius(14)
      }
      .width('100%')
      .height(168)

      Text('这不是相机取景，也没有图像识别。选择最接近的描述后，线索只会保存在本机。')
        .fontSize(13)
        .lineHeight(19)
        .fontColor($r('app.color.ink_muted'))
        .width('100%')

      Button('用这张示例照片记录')
        .width('100%')
        .constraintSize({ minHeight: 52 })
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ink_on_ice'))
        .backgroundColor($r('app.color.ice'))
        .borderRadius(16)
        .onClick((): void => {
          this.scannerStep = 1;
        })
    }
    .width('100%')
  }

  @Builder
  private confirmStep() {
    Column({ space: 12 }) {
      Text('选择最接近的描述')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ink'))
        .width('100%')

      this.resultChoice('暴雨云团')
      this.resultChoice('台风外雨带')
      this.resultChoice('山洪水迹')
      this.resultChoice('潮汐变化')

      TextInput({ text: this.observationPlace, placeholder: '观察地点（可选，仅本机）' })
        .constraintSize({ minHeight: 48 })
        .fontSize(14)
        .fontColor($r('app.color.ink'))
        .placeholderColor($r('app.color.ink_subtle'))
        .backgroundColor($r('app.color.surface'))
        .border({ width: 1, color: $r('app.color.line') })
        .borderRadius(14)
        .padding({ left: 15, right: 15 })
        .onChange((value: string): void => {
          this.observationPlace = value;
        })

      TextInput({ text: this.observationNote, placeholder: '这一刻的补充（可选，仅本机）' })
        .constraintSize({ minHeight: 48 })
        .fontSize(14)
        .fontColor($r('app.color.ink'))
        .placeholderColor($r('app.color.ink_subtle'))
        .backgroundColor($r('app.color.surface'))
        .border({ width: 1, color: $r('app.color.line') })
        .borderRadius(14)
        .padding({ left: 15, right: 15 })
        .onChange((value: string): void => {
          this.observationNote = value;
        })

      Button('确认并保存到本机')
        .width('100%')
        .constraintSize({ minHeight: 52 })
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ink_on_ice'))
        .backgroundColor($r('app.color.ice'))
        .borderRadius(16)
        .margin({ top: 4 })
        .enabled(!this.isLoading)
        .accessibilityText('把当前目击线索保存到本机，不向外发送')
        .onClick((): void => {
          this.saveObservation();
        })

      Button('为什么标为公众线索？')
        .fontSize(13)
        .fontColor($r('app.color.accent'))
        .backgroundColor(Color.Transparent)
        .constraintSize({ minHeight: 40 })
        .width('100%')
        .onClick((): void => {
          this.sourceOpen = true;
        })
    }
    .width('100%')
  }

  @Builder
  private resultChoice(label: ObservationType) {
    Button() {
      Row() {
        Text(label)
          .fontSize(15)
          .fontColor($r('app.color.ink'))
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
        if (this.selectedResult === label) {
          Text('已选')
            .fontSize(13)
            .fontColor($r('app.color.ice'))
        }
      }
      .width('100%')
    }
    .width('100%')
    .constraintSize({ minHeight: 48 })
    .padding({ left: 15, right: 15 })
    .backgroundColor(this.selectedResult === label ? $r('app.color.accent_soft') : $r('app.color.surface'))
    .border({
      width: 1,
      color: this.selectedResult === label ? $r('app.color.accent') : $r('app.color.line')
    })
    .borderRadius(14)
    .accessibilityText(this.selectedResult === label ? `已选择${label}` : `选择${label}`)
    .onClick((): void => {
      this.selectedResult = label;
    })
  }

  @Builder
  private savedStep() {
    Column({ space: 12 }) {
      Text('已保存')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ice'))
      Text('已留下一条自然目击')
        .fontSize(19)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ink'))
      Text(`已保存为「${this.selectedResult}」，当前标记为未核验公众线索。线索不是事实，也不会上传。`)
        .fontSize(13)
        .lineHeight(20)
        .fontColor($r('app.color.ink_muted'))
      if (this.observationPlace.length > 0) {
        Text(`地点：${this.observationPlace}`)
          .fontSize(13)
          .fontColor($r('app.color.ink_muted'))
      }
      Button('回到观测站')
        .width('100%')
        .constraintSize({ minHeight: 52 })
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ink_on_ice'))
        .backgroundColor($r('app.color.ice'))
        .borderRadius(16)
        .margin({ top: 8 })
        .onClick((): void => {
          this.closeScanner();
          this.activePage = '观测';
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private profileSheet() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.overlay_dim'))
        .onClick((): void => {
          this.profileOpen = false;
        })

      Scroll() {
        Column({ space: 15 }) {
          Row() {
            Text('我的观测')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.ink'))
              .layoutWeight(1)
            Button('关闭')
              .fontSize(13)
              .fontColor($r('app.color.accent'))
              .backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 40 })
              .onClick((): void => {
                this.profileOpen = false;
              })
          }
          .width('100%')

          if (this.privacyChoice !== PRIVACY_ACCEPTED) {
            Text('当前未开启本机保存，因此不读取或显示目击线索。')
              .fontSize(14)
              .lineHeight(21)
              .fontColor($r('app.color.ink_muted'))
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.surface'))
              .border({ width: 1, color: $r('app.color.line') })
              .borderRadius(16)
            Button('阅读隐私说明并允许保存')
              .fontSize(15)
              .fontColor($r('app.color.accent'))
              .backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 44 })
              .onClick((): void => {
                this.profileOpen = false;
                this.showPolicy = true;
              })
          } else if (this.isLoading) {
            Text('正在读取本机目击线索，请稍候。')
              .fontSize(14)
              .fontColor($r('app.color.ink_muted'))
              .width('100%')
          } else if (this.records.length > 0) {
            ForEach(this.records, (record: ObservationRecord) => {
              this.profileRecord(record)
            }, (record: ObservationRecord) => record.id)
            Button('清除全部本机目击线索')
              .fontSize(15)
              .fontColor($r('app.color.accent'))
              .backgroundColor(Color.Transparent)
              .constraintSize({ minHeight: 44 })
              .accessibilityText('清除全部保存在本机的目击线索')
              .onClick(() => this.clearRecords())
          } else {
            Text('还没有本机目击线索。可从示例照片开始记录。')
              .fontSize(14)
              .lineHeight(21)
              .fontColor($r('app.color.ink_muted'))
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.surface'))
              .border({ width: 1, color: $r('app.color.line') })
              .borderRadius(16)
          }

          if (this.storageError.length > 0) {
            Column({ space: 8 }) {
              Text(this.storageError)
                .fontSize(14)
                .fontColor($r('app.color.notice_ink'))
              Button('重试读取本机状态')
                .fontSize(15)
                .fontColor($r('app.color.accent'))
                .backgroundColor(Color.Transparent)
                .onClick(() => this.bootstrap())
            }
            .padding(16)
            .backgroundColor($r('app.color.notice_surface'))
            .borderRadius(16)
            .width('100%')
          }

          Button('查看隐私说明')
            .fontSize(15)
            .fontColor($r('app.color.accent'))
            .backgroundColor(Color.Transparent)
            .constraintSize({ minHeight: 44 })
            .onClick((): void => {
              this.profileOpen = false;
              this.showPolicy = true;
            })
        }
        .width('100%')
        .constraintSize({ maxWidth: 640 })
        .padding(22)
      }
      .width('100%')
      .constraintSize({ maxHeight: '88%' })
      .backgroundColor($r('app.color.surface_elevated'))
      .border({ width: { top: 1 }, color: $r('app.color.line') })
      .borderRadius({ topLeft: 28, topRight: 28 })
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private sourceSheet() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.overlay_dim'))
        .onClick((): void => {
          this.sourceOpen = false;
        })

      Column({ space: 12 }) {
        Text('信息从哪里来？')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.ink'))
        this.sourceLine('权威发布', '具名政府部门、科研机构或正式公告。本版不生成此类信息。')
        this.sourceLine('已核验协作信息', '来源、时间或地点经过协作核验。本版不生成此类信息。')
        this.sourceLine('未核验公众线索', '由个人记录，保存为线索而非确认事实。本版只产生这一级。')
        Button('知道了')
          .width('100%')
          .constraintSize({ minHeight: 50 })
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.ink_on_ice'))
          .backgroundColor($r('app.color.ice'))
          .borderRadius(16)
          .margin({ top: 6 })
          .onClick((): void => {
            this.sourceOpen = false;
          })
      }
      .width('100%')
      .constraintSize({ maxWidth: 640 })
      .padding(22)
      .backgroundColor($r('app.color.surface_elevated'))
      .border({ width: { top: 1 }, color: $r('app.color.line') })
      .borderRadius({ topLeft: 28, topRight: 28 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private sourceLine(title: string, detail: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.accent'))
      Text(detail)
        .fontSize(13)
        .lineHeight(19)
        .fontColor($r('app.color.ink_muted'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor($r('app.color.surface'))
    .border({ width: 1, color: $r('app.color.line') })
    .borderRadius(15)
  }

  @Builder
  private profileRecord(record: ObservationRecord) {
    Column({ space: 5 }) {
      Text(record.kind)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.ink'))
      Text(`${this.recordStamp(record)} · ${record.sourceLevel} · 仅本机`)
        .fontSize(13)
        .fontColor($r('app.color.ink_muted'))
      if (record.place.length > 0) {
        Text(record.place)
          .fontSize(13)
          .fontColor($r('app.color.ink_muted'))
      }
      if (record.note.length > 0) {
        Text(record.note)
          .fontSize(13)
          .lineHeight(19)
          .fontColor($r('app.color.ink_muted'))
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor($r('app.color.surface'))
    .border({ width: 1, color: $r('app.color.line') })
    .borderRadius(16)
  }

  private hostContext(): Context {
    return getContext(this);
  }

  private startRecordFlow(): void {
    if (this.privacyChoice !== PRIVACY_ACCEPTED) {
      this.showPolicy = true;
      return;
    }
    this.openScanner();
  }

  private openScanner(): void {
    this.scannerOpen = true;
    this.scannerStep = 0;
    this.selectedResult = this.kindToResult(this.selectedKind);
    this.observationPlace = '';
    this.observationNote = '';
    this.storageError = '';
  }

  private closeScanner(): void {
    this.scannerOpen = false;
    this.scannerStep = 0;
  }

  private kindToResult(kind: string): ObservationType {
    if (kind === '水域') {
      return '潮汐变化';
    }
    if (kind === '地貌') {
      return '山洪水迹';
    }
    return '暴雨云团';
  }

  private scannerTitle(): string {
    if (this.scannerStep === 0) {
      return '用示例记录';
    }
    if (this.scannerStep === 1) {
      return '由你确认';
    }
    return '这一刻已记录';
  }

  private scannerSubtitle(): string {
    if (this.scannerStep === 0) {
      return '内置示例，不是相机画面。';
    }
    if (this.scannerStep === 1) {
      return '选择最符合你看到的自然现象。';
    }
    return '可在右上角查看已保存的本机线索。';
  }

  private async bootstrap(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      this.privacyChoice = await this.observationStore.loadPrivacyChoice(this.hostContext());
      this.privacyReady = true;
      if (this.privacyChoice === PRIVACY_ACCEPTED) {
        await this.loadRecords();
        return;
      }
      this.records = [];
    } catch {
      this.privacyReady = true;
      this.storageError = '无法读取本机隐私选择。请重试；不会影响任何外部服务。';
    } finally {
      this.isLoading = false;
    }
  }

  private async loadRecords(): Promise<void> {
    this.isLoading = true;
    this.storageError = '';
    try {
      this.records = await this.observationStore.load(this.hostContext());
    } catch {
      this.storageError = '无法读取本机目击线索。请重试；不会影响任何外部服务。';
    } finally {
      this.isLoading = false;
    }
  }

  private async acceptPrivacy(): Promise<void> {
    try {
      await this.observationStore.savePrivacyChoice(this.hostContext(), PRIVACY_ACCEPTED);
      this.privacyChoice = PRIVACY_ACCEPTED;
      this.showPolicy = false;
      this.storageError = '';
      await this.loadRecords();
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传任何内容。';
    }
  }

  private async declinePrivacy(): Promise<void> {
    try {
      await this.observationStore.savePrivacyChoice(this.hostContext(), PRIVACY_DECLINED);
      this.privacyChoice = PRIVACY_DECLINED;
      this.showPolicy = false;
      this.records = [];
      this.storageError = '';
    } catch {
      this.storageError = '无法保存隐私选择。请重试；没有上传任何内容。';
    }
  }

  private async saveObservation(): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    const record: ObservationRecord =
      this.observationStore.create(this.selectedResult, this.observationPlace, this.observationNote);
    const updatedRecords: ObservationRecord[] = [record, ...this.records];
    try {
      await this.observationStore.save(this.hostContext(), updatedRecords);
      this.records = updatedRecords;
      this.storageError = '';
      this.scannerStep = 2;
    } catch {
      this.storageError = '无法保存本机目击线索。请重试；没有上传任何内容。';
    }
  }

  private async clearRecords(): Promise<void> {
    if (this.isLoading || this.privacyChoice !== PRIVACY_ACCEPTED) {
      return;
    }
    try {
      await this.observationStore.clear(this.hostContext());
      this.records = [];
      this.storageError = '';
    } catch {
      this.storageError = '无法清除本机目击线索。请重试；没有上传任何内容。';
    }
  }

  private async openSystemDialer(): Promise<void> {
    try {
      const context = this.hostContext() as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.dial',
        uri: 'tel:'
      };
      await context.startAbility(want);
    } catch {
      this.storageError = '无法打开系统电话。请退出本应用，使用系统电话应用拨打 110/119/120。';
    }
  }

  private recordStamp(record: ObservationRecord): string {
    const date: Date = new Date(record.observedAt);
    const year: string = date.getFullYear().toString();
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    const hour: string = date.getHours().toString().padStart(2, '0');
    const minute: string = date.getMinutes().toString().padStart(2, '0');
    return `${year}-${month}-${day} ${hour}:${minute}`;
  }
}
