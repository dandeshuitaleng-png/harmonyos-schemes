# 近地天体探索 · 发布证据台账

更新：2026-08-31。

| Gate | Evidence | Status |
| --- | --- | --- |
| Build | `assembleHap` 返回 `BUILD SUCCESSFUL in 7 s 948 ms`；未签名 HAP SHA-256 `3aa9e661a411163b4005f67097221951d65a602ddde753e6f1b7b8c1df3277ec`，`unzip -t` 无错误 | verified（仅编译） |
| Permissions | 未声明网络、定位、相机、麦克风或联系人权限 | verified（静态） |
| Scientific data | 当前只含离线稳定基础概念和循环自检；不加载实时轨道/距离/风险 | scoped |
| Signing | 未配置 signingConfig | blocked |
| Device/accessibility | 无签名真机、读屏或大字号截图 | blocked |
| Store | 商店主体、隐私 URL、截图和科学内容审核未确认 | blocked |

**发布结论：blocked。** 未签名 HAP 不可视为安装包或上架候选；若加入实时数据，必须附权威来源和数据日期。
