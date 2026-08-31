# QuietBeacon · 本机求助卡

> Route: `pages/Index` · Status: Implemented · Updated: 2026-08-31

## Purpose

- 用户目标：不便语音时，三步内选择模板、生成本机求助卡、确认后取消。
- 主操作：生成本机求助卡。
- 不得发生：不声称已通知机构、已发短信、已读位置或保证送达。
- 数据：Preferences 中一张已知模板卡；未知来源卡不展示。
- 权限：本切片不申请短信、联系人、位置。

## Hierarchy

```text
[标题 静默信标 + 徽章「本机卡」]
[副标题：不是报警平台]
[P0 系统电话]
[P1 三句模板，已选择用文字标出，全文换行]
[主操作：生成本机求助卡]
[当前卡 / 空态；取消需二次确认]
[错误重试 / 隐私说明]
```

平板 `maxWidth 640`；安全区 TOP/BOTTOM。

## States

| State | Visible | Recovery |
| --- | --- | --- |
| Boot / Loading | 正在读取 | 自动完成 |
| Privacy | 同意 / 仅查看模板 | 系统返回可退出说明 |
| Declined | 可看模板与电话，不读卡 | 阅读并同意 |
| Empty | 选择模板后生成 | 生成 |
| Success | 全文 + 时间 +「仅本机，未发送」 | 可取消（需确认） |
| Confirm cancel | 危险文案 + 确认/取消 | 返回键取消确认 |
| Unknown card | 不展示内容，说明来源无法确认 | 重选模板 |
| Error | 未发送 + 重试 | 重试 |
| Dialer failed | 改用系统电话或线下 | 退出应用 |

## A11y

读屏：标题 → 徽章 → 电话 → 模板（含已选择）→ 生成 → 当前卡 → 取消。触控 ≥48vp。无 `maxLines` 裁切求助文案。Visual 无截图则 BLOCKED。
