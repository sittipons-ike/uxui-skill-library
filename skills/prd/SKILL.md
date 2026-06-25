---
name: prd
description: 'Generate high-quality Product Requirements Documents (PRDs) for software systems and AI-powered features. Phase 0 auto-scans docs/intent/, docs/brand/, docs/product/ for existing context — skips already-answered questions, only asks on gaps. Cites sources in the final PRD. Includes executive summaries, user stories, technical specifications, and risk analysis. Chains downstream from interview-me (intent) and upstream to ux-strategist / design-builder.'
license: MIT
version: 2.0.0
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

### Phase 0: Scan Existing Context (v2.0 — REQUIRED before Phase 1)

**Before AskUserQuestion**, scan project for existing docs that may have already answered some questions.

#### Step 0.1 — Scan directories (priority order)

| Folder / file | What it likely answers |
|---|---|
| `docs/intent/<topic>.md` | problem, success, user, constraint (highest priority — from interview-me) |
| `docs/product/product-overview.md` | user, value prop, features, positioning |
| `docs/brand/brand-book.md` | target audience, voice, brand-level constraint |
| `BRAND.md` / `PRODUCT.md` / `README.md` (root) | fallback if no docs/ folder |

If nothing found → skip to Phase 1 (full AskUserQuestion).

#### Step 0.2 — Map doc coverage to Phase 1 questions

3 questions Phase 1 asks:
| Q | Likely doc source | Action if doc answers |
|---|---|---|
| **Q1 ปัญหาหลัก** | intent.md (WHY/SUCCESS), product-overview (problem) | skip Q1, cite source |
| **Q2 KPI** | intent.md (SUCCESS), product-overview (metrics) | usually missing → ask anyway, but pre-fill default from doc |
| **Q3 Target audience** | always asked — user-specific (stakeholder/dev/AI agent) — never in doc | always ask |

#### Step 0.3 — Build reduced AskUserQuestion

After scan:
- If Q1 + Q2 both resolved by docs → ask only Q3 (1 question)
- If Q1 resolved, Q2 partial → ask Q2 + Q3 (2 questions)
- If nothing → full Phase 1 (3 questions)

**Show user what was found before asking:**
```
PHASE 0 SCAN RESULTS:
  ✓ docs/intent/checkout-revamp.md (created 2026-06-20)
    → problem: cart abandonment 40%, success: <25% within Q3
  ✓ docs/product/product-overview.md
    → user: returning customers, value: faster checkout

Skipping Q1 + Q2 (answered by docs above).
Q3 only:
```

#### Step 0.4 — Conflict / staleness

- If doc says X but user statement contradicts → **flag + ask clarify** before proceeding
- If doc older than 3 months → confirm explicitly: "doc บอก X. ยังใช่มั้ย?"

#### Step 0.5 — Source attribution in final PRD

Every section in the output PRD must cite where its info came from:
- `[source: docs/intent/<topic>.md]`
- `[source: docs/product/product-overview.md]`
- `[source: user — Phase 1 interview]`

→ Audit trail: PR reviewer / stakeholder รู้ว่าอะไรมาจากไหน

---

### Phase 1: Discovery (ใช้ AskUserQuestion — only on gaps)

**MUST** ใช้ `AskUserQuestion` tool ถามรอบเดียว — แต่ **ถามเฉพาะคำถามที่ Phase 0 ยังไม่ resolved**

คำถามเต็ม (ถ้า doc ไม่ตอบเลย):

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
