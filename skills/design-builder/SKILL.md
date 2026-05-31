---
name: design-builder
description: Build the BASE of a design system — outputs design.md (tokens-only file). DUAL-PATH (v6.0.0):accepts brand inputs from scratch OR ingests client-given assets (palette, mood, brand refs, typography). Phase 0 inventory check detects what user already has, then asks ONLY for missing pieces. Includes primitive + semantic + mood + iconography-placeholder. Biases token defaults by mood. Tailwind v3.4+ palette for primitives. Part of a 3-file split architecture (design.md + components.md + ui.md). Supports light/dark modes. Triggers on "build design system", "create design.md", "design system from scratch", "brand design guide", "มี palette แล้ว", "ใช้ brand kit ที่มี", "have palette ready", "สร้าง design system", "ออกแบบ DS ใหม่".
version: 6.0.0
user-invokable: true
---

# 🏗️ Design Builder

Generate a complete `DESIGN.md` from brand inputs. Output follows the structure proven across 6 enterprise design systems (Apple, Claude, Airbnb, Figma, Spotify, Mastercard).

## When to use
- Starting a new product/brand with no DS yet
- Need a token-driven foundation (primitive + semantic) before extending
- Have brand inputs (vibe / audience / mood / reference images) ready

## When NOT to use
- Already have a DESIGN.md base + want to add components → use `design-component-builder`
- Already have a DESIGN.md base + want to add icons → use `design-icon-builder`
- Want to combine styles from existing references → use `design-remix`
- Want to check completeness → use `design-md-audit`

## Pipeline — 3-file split architecture
```
design-builder            →  design.md      (primitive + semantic + mood + iconography placeholder)
design-component-builder  →  components.md  (atom + molecule + organism, refs {design.*})
design-icon-builder       →  design.md      (populates iconography block + ## Iconography)
design-ui-builder         →  ui.md          (page + pattern + section + flow, refs {components.*})
design-md-audit           →  audits all 3 files + cross-file refs
design-styleguide         →  HTML / Figma render of all 3
```

**Output file rule:** this skill writes ONLY `design.md`. Never `components.md` or `ui.md`. Cross-file ref syntax: see NAMING.md § 0a.

## Execution Steps

### Phase 0 — Inventory check (MUST use AskUserQuestion)

**ห้ามถามด้วย text** — ใช้ AskUserQuestion `multiSelect: true` ทันที:

```
คำถาม: "มีอะไรพร้อมแล้วบ้าง? (เลือกได้หลายข้อ)"
header: "Brand assets"
multiSelect: true
options:
  - "✅ มี color palette แล้ว (hex/HSL ของ primary/secondary/accent)"
  - "✅ มี mood/vibe direction ชัดแล้ว"
  - "✅ มี brand reference (logo/Figma/website/mood-board)"
  - "✅ มี typography choice แล้ว (font family / pairing)"
  - "❌ เริ่มจาก zero — ยังไม่มีอะไรเลย"
```

**Normalize ผลลัพธ์เป็น InputBundle:**

```yaml
InputBundle:
  has_palette:     true | false
  has_mood:        true | false
  has_brand_refs:  true | false
  has_typography:  true | false
  from_scratch:    true | false   # = ทุกข้ออื่นเป็น false
```

**Decision tree:**
- ถ้า `from_scratch == true` → ไป Phase 1A (zero — ถามทุกอย่างเหมือน v5.0.0)
- มิฉะนั้น → ไป Phase 1B (adaptive — ถามเฉพาะที่ขาด)

---

### Phase 1A — Gather from zero (backward-compat v5.0.0)

**ถามทุกอย่าง 1 batch:**

- **Product / brand name**
- **One-sentence positioning** (e.g., "premium audio for audiophiles")
- **Audience** (e.g., "Gen Z gamers", "enterprise IT admins")
- **Mood — pick 1 primary + 1-2 secondary** from canonical list (ดูตาราง Mood Map ใน Step 1b)
- **Reference attachments** (optional, ถ้ามี)
- **Reference brands** (optional verbal) — "feels like Linear + Notion"
- **Constraints** — dark mode required? mobile-first? accessibility tier (AA/AAA)?
- **Tech stack** — Tailwind / CSS vars / Figma tokens / other

ไป Step 1-confirm

---

### Phase 1B — Adaptive gather (client-given assets path)

ถามเฉพาะที่ขาด ตามตารางนี้:

| InputBundle flag | ถ้า true (มี) | ถ้า false (ขาด) |
|---|---|---|
| `has_palette` | Ask user paste hex list (primary/secondary/accent + optional neutrals/status) | Ask: "ชอบสีหลักโทนไหน?" (warm/cool/neutral/vivid) + auto-pick Tailwind hue |
| `has_mood` | Ask user pick from canonical mood list OR paste their mood description | Ask "Brand vibe เป็นยังไง?" → pick mood from canonical list |
| `has_brand_refs` | Ask user paste/upload (image, URL, markdown, Figma link) | Skip |
| `has_typography` | Ask user paste font names + weights + usage notes | Skip — default ตาม mood |

**Always-required (ถาม 100% ทุกครั้ง — ไม่ assume):**
1. Product / brand name
2. One-sentence positioning
3. Audience
4. Dark mode required? (y/n)
5. Accessibility tier (AA / AAA)

---

### Step 1-confirm — Echo InputBundle ก่อน generate (MANDATORY)

**ห้ามข้าม** — ตาม Working Rule 7 (NO MAGIC) + Rule 8 (VERIFY BEFORE DONE)

แสดง InputBundle ที่ collect ได้เป็น markdown table:

```markdown
## พร้อม generate? เช็ก input ก่อน:

| Field | Value | Source |
|---|---|---|
| Brand name | Acme Co | user input |
| Positioning | "premium audio for audiophiles" | user input |
| Audience | "Gen Z gamers" | user input |
| Primary color | `#2563eb` (blue.600) | **client-given** ✅ |
| Secondary color | `#f59e0b` (amber.500) | **client-given** ✅ |
| Mood | bold-tech | client-given ✅ |
| Typography | Inter / JetBrains Mono | client-given ✅ |
| Brand refs | logo.svg, brandkit.pdf | client-given ✅ |
| Dark mode | required | user input |
| A11y tier | AA | user input |

พิมพ์ **'go'** = generate · พิมพ์ **'แก้ X'** = แก้ field
```

รอ user confirm ก่อนไป Step 1b

### 1b. Apply Mood Map → bias token defaults

Use the chosen primary mood to bias the YAML defaults BEFORE generating. This is the unique fingerprint that makes the DS NOT generic.

| Mood | radius default | shadow strength | border-width | spacing density | tracking | brand hue tendency |
|---|---|---|---|---|---|---|
| `bold-tech` | `sm` (4px) | `sm` flat | `thin` (2) | tight (4/8/12) | tight (-0.02) | saturated (blue/red 600+) |
| `friendly-warm` | `lg` (16px) | `md` soft, larger blur | `hairline` (1) | generous (8/16/24) | normal | warm hues (amber/orange/rose) |
| `premium-editorial` | `sm` (4px) or `none` | barely-there (sm but @5%) | `hairline` (1) | wide (16/24/32) | wide (+0.02) | muted, near-mono |
| `playful-vivid` | `xl` (24px) or `pill` | `md`+ colored | `thin` (2) | medium (8/16/20) | normal | vivid (purple/pink/sky) |
| `technical-dev` | `sm` (4px) | `sm` or none | `thin` (2) | tight (4/8/12) | tight | tech (green/cyan/slate) |
| `calm-focused` | `md` (8px) | `sm` subtle | `hairline` (1) | generous | normal | one calm accent (blue/teal) |

If user picks 2 moods, take primary's defaults but blend the secondary's spacing/radius if no conflict.

### 1bb. WCAG AA constants — inject into mood + tokens

Before generating semantic colors, add these **mandatory primitive constants** for accessibility:

```yaml
primitive:
  a11y:
    contrast-min-aa-body:   4.5    # WCAG AA — text < 18pt
    contrast-min-aa-large:  3.0    # WCAG AA — text ≥ 18pt or 14pt bold
    touch-target-min-px:    44     # WCAG 2.5.5 + Apple HIG + Material
    focus-ring-min-px:      2      # focus indicator must be ≥ 2px
    motion-prefers-reduced: true   # respect prefers-reduced-motion
```

### 1bc. Contrast Pair Matrix — required validation

For every text role × surface role combination, compute WCAG contrast ratio. The matrix below must ALL pass AA (4.5:1 for body / 3.0:1 for large text).

| Text role | Surface (light mode) | Required ratio |
|---|---|---|
| text.primary | surface.base, surface.raised, surface.sunken, background.page | ≥ 4.5 |
| text.secondary | surface.base, surface.raised | ≥ 4.5 |
| text.tertiary | surface.base, surface.raised | ≥ 4.5 (body) — **common fail point** |
| text.on-bgcolor | primary.default, primary.dark, primary.darker, status.error.default | ≥ 4.5 |
| text.inverse | secondary.default (dark surfaces) | ≥ 4.5 |
| text.state.error | surface.base, status.error.soft-light | ≥ 4.5 |
| text.state.warning | surface.base, status.warning.soft-light | ≥ 4.5 |
| text.state.success | surface.base, status.success.soft-light | ≥ 4.5 |
| text.state.info | surface.base, status.info.soft-light | ≥ 4.5 |

If a pair fails:
1. Auto-shift the failing color to the next darker/lighter stop until pass
2. Log the shift in `## Known Gaps` with original + adjusted values
3. If no Tailwind stop in the chosen hue passes → ABORT and ask user to pick a different hue

**Common pattern that fails:** `stone.500` (#78716c) on `coffee.50` (#faf7f2) = ~4.0:1. Auto-shift `text.tertiary` → `stone.600` (#57534e) = ~6.8:1 ✓.

### 1c. Process reference attachments

For each attachment:
- **Image:** scan visible colors → identify dominant hex (rounded to nearest Tailwind hue). Note radii / shadow / type style if visible.
- **Markdown:** parse any YAML frontmatter, extract tokens. Quote source verbatim in comments.
- **URL:** if MCP can fetch, screenshot + analyze. Otherwise ask user to describe.

Record findings as comments in the generated YAML:
```yaml
primitive:
  colors:
    # reference: extracted from user mood-board IMG_3412.jpg
    # dominant: warm cream + terracotta accent
    brand:
      50: '#fff5f0'
      # ...
```

Never copy hex from a single reference without confirming — propose, ask user to confirm.

### 1d. Honor client-given palette (NEW in v6.0.0)

ถ้า `InputBundle.has_palette == true` — **LOCK client-given hex values**:

1. **Snap to Tailwind ladder if possible** — สำหรับแต่ละ hex client ให้:
   - Compute ΔE76 (CIE Lab) ระหว่าง hex client กับทุก Tailwind shade ใน hue ใกล้เคียง
   - ถ้า ΔE < 5 → snap เข้า Tailwind shade ที่ใกล้สุด, log `mapped from client #XXXXXX → tailwind.<hue>.<stop>`
   - ถ้า ΔE ≥ 5 → ตั้งเป็น **custom brand hue** + generate 50..950 ladder ผ่าน OKLCH interpolation (lightness curve เดียวกับ Tailwind)

2. **Use as primary semantic source** — NOT mood default:
   - `semantic.colors.primary.*` = derived จาก client-given primary
   - `semantic.colors.secondary.*` = derived จาก client-given secondary (ถ้ามี)
   - `semantic.colors.accent.*` = derived จาก client-given accent (ถ้ามี)
   - Neutrals / status colors ใช้ mood default ตามเดิม

3. **Re-run Contrast Pair Matrix (Step 1bc) ด้วย LOCKED values**

4. **ถ้า contrast fail** — auto-shift เฉพาะ semantic mapping ที่ fail (ไม่แตะ client-given primary):
   - แทนที่จะเปลี่ยน `primary.default` → ปรับ `text.on-bgcolor` ไป shade ที่ contrast pass
   - **Log shift ใน `## Known Gaps`** ด้วย format มาตรฐาน:
     ```
     ## Known Gaps
     - shifted from client-provided #2563eb → semantic.text.on-bgcolor = #f8fafc (reason: AA fail on primary.default surface, original #ffffff = 4.2:1, shifted = 4.8:1)
     ```

5. **NEVER silently change client-given values** — log every adjustment + reason

### 2. Generate `DESIGN.md` using this exact structure

```
---
[YAML frontmatter: 2-tier tokens — Primitive + Semantic]

primitive:
  colors:
    # BASE atoms — pure white, pure black, transparent. Tailwind hue scales don't cover these.
    # Always include `base` if any semantic value needs pure white/black (e.g., surface.raised on light mode).
    base:
      white:       '#ffffff'
      black:       '#000000'
      transparent: 'transparent'
    # SOURCE: Tailwind CSS v3.4+ palette (https://tailwindcss.com/docs/customizing-colors).
    # 22 hues × 11 stops. Hex values are the official Tailwind values — do NOT invent.
    # Include only the hues you'll reference in semantic layer (minimum: 1 neutral + 1 brand + red).
    slate:   { 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950 }
    gray:    { 50..950 }
    zinc:    { 50..950 }
    neutral: { 50..950 }
    stone:   { 50..950 }
    red:     { 50..950 }
    orange:  { 50..950 }
    amber:   { 50..950 }
    yellow:  { 50..950 }
    lime:    { 50..950 }
    green:   { 50..950 }
    emerald: { 50..950 }
    teal:    { 50..950 }
    cyan:    { 50..950 }
    sky:     { 50..950 }
    blue:    { 50..950 }
    indigo:  { 50..950 }
    violet:  { 50..950 }
    purple:  { 50..950 }
    fuchsia: { 50..950 }
    pink:    { 50..950 }
    rose:    { 50..950 }
    # Custom brand hues ONLY if Tailwind doesn't cover (e.g., specific brand red #E60023)
    # Custom: { name, 50..950 with hex }
  typography:
    # Atomic sub-tokens — semantic layer composes these into roles.
    family:
      sans:  '<font name>'           # e.g., "Inter", "Geist"
      serif: '<font name>'           # optional
      mono:  '<font name>'           # optional
    size:        { 2xs: 10, xs: 12, sm: 14, md: 16, lg: 18, xl: 20, 2xl: 24, 3xl: 30, 4xl: 36, 5xl: 48, 6xl: 60 }  # px
    line-height: { 2xs: 14, xs: 16, sm: 20, md: 24, lg: 28, xl: 28, 2xl: 32, 3xl: 36, 4xl: 40, 5xl: 56, 6xl: 64 }  # px
    weight:      { thin: 100, light: 300, regular: 400, medium: 500, semibold: 600, bold: 700, black: 900 }
    tracking:    { tight: -0.02, normal: 0, wide: 0.02 }   # em
  spacing:   { 0, 2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48, 56, 64, 80 }  # px
  radius:    { 0, 2, 4, 6, 8, 12, 16, 20, 24, 32, 9999 }                # px (9999 = pill)
  opacity:   { 0, 5, 10, 20, 40, 60, 80, 100 }                          # %
  blur:      { 0, 4, 8, 16, 24, 40 }                                    # px
  border-width: { 0, 1, 2, 4, 8 }                                       # px
  breakpoints:  { 360, 768, 1024, 1280, 1440, 1920 }                    # px
  shadow:
    # Each shadow level is composed of atomic sub-tokens (Figma-style decomposition).
    # Semantic layer combines these into named elevations.
    sm:    { x: 0, y: 1,  blur: 2,  spread: 0, color: '{primitive.colors.neutral.900}@10%' }
    md:    { x: 0, y: 4,  blur: 8,  spread: 0, color: '{primitive.colors.neutral.900}@12%' }
    lg:    { x: 0, y: 12, blur: 24, spread: 0, color: '{primitive.colors.neutral.900}@16%' }
    xl:    { x: 0, y: 24, blur: 48, spread: 0, color: '{primitive.colors.neutral.900}@24%' }
    inner: { x: 0, y: 2,  blur: 4,  spread: 0, color: '{primitive.colors.neutral.900}@8%',  inset: true }

semantic:
  # Roles. Every value refs a primitive via {primitive.*}.
  # ARCHITECTURE: semantic uses SCALE (default/darker/dark/light/soft-light).
  # STATES (hover/pressed/focused/disabled) live in component layer (Phase 3).
  # MODES: light is required. dark optional. Add as { light, dark } at leaf level.
  colors:
    text:
      # Plain text scale
      primary:        { light: '{primitive.colors.neutral.900}', dark: '{primitive.colors.neutral.50}' }
      primary-darker: { light: '{primitive.colors.neutral.950}', dark: '{primitive.colors.neutral.100}' }
      secondary:        { light: '{primitive.colors.neutral.600}', dark: '{primitive.colors.neutral.300}' }
      secondary-darker: { light: '{primitive.colors.neutral.700}', dark: '{primitive.colors.neutral.200}' }
      tertiary:         { light: '{primitive.colors.neutral.500}', dark: '{primitive.colors.neutral.400}' }
      tertiary-darker:  { light: '{primitive.colors.neutral.600}', dark: '{primitive.colors.neutral.300}' }
      inverse:          { light: '{primitive.colors.neutral.50}',  dark: '{primitive.colors.neutral.900}' }
      on-bgcolor:       { light: '{primitive.colors.neutral.50}',  dark: '{primitive.colors.neutral.900}' }
      # Status-tinted text (Critical add)
      state:
        disable:         { light: '{primitive.colors.neutral.400}', dark: '{primitive.colors.neutral.600}' }
        error:           { light: '{primitive.colors.red.600}',     dark: '{primitive.colors.red.500}' }
        error-darker:    { light: '{primitive.colors.red.800}',     dark: '{primitive.colors.red.300}' }
        warning:         { light: '{primitive.colors.amber.600}',   dark: '{primitive.colors.amber.500}' }
        warning-darker:  { light: '{primitive.colors.amber.800}',   dark: '{primitive.colors.amber.300}' }
        success:         { light: '{primitive.colors.green.600}',   dark: '{primitive.colors.green.500}' }
        success-darker:  { light: '{primitive.colors.green.800}',   dark: '{primitive.colors.green.300}' }
        info:            { light: '{primitive.colors.blue.600}',    dark: '{primitive.colors.blue.500}' }
        info-darker:     { light: '{primitive.colors.blue.800}',    dark: '{primitive.colors.blue.300}' }
    surface:
      base:   { light: '{primitive.colors.neutral.50}',  dark: '{primitive.colors.neutral.950}' }
      raised: { light: '{primitive.colors.neutral.50}',  dark: '{primitive.colors.neutral.900}' }
      sunken: { light: '{primitive.colors.neutral.100}', dark: '{primitive.colors.neutral.950}' }
    background:
      page:  { light: '{primitive.colors.neutral.50}',  dark: '{primitive.colors.neutral.950}' }
      muted: { light: '{primitive.colors.neutral.100}', dark: '{primitive.colors.neutral.900}' }
    # SCALE roles — 5 stops each: default / darker / dark / light / soft-light
    primary:
      default:    { light: '{primitive.colors.brand.600}',  dark: '{primitive.colors.brand.500}' }
      darker:     { light: '{primitive.colors.brand.800}',  dark: '{primitive.colors.brand.300}' }
      dark:       { light: '{primitive.colors.brand.700}',  dark: '{primitive.colors.brand.400}' }
      light:      { light: '{primitive.colors.brand.200}',  dark: '{primitive.colors.brand.800}' }
      soft-light: { light: '{primitive.colors.brand.50}',   dark: '{primitive.colors.brand.950}' }
    secondary:
      default:    { light: '{primitive.colors.neutral.900}', dark: '{primitive.colors.neutral.50}' }
      darker:     { light: '{primitive.colors.neutral.950}', dark: '{primitive.colors.neutral.100}' }
      dark:       { light: '{primitive.colors.neutral.800}', dark: '{primitive.colors.neutral.200}' }
      light:      { light: '{primitive.colors.neutral.200}', dark: '{primitive.colors.neutral.700}' }
      soft-light: { light: '{primitive.colors.neutral.50}',  dark: '{primitive.colors.neutral.900}' }
    tertiary:
      # Critical add — third interactive role (e.g., accent / outline / ghost base)
      default:    { light: '{primitive.colors.neutral.500}', dark: '{primitive.colors.neutral.400}' }
      darker:     { light: '{primitive.colors.neutral.700}', dark: '{primitive.colors.neutral.200}' }
      dark:       { light: '{primitive.colors.neutral.600}', dark: '{primitive.colors.neutral.300}' }
      light:      { light: '{primitive.colors.neutral.200}', dark: '{primitive.colors.neutral.700}' }
      soft-light: { light: '{primitive.colors.neutral.100}', dark: '{primitive.colors.neutral.800}' }
    # Status — extended to full 5-stop scale (Critical add)
    status:
      success:
        default:    { light: '{primitive.colors.green.600}',  dark: '{primitive.colors.green.500}' }
        darker:     { light: '{primitive.colors.green.800}',  dark: '{primitive.colors.green.300}' }
        dark:       { light: '{primitive.colors.green.700}',  dark: '{primitive.colors.green.400}' }
        light:      { light: '{primitive.colors.green.200}',  dark: '{primitive.colors.green.800}' }
        soft-light: { light: '{primitive.colors.green.50}',   dark: '{primitive.colors.green.950}' }
      warning:
        default:    { light: '{primitive.colors.amber.500}',  dark: '{primitive.colors.amber.400}' }
        darker:     { light: '{primitive.colors.amber.700}',  dark: '{primitive.colors.amber.200}' }
        dark:       { light: '{primitive.colors.amber.600}',  dark: '{primitive.colors.amber.300}' }
        light:      { light: '{primitive.colors.amber.200}',  dark: '{primitive.colors.amber.800}' }
        soft-light: { light: '{primitive.colors.amber.50}',   dark: '{primitive.colors.amber.950}' }
      error:
        default:    { light: '{primitive.colors.red.600}',    dark: '{primitive.colors.red.500}' }
        darker:     { light: '{primitive.colors.red.800}',    dark: '{primitive.colors.red.300}' }
        dark:       { light: '{primitive.colors.red.700}',    dark: '{primitive.colors.red.400}' }
        light:      { light: '{primitive.colors.red.200}',    dark: '{primitive.colors.red.800}' }
        soft-light: { light: '{primitive.colors.red.50}',     dark: '{primitive.colors.red.950}' }
      info:
        default:    { light: '{primitive.colors.blue.600}',   dark: '{primitive.colors.blue.500}' }
        darker:     { light: '{primitive.colors.blue.800}',   dark: '{primitive.colors.blue.300}' }
        dark:       { light: '{primitive.colors.blue.700}',   dark: '{primitive.colors.blue.400}' }
        light:      { light: '{primitive.colors.blue.200}',   dark: '{primitive.colors.blue.800}' }
        soft-light: { light: '{primitive.colors.blue.50}',    dark: '{primitive.colors.blue.950}' }
    # Border — extended to role + status (Critical add)
    border:
      primary:           { light: '{primitive.colors.brand.600}',    dark: '{primitive.colors.brand.500}' }
      primary-darker:    { light: '{primitive.colors.brand.800}',    dark: '{primitive.colors.brand.300}' }
      secondary:         { light: '{primitive.colors.neutral.300}',  dark: '{primitive.colors.neutral.700}' }
      secondary-darker:  { light: '{primitive.colors.neutral.500}',  dark: '{primitive.colors.neutral.500}' }
      tertiary:          { light: '{primitive.colors.neutral.200}',  dark: '{primitive.colors.neutral.800}' }
      tertiary-darker:   { light: '{primitive.colors.neutral.400}',  dark: '{primitive.colors.neutral.600}' }
      disable:           { light: '{primitive.colors.neutral.200}',  dark: '{primitive.colors.neutral.800}' }
      on-bgcolor:        { light: '{primitive.colors.neutral.50}',   dark: '{primitive.colors.neutral.900}' }
      error:             { light: '{primitive.colors.red.600}',      dark: '{primitive.colors.red.500}' }
      error-darker:      { light: '{primitive.colors.red.800}',      dark: '{primitive.colors.red.300}' }
      warning:           { light: '{primitive.colors.amber.500}',    dark: '{primitive.colors.amber.400}' }
      warning-darker:    { light: '{primitive.colors.amber.700}',    dark: '{primitive.colors.amber.200}' }
      success:           { light: '{primitive.colors.green.600}',    dark: '{primitive.colors.green.500}' }
      success-darker:    { light: '{primitive.colors.green.800}',    dark: '{primitive.colors.green.300}' }
      info:              { light: '{primitive.colors.blue.600}',     dark: '{primitive.colors.blue.500}' }
      info-darker:       { light: '{primitive.colors.blue.800}',     dark: '{primitive.colors.blue.300}' }
    overlay:
      scrim: { light: '{primitive.colors.neutral.900}@60%', dark: '{primitive.colors.neutral.950}@80%' }
    divider:
      default: { light: '{primitive.colors.neutral.200}', dark: '{primitive.colors.neutral.800}' }
  typography:
    # Each role composes atomic primitives. Modes only if mobile/desktop differ.
    heading:
      h1: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.5xl}',
            line-height: '{primitive.typography.line-height.5xl}', weight: '{primitive.typography.weight.bold}',
            tracking: '{primitive.typography.tracking.tight}' }
      h2: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.4xl}',
            line-height: '{primitive.typography.line-height.4xl}', weight: '{primitive.typography.weight.bold}',
            tracking: '{primitive.typography.tracking.tight}' }
      h3: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.3xl}',
            line-height: '{primitive.typography.line-height.3xl}', weight: '{primitive.typography.weight.semibold}',
            tracking: '{primitive.typography.tracking.normal}' }
      h4: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.2xl}',
            line-height: '{primitive.typography.line-height.2xl}', weight: '{primitive.typography.weight.semibold}',
            tracking: '{primitive.typography.tracking.normal}' }
    body:
      lg: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.lg}',
            line-height: '{primitive.typography.line-height.lg}', weight: '{primitive.typography.weight.regular}',
            tracking: '{primitive.typography.tracking.normal}' }
      md: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.md}',
            line-height: '{primitive.typography.line-height.md}', weight: '{primitive.typography.weight.regular}',
            tracking: '{primitive.typography.tracking.normal}' }
      sm: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.sm}',
            line-height: '{primitive.typography.line-height.sm}', weight: '{primitive.typography.weight.regular}',
            tracking: '{primitive.typography.tracking.normal}' }
    label:
      md: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.sm}',
            line-height: '{primitive.typography.line-height.sm}', weight: '{primitive.typography.weight.medium}',
            tracking: '{primitive.typography.tracking.normal}' }
      sm: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.xs}',
            line-height: '{primitive.typography.line-height.xs}', weight: '{primitive.typography.weight.medium}',
            tracking: '{primitive.typography.tracking.normal}' }
    caption:
      md: { family: '{primitive.typography.family.sans}', size: '{primitive.typography.size.xs}',
            line-height: '{primitive.typography.line-height.xs}', weight: '{primitive.typography.weight.regular}',
            tracking: '{primitive.typography.tracking.normal}' }
  spacing:
    # t-shirt → numeric primitive ref. base-4 multiples.
    xs:    '{primitive.spacing.4}'
    sm:    '{primitive.spacing.8}'
    md:    '{primitive.spacing.16}'
    lg:    '{primitive.spacing.24}'
    xl:    '{primitive.spacing.32}'
    2xl:   '{primitive.spacing.48}'
    3xl:   '{primitive.spacing.64}'
  radius:
    none:  '{primitive.radius.0}'
    sm:    '{primitive.radius.4}'
    md:    '{primitive.radius.8}'
    lg:    '{primitive.radius.16}'
    xl:    '{primitive.radius.24}'
    pill:  '{primitive.radius.9999}'
    full:  '{primitive.radius.9999}'
  border-width:
    hairline: '{primitive.border-width.1}'
    thin:     '{primitive.border-width.2}'
    thick:    '{primitive.border-width.4}'
  elevation:
    # Named depth roles → shadow primitive ref.
    raised:   '{primitive.shadow.sm}'
    floating: '{primitive.shadow.md}'
    modal:    '{primitive.shadow.lg}'
    popover:  '{primitive.shadow.xl}'
  breakpoints:
    sm:  '{primitive.breakpoints.360}'
    md:  '{primitive.breakpoints.768}'
    lg:  '{primitive.breakpoints.1024}'
    xl:  '{primitive.breakpoints.1280}'
    2xl: '{primitive.breakpoints.1920}'
  iconography:
    # PLACEHOLDER — populated by `design-icon-builder` skill.
    # Style choice (outlined/filled/duotone/...) is mood-driven.
    style: 'tbd'           # set by design-icon-builder
    stroke-width: 'tbd'    # 1, 1.5, 2 — depends on mood
    grid: 'tbd'            # 24 by default
    sizes:                 # ref semantic.spacing
      sm: 'tbd'
      md: 'tbd'
      lg: 'tbd'

mood:
  primary:   'tbd'         # one of: bold-tech | friendly-warm | premium-editorial | playful-vivid | technical-dev | calm-focused
  secondary: []            # 0-2 secondary moods
  reference:               # paths/URLs of attached references
    - 'tbd'
---

## Overview
Brand philosophy + design language principles. 3-5 short paragraphs.

**Mood & Tone — required first paragraph.** Open with the chosen primary mood, what it means visually for this brand, and what it explicitly is NOT. Example: *"TaskFlow leans `calm-focused` — a moderate-radii surface with one calm accent, generous whitespace, restrained shadows. Not bold. Not playful. The product should feel like quiet competence."*

**Reference provenance — second paragraph.** Briefly cite any reference attachments that shaped the tokens (mood board, brand brief, competing site). Be specific: *"The terracotta accent was extracted from the user's mood board file `IMG_3412.jpg`; the spacing rhythm was inherited from `notion/DESIGN.md` in the local design library."*

## Mood & Tone

Document the mood decisions so future designers and agents understand the WHY behind token values.

| Decision | Choice | Why (mood-driven) |
|---|---|---|
| Radius default | `{semantic.radius.md}` (8px) | calm-focused → moderate, not aggressive |
| Shadow strength | `{semantic.elevation.raised}` only | restrained — surfaces should feel quiet |
| Border-width | `hairline` (1px) | minimal visual weight |
| Spacing density | generous (md = 16px default gap) | breathing room conveys calm |
| Brand hue | `blue` (Tailwind) | trustworthy, productive, not loud |
| Type tracking | normal | calm reading rhythm |
| Iconography style | outlined, 1.5-2px stroke | matches hairline borders |

Add this table to every DESIGN.md. If a future change drifts from these values, the audit will surface it.

## Primitives
Raw palette. NO semantic meaning. These are reference targets only.

### Base atoms (pure white / black / transparent)
Tailwind hue scales don't include pure white (`slate.50` = `#f8fafc`, not `#ffffff`). Add a `base` block in primitive whenever the semantic layer needs literal white/black:

```yaml
primitive:
  colors:
    base:
      white:       '#ffffff'
      black:       '#000000'
      transparent: 'transparent'
```

Semantic refs base just like any hue: `{primitive.colors.base.white}`.

### Color scales — Tailwind v3.4+ palette
**SOURCE OF TRUTH:** https://tailwindcss.com/docs/customizing-colors

Include ONLY hues used by the semantic layer (avoid bloating the file).
Minimum required:
- 1 neutral hue (pick from: `slate`, `gray`, `zinc`, `neutral`, `stone`)
- 1 brand hue (pick from any Tailwind hue OR define a custom hue if Tailwind doesn't match)
- `red` (for error/destructive states)

Each hue has 11 stops with EXACT Tailwind hex values:
```
red:
  50:  '#fef2f2'
  100: '#fee2e2'
  200: '#fecaca'
  300: '#fca5a5'
  400: '#f87171'
  500: '#ef4444'
  600: '#dc2626'
  700: '#b91c1c'
  800: '#991b1b'
  900: '#7f1d1d'
  950: '#450a0a'
```
Do NOT invent hex values — copy verbatim from Tailwind docs.

**Custom brand hue** (only when Tailwind doesn't match):
```
brand:
  50..950 with manually-tuned hex values
  note: 'designed by lead designer 2026-05'
```

### Typography sub-tokens
Atomic — semantic layer composes these into named roles (heading-h1, body-md, etc.).
- `family` — font families by category (sans/serif/mono)
- `size` — px scale 2xs..6xl
- `line-height` — px scale paired with size
- `weight` — numeric (100..900)
- `tracking` — em values for letter-spacing

### Shadow sub-tokens
Each elevation = `{ x, y, blur, spread, color, inset? }`. Color refs a primitive color + opacity.
Semantic layer maps these to named elevations (raised, floating, modal, etc.).

### Numeric scales (raw px / %)
- `spacing` (base 4)
- `radius` (includes 9999 for pill)
- `opacity` (%)
- `blur` (px)
- `border-width` (px)
- `breakpoints` (px)

## Semantic Tokens

Role-based abstraction over primitives. Every value MUST `{primitive.*}`-ref.
**Modes** (light/dark) live at the leaf level inside `{ light: ..., dark: ... }`. Path never carries mode.
**States** (`hover/pressed/focused/disabled/active`) belong to the **component layer** (Phase 3) — NOT here.

### Color roles (required)
| Group | Stops | Purpose |
|---|---|---|
| `text` | primary, primary-darker, secondary, secondary-darker, tertiary, tertiary-darker, inverse, on-bgcolor | plain text scale |
| `text.state` | disable, error+darker, warning+darker, success+darker, info+darker | status-tinted text |
| `surface` | base, raised, sunken | container surfaces |
| `background` | page, muted | page-level fills |
| `primary` | **5-stop scale:** default, darker, dark, light, soft-light | primary brand color |
| `secondary` | 5-stop scale | secondary action |
| `tertiary` | 5-stop scale | tertiary action / accent / ghost base |
| `status` | success / warning / error / info × **5-stop scale** | feedback fills |
| `border` | primary+darker, secondary+darker, tertiary+darker, disable, on-bgcolor, status × {default, darker} | edges |
| `overlay` | scrim | modal/sheet backdrop (with opacity) |
| `divider` | default | horizontal/vertical lines |

**Rules:**
- Scale roles (`primary`, `secondary`, `tertiary`, `status.*`) MUST have all 5 stops: `default, darker, dark, light, soft-light`
- NO states in semantic (`hover`, `pressed`, `focused`, `disabled`, `active`) — states map at component layer
- Every leaf has `light` mode; `dark` is optional but if added, must appear on ALL leaves (no half-coverage)
- `on-bgcolor` tokens define foreground against arbitrary background — required for contrast pairs

### Typography roles (required)
| Group | Stops | Purpose |
|---|---|---|
| `heading` | h1, h2, h3, h4 | titles |
| `body` | sm, md, lg | running text |
| `label` | sm, md | UI labels |
| `caption` | md | metadata, captions |

**Rules:**
- Each role is a composition: `{ family, size, line-height, weight, tracking }`
- All 5 sub-keys required — no `font: 16px/24px sans-serif` shorthand
- Each sub-key MUST `{primitive.typography.*}`-ref

### Spacing roles (required)
T-shirt: `xs, sm, md, lg, xl, 2xl, 3xl` — each `{primitive.spacing.N}`-ref.

### Radius roles (required)
`none, sm, md, lg, xl, pill, full` — each `{primitive.radius.N}`-ref.

### Border-width roles (required)
`hairline, thin, thick` — each `{primitive.border-width.N}`-ref.

### Elevation roles (required)
Named depth: `raised, floating, modal, popover` — each `{primitive.shadow.X}`-ref.

### Breakpoint roles (required)
T-shirt: `sm, md, lg, xl, 2xl` — each `{primitive.breakpoints.N}`-ref.

### Documentation format (in markdown body)
For each role, show one row:
```
{semantic.colors.primary.default} → {primitive.colors.brand.600} → #dc2626 → "Primary CTA, brand actions"
                ↑role                       ↑primitive ref           ↑resolved hex   ↑usage rule
```

### Forbidden in this section
- Raw hex (must `{primitive.*}`-ref)
- Mode in path (e.g., `primary-dark.default` — use `default.{ light, dark }` instead)
- State outside interactive role (e.g., `text.primary.hover` — text isn't interactive)
- Numeric stops (use t-shirt scale only)

## Layout
Grid (12-col default), container widths, gutters per breakpoint.
Pure structural notes — spacing/breakpoint values live in Semantic Tokens above.

## Do's and Don'ts
Two-column. ✓ rule + reason || ✗ anti-pattern + why.
Minimum 8 pairs covering: color use, spacing, typography pairing, component variants, accessibility.

## Responsive Behavior
Mobile-first rules. What collapses, stacks, hides per breakpoint.

## Iteration Guide
How to extend safely:
- Adding new tokens (where + naming convention)
- Adding components (which sections to update)
- Versioning rules

## Known Gaps
What's NOT covered yet. Be honest — builds trust.

## Agent Prompt Guide
3-5 example prompts a coding agent can use:
- "Build a pricing page using DESIGN.md"
- "Create a sign-up form following DESIGN.md spec"
Each prompt shows expected token refs.
```

### 3. Validate output
Before delivering, self-check:
- [ ] YAML frontmatter parses (valid YAML)
- [ ] `mood.primary` set (not `'tbd'`) — primary mood is required
- [ ] `mood.reference` lists any attached files/URLs or is explicitly `[]`
- [ ] `## Mood & Tone` section table populated with concrete token choices
- [ ] `## Overview` opens with mood paragraph + reference provenance paragraph
- [ ] `iconography:` block exists as placeholder (`'tbd'` values) for `design-icon-builder` to fill
- [ ] Token defaults align with chosen mood (cross-check vs Mood Map table)

**WCAG AA (Critical):**
- [ ] `primitive.a11y` block present with contrast-min, touch-target-min, focus-ring-min, motion-prefers-reduced
- [ ] Contrast Pair Matrix run — every text × surface combination ≥ 4.5:1 (or 3.0:1 for large)
- [ ] Failed pairs auto-shifted to passing stops, original values logged in Known Gaps
- [ ] If any pair still fails after auto-shift → block delivery, ask user to change hue
- [ ] **Two tiers present**: `primitive:` and `semantic:` blocks
- [ ] **Primitives are raw** — no semantic names in primitive block (no `primary`, `error`, etc.)
- [ ] **Semantics ref primitives** — every semantic value uses `{primitive.*}` syntax
- [ ] **`## Primitives` section** precedes `## Semantic Tokens`
- [ ] At least 2 hue scales in primitives (neutral + brand minimum) + `red`
- [ ] **Color hexes match Tailwind v3.4+** exactly (no drift) — except explicitly-marked custom hues
- [ ] **Typography primitives present** — `family`, `size`, `line-height`, `weight`, `tracking` sub-tokens
- [ ] **Shadow primitives decomposed** — each level has `x/y/blur/spread/color` sub-tokens, not a single string

**Semantic layer (Phase 2):**
- [ ] All required color groups present: `text` (+ text.state), `surface`, `background`, `primary`, `secondary`, `tertiary`, `status`, `border`, `overlay`, `divider`
- [ ] Scale roles (`primary`, `secondary`, `tertiary`, `status.*`) have all 5 stops: `default, darker, dark, light, soft-light`
- [ ] **NO states in semantic** — no `hover`, `pressed`, `focused`, `disabled`, `active` keys anywhere under `semantic.colors.*`
- [ ] `text.state` has all status tints: `error+darker`, `warning+darker`, `success+darker`, `info+darker`, `disable`
- [ ] `status` has all 4 channels (success/warning/error/info), each with 5-stop scale
- [ ] `border` has role variants (primary/secondary/tertiary + darker) + status + disable + on-bgcolor
- [ ] If `dark` mode used anywhere → every leaf has both `light` AND `dark` (no half-coverage)
- [ ] Mode appears only at leaf level — never in path
- [ ] All required typography groups: `heading{h1..h4}`, `body{sm,md,lg}`, `label{sm,md}`, `caption{md}`
- [ ] Each typography role has all 5 sub-keys: `family, size, line-height, weight, tracking`
- [ ] `spacing`, `radius`, `border-width`, `elevation`, `breakpoints` all present in semantic
- [ ] **States NOT in semantic** — `hover/pressed/focused/disabled/active` belong to component layer (built by `design-component-builder` skill)

**Naming compliance (per NAMING.md):**
- [ ] No snake_case anywhere (no `soft_light`, `gray_light`)
- [ ] No brand-suffix names (no `apple-blue`, `lottoplus-red`)
- [ ] No raw hex in markdown body — must `{semantic.*}`-ref

**Content:**
- [ ] Do/Don't has ≥8 pairs
- [ ] Known Gaps section is honest (not empty)

### 4. Save location
- Default: `./design.md` (tokens-only file in 3-file split architecture)
- If `./design.md` exists: save to `./design-library/<brand>/design.md` and tell user
- Tell user next steps: `design-component-builder` → `./components.md`; `design-ui-builder` → `./ui.md`
- frontmatter MUST include `scope: 'tokens-only'`

## Output Format Rules
- Use markdown (no HTML)
- Token references inline: `{colors.primary}` style
- Code blocks for examples (CSS/Tailwind/JSX as requested)
- Visual examples as ASCII or color hex swatches in markdown
- Maximum 2 heading levels deep (##, ###)

## Constraints
- Do NOT invent brand history or unverifiable facts about the company
- Do NOT copy verbatim from any single reference brand — synthesize
- Do NOT skip Known Gaps section (set it honestly even if short)
- Do NOT add sections beyond the 12 listed unless user requests
- If user gives < 3 inputs from step 1, ask before generating

## Quality Bar
Final DESIGN.md should:
- Be readable by a coding agent → coding agent can build a page using only this file
- Be readable by a human designer → no jargon without definition
- Pass `design-md-audit` skill with no Critical issues
