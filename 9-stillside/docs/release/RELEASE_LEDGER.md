# 静伴空间 · 上架证据台账

更新：2026-08-29。本文件只记录已核对事实；不填写未证实的商店主体、隐私网址或签名材料。

## Release identity

| Field | Value |
| --- | --- |
| App name | 静伴空间 |
| Package name | com.harmonyradar.stillside |
| Version | 0.1.0 / 1000000 |
| Device types | phone, tablet |
| SDK range | compatible 6.1.0(23) · compile 6.1.1(24) · target 6.1.0(23) |
| Candidate commit | not recorded this round |
| Release owner | blocked：应用市场登记主体未在仓库确认 |

## External dependency inventory

| Capability | Route or SDK | Data categories | Secrets stay in | Normal/failure evidence | Status |
| --- | --- | --- | --- | --- | --- |
| 可选本机练习次数 | Preferences `stillside-practice` | 完成次数、隐私选择 | 无服务端密钥 | 同意后才读写次数；拒绝后不读取次数；失败有重试 | verified（代码契约） |
| 系统电话入口 | `ohos.want.action.dial` + `tel:` | 不由本应用拨号或保存号码 | 无 | 失败时提示改用系统电话应用 | not tested（真机） |
| 网络/定位/相机/麦克风/联系人 | 未实现、未声明权限 | 无 | 无 | 静态扫描未发现对应 API | verified（静态） |

## Gate ledger

| Gate | Evidence | Status | Owner | Date |
| --- | --- | --- | --- | --- |
| Build | `assembleHap` 返回 BUILD SUCCESSFUL；产物 `entry-default-unsigned.hap`，`isSigned=false`；警告 `No signingConfig found for product default` | verified（未签名） | engineering | 2026-08-29 |
| Signing | `signingConfigs` 为空；未读取证书或 Profile | blocked | 本机 DevEco 调试签名 | 2026-08-29 |
| Backend | 本切片无自有服务 | not tested | n/a | 2026-08-29 |
| Device | 隐私门禁、计时、清除次数、系统电话、读屏与减弱动态均需签名安装 | blocked | 真机验收 | 2026-08-29 |
| Store | 缺公开隐私政策 URL、商店文案、截图、年龄分级与登记主体 | blocked | 上架负责人 | 2026-08-29 |

## 本轮已落地的上架工程项

- 首次进入展示与实际行为一致的隐私说明，并提供同意 / 仅计时不保存 选项。
- 拒绝后仍可离线完成 2/5/10 分钟练习，但不读取或写入练习次数。
- 同意后可关闭保存并清除全部本机练习次数。
- 紧急路径仅打开系统拨号界面，不申请拨号权限，也不由本应用拨出号码。
- 模块与 Ability 补齐名称、描述；发布构建开启保守混淆（不启用文件名混淆）。
- 界面写明非医疗、非危机干预；完成练习不作为健康或治疗结论。

## Release decision

**Decision:** blocked

**Open blockers:**

- 本机调试签名未配置，无法安装验收隐私门禁、计时精度、读屏与系统电话
- 公开隐私政策 URL 与应用市场登记主体名称未提供
- `versionName` / `versionCode` 未由负责人指定为上架值
- 商店截图、分类、年龄分级与更新说明未准备
