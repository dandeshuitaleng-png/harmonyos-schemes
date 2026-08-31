# 城市自然观察 · 发布证据台账

更新：2026-08-31。

| Gate | Evidence | Status |
| --- | --- | --- |
| Build | `assembleHap` 返回 `BUILD SUCCESSFUL in 8 s 93 ms`；未签名 HAP SHA-256 `c7ed830805bb58c07290863b4a1dd51f28ac921e71d908106deb49fbfc54112b`，`unzip -t` 无错误 | verified（仅编译） |
| Permissions | 未声明网络、定位、相机、麦克风或联系人权限 | verified（静态） |
| Ecology boundary | 会话观察仅为通用可见特征；不识别、不记录精确位置、不上传、不输出物种结论 | verified（代码/文案范围） |
| Signing | 未配置 signingConfig | blocked |
| Device/accessibility | 无签名真机、读屏或大字号截图 | blocked |
| Store | 商店主体、隐私 URL、截图与生态内容审核未确认 | blocked |

**发布结论：blocked。** 如接入相机、识别或社区功能，须先完成敏感物种位置保护、数据留存和审核机制设计。
