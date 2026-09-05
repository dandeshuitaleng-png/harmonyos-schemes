
# 所有方案

本目录集中存放现有的 HarmonyOS 方案工程。编号按原始方案批次和原始顺序连续编排；工程名称保留在编号后，避免路径失去可读性。进度只记录已有文档或构建记录可以证明的状态，不将未签名构建视为可上架。

| 编号 | 工程目录 | 团队下一步 |
| --- | --- | --- |
| 1 | `01-beidou-neighboraid` | 配置 Debug 签名并在真机验证核心路径 |
| 2 | `02-quietbeacon` | 完成 Node 4 真机验证与问题修复 |
| 3 | `03-tidewatch` | 完成 Node 4 真机验证与问题修复 |
| 4 | `04-sensecraft` | 完成 Node 4 真机验证与问题修复 |
| 5 | `05-freshloop` | 完成 Node 4 真机验证与问题修复 |
| 6 | `06-greenlens` | 完成 Node 4 真机验证与问题修复 |
| 7 | `07-voicebridge` | 完成 Node 4 真机验证与问题修复 |
| 8 | `08-aidtrace` | 补齐 Node 4 验证并在真机复测 |
| 9 | `09-stillside` | 配置签名后进行真机、视觉与持久化验收 |
| 10 | `10-farmvoice` | 配置签名后进行真机、视觉与持久化验收 |
| 11 | `11-gentlesteps` | 配置签名后进行真机、视觉与持久化验收 |
| 12 | `12-questproof` | 配置签名后进行真机、视觉与持久化验收 |
| 13 | `13-allyecho` | 真机验证感受卡，并确认系统分享边界 |
| 14 | `14-ai-speaking-practice` | 明确 AI/语音服务、数据去向与用户同意规则 |
| 15 | `15-disaster-recovery-map` | 补齐发布门槛并进行真机验收 |
| 16 | `16-fridge-pantry` | 配置签名后进行真机、视觉与持久化验收 |
| 17 | `17-neo-explorer` | 定位并解决当前发布阻塞项 |
| 18 | `18-standby-appointment` | 验证真机与持久化，再决定真实日历接入 |
| 19 | `19-urban-nature-observer` | 配置签名后进行真机、视觉与持久化验收 |
| 20 | `20-visual-table-book` | 完成核心交互 MVP，再验证静态桌位流程 |
| 21 | `21-stepaccess` | 在真机验证本地 RDB 观察流程 |
| 22 | `22-plantrelay`（叶伴 / Leafmate） | 确认导出/提醒/照片规则后继续 MVP，并做真机验证 |
| 23 | `23-repairpassport`（修物志 / Mendbook） | 确认附件与导出规则后继续 MVP，并做真机验证 |
| 24 | `24-visitready`（从容赴约 / ReadyVisit） | 确认通知与分享规则后继续 MVP，并做真机验证 |
| 25 | `25-wovenday`（织日 / WovenDay） | 确认照片、提醒与分享摘要规则后继续 MVP，并做真机验证 |
| 26 | `26-breath-half-hour`（喘息半小时） | 在 DevEco 中完成真机验证并补齐本地构建记录 |
| 27 | `27-accessibility-window-checklist`（无障碍窗口检查表） | 在 DevEco 中打开英文路径工程并补齐 WSL/Node 构建验证 |
| 28 | `28-community-referral-card`（社区转介卡） | 在 DevEco 中打开英文路径工程并补齐真机验证 |
| 29 | `29-silentwindow`（无声窗口 / SilentWindow） | 在 DevEco 中打开英文路径工程并完成真机验证与签名配置 |

各方案的研究资料与跨项目台账保留在对应文档中；每日开发与验收自动化以本目录为工程根路径。

## UI/UX 工作流

对本目录方案做界面设计或 ArkUI 开发时，按仓库技能 `.cursor/skills/harmonyos-scheme-ui/SKILL.md` 执行：先读该方案 `AGENTS.md`，用 UI UX Pro Max 生成 `docs/design/MASTER.md`，映射到 ArkUI 资源后再改页面。不要把 shadcn/ui、Nuxt UI 或 Creative Tim 当作鸿蒙组件库。
