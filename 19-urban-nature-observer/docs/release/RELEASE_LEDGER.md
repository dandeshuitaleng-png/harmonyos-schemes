# 城市自然观察 · 发布证据台账

> 2026-09-23最新：E1记录边界改进与本地18项测试/模拟器闭环通过；T004全仓guard因原始26号缺AGENTS阻塞。当前HAP与逐项结论见 `../evolution/release-review.md`，以下9月21日产物与状态为历史。发布仍blocked。

更新：2026-09-21。

| Gate | Evidence | Status |
| --- | --- | --- |
| Build | SDK 26内置编译；ArkTS、HAP打包成功；SHA-256 `c109f08207bba11313ec098a416faf4be06d09fd23dd02fa1eb2166527a93211` | verified（未签名） |
| Model / Storage | 12项测试，包括无效数据、互斥、容量、回滚及并发 | verified（自动化） |
| Emulator | API 24保存、进程重启恢复、再次观察、取消/确认删除、清空后重启 | verified（模拟器） |
| Permissions | 无网络、定位、相机等权限或相关上传实现 | verified（静态） |
| Visual | 手机模拟器浅色截图复核 | partial |
| Signing / Real device | 未配置本项目签名，未完成真机验证 | blocked |
| Accessibility / Theme / Tablet | 深色、大字号、读屏、平板待测 | pending |
| Store / Usability | 主体、隐私URL、上架截图与新手访谈待完成 | blocked |

**发布结论：blocked；离线MVP核心闭环已通过模拟器验证。** 完整证据与已知限制见 `../development/VALIDATION.md`。

---

## 历史台账（以下内容保留为旧版证据）

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
