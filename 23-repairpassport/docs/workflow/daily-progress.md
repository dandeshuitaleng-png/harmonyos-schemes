# 每日开发进度

## 2026-08-30 · 轮换至 23 / 本机设备卡骨架

### 1. 范围与输入

- **工程 / 候选：** `23-repairpassport`；因 24 已连续完成两个切片，本轮按轮换规则处理次新的 23。
- **当前节点：** Scope → Design → Implement → Verify。
- **本次 MVP 切片与用户路径：** 离线填写设备类别、用户填写型号、购买日期及可选保修到期日 → 保存本机设备卡 → 读取列表 → 删除卡。空态、加载、未填必填项、读写失败/重试均有文字恢复。
- **不在本次范围：** 文件 Picker、URI、附件、维修事件、时间线、导出、提醒、诊断、报价、维修教学、网络、账号、签名或上架。

### 2. 实际执行与产出

- **做了什么：** 从研究准入工程建立 Stage/Hvigor 骨架、原生 ArkUI、Preferences 本地存储与最小设备卡路径。
- **改动文件：** `AppScope/`、`entry/`、`hvigor/`、根构建配置、`docs/design/device-card-screen.md` 及本台账。
- **生成的本地产物：** 未签名 HAP `entry/build/default/outputs/default/entry-default-unsigned.hap`，`45401` bytes，SHA-256 `c2c04811b039166115363613ab4bb215ffe4687d95722965b70e4a7be632223b`。

### 3. 验收证据

| 层级 | 本次状态 | 实际证据 | 结论边界 |
| --- | --- | --- | --- |
| Scope / Design | PASS | AGENTS 允许本地设备卡；设计覆盖加载、空、禁用、错误与删除 | 不以设计替代真机 |
| 产品 MVP 就绪 | FAIL | 仅设备卡创建/读取/删除完成；附件、维修事件、时间线、导出及真机验收未完成 | 不进入发布预检 |
| Build | PASS（未签名） | 扫描 `NO_UNAPPROVED_CAPABILITIES_FOUND`；Hvigor 输出 `TYPE CHECK SUCCESSFUL`、`CompileArkTS`、`PackageHap`、`BUILD SUCCESSFUL in 8 s 113 ms`；`unzip -t` 无错误 | 不代表设备或文件能力通过 |
| Signing / Device / Visual | BLOCKED | 无签名配置、当天安装、截图、读屏或大字号证据 | 构建不等于真机或视觉通过 |
| Backend / Privacy | PASS（本切片边界） | 未引入网络、诊断、Picker 或导出 API；仅保存用户手动字段 | 不表示附件隐私流程完成 |
| Store | 未验证 | 未执行任何上传或审核 | 不得称可发布 |

### 4. 风险与阻塞

- **阻塞项：** 无 Debug 签名与设备，无法验证本机持久化、删除、重启恢复或无障碍运行。
- **不能据此声称：** 设备卡不等于已附加文件、已记录维修、可导出、真机通过或上架就绪。

### 5. 提交归档

- **本次提交：** 无。本轮只读核验最近既有提交 `b053cf4 · Sort scheme folders by sequence · 2026-08-30T16:50:05+08:00`，不含本轮改动。
- **归档状态：** 本轮未提交；未执行 `git add`、`commit`、`push` 或历史改写。

### 6. 后续事项与续办规则

- **下次首个动作：** 继续 23：实现本机维修事件与时间线，不接入文件或诊断能力。
- **重试条件：** Debug 签名和设备可用后，验证离线创建、删除、重启恢复、读屏与大字号。
- **续办对象：** 当前工程；下一轮应按轮换规则避免连续处理 23。

## 2026-08-30 · 本机维修事件与时间线

### 1. 范围与输入

- **工程 / 候选：** `23-repairpassport`；只处理已有设备卡关联的本机维修事件。
- **当前节点：** Implement → Verify。
- **本次 MVP 切片与用户路径：** 已保存设备卡 → 打开事件表单 → 填写事件类型、发生日期与可选备注 → 保存 → 在该设备卡的时间线中查看。没有事件时显示明确空态；事件保存失败时保留输入并提供再次保存。
- **不在本次范围：** 文件或附件、DocumentViewPicker、导出、故障诊断、报价、网络、账号、第三方能力、签名、真机、上传或审核。

### 2. 实际执行与产出

- **做了什么：** 扩展 `DeviceCard` 的本机数据为可选 `events`；旧卡加载时补齐为空数组。页面增加每卡时间线、无事件状态、事件表单、必填禁用、取消、保存失败后的“再次保存该维修事件”，以及删除当前卡时退出事件表单。所有事件仍经原有 Preferences 保存。
- **改动文件：** `entry/src/main/ets/data/DeviceStore.ets`、`entry/src/main/ets/pages/Index.ets`、`docs/design/device-card-screen.md` 和本文件。
- **修复记录：** 首次构建发现 ArkTS 禁止对象/数组展开与 Builder 局部变量；已改为显式构造 `DeviceCard` 和事件数组后重新构建通过。
- **生成的本地产物：** 未签名 HAP `entry/build/default/outputs/default/entry-default-unsigned.hap`，`73492` bytes，SHA-256 `73175140e80ac65f5f8f367df80e09ada42880b4993f5ea01bc8a87f165382f7`。

### 3. 验收证据

| 层级 | 本次状态 | 实际证据 | 结论边界 |
| --- | --- | --- | --- |
| Scope / Design | PASS | AGENTS 要求离线设备卡、维修事件与时间线，并明确不做诊断或报价；设计已记录空态、取消和失败重试 | 不代表附件或导出已实现 |
| 当前切片 | PASS（源码与构建） | 事件只挂在现有设备卡；类型/日期为空时禁用保存；无事件、取消和失败重试均有可见文本与动作 | 无真机交互证据，不能称运行验收通过 |
| 产品 MVP 就绪 | FAIL | 设备卡和本机事件时间线已实现；真实附件、失效 URI、导出摘要和真机验收仍缺失 | 不进入发布预检 |
| Build | PASS（未签名） | 修复后执行 `hvigorw --mode module -p product=default -p module=entry@default assembleHap --no-daemon --no-incremental --stacktrace`，输出 `TYPE CHECK SUCCESSFUL`、`CompileArkTS`、`PackageHap`、`BUILD SUCCESSFUL in 8 s 275 ms`；`unzip -t` 输出 `No errors detected` | 构建不代表安装或运行 |
| Signing / Device / Visual | BLOCKED | 输出 `No signingConfig found for product default`；无当天安装、截图、读屏或大字号证据 | 未签名构建不能作为设备或发布通过 |
| Backend / Privacy | PASS（本切片边界） | 应用源码导入仅含 `@kit.ArkData`、`@kit.AbilityKit`、`@kit.ArkUI`；未接入 Picker、网络、导出或诊断 API；事件仅保存用户填写的最小文本 | 静态检查不代替附件和导出的未来隐私验收 |
| Store | 未验证 | 未进行版本、签名、上传或审核动作 | 不得称可发布 |

### 4. 阻塞与轮换依据

- **当前阻塞：** 无 Debug 签名与设备，无法验证离线事件保存、重启恢复、删除、读屏与大字号；仍有 Preferences 可能抛异常与 `getContext` 已弃用警告，但未阻断编译。
- **下一轮依据：** 23 已完成设备卡和事件时间线两个本地切片，应按轮换规则处理其他工程；回到 23 时再处理附件 Picker 的取消/失效 URI，或导出摘要的默认隐藏序列号，不能把任一能力伪造成已可用。
- **需要用户输入：** 当前不需要；若定义真实附件保留、导出字段或提醒日期语义，须先取得对应产品/隐私决定。

### 5. 提交归档

- **本次提交：** 无。本轮只读核验最近既有提交为 `b053cf4 · Sort scheme folders by sequence · 2026-08-30T16:50:05+08:00`，范围不包含本轮改动。
- **归档状态：** 工程目录当前为仓库未跟踪目录；本轮改动未提交，未执行 `git add`、`commit`、`push` 或历史改写。

## 2026-08-30 · 导出前本地字段选择与取消

### 1. 范围与输入

- **工程 / 候选：** `23-repairpassport`；只处理已有设备卡和维修事件的屏幕内字段选择。
- **当前节点：** Implement → Verify。
- **本次用户路径与验收：** 选择一张设备卡 → 打开“选择导出前字段” → 选择类别、型号、购买/保修日期和维修事件/备注 → 查看本地摘要 → 取消选择。型号默认隐藏；零字段时提示保留至少一个字段；选择不写入存储。
- **不在本次范围：** 文件、Picker、URI、附件、系统分享、真实导出、网络、账号、诊断、报价、签名、设备、上传或审核。

### 2. 实际执行与产出

- **做了什么：** 增加每张设备卡的内存字段选择态和本地摘要预览。类别与购买日期默认包含，型号默认隐藏；保修日期与维修事件/备注仅在有对应数据时可选。删除当前卡或进入事件记录时退出字段选择；取消不会持久化任何选择。
- **改动文件：** `entry/src/main/ets/pages/Index.ets`、`docs/design/device-card-screen.md` 和本文件。
- **未做什么：** 未生成文件或文本导出，未调用 FilePicker、URI、系统分享、网络或账户 API；没有序列号字段，也未凭空创建该字段。
- **生成的本地产物：** 未签名 HAP `entry/build/default/outputs/default/entry-default-unsigned.hap`，`95877` bytes，SHA-256 `b119f4770cda6176a69311d10b651999bf9f74861f6ec85005a753c9d052d245`。

### 3. 验收证据

| 层级 | 本次状态 | 实际证据 | 结论边界 |
| --- | --- | --- | --- |
| Scope / Design | PASS | AGENTS 要求导出默认隐藏敏感序列号；当前模型无序列号，用户填写型号因此默认隐藏；规格定义选择、零字段和取消边界 | 不代表真实导出可用 |
| 当前切片 | PASS（源码与构建） | 所有选择仅为 `@State` 内存状态；没有确认导出操作；取消、删除和打开事件表单均退出选择态 | 无真机交互证据，不能称运行验收通过 |
| 产品 MVP 就绪 | FAIL | 本机设备卡、维修事件、时间线和导出前字段预览已实现；真实附件、失效 URI、真实导出和真机验收仍缺失 | 不进入发布预检 |
| Build | PASS（未签名） | `hvigorw --mode module -p product=default -p module=entry@default assembleHap --no-daemon --no-incremental --stacktrace` 输出 `TYPE CHECK SUCCESSFUL`、`CompileArkTS`、`PackageHap`、`BUILD SUCCESSFUL in 8 s 340 ms`；`unzip -t` 输出 `No errors detected` | 构建不代表安装或运行 |
| Signing / Device / Visual | BLOCKED | 输出 `No signingConfig found for product default`；无当天安装、截图、读屏或大字号证据 | 未签名构建不能作为设备或发布通过 |
| Backend / Privacy | PASS（本切片边界） | 导入仅含 ArkData、AbilityKit、ArkUI；对 FilePicker、分享、网络、相机和位置的受限导入扫描无命中 | 静态检查不替代未来文件/导出隐私验收 |
| Store | 未验证 | 未进行版本、签名、上传或审核动作 | 不得称可发布 |

### 4. 阻塞与轮换依据

- **当前阻塞：** 真实导出格式、保存位置及文件保留/覆盖语义尚未定义；无 Debug 签名与设备，无法验证本机持久化、读屏和大字号。Preferences 可能抛异常与 `getContext` 已弃用警告未阻断编译。
- **下一轮依据：** 23 已完成三个本地切片，应按轮换规则处理其他工程；若回到 23，只有在明确导出格式与文件隐私语义后才可处理真实导出，或先处理 Picker 取消与失效 URI 的可恢复状态。
- **需要用户输入：** 真实导出前需要确认格式、保存目标、覆盖方式和可包含的字段。

### 5. 提交归档

- **本次提交：** 无。本轮只读核验最近既有提交为 `b053cf4 · Sort scheme folders by sequence · 2026-08-30T16:50:05+08:00`，范围不包含本轮改动。
- **归档状态：** 工程目录当前为仓库未跟踪目录；本轮改动未提交，未执行 `git add`、`commit`、`push` 或历史改写。
