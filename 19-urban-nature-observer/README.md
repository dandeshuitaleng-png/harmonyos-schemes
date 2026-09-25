# 城市自然观察 · 19号

面向城市青年和亲子家庭的 HarmonyOS 离线植物观察应用。选择叶缘、叶脉、花果或树皮，记录肉眼可见特征，在本机保存与回顾。所有记录标记为“个人观察，未鉴定”。

## 独立开发工作区

本次从 GitHub 完整克隆到 `/Users/Admin/Projects/harmonyos-nature-19`，19号工程根目录为其下的 `19-urban-nature-observer`。分支：`dev/nature-19-improvements`。

- **开发IDE：DevEco Studio**。以新项目打开此目录（含 `build-profile.json5`），选择新窗口；不要打开仓库总目录作为鸿蒙工程。本轮已用窗口标题与IDE同步日志核实。
- `urban-nature-19.code-workspace` 仅是历史辅助配置，不替代DevEco工程。
- 不把项目导入或覆盖到其他既有工程。

## 开发命令

本机使用 DevEco Studio 26 内置 Node、Hvigor、SDK。编译 SDK 跟随 IDE；最低兼容版本保持 HarmonyOS 6.1.0 / API 23，API 21 模拟器无法安装。

```bash
./scripts/build.sh
node --test tests/observations.test.cjs
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_*.py' -v
```

非默认安装路径可设置 `DEVECO_APP`；规则测试也支持用 `TYPESCRIPT_PATH` 指向已有 TypeScript 模块。测试不需要下载 npm 依赖。首次构建若 IDE 要求同步依赖，执行 IDE Sync；`local.properties` 只配置本机 SDK 路径并已被 git 忽略。

产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`。构建通过不代表有真机签名或商店发布资格。

模拟器回归（API >=23、独占前台、空记录状态）：

```bash
python3 scripts/emulator-smoke.py --device 127.0.0.1:5557
```

脚本仅操作本应用，会生成和删除自己的测试记录；发现初始记录不为空或目标窗口不可见时停止。滑动坐标按当前窗口尺寸计算。本轮验证手机1256×2760，其他尺寸未据此声称验收通过。每次运行创建带UTC时间及随机标识的独立证据目录，保留RUNNING/PASS/FAIL；不再支持跳过空数据检查的resume参数。

## 保存和删除规则

- 只有点击“保存本次观察到本机”才持久化，最多10条；满额需先删除，无自动淘汰。
- 草稿不保存。保存后可结束进程再打开回顾；再次观察新建记录，不覆盖旧记录。
- “暂时看不清”与明确特征互斥；花果“未见”与“看到”互斥。
- 删除/清空必须确认。写入完成后才更新列表；失败尝试回滚，回滚也失败则暂停写入并要求重启核对。
- 损坏或未知版本记录不会自动覆盖。没有网络、相机、定位、社区、账号或云同步功能。

## 文档

- [当前接续状态](docs/evolution/state.md)
- [当前产品与技术方案](docs/evolution/blueprint.md)
- [当前验收结论](docs/evolution/release-review.md)
- [初轮开发方案（历史）](docs/development/PLAN.md)
- [9月21日验证结果（历史）](docs/development/VALIDATION.md)
- [产品规格](docs/product-spec.md)
- [发布台账](docs/release/RELEASE_LEDGER.md)
