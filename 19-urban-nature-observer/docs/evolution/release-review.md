# E1 交付审查 · 2026-09-23

**19号可靠性改进及本地验证已完成；本轮总体验收未全部通过，T004被原有全仓检查问题阻塞。尚未签名发布或推送GitHub。**

## 交付范围与证据

- 开发IDE为DevEco Studio，已在独立新项目窗口打开19号工程并完成同步；证据deveco-workspace.txt。
- 模型增加8KiB应用档案预算和all保留ID校验；异常档案保持原数据、拒绝覆盖。保留原离线观察闭环与Schema1合法记录。
- 脚本每次建立独立RUNNING/PASS/FAIL证据，识别hdc零退出码错误，移除resume绕过，按窗口尺寸滑动。
- 15项生产模型/存储故障桩测试、3项脚本测试通过；DevEco构建与无缓存临时工程构建成功。
- API24手机1256×2760模拟器第二轮完整通过：选择互斥、保存、结束进程恢复、再次观察、取消/确认删除、清空并重启。已审阅原生截图。第一轮超时FAIL原样保留。
- HAP SHA256：`85fdd87acb5fc066210e449a9da9c945f03b8b52d66f2114cb1c4451db18a636`，97745 bytes，ZIP完整性通过。
- 当前代码/配置/测试摘要：`2f90ca8e6d50e2409e13c3ddc4aa79e624ef31347acda3b5084e1947ee2405ea`，逐文件见evidence/source-manifest.json。

## 计划结论

| 步骤 | 自评分 | 状态 | 主要证据 |
| --- | --- | --- | --- |
| T001评估与方案 | 100.0 | passed | DevEco窗口/路径、基线、纠正过的方案 |
| T002档案边界 | 100.0 | passed | 15/15、构建、先失败后修复日志 |
| T003回归证据 | 100.0 | passed | 3/3、第二轮完整模拟器日志/截图 |
| T004整体验收 | 83.3 | blocked | clean构建/18测试通过，但全仓guard失败 |

评分只针对各步预先固定检查项，是自审记录而非独立认证；前三步高分不能抵消T004失败。

追溯：P-001→F-001/002→Observation/Store/Index→AC-002/004；P-002→F-001→原生观察提示与权限空列表→AC-001/004；P-003→F-003/004→独立证据/DevEco项目/clean构建→AC-001/003/005。AC-005保留失败，未删分母或弱化断言。

## 启动

DevEco Studio打开本工程根目录（含build-profile.json5），使用新项目窗口。详细命令见README：`./scripts/build.sh`、`node --test tests/observations.test.cjs`、Python unittest；模拟器命令指定空记录的API>=23设备。清洁工程测试目录位置见evidence/clean-environment.txt。

## 当前阻塞及后续

原始提交的26-breath-half-hour缺少AGENTS.md，根CI脚本因此失败，非19号变更引入；需要在26号维护范围内补齐并重新运行。没有擅自修改其他编号或跳过CI。

原有SemVer警告仍存在，当前不阻断编译/模拟器；真机签名、深色/放大字体/读屏/平板、极端磁盘故障与访谈、商店资料是后续发布门槛。没有新增账号、识别、定位或社区。

## 2026-09-25 同步前复核

为避免公开签名密码，可提交的build-profile.json5已移除signingConfigs；本机忽略备份保留。之后重新运行15项模型测试、3项脚本测试及assembleHap均通过；当前编译HAP未签名，真机调试签名需在本机DevEco配置。原9月23日HAP哈希仅对应当时产物。
