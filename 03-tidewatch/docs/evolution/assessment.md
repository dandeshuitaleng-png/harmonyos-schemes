# 现状评估 · 2026-09-22

仓库：https://github.com/dandeshuitaleng-png/harmonyos-schemes.git
目标子项目：03-tidewatch。分支codex/tidewatch-development，HEAD d05b4aa0aa1beaa0c3910eadddc9b3a2b7b257cf。
独立克隆：/Users/Admin/Projects/tidewatch-development；DevEco打开03-tidewatch，已通过System Events实际列出并提升该窗口核实。工作区TideWatch.code-workspace。此前IDE模块问题已于2026-09-21同步修复。

## 授权与事实来源

用户要求按repo-evolution完整开发。新消息中的“作者/仓库”为占位URL，依照技能“已有会话目标持续有效”沿用本项目（假设D-001）；未创建第二份克隆，也未更改remote。

现有工作树含前轮源码、文档、测试与IDE截图的未提交改动；全部保留，未重置。出现entry/.preview生成目录，不作为源码。
本轮可执行基线与上游HEAD不同，具体文件哈希见evidence/baseline-manifest.txt；后续证据不得仅引用HEAD。

## 代码证实

- ArkTS/ArkUI原生HarmonyOS应用，EntryAbility→pages/Index单路由。最低/目标API23，本机API26 SDK编译。无第三方运行依赖，暂无依赖锁文件；CI仅仓库结构/敏感文件守卫，不运行应用测试。
- Observation.ts包含真实字段、有效期、校验、旧格式兼容和筛选；Index包含创建/编辑/删除/隐私选择；ObservationRepository包含加载门禁与写入互斥。
- ObservationStore使用Preferences将全部记录序列化到drafts单值；失败时尝试恢复缓存再flush，不是数据库事务。
- 网络、相机、定位权限未声明；无照片/定位/上传/审核/居民页面。固定“待审核”表示本机未审状态，不是已接入管理员。
- 现有端到端离线文字流程可运行；历史截图仅是历史证据，本轮重新验证相关改动。

## 基线

scripts/test.sh：17/17通过。scripts/build.sh：33任务、BUILD SUCCESSFUL 15s681ms。证据见evidence/baseline-tests.txt、baseline-build.txt。
安装脚本已读：调用本机IDE工具，不含远程执行或发布。CI脚本已检查，仅扫描仓库。
历史警告包括模块SemVer、部分Preferences异常检查、缺少签名；未阻断未签名模拟器构建。物理设备安装/上架仍无本轮签名证据。

## 风险与推断

R-001（事实）：记录持久化为全量字符串，不具备多记录/未来附件的事务边界。
R-002（推断）：迁移若只判断“数据库为空”，用户清空后可能重新导入旧偏好记录。因此必须单独存迁移完成标记。
R-003（推断）：迁移后永久保留旧Preferences原文会使删除与隐私说明不一致。因此提交后读回验证，清理旧草稿键；失败则禁止修改并允许重试清理。
R-004（事实）：本轮设备是专用模拟器，无法替代真机、读屏或上架验收。
R-005（未知）：后续照片来源、地图许可、审核服务器运营主体与数据源未确定，只阻塞对应未来阶段。

## 本轮选择

v0.2.0：本地关系型数据库及无损迁移切片。照片/定位延后至v0.3候选，不以本轮完成推算整体产品已完成。保留现有用户群、ArkUI与本机数据归属，无新增账号、付费或服务端。
旧方案docs/workflow/development-plan.md保留为路线历史；当前版本范围、追溯与状态由本目录维护。

## 2026-09-23 补充基线发现

全仓库守卫首次实际执行失败：26-breath-half-hour缺少AGENTS.md。在临时目录还原未改HEAD并运行同一脚本复现相同失败（evidence/T004-guard-baseline.txt）。这是仓库既有的其他项目结构问题，不是潮汐变更新增回归；不能将全仓库守卫报告为通过。
