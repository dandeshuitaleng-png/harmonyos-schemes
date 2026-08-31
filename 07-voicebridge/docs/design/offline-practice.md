# VoiceBridge · 离线文字稿练习

> Route: `pages/Index` · Status: Implemented · Updated: 2026-08-31

## Purpose

- 用户目标：选择场景、阅读文字稿、标记本人已练习。
- 主操作：仅标记本次本人练习。
- 不得发生：无音频、AI 评价、能力卡、分享或投递；不评价就业资格。
- 数据：练习标记只存在于本次会话；本机仅可能保存「已阅读」标记。
- 权限：本切片不申请麦克风。

## Hierarchy

```text
[标题 语桥求职 + 徽章「非认证」]
[练习完成不等于资格]
[P1 场景，已选择用文字标出]
[全文文字稿]
[主操作：标记本人练习]
```

平板 `maxWidth 640`；安全区 TOP/BOTTOM。

## States

| State | Visible | Recovery |
| --- | --- | --- |
| Boot / Loading | 正在读取本机状态 | 自动完成 |
| Privacy | 已阅读并继续 | 系统返回可退出说明 |
| Practice | 文字稿全文 | 切换场景重置标记 |
| Marked | 会话内已标记 | 离开页面即消失 |
| Error | 隐私读写失败 | 重试 |

## A11y

读屏：标题 → 徽章 → 场景（含已选择）→ 文字稿全文 → 标记。触控 ≥48vp。Visual 无截图则 BLOCKED。
