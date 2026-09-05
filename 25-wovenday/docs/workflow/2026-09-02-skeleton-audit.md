# 2026-09-02 工程骨架只读核验

## 处理对象与边界

- 对象：`25-wovenday`，当前编号最新且未完成，并且其 ArkTS 页面相对既有提交已有新输入。
- 当前节点：Verify。
- 本轮只读检查现有源码、资源和配置；未覆盖、重构或删除 ArkTS/ArkUI 文件，未实现照片、通知、分享、服务卡片、网络或账号能力。
- 当前工作树在本轮开始前已有 `entry/src/main/ets/pages/Index.ets`、`docs/design/garment-card-screen.md`、`docs/workflow/daily-progress.md` 修改；本轮保留这些改动，仅新增本记录。

## 结构与配置

- 结构命令：对 `AGENTS.md`、AppScope、根/entry Hvigor 配置、`module.json5`、`EntryAbility.ets`、`pages/Index.ets`、`GarmentStore.ets`、路由、颜色、图标及设计/workflow 文档逐项执行 `test -f`。
- 原始结果：`REQUIRED_TOTAL 19`，`MISSING_TOTAL 0`。
- 配置命令：使用 DevEco 自带 Node 对 9 个 JSON/JSON5 文件执行 `JSON.parse(...)`。
- 原始结果：9 项均为 `PARSE_OK`，`PARSE_FAILURES 0`。
- 入口核验：源码 `module.json5` 含 `entity.system.home` 与 `action.system.home`，路由为 `pages/Index`；重新读取 HAP 内 `module.json`，两个 Home 值均存在。
- 受限能力扫描：对网络、相机、位置、通知、Picker、系统分享、动态权限关键词执行 `rg`，原始结果为 `NO_MATCHES`。这只证明当前扫描范围未接入这些能力，不代表未来隐私验收通过。

## 构建、包与源码保全

- 环境：`DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk`；`JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home`。
- 命令：`/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw --mode module -p product=default -p module=entry@default assembleHap --no-daemon --no-incremental --stacktrace`。
- 原始关键结果：`TYPE CHECK SUCCESSFUL in 264 ms`、`CompileArkTS`、`PackageHap`、`BUILD SUCCESSFUL in 9 s 699 ms`、`BUILD_EXIT 0`。
- 源码/配置聚合 SHA-256：构建前后均为 `fa8f719fdeebaade31af72e00d6631ed945f1e1a4802c810fe82e82f753e1243`，证明本轮构建没有改写列入清单的输入。
- 产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`，103899 bytes，SHA-256 `73ee2d8bd81e8a993143836845ea9db950af6fc4b7e75e57ad4f38d91f22a624`。
- 容器命令：`unzip -t entry/build/default/outputs/default/entry-default-unsigned.hap`；原始结果：8 项 `OK`，`No errors detected in compressed data`。
- 非阻断警告：模块 SemVer 检查警告；`GarmentStore.ets` 的 Preferences 调用可能抛异常；`Index.ets` 的 `getContext` 已弃用。本轮 Build 未失败，且自动化对既有工程只有只读核验权限，因此未借机修改源码。

## 门禁、阻塞与后续

| 层级 | 状态 | 当前证据与边界 |
| --- | --- | --- |
| Skeleton / Config | PASS | 19 项必需路径齐全，9 项配置可解析，源码及包内桌面入口一致。 |
| Build | PASS（未签名） | 当前修改可完成 ArkTS 编译和 HAP 打包；不代表安装或运行。 |
| Product MVP | FAIL | 交接摘要、系统分享取消、照片 Picker、归档和运行验收仍缺失；真实分享、照片和提醒规则需要一次性产品输入。 |
| Signing | BLOCKED | 构建原始警告为 `No signingConfig found for product default`；配置扫描未发现 signingConfig。未读取、创建或管理任何证书、Profile、私钥或密码。 |
| Device | BLOCKED | `hdc list targets` 本轮返回一个非空目标，说明连接条件较上一记录有变化；但当前只有未签名 HAP，未安装、启动或执行编辑/重启恢复路径，设备标识未写入本记录。 |
| Visual / Accessibility | BLOCKED | 无本轮运行截图、读屏、高对比或 150% 字号证据。 |
| Store | 未验证 | 未改版本、签名、上传或审核。 |

- 当前阻塞：签名配置仍缺失；完整产品路径还需要用户明确分享、照片和提醒规则。
- 下一动作：本轮切片完成后重新比较最新三个未完成方案。25 不重复构建；仅在源码/配置再次变化、规则明确，或受控 Debug 签名可用时重试对应节点。
- 轮换结论：24 的通知/分享、23 的附件/导出也需要一次性规则；不得把任一项目标记完成。下一轮应优先检查较新方案是否获得新输入或新证据，否则继续向下寻找独立安全事项。
- Git：只读核验 `HEAD 551a9f1` 与 `origin/main`；未执行 `git add`、`commit`、`push` 或历史改写。
