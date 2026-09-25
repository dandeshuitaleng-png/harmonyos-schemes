# 现状评估 · 2026-09-23

目标沿用会话19号项目；“作者/仓库”URL为占位，未替换origin。仓库 https://github.com/dandeshuitaleng-png/harmonyos-schemes.git ，分支 dev/nature-19-improvements，HEAD d05b4aa0aa1beaa0c3910eadddc9b3a2b7b257cf。

独立工程 `/Users/Admin/Projects/harmonyos-nature-19/19-urban-nature-observer`。已通过 open -a 打开DevEco Studio新项目；窗口标题、IDE日志项目模型setup及工程绝对路径共同确认，见 evidence/deveco-workspace.txt。Cursor配置仅为历史辅助文件，不算本轮IDE证据。

## 代码事实

ArkTS/ArkUI Stage应用，单页pages/Index；纯TS Observation模型、Preferences存储，API23兼容、DevEco26内置SDK编译。应用权限列表为空，无网络、相机、定位。四种植物观察任务→环境→特征→保存→回顾→再次观察/删除已实现。模型和存储在Node下使用TypeScript转译测试，存储故障由桩模拟，不等同设备故障注入。无外部运行依赖及依赖锁文件，Hvigor依赖IDE运行时。

Git工作树包含上轮尚未提交的代码和文档；全部保留，不reset或覆盖其他编号。根CI只有结构与敏感文件检查，不包含19号规则测试或HAP编译；本轮不修改全仓CI。

当前重新执行：12/12测试通过，assembleHap通过。仍有SemVer警告与无signingConfig警告。API24模拟器5555在线；真机未连接。旧截图与9月21日测试只作历史证据，本轮改动需重新关联验证。

## 发现与推断

- 代码事实：档案ID允许all，但页面用all代表“清空全部”。异常档案中的单条ID可混淆删除范围；应在加载边界拒绝保留字（应用正常生成ID不会用此值）。
- 代码事实：容量只限制10条及80字符ID，未检查序列化字节数。正常10条极端ID经实际计算仍仅6345字节；只有加入异常额外字段才可超预算。原先推断已被验证纠正。本机SDK26上限为16MB，本轮以应用自定8KiB预算约束含未知字段的异常档案，正常生成的记录不受影响。
- 代码事实：模拟器脚本输出目录复用、成功结果仅在末尾写入；新运行失败时旧PASS可能残留，并支持跳过初始空数据保护的resume参数。
- 推断：以上边界完善比扩展识别/云端功能更适合当前可靠性迭代；不改变用户群、数据归属或技术栈。

## 未知与范围

真机、读屏/大字号、平板、深色和访谈沿用旧计划后续门槛，不声称完成。当前无阻塞本轮方向的用户决策。产品身份及规则继续以 ../product-spec.md 为源；此前实现记录见 ../development/VALIDATION.md。

## 全仓基线补充

最终执行根guard时发现原始26号缺AGENTS.md，git ls-tree已核实HEAD即缺失。本轮没有修改该目录，保留为T004必需门槛阻塞，见evidence/baseline-guard-failure.txt。此前只阅读CI未执行根脚本，不能把原先12项业务基线通过表述为全仓CI通过。
