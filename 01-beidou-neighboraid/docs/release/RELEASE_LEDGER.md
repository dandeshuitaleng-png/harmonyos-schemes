# 北斗邻援 · 上架证据台账

更新：2026-08-29。本文件只记录已核对事实；不填写未证实的商店主体、隐私网址或签名材料。

## Release identity

| Field | Value |
| --- | --- |
| App name | 北斗邻援 |
| Package name | com.harmonyradar.neighboraid |
| Version | 0.1.0 / 1000000 |
| Device types | phone, tablet |
| SDK range | compatible 6.1.0(23) · compile 6.1.1(24) · target 6.1.0(23) |
| Candidate commit | not recorded this round |
| Release owner | blocked：应用市场登记主体未在仓库确认 |

## External dependency inventory

| Capability | Route or SDK | Data categories | Secrets stay in | Normal/failure evidence | Status |
| --- | --- | --- | --- | --- | --- |
| 本地演练记录 | Preferences `beidou-neighboraid-drill-records` | 本地标识、创建时间、固定类型标签 | 无服务端密钥 | 同意后读写；拒绝后不读取记录；失败有重试 | verified（代码契约） |
| 系统电话入口 | `ohos.want.action.dial` + `tel:` | 不由本应用拨号或保存号码 | 无 | 失败时提示改用系统电话应用 | not tested（真机） |
| 网络/定位/联系人/短信 | 未实现、未声明权限 | 无 | 无 | 静态扫描未发现对应 API | verified（静态） |

## Gate ledger

| Gate | Evidence | Status | Owner | Date |
| --- | --- | --- | --- | --- |
| Build | `assembleHap` 返回 BUILD SUCCESSFUL；产物仍为未签名 debug HAP | verified（未签名） | engineering | 2026-08-29 |
| Signing | `signingConfigs` 为空；未读取证书或 Profile | blocked | 本机 DevEco 调试签名 | 2026-08-29 |
| Backend | 本切片无自有服务 | not tested | n/a | 2026-08-29 |
| Device | 系统电话、隐私门禁、清除记录、重启恢复均需签名安装 | blocked | 真机验收 | 2026-08-29 |
| Store | 缺公开隐私政策 URL、商店文案、截图、年龄分级与登记主体 | blocked | 上架负责人 | 2026-08-29 |

## 本轮已落地的上架工程项

- 首次处理本机记录前展示隐私说明，并提供同意 / 拒绝选项。
- 拒绝后仍可打开系统电话，但不读取或写入演练记录。
- 同意后可清除全部本机演练记录。
- 演练存档改为 JSON，并兼容旧分隔符记录。
- 创建时间改为含日期的本机时间，避免跨日混淆。
- 发布构建开启保守混淆（不启用文件名混淆）。

## Release decision

**Decision:** blocked

**Open blockers:**

- 本机调试签名未配置，无法安装验收系统电话与隐私门禁
- 公开隐私政策 URL 与应用市场登记主体名称未提供
- `versionName` / `versionCode` 未由负责人指定为上架值
- 商店截图、分类、年龄分级与更新说明未准备

## 2026-08-30 · 产品 MVP 门禁

**状态：blocked。** 当前源码只实现“本机 SOS 演练记录”垂直切片，不满足 `AGENTS.md` 定义的产品 MVP。缺少离线地图/演练包、避险点/道路障碍/物资点事件、近场交换与冲突追溯、网络恢复后的用户确认上传，以及审核端待核验状态。该门禁优先于任何签名、设备或商店资料检查；在功能闭环完成前，不进行完整上架预检。

**构建证据边界：** 规范源码路径含中文目录 `所有方案`，已有复现显示 Hvigor 对该路径返回 `00306003 Invalid project path`。任何纯英文临时快照的编译结果只可用于源码编译诊断，不可标记本工程 Build、Device、Visual 或发布通过。
