# 农事口述簿 · 上架证据台账

更新：2026-08-29。本文件只记录已核对事实；不填写未证实的商店主体、隐私网址或签名材料。

## Release identity

| Field | Value |
| --- | --- |
| App name | 农事口述簿 |
| Package name | com.harmonyradar.farmvoice |
| Version | 0.1.0 / 1000000 |
| Device types | phone, tablet |
| SDK range | compatible 6.1.0(23) · compile 6.1.1(24) · target 6.1.0(23) |
| Candidate commit | not recorded this round |
| Release owner | blocked：应用市场登记主体未在仓库确认 |

## External dependency inventory

| Capability | Route or SDK | Data categories | Secrets stay in | Normal/failure evidence | Status |
| --- | --- | --- | --- | --- | --- |
| 已阅读标记 | Preferences `farmvoice-privacy-choice` | 仅“已阅读” | 无服务端密钥 | 首次须阅读后继续；失败有重试 | verified（代码契约） |
| 会话农事记录 | 页面内存 | 作业类型、当天日期与时间 | 无 | 离开页面即消失；可清除本次会话 | verified（代码契约） |
| 录音/转写/网络/位置/联系人 | 未实现、未声明权限 | 无 | 无 | 静态扫描未发现对应 API | verified（静态） |

## Gate ledger

| Gate | Evidence | Status | Owner | Date |
| --- | --- | --- | --- | --- |
| Build | `assembleHap` 返回 BUILD SUCCESSFUL；产物 `entry-default-unsigned.hap`，`isSigned=false`；警告 `No signingConfig found for product default` | verified（未签名） | engineering | 2026-08-29 |
| Signing | `signingConfigs` 为空；未读取证书或 Profile | blocked | 本机 DevEco 调试签名 | 2026-08-29 |
| Backend | 本切片无自有服务 | not tested | n/a | 2026-08-29 |
| Device | 隐私说明、会话记录、摘要文案、深浅色均需签名安装 | blocked | 真机验收 | 2026-08-29 |
| Store | 缺公开隐私政策 URL、商店文案、截图、年龄分级与登记主体 | blocked | 上架负责人 | 2026-08-29 |

## 本轮已落地的上架工程项

- 首次进入展示与实际行为一致的隐私说明；本机最多保存“已阅读”标记。
- 作业记录只在当前会话；页面写明摘要不是文件导出，也不构成种植建议。
- 去掉“显示全部日期（演示）”等可能被理解为已有历史存档的措辞。
- 可清除本次会话记录；模块与 Ability 补齐名称、描述；发布构建开启保守混淆。
- 未实现录音、转写、落盘或文件导出。

## Release decision

**Decision:** blocked

**Open blockers:**

- 本机调试签名未配置，无法安装验收隐私说明与会话记录
- 公开隐私政策 URL 与应用市场登记主体名称未提供
- `versionName` / `versionCode` 未由负责人指定为上架值
- 持久化与文件导出仍须先确认保留期和逐字段移除规则
