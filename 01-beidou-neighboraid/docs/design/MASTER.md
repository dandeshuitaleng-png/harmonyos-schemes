# 北斗邻援 · 设计系统

> 由 UI UX Pro Max 根据 query `offline emergency community drill SOS mutual-aid high-contrast trustworthy civic safety not-official-dispatch local-first` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 `color.json` 语义名（未把 UUPM 报警红当品牌主色）
- [x] 字体改为 HarmonyOS Sans / fp 档位（16fp 起，行高约 1.5）
- [x] 已丢弃 GSAP、Google Fonts import、社区论坛版式、成员照片与 Join CTA
- [x] 反模式与 AGENTS.md 对齐：不伪官方报警；状态用文字；清除需确认

---

## Design System: 北斗邻援

### Pattern
- **Name:** Community/Forum Landing
- **Conversion Focus:** Show active community (member count, posts today). Highlight benefits. Preview content. Easy onboarding.
- **CTA Placement:** Join button prominent + After member showcase
- **Color Strategy:** Warm, welcoming. Member photos add humanity. Topic badges in brand colors. Activity indicators green.
- **Sections:** 1. Hero (community value prop), 2. Popular topics/categories, 3. Active members showcase, 4. Join CTA

### Style
- **Name:** Accessible & Ethical
- **Mode Support:** Light ✓ Full | Dark ✓ Full
- **Keywords:** High contrast, large text (16px+), keyboard navigation, screen reader friendly, WCAG compliant, focus state, semantic
- **Best For:** Government, healthcare, education, inclusive products, large audience, legal compliance, public
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ WCAG AAA

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#DC2626` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#EF4444` | `--color-secondary` |
| Accent/CTA | `#2563EB` | `--color-accent` |
| Background | `#FFF1F2` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Muted | `#FCF1F1` | `--color-muted` |
| Border | `#FAE4E4` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#DC2626` | `--color-ring` |

*Notes: Alert red + safety blue*

### Typography
- **Heading:** Playfair Display
- **Body:** Source Serif 4
- **Mood:** monochrome, editorial, austere, typographic, pocket manifesto, luxury, high contrast, brutalist mobile
- **Best For:** Luxury fashion mobile apps, editorial publications, digital exhibitions, portfolio apps, high-contrast e-reader aesthetics
- **Google Fonts:** https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&family=Playfair+Display:ital,wght@0,400;0,700;0,900;1,400|Source+Serif+4:ital,wght@0,300;0,400;0,600;1,300
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500&family=Playfair+Display:ital,wght@0,400;0,700;0,900;1,400&family=Source+Serif+4:ital,wght@0,300;0,400;0,600;1,300&display=swap');
```

### Key Effects
Clear focus rings (3-4px), ARIA labels, skip links, responsive design, reduced motion, 44x44px touch targets

### Avoid (Anti-patterns)
- Complex shadows
- 3D effects
- Color-only indicators

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard nav
- [ ] prefers-reduced-motion respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px

## 鸿蒙落地（2026-08-31）

UUPM 给出的「Community/Forum Landing + Alert red primary + Playfair/Source Serif」**不采用**。本应用是离线演练记录，不是社区运营页，也不得做成 110/119/120 官方报警皮肤。

| 维度 | 采用 | 丢弃 |
| --- | --- | --- |
| 风格 | Accessible & Ethical：高对比、16fp+、状态不只靠颜色、48vp 触控、无 emoji 图标 | 社区成员数、帖子预览、Join CTA、成员照片 |
| 主操作色 | 沿用 civic 青灰 `action_primary` `#005E7A` / 深色 `#55C8E8` | `#DC2626` 作为全局 Primary（易被当成官方警情） |
| 紧急入口 | 警示表面 `surface_warning` + 文字「打开系统电话」；不由本应用拨号 | 红色大按钮写「报警」 |
| 字体 | HarmonyOS Sans；标题 24–26fp，正文 16fp 行高 24，说明 14fp 行高 22 | Playfair Display、Source Serif 4、任何 `@import` 字体 |
| 动效 | 系统按下态；无装饰动画 | GSAP、hover 菜单 |
| 破坏操作 | 清除记录需二次确认，按钮文案写明不可撤销 | 一点即删 |

资源名仍用工程已有 token，新增 `border_subtle`、`text_danger`。记录卡改用 `surface_card`，不再用 `surface_success` 把所有事件涂成「健康/成功」。
