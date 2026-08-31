# 潮汐守望 · 设计系统

> 由 UI UX Pro Max 根据 query `offline coastal observation not-forecast local draft high-contrast` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 Web 字体与 GSAP
- [x] 不把草稿写成预报或公告

---

## Design System: 潮汐守望

### Pattern
- **Name:** Hero + Features + CTA
- **Conversion Focus:** Deep CTA placement. Use contrasting color (at least 7:1 contrast ratio). Sticky navbar CTA.
- **CTA Placement:** Hero (sticky) + Bottom
- **Color Strategy:** Hero: Brand primary or vibrant. Features: Card bg #FAFAFA. CTA: Contrasting accent color
- **Sections:** 1. Hero with headline/image, 2. Value prop, 3. Key features (3-5), 4. CTA section, 5. Footer

### Style
- **Name:** Accessible & Ethical
- **Mode Support:** Light ✓ Full | Dark ✓ Full
- **Keywords:** High contrast, large text (16px+), keyboard navigation, screen reader friendly, WCAG compliant, focus state, semantic
- **Best For:** Government, healthcare, education, inclusive products, large audience, legal compliance, public
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ WCAG AAA

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#0F172A` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#334155` | `--color-secondary` |
| Accent/CTA | `#0369A1` | `--color-accent` |
| Background | `#F8FAFC` | `--color-background` |
| Foreground | `#020617` | `--color-foreground` |
| Muted | `#E8ECF1` | `--color-muted` |
| Border | `#E2E8F0` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#0F172A` | `--color-ring` |

*Notes: High contrast navy + blue*

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
- Small text
- Complex navigation
- AI purple/pink gradients

### Pre-Delivery Checklist
- [ ] No emojis as icons (use SVG: Heroicons/Lucide)
- [ ] cursor-pointer on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Light mode: text contrast 4.5:1 minimum
- [ ] Focus states visible for keyboard nav
- [ ] prefers-reduced-motion respected
- [ ] Responsive: 375px, 768px, 1024px, 1440px

## 鸿蒙落地（2026-08-31）

丢弃实时预报/地图/相机视觉。主色保持沿海青 `action_primary`。草稿字段分行（来源、采集、有效至、待审核、仅本机不公开）。清除需二次确认。不是公共公告。
