# 口语情境练习 · 设计系统

> 由 UI UX Pro Max 根据 query `offline speaking prompts not-AI-service` 生成。 颜色/字体/动效必须再按 `.cursor/skills/harmonyos-scheme-ui/arkui-mapping.md` 映射到 ArkUI 资源， 不得把 CSS、GSAP 或 Web 字体直接进工程。

落地检查：
- [x] hex 已写入现有 color.json 语义名（丢弃 Web 主色若冲突）
- [x] 字体 HarmonyOS Sans / 16fp+
- [x] 已丢弃 GSAP 与 Google Fonts import
- [x] 反模式与 AGENTS.md 禁止事项对齐

---

## Design System: 口语情境练习

### Pattern
- **Name:** AI Personalization Landing
- **Conversion Focus:** 20%+ conversion with personalization. Requires analytics integration. Fallback for new users.
- **CTA Placement:** Context-aware placement based on user segment
- **Color Strategy:** Adaptive based on user data. A/B test color variations per segment.
- **Sections:** 1. Dynamic hero (personalized), 2. Relevant features, 3. Tailored testimonials, 4. Smart CTA

### Style
- **Name:** AI-Native UI
- **Mode Support:** Light ✓ Full | Dark ✓ Full
- **Keywords:** Chatbot, conversational, voice, assistant, agentic, ambient, minimal chrome, streaming text, AI interactions
- **Best For:** AI products, chatbots, voice assistants, copilots, AI-powered tools, conversational interfaces
- **Performance:** ⚡ Excellent | **Accessibility:** ✓ WCAG AA

### Colors
| Role | Hex | CSS Variable |
|------|-----|--------------|
| Primary | `#7C3AED` | `--color-primary` |
| On Primary | `#FFFFFF` | `--color-on-primary` |
| Secondary | `#6366F1` | `--color-secondary` |
| Accent/CTA | `#EC4899` | `--color-accent` |
| Background | `#FAF5FF` | `--color-background` |
| Foreground | `#0F172A` | `--color-foreground` |
| Muted | `#F7F3FD` | `--color-muted` |
| Border | `#EFE7FC` | `--color-border` |
| Destructive | `#DC2626` | `--color-destructive` |
| Ring | `#7C3AED` | `--color-ring` |

*Notes: AI purple + generation pink*

### Typography
- **Heading:** Space Grotesk
- **Body:** DM Sans
- **Mood:** tech, startup, modern, innovative, bold, futuristic
- **Best For:** Tech companies, startups, SaaS, developer tools, AI products
- **Google Fonts:** https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Space+Grotesk:wght@400;500;600;700&display=swap
- **CSS Import:**
```css
@import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&family=Space+Grotesk:wght@400;500;600;700&display=swap');
```

### Key Effects
Typing indicators (3-dot pulse), streaming text animations, pulse animations, context cards, smooth reveals

### Avoid (Anti-patterns)
- Complex shadows
- 3D effects

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
