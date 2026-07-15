---
name: design-md-audit
description: Audit a design system across three input modes — (1) v6 JSON-primary (design.md + components.json + patterns.json + ui.json) validated against JSON Schema Draft-07 in schemas/*.schema.json, (2) v5 MD-split (design.md + components.md + ui.md), (3) legacy monolithic DESIGN.md. Auto-detects input mix; prefers JSON when both JSON and MD manifests are present (warns 'stale spec'). Resolves brace refs via regex ^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$, enforces strict downward direction (ui → patterns → components → design), enforces $meta.scope per manifest (components-only / ui-only / patterns-only), runs diff-merge (base → variant → size → state, last-write-wins) on every variant×size×state combo and validates the merged result. Carries forward v5.1 checks — NAMING.md atomic + alias rules, WCAG AA contrast pair matrix, HTML coverage (components/<name>.html, pages/<name>.html, patterns/<name>.html), Known Gaps reserved keywords. Flags expired variant-extensions entries (governed one-off variants past their reason/expiry) as Major, escalating to Critical past 90 days. Reports missing sections, schema violations, broken refs, dangling refs, upward refs, scope violations, snake_case, Tailwind hex drift. Supports --migrate flag to split monolithic into 3 files. Supports --migrate-to-json flag to convert legacy MD spec (components.md + ui.md + monolithic DESIGN.md) into v6 JSON manifests (components.json + ui.json + patterns.json) with pattern auto-extraction. Triggers on "audit", "audit design system", "check design system", "review DS spec", "validate", "ตรวจ design", "audit DS".
version: 6.1.0
user-invokable: true
args:
  - name: file
    description: Path to entry file (default ./design.md for split mode, ./DESIGN.md for legacy). Audit auto-discovers sibling manifests from entry directory.
    required: false
  - name: json
    description: Set false to force MD-only audit (skips JSON Schema validation + ref resolver). Default true. Use for v5 / legacy repos that have not migrated.
    required: false
  - name: migrate-to-json
    description: Set true to skip audit and run migration instead — converts legacy MD spec (components.md / ui.md / monolithic DESIGN.md) into v6 JSON manifests (components.json + ui.json + patterns.json). Idempotent and non-destructive (never deletes .md files). Default false.
    required: false
---

# 🔍 Design Md Audit (v6)

Audit a design system against the v6 backbone. Surfaces gaps, schema violations, broken refs, scope/direction errors, weak sections, and missing HTML coverage.

v6 is the **first dual-format release**: it audits JSON manifests (`components.json` / `patterns.json` / `ui.json`) AND falls back to MD manifests (`components.md` / `ui.md`) or legacy monolithic `DESIGN.md` when JSON is not present. See [§ Backward Compat](#backward-compat) for the migration path to v7 (MD removal).

## When to use
- Inherited a design system and need a completeness check
- Pre-handoff QA before coding agents consume the spec
- After running `design-builder`, `design-component-builder`, `design-ui-builder`, or `design-remix` to verify quality
- Mid-migration from v5 (MD) to v6 (JSON) to make sure refs still resolve
- Migrating from v5 MD spec to v6 JSON manifests (use `--migrate-to-json`)

## When NOT to use
- File doesn't exist yet → use `design-builder`
- Want to fix issues → audit first, then fix manually or re-run builder

---

## Input Mode Detection

Audit auto-detects which files are present in the entry directory and picks one of four input modes. The selected mode is printed as a banner at the top of the report.

### Detection order (per scope)
| Scope | Looks for (in order) | Preference |
|---|---|---|
| design | `./design.md` → `./DESIGN.md` | `design.md` always required (or `DESIGN.md` in legacy mode) |
| components | `./components.json` → `./components.md` | JSON wins when both exist (warning emitted) |
| patterns | `./patterns.json` | JSON-only — patterns layer is **new in v6**, no MD form ever existed |
| ui | `./ui.json` → `./ui.md` | JSON wins when both exist (warning emitted) |
| html | `./components/*.html`, `./pages/*.html`, `./patterns/*.html` | Always checked when corresponding manifest declares entries |

### Resulting input modes

| Mode | Trigger | Behavior |
|---|---|---|
| **JSON-primary** | `design.md` + `components.json` (+ optional `patterns.json` + `ui.json`); no MD siblings | Run JSON Schema validation + ref resolver + diff-merge + HTML coverage. MD-side checks run only on `design.md`. |
| **MD-primary** (v5) | `design.md` + `components.md` + `ui.md`; no JSON manifests | Run v5.1 MD-side checks. Skip JSON Schema + diff-merge. Ref resolver still runs with legacy unprefixed-ref shim. |
| **Hybrid (warn)** | Both `components.json` and `components.md` exist (or both `ui.json` and `ui.md`) | Audit JSON; flag MD files as **legacy stale spec — pick one** (Warning, not Critical). Recommend deleting MD or porting any deltas into JSON. |
| **Legacy MD-only** | Only `DESIGN.md` present (no split files, no JSON) | Run v5.1 monolithic checks. Recommend `--migrate` to split into v6 layout. |

`json=false` arg forces **MD-primary** or **Legacy MD-only** even when JSON exists (useful for repos that haven't migrated and want to silence JSON-schema noise).

### Banner format (top of report)

```
Input mode: JSON-primary
Files detected:
  design.md          ✓
  components.json    ✓ (schema: uxui/components/v1)
  patterns.json      ✓ (schema: uxui/patterns/v1)
  ui.json            ✓ (schema: uxui/ui/v1)
  components/*.html  12 files
  pages/*.html       4 files
  patterns/*.html    3 files
```

---

## Migration Mode (`--migrate-to-json`)

When invoked with `--migrate-to-json` (or its legacy alias `--migrate` from v5 monolithic-split mode), this skill **skips audit entirely** and instead converts legacy MD spec files into v6 JSON manifests. The audit can then be re-run on the resulting JSON layout for validation.

### Trigger condition
- CLI flag `--migrate-to-json=true` OR `migrate-to-json: true` arg
- Legacy alias `--migrate` is preserved from v5 (was used for monolithic→split). In v6.1 it is treated as `--migrate-to-json` and chains automatically (monolithic DESIGN.md → 3-file MD split → JSON in one run).

### Pre-flight checks
Before doing anything, verify:
- [ ] At least one legacy MD source exists: `components.md` OR `ui.md` OR monolithic `DESIGN.md`
- [ ] `design.md` is present (or `DESIGN.md` for legacy) — design tokens are required as the migration root
- [ ] If only JSON manifests exist (no legacy MD) → **no-op**: emit warning "Already JSON-primary mode — nothing to migrate. Did you mean to run audit (no flag)?"
- [ ] If `design.md` AND `DESIGN.md` both exist → error: "Ambiguous root — delete one before migrating"
- [ ] Write permission to entry directory (migration emits new files)

### Conversion algorithm

**Step 1 — Input detection**
- Locate `components.md` and/or `ui.md` and/or monolithic `DESIGN.md`
- If only `DESIGN.md` exists: first split to 3-file MD layout (existing `--migrate` behavior from v5), then proceed to JSON conversion
- If `design.md` already exists: **skip its migration** — design.md remains YAML-in-MD by design decision (tokens are designer-facing, not coder-facing)

**Step 2 — components.md → components.json**
- Parse YAML frontmatter `component:` block + markdown body
- For each atom entry in components.md, build a JSON entry per `schemas/components.schema.json`:
  - `id` — kebab-case derived from the atom name
  - `summary` — first sentence of the matching `### <name>` section in the body
  - `render`:
    - `tag` — inferred from atomic type (`button` → `button`, `input` → `input`, `card` → `div`, etc.)
    - `role` — ARIA role where applicable
    - `classes` — initial array (Tailwind utilities or `--comp-*` aliases)
    - `slots` — extracted from any `slots:` YAML key, else `[]`
    - `html_template` — `./components/<id>.html` if that file exists; otherwise mark `"TBD"` (and report in the manual-review section)
  - `tokens` — mapped from existing token refs, prefixed with `--comp-*` aliases per NAMING.md
  - `variants` / `sizes` / `states` — diff-only entries parsed from the YAML state aliases (rest / hover / active / focus / disabled / selected / error)
  - `a11y` — extracted from the a11y notes section
- Molecule / organism entries with MD spec but no HTML → emit as `{ "status": "planned" }`
- Emit `$meta`:
  - `scope: "components-only"`
  - `schema: "uxui/components/v1"`
  - `version: "1.0.0"`
  - `depends_on: ["./design.md", "./tokens.css"]`
  - `dtcg_version: "2024-09"`

**Step 3 — ui.md → ui.json + patterns.json (EXTRACTION)**
- `ui.json` receives: `page`, `section`, and `flow` entries
- `patterns.json` receives: extracted **pattern** entries (reusable shells like `auth-split`, `app-shell`, `empty-state`)
- Heuristic for pattern extraction:
  - Sections in `ui.md` tagged with `pattern:` / `shell:` / `reusable:` YAML keys → `patterns.json`
  - Sections whose `composes:` block references **2+ pages** → `patterns.json` (cross-page reuse signal)
  - All other section / page / flow entries → `ui.json`
- Confidence levels (reported per extracted pattern):
  - **HIGH** — explicit `pattern:` YAML key in `ui.md`
  - **MEDIUM** — name matches a known pattern (`auth-split`, `app-shell`, `empty-state`, `dashboard-shell`, `marketing-shell`, etc.)
  - **LOW** — heuristic-based guess (cross-page reuse only); flag for manual review
- Emit `$meta` per scope:
  - `ui.json` → `scope: "ui-only"`, `schema: "uxui/ui/v1"`, `depends_on: ["./design.md", "./components.json", "./patterns.json"]`
  - `patterns.json` → `scope: "patterns-only"`, `schema: "uxui/patterns/v1"`, `depends_on: ["./design.md", "./components.json"]`

**Step 4 — Report output**
- Machine-readable summary → **stdout** (JSON line for scripting / chaining)
- Human report → **stderr** (rich format, see example below)

### Pattern extraction heuristic (decision tree)

```
For each section in ui.md:
  1. Has explicit `pattern: true` or `type: pattern` YAML key?
     → patterns.json, confidence: HIGH
  2. Name in known-pattern list (auth-split, app-shell, empty-state, ...)?
     → patterns.json, confidence: MEDIUM
  3. composes: block references 2+ pages?
     → patterns.json, confidence: LOW (flag for review)
  4. Else:
     → ui.json (page / section / flow per its original category)
```

### Idempotency contract
- Re-runs on unchanged MD sources produce byte-identical JSON (deterministic key ordering, stable timestamps)
- If MD source changed since last migration: emit a diff log showing what JSON keys changed (added / removed / updated)
- Never throws on re-run — overwrites JSON with the new content, never appends

### Non-destructive guarantee
- **NEVER deletes any `.md` file** — legacy MD stays in place after migration
- Existing JSON files are overwritten only if they would change (idempotent)
- Report explicitly lists "preserved" MD files so user knows they're safe and can delete manually after verification

### Report format (printed to stderr)

```
📦 Migration Report — v5 MD → v6 JSON

✅ components.json (9 atoms, 0 molecules, 0 organisms) — HIGH confidence
✅ ui.json (4 pages, 2 sections, 1 flow) — HIGH confidence
✨ patterns.json (3 patterns extracted) — MEDIUM confidence:
   • auth-split (matched known pattern name)
   • app-shell (matched known pattern name)
   • landing-hero ⚠️ LOW confidence — manual review recommended

📁 Files written:
   ./components.json  (4.2 KB)
   ./ui.json          (1.8 KB)
   ./patterns.json    (3.1 KB)

📋 Untouched (preserved):
   ./components.md  (legacy spec — delete after verification)
   ./ui.md          (legacy spec — delete after verification)

⚠️ Manual review required:
   • patterns.json: verify "landing-hero" classification (LOW confidence)
   • components.json: 3 atoms missing render.html_template (no HTML files in components/)

Next: run /design-md-audit to validate
```

### When NOT to use
- Repo is already JSON-primary (no `components.md` / `ui.md` / `DESIGN.md` present) → no-op, emit warning
- User wants to audit current spec (no flag, default behavior)
- User wants to build a new design system from scratch → use `design-builder` / `design-component-builder` / `design-ui-builder` instead

### Recommended path for v5 → v6 teams
`--migrate-to-json` is the recommended migration route. It supersedes the older `--migrate` flag (which only split monolithic → 3-file MD): the new flag handles both legs in one run (monolithic → split MD → JSON manifests). After migration, re-run the audit (no flag) to validate the resulting JSON layout against schemas.

---

## Audit Backbone (the spec to check against)

The backbone splits into **MD-side checks** (always run on `design.md`, and on `components.md` / `ui.md` / `DESIGN.md` when present) and **JSON-side checks** (run only on `*.json` manifests).

### Required sections — design.md (Critical if missing)
1. YAML frontmatter with `primitive:` AND `semantic:` blocks (base tiers — built by `design-builder`)
2. YAML `$meta:` block with `scope: design` and `depends_on: []` (v6+; v5 files without `$meta` get a Warning, not Critical, in MD-primary mode)
3. YAML `mood:` block with `primary` set (not `'tbd'`)
4. ## Overview (opens with mood paragraph + reference provenance)
5. ## Mood & Tone (decision table)
6. ## Primitives
7. ## Semantic Tokens
8. ## Layout
9. ## Do's and Don'ts
10. ## Responsive Behavior

### Conditional sections (built by separate skills)
- YAML `component:` block + `## Component Tokens` — added by `design-component-builder` (MD-primary mode)
- `components.json` — added by `design-component-builder` v6+ (JSON-primary mode)
- YAML `iconography:` populated (not `'tbd'`) + `## Iconography` — added by `design-icon-builder`

**Conditional rule:** if section/block/file exists, audit fully. If missing, surface as "Not yet built — run `<skill>` to add" (informational, not Critical).

### Strongly recommended (Major if missing)
- ## Iteration Guide
- ## Known Gaps

### Nice-to-have (Minor if missing)
- ## Agent Prompt Guide

### Semantic Tokens — required subsections (Critical if missing)
- ### Color roles — with `text/surface/background/border/primary/secondary/status/overlay/divider`
- ### Typography roles — with `heading/body/label/caption`
- ### Spacing roles
- ### Radius roles
- ### Border-width roles
- ### Elevation roles
- ### Breakpoint roles

---

## JSON-side checks (v6, JSON-primary or Hybrid mode)

### JSON Schema Validation (Critical if invalid)
- [ ] `components.json` validates against `schemas/components.schema.json` (JSON Schema Draft-07)
- [ ] `patterns.json` validates against `schemas/patterns.schema.json`
- [ ] `ui.json` validates against `schemas/ui.schema.json`
- [ ] Every `$meta.scope` matches the manifest's expected scope const (`components-only`, `patterns-only`, `ui-only`)
- [ ] Every `$meta.schema` matches the expected schema id for that file (e.g. `uxui/ui/v1`)
- [ ] Every `$meta.version` is valid semver (`^\d+\.\d+\.\d+$`)
- [ ] Every `$meta.depends_on` lists at least one upstream file and the listed files exist on disk

Schema errors are reported with **JSON Pointer paths** (e.g. `components.json#/atom/button/render/tag`) so designers can jump straight to the offending key.

### Ref Resolution (Critical for broken / Major for direction)
- [ ] Every brace ref in any manifest matches the canonical regex `^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$`
- [ ] Every ref resolves to an existing path in the target manifest (else `PATH_NOT_FOUND` → Critical, "broken ref")
- [ ] No `INVALID_SYNTAX` refs (malformed brace, missing prefix, illegal chars) → Critical
- [ ] No `CIRCULAR_REF` chains (A → B → A) detected by `resolveDeep` → Critical
- [ ] No `SCOPE_NOT_LOADED` refs (ref into a scope whose manifest is missing) → Critical
- [ ] **Direction rule (Major → escalates to Critical if production)**: ui → patterns → components → design only. Upward refs (`design` → `components`, `components` → `patterns`, `patterns` → `ui`) fail per `schemas/ref-resolver.md § 3.3`.
- [ ] Legacy unprefixed refs (`{semantic.*}`, `{primitive.*}` without `design.` prefix) emit a **deprecation Warning** in v6 (will hard-fail in v7)

Each ref error is reported with **source location** (file + path-to-ref) AND **target** (ref string), per `ref-resolver.md § 10`.

### Scope Enforcement (Critical)
- [ ] `components.json` root keys are limited to `$meta`, `atom`, `molecule`, `organism` — any other root key = **scope violation, Critical**
- [ ] `patterns.json` root keys are `$meta` + pattern names (kebab-case) — no `atom`/`page`/`flow` at root
- [ ] `ui.json` root keys are limited to `$meta`, `page`, `section`, `flow` — no `atom`/`pattern` definitions
- [ ] `design.md` YAML root keys are limited to `$meta`, `primitive`, `semantic`, `mood`, `iconography`, `component` (component only in legacy MD-primary mode; v6 expects component to live in `components.json`)
- [ ] No cross-scope leakage: a `pattern.foo` definition inside `components.json` = Critical

### Diff-Merge Validation (Critical for required-after-merge missing)

For every `atom`, `molecule`, `organism` in `components.json`, run the diff-merge algorithm from `ref-resolver.md § 5` for every (variant × size × state) combination:

```
render(component, { variant, size, state }) = deepMerge(base, variant, size, state)   // last-write-wins
```

After merge, verify:
- [ ] `render.tag` is set (string)
- [ ] `render.classes` is a non-empty array
- [ ] `render.html_template` resolves to an existing file
- [ ] `tokens` block has all required keys for the component type (e.g. button must have a `--btn-bg`-equivalent after merge; input must have bg+fg+border-equivalent)
- [ ] No merged token value is the literal string `null` (use omission, not null, to "unset")
- [ ] Interactive components (`atom.button`, molecule that includes button) have all 5 states present after merge: `rest`, `hover`, `active`, `focus`, `disabled` — partial state coverage = Critical
- [ ] Input-like components have `rest`, `hover`, `focus`, `disabled` (+ `error` where applicable)
- [ ] Every ref produced by the merge resolves through `resolveDeep` without `PATH_NOT_FOUND` or `CIRCULAR_REF`
- [ ] Merge order is **base → variant → size → state** (not configurable); if a tool overrides order, audit fails with a config-mismatch error

Worked merge example traced in the report when a failure occurs (per `ref-resolver.md § 5.4`).

### Variant-Extensions Governance (Major; escalates to Critical if expired > 90 days)

For every atom with a `variant-extensions` block:
- [ ] Every entry has `reason`, `expires`, `extends` (schema requires these — a missing one is a schema-validation Critical, not just a governance Major)
- [ ] `extends` refers to a variant name that actually exists in that atom's canonical `variants` (or the atom's implicit base) — dangling `extends` is Critical
- [ ] `expires` is a real, parseable `YYYY-MM-DD` date
- [ ] **Expired check**: if `expires` is in the past, flag Major — "extension `<name>` on `<atom>` expired `<date>` — promote to canonical `variants` or remove"
- [ ] **Long-expired check**: if `expires` is more than 90 days in the past, escalate to Critical — stale extensions left unreviewed are exactly the sprawl this mechanism exists to prevent
- [ ] Report a count in the summary: "N active extensions, M expired" so the team sees accumulation trending up over time, not just per-run pass/fail

This block exists specifically to prevent the variant-sprawl pattern seen in production apps (11+ ungoverned button variants with no record of why each was added) — treat a growing, un-reviewed `variant-extensions` list as a signal the team needs a design-system review pass, not just a rubber-stamped audit pass.

### Stale Spec Detection (Warning if both `.json` and `.md` present)
- [ ] If `components.json` AND `components.md` both exist → Warning: "Pick one source — `components.md` flagged as **legacy stale spec**. Recommend delete after porting any unique content to JSON."
- [ ] Same rule for `ui.json` + `ui.md`
- [ ] In Hybrid mode, audit reads JSON as the source of truth; MD files are parsed only to surface drift (e.g. atoms present in MD but missing from JSON)

---

## MD-side checks (carried from v5.1)

Run on `design.md` always, and on `components.md` / `ui.md` / `DESIGN.md` when input mode is MD-primary, Legacy MD-only, or Hybrid (for drift reporting).

### Token quality (Critical)
- [ ] YAML frontmatter has BOTH `primitive:` and `semantic:` blocks
- [ ] `## Primitives` section exists and precedes `## Colors`
- [ ] Primitive block has ≥2 color hue scales (e.g., `neutral`, `brand`) + `red` with 50–950 stops
- [ ] If semantic uses pure white/black anywhere, `primitive.colors.base` block exists with `white`/`black`
- [ ] **Color hexes match Tailwind v3.4+ palette** for any Tailwind-named hue. Custom hues must be marked as custom. `base` allowed exact `#ffffff`/`#000000`.
- [ ] Typography primitives include atomic sub-tokens: `family`, `size`, `line-height`, `weight`, `tracking`
- [ ] Shadow primitives are decomposed — each level has `x/y/blur/spread/color` sub-tokens (NOT a single CSS string)
- [ ] Primitive block has numeric scales for: spacing, radius, opacity, blur, border-width, breakpoints
- [ ] No semantic role names inside `primitive:` block (no `primary`, `error`, `success` keys under primitive)
- [ ] Every value inside `semantic:` block references a primitive via `{design.primitive.*}` (v6) or `{primitive.*}` (v5 legacy) ref
- [ ] Spacing scale uses one base unit (4 or 8)
- [ ] At least one shape/radius scale present

### Reference integrity — MD-side (Major)
- [ ] Every `{token.path}` ref in body resolves to YAML frontmatter
- [ ] Every `{primitive.*}` ref inside `semantic:` resolves to a primitive token
- [ ] No primitive→component direct refs (component should ref semantic, not primitive)
- [ ] Component definitions reference at least 1 semantic token each
- [ ] No leaked brand-specific names (`apple-*`, `spotify-*` unless that IS the brand)
- [ ] No raw hex/px in `## Semantic Tokens` / `## Components` body — must be token refs

### Semantic roles (Critical)
- [ ] All required color role groups present: `text` (+ text.state), `surface, background, primary, secondary, tertiary, status, border, overlay, divider`
- [ ] Scale roles (`primary, secondary, tertiary, status.{success,warning,error,info}`) have all 5 stops: `default, darker, dark, light, soft-light`
- [ ] **NO state keys** (`hover, pressed, focused, disabled, active`) anywhere under `semantic.colors.*`
- [ ] `text.state` has: `disable, error+darker, warning+darker, success+darker, info+darker`
- [ ] `border` has role variants + status variants + disable + on-bgcolor
- [ ] Required typography roles: `heading{h1..h4}, body{sm,md,lg}, label{sm,md}, caption{md}`
- [ ] Each typography role has all 5 sub-keys: `family, size, line-height, weight, tracking`
- [ ] **If a typography role has `responsive:`** — every tier key under it exists in `semantic.breakpoints` (no invented tier names); each tier is diff-only (does not repeat unchanged sub-keys from base); base 5 keys still present on the role itself (responsive tiers augment, never replace, the base)
- [ ] `spacing`, `radius`, `border-width`, `elevation`, `breakpoints` all present in semantic

### WCAG AA — Accessibility (Critical)

Audit enforces WCAG 2.1 Level AA at spec level (catches issues BEFORE code is written).

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

**Tier: components (atomic) — MD or JSON**

In JSON mode, these checks run on the merged output of `render(...)`. In MD mode, they parse the prose component table.

- [ ] Every atom has `a11y:` block (button / icon / input / label / helper-text / avatar / badge)
- [ ] atom.button declares `hit-area-min: 44` (or `a11y.touch_min: "44px"` in JSON); sizes with visual height < 44 declare invisible padding workaround
- [ ] atom.icon has required-one-of (`aria-hidden` OR `aria-label`)
- [ ] atom.input has required-attrs (`id`, `aria-describedby`) + label association
- [ ] molecule.nav-item declares `aria-current` for selected state
- [ ] molecule.form-field error state declares `aria-invalid` + `role="alert"` on helper
- [ ] organism.sidebar declares landmark `nav` + `aria-label`
- [ ] organism.modal declares role `dialog`, `aria-modal`, focus-trap, ESC-close
- [ ] Every `a11y.contrast_pair` in JSON resolves and passes its `min_ratio` (default 4.5)

**Tier: ui (compositions) — MD or JSON**
- [ ] Every page declares `a11y.h1` slot exactly once
- [ ] Every page declares `a11y.landmarks` listing main + (nav, header, contentinfo)
- [ ] Every page declares `a11y.skip-link` with target `#main`
- [ ] Every page declares `a11y.page-title` format
- [ ] Every flow declares `live-region` + `back-button` aria-label
- [ ] Every section declares heading-level

### Known Gaps reserved keywords (v6.0.0+) — informational, do NOT flag as errors
- `shifted from client-provided #XXXXXX → ...` — client palette honored, semantic mapping shifted
- `mapped from client #XXXXXX → tailwind.<hue>.<stop>` — client hex snapped to Tailwind ladder
- `custom hue generated from client #XXXXXX → primitive.colors.<name>.50..950` — non-Tailwind hex, brand ladder generated
- `TBD: <free-form>` — open work, treat as Warning (Minor)

See `design-builder/NAMING.md § 12` for full format spec.

### Mood & Iconography (Critical)
- [ ] `mood.primary` is set (not `'tbd'` or missing)
- [ ] `mood.primary` is one of the canonical 6: `bold-tech | friendly-warm | premium-editorial | playful-vivid | technical-dev | calm-focused`
- [ ] `## Mood & Tone` body section exists with token decisions table
- [ ] Token defaults align with mood (e.g., `calm-focused` should NOT have `pill` radius default)
- [ ] If `iconography:` block has populated values (no `'tbd'`), validate: style is a known style, sizes ref semantic, colors ref semantic
- [ ] If `iconography:` block is all `'tbd'`, surface as INFO: "Run `design-icon-builder` to populate"

### Component layer — MD-primary mode only (Critical IF present)
- [ ] If no `component:` block and no `components.json` → INFO: "Run `design-component-builder` to add components"
- [ ] If `component:` block exists, must contain `atom:` / `molecule:` / `organism:` keys (3-tier)
- [ ] Old flat shape (no tier nesting) → Critical: must migrate to atomic
- [ ] **Prop name check**: NO `surface`, `content`, `edge`, `elevation`, `focus-halo` used as a component prop — must use `background`, `foreground`, `border`, `shadow`, `ring` (per NAMING.md § Prop names — shadcn + DTCG vocab, one word every layer, no swap). Does not apply to the semantic color role `surface` (`{semantic.colors.surface.*}`), which is a different, unrelated token category and keeps its name.
- [ ] **State alias check**: NO `default`, `pressed`, `focused` keys — must use `rest`, `active`, `focus`
- [ ] **Ambiguous `active` check**: if `active` appears, verify it's pressed-state. If it's nav-current, must rename to `selected`
- [ ] **`disabled`-as-variant check**: `disabled` must never appear as a variant name (e.g. a `variants.disabled` entry) — only as a state present on every variant. A `disabled` variant alongside per-variant `disabled` states is a Critical finding (real-world anti-pattern)
- [ ] Tier flow valid (organism → molecule/atom, molecule → atom)
- [ ] No upward refs (atom must NOT ref molecule/organism)
- [ ] Tier A (always required): `button`, `input`, `card`
- [ ] **Tier B/C/D/E rule** — for each tier, either ALL 4 components present OR Known Gaps explicitly lists the tier with a reason
  - Tier B (Form): `checkbox`, `radio`, `toggle`, `select`
  - Tier C (Feedback): `badge`, `alert`, `toast`, `tooltip`
  - Tier D (Navigation): `tab`, `nav-link`, `breadcrumb`, `pagination`
  - Tier E (Overlay): `modal`, `drawer`, `popover`, `dropdown`
- [ ] **No partial tier** — if a tier has 1-3 components present but not all 4, audit fails
- [ ] If a tier is skipped, Known Gaps MUST name it explicitly: `**Tier X (name)** — skipped because <reason>`
- [ ] `button` has all 5 variants: primary, secondary, tertiary, ghost, destructive
- [ ] `alert` / `toast` have all 4 status channels (info/success/warning/error)
- [ ] Mandatory props per component type present (button: background+foreground; input: background+foreground+border; card: background)
- [ ] Every state value is `{design.semantic.*}` / `{semantic.*}` ref OR literal `'transparent'` / `'none'`
- [ ] NO `{design.primitive.*}` refs in `component:` block (3-tier separation)
- [ ] NO raw hex / px in `component:` block
- [ ] State is LAST path segment (`bg.hover`, not `hover.bg`)
- [ ] No invented state names (only: rest, hover, active, focus, disabled, selected, error)
- [ ] ## Component Tokens section present with table of components × variants × props × states

### Mode coverage (Major)
- [ ] If ANY leaf uses dark mode, EVERY leaf has both `light` AND `dark` (no half-coverage)
- [ ] Mode never appears in token path (only at leaf level as `{ light, dark }`)
- [ ] Mode keys are exactly `light` / `dark` / `high-contrast` — no custom mode names

### Naming compliance (Major) — per NAMING.md
- [ ] No snake_case keys anywhere (no `soft_light`, `gray_light`, `super_black`)
- [ ] No camelCase keys (no `lineHeight`, `fontFamily`)
- [ ] No brand-suffix hue names (no `apple-blue`, `lottoplus-red`)
- [ ] No `grey` vs `gray` mixing — pick one and stick (Tailwind uses `gray`)
- [ ] No mode-as-prefix patterns (no `mobile-heading1`, `desktop-display-l` in YAML)
- [ ] State appears ONLY in component layer paths — never in semantic or primitive

### Content depth (Major)
- [ ] Do's and Don'ts has ≥6 pairs
- [ ] Components section covers ≥4 component types
- [ ] Responsive Behavior names ≥3 breakpoints

### Honesty (Minor)
- [ ] Known Gaps is non-empty
- [ ] Iteration Guide explains how to add tokens AND components

---

## Component / Pattern / Page HTML Coverage

Verifies that the manifest is backed by real HTML preview files on disk. Run alongside the manifest checks above. Source key adapts to input mode (JSON path or MD spec).

### Source mapping

| Input mode | Atom source | Pattern source | Page source |
|---|---|---|---|
| JSON-primary | `components.json` → keys under `atom` / `molecule` / `organism` | `patterns.json` → kebab-case root keys | `ui.json` → keys under `page` |
| MD-primary (v5) | `components.md` → `component.atom.*` | (n/a — patterns layer is JSON-only) | `ui.md` → `ui.page.*` |
| Legacy MD-only | `DESIGN.md` → `component.*` (flat) | (n/a) | (n/a) |

### Checks
- [ ] `tokens.css` exists at the design system root (error if components manifest is present but `tokens.css` missing — components depend on tokens being materialized as CSS variables)
- [ ] For each atom name in the components source, a file `components/<atom>.html` exists (error per missing atom)
- [ ] For each molecule / organism name, a file `components/<name>.html` exists (error per missing — molecules and organisms are also rendered)
- [ ] `components.html` showcase file exists at root (warning if missing)
- [ ] For each page name in the ui source, a file `pages/<page>.html` exists (error per missing page)
- [ ] For each pattern name in `patterns.json` (JSON-primary mode only), a file `patterns/<name>.html` exists (error per missing pattern)
- [ ] JSON mode: every `render.html_template` path declared in `components.json` / `ui.json` resolves to an existing file (cross-check: declared path vs convention path)

### Severity table

| Check | Severity | Behavior on fail |
|---|---|---|
| `tokens.css` missing (when components manifest present) | **error** | Counts toward Critical; blocks pass verdict |
| `components/<atom>.html` missing (per atom) | **error** | Counts toward Critical per missing file |
| `components/<molecule>.html` / `<organism>.html` missing | **error** | Counts toward Critical per missing file |
| `components.html` showcase missing | **warning** | Surfaced as Minor; does not block |
| `pages/<page>.html` missing (per page) | **error** | Counts toward Critical per missing file |
| `patterns/<name>.html` missing (per pattern) | **error** | Counts toward Critical per missing file |
| `render.html_template` path mismatch (JSON only) | **warning** | Minor; recommend updating path |

Report missing files with both the spec source (e.g. `components.json#/atom/button`) and the expected file path (`components/button.html`) so the user knows exactly which file to create.

---

## Execution Steps

### 0.5. Check migration flag
- If `--migrate-to-json` (or legacy `--migrate`) is set → **route to Migration Mode** (see [§ Migration Mode](#migration-mode---migrate-to-json)); SKIP all audit steps below
- Otherwise → continue to audit

### 1. Detect input mode
- Scan entry directory for `design.md`, `components.{json,md}`, `patterns.json`, `ui.{json,md}`, `DESIGN.md`
- Apply the detection table above to pick one of: JSON-primary / MD-primary / Hybrid / Legacy MD-only
- Log detection result + file list to stderr (visible in console output)
- Print banner at top of report

### 1a. JSON Schema Validation (skip in MD-primary / Legacy / `json=false`)
- For each manifest file present:
  - Load and parse as JSON
  - Validate against `schemas/<scope>.schema.json` using JSON Schema Draft-07
  - Report schema errors with **JSON Pointer paths** and the offending value
  - Halt deeper analysis of a manifest only if schema validation fails at the `$meta` level — otherwise continue so designers see all problems at once

### 1b. Build ref index
- Walk every manifest (parsed YAML or JSON) and collect every ref string + its source location (file path + JSON pointer / YAML line)
- Build a lookup of all valid target paths per scope (every key in every loaded manifest)
- Apply legacy unprefixed-ref normalization (`{semantic.*}` → `{design.semantic.*}`) per `ref-resolver.md § 7.1`; emit deprecation Warnings

### 1c. Resolve refs + check direction + check scope
- For each ref:
  1. Match against the canonical regex; report `INVALID_SYNTAX` if it fails
  2. Determine caller scope from the source file's `$meta.scope`
  3. Apply direction rule via `rank()` — flag `UPWARD_REF` if caller rank < target rank
  4. Walk the dot-path; flag `PATH_NOT_FOUND` if any segment misses
  5. Detect circular chains via `resolveDeep` seen-set
- For each manifest, verify `$meta.scope` matches expected scope (components-only / patterns-only / ui-only / design) and root keys stay within the allowed set; cross-scope keys = Critical

### 1d. Diff-merge validation (JSON-primary / Hybrid only)
- For each component in `components.json` (atom / molecule / organism):
  - Enumerate every (variant × size × state) combo declared
  - Run `render(component, { variant, size, state })` per `ref-resolver.md § 5.2`
  - Validate the merged result has all required fields (tag, classes, html_template, tokens, a11y where applicable)
  - Run `resolveDeep` on every ref in the merged output; flag broken/circular refs with the combo context (`atom.button × variant=secondary × size=lg × state=hover`)
  - Verify state-coverage rules (interactive components have rest/hover/active/focus/disabled; input-like have rest/hover/focus/disabled + optional error)

### 2. Parse structure (MD side, always)
- Extract YAML frontmatter from `design.md` (+ `components.md`, `ui.md`, `DESIGN.md` when present) — validate it parses
- List all `## headings` in order
- For each heading, count subsections + measure section length (lines)

### 3. Run remaining checks (mark each pass/fail with severity)

Run the MD-side check sections above conditionally:

| Section | When to run |
|---|---|
| Required sections — design.md | Always |
| Token quality | Always |
| Reference integrity — MD-side | Always (v6 ref resolver handles JSON-side) |
| Semantic roles | Always |
| WCAG AA — tokens tier | Always |
| WCAG AA — components tier | Always; uses merged output in JSON mode, prose table in MD mode |
| WCAG AA — ui tier | Always; uses JSON in JSON mode, prose in MD mode |
| Known Gaps keywords | Always (informational) |
| Mood & Iconography | Always |
| Component layer — MD | **MD-primary** or **Legacy MD-only** only — skipped in JSON-primary mode |
| Mode coverage | Always |
| Naming compliance | Always |
| Content depth | Always |
| Honesty | Always |

### 4. HTML coverage
- Resolve atom / molecule / organism / pattern / page names from the input-mode source (JSON or MD)
- For each name, check the conventional file exists; in JSON mode also verify the `render.html_template` declared path
- Roll up missing-file errors per the severity table above

### 5. Output report
See [Output Report Format](#output-report-format) below.

### 6. No auto-fix
Audit only — do NOT edit files. Report findings; let user choose fix path.

---

## Output Report Format

```markdown
# Design System Audit — <entry path>

**Input mode:** JSON-primary | MD-primary | Hybrid (warn) | Legacy MD-only
**Files detected:** <list of files with schema versions where applicable>
**Verdict:** ✅ Pass / ⚠️ Pass with warnings / ❌ Fail

## Summary
- Sections: X / 13 (X required, X recommended, X nice-to-have)
- JSON Schema: ✓ N manifests valid / ✗ N invalid
- Refs: N resolved / N broken / N upward / N legacy-deprecation
- Diff-merge: N combos validated / N failures
- HTML coverage: N atoms, N pages, N patterns — N missing
- Critical: N issues
- Major:    N issues
- Minor:    N issues

## Critical issues
1. [<file>#<json-pointer or section>] — what's wrong — how to fix
2. ...

## Major issues
...

## Minor issues
...

## Strengths
- What this DS does well (1-3 bullets)

## Recommended next action
- Migrate MD components to JSON (run `design-component-builder` v6+), OR
- Patch X, Y, Z manually
```

When a diff-merge failure occurs, the report includes the merge trace (base → variant → size → state) per `ref-resolver.md § 5.4` so designers can see exactly which layer overrode the failing token.

---

## Severity Definitions
- **Critical** — blocks coding agents from using the spec correctly (missing tokens, broken JSON schema, no components manifest, broken refs, upward refs, scope violations, missing HTML files, failed diff-merge required fields)
- **Major** — degrades quality but agents can still work (missing Iteration Guide, weak Do/Don't, mode coverage half-done, legacy unprefixed refs that will fail in v7)
- **Minor** — polish items (no Agent Prompt Guide, sparse Known Gaps, stale MD file alongside JSON, `render.html_template` path drift)

Verdict thresholds:
- ✅ Pass: 0 Critical, ≤2 Major
- ⚠️ Pass with warnings: 0 Critical, 3-5 Major
- ❌ Fail: any Critical, OR >5 Major

---

## Backward Compat

v6 is the **bridge release** between MD-only (v5) and JSON-only (v7).

| Feature | v5.1 | v6 (this release) | v7 (planned) |
|---|---|---|---|
| MD-primary audit (components.md + ui.md) | ✓ supported | ✓ supported (warns on hybrid) | ✗ removed |
| Legacy monolithic DESIGN.md | ✓ supported | ✓ supported (recommends `--migrate`) | ✗ removed |
| JSON Schema validation | n/a | ✓ run when JSON present | ✓ always |
| Brace ref resolver + direction rule | partial (no formal regex) | ✓ canonical regex, enforced | ✓ |
| Diff-merge validation | n/a | ✓ JSON mode | ✓ |
| Legacy unprefixed refs (`{semantic.*}`) | accepted silently | accepted with **deprecation Warning** | rejected (INVALID_SYNTAX) |
| `--format=md` legacy flag | accepted | accepted | removed |
| `json=false` arg | n/a | ✓ forces MD-only audit | ✓ deprecated then removed |
| `--migrate` (mono → 3-file MD) | n/a | ✓ accepted, aliased to `--migrate-to-json` (chains mono → MD → JSON) | removed |
| `--migrate-to-json` (MD → JSON) | n/a | ✓ **recommended v5→v6 path** (v6.1+) | ✓ |
| Patterns layer | n/a | ✓ JSON-only (no MD form ever) | ✓ |

**Upgrade guidance (recommended path for v5 → v6 teams):**
1. Run `/design-md-audit --migrate-to-json` to convert `components.md` + `ui.md` (+ monolithic `DESIGN.md` if present) into `components.json` + `ui.json` + `patterns.json` in one run. Migration is idempotent and non-destructive — `.md` files are preserved.
2. Manually review LOW-confidence pattern extractions flagged in the migration report.
3. Re-run `/design-md-audit` (no flag) to validate the resulting JSON layout against schemas.
4. After verification, delete `components.md` and `ui.md` to silence the hybrid-mode warning.

**Alternative manual path:** repos can also fix Critical audit issues first, then re-run `design-component-builder` v6+ to emit `components.json` from scratch. The `--migrate-to-json` route is faster and preserves all hand-written prose.

---

## Constraints
- Read-only — never edit any file
- If a manifest > 200KB, sample sections rather than full read (note in report)
- Do NOT compare to a specific brand reference unless user asks
- Do NOT rate "design quality" — only structural completeness and schema/ref/HTML correctness
- Always include source location (file + JSON pointer or YAML line) in every error message — per `ref-resolver.md § 10`

## Quality Bar
Report must be actionable — every issue tells user exactly which file + JSON pointer (or section + line) to fix.
No vague feedback like "improve typography" — instead "Typography section missing line-height values for body/heading roles" or "components.json#/atom/button/states/hover/tokens/background → PATH_NOT_FOUND in design.semantic.color.primary.hovr (typo, did you mean 'hover'?)".
