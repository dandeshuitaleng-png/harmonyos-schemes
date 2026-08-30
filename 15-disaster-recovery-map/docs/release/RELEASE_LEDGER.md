# 地球 Online · 观测站 · 上架证据台账

更新：2026-08-29。不填写未证实的商店主体、隐私网址或签名材料。

## Release identity

| Field | Value |
| --- | --- |
| App name | 地球 Online · 观测站 |
| Package name | com.naturalcollect.app |
| Version | 1.0.0 / 1000000 |
| Device types | phone, tablet |
| SDK range | compatible 6.1.0(23) · compile/target 6.1.1(24) |
| Release owner | blocked：应用市场登记主体未在仓库确认 |

## External dependency inventory

| Capability | Route or SDK | Data categories | Secrets stay in | Status |
| --- | --- | --- | --- | --- |
| 本机观察记录 | Preferences `naturalcollect-observations` | 现象类型、可选地点/备注、时间、来源分级 | 无服务端 | verified（代码契约） |
| 示例照片 | 本地 `typhoon_coast_unsplash.jpg` | 无用户照片 | 无 | verified（本地资源） |
| 系统电话入口 | `ohos.want.action.dial` + `tel:` | 不保存号码 | 无 | not tested（真机） |
| 相机/识别/定位/网络 | 未实现、未声明权限 | 无 | 无 | verified（静态） |

## Gate ledger

| Gate | Evidence | Status | Date |
| --- | --- | --- | --- |
| Build | `assembleHap` BUILD SUCCESSFUL，9.5s，HarmonyOS 6.1.1 SDK。产物 `entry/build/default/outputs/default/entry-default-unsigned.hap` SHA-256 `f48a12cf7aa8ee8962bc7e176ff5e514d9711291c65726d9f4ebbc693e6cb556`。编译告警：Preferences `Function may throw`（调用方已 try/catch）、`getContext` deprecated。 | verified（仅编译；未签名） | 2026-08-29 |
| Signing | `No signingConfig found for product default` | blocked | 2026-08-29 |
| Backend | 无自有服务 | not tested | 2026-08-29 |
| Device | 需签名安装；视觉验收缺少真机截图 | blocked | 2026-08-29 |
| Store | 缺公开隐私 URL、截图、主体名称；Unsplash 正式使用方式待复核 | blocked | 2026-08-29 |

## Release decision

**Decision:** blocked

**Open blockers:** 调试/发布签名、公开隐私政策 URL、商店主体、Unsplash 上架使用复核、真机与读屏验收。未签名 HAP 不能安装或上架。
