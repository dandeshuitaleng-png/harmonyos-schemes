# 织日 / WovenDay — 研究证据

检索日期：2026-08-31（Asia/Shanghai）。这是面向个人的衣物养护与送修前准备日记，不是衣橱穿搭、购物、洗护建议、鉴定或维修交易平台。

## 原始来源与真实问题

- [Ellen MacArthur Foundation：Fashion ReModel](https://www.ellenmacarthurfoundation.org/the-fashion-remodel/learn) 将修补、转售、租赁和再造列为让服装继续被使用的面向消费者模式；其 [2026 年修补报告](https://www.ellenmacarthurfoundation.org/policy-levers-for-resale-and-repair/report) 也说明服装修补有明确的经济与实施条件。
- [Save Your Wardrobe（美国 App Store）](https://apps.apple.com/us/app/save-your-wardrobe-organiser/id1485757044?platform=tv) 的公开页面提供数字衣橱、衣物护理/修补和服务护照，证明衣物维护记录存在真实产品需求。

以上是两个独立来源类别：行业研究机构与实际运营产品页；GitHub 未作为唯一或准入来源。

## 竞品核验（含 Apple App Store）

| 产品 | 检索地区与公开能力 | 本方案边界与差异 |
|---|---|---|
| [Save Your Wardrobe](https://apps.apple.com/us/app/save-your-wardrobe-organiser/id1485757044?platform=tv) | 美国；数字衣橱、护理/修补、服务护照 | 织日不提供衣橱全量管理、消费建议或服务商网络；只围绕一件已拥有衣物的养护约定和一次送修准备。 |
| [Whering](https://apps.apple.com/us/app/whering-your-digital-closet/id1519461680) | 美国；衣橱整理、穿搭、社区、消费/穿着分析 | 织日不做搭配、社交、AI 抠图、商品库或消费分析。 |
| [Stylebook](https://apps.apple.com/us/app/stylebook/id335709058) | 美国；衣物目录、搭配、日历、打包清单和统计 | 织日不做衣橱目录或穿搭日历；MVP 只维护少量需要照料的衣物。 |

Apple 页面仅作竞争与需求证据，检索日期同上；不用于推断鸿蒙市场状态。

## 鸿蒙生态与可行性核验

- [HarmonyOS NEXT Design](https://developer.huawei.com/consumer/en/design/) 明确列出 Picker、分享和服务卡片等设计能力；本方案仅把它们用作照片/凭据的临时选择、分享前预览和下一件待处理衣物的轻量入口。
- [服务卡片官方文档](https://developer.huawei.com/consumer/cn/doc/HarmonyOS-Guides/ide-service-widget) 说明 ArkTS 卡片的创建和静态/动态卡片边界。
- [Accessibility Kit](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/accessibilitykit-overview-V5) 说明 ArkUI 可提供无障碍文本、描述与事件。
- 以“衣橱、穿搭、服装护理、修补”检索华为应用市场公开网页索引，未得到可复核的直接同类页面；元服务中心、HarmonyOS/OpenHarmony 社区的完整同类清单也无法从公开索引证明。因此“鸿蒙是否已有直接同类”为**待人工复核**，不得表述为“鸿蒙没有”。

## 准入评分

| 项目 | 分数 | 依据 |
|---|---:|---|
| 真实问题、来源与竞争证据 | 4/5 | 行业机构与运营产品各一类来源，且完成三款近似产品核验。 |
| 差异化 | 4/5 | 从全衣橱/穿搭转为少量衣物的养护约定、送修前说明和本地交接摘要。 |
| 鸿蒙原生可行性 | 4/5 | ArkTS/ArkUI、Picker、分享、卡片与无障碍语义均有官方文档；不承诺未核验能力。 |
| 两周 MVP | 5/5 | 本地单列表、事件记录、摘要预览、轻量卡片，单人可闭环。 |
| 风险 | 5/5 | 不鉴定真伪、不推荐洗涤剂/处理方式、不报价、不撮合交易，也不宣称环保效果。 |
| **总分** | **22/25** | 五项均至少 4 分，达到准入线。 |

不复制或抓取任何竞品的服装图库、商标、文案、评分、服务商资料或用户数据。
