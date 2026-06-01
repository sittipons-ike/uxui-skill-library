---
name: design-md-audit
description: Audit a design system across either the 3-file split architecture (design.md + components.md + ui.md) OR the legacy monolithic DESIGN.md. Resolves cross-file refs ({design.*} / {components.*} / {ui.*}), enforces strict downward ref direction (ui → components → design), checks scope keys match file roots, validates NAMING.md atomic + alias rules. Reports missing sections, broken refs, dangling refs (ui→missing component), upward refs (audit fail), scope violations, snake_case, Tailwind hex drift. Adds HTML coverage check — verifies components/<name>.html exists for each atom in components.md + pages/<name>.html for each page in ui.md. Supports --migrate flag to split monolithic into 3 files. Triggers on "audit", "audit design system", "check design system", "review DS spec", "validate", "ตรวจ design", "audit DS".
version: 5.1.0
user-invokable: true
args:
  - name: file
    description: Path to DESIGN.md (default ./DESIGN.md)
    required: false
---

# 🔍 Design Md Audit

Audit a `DESIGN.md` against the backbone structure. Surface gaps, broken token refs, weak sections.

## When to use
- Inherited a DESIGN.md and need a completeness check
- Pre-handoff QA before coding agents consume the spec
- After running `design-builder` or `design-remix` to verify quality

## When NOT to use
- File doesn't exist yet → use `design-builder`
- Want to fix issues → audit first, then fix manually or re-run builder

## Audit Backbone (the spec to check against)

### Required sections (Critical if missing)
1. YAML frontmatter with `primitive:` AND `semantic:` blocks (base tiers — built by `design-builder`)
2. YAML `mood:` block with `primary` set (not `'tbd'`)
3. ## Overview (opens with mood paragraph + reference provenance)
4. ## Mood & Tone (decision table)
5. ## Primitives
6. ## Semantic Tokens
7. ## Layout
8. ## Do's and Don'ts
9. ## Responsive Behavior

### Conditional sections (built by separate skills)
- YAML `component:` block + `## Component Tokens` — added by `design-component-builder`
- YAML `iconography:` populated (not `'tbd'`) + `## Iconography` — added by `design-icon-builder`

**Conditional rule:** if section/block exists, audit fully. If missing, surface as "Not yet built — run `<skill>` to add" (informational, not Critical).

### Strongly recommended (Major if missing)
9. ## Iteration Guide
10. ## Known Gaps

### Nice-to-have (Minor if missing)
11. ## Agent Prompt Guide

### Semantic Tokens — required subsections (Critical if missing)
- ### Color roles — with `text/surface/background/border/primary/secondary/status/overlay/divider`
- ### Typography roles — with `heading/body/label/caption`
- ### Spacing roles
- ### Radius roles
- ### Border-width roles
- ### Elevation roles
- ### Breakpoint roles

## Execution Steps

### 1. Detect architecture mode
- Look for split files first: `./design.md`, `./components.md`, `./ui.md`
- If 2+ split files exist → **split-architecture mode**: load all present, audit each per scope
- If only monolithic `./DESIGN.md` exists → **legacy mode**: audit single file
- If both exist → WARN: "Mixed state — split files take precedence; consider removing DESIGN.md after migration"
- If `file` arg passed → audit just that file with auto-detected scope

### 1b. Cross-file resolution (split mode only)
For each ref `{<file>.<path>}` in any file:
1. Verify the file prefix is one of: `design`, `components`, `ui`
2. Resolve the path inside the target file
3. If target file missing or path doesn't exist → **dangling ref (Major)**
4. Check ref direction:
   - ✅ ui → components, ui → design, components → design, same-file refs
   - ❌ design → components/ui, components → ui → **upward ref (Critical)**

### 1c. Scope check (split mode only)
Each file must have `scope: <expected>` in frontmatter:
| File | Required scope value | YAML root keys allowed |
|---|---|---|
| design.md | `'tokens-only'` | primitive, semantic, mood (NO component, NO ui) |
| components.md | `'components-only'` | component (NO primitive, NO semantic, NO ui) |
| ui.md | `'ui-compositions'` | ui (NO component, NO design tokens at root) |

Scope mismatch = **Critical**.

### 2. Parse structure
- Extract YAML frontmatter — validate it parses
- List all `## headings` in order
- For each heading, count subsections + measure section length (lines)

### 3. Run checks (mark each pass/fail with severity)

**Structural (Critical)**
- [ ] Required sections all present
- [ ] YAML frontmatter present and parses
- [ ] No section >3 levels deep (## ### ####)

**Token quality (Critical)**
- [ ] YAML frontmatter has BOTH `primitive:` and `semantic:` blocks
- [ ] `## Primitives` section exists and precedes `## Colors`
- [ ] Primitive block has ≥2 color hue scales (e.g., `neutral`, `brand`) + `red` with 50–950 stops
- [ ] If semantic uses pure white/black anywhere, `primitive.colors.base` block exists with `white`/`black` (Tailwind hues don't cover pure white/black)
- [ ] **Color hexes match Tailwind v3.4+ palette** for any Tailwind-named hue (slate/gray/zinc/neutral/stone/red/orange/amber/yellow/lime/green/emerald/teal/cyan/sky/blue/indigo/violet/purple/fuchsia/pink/rose). Custom hues must be marked as custom. `base` allowed exact `#ffffff`/`#000000`.
- [ ] Typography primitives include atomic sub-tokens: `family`, `size`, `line-height`, `weight`, `tracking`
- [ ] Shadow primitives are decomposed — each level has `x/y/blur/spread/color` sub-tokens (NOT a single CSS string)
- [ ] Primitive block has numeric scales for: spacing, radius, opacity, blur, border-width, breakpoints
- [ ] No semantic role names inside `primitive:` block (no `primary`, `error`, `success` keys under primitive)
- [ ] Every value inside `semantic:` block references a primitive via `{primitive.*}` ref
- [ ] Spacing scale uses one base unit (4 or 8)
- [ ] At least one shape/radius scale present

**Reference integrity (Major)**
- [ ] Every `{token.path}` ref in body resolves to YAML frontmatter
- [ ] Every `{primitive.*}` ref inside `semantic:` resolves to a primitive token
- [ ] No primitive→component direct refs (component should ref semantic, not primitive)
- [ ] Component definitions reference at least 1 semantic token each
- [ ] No leaked brand-specific names (`apple-*`, `spotify-*` unless that IS the brand)
- [ ] No raw hex/px in `## Semantic Tokens` / `## Components` body — must be token refs

**Semantic roles (Critical)**
- [ ] All required color role groups present: `text` (+ text.state), `surface, background, primary, secondary, tertiary, status, border, overlay, divider`
- [ ] Scale roles (`primary, secondary, tertiary, status.{success,warning,error,info}`) have all 5 stops: `default, darker, dark, light, soft-light`
- [ ] **NO state keys** (`hover, pressed, focused, disabled, active`) anywhere under `semantic.colors.*`
- [ ] `text.state` has: `disable, error+darker, warning+darker, success+darker, info+darker`
- [ ] `border` has role variants + status variants + disable + on-bgcolor
- [ ] Required typography roles: `heading{h1..h4}, body{sm,md,lg}, label{sm,md}, caption{md}`
- [ ] Each typography role has all 5 sub-keys: `family, size, line-height, weight, tracking`
- [ ] `spacing`, `radius`, `border-width`, `elevation`, `breakpoints` all present in semantic

**WCAG AA — Accessibility (Critical)**

Audit enforces WCAG 2.1 Level AA at spec level (catches issues BEFORE code is written):

**Tier: design.md (tokens)**
- [ ] `primitive.a11y` block exists with: `contrast-min-aa-body: 4.5`, `touch-target-min-px: 44`, `focus-ring-min-px: 2`
- [ ] **Contrast Pair Matrix** — for every text role × surface role combo, compute ratio. Fail if any < 4.5 (body) or < 3.0 (large text):
  - text.primary × surface.{base, raised, sunken}
  - text.secondary × surface.{base, raised}
  - text.tertiary × surface.{base, raised}     ← common fail
  - text.on-bgcolor × {primary.default, primary.dark, primary.darker, status.error.default}
  - text.inverse × secondary.default
  - text.state.{error, warning, success, info} × surface.base
- [ ] Failing pairs MUST be documented in Known Gaps with original + adjusted values
- [ ] If `mood.primary` is `premium-editorial` and uses light text on cream surfaces, extra scrutiny (common AA fail mode)

**Known Gaps reserved keywords (v6.0.0+)** — parse-only, do NOT flag as errors:
- `shifted from client-provided #XXXXXX → ...` — client palette honored, semantic mapping shifted (informational, design-builder v6+)
- `mapped from client #XXXXXX → tailwind.<hue>.<stop>` — client hex snapped to Tailwind ladder (informational)
- `custom hue generated from client #XXXXXX → primitive.colors.<name>.50..950` — non-Tailwind hex, brand ladder generated (informational)
- `TBD: <free-form>` — open work, treat as warning not error

See `design-builder/NAMING.md § 12` for full format spec.

**Tier: components.md (atomic)**
- [ ] Every atom has `a11y:` block (button / icon / input / label / helper-text / avatar / badge)
- [ ] atom.button declares `hit-area-min: 44`; sizes with visual height < 44 declare invisible padding workaround
- [ ] atom.icon has required-one-of (`aria-hidden` OR `aria-label`)
- [ ] atom.input has required-attrs (`id`, `aria-describedby`) + label association
- [ ] molecule.nav-item declares `aria-current` for selected state
- [ ] molecule.form-field error state declares `aria-invalid` + `role="alert"` on helper
- [ ] organism.sidebar declares landmark `nav` + `aria-label`
- [ ] organism.modal declares role `dialog`, `aria-modal`, focus-trap, ESC-close

## Component HTML Coverage

Verifies that the components.md spec is backed by real HTML preview files on disk. Run alongside the components.md atomic checks above.

- [ ] `tokens.css` exists at the design system root (error if `components.md` is present but `tokens.css` missing — components depend on tokens being materialized as CSS variables)
- [ ] For each atom name declared in `components.md` under `component.atom.*`, a file `components/<atom>.html` exists (error per missing atom — atoms without HTML cannot be visually verified or composed into molecules/organisms)
- [ ] `components.html` showcase file exists at root (warning if missing — showcase is the team-facing index of all atoms; useful but not blocking)
- [ ] For each page name declared in `ui.md` under `ui.page.*`, a file `pages/<page>.html` exists (error per missing page — pages declared in spec must have a renderable HTML counterpart)

### Severity table

| Check | Severity | Behavior on fail |
|---|---|---|
| `tokens.css` missing (when components.md present) | **error** | Counts toward Critical issues; blocks pass verdict |
| `components/<atom>.html` missing (per atom) | **error** | Counts toward Critical issues per missing file; blocks pass verdict |
| `components.html` showcase missing | **warning** | Surfaced as Minor; does not block pass verdict |
| `pages/<page>.html` missing (per page) | **error** | Counts toward Critical issues per missing file; blocks pass verdict |

Report missing files with both the spec source (e.g. `components.md: component.atom.button`) and the expected file path (`components/button.html`) so the user knows exactly which file to create.

**Tier: ui.md (compositions)**
- [ ] Every page declares `a11y.h1` slot exactly once
- [ ] Every page declares `a11y.landmarks` listing main + (nav, header, contentinfo)
- [ ] Every page declares `a11y.skip-link` with target `#main`
- [ ] Every page declares `a11y.page-title` format
- [ ] Every flow declares `live-region` + `back-button` aria-label
- [ ] Every section declares heading-level

**Mood & Iconography (Critical)**
- [ ] `mood.primary` is set (not `'tbd'` or missing)
- [ ] `mood.primary` is one of the canonical 6: `bold-tech | friendly-warm | premium-editorial | playful-vivid | technical-dev | calm-focused`
- [ ] `## Mood & Tone` body section exists with token decisions table
- [ ] Token defaults align with mood (e.g., `calm-focused` should NOT have `pill` radius default — check vs mood map)
- [ ] If `iconography:` block has populated values (no `'tbd'`), validate: style is a known style, sizes ref semantic, colors ref semantic
- [ ] If `iconography:` block is all `'tbd'`, surface as INFO: "Run `design-icon-builder` to populate"

**Component layer — Atomic 3-tier (Critical IF present)**
- [ ] If no `component:` block → INFO: "Run `design-component-builder` to add components"
- [ ] If `component:` block exists, must contain `atom:` / `molecule:` / `organism:` keys (3-tier)
- [ ] Old flat shape (no tier nesting) → Critical: must migrate to atomic
- [ ] **Prop alias check**: NO `bg`, `fg`, `border`, `shadow`, `ring` keys anywhere — must use `surface`, `content`, `edge`, `elevation`, `focus-halo`
- [ ] **State alias check**: NO `default`, `pressed`, `focused` keys — must use `rest`, `active`, `focus`
- [ ] **Ambiguous `active` check**: if `active` appears, verify it's pressed-state (interactive). If it's nav-current, must rename to `selected`
- [ ] Tier flow valid (organism → molecule/atom, molecule → atom)
- [ ] No upward refs (atom must NOT ref molecule/organism)
- [ ] Molecules have `composed-of:` block; refs are valid `{component.atom.*}`
- [ ] Organisms have `composed-of:` block; refs are valid `{component.molecule.*}` or `{component.atom.*}`
- [ ] YAML `component:` block exists
- [ ] Tier A (always required): `button`, `input`, `card`
- [ ] **Tier B/C/D/E rule** — for each tier, either ALL 4 components present OR Known Gaps explicitly lists the tier with a reason
  - Tier B (Form): `checkbox`, `radio`, `toggle`, `select`
  - Tier C (Feedback): `badge`, `alert`, `toast`, `tooltip`
  - Tier D (Navigation): `tab`, `nav-link`, `breadcrumb`, `pagination`
  - Tier E (Overlay): `modal`, `drawer`, `popover`, `dropdown`
- [ ] **No partial tier** — if a tier has 1-3 components present but not all 4, audit fails (mixed-completeness is the worst state)
- [ ] If a tier is skipped, Known Gaps MUST name it explicitly: `**Tier X (name)** — skipped because <reason>`
- [ ] `button` has all 5 variants: primary, secondary, tertiary, ghost, destructive
- [ ] `alert` / `toast` have all 4 status channels (info/success/warning/error)
- [ ] `badge` has all 3 variants (solid, soft, outline) when present
- [ ] `tab` has both variants (underline, pills) when present
- [ ] Mandatory props per component type present (button: bg+fg; input: bg+fg+border; card: bg)
- [ ] **Per-prop completeness**: if a variant has a prop, all required states for the variant kind are present
  - Interactive (button.*, card.interactive): default + hover + pressed + focused + disabled
  - Input-like (input.*): default + hover + focused + disabled (+ error where applicable)
  - Display (card.default): default + hover
- [ ] Skipped optional props don't appear as `'none'` repeated — either omit prop or use single value
- [ ] Variants skipping a prop have inline `# comment` explaining why
- [ ] Every state value is `{semantic.*}`-ref OR literal `'transparent'` / `'none'`
- [ ] NO `{primitive.*}` refs in `component:` block (3-tier separation)
- [ ] NO raw hex / px in `component:` block
- [ ] State is LAST path segment (`bg.hover`, not `hover.bg`)
- [ ] `sizes` block exists per component with refs to semantic spacing/radius/typography
- [ ] No invented state names (only: default, hover, pressed, focused, disabled, active, selected, error)
- [ ] ## Component Tokens section present with table of components × variants × props × states

**Mode coverage (Major)**
- [ ] If ANY leaf uses dark mode, EVERY leaf has both `light` AND `dark` (no half-coverage)
- [ ] Mode never appears in token path (only at leaf level as `{ light, dark }`)
- [ ] Mode keys are exactly `light` / `dark` / `high-contrast` — no custom mode names

**Naming compliance (Major) — per NAMING.md**
- [ ] No snake_case keys anywhere (no `soft_light`, `gray_light`, `super_black`)
- [ ] No camelCase keys (no `lineHeight`, `fontFamily`)
- [ ] No brand-suffix hue names (no `apple-blue`, `lottoplus-red`)
- [ ] No `grey` vs `gray` mixing — pick one and stick (Tailwind uses `gray`)
- [ ] No mode-as-prefix patterns (no `mobile-heading1`, `desktop-display-l` in YAML)
- [ ] State appears ONLY in component layer paths (`{component.*.state}`) — never in semantic or primitive

**Content depth (Major)**
- [ ] Do's and Don'ts has ≥6 pairs
- [ ] Components section covers ≥4 component types
- [ ] Responsive Behavior names ≥3 breakpoints

**Honesty (Minor)**
- [ ] Known Gaps is non-empty
- [ ] Iteration Guide explains how to add tokens AND components

### 4. Output report

```markdown
# DESIGN.md Audit — <file path>

**Verdict:** ✅ Pass / ⚠️ Pass with warnings / ❌ Fail

## Summary
- Sections: X / 13 (X required, X recommended, X nice-to-have)
- Critical: N issues
- Major: N issues
- Minor: N issues

## Critical issues
1. [section] — what's wrong — how to fix
2. ...

## Major issues
...

## Minor issues
...

## Strengths
- What this DS does well (1-3 bullets)

## Recommended next action
- Run `design-builder` to regenerate, OR
- Patch X, Y, Z manually
```

### 5. No auto-fix
Audit only — do NOT edit the file. Report findings; let user choose fix path.

## Severity Definitions
- **Critical** — blocks coding agents from using the spec correctly (missing tokens, no components section, broken YAML)
- **Major** — degrades quality but agents can still work (missing Iteration Guide, weak Do/Don't)
- **Minor** — polish items (no Agent Prompt Guide, sparse Known Gaps)

## Constraints
- Read-only — never edit the file
- If file > 50KB, sample sections rather than full read (note in report)
- Do NOT compare to a specific brand reference unless user asks
- Do NOT rate "design quality" — only structural completeness
- Verdict thresholds:
  - ✅ Pass: 0 Critical, ≤2 Major
  - ⚠️ Pass with warnings: 0 Critical, 3-5 Major
  - ❌ Fail: any Critical, OR >5 Major

## Quality Bar
Report must be actionable — every issue tells user exactly which line/section to fix.
No vague feedback like "improve typography" — instead "Typography section missing line-height values for body/heading roles".
