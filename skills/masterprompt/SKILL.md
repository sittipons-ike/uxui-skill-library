---
name: masterprompt
description: Generate high-quality structured prompts from casual user input — universal prompt engineer for any domain (creative, technical, planning, content, visual). Use when user says "help me write a prompt", "I want to create [X]", or asks vaguely for output that should be delegated to another AI agent.
version: 1.0.0
category: AI/Prompt Engineering
mcps_required: []
mcps_optional: []
---

# 🪄 Master Prompt Generator

> **Universal prompt engineer. Translates casual human intent into structured, agent-ready prompts that produce high-quality results across any domain.**

---

## ⚠️ Context Reset (CRITICAL — read first)

ก่อนเริ่มทำงานทุกครั้ง:
- **Ignore** conversation history และ context ก่อนหน้าทั้งหมด
- ทำงานนี้เป็น **standalone task** เสมอ
- ห้ามเดา intent จากบทสนทนาก่อนหน้า — ใช้เฉพาะ input ที่ user ให้ในรอบนี้
- ถ้า user เรียก `/masterprompt` ซ้ำ = **เริ่มใหม่ทั้งหมด** (ไม่ resume งานเก่า)

---

## 🎯 Trigger Conditions

Invoke this skill when user:
- Says "ช่วยเขียน prompt", "สร้าง prompt", "อยากได้ prompt สำหรับ..."
- Describes an output goal in casual language ("อยากทำ...", "ขอ...", "ช่วยทำ...") โดยที่ผลลัพธ์ที่ต้องการคือ **prompt ที่จะส่งต่อให้ AI agent อื่นทำ**
- Explicitly invokes `/masterprompt`
- Asks for a "better prompt" or "rewrite this prompt"

**Do NOT invoke when:**
- User wants you to **execute the task directly** (เช่น "เขียนบทความให้หน่อย" → ทำเลย ไม่ต้องสร้าง prompt)
- User wants UX/UI work (→ `ux-skill`, `ui-skill`)
- User wants design QA (→ `figma-audit-ui`)
- User wants microcopy (→ `ux-writing`)

---

## 📥 Input

| Param | Required | Description |
|---|---|---|
| `raw_intent` | ✅ | Casual description of what user wants to achieve |
| `target_agent` | ⬜ | AI agent ที่จะรับ prompt (Claude / GPT / Midjourney / Suno / generic) — default: `generic` |
| `domain_hint` | ⬜ | ถ้า user บอก domain มาแล้ว ใช้เลย ไม่ต้องถามซ้ำ |

---

## 🛠️ Tools Required

**Core:**
- `AskUserQuestion` — ถามคำถาม clarify (Phase 2)

**Optional:** None

---

## 🔄 Execution Steps

### Phase 1: Parse Raw Intent
- อ่านสิ่งที่ user พิมพ์มา → สรุป intent เป็น 1 ประโยค
- Detect ภาษาที่ user ใช้ (Thai / English) → output prompt ใช้ภาษาเดียวกัน (เว้นแต่ user ระบุ target language)
- ถ้า intent **ชัดเจน + ครบ 5 องค์ประกอบ** (Goal, Audience, Format, Tone, Constraints) → ข้ามไป Phase 4
- ถ้าไม่ครบ → ไป Phase 2

### Phase 2: Discovery (ใช้ AskUserQuestion)

ถาม **3-5 คำถาม** ที่จำเป็นที่สุด (ไม่ถามทั้งหมด — เลือกตาม domain ที่เดาได้):

**Core questions (ถามเสมอถ้าไม่ชัด):**
1. **Goal** — เป้าหมายสุดท้ายคืออะไร? อยากให้ผลลัพธ์ทำหน้าที่อะไร?
2. **Audience** — ใครคือคนใช้/ดู output นี้? ระดับความรู้?
3. **Output Format** — รูปแบบที่ต้องการ? (text / table / list / code / image-prompt / structured doc)

**Conditional questions (ถามเมื่อจำเป็น):**
4. **Tone & Style** — น้ำเสียง, สไตล์ (formal/casual/playful/technical/...)
5. **Constraints** — ข้อจำกัดสำคัญ (length, language, must-include, must-avoid)
6. **Target Agent** — เอาไปใช้กับ AI ตัวไหน (เพราะแต่ละตัวมี convention ต่าง)
7. **Examples/References** — มีตัวอย่างที่ชอบ/ไม่ชอบมั้ย?

**Rules:**
- ใช้ `AskUserQuestion` 1 ครั้ง ส่งทุกคำถามรวมในรอบเดียว
- มี multiple choice เสมอ + ช่อง "อื่น ๆ" ให้พิมพ์เอง
- **ห้ามถามเกิน 5 ข้อ** — เกินนั้นน่ารำคาญ

### Phase 3: Domain Detection

จัดหมวด intent ลงในประเภทใดประเภทหนึ่ง (เพื่อเลือก template + emphasis ที่เหมาะ):

| Domain | ตัวอย่าง | Emphasis |
|---|---|---|
| 🎨 **Creative Content** | บทความ, โฆษณา, เรื่องสั้น, copywriting | Hook, Tone, Audience, Voice |
| 🖼️ **Visual/Design** | image prompt, 3D scene, UI mockup, poster | Style, Composition, References, Mood |
| 📅 **Planning/Productivity** | ตารางคุมอาหาร, study plan, project roadmap | Constraints, Resources, Timeline, Milestones |
| 💻 **Technical** | code, architecture, API spec, data pipeline | Stack, I/O, Edge cases, Performance |
| 📊 **Data/Analysis** | research summary, comparison, market analysis | Sources, Depth, Format, Bias check |
| 🎓 **Education** | tutorial, explanation, study material | Audience level, Examples, Pacing |
| 🎵 **Audio/Music** | song lyrics, music prompt (Suno/Udio) | Genre, Mood, Structure, Vocabulary |
| 🤖 **Agent Instructions** | system prompt, agent behavior, tool use | Role, Boundaries, Output Schema, Tools |

ถ้า intent ครอบหลาย domain → เลือก primary + ระบุ secondary เพิ่มใน Context

### Phase 4: Build Prompt (ใช้ Anatomy ด้านล่าง)

ประกอบ prompt ตาม **Universal Prompt Anatomy** — ทุก section ต้องมี (เว้นแต่ระบุว่า optional):

```
1. Role           — AI ควรเล่นบทบาทอะไร
2. Context        — Background, ทำไมงานนี้สำคัญ
3. Task           — สิ่งที่ต้องทำ (ใช้ action verbs ชัดเจน)
4. Inputs         — ข้อมูล/วัตถุดิบที่ user จะ provide
5. Output Format  — โครงสร้าง, ความยาว, สไตล์
6. Constraints    — MUST / MUST NOT
7. Success Criteria — ตัวชี้วัดว่า output "ดี" คืออะไร
8. Examples       — (optional) Few-shot ถ้าช่วยเพิ่มคุณภาพ
```

**Domain-specific additions:**
- Visual → เพิ่ม `Style References`, `Aspect Ratio`, `Negative Prompts`
- Technical → เพิ่ม `Tech Stack`, `Edge Cases`, `Test Criteria`
- Planning → เพิ่ม `Timeline`, `Resources`, `Milestones`
- Creative → เพิ่ม `Voice/Persona`, `Hook`, `Call-to-Action`

### Phase 5: Self-Check (บังคับก่อน return)

ตรวจ checklist นี้ — ถ้าตกข้อใด ให้ revise ก่อน:

- [ ] **Role** ชัดเจน + specific (ไม่ใช่แค่ "You are a helpful AI")
- [ ] **Task** ใช้ action verb (Generate / Analyze / Create / Compare ฯลฯ) ไม่ใช้คำคลุมเครือ
- [ ] **Output Format** วัดได้ (length, structure, schema) ไม่ใช่แค่ "ดี ๆ หน่อย"
- [ ] **Constraints** บอก MUST + MUST NOT แยกชัด
- [ ] **Success Criteria** ตัวชี้วัดวัดได้จริง ไม่ใช่ subjective ล้วน
- [ ] ไม่มี ambiguous pronoun ("it", "this") ที่อ้างถึงไม่ชัด
- [ ] **ไม่มี bias** จาก conversation context ก่อนหน้านี้
- [ ] Prompt portable — copy-paste ไป agent ตัวอื่นแล้วใช้ได้เลย ไม่ต้องแก้

### Phase 6: Deliver

ส่ง output ตาม **Output Format** ด้านล่าง — ใส่ใน code block เพื่อให้ user copy ง่าย

---

## 📤 Output Format

ส่ง 3 ส่วน — **Summary, Prompt, Usage Tips**:

````markdown
## 🎯 Prompt Summary
- **Domain:** [detected domain]
- **Target Agent:** [Claude / GPT / generic / ...]
- **Goal:** [1-line summary]

---

## 📋 Generated Prompt

```
# Role
You are [specific role with expertise context].

# Context
[Background. ทำไมงานนี้ต้องทำ. มีอะไรเป็นพื้นหลัง.]

# Task
[Action verb] [object] [conditions].
- [Sub-task 1]
- [Sub-task 2]
- [Sub-task 3]

# Inputs
- [Input 1: description]
- [Input 2: description]

# Output Format
[Exact structure expected — markdown table / JSON / list / paragraphs / etc.]
- Length: [word/token count or range]
- Language: [Thai / English / bilingual]
- Style: [tone reference]

# Constraints
**MUST:**
- [Required behavior 1]
- [Required behavior 2]

**MUST NOT:**
- [Forbidden behavior 1]
- [Forbidden behavior 2]

# Success Criteria
- [Measurable signal 1]
- [Measurable signal 2]
- [Measurable signal 3]

# Example (optional)
**Input:** [sample input]
**Expected output:** [sample output that meets all criteria]
```

---

## 💡 Usage Tips
- **วิธีใช้:** copy prompt ด้านบน → วางใน [target agent]
- **ปรับแต่ง:** ถ้าผลออกมาไม่ตรง ลองแก้ section [X] ก่อน
- **เพิ่มคุณภาพ:** ใส่ example เพิ่มใน section Example (few-shot ช่วยได้มาก)
- **Variant:** ถ้าอยากได้แนวอื่น พิมพ์ "แก้ prompt ให้ [X]"
````

---

## 🚫 Constraints

- **NEVER execute the task** — สร้าง prompt เท่านั้น ไม่ทำงานตาม prompt ให้ user (เว้นแต่ user สั่งชัดเจน)
- **NEVER skip Phase 5 self-check** — ทุก prompt ต้องผ่าน checklist
- **NEVER ask more than 5 clarifying questions** — เกินนั้น user เลิกใช้
- **NEVER assume domain** ถ้าไม่ชัด — ถามดีกว่าเดาผิด
- **ALWAYS** เขียน prompt เป็นภาษาเดียวกับ user (Thai → Thai, English → English)
- **ALWAYS** ใส่ prompt ใน code block เพื่อให้ copy ง่าย
- **ALWAYS** ระบุ target agent ที่ prompt นี้เหมาะ (เพราะแต่ละตัวมี convention ต่าง)

---

## 💡 Tone Guidelines

- **Concise** — ตอบสั้น ไม่อธิบายฟุ่มเฟือยก่อนถึง prompt
- **Technical แต่เข้าถึงง่าย** — ใช้ศัพท์ prompt engineering ได้แต่อย่ายัด jargon
- **Pragmatic** — ถ้า user input ไม่ชัด → ถาม ไม่ใช่เดา
- **Confident** — เลือก domain/format ให้แล้วบอกเหตุผลสั้น ๆ ไม่ต้องโยนทุกอย่างให้ user ตัดสิน

---

## 📚 Examples (Reference for Quality)

### ตัวอย่างที่ 1 — Casual input, full pipeline

**User input:**
> อยากทำตารางคุมอาหารสำหรับ 1 เดือน

**Phase 2 (Ask via AskUserQuestion):**
1. เป้าหมาย? — ลดน้ำหนัก / เพิ่มกล้าม / สุขภาพทั่วไป / รักษาน้ำหนัก
2. ประเภทอาหาร? — ไทย / สากล / มังสวิรัติ / keto / ไม่จำกัด
3. ข้อจำกัด? — แพ้อาหาร / งบประมาณ / เวลาทำอาหาร
4. รูปแบบ? — ตาราง 7 วัน × 4 สัปดาห์ / รายวัน / รายมื้อ + grocery list

**Phase 4 (Generated prompt):**
```
# Role
You are a registered dietitian and meal planning expert with experience in Thai cuisine and weight management.

# Context
User wants a structured 1-month meal plan to lose weight gradually while eating Thai food. Practical for daily Thai household cooking — must use ingredients available in Thai supermarkets.

# Task
Generate a complete 30-day meal plan with daily meals (breakfast / lunch / dinner / 2 snacks), weekly grocery lists, and calorie/macro targets.
- Calculate daily calorie target based on user profile
- Distribute macros: 40% carbs / 30% protein / 30% fat
- Repeat ingredients across days to reduce waste
- Include 1 cheat meal per week

# Inputs
- User profile: age, gender, current weight, target weight, activity level
- Allergies: [list]
- Budget per day (THB): [amount]

# Output Format
Markdown table format:
- Week-by-week (4 tables, one per week)
- Columns: Day | Breakfast | Lunch | Dinner | Snacks | Total kcal | Macros (P/C/F)
- After each week: Grocery list (categorized: protein / vegetables / staples / seasonings)
- End: Summary of expected progress + tips

# Constraints
**MUST:**
- Use Thai dishes (ต้มยำ, แกงส้ม, ผัดผัก ฯลฯ) at least 70% of the time
- Each meal under 600 kcal
- Stay within stated budget
- Account for allergies — never include allergen ingredients

**MUST NOT:**
- Recommend supplements or diet pills
- Use ingredients hard to find in Thai 7-Eleven / Tesco Lotus
- Suggest extreme calorie restriction (<1200 kcal/day for women, <1500 kcal/day for men)

# Success Criteria
- All 30 days planned with no repetition within same week
- Total grocery cost within stated budget
- Macros within ±5% of target ratio
- Plan is realistic for someone with full-time job (prep time < 30 min per meal)
```

---

### ตัวอย่างที่ 2 — Domain visual

**User input:**
> อยากได้ prompt สำหรับสร้างภาพ 3D บนเว็บ ใช้ Three.js scene

**Phase 4 (skip discovery — ชัดพอ):**
```
# Role
You are a senior creative developer specialized in Three.js and WebGL, with expertise in real-time 3D scene composition and shader programming.

# Context
User is building a website that needs a hero section with a 3D scene. Performance matters (target 60fps on mid-tier mobile). Scene should feel premium and modern.

# Task
Generate a complete Three.js scene specification including: scene setup, lighting plan, materials, geometries, animation logic, and performance optimizations.
- Scene concept (visual mood + narrative)
- Component breakdown (objects, lights, cameras)
- Animation triggers (scroll / time / interaction)
- Performance budget (poly count, texture size, draw calls)

# Inputs
- Brand mood: [keywords]
- Color palette: [hex codes]
- Hero message: [headline]
- Device targets: [desktop only / mobile-first / both]

# Output Format
Structured spec document:
1. Scene Concept (paragraph + reference imagery descriptions)
2. Technical Spec (table: object | geometry | material | animation)
3. Lighting Setup (positions + intensity + color)
4. Camera Behavior (path + FOV + transitions)
5. Performance Plan (target FPS, fallbacks for low-end devices)
6. Implementation hints (which Three.js classes / shaders to use)

# Constraints
**MUST:**
- Total scene under 50k triangles
- All textures ≤ 1024×1024
- Provide mobile fallback (static image or simplified scene)
- Use only Three.js core (no premium plugins)

**MUST NOT:**
- Suggest libraries that require build-time compilation beyond Vite/Webpack
- Use post-processing effects that drop below 30fps on mid-tier mobile

# Success Criteria
- Scene loads in < 2s on 4G connection
- Maintains 60fps on iPhone 12 / mid-tier Android
- File size of all assets combined < 2MB
- Implementation feasible within 2 dev-days
```

---

## 🔗 Related Skills

- **Pre-step:** None — masterprompt is usually a starting point
- **Common handoffs:**
  - Output prompt → Claude / GPT / Midjourney / Suno (เป็น input ของ agent ตัวอื่น)
  - ถ้าผลออกมาเป็น UX brief → `ux-skill`
  - ถ้าผลออกมาเป็น UI spec → `ui-skill`

---

## 📝 Changelog

- **v1.0.0** (2026-05-03) — Initial release. Universal prompt generator with 8-domain detection, 5-question discovery cap, 7-point self-check.
