# 🛡️ Working Rules

> **กฎที่ Claude ต้องยึดถือทุก session — ไม่มีข้อยกเว้น**
>
> Owner: design@7solutions.co.th
>
> **2 หมวดหลัก:**
> - 🔒 **Security** (Rules 1–6) — การจัดการ secrets
> - 🎯 **Engineering Discipline** (Rules 7–11) — วิธีคิดและส่งมอบงาน

---

## 🚧 Active Architecture Migration — JSON Manifest (Phase 5)

DS spec layer migrating from `.md` → JSON manifests (DTCG-aligned).

**Read first when working on DS skills:**
- [docs/architecture-v5.md](docs/architecture-v5.md) — full rationale + roadmap
- [schemas/ref-resolver.md](schemas/ref-resolver.md) — ref syntax `{file.path}` + diff-merge algorithm
- [schemas/components.schema.json](schemas/components.schema.json) — atoms/molecules/organisms manifest
- [schemas/ui.schema.json](schemas/ui.schema.json) — pages/sections/flows manifest
- [schemas/patterns.schema.json](schemas/patterns.schema.json) — reusable shells manifest

**Status:**
- ✅ Phase 1A: schemas + examples + ref-resolver spec
- ✅ Phase 1B: architecture doc
- ✅ Phase 2A: design-component-builder v5 (JSON output)
- ✅ Phase 2B: design-ui-builder v4
- ✅ Phase 2C: design-builder v6.1 (doc-only pipeline refs)
- ✅ Phase 2D: design-icon-builder v2.2 (doc-only)
- ✅ Phase 3B: design-styleguide v3.1 (JSON-aware + MD fallback)
- ⏳ Phase 3A: design-md-audit v3 (JSON schema validation)
- ⏳ Phase 4: migration tool (`--migrate-to-json`)
- ⏳ Phase 5: E2E verify on sample DS
- ⏳ Phase 6 (deferred): DTCG Style Dictionary export

---

# 🔒 SECURITY RULES

## 🚫 RULE 1 — Secrets ต้องไม่อยู่ที่เหล่านี้

**ห้ามเด็ดขาด** ฝัง / commit / log secret ในสถานที่ต่อไปนี้:

| ที่ห้าม | เหตุผล |
|---|---|
| ❌ Source code | จะถูก commit ขึ้น git → หลุดถาวร |
| ❌ Config files (`settings.json`, `package.json`) | อาจ commit หรือ share โดยไม่ตั้งใจ |
| ❌ SKILL.md | ขึ้น git แน่นอน — ใช้ `{{PLACEHOLDER}}` หรือ instruct ผู้ใช้ผ่าน `/addkey` |
| ❌ Markdown / docs / comments | ขึ้น git แน่นอน |
| ❌ Bash command ที่ echo/cat secret | shell history เก็บไว้ |

**Secrets ที่ครอบคลุม:**
- API tokens (`ntn_`, `sk-`, `ghp_`, `xox[bp]-`, `AKIA`)
- Webhook URLs ที่ใช้เป็น auth
- HMAC signing secrets
- OAuth client secrets
- Database URLs ที่มี credentials

---

## ✅ RULE 2 — ที่เก็บ Secrets ที่ปลอดภัย

แนะนำตามลำดับ:

1. **macOS Keychain** ⭐ **ใช้ slash command `/addkey` แทนการรันมือ**
2. **`.env` file** (gitignored) + dotenv loader
3. **Environment variable** ใน `~/.zshrc`

### 🔑 Slash commands สำหรับจัดการ keys

| Command | หน้าที่ |
|---|---|
| `/addkey <service>` | เพิ่ม API key ลง Keychain (มี security check ก่อน) |
| `/listkeys` | ดู keys ที่เก็บไว้ (metadata เท่านั้น) |
| `/removekey <service>` | ลบ key |

**Skill ที่ต้องการ secret** (เช่น `email-summarizer`, `jira-tracker`) ต้อง:
- ใน SKILL.md → instruct user ให้รัน `/addkey <name>` เอง
- ห้าม hardcode token / webhook URL ใน SKILL.md
- ใช้ Pre-flight check (AskUserQuestion) เช็ก setup ก่อนรัน

---

## 🔍 RULE 3 — Auto-scan ก่อนทุก action ที่เสี่ยง

### ก่อน `git add` / `git commit` / `git push`
- Scan staged content หา pattern:
  - `Bearer\s+[A-Za-z0-9_\-\.]+`
  - Token prefix: `ntn_`, `sk-`, `ghp_`, `xox[bpoa]-`, `AKIA`, `eyJ`
  - Private key markers: `-----BEGIN ... PRIVATE KEY-----`
- ถ้าเจอ → **หยุด commit ทันที** + แจ้ง user

### ก่อนแสดง config / settings file ใน chat
- Redact secret เป็น `<REDACTED>` ก่อนแสดง

### ก่อนรัน curl / API call
- ถ้าเห็น secret hardcode → **ไม่รัน** + เสนอเปลี่ยนเป็น `$ENV_VAR`

---

## 🚨 RULE 4 — ถ้าเจอ secret รั่วในระบบ

```
1. หยุด action ปัจจุบันทันที
2. แจ้ง user (ไม่แสดง secret เต็ม)
3. Scan ทั่ว — git history, ~/.claude/projects/*.jsonl, shell history
4. Redact ด้วย placeholder เช่น "ntn_REDACTED_PLEASE_ROTATE"
5. แนะนำ rotation ที่ provider
6. แนะนำย้าย secret ใหม่ไป Keychain
```

---

## 🔐 RULE 5 — Tool-specific rules

### Git
- ❌ `git add -A` / `git add .` ต้องเช็คว่าไม่มีไฟล์ใหม่ที่อาจมี secret
- ❌ ห้าม `git push --force` to main เด็ดขาด
- ❌ ห้าม commit ถ้า diff มี secret pattern

### Shell / Bash
- ❌ ห้าม `echo $TOKEN`, `cat .env` ลง stdout
- ✅ ใช้ `$VAR` reference แทน inline
- ✅ ถ้าต้อง debug — mask: `echo "${TOKEN:0:8}***"`

---

## 📋 RULE 6 — Checklist ก่อนปิด session

- [ ] ไม่มี secret ใหม่ใน SKILL.md / docs
- [ ] ไม่มี untracked file ที่มี secret
- [ ] `git status` clean
- [ ] ถ้าเจอ secret รั่ว — rotate แล้ว ไม่ใช่แค่ลบ

---

# 🎯 ENGINEERING DISCIPLINE

## 🎲 RULE 7 — NO MAGIC (ห้ามเดา)

**Assumptions ทุกอย่างต้อง explicit** — ห้าม hallucinate

| ✅ ทำแบบนี้ | ❌ ห้ามทำแบบนี้ |
|---|---|
| "ขอ confirm ว่า skill นี้ trigger ตอนไหน" | เดา trigger condition แล้วเขียน SKILL.md |
| Read SKILL.md จริงก่อนอ้างอิง | อ้างอิงจาก memory |
| "ไม่เห็น MCP X — เพิ่ม pre-flight check ดีมั้ย" | สมมติว่า MCP ทำงานได้แน่ |

ถ้า context ไม่พอ → state assumption **ก่อน** เขียน

---

## ✔️ RULE 8 — VERIFY BEFORE DONE

**"แก้แล้ว" ≠ "เสร็จ"** — ต้องมี evidence

| สถานะ | คำพูดที่ใช้ได้ | คำพูดที่ห้ามใช้ |
|---|---|---|
| Push แล้วยังไม่ test install | "push แล้ว — กำลัง test npx install" | "เสร็จแล้ว ✅" |
| Test install ผ่าน | "เสร็จ — install ครบ 18 skills" | "should work" |
| Verify ไม่ได้ | "push แล้ว แต่ test ไม่ได้เพราะ X" | "ทำเสร็จแล้ว" |

**Evidence:**
- ✅ Output ของ `npx skills add` / `claude plugin install`
- ✅ Git status / diff
- ✅ Verify command ที่ confirm พฤติกรรม

---

## 🛑 RULE 9 — DISSENT (ต้องเถียงก่อน change ใหญ่)

ก่อน change ใหญ่ใน repo — ตั้งคำถาม:

```
1. 💥 BLAST RADIUS — กระทบทีมกี่คน? ต้อง re-install plugin ไหม?
2. 🔮 ASSUMPTIONS — ทีมใช้ install method ไหน? plugin หรือ npx?
3. ↩️ REVERSIBILITY — revert ผ่าน git ได้ แต่ทีมต้อง re-install อยู่ดี
4. 👁️ BLIND SPOTS — มี skill ที่ depend on อันที่จะแก้ไหม?
```

**เกณฑ์ "change ใหญ่":**
- ลบ skill / rename skill
- เปลี่ยน folder structure
- Breaking change ใน frontmatter
- Push to main

---

## 📏 RULE 10 — SCOPE DRIFT DETECTION

**Track เป้าหมายเดิม vs ที่ทำจริง**

| Drift signs | ตัวอย่าง |
|---|---|
| 🍰 "Just one more" | "เพิ่ม skill X" → "ขอแก้ Y ด้วย" → "Z ก็เห็น..." |
| 🎯 Nice-to-have → Must | "อยาก polish docs" → rewrite ทั้ง README |
| 🌊 ขอบเขตขยาย | "Fix typo" → ปรับ structure ทั้ง folder |

**เมื่อเจอ drift:**
1. หยุดและสรุปสิ่งที่กำลังจะทำเพิ่ม
2. ถาม: "เดิม agree X — ตอนนี้กลายเป็น X+Y+Z OK มั้ย?"
3. ถ้าเลยไปแล้ว — แยก commit/PR

---

## 🚦 RULE 11 — R0 / R1 / R2 (Reversibility)

### 🔴 R0 — Irreversible (ถาม user ก่อนทุกครั้ง)

| R0 actions | เหตุผล |
|---|---|
| `git push --force` to main | overwrite history |
| Delete skill folder ที่ทีมใช้อยู่ | ทีมจะใช้ไม่ได้หลัง update |
| Rename skill (frontmatter name) | ทีม invoke ด้วยชื่อเก่าจะ fail |
| Transfer repo / change repo name | URL ของ install command พังหมด |

### 🟡 R1 — Costly to Reverse (บอกเหตุผลก่อนทำ)

| R1 actions | reversal cost |
|---|---|
| `git commit` to main | revert + push อีกรอบ |
| Edit shared SKILL.md | ทีมต้อง re-install |
| Restructure folder | update marketplace.json + plugin.json + symlinks |
| Push to main | force-push ไม่ได้ → ต้อง revert commit |

### 🟢 R2 — Easily Reversed (ลุยเลย)

| R2 actions | |
|---|---|
| Edit local file (uncommitted) | `git checkout -- file` |
| Read SKILL.md / grep | ไม่กระทบ state |
| Test install ใน /tmp | ลบ folder ทิ้ง |
| Run agent (read-only) | ไม่กระทบ state |

**กฎ:** R0 → ถามทุกครั้ง · R1 → บอกเหตุผล · R2 → ลุยเลย

---

# 🎯 ปรัชญาพื้นฐาน

> **"ลบจากไฟล์ ≠ ปลอดภัย" — ต้อง rotate ที่ provider เสมอ**

เพราะ secret รั่วไปไหนบ้างเราไม่รู้:
- Git history, backups, sync services, screen recordings
- AI/IDE tools ที่ index ไฟล์

**Rotation = action เดียวที่ปลอดภัย 100%**

---

## 📅 Last Updated

- 2026-05-30 — refactored to mirror global CLAUDE.md (Rules 1–11) + project-specific structure section
