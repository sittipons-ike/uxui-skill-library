---
name: email-summarizer
description: สรุป Gmail inbox 24 ชม.ที่ผ่านมาเป็นภาษาไทย แบ่งกลุ่ม Action/FYI/Meeting ใช้สำหรับ daily morning summary หรือเมื่อ user ขอสรุปเมล output เป็นรูปแบบที่ส่งเข้า Lark ได้ — แต่ละ block คั่นด้วย ===LARK-MSG=== สำหรับ wrapper script parse ส่ง webhook
type: automation
---

# Email Summarizer Skill

> ⚠️ **ต้อง setup ก่อนใช้งาน** — skill นี้ต้องการการเชื่อมต่อ Gmail และ (optional) Lark webhook

## 🔧 Setup Checklist

ทำครั้งเดียวก่อนเริ่มใช้ — เช็กตามลำดับ:

### ขั้นตอนที่ 1 — เชื่อม Gmail MCP

Gmail MCP ทำให้ Claude อ่านเมลได้ (read-only ไม่ส่งเมลเอง)

1. เปิด Claude Code Desktop → พิมพ์ `/mcp`
2. ถ้าเห็น **Gmail** หรือ **google-workspace** สถานะ Connected → ข้ามขั้นนี้ได้
3. ถ้ายังไม่มี → ติดต่อ @sittipon เพื่อขอ config ครับ

### ขั้นตอนที่ 2 — เก็บ Lark Webhook (ถ้าต้องการส่ง Lark)

ถ้าแค่สรุปเมลดูเองในแชท → ข้ามขั้นนี้ได้

ถ้าอยากให้ output ส่งเข้า Lark group อัตโนมัติ:

1. ขอ Webhook URL จาก admin Lark group
2. เปิด Claude Code Desktop แล้วรัน:
   ```
   /addkey lark-email-webhook
   ```
3. วาง Webhook URL เมื่อถูกถาม (ไม่ต้อง paste ใน chat)

### ✅ พร้อมใช้งานเมื่อ
- [ ] Gmail MCP สถานะ Connected ใน `/mcp`
- [ ] (optional) `lark-email-webhook` อยู่ใน Keychain แล้ว

---

ใช้สำหรับสรุปเมลใน Gmail inbox ย้อนหลัง 24 ชั่วโมง output เป็นภาษาไทย รูปแบบที่ wrapper script (`~/.config/claude-automations/daily-email-summary/run.sh`) parse และส่งเข้า Lark group ได้

---

## 🎯 Trigger Conditions

Skill นี้ trigger เมื่อ user (หรือ wrapper script) ขอ:
- "สรุปเมล" / "summarize emails" / "daily email summary"
- หรือเรียกตรงๆ `/email-summarizer`

---

## 🚦 Phase 0 — Pre-flight Check (ทำก่อนทุกครั้ง)

**MUST** ใช้ `AskUserQuestion` ถามก่อนเสมอ — ห้ามข้ามขั้นตอนนี้

ถามด้วย multiSelect: true ให้ user tick ✅ ทุกข้อที่พร้อม:

```
คำถาม: "ก่อนเริ่ม — เช็ก setup ให้ครบก่อนนะ"
header: "Setup Check"
options (multiSelect: true):
  - "✅ Gmail MCP Connected แล้ว (เช็กได้ที่ /mcp)"
  - "✅ มี Lark Webhook URL จาก admin แล้ว (หรือไม่ต้องส่ง Lark)"
  - "✅ รัน /addkey lark-email-webhook แล้ว (ถ้าต้องส่ง Lark)"
```

**ถ้า user ไม่ tick ครบ หรือ dismiss:**
→ แสดงขั้นตอนที่ยังขาดอยู่พร้อม command ที่ต้องรัน แล้ว **หยุดทันที** ห้ามดำเนินการต่อ

ตัวอย่าง response เมื่อ setup ยังไม่ครบ:
```
⚠️ ยังไม่พร้อม — ต้องทำก่อน:

1. เชื่อม Gmail MCP
   → ติดต่อ @sittipon เพื่อขอ config แล้วเช็กที่ /mcp

2. เก็บ Lark Webhook ลง Keychain (ถ้าต้องส่ง Lark)
   → ขอ Webhook URL จาก Lark admin ก่อน
   → จากนั้นรันใน Claude Code:
      /addkey lark-email-webhook

ทำครบแล้วค่อยรัน /email-summarizer ใหม่อีกครั้ง
```

**ถ้า user tick ครบทุกข้อ → ดำเนินการต่อ Phase 1**

---

## 📋 Execution Steps

### 1. Fetch emails

ใช้ Gmail MCP `search_threads` ด้วย query:

```
is:important is:unread newer_than:1d
```

- `is:important` — Gmail's IMPORTANT label
- `is:unread` — ยังไม่อ่าน
- `newer_than:1d` — ในช่วง 24 ชม.

ถ้า query result ว่าง → จบที่ขั้นนี้ output เป็น "no emails" message (ดู step 5)

### 2. อ่านเนื้อหาแต่ละ thread

สำหรับ thread ที่ได้ ใช้ `get_thread` ดึง:
- Subject
- Sender (name + email)
- Body (first 500 chars พอ)
- Date
- Attachments (จำนวนไฟล์ ถ้ามี)

### 3. จัดประเภท

จัดทุก thread เข้า 1 ใน 3 กลุ่ม โดยอ่าน subject + body:

| 🔴 Action Required | 🟡 FYI | 📅 Meeting |
|---|---|---|
| ต้องทำอะไรกลับ มี deadline ขอ approval/answer/decision คำถาม | แค่ informational, newsletter ที่ user สำคัญพอที่จะ flag important | นัดหมาย, calendar invite, meeting confirmation |

**สัญญาณ Action:** "?" ในเนื้อหา, "please", "need", "deadline", "by [date]", "approve", "review", "ASAP", "?", "ขอ", "ต้องการ", "กรุณา", "ภายใน"

**สัญญาณ Meeting:** "meeting", "call", "invite", "calendar", "นัด", "ประชุม", iCal attachment

ที่เหลือ → FYI

### 4. สรุปแต่ละเมล

แต่ละเมลในกลุ่ม สรุปเป็น 1 บรรทัด (max ~150 chars):

```
• [ผู้ส่ง] หัวข้อเมล — ใจความหลัก ภาษาไทย — [deadline ถ้ามี]
```

**กฎ:**
- ผู้ส่ง: ใช้ชื่อ ไม่ใช่ email (ถ้าเป็น org → ใช้ชื่อ org)
- หัวข้อ: ใช้ของเดิม (อังกฤษหรือไทยตามต้นฉบับ)
- ใจความ: **ภาษาไทย** เสมอ — สรุปจริงไม่ใช่ paraphrase หัวข้อ
- Deadline: bold เด่นๆ ถ้ามี (เช่น `**กำหนด: 9 พ.ค.**`)

### 5. Format output

Output เป็น **stdout** ตามรูปแบบนี้ (มี delimiter ชัดเจน):

#### กรณีมีเมล

```
===LARK-MSG===
📬 สรุปเมลประจำวัน — DD MMM YYYY (เช้า)
จาก inbox 24 ชม. ที่ผ่านมา

🔴 Action Required (N)
• [ผู้ส่ง 1] หัวข้อ 1 — ใจความ — **กำหนด: ...**
• [ผู้ส่ง 2] หัวข้อ 2 — ใจความ
...
===LARK-MSG===
🟡 FYI (M)
• [ผู้ส่ง 1] หัวข้อ 1 — ใจความ
...
===LARK-MSG===
📅 Meeting/Calendar (K)
• [ผู้ส่ง 1] หัวข้อ — วันเวลา
...
===LARK-MSG-END===
```

**กฎการ split message:**
- 1 กลุ่ม = 1 ข้อความ (Lark message)
- ถ้ากลุ่มไหนว่าง (0 รายการ) → **ไม่ต้อง output** กลุ่มนั้น
- ถ้ากลุ่มไหนมี > 15 รายการ → split เพิ่มเป็น 2 messages (cont'd)
- Header (📬 ...) อยู่แค่ message แรกเท่านั้น

#### กรณีไม่มีเมลเลย

```
===LARK-MSG===
🎉 เคลียร์! ไม่มีเมลด่วน
DD MMM YYYY — inbox สะอาด มีวันที่ดี ☀️
===LARK-MSG-END===
```

#### กรณี error (ไม่ควรเกิด — ถ้าเกิดให้ output แบบนี้แทน)

```
===LARK-MSG===
⚠️ สรุปเมลไม่สำเร็จ
สาเหตุ: <reason — เช่น Gmail auth expired, Gmail API rate limit>
ลอง re-auth Gmail MCP หรือตรวจ log ที่ ~/.config/claude-automations/daily-email-summary/logs/
===LARK-MSG-END===
```

---

## ✅ Output Format Constraints

- **stdout เท่านั้น** — ห้าม echo อะไรนอกเหนือจากที่กำหนด (wrapper script จะ parse)
- **`===LARK-MSG===`** = delimiter ระหว่าง messages
- **`===LARK-MSG-END===`** = end of all messages (ตัวสุดท้ายเสมอ)
- **ไม่ต้อง print debug info** — ถ้ามี ให้เขียนไป stderr
- **ไม่ต้อง send Lark เอง** — wrapper script จัดการการส่ง
- **ภาษาไทย** สำหรับใจความสรุปเสมอ ยกเว้นชื่อคน/หัวข้อต้นฉบับ

---

## 🚫 Constraints

- ❌ **ไม่ตอบเมลให้** — แค่สรุป
- ❌ **ไม่ลบ/archive เมล** — read-only
- ❌ **ไม่อ่านเมลที่ไม่ Important** — ตามเกณฑ์ user (Important + Unread เท่านั้น)
- ❌ **ไม่เปิดเผย email body เต็ม** ใน output (privacy — ถ้า user อยากอ่านต่อให้ไปเปิดเอง)
- ❌ **ไม่ summarize ข้าม thread context** — ถ้า thread ยาว ดู message ล่าสุดเป็นหลัก

---

## 📝 Example Output

```
===LARK-MSG===
📬 สรุปเมลประจำวัน — 8 พ.ค. 2026 (เช้า)
จาก inbox 24 ชม. ที่ผ่านมา

🔴 Action Required (2)
• [คุณ A จากบริษัท X] Re: Design review feedback — ขอ approve mockup v3 ภายในวันนี้ — **กำหนด: 8 พ.ค. 17:00**
• [Notion] Workspace billing — credit card หมดอายุเดือนหน้า ต้อง update
===LARK-MSG===
🟡 FYI (3)
• [GitHub] anthropics/apps weekly digest — มี PR ใหม่ 12 รายการที่เกี่ยวกับ ui-system
• [LinkedIn] John Doe ติดต่อมา — sales pitch
• [Lark] product update — เพิ่ม feature audio chat ใน Lark Rooms
===LARK-MSG===
📅 Meeting/Calendar (1)
• [คุณ B] Sync ทีม UXUI — 9 พ.ค. 14:00-15:00
===LARK-MSG-END===
```
