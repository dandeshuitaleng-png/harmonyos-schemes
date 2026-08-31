# AidTrace · 本地物资批次草稿

> Route: `pages/Index` · Status: Implemented · Updated: 2026-08-31

## Purpose

- 用户目标：在当前会话创建去身份化物资批次草稿。
- 主操作：创建本次会话草稿。
- 不得发生：不记录捐赠者、受助者、联系方式或金额；不公开、导出或判定舞弊。
- 数据：草稿离开页面即清除；本机仅可能保存「已阅读」标记。
- 权限：本切片不申请相机或文件访问。

## Hierarchy

```text
[标题 善款明细 + 徽章「非募资」]
[不记录身份与金额]
[P1 批次类别，已选择用文字标出]
[主操作：创建会话草稿]
[空态 / 草稿列表]
```

平板 `maxWidth 640`；安全区 TOP/BOTTOM。

## States

| State | Visible | Recovery |
| --- | --- | --- |
| Boot / Loading | 正在读取本机状态 | 自动完成 |
| Privacy | 已阅读并继续 | 系统返回可退出说明 |
| Empty | 尚未创建草稿 | 创建 |
| Session drafts | 去身份化标题 + 待人工填写 | 离开页面清除 |
| Error | 隐私读写失败 | 重试 |

## A11y

读屏：标题 → 徽章 → 类别（含已选择）→ 创建 → 草稿状态。触控 ≥48vp。Visual 无截图则 BLOCKED。
