# GreenLens · 本地观察范围确认

> Route: `pages/Index` · Status: Implemented · Updated: 2026-08-31

## Purpose

- 用户目标：确认一个受控观察主题与公开范围说明。
- 主操作：确认本次仅做范围观察。
- 不得发生：不启动相机、定位、传感器、上传或 AI 分类；不产生环境事实或执法结论。
- 数据：确认结果不保存；本机仅可能保存「已阅读」标记。
- 权限：本切片不申请相机或定位。

## Hierarchy

```text
[标题 青眼巡查 + 徽章「非执法」]
[不产生事实或结论]
[P1 主题，已选择用文字标出，全文换行]
[主操作：确认范围]
[确认完成：不生成记录]
```

平板 `maxWidth 640`；安全区 TOP/BOTTOM。

## States

| State | Visible | Recovery |
| --- | --- | --- |
| Boot / Loading | 正在读取本机状态 | 自动完成 |
| Privacy | 已阅读并继续 | 系统返回可退出说明 |
| Scope pick | 主题说明 | 切换主题 |
| Confirmed | 不生成记录 | 切换主题重置 |
| Error | 隐私读写失败 | 重试 |

## A11y

读屏：标题 → 徽章 → 主题（含已选择）→ 确认。触控 ≥48vp。无 `maxLines` 裁切范围说明。Visual 无截图则 BLOCKED。
