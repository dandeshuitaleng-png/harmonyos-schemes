# 每日开发进度

## 2026-08-31 · 07 状态复核（按序推进）

- 已复核离线文字稿切片：课程选择和“本人练习”只在当前会话生效；不生成能力卡、不分享、不投递，也不将完成练习表述为就业资格或机构认证。
- 构建证据：`assembleHap --no-daemon --no-incremental --stacktrace` 通过（`BUILD SUCCESSFUL in 7 s 643 ms`）；产物 `entry-default-unsigned.hap` 经 `unzip -t` 校验通过，SHA-256 为 `ceb95e20d1ee75c9ff5e76730b1815a3f2266d128129840299c8ad54cf4efb30`（58,819 bytes）。
- 续办门禁：真实 MVP 需提供可离线续播的音频和文字稿、读屏/硬件焦点真机验收、最小能力卡的预览/撤销/指定分享机制，以及机构审核与个人数据分离；AI 建议若接入还需明确不评价人格、残障或就业资格。`No signingConfig found for product default`，所以安装、无障碍和视觉验收仍为 BLOCKED。
- 按当前“卡住一个方案就紧接下一个”的规则：保留以上续办条件，转入 `08-aidtrace`。

## 2026-08-31 · 07 UI/UX 工作流（离线文字稿）

- **方案：** `07-voicebridge`。无音频/AI。实现：非认证徽章、已选择文字、48vp。
- **Build：** PASS 未签名 `BUILD SUCCESSFUL in 8 s 185 ms`。 HAP `58819` bytes，SHA-256 `32237d1869cf3523beeab8ae085b7bbccb802cf84a4819aafb366b40a31b378d`；unzip PASS。Visual BLOCKED。
- **下次：** 立即 08 善款明细

## 2026-08-29 · 语桥求职

- 当前节点：Node 4 / Verify。
- 已完成：离线文字稿课程选择、本人会话内练习反馈、非就业资格说明、深浅色资源、图标与入口模块构建配置；练习标记明确为离开页面后不保留，课程切换有选中态。
- Build：**PASS（未签名 debug HAP）**。`assembleHap` 于 2026-08-29 成功；未签名产物尚不能作为读屏、焦点顺序或真机验收证据。
- 本轮范围：离线文字稿课程选择和本人练习记录。
- 不实现：音频、AI 评价、能力卡、分享、机构审核、投递或就业承诺。
- 下一步：签名后进行读屏、焦点顺序和大字号真机验收；持久化或技能证明能力须另行评估数据留存与机构责任。
- AppGallery Connect（2026-08-29）：已创建 HarmonyOS APP ID「语桥求职」，包名为 `com.harmonyradar.voicebridge`；未点击申请定位、推送等额外开放能力。
- AppGallery Connect（2026-08-29 续办）：调试 Profile「语桥求职调试」已在后台列表显示为**生效**，类型为调试，包名为 `com.harmonyradar.voicebridge`，有效期至 2027-08-27。已绑定既有调试证书与已登记平板，未申请受限 ACL。未在本机下载 `.p7b`，也未填写 DevEco 私钥口令。
