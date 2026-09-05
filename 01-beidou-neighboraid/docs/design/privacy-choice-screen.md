# privacy-choice: 本机演练记录的隐私选择

> Route/entry: `pages/Index` 的内部视图 `policyView()` · Status: Implemented / runtime unverified · Updated: 2026-09-05

## 1. Purpose

- 用户目标：在任何本机记录写入前，理解当前版本会保存和不会保存什么，并在“同意本机保存”与“仅使用系统电话”之间作出可逆、清晰的选择。
- 主操作：`同意并继续`，仅用于允许 Preferences 保存本机演练记录与选择；它不代表同意网络上传、定位、联系人、报警或第三方处理。
- 明确替代路径：`仅使用系统电话，不保存记录`，保存拒绝选择后进入没有本机记录功能的主页；该路径仍提供系统电话入口。
- 不得发生：不得把不同意设置为不可退出的死路、不得把拒绝称为错误、不得预选同意、不得将本机保存描绘为官方报警或救援服务。
- 数据源与前置：`privacyChoice` 从 `DrillRecordStore.loadPrivacyChoice()` 读取；同意/拒绝分别通过 `savePrivacyChoice()` 写入应用私有 Preferences。当前不申请任何系统权限，也不发出网络请求。

## 2. Compact wireframe and hierarchy

```text
[Safe-area title: 隐私说明]
[P0 服务边界：离线演练，非官方报警；系统电话入口保留]
[P1 不申请/不接入的能力列表]
[P1 同意后本机保存字段 + 不保存字段]
[P0 同意并继续]
[P1 仅使用系统电话，不保存记录]
[P2 已有选择时：返回]
[错误：无法保存选择 + 重试当前选择]
```

| Priority | Region/content | ArkUI component | Token references | Visibility/interaction |
| --- | --- | --- | --- | --- |
| P0 | 非官方报警与能力边界 | warning `Column` + `Text` | `surface_warning`, `text_warning` | 位于选择按钮前；文字说明系统电话而非应用报警 |
| P1 | 本机保存与不保存字段 | `Column` + 分段 `Text` | `surface_card`, `text_primary`, `text_secondary` | 可读的多行文本；不依赖图标或颜色 |
| P0 | 同意并继续 | 全宽原生 `Button` | `action_primary`, `text_on_primary` | 最小 48vp；保存成功后开始读取本机记录 |
| P1 | 仅使用系统电话 | 原生文本按钮 | `action_primary` | 最小 48vp；明确“不会保存记录” |
| P2 | 返回 | 原生文本按钮 | `action_primary` | 仅已有选择且主动查看说明时显示 |
| P1 | 保存失败恢复 | warning `Column` + 对应重试按钮 | `surface_warning`, `text_warning`, `action_primary` | 就近说明失败的本机操作和重试，不展示网络错误 |

## 3. Layout and adaptation

- 紧凑手机：保持单一主滚动区；横向 20vp，区块间 16vp，选择按钮不固定在底部，避免大字号遮挡替代路径。
- 平板/横屏：最大内容宽度 640vp；长说明文本保持 16fp / 24vp 行高，不拆成并排隐私条款或压缩为单行。
- 系统返回：首次尚无选择时交给系统返回，不默认写入拒绝；已有选择且从主页进入说明时，系统返回只关闭说明页，不改变已保存选择。
- 深浅色与动效：使用现有语义 token；按下反馈使用系统默认，保存中/失败不能仅以颜色表示，后续实现应以文字和禁用态说明状态。

## 4. Component tree and contracts

```text
Index
└── policyView
    ├── TitleAndContext
    ├── SafetyBoundaryNotice
    ├── LocalStorageDisclosure
    ├── AcceptLocalStorageButton
    ├── DeclineAndDialerOnlyButton
    ├── BackButton (conditional)
    └── PrivacyStorageErrorRecovery (conditional)
```

| Component | Variant | Inputs/state | Event/output | Reuse or new component |
| --- | --- | --- | --- | --- |
| `policyView` | first decision / revisit / storage failure | `privacyChoice`, `storageError` | accept, decline, back | 已有 Builder；不新增路由 |
| Accept button | enabled / saving / failure | `isSavingPrivacyChoice`, `PRIVACY_ACCEPTED` | `acceptPrivacy()` | 已实现：保存中禁用，文字说明“正在保存…” |
| Decline button | enabled / saving / failure | `isSavingPrivacyChoice`, `PRIVACY_DECLINED` | `declinePrivacy()` | 已实现：保存中暂不显示，防止两种选择并发写入 |
| `DrillRecordStore` | load / save choice | string choice | Promise success/failure | 仅 Preferences；不扩展为权限或网络控制器 |

## 5. State model

| State | Trigger | Visible content | Action/recovery | Data/UI contract |
| --- | --- | --- | --- | --- |
| First decision | `privacyChoice` 为空 | 完整说明、同意、仅电话 | 选择任一项或系统返回 | 尚不读取/写入演练记录 |
| Accepted | 保存 `accepted` 成功 | 返回主页并加载本机记录 | 以后可主动查看说明并返回 | 仅允许本机 Preferences 行为 |
| Declined | 保存 `declined` 成功 | 主页保留系统电话与重新阅读说明入口 | 可重新阅读并改为同意 | 不读、不展示记录与演练包选择 |
| Saving | 点击任一选择 | 明确“正在保存本机选择”；两项不可重复点击 | 成功或显示失败 | 不提前切换业务界面 |
| Storage error | 读取或保存 Preferences 失败 | 原因、当前选择未确认、对应重试 | 重试读取或原选择 | 不虚称选择已保存；不涉及外部服务 |
| Revisit | 已有选择后打开说明 | 显示返回 | 返回原主页 | 系统返回不改变选择 |

## 6. Accessibility, motion, and QA

- 读屏顺序：标题 → 非官方报警边界 → 不申请能力 → 保存/不保存字段 → 同意 → 仅电话 → 返回 → 错误/重试。两种选择的读屏文案需清晰区分后果。
- 同意与拒绝均使用不小于 48vp 的原生按钮，文字目标之间保留至少 8vp；拒绝不应使用低对比、灰掉或难以发现的样式。
- 保存失败文本必须说明“无法保存本机选择”和重试动作；同意、拒绝和返回都不能依赖颜色或手势唯一操作。
- 运行时必测：首次进入 → 拒绝 → 重启后仍不读记录 → 再阅读并同意 → 重启恢复同意 → Preferences 读取/写入失败后的重试 → 深浅色、150% 字号、横屏、读屏和系统返回。
- 当前状态：请求态、重复点击防护与按原选择重试已写入 `policyView()`；当前没有签名安装包、可用设备或截图，所有运行时、读屏和视觉检查均为 **BLOCKED**。
