# 每日开发进度

## 2026-08-31 · 20 状态复核（按序推进）

- 已复核本地订桌草稿：仅可选演示日期、人数与演示桌位，生成后可取消；页面清楚说明不连接真实餐厅、桌位库存、支付、会员、通知、地图或商家后台，也不向商家发送信息或占用真实桌位。
- 构建证据：`assembleHap --no-daemon --no-incremental --stacktrace` 通过（`BUILD SUCCESSFUL in 7 s 549 ms`）；产物 `entry-default-unsigned.hap` 经 `unzip -t` 校验通过，SHA-256 为 `901c926af5ddb4cea64bf18e2cdadf9b8f5b27145c42c227d81a57f2c755c633`（46,289 bytes）。
- 续办门禁：真实预约需有商家库存与并发锁定、用户/商家确认、取消/超时规则、通知、支付边界和审计；联系人、位置与支付数据必须最小化并经独立安全/隐私、真机验证。`No signingConfig found for product default`，故安装与视觉/无障碍验收仍为 BLOCKED。
- 按当前“卡住一个方案就紧接下一个”的规则：保留以上续办条件，转入 `21-stepaccess`。

## 2026-08-31 · 20 UI/UX 工作流（订桌草稿）

- **方案：** `20-visual-table-book`。不接支付。实现：非支付徽章、已选择、48vp。
- **Build：** PASS 未签名 `BUILD SUCCESSFUL in 8 s 12 ms`。 HAP `46289` bytes，SHA-256 `c8c96e7cb39fc91a5a2bd139195261de240567574cac1f4dc2d7d45e96bb95ae`；unzip PASS。Visual BLOCKED。
- **下次：** 立即 21 步道通
