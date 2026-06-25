# UXUI Skill Library

29 skills + Team Rules สำหรับทีม Designer ใช้ Claude Code ร่วมกับ Figma

## วิธี Setup

ต้องมี 4 อย่างบนเครื่อง:

1. **Node.js** — ดาวน์โหลด LTS จาก [nodejs.org](https://nodejs.org)
2. **Git** — Terminal รัน `xcode-select --install`
3. **Claude Code Desktop** — ดาวน์โหลดจาก [claude.ai/download](https://claude.ai/download)
4. **Figma MCP** — แก้ไฟล์ `claude_desktop_config.json` ใส่ Figma token

> ดูคู่มือ step-by-step → **[ONBOARDING.md](ONBOARDING.md)**

**วิธีง่ายสุด:** ติดตั้ง Claude Code แล้วพิมพ์ `/check-setup` → จะ auto-detect และ guide ที่เหลือให้

---

## วิธีติดตั้ง

เลือก **1 วิธี** ก็พอ

### วิธีที่ 1 — npx (แนะนำ)

```
npx skills add sittipons-ike/uxui-skill-library
```

### วิธีที่ 2 — Claude Code Plugin (ใช้เมื่อ npx ไม่ได้)

```
claude plugin marketplace add https://github.com/sittipons-ike/uxui-skill-library
claude plugin install uxui-skills
```

### หลังติดตั้งเสร็จ

```
/check-setup
```

---

## ⚡ Team Rules — กฎกลางทีม (สำคัญ)

หลัง install skills เสร็จ ติดตั้ง **Team Rules** ด้วย — กฎกลาง 13 ข้อที่ Claude apply ทุก session ทุก project

| Layer | Rules |
|---|---|
| 🔒 Security | 1-6 (secret handling, scan ก่อน commit, rotation, incident response) |
| 🎯 Engineering | 7-11 (NO MAGIC, VERIFY BEFORE DONE, DISSENT, SCOPE DRIFT, R0/R1/R2) |
| 📚 Persistence | 12-13 (per-project `MEMORY.md` + `spec.md` — กันลืม / กัน /clear) |

### ติดตั้ง (ทำครั้งเดียว)

```bash
git clone https://github.com/sittipons-ike/uxui-skill-library.git
cd uxui-skill-library
bash team-rules/install-team-rules.sh
```

Script จะ:
1. Backup `~/.claude/CLAUDE.md` เดิม (ถ้ามี)
2. Symlink `~/.claude/team-rules.md` → `<repo>/team-rules/CLAUDE.md`
3. ใส่ `@~/.claude/team-rules.md` ใน `~/.claude/CLAUDE.md` (idempotent — รันซ้ำได้)

### Update rules ในอนาคต

```bash
cd uxui-skill-library && git pull    # symlink ชี้ของจริง — auto sync ทุกเครื่อง
```

ดูเนื้อหา rules เต็ม → [team-rules/CLAUDE.md](team-rules/CLAUDE.md)

> **Personal customization** — เพิ่ม section ของตัวเองท้าย `~/.claude/CLAUDE.md` ได้ — survive git pull (อยู่คนละไฟล์)

---

## Skills ที่มี (29 skills)

### UX / UI Design

| Skill | หน้าที่ |
|---|---|
| `check-setup` | เช็ก prerequisites + แนะนำ skill แรกที่ควรลอง |
| `ux-strategist` | วาง User Flow + Information Architecture |
| `ui-implementation-specialist` | Map component + design token จาก Blueprint |
| `ux-writer` | เขียน / rewrite microcopy บน UI |
| `modal-writer` | เขียน/review Thai modal copy (Title + Body + CTAs) สำหรับ Desktop web — 6 modal types, 12 forbidden patterns auto-check, Double/Single layout rules |
| `masterprompt` | แปลง idea คร่าวๆ เป็น structured prompt |
| `figma-audit-ui` | ตรวจ Figma DS compliance ก่อน handoff |
| `audit` | ตรวจ interface quality ด้าน accessibility, performance, responsive |
| `user-personas` | สร้าง User Persona จาก research data |

### Product & Planning

| Skill | หน้าที่ |
|---|---|
| `prd` | สร้าง Product Requirements Document (3 targets: stakeholder / dev / AI agent) |
| `notion-planning` | วางแผนงานลง Notion |
| `interview-me` | ดึง intent ที่แท้จริงออกมาก่อนเริ่ม build — ถามทีละคำถามจนมั่นใจ ~95% |
| `spec-driven-development` | เขียน spec ก่อน code — 4-phase gated workflow |
| `shipping-and-launch` | เตรียม launch checklist + go-live workflow |

### Engineering

| Skill | หน้าที่ |
|---|---|
| `frontend-ui-engineering` | Front-end best practices: component patterns, performance, accessibility |
| `browser-testing-with-devtools` | ทดสอบ UI ด้วย DevTools — layout, network, console, a11y |

### Design System Suite

| Skill | หน้าที่ |
|---|---|
| `design-builder` v6 | สร้าง `design.md` — dual-path (zero / client-given) → base tokens + WCAG validation |
| `design-component-builder` v5 | สร้าง `components.json` (DTCG) + `tokens.css` + `components/<name>.html` |
| `design-icon-builder` | populate iconography layer + ดึง SVG จาก Phosphor/Tabler/Heroicons ฯลฯ |
| `design-ui-builder` v5 | สร้าง `ui.json` + `patterns.json` + `pages/<name>.html` (dual-mode: iframe / `--render=inline`) |
| `design-md-audit` v6.1 | audit DS + `--migrate-to-json` flag (convert legacy MD → v6 JSON) |
| `design-styleguide` v3 | aggregator mode: อ่าน `components/*.html` → single `styleguide.html` |
| `design-remix` | mix design จาก brand references |
| `design-export-dtcg` v1 | export → W3C DTCG `tokens.json` + Style Dictionary (iOS/Android/Flutter/web/Tailwind) |

### Figma Integration

| Skill | หน้าที่ |
|---|---|
| `figma-push-tokens` v1 | sync DS tokens → Figma Variable Collection (light/dark, idempotent) |
| `figma-push-components` v1 | push 5 atoms → Figma Component Sets + Variable bindings (variant × size × state) |
| `figma-rename-tokens` v1 | normalize existing Figma Variable names → canonical DS naming (non-destructive) |

### Integrations (ต้อง setup ก่อนใช้)

| Skill | ต้องการ |
|---|---|
| `email-summarizer` | Gmail MCP + (optional) Lark webhook |
| `jira-tracker` | Atlassian MCP + Lark webhook + Jira project config |

> skill กลุ่มนี้จะแสดง checklist setup ให้กรอกก่อนทุกครั้งที่รัน

---

### ตัวเสริม (ติดตั้งแยก)

`animate`, `polish`, `colorize`, `critique`, `adapt`, `arrange`, `bolder`, `clarify`, `distill`, `delight`, `extract`, `frontend-design`, `harden`, `normalize`, `onboard`, `optimize`, `overdrive`, `quieter`, `teach-impeccable`, `typeset`

```
npx skills add pbakaus/impeccable
```

---

## อัปเดต Skills

รันคำสั่งเดิมซ้ำ:

**npx:**
```
npx skills add sittipons-ike/uxui-skill-library
```

**Plugin:**
```
claude plugin marketplace update
```

---

## DS Architecture

3-file split architecture (JSON manifest, DTCG-aligned):

```
design-builder            →  design.md        (YAML tokens, designer-facing)
design-component-builder  →  components.json  (atoms/molecules/organisms)
design-icon-builder       →  design.md        (iconography block + ./icons/*.svg)
design-ui-builder         →  ui.json + patterns.json  (pages/flows/shells)
design-md-audit           →  validates all files + cross-file refs
design-styleguide         →  styleguide.html  (aggregator view)
```

Schemas: [schemas/](schemas/) — ref syntax: [schemas/ref-resolver.md](schemas/ref-resolver.md)  
Architecture doc: [docs/architecture-v5.md](docs/architecture-v5.md)

**DS v6 + Figma Integration — COMPLETE**

| Phase | Status |
|---|---|
| Phase 1–6: DS JSON Migration | ✅ |
| Phase 7A: `figma-push-tokens` v1 | ✅ |
| Phase 7C: `figma-rename-tokens` v1 | ✅ |
| Phase 8: `figma-push-components` v1 | ✅ |
| Phase 9A: `design-ui-builder` v5 dual-mode | ✅ |
| Phase 7B: Tokens Studio export (optional) | ⏳ |
| Phase 9B: Patterns push + Interactions auto-wire | ⏳ |
