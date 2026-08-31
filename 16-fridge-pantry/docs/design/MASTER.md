# 食材管家 · 设计系统

> 由 UI UX Pro Max 根据 query `local pantry expiry notes not-food-safety-advice` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名（丢弃 Web 主色若冲突）
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 GSAP 与 Google Fonts import
- [x] 反模式与 AGENTS.md 禁止事项对齐

---

## Design System: 食材管家

### Pattern
- **Name:** Marketplace / Directory
- **Conversion Focus:** Search bar is the CTA. Reduce friction to search. Popular searches suggestions.
- **CTA Placement:** Hero Search Bar + Navbar 'List your item'
- **Color Strategy:** Search: High contrast. Categories: Visual icons. Trust: Blue/Green.
- **Sections:** 1. Hero (Search focused), 2. Categories, 3. Featured Listings, 4. Trust/Safety, 5. CTA (Become a host/seller)

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
- **Heading:** Playfair Display SC
- **Body:** Karla
- **Mood:** restaurant, menu, culinary, elegant, foodie, hospitality
- **Best For:** Restaurants, cafes, food blogs, culinary, hospitality
- **Google Fonts:** https://fonts.googleapis.com/css2?family=Karla:wght@300;400;500;600;700&family=Playfair+Display+SC:wght@400;700&display=swap
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=Karla:wght@300;400;500;600;700&family=Playfair+Display+SC:wght@400;700&display=swap');
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

类型 26fp、正文允许换行、透明按钮最小高度 48vp。不把 UUPM 的 Web 字体/GSAP/报警红主色直接进工程。Visual 无截图则 BLOCKED。
