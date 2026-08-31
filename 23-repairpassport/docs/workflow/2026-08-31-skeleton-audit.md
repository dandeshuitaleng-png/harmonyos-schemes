# 2026-08-31 · 修物志工程骨架只读核验

运行时间：2026-08-31 03:00–03:07 CST（检查脚本开始于03:03）。处理对象：`23-repairpassport`。本轮最小切片为既有工程的结构、配置、正式路径构建与包检查；不实施产品功能、不覆盖源码、不修改既有配置。

## 排程与现状

- 已读取 `all-schemes/README.md`、24 个编号工程已有的 `docs/workflow` 状态、最新三项的 AGENTS、23 的研究方案、页面规格、源码和配置。19 没有 workflow，改读其 `docs/release/RELEASE_LEDGER.md`，不将无台账视为已完成。
- 最新三个未完成工程为 24、23、22，均已有原生骨架。24 最近已完成多个本地切片，真实通知需要一次性权限/调度语义决定，因此本轮不继续其实现，轮换至23的尚未完成的独立工程核验。
- 24 个工程均能找到本次15项最低结构路径或声明的等价路径。15 的入口为 `.ts`、图标为 AppScope PNG；首轮按统一模板路径扫描产生两个疑似缺件，核对实际声明后修正本轮检查脚本并重验，无需新建文件。此清单不代表24个工程功能或配置全部通过。
- 21 的 `pages/Index.ets` 当前存在，旧文档中的“入口缺失”不再代表当前事实；本轮未重建或修改21。
- 当前已存在 Git 仓库。HEAD 为 `ce1af4d`（README 看板）；23源文件已包含在既有提交 `4268c1b`，不再是旧记录中的未跟踪目录。本轮开始时 `git status --short` 为空；未执行 Git 写入。

## 验证命令与原始证据

所有路径均基于正式英文工程根目录 `/Users/huangnianpeng/Desktop/7/hongmengOS/all-schemes/23-repairpassport`。

```sh
/Applications/DevEco-Studio.app/Contents/tools/node/bin/node docs/workflow/evidence/2026-08-31-skeleton-audit.cjs
export DEVECO_SDK_HOME=/Applications/DevEco-Studio.app/Contents/sdk
export JAVA_HOME=/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home
export PATH=/Applications/DevEco-Studio.app/Contents/tools/node/bin:$PATH
/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw --mode module -p product=default -p module=entry@default assembleHap --no-daemon --no-incremental --stacktrace
unzip -t entry/build/default/outputs/default/entry-default-unsigned.hap
/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc list targets
git status --short
git log -3 --format='%h %s %cI' --name-only
git log -1 --format='%H %s %cI' -- 23-repairpassport
```

最后一条 Git 命令在 `all-schemes` 根目录执行。HDC 探测限时8秒；本次立即返回，不存在把超时当作无设备的问题。SHA-256与前后源码哈希由 Python `hashlib.sha256` 计算，记录在原始证据中。

| 检查 | 原始结果 | 结论 |
| --- | --- | --- |
| 最新三项结构 | 各15项均存在 | 文件层骨架齐全，不创建替代工程 |
| JSON/JSON5解析 | 各10项 `PARSE_PASS`，共30项 | 只证明能解析 |
| Stage/模块/Ability/页面路由 | 最新三项均为 true；phone/tablet；权限列表空 | 入口路径存在，不等于桌面可启动 |
| 桌面启动声明 | 最新三项 `hasHomeSkill:false`；`CONFIG_FAILURE_COUNT 3`；重验 `AUDIT_EXIT=2` | 配置核验 FAIL，缺 Home action/entity skill |
| 23 正式构建 | `TYPE CHECK SUCCESSFUL in 348 ms`；`CompileArkTS`；`PackageHap`；`BUILD SUCCESSFUL in 8 s 220 ms`；`BUILD_EXIT=0` | Build PASS，未签名 |
| HAP完整性 | `No errors detected in compressed data`；`UNZIP_EXIT=0` | 容器完整，不代表可安装 |
| 源码/配置保全 | `SOURCE_FILES_CHECKED=16`；`SOURCE_CHANGES=[]`；工程 `git diff --exit-code` 返回0（写本轮文档前） | 未更改已有工程实现 |
| 签名 | 三项 `signingConfigCount:0`；构建 `No signingConfig found for product default` | Signing BLOCKED |
| 设备 | HDC退出0，stdout为 `[Empty]` | Device BLOCKED；无目标、未安装 |
| 视觉/无障碍/持久化 | 本轮无运行截图、读屏、大字号或重启恢复 | 未验证，不得借构建判PASS |

产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`，95877 bytes，SHA-256 `fee998941edbbe62b6d5c8a99b3b7b185c0f4f0c00b3a06bab67c5b4934aa898`。本轮包内 `module.json` 的 `EntryAbility` 也没有 `skills`，说明打包没有自动补齐桌面入口。

对照本机 DevEco 原生 Empty Ability 模板，桌面入口声明是同一个 skill 内的 `ohos.want.action.home` 和 `entity.system.home`。模板路径及全文摘录保存在 post-build 证据。当前配置缺少整个 `skills` 字段；这是静态配置缺陷，未以未进行的桌面点击测试冒充运行结论。

未阻断构建的警告仍包括：entry模块 SemVer 提示、Preferences 可能抛异常、`getContext` 弃用。本轮不越过“已有工程只读”要求修订这些代码或配置。完整MVP仍缺真实附件/失效URI/真实导出及设备验收；Backend不适用于此本地切片，Store未进入预检。

## 本轮改动与限制

- 新增本报告、只读检查脚本、checks/recheck/build/post-build原始证据；在22、23、24的workflow中追加轮换交接。构建刷新23的忽略产物与缓存。
- 未新增页面、数据模型或外部能力；没有覆盖、重构、删除已有工程文件。所有既有源码/配置哈希保持一致。
- 没有读取或管理签名私钥、口令、证书或Profile；没有安装、上传、提交审核，也没有执行 `git add`、`commit`、`push` 或改写历史。
- 桌面入口缺陷已定位并复验；修复需要修改已有 `module.json5`，超出本自动化的只读限制，因此记录为待其他获授权实现任务处理，不伪造“已修复”。

## 切片后重新比较与下一轮

| 编号 | 状态/缺失条件 | 下一步 | 重试触发 |
| --- | --- | --- | --- |
| 24 从容赴约 | 未完成；Home skill缺失、签名与设备缺失；真实通知语义待决定 | 保留待办，不连续扩展24；获授权后修入口，再处理通知/分享边界 | 配置变化、可用签名设备或一次性通知规则到位 |
| 23 修物志 | 本轮核验切片完成，工程未完成；配置FAIL，未签名构建PASS，设备BLOCKED；导出/附件规则未定 | 立即退出23的本轮工作；获授权实现任务修Home skill后复验、安装及桌面启动 | 源配置变化、签名设备到位，或附件/导出语义明确 |
| 22 叶伴 | 未完成；已做结构/配置检查，尚无本自动化当天正式构建核验；同有Home skill、签名设备、真实导出规则缺口 | 下一轮候选切换为22，仅做尚未做过的构建/包/源码保全核验，不覆盖现有代码 | 下轮先检查是否出现更高编号方案或已有新证据，避免重复 |

本轮只完成23这一项完整核验切片，不额外启动22构建。22核验结束后再次比较最新三项；若三项只剩相同外部阻塞且输入/代码均未变，不反复运行相同检查，应登记并选择21或更高编号中其他尚有安全事项的工程。不得把任何工程因轮换标为完成。

## 原始证据文件

- `evidence/2026-08-31-skeleton-audit.cjs`：可重跑的只读检查脚本（失败时退出2）。
- `evidence/2026-08-31-checks.txt`：首次清单、配置、源码哈希、Git、HDC原始输出。
- `evidence/2026-08-31-recheck.txt`：正确解析15等价路径后的重验输出；仍保留3个配置失败。
- `evidence/2026-08-31-build.txt`：完整原始构建输出，保留ANSI控制符。
- `evidence/2026-08-31-post-build.txt`：包检查、SHA-256、打包Ability元数据、本地官方模板、前后源码哈希与Git结果。
