# 可信任务贴 · 设计系统

> 由 UI UX Pro Max 根据 query `local task proof notes not-surveillance` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名（丢弃 Web 主色若冲突）
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 GSAP 与 Google Fonts import
- [x] 反模式与 AGENTS.md 禁止事项对齐

---

## Design System: 可信任务贴

### Pattern
- **Name:** Hero + Testimonials + CTA
- **Conversion Focus:** Social proof before CTA. Use 3-5 testimonials. Include photo + name + role. CTA after social proof.
- **CTA Placement:** Hero (sticky) + Post-testimonials
- **Color Strategy:** Hero: Brand color. Testimonials: Light bg #F5F5F5. Quotes: Italic, muted color #666. CTA: Vibrant
- **Sections:** 1. Hero, 2. Problem statement, 3. Solution overview, 4. Testimonials carousel, 5. CTA

### Style
- **Name:** Micro-interactions
- **Mode Support:** Light ✓ Full | Dark ✓ Full
- **Keywords:** Small animations, gesture-based, tactile feedback, subtle animations, contextual interactions, responsive
- **Best For:** Mobile apps, touchscreen UIs, productivity tools, user-friendly, consumer apps, interactive components
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ Good

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
- **Heading:** Inter
- **Body:** Inter
- **Mood:** Clean + Efficient typography

### Key Effects
Small hover (50-100ms), loading spinners, success/error state anim, gesture-triggered (swipe/pinch), haptic

### Avoid (Anti-patterns)
- Complex onboarding
- Slow performance

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
