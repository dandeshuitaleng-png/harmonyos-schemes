# offline-drill-pack: 选择本机演练包

> Route/entry: `pages/Index`（主页面内的渐进披露区，暂不新增路由） · Status: Implemented / runtime unverified · Updated: 2026-09-02

## 1. Purpose

- 用户目标：在同意本机存储后，为下一条演练记录选择一个已内置的练习语境，并清楚知道它不是离线地图、政府预警或真实救援资料。
- 主操作：选择一项本机演练包；选中的包名会随之后创建的本机记录保存。
- 不得发生：不得显示下载进度、地图缩略图、实时警情、官方来源、网络同步或联系人通知；未同意本机存储时不得保留选择。
- 数据源与加载：`LOCAL_DRILL_PACKS` 是随应用提供的静态提示；当前选择通过 `DrillRecordStore.loadSelectedDrillPackId()` 读取、`saveSelectedDrillPackId()` 保存到应用私有 Preferences。没有网络请求、权限或后台任务。
- 前置条件：仅当隐私选择为 `accepted` 且本机状态读取完成时可选择；否则展示原因和可恢复路径。

## 2. Compact wireframe and hierarchy

```text
[P1 节标题：本机演练包]
[说明：内置提示；不含地图、下载或官方指引]
[包 A：社区基础演练包 + 用途说明 + 选中状态]
[包 B：家庭预案演练包 + 用途说明 + 选中状态]
[P2 当前选择摘要：未启用 / 已启用 {包名}]
[P2 与本机事件类型选择、创建按钮连续出现]
```

| Priority | Region/content | ArkUI component | Token references | Visibility/interaction |
| --- | --- | --- | --- | --- |
| P1 | 节标题与能力说明 | `Column` + `Text` | `text_primary`, `text_secondary` | 始终可见；说明在标题下方，不折叠 |
| P1 | 演练包选项 ×2 | 全宽原生 `Button`，竖向列表 | 未选：`surface_status` + `border_subtle`；选中：`action_primary` + `text_on_primary` | 48vp 最小高度；包名、说明和“已启用”均以文字呈现 |
| P2 | 当前选择摘要 | `Text` 或卡内说明 | `text_secondary` / `text_warning` | 未选择写“未启用本机演练包”；不把空选择视为错误 |
| P2 | 读写错误与重试 | `Text` + 原生文本按钮 | `surface_warning`, `text_warning`, `action_primary` | 显示具体原因；“重试”只重试本机读写，不重试网络 |

## 3. Layout and adaptation

- 紧凑手机：在主 `Scroll` 中位于状态卡之后、事件类型之前；横向 20vp、区块间 16vp、同级触控目标至少间隔 8vp。列表不可横向滚动。
- 平板/横屏：沿用主页面 `maxWidth 640vp`；每个包仍整行可点，说明可换行但不与按钮文字截断冲突，避免把两个包挤成高密度双列。
- 安全区与滚动：不使用固定底栏；创建按钮和演练包都在同一主滚动容器，避免内容被系统手势区域遮挡。
- 大字号与深浅色：包名和说明均允许多行；语义色只来自现有 Light/Dark `color.json`，选中态除颜色外必须包含“已启用”文字。
- 动效：使用系统按下态；选择完成不做弹跳、闪烁或装饰动画。若后续出现加载反馈，仅替换当前摘要内容，不改变按钮布局。

## 4. Component tree and contracts

```text
Index.mainView
└── LocalDrillPackSection
    ├── SectionHeading
    ├── CapabilityBoundaryText
    ├── DrillPackButton (community-basics)
    ├── DrillPackButton (family-preparedness)
    └── SelectionOrStorageFeedback
```

| Component | Variant | Inputs/state | Event/output | Reuse or new component |
| --- | --- | --- | --- | --- |
| `drillPackButton` | unselected / selected / unavailable | `DrillPack`, `selectedDrillPackId`, `isLoading`, `privacyChoice` | `selectDrillPack(drillPack)` | 已实现；加载中禁用并降为 48% 强度，读屏说明暂不可选择 |
| `SelectionOrStorageFeedback` | no selection / selected / error | `selectedDrillPackId`, `storageError` | `loadRecords()` 或专项重试 | 当前可由状态卡承载；不新增伪造数据 |
| `DrillRecordStore` | load / save | Preferences 中的包 ID | Promise 成功或失败 | 已有数据层；不得扩展为下载器 |

## 5. State model

| State | Trigger | Visible content | Action/recovery | Data/UI contract |
| --- | --- | --- | --- | --- |
| Loading | `bootstrap()` 或 `loadRecords()` 读取选择 | “正在读取本机状态”；两个选项不可操作 | 自动结束；失败转 Error | 不猜测上次选择 |
| No selection | 已同意且 ID 为空 | 两个未选选项 + “未启用本机演练包” | 选择任一包 | 允许创建记录，但记录写明未启用 |
| Selected | 保存成功或读取到有效 ID | 对应选项文字“已启用”；状态说明本机保存 | 可改选另一包 | 创建记录复制 `id` 与 `title` |
| Privacy declined / pending | 未同意或读取失败 | 选项不可用；说明“同意本机存储后可选择” | 打开隐私说明或重试读取 | 不读、不写包 ID |
| Storage error | Preferences 读取或写入异常 | 原因：无法读取/保存本机选择；明确没有下载或上传 | 重试同一读写动作 | 不改变内存中的已确认选择 |
| Offline | 始终 | “不含地图、下载或网络请求” | 无恢复要求 | 不显示网络断连、刷新或同步控件 |
| Success | 切换包成功 | 简短状态“已启用{包名}；仅保存在本机” | 继续选择事件类型 | 不宣称已获得避险指引 |

## 6. Accessibility, motion, and QA

- 读屏顺序：节标题 → 能力边界 → 包 A 名称/说明/状态 → 包 B 名称/说明/状态 → 当前选择或错误 → 事件类型。每个按钮的 `accessibilityText` 应包含包名、描述与当前是否启用。
- 状态不只依赖蓝色填充；选中写“已启用”，不可用写出原因，错误文本同时说明恢复操作。
- 每个包操作区不小于 48vp，高亮和按下态不改变布局边界；不使用水平滑动、长按或图标唯一入口。
- 运行时必测：首次同意后空选择 → 选 A → 终止/重启恢复 A → 切换 B → 创建一条记录并核对包字段 → 拒绝隐私后确认选择不可读写 → 模拟 Preferences 错误后的重试。
- 必采截图：紧凑 Light/Dark 的未选择、A 已启用、B 已启用、读写错误；150% 字号与平板/横屏各一张。当前缺少可安装签名包与设备运行证据，因此视觉与无障碍运行验收均为 **BLOCKED**。
