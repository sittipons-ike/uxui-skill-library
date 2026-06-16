---
name: modal-writer
description: Write or review Thai modal copy (Title + Body + Primary CTA + Secondary CTA) for Desktop web apps following Thai UX writing standards. Covers 6 modal types — Confirmation (general/destructive), Success, Error, Info, Loading. Enforces verb+noun titles, action-mirrored CTAs, ≤80 char body, Double/Single button layout rules, WCAG 1.4.1 color+shape. Forbidden patterns auto-flagged (no "ยืนยัน" CTAs, no "?" in titles, no "กด" for Desktop, no jargon in body). Triggers on "เขียน modal", "modal copy", "modal text", "modal confirmation", "modal error", "review modal", "ตรวจ modal", "modal UX".
license: MIT
---

# Modal Writer (Thai UX)

> Write or review modal copy (Title + Body + Buttons) for Thai Desktop web apps following team UX writing standards.
>
> Adapted from Lottery Plus Back-Office Modal UX Writing Guide v1.2.

## When to use

- เขียน modal copy ใหม่สำหรับ feature
- Review modal ที่มีอยู่ ก่อน implement
- ทีมต้องการ consistency ข้าม modals ทั้งระบบ
- มี Figma frame ที่มี modal — ตรวจ copy compliance

## When NOT to use

- Mobile-first apps → ใช้ "แตะ" แทน "คลิก" (skill นี้ Desktop-focused)
- ภาษาอื่น (EN/CN) → skill นี้ Thai-only
- Toast / notification (not modal) — different pattern
- Inline error / form helper text → ใช้ ux-writing skill

---

## 1. Tone of Voice

**Platform:** Desktop Browser เท่านั้น — ใช้ **"คลิก"** ไม่ใช่ "กด"

| หลักการ | ความหมาย |
|---|---|
| ทางการแต่เข้าใจง่าย | ภาษาราชการระดับกลาง ไม่ใช้ภาษาพูดหรือศัพท์เฉพาะ |
| กระชับ ตรงประเด็น | ประโยคสั้น สาระสำคัญใน 1–2 ประโยค |
| เน้นการกระทำ | บอกผู้ใช้ว่าต้องทำอะไร ไม่อธิบายกระบวนการภายใน |
| สอดคล้องกัน | ใช้คำเดิมในความหมายเดิมทั้งระบบ |

---

## 2. ประเภท Modal และ Intent

| ประเภท | Icon | สี | Intent | Tone |
|---|---|---|---|---|
| Confirmation ทั่วไป | ⚠️ สามเหลี่ยม filled | เหลือง/ส้ม | ยืนยัน action ที่ reversible | Neutral / Serious |
| Confirmation Destructive | △ สามเหลี่ยม outline | แดง | ยืนยัน action ที่ย้อนกลับไม่ได้ | Serious / Warning |
| Success | ✓ วงกลม + ติ๊กถูก | เขียว #16A34A | แจ้งว่าดำเนินการสำเร็จ | Positive |
| Error / Failure | ✕ วงกลม + X | แดง | แจ้งว่าล้มเหลว + next step | Calm / ไม่ตำหนิ |
| Info / Notice | ℹ วงกลม + i | น้ำเงิน | ให้ข้อมูลก่อนดำเนินการ | Neutral / Informative |
| Loading | ⟳ Spinner animated | น้ำเงิน | กำลังประมวลผล | Neutral |

**เกณฑ์เลือก Confirmation Icon:**
- ⚠️ เหลือง = Action **ย้อนกลับได้** (แก้ไข, วางขาย, อนุมัติ)
- △ แดง = Action **ย้อนกลับไม่ได้เลย** (ลบถาวร, ยกเลิกออเดอร์)

---

## 3. โครงสร้าง Modal มาตรฐาน

```
┌─────────────────────────────────────────┐
│  [Icon]  Title (กริยา + นาม)            │
│                                         │
│  Body text — ผลที่จะเกิดขึ้น (≤2 บรรทัด) │
│                                         │
│        [ ยกเลิก ]  [ Primary CTA ]     │
└─────────────────────────────────────────┘
```

### กฎ Title
- ≤ **40 ตัวอักษร**
- รูปแบบ **"กริยา + นาม"** (e.g. "ลบรายการนี้", "วางขายสินค้า")
- ❌ ห้ามใช้ "ยืนยัน" นำหน้า
- ❌ ห้ามใช้เครื่องหมายคำถาม (?)
- ระบุ Object ชัดเจน — "ลบรายการนี้" ไม่ใช่แค่ "ลบ"

### กฎ Body
- ≤ **80 ตัวอักษร** (ไม่เกิน 2 บรรทัด)
- **Destructive:** เน้นผลที่ย้อนกลับไม่ได้
- **Confirmation:** บอกผลที่เกิดขึ้น
- **Success:** กระชับ ≤ 1 ประโยค
- **Error:** อะไรเกิดขึ้น + ทำไม + ทำอะไรต่อ — ❌ ห้ามตำหนิผู้ใช้
- **Loading:** ไม่ต้องมี หรือ "กรุณารอสักครู่"

### กฎ Button
- Primary CTA ต้อง **mirror Action ใน Title**
- ❌ ห้ามใช้ "ยืนยัน" เป็น CTA จริง
- ปุ่มไม่เกิน 2 ปุ่ม

---

## 4. Button Layout

### Layout A — Double CTA
```
[ ยกเลิก (outline) ]  [ Primary Action (filled) ]
```

**ใช้เมื่อ:**
- Destructive action — **บังคับ**
- มีผลกระทบต่อผู้อื่น
- ต้องการให้พิจารณาก่อน
- Error modal ที่มี retry

### Layout B — Single CTA
```
[ ════ Primary Action (full-width) ════ ]
            ยกเลิก (text link)
```

**ใช้เมื่อ:**
- Non-destructive ทั่วไป
- Action ผู้ใช้ต้องการ ~90%+
- Success / Info ที่ dismiss ได้

---

## 5. Template สำเร็จรูป

### 5.1 Confirmation ทั่วไป ⚠️
```
Title:     [กริยา + นาม]
Body:      [ผลที่จะเกิดขึ้น]
Primary:   [กริยาเดียวกับ Title]
Secondary: ยกเลิก
Layout:    Double หรือ Single
```

**ตัวอย่าง:**
| Title | Body | Primary |
|---|---|---|
| วางขายสินค้านี้ | สินค้าจะแสดงบนหน้าขายทันที | วางขาย |
| อนุมัติสลิปนี้ | ยอดที่ต้องชำระ: 945.00 บาท | อนุมัติ |

### 5.2 Confirmation Destructive △
```
Title:     [กริยา + นาม]
Body:      [ผลที่ย้อนกลับไม่ได้ — ชัดเจน]
Primary:   [กริยาเดียวกับ Title] — สีแดง
Secondary: ยกเลิก
Layout:    Double (บังคับ)
```

**ตัวอย่าง:**
| Title | Body | Primary |
|---|---|---|
| ลบรายการนี้ | รายการนี้จะถูกลบและไม่สามารถกู้คืนได้ | ลบ |
| ยกเลิกออเดอร์นี้ | ออเดอร์นี้จะถูกยกเลิกและไม่สามารถดำเนินการต่อได้ | ยกเลิกออเดอร์ |

### 5.3 Success ✓
```
Title:    [สิ่งที่สำเร็จ]
Body:     [optional ≤1 ประโยค]
Primary:  ตกลง (dismiss) / [action] (มี next step)
Layout:   Single (dismiss) / Double (next step)
```

### 5.4 Error / Failure ✕
```
Title:    ไม่สามารถ[action]ได้
Body:     [อะไรเกิดขึ้น] + [ทำไม] + [ทำอะไรต่อ]
```

| กรณี | Primary | Secondary | Layout |
|---|---|---|---|
| Non-recoverable | ตกลง | — | Single |
| Recoverable | ลองอีกครั้ง | ยกเลิก | Double |

**Empathy Language:**
| ❌ ก่อน | ✅ หลัง |
|---|---|
| เกิดข้อผิดพลาดในการประมวลผลคำขอของท่าน | ไม่สามารถดำเนินการได้ในขณะนี้ |
| ระบบไม่สามารถ process request ได้ | เครือข่ายขัดข้อง กรุณาตรวจสอบการเชื่อมต่อ |

### 5.5 Info / Notice ℹ
```
Title:    [หัวข้อข้อมูล]
Body:     [รายละเอียดที่จำเป็น]
Primary:  รับทราบ
Layout:   Single หรือไม่มีปุ่ม
```

### 5.6 Loading ⟳
```
Title:    [optional] เช่น "กำลังดำเนินการ..."
Body:     กรุณารอสักครู่ (หรือไม่มี)
Button:   ไม่มีปุ่ม
```

---

## 6. คำมาตรฐาน

### Button Labels

| สถานการณ์ | ✅ ใช้ | ❌ ห้ามใช้ |
|---|---|---|
| Desktop / Web app | คลิก | กด, แตะ |
| Primary CTA ทั่วไป | [กริยาเฉพาะ] | ยืนยัน, โอเค |
| Secondary / dismiss | ยกเลิก | ปิด, ไม่ |
| Error non-recoverable | ตกลง | โอเค, ปิด |
| Error recoverable | ลองอีกครั้ง | Retry |
| Info / Notice | รับทราบ | โอเค, ตกลง |

### Title Patterns

| ❌ ก่อนแก้ | ✅ หลังแก้ |
|---|---|
| ยืนยันการวางขายสินค้า | วางขายสินค้านี้ |
| ยืนยันอนุมัติสลิป | อนุมัติสลิปนี้ |
| ต้องการลบรายการนี้หรือไม่? | ลบรายการนี้ |
| ยืนยันการตั้งค่า Highlight | ตั้งค่า Highlight |

---

## 7. กฎเด็ดขาด (Forbidden Patterns)

ทุกข้อ — **auto-flag เป็น Critical ก่อน implement**:

1. ❌ "ยืนยัน" เป็น CTA จริง (Figma placeholder เท่านั้น)
2. ❌ "ยืนยัน" นำหน้า Title
3. ❌ ประโยคคำถามใน Title (?)
4. ❌ ปุ่ม "โอเค" — ใช้ "ตกลง" หรือ "รับทราบ"
5. ❌ "กด" ใน Body — ใช้ "คลิก"
6. ❌ Body > 80 ตัวอักษร / > 2 บรรทัด
7. ❌ มีปุ่มเกิน 2 ปุ่ม
8. ❌ ภาษาเทคนิคใน Body ("Error 500", "null", "timeout")
9. ❌ Title ว่างเปล่า (ยกเว้น Loading)
10. ❌ สีเป็น signal เพียงอย่างเดียว — ต้องมี icon shape (WCAG 1.4.1)
11. ❌ icon △ แดง กับ action reversible
12. ❌ พหูพจน์ผสม "รายการ(s)" — ใช้ "รายการทั้งหมด" หรือ "รายการนี้"

---

## 8. Execution Workflow

### Mode A — Write new modal (default)

**Step 1: Gather context (ใช้ AskUserQuestion)**

ถามรอบเดียว 4-5 ข้อ:
- Feature name?
- Action (ผู้ใช้กำลังทำอะไร)?
- Modal type (Confirmation / Destructive / Success / Error / Info / Loading)?
- Reversible? (สำหรับ Confirmation)
- Data ที่ต้องแสดง (ถ้ามี)?

**Step 2: Apply template**

เลือก template ตาม type (§ 5.1–5.6)
- เลือก Layout (Double / Single) ตาม § 4
- เลือก Icon ตาม § 2

**Step 3: Draft copy**

Apply rules:
- Title: "กริยา + นาม", ≤40 chars, no "ยืนยัน", no "?"
- Body: ≤80 chars, ผลที่เกิดขึ้น, ไม่ตำหนิ
- Primary: mirror title verb
- Secondary: ตามตาราง

**Step 4: Self-check vs forbidden patterns (§ 7)**

Run through 12 rules — flag violations.

**Step 5: Output**

```markdown
## Modal: [feature name]

| Field | Value | Rule |
|---|---|---|
| Type | [Destructive/Confirmation/...] | § 2 |
| Icon | [⚠️/△/✓/...] | § 2 |
| Title | "..." | "กริยา + นาม" |
| Body | "..." | ≤80 chars |
| Primary | "..." | mirror title |
| Secondary | "..." | "ยกเลิก" หรือ "—" |
| Layout | Double / Single | § 4 |

✓ Passed all 12 forbidden patterns
```

---

### Mode B — Review existing modal

**Step 1: Parse input**

รับ input format:
```
Title: [...]
Body: [...]
Primary: [...]
Secondary: [...]
```

**Step 2: Apply checklist (§ 8 Original)**

Run through:
- Icon (3 checks)
- Title (4 checks)
- Body (5 checks)
- Button (6 checks)
- Tone (3 checks)

**Step 3: Output diff**

```markdown
## Review Result

### ❌ Issues found

1. [Rule violated] — "[current value]"
   → Suggested: "[fixed value]"
   Reason: [why]

### ✅ Passed

- [Rule X passed]
- [Rule Y passed]

### 📝 Final suggested copy

| Field | Original | Suggested |
|---|---|---|
| Title | "..." | "..." |
| Body | "..." | "..." |
| Primary | "..." | "..." |
| Secondary | "..." | "..." |
```

---

### Mode C — Batch (multiple modals for 1 feature)

User provides list of modal needs → output all in 1 batch.

```markdown
## Feature: [name]

### Modal 1: [action]
Type: [...]
[full output]

### Modal 2: [action]
Type: [...]
[full output]

...
```

---

## 9. Output Format Rules

- ใช้ markdown table
- Always show: Type, Icon, Title, Body, Primary, Secondary, Layout
- Always include self-check pass/fail
- Always note which rules apply (§ reference)
- ภาษาไทยล้วนใน copy (ไม่ผสม EN ยกเว้น brand name)

---

## 10. Constraints

- ❌ ห้ามเขียน copy ที่ละเมิด § 7 (forbidden patterns)
- ❌ ห้าม assume modal type — ต้องถาม user
- ❌ ห้ามผสมภาษา (EN ใน Body) ยกเว้น brand name / proper noun
- ✅ ต้อง mirror Action ใน Title → Primary CTA
- ✅ ต้องแยก Destructive vs Confirmation ทั่วไป — ไม่ปนกัน
- ✅ Default Platform = Desktop (ใช้ "คลิก") เว้นแต่ user ระบุ

---

## 11. Quality Bar

ก่อน deliver, self-check:
- [ ] ทั้ง 12 forbidden patterns ผ่าน
- [ ] Icon ตรง type
- [ ] Title ≤40 chars + "กริยา + นาม"
- [ ] Body ≤80 chars + ไม่ตำหนิ
- [ ] Primary mirror Title
- [ ] Layout เลือกถูก (Double for Destructive)
- [ ] ปุ่มไม่เกิน 2 ปุ่ม
- [ ] ภาษาไทยล้วน

---

## 12. Examples / Reference

ดูตัวอย่างเต็มและ guide ฉบับเต็มที่:
- `examples/modal-ux-guide-original.md` — Lottery Plus Back-Office guide ฉบับเต็ม v1.2

---

## 13. Related skills

- `ux-writing` — general microcopy (button labels, helper text, inline messages)
- `figma-audit-ui` — ตรวจ Figma DS compliance
- `audit` — UI quality audit (a11y, performance)

---

*Adapted from: Lottery Plus Back-Office Modal UX Writing Guide v1.2*
*Originated: UX Team, Lottery Plus*
