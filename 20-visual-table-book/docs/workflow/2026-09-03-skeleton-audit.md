# 2026-09-03 工程骨架只读核验

## 处理对象与排程边界

- 本轮先比较编号最新的 `25-wovenday`、`24-visitready`、`23-repairpassport`：三者自上次记录后没有新的产品规则或源码输入，仍分别需要照片/提醒/分享、通知/分享、附件/导出的一次性规则；不重复其既有构建。
- `22-plantrelay` 同样等待导出/提醒/照片规则；`21-stepaccess` 的本机 RDB 路径已构建，当前只剩签名设备运行验收。HDC 本轮可识别设备，但 25–21 均无已安装对应包，工程产物也都是未签名 HAP。
- 因此按轮换规则选择编号较新的安全事项：对 `20-visual-table-book` 做一次结构、配置、正式构建、包内容和源码保全核验。已有 ArkTS、配置与资源只读，未覆盖、重构或删除。
- 本轮新增内容只有本记录；构建刷新可复现的 `entry/build/` 与 `.hvigor/` 缓存，不执行 Git 写操作。

## 结构与配置校验

从工程根目录运行只读 Node 校验，检查 AGENTS、AppScope、Stage/Hvigor 配置、入口 Ability、页面、路由、资源和 workflow，共 19 个必需路径；同时解析 10 个 JSON/JSON5 文件，核对桌面 Home skill、`pages/Index` 路由、页面颜色引用及受限系统能力关键词。

更正记录：第一次运行时工作目录已经是工程根目录，却又将 `20-visual-table-book` 拼入脚本根路径，原始结果为 `REQUIRED_PATHS=19 MISSING=19` 和 `PARSE_FAILURES=10`；这是核验命令路径错误，不是工程缺文件。改用根路径 `.` 后重新执行，原始摘要为：

```text
REQUIRED_PATHS=19 MISSING=0
JSON_JSON5=10 PARSE_FAILURES=0
HOME_ENTITY=true
HOME_ACTION=true
ROUTE_INDEX=true
COLOR_REFS=33 UNIQUE=10 MISSING=0
EXTERNAL_CAPABILITY_HITS=0
```

这里的外部能力扫描覆盖网络、定位、相机、日历、通知、动态权限、Document/Photo Picker 和跨 Ability 结果调用关键词；零命中只证明当前演示草稿切片没有接入这些能力，不代表隐私、设备或上架验收通过。

## 构建、包与源码保全

构建前后对 AppScope、`entry/src`、构建配置、Hvigor 与 OHPM 配置共 15 个源文件计算聚合 SHA-256，然后使用 DevEco Studio 内置 JBR、SDK 和 Hvigor 执行：

```text
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk
JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw \
  --mode module -p product=default -p module=entry@default \
  assembleHap --no-daemon --no-incremental --stacktrace
```

原始关键结果：

```text
SOURCE_PRE=1028064e7d042823cd2ef5378cbe8c48706556650d52198f7aeee7b24c2618fd FILES=15
TYPE CHECK SUCCESSFUL in 258 ms
CompileArkTS... after 2 s 866 ms
PackageHap... after 349 ms
WARN: No signingConfig found for product default
BUILD SUCCESSFUL in 6 s 557 ms
SOURCE_POST=1028064e7d042823cd2ef5378cbe8c48706556650d52198f7aeee7b24c2618fd FILES=15
SOURCE_UNCHANGED=true
```

未签名产物 `entry/build/default/outputs/default/entry-default-unsigned.hap` 为 46,289 bytes，SHA-256：

```text
08fdeba6a17d7f2bf71a766b09ce3a17215b963ea6908f83bd49df9d94437db5
```

`unzip -t` 检查 8 个包内项目并返回 `No errors detected`；包内 `module.json` 的复验结果为：

```text
PACKAGED_HOME_ENTITY=true
PACKAGED_HOME_ACTION=true
```

Hvigor 还报告 `entry` 模块版本不符合 SemVer 的既有警告；本轮按只读边界未修改 OHPM 配置，该警告需要在进入依赖发布或安装门槛前单独处理。

## 设备、门禁与后续

- `hdc list targets` 本轮返回一个非空目标；随后只读查询 `com.hongmengoutputs.visualtable`，`bm dump -n` 返回 `failed to get information`，没有该应用已安装的证据。
- Build：PASS（未签名）。Signing：BLOCKED，构建明确无 `signingConfig`。Device / Visual：BLOCKED，没有可追溯到当前源码的已签名安装包、安装、启动、草稿交互、重启、读屏或截图证据。Store：未进入。
- 产品边界仍是本地演示日期、人数、桌位与可取消草稿；真实预约仍需要商家库存、并发锁定、营业/取消规则、联系人、通知、支付责任和审计，不得由演示骨架推断完成。
- 本轮切片已经完成，`20-visual-table-book` 仍未完成且未被标记完成。仅在源码/配置变化、存在可追溯的受控 Debug 签名安装包，或真实预约规则明确时重试 20。
- 下一轮先重新比较 25、24、23 是否出现新输入；若仍无安全事项，则轮换到 `19-urban-nature-observer` 做尚未留存的同类正式骨架核验，不重复本轮构建充数。
- Git：只读核验当前 HEAD 为 `551a9f1`，本轮未执行 `git add`、`commit`、`push` 或历史改写。
