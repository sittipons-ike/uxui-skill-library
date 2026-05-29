---
name: setup-helper
description: Guide ทีม Designer setup Claude Code + Figma MCP + skills ครั้งแรก — เช็ก prerequisites, walk through setup steps, แนะนำ skill ที่ลองใช้ครั้งแรก ใช้เมื่อ user พูดว่า "เริ่มยังไง", "เพิ่งติดตั้ง", "setup", "ติดตั้งครั้งแรก", "first time", "เริ่มต้น", หรือเรียกตรง /setup-helper
license: MIT
---

# Setup Helper

> Guide ทีมตอน install ครั้งแรก — ช่วยเช็ก prerequisites และพาเริ่มใช้ skill แรก

## 🎯 Trigger Conditions

Skill นี้ trigger เมื่อ user พูดว่า:
- "เริ่มยังไง", "เริ่มต้น", "ต้องทำอะไรบ้าง"
- "เพิ่งติดตั้ง skill นี้", "ลงครั้งแรก"
- "first time", "getting started", "setup", "onboarding"
- เรียกตรง `/setup-helper`

**Do NOT trigger when:** user อยู่กลาง task อื่น หรือถามเรื่อง skill ใดๆ เป็นการเฉพาะ

---

## 🔄 Execution Workflow

### Phase 1: ทักทาย + อธิบาย scope

แสดงข้อความสั้น:
```
👋 ยินดีต้อนรับสู่ UXUI Skill Library

ผมช่วยเช็กว่า setup ครบหรือยัง แล้วพาลองใช้ skill แรก
ใช้เวลา ~5 นาที
```

### Phase 2: Pre-flight Check (ใช้ AskUserQuestion)

ถามรอบเดียว multiSelect: true ให้ tick ทุกข้อที่ทำแล้ว:

```
คำถาม: "เช็ก setup ก่อน — ทำอะไรไปบ้างแล้ว?"
header: "Setup Check"
options (multiSelect: true):
  - "✅ ติดตั้ง Node.js แล้ว (เช็ก: node -v ใน Terminal)"
  - "✅ ติดตั้ง Git แล้ว (เช็ก: git --version ใน Terminal)"
  - "✅ ติดตั้ง Claude Code Desktop แล้ว"
  - "✅ ต่อ Figma MCP แล้ว (เช็กที่ /mcp เห็น figma-console Connected)"
```

### Phase 3: วิเคราะห์ผล + แนะนำขั้นต่อ

**ถ้า tick ครบทุกข้อ:**
- ✅ "Setup เรียบร้อย พร้อมใช้งานแล้ว"
- ไป Phase 4

**ถ้า tick ไม่ครบ:**
- แสดงเฉพาะ step ที่ยังขาดพร้อม command/link
- ใช้ format นี้สำหรับแต่ละข้อที่ขาด:

```
❌ ยังไม่ได้: [step name]
   → วิธีทำ: [คำสั่ง หรือ link ไป ONBOARDING.md section]
```

ตัวอย่าง:
```
❌ ยังไม่ได้ติดตั้ง Node.js
   → เปิด nodejs.org → กดปุ่ม LTS → install
   → เช็กด้วย `node -v` ใน Terminal

❌ ยังไม่ได้ติดตั้ง Git
   → เปิด Terminal แล้วรัน: xcode-select --install
   → กด Install เมื่อมี popup → รอ 5-10 นาที
   → เช็กด้วย `git --version`

❌ ยังไม่ได้ต่อ Figma MCP
   → ดู ONBOARDING.md ขั้นตอนที่ 3
   → หรือติดต่อ @sittipon (design@7solutions.co.th)
```

แล้วบอก: "ทำให้ครบแล้วเรียก /setup-helper ใหม่อีกที"
**หยุดทันที — ห้ามดำเนินการต่อ**

### Phase 4: แนะนำ skill แรก (เมื่อ setup ครบแล้ว)

ใช้ `AskUserQuestion` ถาม role/use case ทีมเพื่อแนะนำ skill ที่เหมาะ:

```
คำถาม: "อยากลอง skill อันไหนก่อน?"
header: "First skill"
multiSelect: false
options:
  - "🎨 audit-ui — ตรวจ Figma DS compliance"
  - "🗺️ ux-skill — วาง User Flow + IA"
  - "🧩 ui-skill — Map component จาก Blueprint"
  - "📋 prd — สร้าง Product Requirements Document"
```

ตามที่เลือก → แสดง example prompt ที่ใช้ได้ทันที:

| skill | example prompt |
|---|---|
| audit-ui | "Audit Figma นี้: [วาง link] ตรวจ DS compliance" |
| ux-skill | "วาง UX Blueprint สำหรับฟีเจอร์ X — User goal: Y, Business goal: Z" |
| ui-skill | "Map component จาก Blueprint นี้ → DS [name]" |
| prd | "/prd ฟีเจอร์ [ชื่อ feature]" |

ปิดท้าย:
```
✅ พร้อมแล้ว — copy prompt ข้างบน วางใน Claude Code ได้เลย

เจอปัญหาตอนใช้ → /setup-helper อีกที หรือถาม @sittipon
```

---

## 📋 Skills ที่ทีมจะได้ใช้

หลัง setup เสร็จ ทีมจะมี skills เหล่านี้ใน `~/.claude/skills/`:

**ใช้ทันที:**
- `audit-ui` — ตรวจ Figma
- `ux-skill` — วาง UX
- `ui-skill` — Map component
- `ux-writing` — copy
- `prd` — สร้าง PRD
- `masterprompt` — สร้าง structured prompt
- `notion-planning` — วางแผน Notion
- `audit` — ตรวจ interface quality

**ต้อง setup เพิ่มก่อน (มี checklist popup ในตัว):**
- `email-summarizer` — สรุปเมล
- `jira-tracker` — track sprint

---

## 🚫 Constraints

- ❌ **ห้ามรัน skill อื่นแทน user** — แค่แนะนำ + ให้ prompt
- ❌ **ห้ามดำเนินการต่อถ้า setup ไม่ครบ** — หยุดที่ Phase 3
- ❌ **ห้าม assume ว่า MCP ทำงานได้** — ให้ user confirm ผ่าน /mcp
- ✅ **ภาษาไทย** เสมอ — เพราะทีมเป็น Designer ไทย
- ✅ **ใช้ AskUserQuestion** — ห้ามถามด้วย text แทน

---

## 🔗 Related Links

- ONBOARDING.md — คู่มือเต็มสำหรับการลงเครื่อง
- README.md — overview ของ skills ทั้งหมด
- ติดต่อ: design@7solutions.co.th (@sittipon)
