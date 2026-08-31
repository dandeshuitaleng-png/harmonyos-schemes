# drill-event: 创建本机演练事件

> Route/entry: `pages/Index` · Status: Implemented · Updated: 2026-08-31

## 1. Purpose

- 用户目标：在离线演练中选择一种本地事件并创建记录，确认应用没有向外发送任何信息；紧急情况能打开系统电话，且明白本应用不是官方报警。
- 主操作：选择 `SOS 演练`、`避险点`、`道路障碍` 或 `物资点` 后，创建对应本机记录。
- 不得发生：不能声称已报警、已联系他人、已上传、已获得定位或已建立近场通信；界面不得使用官方警情红作为品牌主色。
- 数据源：应用私有 Preferences 内的 `DrillRecord[]` 与已选演练包 ID；记录仅保存本地标识、创建时间、固定类型、已选演练包、来源（本机演练）、来源版本、接收时间、冲突组、冲突状态、位置精度（未添加位置）与审核状态（未提交）。当前不会伪造近场接收或冲突数据。
- 权限：本切片不请求任何权限。

## 2. Compact wireframe and hierarchy

```text
[Safe-area]
[标题 北斗邻援 + 文字徽章「演练」]
[副标题：离线优先 · 不是官方报警]
[P0 紧急：系统电话说明 + 打开系统电话]
[P0 当前演练状态：离线、加载/条数/错误]
[P1 本机演练包：两种内置提示；明确不是地图下载]
[P1 类型芯片 ×4，已选择用文字「已选择」]
[主操作：创建所选类型的本机记录]
[P1 记录列表：空态 / 卡片（类型、时间、字段分行、仅本机）]
[P2 字段预览、逐项确认后才能打开系统分享、确认后才能清除]
[P2 能力边界 + 查看隐私说明]
```

| Priority | Region | ArkUI | Tokens | Interaction |
| --- | --- | --- | --- | --- |
| P0 | 紧急电话 | Column + Button | surface_warning, text_warning, action_primary | 打开系统拨号，失败则页内文字恢复 |
| P0 | 演练状态 | Column | surface_status, text_primary/muted/warning/success | 只读；错误时下方重试 |
| P1 | 本机演练包 | Column + Button | surface_card, action_primary, border_subtle | 选择仅本机保存；每项写明不是地图下载/官方指引 |
| P1 | 类型选择 | 双列 Button 芯片 | 未选 surface_status+border_subtle；已选 action_primary | 文字含「已选择」 |
| P1 | 创建记录 | Button 全宽 ≥48vp | action_primary, text_on_primary | 未同意/加载中不显示或 disabled |
| P1 | 记录卡 | Column 列表 | surface_card, border_subtle | 显示文字化冲突状态；预览展开/收起 |
| P2 | 分享前预览 | Column + Button | surface_card, surface_warning, action_primary | 先显示完整文本；取消不改本机记录；只打开系统分享面板 |
| P2 | 清除 | 二次确认 Button | text_danger 仅在确认态 | 第一次进入确认，第二次执行 |

紧凑手机单列滚动；平板 `maxWidth 640vp`，信息不改优先级。

## 3. Layout and adaptation

- 安全区：`expandSafeArea` TOP/BOTTOM；内边距 16/20/28，块距 16。
- 大字号：标题、状态、主按钮、类型名允许换行，元数据拆成带标签的多行，不用单行 `·` 拼接。
- Light/Dark：`color.json` / `dark/element/color.json` 同名语义色。
- 无键盘输入本切片。

## 4. Component tree

```text
Scroll
└── Column
    ├── Header（标题 + 演练徽章）
    ├── EmergencyCard
    ├── StatusCard
    ├── LocalDrillPackSelector + TypeChips + CreateButton | 隐私未同意引导
    ├── ErrorRetry（可选）
    ├── RecordList（空/载/卡 + 确认清除）
    └── BoundaryCard

SharePreview（独立页面）：完整文本 → 打开系统分享面板 | 取消返回
```

## 5. State model

| State | Trigger | Visible | Recovery |
| --- | --- | --- | --- |
| Boot loading | 首次进入 | 「正在读取本机状态」 | 自动结束 |
| Privacy | 无选择或主动查看 | 隐私说明；同意/仅电话 | 系统返回可退出说明（已有选择时） |
| Declined | 拒绝保存 | 电话入口；不读记录；引导去说明 | 阅读并同意 |
| Loading | 读 Preferences | 状态与列表为「正在读取」；创建不可用 | 自动完成 |
| Empty | 已同意且无记录 | 类型选择 + 空态说明 | 创建 |
| Local drill pack | 已同意且点选内置提示 | 当前包写为「已启用」；保存选择 | 失败时显示重试；不称为地图下载 |
| Success | 写入成功 | 卡片显示类型/时间/来源/精度/未提交 +「仅本机」 | 可再创建或预览 |
| Preview | 查看字段预览 | 分行字段；含来源版本/接收时间/冲突组；写明未导出、未外发 | 收起 |
| Share preview | 点「预览后使用系统分享」 | 完整文本、系统分享边界与取消 | 确认后仅拉起系统面板；失败可重试 |
| Confirm clear | 点清除一次 | 危险文案按钮 + 取消 | 确认执行或取消 |
| Offline | 始终 | 「没有网络请求，也不会上传」 | 无需恢复 |
| Permission unavailable | 始终 | 文字说明未请求定位/联系人 | 不伪造已授权 |
| Error | 读写失败 | 错误原因 + 重试 | 重试；不伪造已保存 |
| Dialer failed | 无法打开电话 | 请使用系统电话应用拨 110/119/120 | 退出应用改用系统电话 |

## 6. Accessibility, motion, QA

- 读屏顺序：标题 → 演练徽章 → 紧急电话 → 状态 → 类型 → 创建 → 记录 → 清除 → 边界。
- 类型与记录状态必须有文字，不能只靠颜色。
- 触控目标 ≥48vp；透明按钮同样设最小高度。
- 无装饰动画；系统按下态即可。
- 必采截图（真机可用后）：隐私、拒绝后主页、空态、演练包启用、四类创建后、字段预览、分享前预览、分享取消/失败、清除确认、错误（若可造）、浅/深色、150% 字号。当前无签名安装则 Visual **BLOCKED**。
