# 食材管家 · 本机食材清单

> Route: `pages/Index` · Status: Implemented · Updated: 2026-09-03

## 1. Purpose

- User goal: 在本机记下食材与自己填写的日期，按日期远近先处理更近的条目。
- Primary action or explicit choice state: 保存一条本机记录；点选一条生成今日优先消耗提示。
- What must not happen: 不把排序说成保质期或食品安全结论；不接条码、购物、营养、菜谱、网络。
- Data source and loading trigger: 本机 preferences；`aboutToAppear` 读取。
- Preconditions/permissions: 无权限。拒绝权限不适用；不申请相机/通知。

## 2. Compact wireframe and hierarchy

```text
[Safe-area 标题「食材管家」+ 徽章「非安全建议」]
[P0 边界说明：日期由你填写，排序不是可否食用]
[P0 新建：名称（必填）/ 记下的日期 YYYY-MM-DD（必填）/ 存放位置（可选）]
[主操作：保存本机食材]
[P1 今日优先消耗（仅在已选择时）]
[P1 按日期排序的列表 · 点选 / 确认删除]
```

| Priority | Region/content | ArkUI component | Token references | Visibility/interaction |
| --- | --- | --- | --- | --- |
| P0 | 标题与非安全建议徽章 | `Row` + `Text` | `text_primary` / `notice` | 始终可见 |
| P0 | 边界说明 | `Column` | `notice` / `text_notice` | 始终可见 |
| P0 | 新建表单与保存 | `Text` 标签 + `TextInput` + `Button` | `card` / `action` | 保存未填齐时禁用 |
| P1 | 今日提示 | `Column` + 清除 | `active` / `text_success` | 仅已选择 |
| P1 | 排序列表 | `ForEach` + 点选/删除 | `card` / `notice` / `active` | 空/载/错见状态表 |

## 3. Layout and adaptation

- Compact layout order and scroll container: 单列 `Scroll`，表单在列表之上，主按钮滑一层能到。
- Expanded/tablet/foldable adaptation: `maxWidth 640`，只降密度，不改信息优先级。
- Safe-area, keyboard, and sticky-action behavior: 系统安全区；输入时随页面上移，不把主按钮钉死在手势条上。
- Text scaling/localization expansion behavior: 标题、按钮、状态文字允许换行，不截成省略。
- Light/Dark mapping and visual assets: 本轮仅浅色语义色；无插图。

## 4. Component tree and contracts

```text
Index
├── Header（标题 + 非安全建议）
├── BoundaryNotice
├── AddForm（可见标签 + 保存）
├── ErrorBanner（可选 · 重试）
├── TodayHint（可选 · 清除选择）
└── PantryList（加载 / 空 / 条目）
    └── PantryRow（已选择文案 + 删除确认）
```

| Component | Variant | Inputs/state | Event/output | Reuse or new component |
| --- | --- | --- | --- | --- |
| Header | 默认 | — | — | 页内 |
| AddForm | 可保存 / 禁用 | name, notedDate, place | `save` | 页内 |
| PantryRow | 普通 / 已选择 / 确认删除 | item, pickedId, confirmDeleteId | pick, confirm delete | 页内 |

## 5. State model

| State | Trigger | Visible content | Action/recovery | Data/UI contract |
| --- | --- | --- | --- | --- |
| Normal | 读取成功且有记录 | 排序列表；可点选 | 点选或删除 | 仅本机 |
| Loading | 读取或写入中 | 「正在读取或保存本机记录…」 | 等待 | 保存按钮禁用 |
| Empty | 无记录 | 「还没有本机食材记录」+ 指向上方表单 | 去填写名称和日期 | 表单仍可用 |
| Error | 读/写失败 | 原因 + 未上传 | 重试读取；表单输入保留 | 不丢未提交字段 |
| Offline | 始终无网络 | 边界说明写明不使用网络 | 继续本机操作 | 不是错误 |
| Disabled/permission | 名称或日期未填 | 保存禁用 + 说明还差什么 | 补全必填 | 无权限弹窗 |
| Success | 保存成功 | 新条目进入排序列表，表单清空 | 可继续添加或点选 | 重启后仍在 |

## 6. Accessibility, motion, and QA

- Meaningful labels and focus order: 标题 → 徽章 → 表单字段 → 保存 → 列表点选 → 删除。徽章读屏为「不提供食品安全判断」。已选择含「已选择{名称}」。删除分两步，确认含「不能撤销」。
- Non-color state treatment: 「已选择」「更近」「无法按日期排序」用文字；不单靠红色表示过期。
- Touch/gesture and system-back behavior: 触控 ≥48vp。系统返回先取消删除确认，再退出。
- Motion purpose and reduced-motion fallback: 无装饰动效。
- Required runtime paths: 添加两条（含一条非法日期）→ 排序 → 点选 → 清除选择 → 确认删除 → 重启仍在。
- Required screenshots: compact Light 正常/空/错误/已选择。无真机则 Visual BLOCKED。
