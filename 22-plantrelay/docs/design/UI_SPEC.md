# 叶伴 · UI/UX 规格

> Version: 2.0 · Updated: 2026-09-07 · Status: implementation specification

## 概览

核心路径：花园安排真实任务 → 交接确认接手 → 填写完成时间和可选备注 → 本机写入成功 → 足迹回看。趣味来自可轻触软陶盆栽、每张交接卡的三色外观和保存成功反馈。

沿用 preferences `leafmate/cards` 与现有 PlantCard 数据；新增可选 palette:number，不改变旧键名，无 palette 的旧卡默认赤陶。同名昵称的任务不推断为独立植物档案，因此数量称为交接卡。无样例数据、账号、网络、植物识别、健康值、积分、提醒、照片、导出或跨设备能力。

支持 320vp 起手机、平板、深浅色与可缩放系统字体。设计系统见 [MASTER.md](MASTER.md)，语义色为 `resources/base/element/color.json` 与 `resources/dark/element/color.json`。

## 导航与屏幕

```text
pages/Index
├── 花园：交接概况、可轻触软陶盆栽、安排任务入口
├── 交接：待接手、已接手的未完成任务
└── 足迹：持久化成功的完成记录
    原生全页子视图：新建 / 完成 / 本机摘要 / 关于
```

| ID | 用户目标 | 入口 | 详细规格 |
| --- | --- | --- | --- |
| SCR-01 | 理解真实概况并安排任务 | 默认花园 tab | playful-garden-screen.md |
| SCR-02 | 接手并记录完成 | 交接 tab、花园入口 | playful-garden-screen.md |
| SCR-03 | 回看完成时间和备注 | 足迹 tab | playful-garden-screen.md |
| SCR-04 | 自选摘要包含的字段 | 任务卡本机摘要 | playful-garden-screen.md |

旧 `task-confirmation-screen.md` 为 2026-08-31 历史单页说明，本版替代布局和视觉，保留真实状态约束。新建、完成、摘要和关于在同一原生页面导航状态中渐进呈现，系统返回回原入口。

## 共用组件

| 组件 | 状态归属 | 使用处 | 契约 |
| --- | --- | --- | --- |
| ClayPlant | 页面外观状态 + 组件局部动画 | 花园主景、可选小图 | clay-plant-component.md |
| 交接卡 | 真实 cards 与 card.id | 交接、足迹 | 完成前后不复制记录 |
| 完成表单 | completingCardId / completionDate / completionNote | 已接手任务 | 时间必填，写入成功才清空和庆祝 |
| 摘要字段 | exportCardId 与既有 include* | 交接、足迹 | 仅预览，照护人与备注默认隐藏 |
| 底部导航 | selectedTab | 三 tab | 图标与文字、显式选中 |

## 设计决策

| 决策 | 规则 | 理由 |
| --- | --- | --- |
| 信息结构 | 花园 / 交接 / 足迹 | 将主景、执行、回看分开，减轻首屏表单负担 |
| 渐进表单 | 用户主动进入全页表单 | 适应小屏和键盘，保存/取消可滚到 |
| 任务状态 | 未确认 → 已接手 → 已完成 | 保留既有真实持久化契约 |
| 可玩性 | 轻触、三配色、单次成功庆祝 | 外观操作不伪造照护结果 |
| 美术与 UI | UI 语义色，Canvas 集中美术色 | 渐变有稳定形体，UI 可单独检查对比度 |
| 减少动效 | 页内开关 + AccessibilityKit 系统状态监听 | 用户偏好与系统偏好任一开启即停用装饰运动 |
| 平板 | 居中限制宽度或主景/概况双栏 | 保持同一内容优先级 |

## 证据边界

| 项目 | 证据 | 状态 |
| --- | --- | --- |
| 设计系统 | MASTER + base/dark 20 色 | Specified |
| 页面与组件规格 | 本规格、playful-garden-screen、clay-plant-component | Specified |
| ArkUI 实现与构建 | 由实际源文件与构建输出确定 | Pending implementation verification |
| 运行视觉与无障碍 | 需要当前截图、150% 字号与读屏验证 | BLOCKED until evidence |

规格不代表构建成功或设备通过，最终状态以实际工作流台账与证据为准。
