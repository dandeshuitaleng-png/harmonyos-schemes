# 喘息半小时

HarmonyOS 本地版：为照护者整理半小时替班请求，复制给亲友，并手动跟进结果。

## 已实现

- 联系人新增、编辑、删除；历史请求保留联系人称呼快照。
- 模板、标题、联系人、日期、时间、事项、备注；自动计算30分钟结束时间。
- 草稿保存、继续编辑、详情、筛选、删除确认、未保存修改退出确认。
- 请求文案预览和复制；复制不改变发送状态。
- 手动记录待回应、已接受、已完成、延期、取消；延期后可重新编辑为草稿。
- 本机文件持久化、临时文件替换、读写异常提示；首次启动不生成演示数据。

## 打开与运行

在 DevEco Studio 中独立打开本项目根目录（包含 `build-profile.json5`），不要只打开 `entry` 子目录，也不要覆盖其他项目。
当前验证环境为 macOS、DevEco Studio 26 内置 SDK、API 21 模拟器；运行模块为 `entry`，入口为 `EntryAbility`。
使用 IDE 的 Build / Run 运行完整应用。UI Preview 不替代文件存储和剪贴板的模拟器验证。

本机命令行构建：

```sh
env DEVECO_SDK_HOME='/Applications/DevEco-Studio.app/Contents/sdk' JAVA_HOME='/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home' PATH='/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home/bin:/Applications/DevEco-Studio.app/Contents/tools/node/bin:/usr/bin:/bin:/usr/sbin:/sbin' /Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw --mode module -p module=entry@default -p product=default assembleHap
```

## 验证

运行 `node tests/run-tests.cjs`：22项业务逻辑和存储适配测试，覆盖日期、跨天/跨年、状态转换、校验、持久化和损坏文件保护。脚本使用当前 DevEco 安装中的 TypeScript，并用 Node 文件系统适配器验证仓库逻辑，不替代原生端测试。
`node tests/simulator.cjs dump` 为本机 API21 模拟器 UI 检查辅助命令，默认连接 `127.0.0.1:5555`。
具体人工回归结果见 `DEVELOPMENT_PLAN.md`。

## 边界

无账号、后端、云同步、自动消息或对方自动确认。状态由使用者记录，变更时间和取消仍需自行通知亲友。数据仅在本机，卸载会清除。当前产物未配置发布签名，不能视为可上架版本；真机兼容、签名和发布材料仍需后续验证。
