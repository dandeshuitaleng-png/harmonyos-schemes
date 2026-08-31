# 候补预约 · 设计系统

> 由 UI UX Pro Max 根据 query `local standby booking draft not-real-calendar` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名（丢弃 Web 主色若冲突）
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 GSAP 与 Google Fonts import
- [x] 反模式与 AGENTS.md 禁止事项对齐

---

## Design System: 候补预约

### Pattern
- **Name:** Real-Time / Operations Landing
- **Conversion Focus:** For ops/security/iot products. Demo or sandbox link. Trust signals.
- **CTA Placement:** Primary CTA in nav + After metrics
- **Color Strategy:** Dark or neutral. Status colors (green/amber/red). Data-dense but scannable.
- **Sections:** 1. Hero (product + live preview or status), 2. Key metrics/indicators, 3. How it works, 4. CTA (Start trial / Contact)

### Style
- **Name:** Minimalism & Swiss Style
- **Mode Support:** Light ✓ Full | Dark ✓ Full
- **Keywords:** Clean, simple, spacious, functional, white space, high contrast, geometric, sans-serif, grid-based, essential
- **Best For:** Enterprise apps, dashboards, documentation sites, SaaS platforms, professional tools
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ WCAG AAA

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#0284C7` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#0EA5E9` | `--color-secondary` |
| Accent/CTA | `#059669` | `--color-accent` |
| Background | `#F0F9FF` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Muted | `#EFF7FB` | `--color-muted` |
| Border | `#E0F0F8` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#0284C7` | `--color-ring` |

*Notes: Calendar blue + available green*

### Typography
- **Heading:** Cinzel
- **Body:** Josefin Sans
- **Mood:** real estate, luxury, elegant, sophisticated, property, premium
- **Best For:** Real estate, luxury properties, architecture, interior design
- **Google Fonts:** https://fonts.googleapis.com/css2?family=Cinzel:wght@400;500;600;700&family=Josefin+Sans:wght@300;400;500;600;700&display=swap
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@400;500;600;700&family=Josefin+Sans:wght@300;400;500;600;700&display=swap');
```

### Key Effects
Subtle hover (200-250ms), smooth transitions, sharp shadows if any, clear type hierarchy, fast loading

### Avoid (Anti-patterns)
- No map
- Hidden reviews

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
