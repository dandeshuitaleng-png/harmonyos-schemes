# 近地天体探索 · 设计系统

> 由 UI UX Pro Max 根据 query `offline NEO learning cards not-live-orbit` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名（丢弃 Web 主色若冲突）
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 GSAP 与 Google Fonts import
- [x] 反模式与 AGENTS.md 禁止事项对齐

---

## Design System: 近地天体探索

### Pattern
- **Name:** Webinar Registration
- **Conversion Focus:** Limited seats logic. 'Live' indicator. Auto-fill timezone.
- **CTA Placement:** Hero (Right side form) + Bottom anchor
- **Color Strategy:** Urgency: Red/Orange. Professional: Blue/Navy. Form: High contrast white.
- **Sections:** 1. Hero (Topic + Timer + Form), 2. What you'll learn, 3. Speaker Bio, 4. Urgency/Bonuses, 5. Form (again)

### Style
- **Name:** Vibrant & Block-based
- **Mode Support:** Light ✓ Full | Dark ✓ Full
- **Keywords:** Bold, energetic, playful, block layout, geometric shapes, high color contrast, duotone, modern, energetic
- **Best For:** Startups, creative agencies, gaming, social media, youth-focused, entertainment, consumer
- **Performance:** ⚡ Good | **Accessibility:** ◐ Ensure WCAG

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#2563EB` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#F59E0B` | `--color-secondary` |
| Accent/CTA | `#EC4899` | `--color-accent` |
| Background | `#EFF6FF` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Muted | `#F1F5FD` | `--color-muted` |
| Border | `#E4ECFC` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#2563EB` | `--color-ring` |

*Notes: Learning blue + play yellow + fun pink*

### Typography
- **Heading:** Space Grotesk
- **Body:** Space Grotesk
- **Mood:** neo brutalism, pop art, loud, bold, heavy, stickers, mechanical, high contrast, cream, gen-z
- **Best For:** Creative tools, Gen-Z marketing, e-commerce for youth culture, content portfolios, collage-style apps
- **Google Fonts:** https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@700&display=swap
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@700&display=swap');
```

### Key Effects
Large sections (48px+ gaps), animated patterns, bold hover (color shift), scroll-snap, large type (32px+), 200-300ms

### Avoid (Anti-patterns)
- Flat design without depth
- Text-heavy pages

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
