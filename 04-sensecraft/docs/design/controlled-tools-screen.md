# SenseCraft · 受控工具模板

> Route: `pages/Index` · Status: Implemented · Updated: 2026-08-31

## Purpose

- 用户目标：阅读隐私后选择三个受控模板之一，查看「无法确认」与人工替代路径。
- 主操作：查看当前模板不可用说明。
- 不得发生：不调用相机/OCR/模型、不保存素材、不提供药品或诊断建议。
- 数据：本机仅可能保存「已阅读」标记。
- 权限：本切片不申请相机。

## Hierarchy

```text
[标题 盲行工坊 + 徽章「非识别」]
[能力边界说明]
[P1 三模板，已选择用文字标出，全文换行]
[主操作：查看不可用说明]
[当前状态 / 系统电话]
[隐私说明]
```

平板 `maxWidth 640`；安全区 TOP/BOTTOM。

## States

| State | Visible | Recovery |
| --- | --- | --- |
| Boot / Loading | 正在读取本机状态 | 自动完成 |
| Privacy | 已阅读并继续；停留本页不采集 | 系统返回可退出说明 |
| Normal | 模板选择 + 不可用说明 | 切换模板 |
| Unavailable | 明确未接入相机/识别 | 重看实物 / 设备辅助 / 联系他人 / 系统电话 |
| Dialer failed | 无法打开系统电话 | 退出应用咨询医护或急救 |
| Error | 隐私选择读写失败 | 重试 |
| Future permission | 未实现 | 必须先独立设计和真机验证 |

## A11y

读屏：标题 → 徽章 → 模板（含已选择）→ 不可用说明 → 电话。触控 ≥48vp。无 `maxLines` 裁切模板说明。Visual 无截图则 BLOCKED。
