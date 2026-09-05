# 高质量机会研究日志

## 2026-08-30：本日无推荐

检索日期：2026-08-30（Asia/Shanghai）。本轮没有新增项目目录，也没有修改编号表。

### 已执行核验

- 已读取根目录 `README.md`，当前最大连续编号为 `21-stepaccess`。
- 已以“鸿蒙 + 凭证/数字身份”“鸿蒙 + 食物/冰箱”“鸿蒙 + 无障碍/阅读”“鸿蒙 + 社区任务/志愿”等组合词检索华为应用市场公开网页索引；无结果。网页索引无结果不能证明应用市场或元服务中心不存在同类，因此不能作为差异化通过证据。
- 已检查当前方案目录。食品库存与冰箱问题域已被 `16-fridge-pantry` 占用；无障碍空间观察已被 `21-stepaccess` 占用，不能以轻微改名重复入库。

### 淘汰候选

| 候选问题域 | 可复核研究线索 | 接近产品 | 淘汰原因 |
|---|---|---|---|
| 自主身份/可验证凭证夹 | [Veridian Wallet](https://github.com/cardano-foundation/veridian-wallet)；[W3C Verifiable Credentials](https://www.w3.org/TR/vc-data-model-2.0/) | Veridian、Keyring、Bifold | 涉及可信凭证、密钥、撤销、发行方与合规责任；未核验责任主体，直接触发高风险淘汰。 |
| 食品条码与家庭食材信息 | [Open Food Facts 官方组织](https://github.com/openfoodfacts)；[Open Food Facts 网站](https://world.openfoodfacts.org/) | Open Food Facts、Fridge Buddy、现有 16-fridge-pantry | 与现有方案实质重叠；食品成分、过敏原或保质提示还需要权威数据和责任边界。 |
| 城市无障碍步道问答/地图 | [StreetComplete](https://github.com/streetcomplete/StreetComplete)；[Project Sidewalk](https://projectsidewalk.org/) | StreetComplete、Project Sidewalk、[A11yMapr](https://a11ymapr.org/) | 与 21-stepaccess 重叠；若做路线或城市评分，需本地审核组织、数据来源、撤回规则和地图授权，单人两周 MVP 无法可信完成。 |
| 全量离线地图与户外导航 | [Organic Maps](https://organicmaps.app/)；[OpenStreetMap](https://www.openstreetmap.org/) | Organic Maps、OsmAnd、现有 15-disaster-recovery-map | 地图包、导航与数据许可范围超过两周 MVP，且与现有灾害/自然地图方案重叠。 |

### 结论

本日无推荐。没有任何候选同时满足：两类独立一手或近一手来源、三款相近产品核验、可复核的鸿蒙/应用市场差异、两周单人 MVP、以及五项评分每项至少 4/5、总分至少 21/25。

### 下一轮准入动作

1. 优先寻找有公开运营方、明确许可、非高风险、可在本地闭环的垂直工具。
2. 对每个候选补齐应用市场、元服务中心与 OpenHarmony/Gitee 的人工同类检索证据。
3. 只有达到门槛后才创建 `22-英文短名/`，并同时写入 `RESEARCH_EVIDENCE.md`、`AGENTS.md` 与根目录编号表。

## 2026-08-30：即时复核（无推荐）

检索日期：2026-08-30（Asia/Shanghai）。本次为同日即时复核，未新增项目目录，根目录最大编号仍为 `21-stepaccess`。

### 新增核验线索

- [HarmonyOS 文件选择器官方文档](https://developer.huawei.com/consumer/en/doc/harmonyos-references/js-apis-file-picker) 确认 `DocumentViewPicker` 可在 UIAbility 中让用户选择/保存文档，且文档选择 API 可用于原子化服务。
- [HarmonyOS Accessibility Kit 官方文档](https://developer.huawei.com/consumer/en/doc/harmonyos-guides-V5/accessibilitykit-overview-V5) 确认 ArkUI 可提供无障碍文本、描述与事件能力。
- 以上仅证明文件选择与无障碍语义，不证明系统提供 PDF 解析、文本重排、OCR 准确性或法律文件解释能力。

### 追加淘汰：本地易读文档助手

| 评分项 | 分数 | 结论 |
|---|---:|---|
| 真实问题与来源 | 4/5 | 可参考 [Equalify Reflow](https://equalify.app/) 的可访问 PDF 方向及官方 HarmonyOS 文件/无障碍文档。 |
| 竞争证据与差异 | 3/5 | 已有 Adobe Acrobat、Microsoft Lens、系统文件预览等近似产品；应用市场/元服务中心/Harmony 社区无法通过公开网页索引得到可复核的完整同类清单。 |
| 鸿蒙原生可行性 | 4/5 | Picker 与无障碍语义有官方文档证据。 |
| 两周 MVP | 3/5 | 若不引入并验证 PDF 解析/OCR 组件，只能做文件选择，不能交付“易读重排”的核心价值。 |
| 风险 | 3/5 | 服务通知、合同和医疗文件可能被用户当作法律/医疗解释，且缺少可靠失败边界。 |
| **总分** | **17/25** | 未达到 21/25，且有三项低于 4。 |

结论：本日仍无推荐。没有创建 `22-*`，没有修改编号表，也没有生成任何应用代码。

## 2026-08-30：App Store 竞品补充核验（无推荐）

检索日期：2026-08-30（Asia/Shanghai）。新增范围仅作为竞品与需求证据，不能推断鸿蒙市场状态或鸿蒙能力。

- [Seeing AI（美国 App Store）](https://apps.apple.com/us/app/seeing-ai/id999062298)：Microsoft 的低视力辅助工具，页面列出文本、物品、条码与照片描述能力。它使“通用相机视觉辅助”不具备本轮所需的差异化；若涉及人脸、货币或医疗/安全信息，还会扩大风险。
- [Open Food Facts（美国 App Store）](https://apps.apple.com/us/app/open-food-facts-product-scan/id588797948)：列出条码扫描、营养/过敏原与环保信息；与 `16-fridge-pantry` 问题域重叠，并涉及食品数据准确性边界。
- [Wheelmap（美国 App Store）](https://apps.apple.com/us/app/wheelmap/id399239476?platform=ipad)：列出公共场所无障碍细节与电梯/扶梯状态；与 `21-stepaccess` 相邻，且进一步证明这类产品依赖持续数据维护和社区审核。
- [Day One（美国 App Store）](https://apps.apple.com/us/app/day-one-daily-journal-diary/id1044867788)：列出加密、音视频、导出与提醒能力；本地声音档案方向已有强势成熟竞品，且与既有个人记录方案相近。

结论：本轮未发现既满足两周 MVP、低风险、非重叠，又能在应用市场、元服务中心和 HarmonyOS/OpenHarmony 社区留下充分差异证据的候选；仍为本日无推荐。

## 2026-08-30：命名规则更新后的即时轮次

本日已入选并写入编号表的候选为 `22-plantrelay`、`23-repairpassport`、`24-visitready`，恰好达到每日最多 3 个候选的上限。本轮不再创建任何项目目录，以避免绕过限额重复入库。

- 三个入选候选均已包含 Apple App Store 竞品链接、地区、检索日期和可见功能，且分别使用非 GitHub 的一手/近一手来源交叉核验。
- 名称已按最新规则改为面向用户的品牌式名称：叶伴、修物志、从容赴约；功能描述留在副标题和 `AGENTS.md`。
- 本轮无新增推荐的原因是**日上限已满**，不是放宽或跳过质量门槛。

## 2026-08-31：每日高质量机会研究

检索日期：2026-08-31（Asia/Shanghai）。本轮入选 1 个候选：`25-wovenday`（织日 / WovenDay）。其完整来源、Apple App Store 竞品、鸿蒙能力依据、市场待核验项与 22/25 评分见 [`25-wovenday/RESEARCH_EVIDENCE.md`](25-wovenday/RESEARCH_EVIDENCE.md)。

### 淘汰与未入选方向

| 方向 | 可复核线索 | 未入选原因 |
|---|---|---|
| 共享宠物照看 | [Bean](https://bean.pet/)、[Collie](https://www.collie.care/) | 多数公开功能包含用药、疫苗、兽医记录或共同监护；即使缩小范围也与成熟共享日程产品过近，且需避免动物健康责任，未达到本轮差异化门槛。 |
| 全量数字衣橱/穿搭 | [Whering](https://apps.apple.com/us/app/whering-your-digital-closet/id1519461680)、[Stylebook](https://apps.apple.com/us/app/stylebook/id335709058) | 强势产品已覆盖衣橱、搭配、日历、统计、同步；全量录入和图像处理超出两周 MVP。 |

没有为未入选方向创建项目目录；没有实现应用代码。鸿蒙应用市场、元服务中心及 HarmonyOS/OpenHarmony 的直接同类状态仍需人工复核，不能从公开索引无结果推导为不存在。

## 2026-09-01：本日无推荐

检索日期：2026-09-01（Asia/Shanghai）。本轮未创建 `26-*` 目录，也未修改编号表；当前最大编号仍为 `25-wovenday`。

### 已核验候选：熟人之间的闲置物借还

- [Library of Things](https://www.libraryofthings.co.uk/) 是持续运营的社会企业，公开说明预约、取用、归还本地物品的模式；[myTurn](https://myturn.com/) 公开提供物品借还、预约、提醒和资产管理，且 2026 年仍有更新记录。这两项可证明真实使用场景和维护状态。
- Apple App Store（美国，检索日期同上）已有三款非常接近的产品：[Mooch](https://apps.apple.com/us/app/mooch-lend-borrow-and-track/id6469733215)（好友库存、借还与双方确认）、[Borrow](https://apps.apple.com/us/app/borrow/id885644065)（借出/借入跟踪、到期提醒、分享催还）、[Brrow](https://apps.apple.com/us/app/brrow-save-and-earn/id6743072945)（邻里租借/出借市场）。Apple 页面仅作竞争证据，不能推断鸿蒙状态。
- 同时检索华为应用市场、元服务中心与 HarmonyOS/OpenHarmony 的公开网页索引；没有得到可复核的完整同类清单，结论只能是**待人工复核**，不能称“鸿蒙没有”。

| 评分项 | 分数 | 结论 |
|---|---:|---|
| 真实问题、来源与竞争证据 | 4/5 | 运营服务、维护中的产品及三款近似 App 已核验。 |
| 差异化 | 3/5 | 即使缩小为熟人离线借还，也与 Borrow 和 Mooch 的核心路径直接重合。 |
| 鸿蒙原生可行性 | 4/5 | 本地存储、分享、提醒和无障碍语义有既有官方能力证据。 |
| 两周 MVP | 5/5 | 单机借还卡可在两周完成。 |
| 风险 | 4/5 | 不做支付、担保、陌生人匹配或位置共享可控制风险，但物损纠纷仍需明确边界。 |
| **总分** | **20/25** | 差异化低于 4 分，未达到 21/25 准入线。 |

结论：本日无推荐。为避免以轻微改名重复成熟借还产品，本轮只保留研究记录；没有实现应用代码。

## 2026-09-02：本日无推荐

检索日期：2026-09-02（Asia/Shanghai）。本轮按“优先好上架”筛选：优先纯本地、低权限、无账号/支付/内容审核、无敏感行业与外部资质依赖的闭环。未创建 `26-*` 目录，也未修改编号表。

### 已核验候选：搬家箱子与储物清单

- [Sortly 的搬家库存页面](https://www.sortly.com/solutions/home-inventory-software/moving/) 与 [Moving Boxes Organizer（美国 App Store）](https://apps.apple.com/us/app/moving-boxes-organizer/id6766885651?platform=watch) 说明照片、搜索、二维码标签与本地库存是已有明确使用场景；后者近期版本仍有更新。
- Apple App Store（美国，检索日期同上）还核验了 [BoxOrganizer](https://apps.apple.com/us/app/boxorganizer-inventory/id1558366385)、[BoxBuddy](https://apps.apple.com/us/app/boxbuddy-moving-box-organizer/id6758800955) 与 [Boxes](https://apps.apple.com/us/app/boxes-storage-made-simple/id1335784284?platform=ipad)。三者已覆盖箱子/物品清单、二维码/标签、搜索、分享、照片或导出等核心路径。Apple 页面只作为竞争证据。
- 以“搬家、箱子、收纳、清单”检索华为应用市场、元服务中心、HarmonyOS/OpenHarmony 的公开网页索引，未取得可复核的完整同类清单；状态只能标记为**待人工复核**，不能据此称“鸿蒙没有”。

| 评分项 | 分数 | 结论 |
|---|---:|---|
| 真实问题、来源与竞争证据 | 4/5 | 两类独立来源及三款相近产品均已核验。 |
| 差异化 | 2/5 | 本地、隐私、二维码与搜索均已被近似产品直接覆盖，改名无法形成可辩护差异。 |
| 鸿蒙原生可行性 | 4/5 | ArkUI、本地持久化、Picker/分享与服务卡片可承载低权限 MVP。 |
| 两周 MVP | 5/5 | 手动箱子卡、文字条目和搜索可由一人两周完成。 |
| 风险与上架可行性 | 5/5 | 无需账号、支付、医疗/金融数据或公开内容；但高上架可行性不足以弥补差异化。 |
| **总分** | **20/25** | 差异化低于 4 分，未达到准入线。 |

结论：本日无推荐。该方向的上架风险较低，但产品同质化明显，不能以低风险为由降低准入门槛；未实现任何应用代码。

## 2026-09-03：本日无推荐

检索日期：2026-09-03（Asia/Shanghai）。本轮继续优先纯本地、少权限、无支付/内容审核/敏感行业的上架友好方案；未创建 `26-*` 目录，也未修改编号表。

### 已核验候选：合住场景的洗衣排班

- [WashQ 官网](https://washq.co.uk/) 与 [Share the Load 官网](https://www.strousetechnologies.com/share-the-load) 都说明合住者为共享洗衣机安排时段的真实场景，后者公开提供下载入口及近期版本信息。
- Apple App Store（美国，检索日期同上）已核验 [Share The Load](https://apps.apple.com/us/app/share-the-load/id6480417573)（合住洗衣排班、邀请与历史）、[WashWallet](https://apps.apple.com/us/app/washwallet/id6756781711)（设备状态、通知与支付）及 [WASH-Connect](https://apps.apple.com/us/app/wash-connect/id1469627109)（设备可用性、通知、支付与报修）。Apple 页面只作竞品证据。
- 华为应用市场、元服务中心、HarmonyOS/OpenHarmony 社区的公开网页索引没有形成可复核的完整同类清单，故鸿蒙直接同类状态为**待人工复核**，不能声称不存在。

| 评分项 | 分数 | 结论 |
|---|---:|---|
| 真实问题、来源与竞争证据 | 4/5 | 两个持续运营服务与三款近似 App 已核验。 |
| 差异化 | 2/5 | 排班、邀请、通知与历史均已由直接竞品覆盖。 |
| 鸿蒙原生可行性 | 4/5 | 本地日历、提醒、分享和无障碍语义可组成低权限 MVP。 |
| 两周 MVP | 5/5 | 单户排班卡和提醒可由一人两周完成。 |
| 风险与上架可行性 | 5/5 | 若不接设备、不支付、不采集位置或联系人，发布边界清晰。 |
| **总分** | **20/25** | 差异化低于 4 分，未达到准入线。 |

结论：本日无推荐。虽然该方向易上架，但不能以“容易做、容易上架”替代产品差异；未实现任何应用代码。

## 2026-09-05：本日无推荐

检索日期：2026-09-05（Asia/Shanghai）。本轮仍优先低权限、无账号、无支付与无外部内容审核的上架友好路径；未创建 `26-*` 目录，也未修改编号表。

### 已核验候选：桌游聚会的私密准备卡

- [BoardGameGeek 官方 App（美国 App Store）](https://apps.apple.com/us/app/boardgamegeek/id1559701270?platform=vision) 与 [SeatUp 官网](https://seatup.app/) 说明桌游收藏、场次记录、同好组织是有真实使用场景的持续产品方向。
- Apple App Store（美国，检索日期同上）进一步核验 [Board Game Shelf](https://apps.apple.com/us/app/board-game-shelf/id6469036106?platform=ipad)（收藏、筛选、随机选择、场次/玩家统计）、[BoardGameGeek](https://apps.apple.com/us/app/boardgamegeek/id1559701270?platform=vision)（官方社区、内容与收藏）以及 [Board Game Night!](https://apps.apple.com/us/story/id1459678890)（Apple 的桌游聚会内容页）。这些页面仅用于竞品与需求证据。
- 华为应用市场、元服务中心、HarmonyOS/OpenHarmony 社区的公开网页索引无法形成完整同类清单；因此鸿蒙直接同类状态为**待人工复核**，不能声称不存在。

| 评分项 | 分数 | 结论 |
|---|---:|---|
| 真实问题、来源与竞争证据 | 4/5 | 官方生态与运行中的聚会产品可复核。 |
| 差异化 | 3/5 | 私密准备卡虽可避开公共社区和版权内容，但收藏、筛选、组局与记录的主路径已被成熟产品覆盖。 |
| 鸿蒙原生可行性 | 4/5 | 本地卡片、分享、提醒和无障碍语义可完成，不需外部数据。 |
| 两周 MVP | 5/5 | 用户手动输入游戏名、人数、物品清单与分享预览可在两周实现。 |
| 风险与上架可行性 | 5/5 | 不接入游戏资料库、不传播规则或图片、不做公开社交，发布边界清晰。 |
| **总分** | **21/25** | 总分达线，但差异化仅 3 分，不满足每项至少 4 分的硬门槛。 |

结论：本日无推荐。未以低风险 MVP 包装成熟桌游管理能力；未实现任何应用代码。
