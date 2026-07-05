# Astryx Design System — Reference

> Meta's design system CLI · 90+ components · agent-ready docs
> Package: [@astryxdesign/cli](https://www.npmjs.com/package/@astryxdesign/cli) · [github.com/facebook/astryx](https://github.com/facebook/astryx)
> Installed via: `npx astryx init --features agents`

---

## Setup (ครั้งเดียว)

ใน app entry (เช่น `main.tsx`) — **ต้องมี** ไม่งั้น components render unstyled:

```ts
import "@astryxdesign/core/reset.css";
import "@astryxdesign/core/astryx.css";
```

---

## Workflow — discover, don't guess

ก่อนเขียน UI ทำตามลำดับ:

1. **`astryx build "<idea>"`** — START HERE
   → ได้ kit (closest [page] + [block]s + [component]s)
   → ไม่ใส่ arg = full playbook

2. **`astryx template <name> [--skeleton]`**
   → scaffold [page]/[block]s ที่ build แนะนำ
   → หรือ study layout ของ template

3. **`astryx component <Name>`**
   → props + examples ต่อ component ที่ใช้

---

## Rules (บังคับ)

- ❌ **ไม่ใช้ `<div>`** — components ทำ layout/spacing เอง
  - Full page → `AppShell`
  - Sidebar nav → `SideNav`
- 🔲 **Frame first** — เลือก shell (`AppShell` / `Layout+LayoutPanel`) + budget regions in px **ก่อน**เขียน content
  - ดู `astryx docs layout`
- 📊 **Dense data = rows** — `Table`, `List/Item` edge-to-edge
  - ห้าม Card-wrapped list items
  - Card = dashboard widgets, galleries, settings groups เท่านั้น
- 🔴 **Status** → `StatusDot`/`Token`
  - `Badge` เฉพาะ counts + enumerated states (ห้าม decoration)
- 🎨 **Custom styling:** component props ก่อน → ถ้าไม่พอ style/className + tokens
  - `var(--color-*|--spacing-*|--radius-*)` เท่านั้น
  - ❌ ห้าม hex/px ตรง
  - ❌ ห้าม StyleX/Tailwind utility classes (ไม่มี compiler)
- 🪙 **Tokens ทุก value** — ดู `astryx docs tokens`
  - Brand/accent → `astryx theme` (ห้าม override `--color-*` ใน `:root`)

---

## CLI Commands

| Command | ทำอะไร |
|---|---|
| `astryx build "<idea>"` | START HERE — return kit |
| `astryx template <name>` | scaffold page/block |
| `astryx template --list` | list templates |
| `astryx component <Name>` | props + examples |
| `astryx component --list` | 90+ components by category |
| `astryx search "<query>"` | find component/hook/doc/template/block |
| `astryx docs <topic>` | color · elevation · icons · illustrations · layout · migration · motion · principles · shape · spacing · styling · theme · tokens · typography |
| `astryx swizzle <Name>` | eject component source (deep customization) |
| `astryx upgrade --apply` | รันหลัง `@astryxdesign/core` bump |

---

## ทำงานร่วมกับ Skills ทีม

- **DS ของทีม (design-builder chain)** — สร้าง `design.md` + `components.json` + `tokens.css` แบบ generic
- **Astryx** — implementation-ready components สำหรับ React apps

**Use case:**
- Design ใน Figma → export tokens ด้วย `/design-export-dtcg` → import เป็น Astryx theme
- Prototype UI ด้วย Astryx components → validate ด้วย `/audit` + `/browser-testing-with-devtools`

---

## Update

```bash
npx @astryxdesign/cli upgrade --apply
```

รันหลังทุกครั้งที่ `@astryxdesign/core` bump version
