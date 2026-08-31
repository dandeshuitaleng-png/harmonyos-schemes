# 静伴空间 · 离线安静练习

> Route: `pages/Index` · Status: Implemented · Updated: 2026-08-31

## Purpose
用户完成一段 2/5/10 分钟离线计时。主操作：开始安静练习。不得把结果显示为治疗或危机干预。次数可选保存本机。

## States
| State | Visible | Recovery |
| --- | --- | --- |
| Privacy | 同意 / 仅离线计时 | 返回可退出说明 |
| Ready | 时长「已选择」+ 开始 | 选时长 |
| Running / Paused | 倒计时 | 暂停、结束 |
| Confirm clear | 危险文案 | 返回键取消 |
| Error | 次数读写失败 | 重试 |

## A11y
徽章「非治疗」；触控 ≥48vp。Visual BLOCKED。
