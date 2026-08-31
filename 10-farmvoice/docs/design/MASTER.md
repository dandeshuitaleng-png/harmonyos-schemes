# 农事口述簿 · 设计系统

> 由 UI UX Pro Max 根据 query `farm voice notes local-first not-agri-platform` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名（丢弃 Web 主色若冲突）
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 GSAP 与 Google Fonts import
- [x] 反模式与 AGENTS.md 禁止事项对齐

---

## Design System: 农事口述簿

### Pattern
- **Name:** App Store Style Landing
- **Conversion Focus:** Show real screenshots. Include ratings (4.5+ stars). QR code for mobile. Platform-specific CTAs.
- **CTA Placement:** Download buttons prominent (App Store + Play Store) throughout
- **Color Strategy:** Dark/light matching app store feel. Star ratings in gold. Screenshots with device frames.
- **Sections:** 1. Hero with device mockup, 2. Screenshots carousel, 3. Features with icons, 4. Reviews/ratings, 5. Download CTAs

### Style
- **Name:** Organic Biophilic
- **Mode Support:** Light ✓ Full | Dark ✓ Full
- **Keywords:** Nature, organic shapes, green, sustainable, rounded, flowing, wellness, earthy, natural textures
- **Best For:** Wellness apps, sustainability brands, eco products, health apps, meditation, organic food brands
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ WCAG AA

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#DC2626` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#EF4444` | `--color-secondary` |
| Accent/CTA | `#2563EB` | `--color-accent` |
| Background | `#FFFFFF` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Muted | `#FCF1F1` | `--color-muted` |
| Border | `#FAE4E4` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#DC2626` | `--color-ring` |

*Notes: Recording red + waveform blue*

### Typography
- **Heading:** Inter
- **Body:** Inter
- **Mood:** flat, clean, system, bold, geometric, cross-platform, icon, poster, minimal, functional, responsive
- **Best For:** Cross-platform apps, dashboards, system UI, onboarding, marketing pages, informational apps, icon-heavy interfaces
- **Google Fonts:** https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap');
```

### Key Effects
Rounded corners (16-24px), organic curves (border-radius variations), natural shadows, flowing SVG shapes

### Avoid (Anti-patterns)
- Generic design
- Ignored accessibility
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

类型 26fp、正文允许换行、透明按钮最小高度 48vp。不把 UUPM 的 Web 字体/GSAP/报警红主色直接进工程。Visual 无截图则 BLOCKED。
