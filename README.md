# UXUI library skill

Skills และคู่มือสำหรับทีม Designer ใช้ Claude Code ร่วมกับ Figma

## 📦 วิธี Setup (ต้องทำก่อนใช้ skill)

ต้องมี 4 อย่างบนเครื่อง:

1. **Node.js** — ดาวน์โหลด LTS จาก [nodejs.org](https://nodejs.org)
2. **Git** — Terminal รัน `xcode-select --install`
3. **Claude Code Desktop** — ดาวน์โหลดจาก [claude.ai/download](https://claude.ai/download)
4. **Figma MCP** — แก้ไฟล์ `claude_desktop_config.json` ใส่ Figma token

> ดูคู่มือ step-by-step → **[ONBOARDING.md](ONBOARDING.md)**

**วิธีง่ายสุด:** ติดตั้ง Claude Code + plugin (ขั้น 2 ข้างล่าง) แล้วพิมพ์ `/check-setup` ในChat → จะ auto-detect และ guide ที่เหลือให้

---

## 🚀 วิธีติดตั้ง Skill

เลือก **1 วิธี** ก็พอ

### วิธีที่ 1 — npx (แนะนำ)

```
npx skills add sittipons-ike/uxui-skill-library
```

### วิธีที่ 2 — Claude Code Plugin (ใช้เมื่อ npx ไม่ได้)

ถ้า network บล็อก npm registry — ใช้วิธีนี้แทน:

```
claude plugin marketplace add https://github.com/sittipons-ike/uxui-skill-library
claude plugin install uxui-skills
```

### หลังติดตั้งเสร็จ

พิมพ์ใน Claude Code:
```
/check-setup
```

→ จะเช็ก setup ครบไหม + แนะนำ skill แรกให้ลอง

## Skills ที่มี

**พร้อมใช้ทันที**

| Skill | หน้าที่ |
|---|---|
| `check-setup` | Guide ทีมตอน install ครั้งแรก — เช็ก prerequisites + แนะนำ skill แรก |
| `audit-ui` | ตรวจ Figma DS compliance ก่อน handoff |
| `ux-skill` | วาง User Flow + Information Architecture |
| `ui-skill` | Map component + design token จาก Blueprint |
| `ux-writing` | เขียน / rewrite microcopy บน UI |
| `masterprompt` | แปลง idea คร่าวๆ เป็น structured prompt |
| `notion-planning` | วางแผนงานลง Notion |
| `prd` | สร้าง Product Requirements Document |
| `audit` | ตรวจ interface quality ด้าน accessibility, performance, responsive |

**Design System Suite (3-file split architecture)**

| Skill | หน้าที่ |
|---|---|
| `design-builder` v6 | สร้าง `design.md` — dual-path (zero / client-given palette + mood + refs) → base tokens + WCAG validation + Known Gaps log |
| `design-component-builder` | สร้าง `components.md` — atomic library (atom/molecule/organism) อ้าง tokens |
| `design-icon-builder` | populate iconography layer + ดึง SVG จริงจาก Phosphor/Tabler/Heroicons ฯลฯ |
| `design-ui-builder` | สร้าง `ui.md` — UI compositions (page/pattern/section/flow) อ้าง components |
| `design-md-audit` | audit design system ทั้ง split + monolithic + เช็ก cross-file refs |
| `design-styleguide` | render HTML/Figma style guide จาก design.md+components.md+ui.md |
| `design-remix` | mix design จาก brand references (Linear typography + Notion spacing ฯลฯ) |

**ต้อง setup ก่อนใช้** ⚠️

| Skill | ต้องการ |
|---|---|
| `email-summarizer` | Gmail MCP + (optional) Lark webhook |
| `jira-tracker` | Atlassian MCP + Lark webhook + config Jira project |

> skill ที่มี ⚠️ จะแสดง checklist setup ให้กรอกก่อนทุกครั้งที่รัน

**ตัวเสริม (ติดตั้งแยก)**

animate, polish, colorize, critique, audit, adapt, arrange, bolder, clarify, distill, delight, extract, frontend-design, harden, normalize, onboard, optimize, overdrive, quieter, teach-impeccable, typeset

ติดตั้งด้วย:
```
npx skills add pbakaus/impeccable
```

## อัปเดต Skills

รันคำสั่งเดิมจากวิธีที่ติดตั้งซ้ำ:

**ถ้าใช้ npx:**
```
npx skills add sittipons-ike/uxui-skill-library
```

**ถ้าใช้ Plugin:**
```
claude plugin marketplace update
```
