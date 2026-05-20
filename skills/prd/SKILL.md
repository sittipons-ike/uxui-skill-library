---
name: prd
description: 'Generate high-quality Product Requirements Documents (PRDs) for software systems and AI-powered features. Includes executive summaries, user stories, technical specifications, and risk analysis.'
license: MIT
---

# Product Requirements Document (PRD)

## Overview

Design comprehensive, production-grade PRDs that bridge the gap between business vision and technical execution. เหมาะสำหรับ designer ที่ต้องการ brief ส่งให้ dev, present ต่อ stakeholder, หรือส่งต่อให้ AI agent ทำงานต่อ

## When to Use

Use this skill when:

- Starting a new product or feature development cycle
- Translating a vague idea into a concrete technical specification
- User asks to "write a PRD", "document requirements", or "plan a feature"

---

## Operational Workflow

### Phase 1: Discovery (ใช้ AskUserQuestion)

**MUST** ใช้ `AskUserQuestion` tool ถามรอบเดียว 3 คำถามพร้อมกัน — ห้ามถามทีละข้อ ห้ามเดา

คำถามที่ต้องถาม:

1. **ปัญหาหลัก** — user ติด friction ตรงไหน? หรืออยากได้ feature อะไร?
   - ให้ user พิมพ์เอง (free text)

2. **วัดความสำเร็จด้วยอะไร** — KPI ที่สำคัญที่สุด?
   - Options: Activation rate / Retention / Conversion rate / Revenue / NPS / อื่นๆ (multiSelect: true)

3. **Target — PRD นี้จะใช้กับใคร?** (กำหนด output format)
   - Option A: **เสนอ Stakeholder / ผู้บริหาร** → ภาษาอ่านง่าย, executive summary ขึ้นก่อน, ไม่เน้น technical
   - Option B: **ส่งให้ทีม Dev / Designer** → technical specs ละเอียด, user stories + acceptance criteria ครบ
   - Option C: **ส่งให้ AI Agent ทำงานต่อ** → structured Markdown เน้น machine-readable, no fluff, หัวข้อชัด

### Phase 2: Analysis & Scoping

Synthesize input → Map user flow → Define non-goals

### Phase 3: Output ตาม Target

---

## Output Schema ตาม Target

### 🎯 Target A — เสนอ Stakeholder / ผู้บริหาร

เน้น: ภาษาเข้าใจง่าย, ทำไมถึงสำคัญ, ผลลัพธ์ทางธุรกิจ

```
1. Executive Summary (ขึ้นก่อน — อ่านอย่างเดียวก็เข้าใจ)
   - ปัญหา → วิธีแก้ → ผลที่คาดหวัง (ตัวเลขชัด)
2. ทำไมต้องทำตอนนี้?
3. User คือใคร และได้ประโยชน์อะไร
4. สิ่งที่จะไม่ทำ (Non-goals)
5. Roadmap ภาพรวม (MVP → v1.1 → v2.0)
6. ความเสี่ยงหลัก (ไม่เกิน 3 ข้อ)
```

ภาษา: ไทยเป็นหลัก, ตัดศัพท์ technical ที่ไม่จำเป็น

---

### 🛠️ Target B — ส่งให้ทีม Dev / Designer

เน้น: User stories + AC ครบ, technical specs, integration points

```
1. Executive Summary (สั้น)
2. User Personas & User Stories
   - As a [user], I want [action] so that [benefit]
   - Acceptance Criteria แต่ละ story
3. Non-Goals
4. Technical Specifications
   - Architecture overview
   - Integration points (APIs, DB, Auth)
   - Security & Privacy
5. Risks & Roadmap (Phased)
```

ภาษา: ผสม Thai/English, technical terms ใช้ English

---

### 🤖 Target C — ส่งให้ AI Agent ทำงานต่อ

เน้น: Structured Markdown, machine-readable, ไม่มี prose ที่ไม่จำเป็น

```markdown
## CONTEXT
- Problem: [1 sentence]
- Solution: [1 sentence]
- Success metric: [measurable]

## USER
- Persona: [role + pain point]
- Primary flow: [step 1 → step 2 → ...]

## REQUIREMENTS
### Functional
- [ ] REQ-001: [requirement]
- [ ] REQ-002: [requirement]

### Non-functional
- Performance: [measurable]
- Security: [measurable]

## CONSTRAINTS
- Must: [...]
- Must not: [...]
- TBD: [...]

## OUT OF SCOPE
- [item]

## RISKS
| Risk | Impact | Mitigation |
|---|---|---|
```

ภาษา: English ล้วน, ไม่มีคำอธิบายซ้ำซ้อน

---

## Quality Standards

ใช้เกณฑ์ที่วัดได้ — ห้ามใช้คำ "fast", "easy", "intuitive"

```diff
- The UI must be easy to use.
+ Onboarding completion rate >= 70% ใน user testing 20 คน
```

---

## Implementation Guidelines

**DO:**
- ใช้ `AskUserQuestion` รอบเดียว ส่งทุกคำถามพร้อมกัน
- ปรับ output ตาม Target ที่เลือก — ห้ามใช้ schema เดียวกับทุก target
- ตัวเลข KPI ต้องมี baseline เปรียบเทียบเสมอ

**DON'T:**
- ห้ามเขียน PRD ก่อนได้รับคำตอบ Phase 1
- ห้าม hallucinate tech stack — ถ้าไม่รู้ใส่ `TBD`
- ห้ามถาม follow-up ทีละข้อหลังจาก AskUserQuestion แล้ว — เขียน draft แล้วค่อยถามรอบ 2 ถ้าจำเป็น
