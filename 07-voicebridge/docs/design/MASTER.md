# 语桥求职 · 设计系统

> 由 UI UX Pro Max 根据 query `accessible job notes local-first not-recruiting-platform` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名（丢弃 Web 主色若冲突）
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 GSAP 与 Google Fonts import
- [x] 反模式与 AGENTS.md 禁止事项对齐

---

## Design System: 语桥求职

### Pattern
- **Name:** App Store Style Landing
- **Conversion Focus:** Show real screenshots. Include ratings (4.5+ stars). QR code for mobile. Platform-specific CTAs.
- **CTA Placement:** Download buttons prominent (App Store + Play Store) throughout
- **Color Strategy:** Dark/light matching app store feel. Star ratings in gold. Screenshots with device frames.
- **Sections:** 1. Hero with device mockup, 2. Screenshots carousel, 3. Features with icons, 4. Reviews/ratings, 5. Download CTAs

### Style
- **Name:** Flat Design Mobile (Touch-First)
- **Mode Support:** Light ✓ Full | Dark ◐ Partial (Dark mode via color swap only)
- **Keywords:** flat, 2D, no shadow, color blocking, geometric, bold, poster, icon, touch-first, minimal, clean, tailored, cross-platform
- **Best For:** Cross-platform apps (iOS+Android parity), information-dense dashboards, system UI, brand illustration, onboarding flows, marketing pages, icon design
- **Performance:** ⚡ Excellent (no GPU effects) | **Accessibility:** ✓ WCAG AA (large bold type helps)

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#EA580C` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#F97316` | `--color-secondary` |
| Accent/CTA | `#2563EB` | `--color-accent` |
| Background | `#FFF7ED` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Muted | `#FDF4F0` | `--color-muted` |
| Border | `#FCEAE1` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#EA580C` | `--color-ring` |

*Notes: Event orange + map blue*

### Typography
- **Heading:** Atkinson Hyperlegible
- **Body:** Atkinson Hyperlegible
- **Mood:** accessible, readable, inclusive, WCAG, dyslexia-friendly, clear
- **Best For:** Accessibility-critical sites, government, healthcare, inclusive design
- **Google Fonts:** https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:wght@400;700&display=swap
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:wght@400;700&display=swap');
```

### Key Effects
Immediate press feedback (scale 0.97, no delay), color section blocking (full-width contrasting View), zero elevation/shadow, solid icon containers (colored squares/circles), geometric low-opacity shape overlays, bottom tabs solid fill (no floating)

### Avoid (Anti-patterns)
- Outdated forms
- Hidden filters

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard nav
- [ ] prefers-reduced-motion respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px

## 鸿蒙落地（2026-08-31）

类型 26fp、正文允许换行、透明按钮最小高度 48vp。不把 UUPM 的 Web 字体/GSAP/报警红主色直接进工程。Visual 无截图则 BLOCKED。
