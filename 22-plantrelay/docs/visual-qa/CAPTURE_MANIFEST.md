# 叶伴软陶花园 · Visual QA 捕获清单

> Candidate: 2026-09-07 本地未签名构建，HAP SHA-256 `814c5e056f3ed185c869558c6a7eb28fc2804166fad77558e2be1ba0ed58c36d` · Mode: exploratory

## 捕获环境

| 字段 | 值 |
| --- | --- |
| 渲染器 | DevEco Studio 6.1 随附的 HarmonyOS 原生 Previewer |
| 设备级别 | phone，矩形屏幕；不等同真机 |
| 方向 / 语言 | portrait / zh_CN |
| 标准尺寸 | 1080×2340 px，480 dpi，约 360×780 vp |
| 窄屏尺寸 | 960×1920 px，480 dpi，约 320×640 vp |
| 主题 | Light / Dark |
| 字号 | 1.0；Previewer 字号倍率命令未验证 |
| 数据 | 原生 Previewer 隔离测试记录 `preview/window/check tray/tester`，不属于应用样例数据或用户数据 |
| 捕获方式 | `scripts/native-preview.cjs`，由当前 `modules.abc` 收取原生 JPEG 帧 |

## 已捕获范围

| ID | 页面 / 状态 | 主题 / 设备 | 证据 | 结果 |
| --- | --- | --- | --- | --- |
| CAP-01 | 花园空态、主 CTA、软陶主景 | Light / 360vp | `/tmp/leafmate-ui-v2/initial.jpg` | PASS |
| CAP-02 | 花盆换色与选中态 | Light / 360vp | `/tmp/leafmate-ui-v2/lilac.jpg` | PASS |
| CAP-03 | 新建表单空态、禁用态与填好状态 | Light / 360vp | `/tmp/leafmate-ui-v3/create-fields.jpg`、`form-ready.jpg` | PASS |
| CAP-04 | 交接待接手、接手后待完成 | Light / 360vp | `/tmp/leafmate-ui-v3/relay-pending.jpg`、`accepted-action.jpg` | PASS after fix |
| CAP-05 | 完成表单禁用态 | Light / 360vp | `/tmp/leafmate-ui-v3/complete-empty.jpg` | PASS |
| CAP-06 | 完成足迹、时间和备注 | Light / 360vp | `/tmp/leafmate-ui-v3/journal.jpg` | PASS |
| CAP-07 | 花园完成态 | Dark / 360vp | `/tmp/leafmate-final-dark/final.jpg` | PASS |
| CAP-08 | 窄屏首屏与固定底栏 | Light / 320vp | `/tmp/leafmate-final-320/final.jpg` | PASS with scroll |

## 覆盖结论

整体覆盖为 Partial。Previewer 已覆盖核心正常、空、禁用、深色、窄屏和完整交互状态。读取/写入错误视觉、150% 字号、横屏、平板、读屏焦点、系统减少动态联动及真机拖动手感尚无证据；无权限状态不适用，因为本轮没有权限入口。
