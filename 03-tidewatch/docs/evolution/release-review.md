# 潮汐守望 v0.2.0 交付审查

2026-09-23。本轮本地开发及专用API24模拟器验收完成；未发布、未推送GitHub，未进行真机签名验收。全仓库守卫仍存在原有26号项目结构失败，见下方限制。

交付：观察记录使用本机关系型数据库事务保存；旧草稿自动迁移，原ID/时间/有效期保持，提交读回验证后清理旧副本；迁移或写入异常暂停修改并可重试，删除后不会重新导入旧缓存。隐私选择独立保存，不新增权限或网络服务。

## 方案覆盖矩阵

|原则/功能|实现|验收及证据|结论|
|---|---|---|---|
|P-001/P-002，F-001|ObservationSchema/RdbSnapshotIO/ObservationStore|AC-002/004：T002-native-run.txt，T003-new-restart.json|通过|
|P-002/P-003，F-002|版本及migration_expected标记、事务导入、读回、偏好清理|AC-003/005：T002-native-run.txt，T003-before/after-upgrade.txt，T003-legacy-cleaned.xml|通过|
|P-002/P-004，F-003|仓储门禁、失败回滚、隐私隐藏/恢复|AC-004/005/006：T002-tests.txt、T002-native-run.txt，T003-privacy-*.json/delete-restart.json|通过|
|P-003，F-004|独立工作区、测试脚本、源码清单、README|AC-001/007：baseline-*、T004-clean-build.txt、T004-package.json、release-manifest.txt|通过；全仓库原有守卫失败保留|
|UI-001至004|既有原生页面及新增迁移说明|T003-dark.png/light.png、back-confirm.json及T003审查|通过，限定本轮手机模拟器|

## 步骤与检查

T001 100.0；T002 98.3；T003 98.5；T004 98.5。均按冻结量表自审通过，评分不是独立质量认证；不计算总分掩盖失败。

- 主机测试20/20通过：领域、仓储故障、真实SQLite绑定/回滚契约。
- 原生数据库11/11通过：新库读写重开、JSON/旧格式迁移、过期保留、源清理/隐私保留、触发器造成实际失败回滚、跨重启读回不一致保护、未知版本/坏数据保护、删除不复活、200条重开。
- 生产应用实测：旧版新建→覆盖升级→字段及时间保持；编辑→强停重启；隐私拒绝→重启隐藏→再同意恢复；删除取消/确认→重启为空；新版新建→重启恢复；全部清除→重启为空。最终模拟器无测试记录。
- 同一源码干净临时目录构建34任务成功；本地构建33任务成功。生产HAP只有pages/Index，无测试入口，无新增权限。
- 全仓库守卫原始HEAD和当前工作树均失败于26号项目缺少AGENTS.md。本项目结构及敏感文件检查通过，没有修改其他项目或弱化守卫。

最后源码清单SHA256：`5c7636f9d94c08820630edc3016e61ff9c6a64092787028f9d752fe3fe84a66b`。T003与交付源码相同；T002原生测试涉及文件哈希保持一致。
实际本地HAP的SHA256、大小见[evidence/release-artifact.json](evidence/release-artifact.json)。所有证据位于本目录evidence；各轮失败与修复见reviews。

## 启动与复验

DevEco打开独立项目 `/Users/Admin/Projects/tidewatch-development/03-tidewatch`，同步后选择entry/default/default。完整命令和运行配置说明见[README](../../README.md)。

```sh
cd /Users/Admin/Projects/tidewatch-development/03-tidewatch
./scripts/test.sh
./scripts/build.sh
# 确认专用模拟器地址后运行独立测试bundle
./scripts/device-test.sh 127.0.0.1:5555
```

未签名调试HAP：`entry/build/default/outputs/default/entry-default-unsigned.hap`。已在API24模拟器安装运行；真机需要用户自己的调试签名。

## 非阻断限制与后续

仍保留SnapshotIO全量编码/替换及200条上限，后续附件阶段应改逐条仓储；没有云备份/导出，不支持直接降级只读Preferences的旧版本。清理Preferences的flush失败只做错误传播及门禁代码审查，未对平台做故障注入。

Node内置SQLite有实验性警告；SDK构建存在异常检查/无签名等警告；不影响已执行模拟器路径，不代表真机/发布就绪。照片、定位、离线地图、签名上传、管理员审核、居民摘要均未接入；这些属于后续方案，当前“待审核”仅是本地未审状态。读屏、平板及物理设备矩阵未覆盖。
