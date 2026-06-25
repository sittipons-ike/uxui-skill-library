# UXUI Agent Library

> Skill library + Team Rules สำหรับทีม Designer ใช้ Claude Code ร่วมกับ Figma
> Owner: design@7solutions.co.th

---

## Project นี้คืออะไร

Repository กลางของทีม UXUI สำหรับเก็บ:
- **`skills/`** — 29 skills ที่สอน Claude วิธีทำงาน UX/UI / DS / Figma
- **`team-rules/CLAUDE.md`** — กฎกลาง (Rules 1-13) ที่ทีมทุกคน apply
- **`team-rules/install-team-rules.sh`** — symlink + @import (git pull = update)
- **`schemas/`** — JSON Schema Draft-07 สำหรับ design system manifest
- **`examples/`** — ตัวอย่าง components.json / ui.json / patterns.json
- **`ONBOARDING.md`** — คู่มือติดตั้งทีละขั้น
- **`README.md`** — overview + install steps

> **หมายเหตุ:** เดิมไฟล์นี้เคยเป็น working rules — ตอนนี้ rules ทั้งหมดย้ายไป `team-rules/CLAUDE.md` (แชร์ทีมผ่าน symlink + @import)

---

## ติดตั้งครั้งแรก

### 1. Install skills (29 ตัว)
```bash
npx skills add sittipons-ike/uxui-skill-library
```
หรือ Claude plugin marketplace:
```bash
claude plugin marketplace add https://github.com/sittipons-ike/uxui-skill-library
claude plugin install uxui-skills
```

### 2. Install team rules (apply ทุก session)
```bash
git clone https://github.com/sittipons-ike/uxui-skill-library.git
cd uxui-skill-library
bash team-rules/install-team-rules.sh
```

### 3. Verify
```bash
/check-setup
```

---

## Skills ที่มี (29 skills — แบ่งหมวด)

### UX / UI Design
`check-setup` · `ux-strategist` · `ui-implementation-specialist` · `ux-writer` · `modal-writer` · `masterprompt` · `figma-audit-ui` · `audit` · `user-personas`

### Product & Planning
`prd` · `notion-planning` · `interview-me` · `spec-driven-development` · `shipping-and-launch`

### Engineering
`frontend-ui-engineering` · `browser-testing-with-devtools`

### Design System Suite
`design-builder` v6 · `design-component-builder` v5 · `design-icon-builder` v2.3 · `design-ui-builder` v5 · `design-md-audit` v6.1 · `design-styleguide` v3 · `design-remix` · `design-export-dtcg` v1

### Figma Integration
`figma-push-tokens` · `figma-push-components` · `figma-rename-tokens`

### Integrations (ต้อง setup ก่อนใช้)
`email-summarizer` · `jira-tracker`

> รายละเอียดเต็มดูที่ [README.md](README.md)

---

## Team Rules (Global — apply ทุก session)

หลังรัน `install-team-rules.sh` ทีมจะได้กฎกลาง 13 ข้อ:

| Layer | Rules |
|---|---|
| 🔒 Security | 1-6 (secret handling, auto-scan, rotation, incident response) |
| 🎯 Engineering | 7-11 (NO MAGIC, VERIFY BEFORE DONE, DISSENT, SCOPE DRIFT, R0/R1/R2) |
| 📚 Persistence | 12-13 (per-project `MEMORY.md` + `spec.md` — กันลืม / กัน /clear) |

ดูเนื้อหาเต็ม → [team-rules/CLAUDE.md](team-rules/CLAUDE.md)

---

## วิธีเพิ่ม Skill ใหม่

1. สร้าง folder `skills/<ชื่อ-skill>/SKILL.md` ตาม format
2. เพิ่มเข้า `skills-lock.json`
3. `git add` → `git commit` → `git push`
4. ทีมรัน `npx skills add sittipons-ike/uxui-skill-library` (re-sync)

---

## วิธีอัปเดต Team Rules

แก้ `team-rules/CLAUDE.md` → `git commit` → `git push`
ทีมทุกคนรัน `git pull` ใน repo → rules update ทันที (เพราะ symlink ชี้ไฟล์จริง)

---

## Connected Tools

- **Figma MCP** (`figma-console-mcp`) — ต่อ Figma โดยตรง อ่าน/เขียน/ตรวจ design ได้
- ตั้งค่าที่ `~/Library/Application Support/Claude/claude_desktop_config.json`

---

## Team

- **Lead:** sittipon.s@7solutions.co.th
- **Repo:** github.com/sittipons-ike/uxui-skill-library
- **Last updated:** 2026-06-25
