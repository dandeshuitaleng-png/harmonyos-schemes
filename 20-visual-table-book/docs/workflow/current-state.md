# 可视化订桌 · 当前状态

更新：2026-08-31 · Node 3 / Implement（本地演示草稿）。

- 用户目标：在演示餐厅平面图上直观看到桌位差异，并练习形成一份预约草稿。
- 主操作：选择一个明确演示日期、人数与一张演示桌位。
- 本轮数据：静态演示桌位与本地会话草稿；无真实餐厅数据。
- 成功标准：日期、桌位选择、草稿创建、取消和空态均不暗示真实预订成功；更换日期/人数/桌位会退出草稿。
- 后续门禁：接入真实商家前，需要桌位库存、营业规则、取消政策、联系人和支付责任方。

## 2026-08-31 · 演示日期选择与本地草稿

- **本次范围：** 仅增加三个明确的演示日期选项（周五、周六、周日）。用户须选择日期和可用演示桌位后才能创建草稿；人数、日期或桌位任一变化会退出当前草稿。
- **实际结果：** 草稿摘要现在展示选中的演示日期、桌位和人数；未选日期/桌位时按钮禁用并有文字与读屏说明。日期、人数、桌位均只存在页面本地状态，不保存、不发送、不占用真实库存。
- **未做什么：** 未连接餐厅、库存、支付、会员、联系人、通知、地图、位置或商家后台；未执行安装、签名、上传或 Git 写操作。
- **构建证据：** `hvigorw --mode module -p product=default -p module=entry@default assembleHap --no-daemon --no-incremental --stacktrace` 输出 `TYPE CHECK SUCCESSFUL`、`CompileArkTS`、`PackageHap`、`BUILD SUCCESSFUL in 7 s 845 ms`。未签名 HAP 为 `entry/build/default/outputs/default/entry-default-unsigned.hap`，`43265` bytes，SHA-256 `7d55b86de430f9de5a9dd960e5aa2a9eb7dc286bcdd7c72ab208d1f6741c0db8`；`unzip -t` 输出 `No errors detected`。
- **门禁：** Build 为 PASS（未签名）；Signing 因 `No signingConfig found for product default` 为 BLOCKED；Device、Visual、Store 无当天证据，均不得视为通过。
- **下次与轮换：** 20 的日期切片已完成，应按轮换处理其他未完成工程。真实预约前仍需真实库存、营业/取消规则、联系人、支付责任和受控真机验证。
