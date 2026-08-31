# 每日开发进度

## 2026-08-31 · 04 状态复核（按序推进）

- 已复核受控模板切片：三个模板仅说明规划用途，主操作固定输出“无法确认”并提供人工替代路径；不调用相机、OCR、模型或云端，也不将药盒模板表述为医疗建议。
- 构建证据：`assembleHap --no-daemon --no-incremental --stacktrace` 通过（`BUILD SUCCESSFUL in 7 s 721 ms`）；产物 `entry-default-unsigned.hap` 经 `unzip -t` 校验通过，SHA-256 为 `f4b56f2740fd88678f2e0efa154ffd2460320deaf3115ce3181b46ad3046c353`（63,279 bytes）。
- 续办门禁：要实现 MVP 需先完成相机权限与素材生命周期、可替换 OCR/模型的低置信度策略、硬件按键/读屏/触觉真机验收；本机没有签名配置（`No signingConfig found for product default`），因此安装和无障碍视觉验收仍为 BLOCKED。现存 ArkTS 异常处理和 `getContext` 弃用警告不影响本次构建。
- 按当前“卡住一个方案就紧接下一个”的规则：保留以上续办条件，转入 `05-freshloop`。

## 2026-08-31 · 04 UI/UX 工作流（受控模板）

- **方案：** 仅 `all-schemes/04-sensecraft`。不接相机、OCR、模型。
- **实现：** 「非识别」徽章；模板「已选择」文字；去掉 `maxLines`；48vp。
- **Build：** PASS 未签名 `BUILD SUCCESSFUL in 8 s 185 ms`。HAP `63279` bytes，SHA-256 `9748c5fc29f47fb2b9c0daead10aba96f0897d60fed9aba0a37aa76374958dda`。Visual BLOCKED。
- **下次：** 立即 05 食光循环。

## 2026-08-29 · 盲行工坊

- 当前节点：Node 4 / Verify。
- 已完成：三个受控模板、不可用状态、人工替代路径、药品非医疗建议边界、深浅色资源与图标；所有模板名称均明确为规划模板，避免暗示识别、朗读或采集已经可用。
- 未实现且未宣称：相机、OCR、AI、云服务、朗读、振动、图像保存、人脸识别。
- Build：**PASS（未签名 debug HAP）**。`assembleHap` 于 2026-08-29 成功；未签名产物不能用于安装或作为无障碍验收证据。
- 验收：仍需在签名真机上以读屏和硬件按键验证焦点顺序、文本缩放和不可用状态。
- AppGallery Connect（2026-08-29）：已创建 HarmonyOS APP ID「盲行工坊」，包名为 `com.harmonyradar.sensecraft`；未点击申请定位、推送等额外开放能力。
- AppGallery Connect（2026-08-29 续办）：调试 Profile「盲行工坊调试」已在后台列表显示为**生效**，类型为调试，包名为 `com.harmonyradar.sensecraft`，有效期至 2027-08-27。已绑定既有调试证书与已登记平板，未申请受限 ACL。未在本机下载 `.p7b`，也未填写 DevEco 私钥口令。
