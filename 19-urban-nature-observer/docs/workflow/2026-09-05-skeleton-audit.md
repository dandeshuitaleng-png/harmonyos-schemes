# 2026-09-05 工程骨架只读核验

## 处理对象与排程边界

- 本轮先比较编号最新的 `25-wovenday`、`24-visitready`、`23-repairpassport`：三者自既有 workflow 记录后没有新的产品规则或源码输入，仍分别等待照片/提醒/分享、通知/分享、附件/导出的一次性规则，因此不重复既有构建。
- 上轮已经完成 `20-visual-table-book` 的正式骨架核验；按轮换记录，本轮选择 `19-urban-nature-observer`，补齐此前未留存的结构、配置、正式构建、包内容和源码保全审计。
- 已有 ArkTS、配置、资源和产品文档全程只读，未覆盖、重构或删除。本轮新增内容只有本记录；正式构建仅刷新可复现的 `entry/build/` 与 `.hvigor/` 缓存。
- 两次预检命令曾因执行目录参数输入错误，在读取工程或启动构建前分别返回 `No such file or directory`；改用工程绝对工作目录后重验。该错误属于核验命令错误，不是项目缺文件或构建失败。

## 结构与配置校验

从工程根目录运行只读校验，检查 AGENTS、AppScope、Stage/Hvigor 配置、入口 Ability、页面、路由、Light/Dark 资源、图标、产品规格和 workflow，共 19 个必需路径；同时解析 11 个 JSON/JSON5 文件，核对桌面 Home skill、`pages/Index` 路由、页面颜色引用及受限系统能力关键词。

原始摘要：

```text
REQUIRED_PATHS=19 MISSING=0
JSON_JSON5=11 PARSE_FAILURES=0
HOME_ENTITY=true
HOME_ACTION=true
ROUTE_INDEX=true
COLOR_REFS=37 UNIQUE=11 MISSING=0
EXTERNAL_CAPABILITY_HITS=0
```

受限能力扫描覆盖网络、精确定位、相机、照片/文档 Picker、通知、动态权限和跨 Ability 结果调用关键词；零命中只证明当前会话观察切片未接入这些能力，不代表隐私、设备、生态内容或上架验收通过。

## 构建、包与源码保全

构建前后对 AppScope、`entry/src`、根/entry 构建配置、Hvigor 与 OHPM 配置共 16 个源文件计算聚合 SHA-256，然后使用 DevEco Studio 内置 JBR、SDK 和 Hvigor 执行：

```text
DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk
JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw \
  --mode module -p product=default -p module=entry@default \
  assembleHap --no-daemon --no-incremental --stacktrace
```

原始关键结果：

```text
SOURCE_PRE=4945c9c4c5d041acf5960f1739d72056451b40de40edaebbbd7005062bbc6fc3 FILES=16
TYPE CHECK SUCCESSFUL in 455 ms
CompileArkTS... after 6 s 182 ms
PackageHap... after 1 s 47 ms
WARN: No signingConfig found for product default
BUILD SUCCESSFUL in 15 s 5 ms
SOURCE_POST=4945c9c4c5d041acf5960f1739d72056451b40de40edaebbbd7005062bbc6fc3 FILES=16
SOURCE_UNCHANGED=true
```

未签名产物 `entry/build/default/outputs/default/entry-default-unsigned.hap` 为 58,410 bytes，SHA-256：

```text
3f9e05e03bae44006d8323db4166251347fb9f80610050b18fff38ba0446207d
```

`unzip -t` 检查 8 个包内项目并返回 `No errors detected`；包内 `module.json` 复验结果为：

```text
PACKAGED_HOME_ENTITY=true
PACKAGED_HOME_ACTION=true
```

Hvigor 同时报告 `entry` 模块版本不符合 SemVer 的既有警告；本轮按只读边界未修改 `oh-package.json5`，该项需在进入安装或依赖发布门槛前单独处理。

## 设备、门禁与后续

- `hdc list targets` 本轮可识别 1 个目标；只读查询 `com.hongmengoutputs.urbannature` 返回 `error: failed to get information and the parameters may be wrong.`，没有该应用已安装的证据。
- Skeleton / Config：PASS。Build：PASS（未签名）。Signing：BLOCKED，构建明确无 `signingConfig`。Device / Visual / Accessibility：BLOCKED，没有可追溯到当前源码的已签名安装包、安装、启动、观察流程、重启、读屏、大字号或截图证据。Store：未进入。
- 产品 MVP 仍为 FAIL：当前仅支持会话内“个人观察，未鉴定”路径；本地持久化和保留/删除语义尚未确认，三种植物场景可用性、相机/位置、敏感物种地点保护、候选识别和社区审核均未验证或未进入范围。
- 本轮切片已完成，`19-urban-nature-observer` 仍未完成且未被标记完成。仅在源码/配置变化、存在可追溯的受控 Debug 签名安装包，或本地记录保留/删除规则明确时重试 19。
- 下一轮先重新比较 25、24、23 是否出现新输入；若仍无安全事项，轮换到 `18-standby-appointment` 检查是否存在尚未留存且不依赖用户规则的正式骨架核验，不重复 19 构建充数。
- Git：只读核验当前 HEAD 为 `551a9f1`；未执行 `git add`、`commit`、`push` 或历史改写。
