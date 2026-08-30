# 可信任务贴 · 上架证据台账

更新：2026-08-29。本文件只记录已核对事实；不填写未证实的商店主体、隐私网址或签名材料。

## Release identity

| Field | Value |
| --- | --- |
| App name | 可信任务贴 |
| Package name | com.harmonyradar.questproof |
| Version | 0.1.0 / 1000000 |
| Device types | phone, tablet |
| SDK range | compatible 6.1.0(23) · compile 6.1.1(24) · target 6.1.0(23) |
| Candidate commit | not recorded this round |
| Release owner | blocked：应用市场登记主体未在仓库确认 |

## External dependency inventory

| Capability | Route or SDK | Data categories | Secrets stay in | Normal/failure evidence | Status |
| --- | --- | --- | --- | --- | --- |
| 已阅读标记 | Preferences `questproof-privacy-choice` | 仅“已阅读” | 无服务端密钥 | 首次须阅读后继续；失败有重试 | verified（代码契约） |
| 演示任务状态 | 页面内存 | 本机状态标签、操作时间 | 无 | 离开页面即消失；确认可撤销 | verified（代码契约） |
| 位置/相机/身份/网络/代币 | 未实现、未声明权限 | 无 | 无 | 静态扫描未发现对应 API | verified（静态） |

## Gate ledger

| Gate | Evidence | Status | Owner | Date |
| --- | --- | --- | --- | --- |
| Build | `assembleHap` 返回 BUILD SUCCESSFUL；产物 `entry-default-unsigned.hap`，`isSigned=false`；警告 `No signingConfig found for product default` | verified（未签名） | engineering | 2026-08-29 |
| Signing | `signingConfigs` 为空；未读取证书或 Profile | blocked | 本机 DevEco 调试签名 | 2026-08-29 |
| Backend | 本切片无自有服务 | not tested | n/a | 2026-08-29 |
| Device | 隐私说明、四态流转、撤销与读屏均需签名安装 | blocked | 真机验收 | 2026-08-29 |
| Store | 缺公开隐私政策 URL、商店文案、截图；无真实发起方前不能作为凭证类产品上架 | blocked | 上架负责人 | 2026-08-29 |

## 本轮已落地的上架工程项

- 首次进入展示与实际行为一致的隐私说明；本机最多保存“已阅读”标记。
- 发布 / 提交 / 本机标记确认 / 撤销 四态均有说明和下一步；“确认”写明不是真实审核。
- 操作记录显示“本机演示操作（不是真实审核人）”和本机时间，不编造审核员身份。
- 界面写明无代币、排行、链上凭证、地点和照片。
- 模块与 Ability 补齐名称、描述；发布构建开启保守混淆。

## Release decision

**Decision:** blocked

**Open blockers:**

- 本机调试签名未配置，无法安装验收状态流转
- 公开隐私政策 URL 与应用市场登记主体名称未提供
- 无真实发起方、审核人和撤销责任规则，不能作为凭证类应用提交商店
- `versionName` / `versionCode` 未由负责人指定为上架值
