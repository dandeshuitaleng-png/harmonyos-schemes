# FreshLoop · 本地安全筛选草稿

> Route: `pages/Index` · Status: Implemented · Updated: 2026-08-31

## Purpose

- 用户目标：选择受控品类，查看拒绝原因或「待人工审核」状态。
- 主操作：检查基础安全规则。
- 不得发生：不发布、预约、显示领取点；不承诺食品安全或平台背书。
- 数据：检查结果不保存；本机仅可能保存「已阅读」标记。
- 权限：本切片不申请相机、位置或联系人。

## Hierarchy

```text
[标题 食光循环 + 徽章「非上架」]
[筛选不等于食品安全]
[P1 品类，已选择用文字标出]
[主操作：检查基础安全规则]
[结果：拒绝 / 待人工审核]
```

平板 `maxWidth 640`；安全区 TOP/BOTTOM。

## States

| State | Visible | Recovery |
| --- | --- | --- |
| Boot / Loading | 正在读取本机状态 | 自动完成 |
| Privacy | 已阅读并继续 | 系统返回可退出说明 |
| Empty check | 已选品类，尚未检查 | 检查 |
| Blocked | 硬规则拒绝 + 原因 | 改选品类 |
| Pass draft | 仅具备人工审核准备条件 | 不提交、不发布 |
| Error | 隐私读写失败 | 重试 |

## A11y

读屏：标题 → 徽章 → 品类（含已选择）→ 检查 → 结果。触控 ≥48vp。Visual 无截图则 BLOCKED。
