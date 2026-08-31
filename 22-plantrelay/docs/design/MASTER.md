# 叶伴 · 设计系统

> 由 UI UX Pro Max 根据 query `local plant care notes not-diagnosis` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名（丢弃 Web 主色若冲突）
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 GSAP 与 Google Fonts import
- [x] 反模式与 AGENTS.md 禁止事项对齐

---

## Design System: 叶伴

### Pattern
- **Name:** Storytelling-Driven + Social Proof
- **CTA Placement:** Above fold
- **Sections:** Hero > Features > CTA

### Style
- **Name:** Organic Biophilic
- **Mode Support:** Light ✓ Full | Dark ✓ Full
- **Keywords:** Nature, organic shapes, green, sustainable, rounded, flowing, wellness, earthy, natural textures
- **Best For:** Wellness apps, sustainability brands, eco products, health apps, meditation, organic food brands
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ WCAG AA

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#15803D` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#059669` | `--color-secondary` |
| Accent/CTA | `#D97706` | `--color-accent` |
| Background | `#F0FDF4` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Muted | `#F0F7F3` | `--color-muted` |
| Border | `#E2EFE7` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#15803D` | `--color-ring` |

*Notes: Nature green + sun yellow*

### Typography
- **Heading:** Inter
- **Body:** Inter
- **Mood:** Warm + Humanist + Natural

### Key Effects
Rounded corners (16-24px), organic curves (border-radius variations), natural shadows, flowing SVG shapes

### Avoid (Anti-patterns)
- Inconsistent styling
- Poor contrast ratios

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
