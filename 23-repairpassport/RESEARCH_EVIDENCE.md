# 修物志 / Mendbook — 研究证据

检索日期：2026-08-30。目标是个人设备保修/维修履历和用户资料索引，不提供拆机指导、故障诊断或维修报价。

## 来源与真实问题

- [iFixit 官方维修知识库](https://www.ifixit.com/) 与 [iFixit 移动应用公告](https://www.ifixit.com/News/114706/the-ifixit-app-is-here) 证明设备工作台和维修历史是稳定场景。
- [Apple 官方维修支持](https://support.apple.com/repair) 清楚区分保修状态和认证维修路径。

## 竞品核验

| 产品 | 公开能力 | 本方案差异 |
|---|---|---|
| [iFixit](https://apps.apple.com/br/app/ifixit/id6755199743) | 设备工作台、零件、维修指南 | 不托管教程/型号库，只存个人凭据与维修履历。 |
| [Fix Stuff AI](https://apps.apple.com/us/app/fix-stuff-ai-repair-assistant/id6756805849) | 拍照诊断、教程、成本 | 不使用 AI、不给步骤、成本或诊断。 |
| [Apple Repair](https://support.apple.com/repair) | 保修与官方维修 | 不判断资格或授权，只帮助用户整理资料。 |

## 鸿蒙与市场

- [文件选择器](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-file-picker) 可由用户主动选择/保存资料；[受限权限说明](https://developer.huawei.com/consumer/cn/doc/doccenter-capabilities/declare-permissions-in-acl) 建议优先使用 Picker。
- 应用市场、元服务中心及 HarmonyOS/OpenHarmony 公开索引没有返回完全对应的本地维修履历页，保留为待人工复核。

## 准入评分

| 项目 | 分数 |
|---|---:|
| 真实问题、来源与竞争证据 | 5/5 |
| 差异化 | 4/5 |
| 鸿蒙原生可行性 | 5/5 |
| 两周 MVP | 5/5 |
| 风险 | 4/5 |
| **总分** | **23/25** |

不复制 iFixit、Apple 或 Fix Stuff 的指南、图像、型号库、诊断逻辑或品牌内容。
