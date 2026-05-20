---
name: jira-tracker
description: Sprint tracking automation สำหรับ Jira board — รัน Mon/Wed/Fri 9am แจ้ง status changes, manday overrun, sprint ending. Monday เพิ่ม weekly per-person summary. ใช้ Atlassian MCP (OAuth) → Python คำนวณ → Lark webhook (HMAC). State diff ผ่าน state.json
type: automation
---

# Jira Sprint Tracker

> ⚠️ **ต้อง setup ก่อนใช้งาน** — skill นี้ต้องการ Atlassian MCP, Lark webhook, และค่า config ของ Jira project คุณ

## 🔧 Setup Checklist

ทำครั้งเดียวก่อนเริ่มใช้ — เช็กตามลำดับ:

### ขั้นตอนที่ 1 — เชื่อม Atlassian MCP

1. เปิด Claude Code Desktop → พิมพ์ `/mcp`
2. ถ้าเห็น **Atlassian** สถานะ Connected → ข้ามขั้นนี้
3. ถ้ายังไม่มี → ติดต่อ @sittipon เพื่อขอ config

### ขั้นตอนที่ 2 — เก็บ Lark Webhook ลง Keychain

**อย่า paste Webhook URL ใน chat** — ใช้ `/addkey` เสมอ

เปิด Claude Code แล้วรันทีละคำสั่ง:
```
/addkey lark-jira-update-webhook
```
```
/addkey lark-jira-update-secret
```

วาง URL และ HMAC secret ใน Terminal เมื่อถูกถาม (ไม่ต้อง paste ใน chat)

### ขั้นตอนที่ 3 — กำหนดค่า Jira project ใน tracker.py

เปิดไฟล์ `~/.config/claude-automations/jira-tracker/tracker.py` แล้วแก้ส่วน config:

```python
PROJECT_KEY  = "YOUR_PROJECT_KEY"    # เช่น "UXI", "DESIGN", "PROD"
CLOUD_ID     = "YOUR_JIRA_CLOUD_ID"  # หาจาก: เปิด Jira → Admin → Products → Cloud ID
SP_FIELD     = "customfield_XXXXX"   # Story Points field — ถาม admin หรือดูจาก Jira API
SPRINT_FIELD = "customfield_XXXXX"   # Sprint field — ถาม admin หรือดูจาก Jira API
```

### ✅ พร้อมใช้งานเมื่อ
- [ ] Atlassian MCP สถานะ Connected ใน `/mcp`
- [ ] `lark-jira-update-webhook` อยู่ใน Keychain (ตรวจด้วย `/listkeys`)
- [ ] `lark-jira-update-secret` อยู่ใน Keychain (ตรวจด้วย `/listkeys`)
- [ ] แก้ `PROJECT_KEY`, `CLOUD_ID`, `SP_FIELD` ใน `tracker.py` แล้ว
- [ ] ทดสอบรัน `python3 tracker.py` ก่อน activate schedule

---

Sprint tracking automation ที่รัน Mon/Wed/Fri 9 AM ส่งสรุป + alerts เข้า Lark group

## 🚦 Phase 0 — Pre-flight Check (ทำก่อนทุกครั้ง)

**MUST** ใช้ `AskUserQuestion` ถามก่อนเสมอ — ห้ามข้ามขั้นตอนนี้

ถามด้วย multiSelect: true ให้ user tick ✅ ทุกข้อที่พร้อม:

```
คำถาม: "ก่อนเริ่ม — เช็ก setup ให้ครบก่อนนะ"
header: "Setup Check"
options (multiSelect: true):
  - "✅ Atlassian MCP Connected แล้ว (เช็กที่ /mcp)"
  - "✅ รัน /addkey lark-jira-update-webhook แล้ว"
  - "✅ รัน /addkey lark-jira-update-secret แล้ว"
  - "✅ แก้ PROJECT_KEY, CLOUD_ID, SP_FIELD ใน tracker.py แล้ว"
```

**ถ้า user ไม่ tick ครบ หรือ dismiss:**
→ แสดงขั้นตอนที่ยังขาดพร้อม command ที่ต้องรัน แล้ว **หยุดทันที** ห้ามดำเนินการต่อ

ตัวอย่าง response เมื่อ setup ยังไม่ครบ:
```
⚠️ ยังไม่พร้อม — ต้องทำก่อน:

1. เชื่อม Atlassian MCP
   → ติดต่อ @sittipon เพื่อขอ config แล้วเช็กที่ /mcp

2. เก็บ Lark Webhook ลง Keychain
   → ขอ Webhook URL และ HMAC Secret จาก admin ก่อน
   → จากนั้นรันใน Claude Code ทีละคำสั่ง:
      /addkey lark-jira-update-webhook
      /addkey lark-jira-update-secret
   → อย่า paste URL ใน chat โดยตรง

3. แก้ค่า config ใน tracker.py
   → เปิดไฟล์ ~/.config/claude-automations/jira-tracker/tracker.py
   → แก้ PROJECT_KEY, CLOUD_ID, SP_FIELD, SPRINT_FIELD
   → ค่าเหล่านี้ขอได้จาก Jira admin

ทำครบแล้วค่อยรัน skill ใหม่อีกครั้ง
```

**ถ้า user tick ครบทุกข้อ → ดำเนินการต่อ**

---

## 🎯 Trigger Conditions

Skill นี้เป็น **scheduled automation** (launchd) — ไม่ต้องใช้ /command เรียก

แต่ skill นี้อ้างอิง pattern ที่ใช้ได้กับ automation อื่นๆ (Atlassian MCP + Python state diff + Lark webhook)

---

## 📦 Files

```
~/.config/claude-automations/jira-tracker/
├── tracker.py        # main logic (Python)
├── run.sh            # launchd wrapper
├── state.json        # auto-managed (last poll snapshot)
└── logs/

~/Library/LaunchAgents/
└── com.YOUR_USERNAME.jira-tracker.plist  # Mon/Wed/Fri @ 9am
```

## 🔑 Dependencies

### Keychain entries (read-only)
- `lark-jira-update-webhook` — Lark group webhook URL (Lark group "Jira daily update")
- `lark-jira-update-secret` — HMAC signing secret

### MCP / OAuth
- Atlassian MCP เชื่อมกับ `YOUR_ATLASSIAN_ACCOUNT` (shared work account)
- ใช้ OAuth ไม่ใช่ API token (API token ใช้ไม่ได้ในสถานการณ์ปัจจุบัน)

### Project
- Cloud ID: `YOUR_JIRA_CLOUD_ID`
- Project key: `YOUR_PROJECT_KEY` (UX/UI project)
- Story Points field: `customfield_XXXXX (Story Points)`
- Sprint field: `customfield_XXXXX (Sprint)`

---

## 🏗️ Architecture

```
launchd (Mon/Wed/Fri 9am)
  ↓
run.sh (sets env, exports HOME/PATH, unsets ANTHROPIC_API_KEY)
  ↓
tracker.py
  ├─ Fetch issues via claude -p --dangerously-skip-permissions (uses Atlassian MCP)
  ├─ Parse JSON → load state.json
  ├─ Compute diffs:
  │    • Status changes
  │    • Manday overrun (working days vs points)
  │    • Sprint end approaching (3 working days, To Do exists)
  ├─ Compose Lark messages (Thai)
  ├─ Send to Lark webhook (HMAC-signed)
  └─ Save updated state.json
```

## 📊 Output Format

### Monday — Weekly summary + alerts (ถ้ามี)

```
📊 Sprint N Weekly — 11 พ.ค. 2026 (จันทร์)

👤 Member A: 9 pts (8 tasks)
👤 Member B: 8 pts (3 tasks)
👤 Member C: 4 pts (2 tasks)

Total: 21 pts · 13 tasks
Sprint ends: 21 พ.ค. 2026 (10 working days)
⚠️ N tickets ยังไม่ estimate (แสดง —)
```

### Wed/Fri — Update message

```
📋 Sprint N Update — พุธ 13 พ.ค. 2026

🔄 Status changes (2)
• PROJ-XXXX [Member A]: ชื่อ task — To Do → In Progress
• PROJ-XXXX [Member A]: ชื่อ task — In Progress → Done

🚨 Manday Overrun (1)
• PROJ-XXXX [Member A] [2pt] ชื่อ task — In Progress 4 working days (เกินงบ 2 วัน)

⚠️ Sprint ends in 3 working days · 4 tickets ใน To Do (5 pts)
```

ถ้าไม่มี alert → "✅ ไม่มีการเปลี่ยนแปลง"

---

## 🧮 Logic Rules

### 1. Status change detection
- เทียบ `current.status_name` กับ `state.json[key].status`
- First run = state ว่าง → ไม่ alert (เริ่ม track)

### 2. Manday overrun
- เฉพาะ ticket ที่ `status_category == "indeterminate"` (ไม่ใช่ To Do, ไม่ใช่ Done)
- `points > 0` (ticket ที่ไม่มี estimate ข้าม)
- `working_days_since_moved_out_of_todo > points` → alert (เกินงบ N วัน)
- "moved_out_of_todo_at" = ตอนแรก track ใช้ `statuscategorychangedate` จาก API; ตอนเปลี่ยน status ตามจริง = poll time

### 3. Sprint end approaching
- working days ถึง `sprint.endDate` ≤ 3
- มี ticket อย่างน้อย 1 ใน To Do (`status_category == "new"`)
- Dedupe: 1 ครั้งต่อ sprint endDate (จำใน `state.sprint_end_alerted_for`)

### Working day calculation
- Mon-Fri only (skip Sat-Sun)
- Inclusive of `end`, exclusive of `start`
- Implementation: simple loop with `weekday() < 5`

### Ticket counting (Method B)
- นับ **ทุก ticket** (Story + Sub-task + Bug + ฯลฯ)
- Ticket ที่ไม่มี points → แสดง "—" + นับ 0

---

## 🚀 Activation

```bash
# Bootstrap (load schedule)
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.YOUR_USERNAME.jira-tracker.plist

# Verify
launchctl print gui/$(id -u)/com.YOUR_USERNAME.jira-tracker | grep -E "state|next"
```

## 🛑 Deactivation

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.YOUR_USERNAME.jira-tracker.plist
```

## 🧪 Manual Test

```bash
# Pre-flight (no Claude quota): keychain + Lark webhook only
python3 -c "from tracker import working_days_between; ..."

# Full run (uses ~3K Claude tokens)
~/.config/claude-automations/jira-tracker/run.sh

# Or unbuffered Python with progress
python3 -u ~/.config/claude-automations/jira-tracker/tracker.py
```

---

## 💰 Cost

| | |
|---|---|
| Per run | ~3K tokens (claude fetch only — Python คำนวณเอง) |
| Per week | 3 runs × 3K = ~10K tokens |
| Per month | ~40-50K tokens |

ใช้ subscription Claude Max (ไม่มี API charges)

---

## 🐛 Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `Fetched 0 issues` | Active sprint ว่างเปล่า OR JQL filter wrong | ดู Jira board ว่ามี active sprint มั้ย |
| `claude exit non-zero` | OAuth expired / quota exhausted | `claude /login` re-auth |
| `Lark error 19021` | HMAC sign ผิด | ตรวจ `lark-jira-update-secret` ใน Keychain |
| `No JSON object found in claude output` | Claude เพิ่ม prose ปน JSON | ปรับ prompt ให้ strict — extractor ในโค้ดมี regex แล้ว |
| State drift (alerts ไม่ตรง) | state.json corrupted | ลบ `state.json` แล้วรันใหม่ (ครั้งถัดไปเริ่ม fresh — ไม่มี status alerts) |

---

## 🔄 Reset / Reuse Pattern

ถ้าจะใช้ pattern นี้กับ project Jira อื่น:

1. Copy ทั้ง dir `~/.config/claude-automations/jira-tracker/` → `<new-name>/`
2. แก้ `tracker.py` config:
   - `PROJECT_KEY`
   - `SP_FIELD` (อาจไม่ใช่ 10032 ใน Jira อื่น — query field list หรือใช้ getJiraIssue ดู custom fields)
3. Update Keychain entries (`<new>-webhook`, `<new>-secret`)
4. Copy plist + เปลี่ยน `Label` + paths
5. Bootstrap ใหม่

---

## 🔗 Related

- **email-summarizer** skill — pattern เดียวกันแต่ใช้ Gmail MCP
- **Lark webhook setup** — เก็บ URL + secret ใน Keychain ผ่าน `/addkey`
