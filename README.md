# UXUI Skill Library

29 skills + Team Rules สำหรับทีม Designer ใช้ Claude Code ร่วมกับ Figma

## ก่อนติดตั้งสกิล ต้องมี 4 อย่างนี้

ต้องมี 4 อย่างบนเครื่อง:

1. **Node.js** — ดาวน์โหลด LTS จาก [nodejs.org](https://nodejs.org)
2. **Git** — Terminal รัน `xcode-select --install`
3. **Claude Code Desktop** — ดาวน์โหลดจาก [claude.ai/download](https://claude.ai/download)
4. **Figma MCP** — แก้ไฟล์ `claude_desktop_config.json` ใส่ Figma token

> ดูคู่มือ step-by-step → **[ONBOARDING.md](ONBOARDING.md)**

**วิธีง่ายสุด:** ติดตั้ง Claude Code แล้วพิมพ์ `/check-setup` → จะ auto-detect และ guide ที่เหลือให้

---

## วิธีติดตั้ง

ทำตามลำดับ — **Rules ก่อน Skills**

> Rules = guardrails (กัน Claude เดา / leak secret / บอก "เสร็จ" ทั้งที่ยังไม่ verify)
> Skills = features (เสริมความสามารถเฉพาะทาง UX/UI/DS)
> ติด skills โดยไม่มี rules = AI ลุยเดาในงาน high-stakes

---

### ⚡ ขั้นที่ 1 (สำคัญสุด) — Team Rules

กฎกลาง 13 ข้อที่ Claude apply ทุก session ทุก project

| Layer | Rules |
|---|---|
| 🔒 Security | 1-6 (secret handling, scan ก่อน commit, rotation, incident response) |
| 🎯 Engineering | 7-11 (NO MAGIC, VERIFY BEFORE DONE, DISSENT, SCOPE DRIFT, R0/R1/R2) |
| 📚 Persistence | 12-13 (per-project `MEMORY.md` + `spec.md` — กันลืม / กัน /clear) |

**ติดตั้ง (ทำครั้งเดียว):**

> ⚠️ **คำสั่งด้านล่างต้องรันใน Terminal (ไม่ใช่ใน Claude Code chat)**
> เปิด Terminal: `Cmd + Space` → พิมพ์ `Terminal` → Enter

```bash
git clone https://github.com/sittipons-ike/uxui-skill-library.git
cd uxui-skill-library
bash team-rules/install-team-rules.sh
```

**ทางอ้อม (ไม่อยากเปิด Terminal)** — พิมพ์ใน Claude Code Desktop:
```
ติด Team Rules จาก https://github.com/sittipons-ike/uxui-skill-library ให้หน่อย
```
Claude จะ clone + ติดตั้งให้ (ต้อง approve permission ทุก step)

Script จะ:
1. Backup `~/.claude/CLAUDE.md` เดิม (ถ้ามี)
2. Symlink `~/.claude/team-rules.md` → `<repo>/team-rules/CLAUDE.md`
3. ใส่ `@~/.claude/team-rules.md` ใน `~/.claude/CLAUDE.md` (idempotent — รันซ้ำได้)

ดูเนื้อหา rules เต็ม → [team-rules/CLAUDE.md](team-rules/CLAUDE.md)

> **Personal customization** — เพิ่ม section ของตัวเองท้าย `~/.claude/CLAUDE.md` ได้ — survive git pull (อยู่คนละไฟล์)

---

### 🧩 ขั้นที่ 2 — Skills (29 ตัว)

หลัง rules ลงเรียบร้อย ค่อยติด skills

**แนะนำ — ลง global (`-g`): ลงครั้งเดียว ทุก project ใช้ได้**
```bash
npx skills add sittipons-ike/uxui-skill-library -g
```
> `-g` = ลงที่ user-level (`~/.claude/skills` → `~/.agents/`) → **ทุก project เห็นเลย ไม่ต้องลงซ้ำแต่ละ project**
> ✅ อัพเดตครั้งเดียว ทุก project ตามพร้อมกัน · ✅ ไม่มีปัญหา project ดึงเวอร์ชันเก่า
> ⚠️ ถ้าเคยลงแบบ project-local ไว้ (มี `.agents/` ในโฟลเดอร์ project) → **ลบ `.agents/` local ทิ้ง** ไม่งั้นมันทับ global (`~/.agents` ห้ามลบ — เป็น global source)

**ถ้าอยาก lock version เฉพาะบาง project** (เช่น production ที่ห้ามเปลี่ยน) → ตัด `-g` ออก (ลงเป็น project-local):
```bash
npx skills add sittipons-ike/uxui-skill-library      # ลงเฉพาะ project นี้
```

**ทางเลือก — Claude Code Plugin (ใช้เมื่อ npx ไม่ได้):**
```bash
claude plugin marketplace add https://github.com/sittipons-ike/uxui-skill-library
claude plugin install uxui-skills
```

---

### ✅ ขั้นที่ 3 — Verify

```
/check-setup
```

---

### 🔄 Update

**global (แนะนำ — ทุก project ตามพร้อมกัน):**
```bash
npx skills add sittipons-ike/uxui-skill-library -g
```
> ⚠️ npx **ไม่ auto-pull** จาก GitHub — ต้องรันคำสั่งนี้เอง**ทุกครั้ง**ที่ repo มีอัพเดต
> symlink `~/.claude/skills` ชี้ path เดิม → อัพ `~/.agents` เมื่อไหร่ เห็นใหม่ทันที ไม่ต้อง re-link

**รวบ rules + skills 1 command** (สำหรับคนที่ clone repo ไว้):
```bash
cd uxui-skill-library && bash update.sh
```
> ทำ: `git pull` (team rules) → `npx skills add -g` (skills) → hint `/check-setup`

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

## 🧰 ตัวเสริมแนะนำ (ติดตั้งแยก — ไม่ใช่ skill ของทีม)

7 ตัวที่ designer ใช้บ่อย — ติดตั้งจาก Claude Code Plugin Marketplace

### ตรง designer

| Skill | ทำอะไร | Install |
|---|---|---|
| **ui-ux-pro-max** | 161 palettes · 57 font pairs · 99 UX rules · CLI search design system | Plugin marketplace |
| **figma-usability-review** | Nielsen 10 heuristics บน Figma (ไทย) — annotation บน canvas | Anthropic skills |
| **accessibility-review** | a11y audit (WCAG 2.1/2.2 check) | design plugin |
| **design-handoff** | dev handoff workflow + token export | design plugin |
| **ux-copy** | UX copy review + microcopy patterns | design plugin |

### ส่งงาน / present

| Skill | ทำอะไร | Install |
|---|---|---|
| **pptx** | export slide deck (.pptx) | Anthropic skills |
| **pdf** | สร้าง / อ่าน / แก้ PDF | Anthropic skills |

### Visual design pack (impeccable)

`animate` · `polish` · `colorize` · `critique` · `adapt` · `arrange` · `bolder` · `clarify` · `distill` · `delight` · `extract` · `frontend-design` · `harden` · `normalize` · `onboard` · `optimize` · `overdrive` · `quieter` · `teach-impeccable` · `typeset`

```bash
npx skills add pbakaus/impeccable
```

> ตัวเสริมเหล่านี้ **ไม่ผ่าน team-rules update flow** — designer ต้องเลือก install เองตามใจ

---

## 📊 Pipeline Diagrams

| Diagram | สำหรับ |
|---|---|
| [docs/pipeline.html](docs/pipeline.html) | **Overview** — 29 skills · 7 phases · ทีมเลือก skill ตาม phase |
| [docs/data-flow.html](docs/data-flow.html) | **Data Flow** — skill ไหน output ไฟล์อะไร · skill ถัดไปอ่านอะไร |

---

## แต่ละสกิลรับอะไร ออกอะไร (input → output)

**Design System chain — เรียงลำดับการทำงาน:**

| # | สกิล | อ่าน (input) | ออก (output) |
|---|---|---|---|
| 1 | `design-builder` | brand info · `docs/brand/` · asset จริงใน `public/` | `design.md` (tokens + mood + **dials**) |
| 2 | `design-icon-builder` | `design.md` (mood) | `./icons/*.svg` + iconography block ใน `design.md` |
| 3 | `design-component-builder` | `design.md` + [`TASTE.md`](skills/design-builder/TASTE.md) gate | `components.json` + `tokens.css` + `components/*.html` |
| 4 | `design-ui-builder` | `design.md` + `components.json` + `TASTE.md` (recipes/dials) | `ui.json` + `patterns.json` + `pages/*.html` |
| — | `design-md-audit` | ทุกไฟล์ข้างบน | รายงาน validate (schema · refs · WCAG · naming) |
| — | `design-styleguide` | `components/*.html` + `pages/*.html` | `styleguide.html` (รวมดูหน้าเดียว) |
| — | `design-export-dtcg` | `design.md` + `components.json` | `tokens.json` (DTCG) + Style Dictionary (iOS/Android/Flutter/web) |
| — | `figma-push-tokens` / `-components` | `design.md` / `components.json` | Figma Variables / Component Sets |

**Pipeline (ทิศทางไหล — downward เท่านั้น):**
```
brand + PRD + assets
      ↓  design-builder                     → design.md  (+ dials, Mood Map มี ref)
      ↓  design-icon-builder                → icons/
      ↓  design-component-builder (+TASTE)  → components.json + tokens.css + HTML
      ↓  design-ui-builder (+TASTE recipes) → ui.json + patterns.json + pages/
      ↓  design-md-audit                    → verify ทั้งหมด
      ↓  design-styleguide / export-dtcg / figma-push → ส่งออก
```

**Taste layer (ขวางทุกสกิลที่ gen UI):** [`TASTE.md`](skills/design-builder/TASTE.md) — §6 gate + §7 recipes (~50 ท่า) + §8 dials · report deviation/DS-gap ให้ human approve → promote เข้า DS

**หลักคิด:** `design.md` = สี/ฟอนต์/token (หน้าตา) · `TASTE.md` = การจัดวาง/รสนิยม (กันโหล) · `docs/brand/` = ที่วางการตัดสินใจดีไซน์ (ไม่ใช่ PRD)

Full diagrams: [docs/pipeline.html](docs/pipeline.html) · [docs/data-flow.html](docs/data-flow.html) · [docs/design-system-structure.md](docs/design-system-structure.md)

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
