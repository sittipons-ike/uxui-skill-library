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
| `design-component-builder` v5 | สร้าง `components.json` (DTCG-aligned manifest) + `tokens.css` 2-tier + `components/<name>.html` + `components.html` showcase. Legacy `--format=md` ยังใช้ได้ใน v5–v6 |
| `design-icon-builder` | populate iconography layer + ดึง SVG จริงจาก Phosphor/Tabler/Heroicons ฯลฯ |
| `design-ui-builder` v4 | สร้าง `ui.json` + `patterns.json` (NEW) + `pages/<name>.html` (self-contained) + `patterns/<name>.html` (NEW — reusable shells with slot contracts) |
| `design-md-audit` v6.1 | audit DS (JSON Schema + ref resolver + diff-merge + HTML coverage + hybrid input) + **`--migrate-to-json`** flag (convert legacy MD spec → v6 JSON manifests with auto-extracted patterns) |
| `design-styleguide` v3 | aggregator mode default (อ่าน components/*.html → single styleguide.html with TOC + theme toggle) หรือ `--regenerate` ใช้ legacy MD mode |
| `design-remix` | mix design จาก brand references (Linear typography + Notion spacing ฯลฯ) |
| `design-export-dtcg` v1 | export DS tokens → W3C DTCG `tokens.json` + Style Dictionary config (cross-platform: iOS/Android/Flutter/web/Tailwind) |
| `design-push-figma-tokens` v1 | sync DS tokens (design.md / tokens.json) → Figma Variable Collection (light/dark modes, idempotent, alias-aware) |

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

## 🚧 Phase 5 in progress — JSON Manifest Migration

DS spec layer กำลังย้ายจาก `.md` → JSON manifests (DTCG-aligned) เพื่อลด token cost + drift + เพิ่ม scalability
- `design.md` **อยู่เหมือนเดิม** (designer-facing, YAML-in-MD)
- `components.json` + `ui.json` + `patterns.json` ใหม่ — แทน `.md` spec
- HTML files (atoms, pages) **ไม่เปลี่ยน**

อ่าน [docs/architecture-v5.md](docs/architecture-v5.md) สำหรับรายละเอียด, [schemas/ref-resolver.md](schemas/ref-resolver.md) สำหรับ ref syntax

**Status:**
- ✅ Phase 1A + 1B: schemas + docs
- ✅ Phase 2A: `design-component-builder v5` (emits `components.json`)
- ✅ Phase 2B: `design-ui-builder v4` (emits `ui.json` + `patterns.json`)
- ✅ Phase 2C: `design-builder v6.1` (doc-only pipeline refs)
- ✅ Phase 2D: `design-icon-builder v2.2` (doc-only)
- ✅ Phase 3B: `design-styleguide v3.1` (reads JSON, falls back MD)
- ✅ Phase 3A: `design-md-audit v6.0` (JSON Schema validation + hybrid mode + ref resolver)
- ✅ Phase 4: `design-md-audit v6.1` (`--migrate-to-json` flag — convert legacy MD → v6 JSON with pattern auto-extraction)
- ✅ Phase 5: E2E verify ([docs/VERIFICATION-v6.md](docs/VERIFICATION-v6.md)) — all schemas + examples PASS after fixes
- ✅ Phase 6: `design-export-dtcg v1.0` — DTCG `tokens.json` + Style Dictionary config (cross-platform: web/iOS/Android/Flutter/Tailwind)

**🎉 DS v6 — JSON Manifest Migration COMPLETE**

---

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
