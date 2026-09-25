# 潮汐守望 / TideWatch

HarmonyOS 原生离线文字观察簿，当前开发版本 **0.2.0**。当前版本可以新建、编辑、检索、筛选和删除本机观察，保留过期历史，显示来源、采集时间、有效期与待审核状态。观察不等同于实时预报或公共公告。

## 独立开发工作区

- 克隆根目录：`/Users/Admin/Projects/tidewatch-development`
- DevEco 项目：本目录 `03-tidewatch`（不要打开其他方案目录后覆盖文件）。
- VS Code：打开上一级 `TideWatch.code-workspace`，新窗口只包含本项目。
- 开发分支：`codex/tidewatch-development`。

## 构建与测试

环境：macOS、DevEco Studio，使用 IDE 自带 Node/JBR/SDK。当前验证环境为 DevEco 26 / API 26 编译 SDK，最低兼容 API 23，目标 API 23。

```sh
cd /Users/Admin/Projects/tidewatch-development/03-tidewatch
./scripts/test.sh
./scripts/build.sh
```

IDE 位于其他目录时设置 `DEVECO_ROOT`。测试使用 IDE 内置 TypeScript 编译器及 Node 测试运行器，不需要 npm 安装。构建输出：`entry/build/default/outputs/default/entry-default-unsigned.hap`。

在 DevEco 内选择本应用对应的调试签名后才能进行物理设备安装验收；未签名包在本轮 API 24 模拟器成功安装，不等于已具备发布签名。

## 使用流程

1. 阅读隐私说明并同意本机保存，也可选择不保存。
2. 新建观察，填写标题、公共地点概述、现场描述、类型、风险级别和有效期。
3. 保存成功后在观察簿查看；内容不会上传，尚无审核人。
4. 编辑有效记录不会更改采集时间及有效期；过期记录只读，新的情况另建记录。
5. 通过搜索和全部/有效期内/已过期筛选查看历史；单条或全部删除均需再次确认。
6. 撤回保存同意后隐藏已有记录，重新同意可恢复查看。需要删除时请在同意状态下执行删除。

本机最多200条文字记录。数据损坏或读取失败时暂停修改，不会静默清空；请先重试，持续失败时保留应用数据。未提供云备份或导出，不要通过卸载解决读取问题。

## 代码结构

- `entry/src/main/ets/data/Observation.ts`：字段、校验、时间规则、旧格式兼容、查询。
- `entry/src/main/ets/data/ObservationRepository.ts`：读取成功门禁、写入互斥、失败后重新读取。
- `entry/src/main/ets/data/ObservationStore.ets`：仓储装配与独立隐私选择。
- `entry/src/main/ets/data/RdbSnapshotIO.ets`：关系型数据库事务、旧草稿迁移和失败保护。
- `entry/src/main/ets/data/ObservationSchema.ts`：数据库结构、固定列与绑定参数。
- `entry/src/main/ets/pages/Index.ets`：隐私页、表单、记录列表和删除确认。
- `tests/observation.test.cjs`：领域及持久化异常测试，不替代设备UI测试。

## 方案及验证

- [完整开发流程与分期方案](docs/workflow/development-plan.md)
- [当前方案及追溯计划](docs/evolution/blueprint.md) · [计划](docs/evolution/plan.md)
- [v0.2.0 整体验收报告](docs/evolution/release-review.md)
- [v0.1 历史验证报告](docs/workflow/validation-report.md)

后续照片/定位、签名上传、管理员复核、居民摘要、权威潮汐数据源均未接入。相关接入流程、状态机与验收标准在开发方案中列出，不能把当前的“待审核”文字理解成真实提交给审核服务。

## DevEco运行配置显示“未找到模块”

命令行构建成功不代表IDE已完成工程导入。如果模块显示`[none]`：

1. 确认DevEco打开的是`03-tidewatch`目录。
2. 关闭运行配置对话框，执行“文件 → 同步和刷新项目”，等待同步成功。
3. 在“运行 → 编辑配置”中选择同步生成的`entry`：模块`entry`、产品`default`、目标`default`，启动方式为“默认Ability”。
4. 点击确定，再选择兼容设备运行。

2026-09-21已实际完成上述同步并确认模块识别成功；[修复后的配置截图](docs/verification/ide-run-configuration.png)。

## v0.2 数据升级与设备验证

首次同意保存并进入时，旧Preferences草稿自动迁入本机关系型数据库；事务提交并逐字段读回校验成功后，清除旧草稿副本，隐私选择保留。迁移或读取失败将暂停修改并提供重试，不会用空列表覆盖原数据。升级后不要直接降级安装只支持Preferences的旧版。

设备集成测试必须指定专用模拟器的hdc地址（用hdc list targets查看）：

```sh
./scripts/device-test.sh 127.0.0.1:5555
```

脚本构建独立测试bundle `com.harmonyradar.tidewatch.rdbtest`，操作其合成数据沙箱；不向正式应用加入测试路由。测试结果写入docs/evolution/evidence。20项主机测试、11项原生数据库用例及生产升级/重启/隐私/删除操作已验收，完整限制见验收报告。

全仓库守卫当前在原始HEAD也因26号项目缺少AGENTS.md而失败；本项目结构与敏感文件检查通过。物理设备签名、商店发布与后续照片/定位未验收。
