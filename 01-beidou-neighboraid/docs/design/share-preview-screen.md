# share-preview: 本机演练记录的分享前预览

> Route/entry: `pages/Index` 的内部视图 `sharePreviewView()` · Status: Implemented / runtime unverified · Updated: 2026-09-04

## 1. Purpose

- 用户目标：先逐项阅读一条本机演练记录将被交给系统分享面板的文本，再明确选择打开系统面板或取消；取消不能修改本机记录。
- 主操作：`确认内容并打开系统分享面板`。该动作只调用系统面板，后续接收者与发送行为由用户在系统界面选择。
- 不得发生：不得自动选择接收者、上传到服务端、生成文件、暗示已通知他人或已获审核；不在此路径请求定位、联系人、存储或网络权限。
- 数据源与触发：来自已选择 `DrillRecord` 的 `shareText(record)`；仅包含类型、创建时间、演练包、位置精度、来源、接收时间、冲突状态、审核状态和边界说明。点击记录卡的“预览后使用系统分享”后显示。
- 前置条件：本机记录已加载，且预览文本非空。若系统面板无法打开，必须留在本页显示重试路径。

## 2. Compact wireframe and hierarchy

```text
[Safe-area header: 分享前预览]
[P0 边界说明：不会自动发送；打开后由用户选择接收目标]
[P1 完整字段文本，按行可读、可滚动]
[P0 确认内容并打开系统分享面板]
[P1 取消，不分享]
[错误：无法打开系统面板 + 重试 / 返回]
```

| Priority | Region/content | ArkUI component | Token references | Visibility/interaction |
| --- | --- | --- | --- | --- |
| P0 | 标题与边界说明 | `Text` + warning `Column` | `text_primary`, `surface_warning`, `text_warning` | 位于文本前，明确“由你选择接收目标” |
| P1 | 字段文本 | 主 `Scroll` 内 `Text` | `surface_card`, `text_primary`, `border_subtle` | 完整换行，不截断；不提供复制成功或已导出的误导性提示 |
| P0 | 确认分享 | 全宽原生 `Button` | `action_primary`, `text_on_primary` | 最小 48vp；调用系统分享面板前不改变记录 |
| P1 | 取消 | 原生文本按钮 | `action_primary` | 返回原记录位置；不清除、保存或上传任何内容 |
| P1 | 错误恢复 | warning `Column` + 重试按钮 | `surface_warning`, `text_warning`, `action_primary` | 仅在 `ShareController.show` 失败后出现 |

## 3. Layout and adaptation

- 紧凑手机：页面内容在一个纵向主滚动区；底部不是固定栏，保证大字号时确认与取消仍可依序滚动到达。横向 20vp，区块间 16vp。
- 平板/横屏：与主页面一致限制为 `maxWidth 640vp`；长字段文本不铺满更宽屏，使用 16fp / 24vp 行高，按字段换行。
- 系统返回：优先关闭分享前预览并回到原记录列表，不清空 `previewRecordId`、不触发分享；系统面板打开后的返回行为交由系统处理。
- 深浅色：仅使用现有 Light/Dark 同名 token；警示说明与确认按钮均以正文明确含义，颜色不是唯一状态载体。
- 动效：仅使用系统页面/按下反馈；不能在打开系统面板前播放“发送成功”动效。系统面板失败时保持当前文本和布局不变。

## 4. Component tree and contracts

```text
Index
└── sharePreviewView
    ├── Title
    ├── BoundaryNotice
    ├── ShareTextCard
    ├── ConfirmSystemShareButton
    ├── CancelButton
    └── ShareFailureRecovery (conditional)
```

| Component | Variant | Inputs/state | Event/output | Reuse or new component |
| --- | --- | --- | --- | --- |
| `sharePreviewView` | normal / failure | `sharePreviewTitle`, `sharePreviewText`, `storageError` | confirm or cancel | 已有 Builder；保留内部视图，不新增伪路由 |
| Confirm button | enabled / requesting / failure | non-empty text; `isOpeningShare` | `sharePreview()` | 已实现：请求期间禁用以防重复点击，文字改为“正在打开…” |
| Cancel button | normal / failure | current preview | `showSharePreview = false` | 已实现：请求期间不显示取消入口，避免中断系统面板打开过程 |
| `ShareController` boundary | system handled / unavailable | text/title | system share panel or thrown error | 系统能力；应用不应判断发送是否完成 |

## 5. State model

| State | Trigger | Visible content | Action/recovery | Data/UI contract |
| --- | --- | --- | --- | --- |
| Normal | `openSharePreview(record)` | 边界说明、完整字段、确认、取消 | 确认或取消 | 文本只在内存中；记录不变 |
| Text unavailable | 文本为空或记录缺字段 | “无法准备分享文本” + 返回 | 回到记录并重新查看字段 | 不打开系统面板，不生成替代内容 |
| Opening system panel | 点击确认 | 保持原文本；确认按钮不可重复触发，显示“正在打开…” | 等待 `ShareController.show` 返回 | 不能显示“已发送”；系统返回不关闭流程 |
| System panel shown | `ShareController.show` 成功 | 返回主页面后提示“已打开系统分享面板” | 由用户在系统面板决定 | 只可称“已打开”，不可称“已分享” |
| Share failure | `ShareController.show` 抛错 | 原文本、失败原因、重试、取消 | 重试或返回 | 本机记录没有修改、上传或导出 |
| Back / cancel | 系统返回或取消 | 回记录列表 | 无副作用 | 保留记录与字段预览状态 |

## 6. Accessibility, motion, and QA

- 读屏顺序：标题 → 边界说明 → 字段文本 → 确认分享 → 取消 → 失败提示/重试。确认按钮读作“确认内容并打开系统分享面板”，不得写成“发送”。
- 每个操作目标 ≥48vp，确认与取消之间至少 8vp；无横向滑动、手势唯一入口或图标唯一入口。
- 文本字段必须按行输出，屏幕阅读器可连续读取；对“未提交”“未添加位置”等缺失能力给文字说明，不能靠颜色猜测。
- 运行时必测：打开预览 → 取消 → 确认并在系统面板返回 → 让系统面板失败后重试；还要检查最大字号、深浅色、横屏与从预览按系统返回。
- 当前状态：请求态、重复点击防护、失败重试与取消路径已写入页面源码；但无当前签名安装包、设备或截图，系统面板、读屏、动态字号、深浅色和横屏运行验收均为 **BLOCKED**。
