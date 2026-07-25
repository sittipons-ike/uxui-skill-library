# Design System — โครงสร้าง & Naming (คู่มือทีม)

> คู่มือกลางว่า **เราจัด Design System ยังไง** และ **ตั้งชื่อ token / component ยังไง เพราะอะไร**
> อ่านครั้งเดียวเข้าใจตั้งแต่ token ดิบ → ประกอบเป็นหน้าจริง
>
> - **Agent อ่าน:** ไฟล์ `.md` นี้ (โครงสร้างชัด grep ได้)
> - **Human อ่าน:** copy ไป Lark Wiki
> - Owner: design@7solutions.co.th · อ้างอิงกฎเต็มที่ [`skills/design-builder/NAMING.md`](../skills/design-builder/NAMING.md)

---

## สารบัญ

1. [ภาพรวม — 3 ชั้น + ส่งเป็น CSS 2-tier](#1-ภาพรวม)
2. [แหล่งอ้างอิง — แต่ละชั้นยืมมาจากไหน](#2-แหล่งอ้างอิง)
3. [Naming — แต่ละชั้นเขียนยังไง เพราะอะไร](#3-naming)
4. [ประกอบ UI — atom → pattern → page](#4-ประกอบ-ui)
5. [spec ↔ dev — vocabulary เดียวกัน](#5-spec--dev)
6. [ที่มาของแนวคิด (references & credits)](#6-ที่มาของแนวคิด)
7. [Cheat sheet](#7-cheat-sheet)

---

## 1. ภาพรวม

### คิดเป็นชั้นๆ — 3 conceptual layers

ไล่จาก "ค่าดิบ" → "มีความหมาย" → "ใช้กับ component จริง"

| ชั้น | คือ | ตัวอย่าง | ไฟล์ |
|---|---|---|---|
| **Primitive** | ค่าดิบล้วนๆ ยังไม่บอกว่าใช้ทำอะไร | `#ef4444`, `16px` | `design.md` |
| **Semantic** | ใส่ความหมาย บอก "ใช้ตอนไหน" | `primary`, `error`, `spacing.md` | `design.md` |
| **Component** | ผูกกับของจริง (ปุ่ม/ช่องกรอก) ว่าดึงค่าจาก semantic อันไหน | `button.background` | `components.json` |

> 💡 **ทำไมแยกชั้น:** เปลี่ยนสีแบรนด์แค่จุดเดียวที่ชั้นล่าง → ทุกอย่างข้างบนเปลี่ยนตามเอง ไม่ต้องไล่แก้ทีละหน้า

### ตอนส่งเป็น CSS จริง = ใช้ตัวแปร 2 ชุด (2-tier)

```
--sys-*   = ชั้น Semantic (cross-component intent)
--comp-*  = ชั้น Component (per-component alias → ชี้ไป --sys-*)
```

```css
:root {
  /* TIER 1 — sys (semantic) */
  --sys-color-primary: #3B82F6;

  /* TIER 2 — comp (per-component alias → sys) */
  --btn-background: var(--sys-color-primary);
}
```

> 💡 **ทำไม 2-tier:** Dark mode / rebrand แก้แค่ `--sys-*` ชุดเดียว → ปุ่ม/การ์ดทั้งระบบเปลี่ยนตาม ไม่ต้องแตะ component ทีละตัว

**หมายเหตุ:** Primitive **ไม่มี tier ของตัวเองใน CSS** — ค่า primitive ถูก resolve (อบ) เข้าไปใน `--sys-*` ตอน build แล้ว ไม่มีใครดึงตรงๆ ตอน runtime

---

## 2. แหล่งอ้างอิง

**เราไม่ได้คิดเอง** — แต่ละชั้นยืมมาจาก design system / มาตรฐานระดับโลก เพื่อให้ dev คุ้นเคย + tool รองรับ + ไม่ต้องสอนใหม่

| สิ่งที่ยืมมา | จากไหน |
|---|---|
| สี Primitive (ชื่อ + ค่า hex เป๊ะ เช่น `red.500`) | **Tailwind v3.4+ palette** |
| ขนาด (spacing / radius / type) แบบ t-shirt (`xs/sm/md/lg`) | convention สากล (Tailwind ก็ใช้) |
| โครง 2-tier (`--sys` / `--comp`) | **Material 3** (Google) + **IBM Carbon** |
| Component props (`background`/`foreground`/`border`/`shadow`/`ring`) | **shadcn/ui** — เติมช่องที่ shadcn ไม่มี (`shadow`) ด้วย **W3C DTCG** |
| รูปแบบ ref `{a.b.c}` (brace + dot path) | **W3C DTCG** (มาตรฐาน design token กลาง) |
| คำศัพท์ variant / state / scale / mode | **Nathan Curtis — "Naming Tokens in Design Systems"** |
| ชั้น atom / molecule / organism | **Brad Frost — Atomic Design** |

> รายละเอียดที่มาแต่ละอัน ดู [§6 ที่มาของแนวคิด](#6-ที่มาของแนวคิด)

---

## 3. Naming

### กฎกลาง (ทุกชั้นใช้เหมือนกัน)

- **kebab-case** สำหรับคำที่มีหลายคำ → `line-height`, `border-width`, `on-primary` (ห้าม `lineHeight`, `line_height`)
- คำเดียว → เขียนเปล่า → `red`, `spacing`, `size`
- **path คั่นด้วยจุด `.`** + ครอบ `{}` เสมอในเนื้อหา → `{semantic.colors.primary.default}`
- เริ่มจาก root เสมอ (`primitive.*` / `semantic.*` / `component.*`) ไม่มี partial path
- **ห้าม:** slash `/`, snake_case, มิกซ์ numeric กับ t-shirt ข้ามชั้น

### `.` กับ `-` — คนละหน้าที่ (จุดที่สับสนบ่อย)

| สัญลักษณ์ | หน้าที่ | เทียบ |
|---|---|---|
| `.` จุด | คั่น **ระดับชั้น** (segment) | เหมือน `/` ใน path |
| `-` ขีด (kebab) | คั่น **คำในชั้นเดียว** (compound word) | เหมือนช่องว่างในประโยค |

```
{ semantic . colors . text . on-primary }
  └──────┬──────────────────┘  └───┬──┘
      คั่นชั้นด้วย .            คำใน 1 ชั้นถ้ามีหลายคำ → kebab -
```

`kebab` โผล่เมื่อ **ชั้นไหนมี 2+ คำ**:
```
{semantic.colors.text.on-primary}                          ← on-primary
{component.molecule.form-field.error.background.rest}       ← form-field
key ที่มี 2 คำ:  line-height · border-width · text-style
```

### แต่ละชั้นเขียนยังไง + เพราะอะไร

**Primitive → ใช้ตัวเลข**
```
{primitive.colors.red.500}   ·   {primitive.spacing.16}
```
> เพราะ: ค่าดิบไม่มีความหมาย — เลขบอกแค่ "คืออะไร" (ตำแหน่งบนแถบสี / ค่า px)

**Semantic → ใช้ t-shirt**
```
{semantic.spacing.md}   ·   {semantic.radius.pill}   ·   {semantic.colors.primary.default}
```
allowed stops: `2xs, xs, sm, md, lg, xl, 2xl, 3xl … 9xl` + special: `pill, full, none`
> เพราะ: บอก "ใช้ยังไง" — เปลี่ยนค่าจริงข้างหลังได้โดยไม่ต้องเปลี่ยนชื่อ

**Component → path เต็ม**
```
{component.atom.button.primary.background.rest}
ลำดับ:  component → tier → name → variant → prop → state
```
> เพราะ: ครอบทุกมิติของ component ไว้ในชื่อเดียว หา/แก้ง่าย

### Canonical vocabulary (คำที่อนุญาต — ห้ามคิดเอง)

| หมวด | คำที่ใช้ได้ |
|---|---|
| **variants** (5) | `primary, secondary, tertiary, ghost, destructive` |
| **states** (7) | `rest, hover, active, focus, disabled, selected, error` |
| **props** (5) | `background, foreground, border, shadow, ring` |
| **breakpoints** (7, mobile-first default) | `2xs, xs, sm, md, lg, xl, 2xl` |

**Escape valve:** variant นอกลิสต์ให้ใส่ใน `variant-extensions` (ต้องมี `reason` + `expires` + `extends`) — กัน variant สะเปะสะปะแบบที่เจอในโปรเจกต์จริง

---

## 4. ประกอบ UI

ลำดับการประกอบของระบบเรา (ไต่ทีละชั้น เอาชั้นล่างมาต่อเป็นชั้นบน):

```
atom → molecule → organism → pattern → page
```

> 📌 **หมายเหตุการอ่าน:** รายการข้างล่างคือ "จักรวาลของสิ่งที่พบทั่วไป" ในแต่ละชั้น — ไม่ใช่ทุกอันถูก build แล้ว
> ⭐ = อยู่ใน **default scope** ที่ `design-component-builder` สร้างให้ทันที (button, input, select, checkbox, radio, textarea, label, card, badge)
> ตัวที่เหลือ = เพิ่มได้ตามต้องการ (สั่ง `--scope`) หรือเป็น reference ว่าควรจัดชั้นไหน
> ตัวอย่างรวบรวมจากของจริง 2 library: **shadcn/ui** (74 components) + **Astryx** (Meta) — แล้วจัดชั้นตามระบบเรา (บาง lib จัดต่างจากเรา เช่น Astryx วาง `App Shell` ไว้หมวด Layout แต่เราจัดเป็น **Pattern**)

### 🔹 Atom — ชิ้นเล็กสุด แยกไม่ได้ (`components.json`)

แยกแล้วไม่มีความหมาย / ไม่ทำงานเดี่ยวๆ ต่อไม่ได้อีก

| หมวด | ตัวอย่าง |
|---|---|
| **Form controls** | ⭐`button` · ⭐`input`/`text-input` · ⭐`textarea` · ⭐`select`/`selector` · ⭐`checkbox` · ⭐`radio` · ⭐`label` · `toggle`/`switch` · `slider` · `icon-button` · `toggle-button` · `number-input` · `date-input` · `time-input` · `file-input` |
| **Display** | `text`/`typography` · `heading` · `icon` · `image`/`thumbnail` · `avatar` · ⭐`badge` · `tag`/`chip`/`token` · `divider`/`separator` · `kbd` · `code` · `blockquote` · `citation` · `timestamp` · `status-dot` |
| **Feedback (เดี่ยว)** | `spinner`/`loader` · `progress-bar` · `skeleton` · `status-dot` · `banner` |
| **Navigation (เดี่ยว)** | `link` · `anchor` |
| **Container เดี่ยว** | ⭐`card` · `clickable-card` · `selectable-card` (แบบ simple — ถ้ามี header/body/footer slot → เลื่อนขึ้น molecule/organism) |

### 🔸 Molecule — atom หลายตัวประกอบ

atom ≥2 ตัวทำงานร่วมกันเป็นหน่วยเล็กที่มีหน้าที่เดียว

| หมวด | ตัวอย่าง |
|---|---|
| **Form** | `form-field`/`field` (label+input+help) · `input-group` · `checkbox-group` · `radio-group`/`radio-list` · `button-group` · `search-bar`/`power-search` · `date-picker` · `date-range-input` · `date-time-input` · `stepper`/`number-input` · `rating` · `tag-input`/`tokenizer` · `multi-selector` · `typeahead` · `file-upload` |
| **Navigation** | `nav-item` · `breadcrumb-item` · `menu-item`/`typeahead-item` · `tab-item` · `pagination-item` · `dropdown`/`dropdown-menu` · `segmented-control` · `more-menu` · `outline` |
| **Display** | `stat-tile`/`metric` · `list-item` · `media-object` (avatar+text) · `avatar-group` · `key-value`/`metadata` · `code-block` · `thumbnail` |
| **Feedback** | `alert`/`banner` (icon+text+close) · `toast` · `tooltip` · `popover` · `hover-card` |
| **Interactive เล็ก** | `accordion-item` · `collapsible` · `switch-field` (label+toggle) · `segmented-control` · `command-item` |

### 🔷 Organism — molecule (+ atom) ประกอบเป็นส่วนใหญ่ของหน้า

ส่วนที่ยืนได้ด้วยตัวเอง มักกินพื้นที่ใหญ่ในหน้า

| หมวด | ตัวอย่าง |
|---|---|
| **Layout ส่วนหลัก** | `navbar`/`top-nav` · `sidebar`/`side-nav` · `header` · `footer` · `toolbar` · `mega-menu` (top-nav-mega-menu) |
| **Data / list** | `table`/`data-table` · `list` · `card-grid` · `feed` · `kanban-board` · `tree-list` · `overflow-list` · `metadata-list` |
| **Content block** | `hero` · `pricing-table` · `feature-grid` · `carousel` · `testimonial-block` · `stats-row` |
| **Overlay / interactive** | `modal`/`dialog` · `drawer`/`sheet` · `tabs`/`tab-list` · `accordion` · `dropdown-panel` · `command-palette` · `lightbox` · `context-menu` · `menubar` · `navigation-menu` |
| **Composite** | `form`/`form-layout` (เต็ม) · `filter-panel` · `search-results` · `comment-thread` · `notification-center` · `pagination` (เต็ม) · `breadcrumb` (เต็ม) · `chat` (chat-layout / composer / message) |

### 🛠️ Utility / Layout helper — ตัวช่วยจัดวาง (ไม่ใช่ UI element)

ไม่มีหน้าตาของตัวเอง ทำหน้าที่เชิงเทคนิค (คุมสัดส่วน / scroll / grid) — **ไม่มี variant/state แบบ atom** เลยแยกออกมา ไม่ปนกับ component ปกติ

| helper | `aspect-ratio` · `scroll-area` · `resizable`/`resize-handle` · `grid` · `section` · `layout` · `visually-hidden` · `direction` (RTL/LTR) |
|---|---|

โยงกับ naming — ระดับอยู่ใน path:
```
{component.atom.button.primary.background.rest}
{component.molecule.form-field.error.background.rest}
{component.organism.navbar.default.background.rest}
```

### 🟪 Pattern — โครง reusable ข้ามหน้า (`patterns.json`)

โครง layout ที่ไม่ผูกหน้าไหน มี **slot** (ช่องว่าง) ให้แต่ละหน้ามาเสียบ content — ต่างจาก organism ตรงมันคือ "โครงของทั้งหน้า/ส่วนใหญ่ของหน้า" ที่หลายหน้าใช้ซ้ำ

| หมวด | ตัวอย่าง |
|---|---|
| **Shell (โครงทั้งแอป)** | `app-shell` (header+sidebar+main) · `dashboard-layout` · `settings-layout` · `docs-layout` · `chat-layout` |
| **Auth / focused** | `auth-split` (form ซ้าย + ภาพขวา) · `centered-card` (login กลางจอ) · `wizard`/`stepper-flow` |
| **Content layout** | `hero-grid` · `feed-layout` · `master-detail`/`list-detail` · `split-view` · `two-column` · `landing-section` |
| **State (โครงหน้าพิเศษ)** | `empty-state` · `error-state` · `loading-state` · `onboarding-flow` |
| **Overlay shell** | `modal-shell` · `drawer-shell` |

- slot เสียบได้: `component` · `section` · `pattern` (ซ้อน) · `text` · `image` · `icon`

### 🟩 Page — หน้าจริง (`ui.json`)

เอา pattern + component มาประกอบเป็นหน้า แล้วเสียบของลง slot — คือสิ่งที่ user เห็นจริง

| หมวด | ตัวอย่าง |
|---|---|
| **Auth** | `login` · `signup` · `forgot-password` · `reset-password` · `verify-otp` |
| **App หลัก** | `dashboard` · `home`/`landing` · `profile` · `settings` · `notifications` |
| **List / detail** | `index`/`list-page` · `detail-page` · `search-results` · `filter-results` |
| **Flow** | `checkout` · `onboarding` · `wizard-step` |
| **System** | `404`/`not-found` · `error`/`500` · `maintenance` · `help`/`support` · `empty` |

### flow จริง (pattern + slot)

```
patterns.json:  app-shell  (slot: header / sidebar / main)   ← โครงว่าง
                   │
                   ↓ pages เสียบ content ลง slot
ui.json:  dashboard  → ใช้ app-shell + เสียบ navbar / เมนู / 📊 กราฟ
          home       → ใช้ app-shell ตัวเดียวกัน + เสียบ navbar / เมนู / 📰 feed
```

ภาพช่อง slot (app-shell):
```
┌─────────────────────────┐
│  [ slot: header ]       │   ← ทุกหน้าเสียบ navbar เหมือนกัน
├──────┬──────────────────┤
│ slot │  [ slot: main ]  │   ← header + sidebar เหมือนทุกหน้า
│ side │                  │      ต่างแค่ของที่เสียบลง main
└──────┴──────────────────┘
```

> 💡 **ทำไม:** `app-shell` ตัวเดียว ทุกหน้าใช้ซ้ำ — แก้โครง/sidebar ครั้งเดียว เปลี่ยนทั้งเว็บ (consistency มาเอง)
> **กฎ:** ไต่ทีละชั้น (organism ประกอบ molecule, page ประกอบ pattern) · ถ้า page ดึง atom ตรงๆ ให้เลื่อนขึ้นเป็น molecule/organism ก่อน

**หมายเหตุ dependency:** ref ไหลลงล่างอย่างเดียว `ui → patterns → components → design` (upward ref = audit error)

---

## 5. spec ↔ dev

### ปัญหา: spec ต้นทาง กับ dev เขียนจริง ดูไม่เหมือนกัน

| | ค่า |
|---|---|
| spec (token file) | `{semantic.colors.error.background}` |
| CSS ที่ compile | `--sys-color-error` + `--btn-background` |
| dev เขียนจริง | `var(--btn-background)` หรือ Tailwind `bg-destructive` |

### ต้องเข้าใจ 2 ชั้นของความต่าง

1. **Syntax — เลี่ยงไม่ได้ (และไม่ใช่ปัญหา):** `{...}` (token file ref) กับ `var(--...)` (CSS) เป็นคนละภาษา เอามาเป็น string เดียวกันเป๊ะไม่ได้ — **แต่ "คำ" ข้างในทำให้ตรงกันได้** (deterministic map: จุด→ขีด + เติม prefix, tool แปลงกลับได้ ไม่มี drift)

2. **Vocabulary — ต้องเหมือน (กฎบังคับ):** คำที่ใช้ต้องเป็นคำเดียวกันทุก layer

### กฎ "No vocabulary swap"

> คำเดียวกันตั้งแต่ `design.md` → `components.json` → `tokens.css` → HTML/CSS

**ตัดสินใจของทีม (option B): property เขียนคำเต็ม, prefix สั้น**

| | ✅ ใช้ | ❌ เลิกใช้ |
|---|---|---|
| property | `--btn-background`, `--btn-foreground`, `--btn-padding-x` | `--btn-bg`, `--btn-fg`, `--btn-px` |
| prefix | `btn` (ย่อไว้ — ประหยัด token) | — |

> **ทำไม property เต็ม:** ตรงกับ spec (`{...background}`) + shadcn (`--background`) + Nathan Curtis taxonomy (ใช้ `background` ไม่ใช่ `bg`) → drift หาย
> **ทำไม prefix ย่อ:** prefix ไม่ใช่ prop vocabulary (ไม่ผิดกฎ) เก็บสั้นไว้ลด output token ตอน gen HTML

**deprecated prop names** (migrate on edit): `surface` `content` `edge` `elevation` `focus-halo` → `background` `foreground` `border` `shadow` `ring`
⚠️ อย่าสับสน: semantic color role `surface` (`base/raised/sunken`) เป็นคนละเรื่อง — ไม่แตะ

---

## 6. ที่มาของแนวคิด

โครงสร้างนี้ไม่ได้คิดขึ้นลอยๆ — สังเคราะห์จากมาตรฐาน/บทความที่วงการ design system ยอมรับ:

| แนวคิด | ที่มา | เราหยิบอะไรมา |
|---|---|---|
| **Naming Tokens taxonomy** | Nathan Curtis (บทความ "Naming Tokens in Design Systems", ~2020) | คำศัพท์ `variant / state / scale / mode`, props `background/border/text`, t-shirt sizes — ~80% ของ vocabulary มาจากนี่ |
| **Atomic Design** | Brad Frost | ชั้น `atom → molecule → organism` (เรายุบ `template + page` ของเขารวมเป็น `pages` + ดึง reusable ออกเป็น `patterns`) |
| **2-tier token strategy** | Material 3 (Google) + IBM Carbon | โครง semantic tier + component tier |
| **Primitive color palette** | Tailwind CSS v3.4+ | ชื่อ hue + ค่า hex เป๊ะ |
| **Component prop vocabulary** | shadcn/ui + W3C DTCG | `background/foreground/border/shadow/ring` |
| **Token format & ref syntax** | W3C Design Tokens Community Group (DTCG) | brace-ref `{a.b.c}`, ไม่ duplicate token value |

### สิ่งที่เราพัฒนาต่อ (ต่างจากต้นฉบับ)

1. **ตัวคั่น** — เราใช้ `.` แยกชั้น + `-` แยกคำ (Nathan Curtis ใช้ dash ล้วน) → grep/resolve ง่ายกว่า เห็นลำดับชั้นชัดกว่า
2. **โครงชั้นชัด** — primitive/semantic/component + resolve ข้ามชั้น (`--comp → --sys → ค่าจริง`)
3. **ผูกกับ build pipeline** — ไม่ใช่แค่ naming แต่ gen เป็น `tokens.css` + HTML จริง + audit ได้ (`design-md-audit`)
4. **Agent-first** — โครงสร้างออกแบบให้ AI agent อ่าน + validate + สร้างต่อได้ ไม่ใช่แค่คนอ่าน

### เทียบกับ DSDS (designsystemdocspec.org)

DSDS = **documentation spec** (อธิบาย DS ให้ tool อ่าน) — คนละเป้ากับเรา (เรา = **build spec** gen artifact จริง) ไอเดียที่น่าหยิบมาใช้ในอนาคต: `agentDocumentBlocks` (แยก doc สำหรับ AI อ่านอย่างเดียวออกจาก doc มนุษย์) — ตรงกับ agent+human split ของเอกสารนี้

---

## 7. Cheat sheet

```
โครงสร้าง:   primitive → semantic → component → pattern → page
CSS ส่งจริง:  --sys-* (semantic)  +  --comp-* (component)

Naming:
  primitive   ตัวเลข      {primitive.colors.red.500}
  semantic    t-shirt     {semantic.spacing.md}
  component   path เต็ม    {component.atom.button.primary.background.rest}
  คั่นชั้น .  ·  คั่นคำ -  ·  kebab-case  ·  ครอบ {}

Canonical:
  variants   primary secondary tertiary ghost destructive
  states     rest hover active focus disabled selected error
  props      background foreground border shadow ring
  breakpoints 2xs xs sm md lg xl 2xl   (mobile-first)

CSS var:  --btn-background  (property เต็ม, prefix ย่อ)  ← ไม่ใช่ --btn-bg
Ref ไหล:  ui → patterns → components → design   (downward only)
```

---

_อ้างอิงกฎเต็ม: [`skills/design-builder/NAMING.md`](../skills/design-builder/NAMING.md) · schema: [`schemas/`](../schemas/) · ตัวอย่าง: [`examples/`](../examples/)_
