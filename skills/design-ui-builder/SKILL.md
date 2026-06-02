---
name: design-ui-builder
description: Build the ui.json manifest + patterns.json manifest + per-page HTML files + per-pattern HTML shells in a split-architecture design system. Reads design.md (tokens, YAML-in-MD) + components.json (atomic catalog) + components/*.html (markup source for inlining into pages). Emits ui.json (page/section/flow compositions, per schemas/ui.schema.json), patterns.json (reusable cross-page shells like auth-split / app-shell / empty-state / hero-grid, per schemas/patterns.schema.json), pages/<name>.html (self-contained — inlines component markup, no iframes), and patterns/<name>.html (template shells with slot placeholders). Pages compose either via a pattern + slot_fills OR direct composes []. Slot contract types — component | section | pattern | inline_html | text | image | icon. Refs use brace syntax {file.path.to.thing} per DTCG; downward only (ui → patterns → components → design). Prefers organism refs over atom refs (promote to molecule/organism if composing atoms directly). Legacy --format=md flag emits ui.md alongside ui.json (deprecated, removed v7). Triggers on "build ui", "build pages", "build patterns", "ui compositions", "create ui.json", "patterns.json", "สร้าง pages", "ui layer", "page composition", "slot fills".
version: 4.0.0
user-invokable: true
args:
  - name: source-design
    description: Path to design.md (default ./design.md)
    required: false
  - name: source-components
    description: Path to components.json (default ./components.json)
    required: false
  - name: components-html-dir
    description: Directory containing per-component HTML files (default ./components/)
    required: false
  - name: categories
    description: "Comma-separated categories to build: page,pattern,section,flow or 'all'. Default: page,pattern"
    required: false
  - name: format
    description: "Output format. 'json' (default v4+) emits ui.json + patterns.json. 'md' (legacy, v5–v6, removed v7) ALSO emits ui.md alongside ui.json. Emits a deprecation warning."
    required: false
---

# 🖼️ Design UI Builder — v4.0.0

Top layer of the split-architecture design system. Reads `design.md` + `components.json` + `components/*.html` → emits `ui.json` + `patterns.json` + `pages/*.html` + `patterns/*.html`.

## What changed in v4 (vs v2)

| v2 (legacy) | v4 (current) |
|---|---|
| Reads `components.md` | Reads `components.json` (atomic JSON catalog) |
| Emits `ui.md` (YAML-in-MD spec) | Emits `ui.json` (JSON manifest, schema-validated) |
| Patterns lived inside `ui.md` under `ui.pattern.*` | Patterns extracted into separate `patterns.json` |
| No pattern HTML shells | Emits `patterns/<name>.html` (template shells with `<slot>` placeholders) |
| Slot fills loose YAML | Slot contract enforced — `accepts` types validated per pattern |
| Refs `{components.organism.*}` already prefixed | Same DTCG brace syntax; direction rule unchanged |
| No format flag | `--format=md` re-emits legacy `ui.md` (deprecated, removed v7) |

## When to use
- `./design.md` + `./components.json` already exist (run `design-builder` + `design-component-builder` first)
- Want to define pages / patterns / sections / flows as a structured JSON spec a coding agent can consume
- Need self-contained `pages/*.html` that render in a browser without a build step

## When NOT to use
- No `./design.md` → run `design-builder` first
- No `./components.json` → run `design-component-builder` first
- Want to render the design system as a viewable style guide → use `design-styleguide`
- Want to validate cross-file refs → use `design-md-audit`

## UI taxonomy — 4 categories

| Category | Lives in | Definition | Examples |
|---|---|---|---|
| **page** | `ui.json` → `page.*` | Full screen with a route | login, dashboard, settings, pricing |
| **pattern** | `patterns.json` (NEW) | Reusable cross-page shell with named slots | auth-split, app-shell, empty-state, hero-grid |
| **section** | `ui.json` → `section.*` | Marketing/landing block (composed of components) | hero, pricing-table, testimonial, cta-banner |
| **flow** | `ui.json` → `flow.*` | Multi-step sequence (page refs + transitions) | signup, onboarding, checkout |

Patterns are **structural shells with slots** — they declare a contract (`slots[]` with `name`, `required`, `accepts`). Pages either **fill** those slots (`pattern` + `slot_fills`) OR **compose** components directly (`composes[]`). Never both on the same page.

## Inputs (dependency chain)

```
design.md (YAML-in-MD, tokens)              ← unchanged, designer-facing
  ↑ referenced by
components.json (atomic catalog)            ← from design-component-builder v4+
components/<atom|molecule|organism>.html    ← HTML markup source for inlining
  ↑ both consumed by THIS skill
ui.json + patterns.json + pages/*.html + patterns/*.html ← OUTPUT
```

Required inputs:
- `./design.md` — must exist, `$meta.scope: design` (YAML-in-MD, UNCHANGED format)
- `./components.json` — must exist, `$meta.scope: components`, schema `uxui/components/v1`
- `./components/*.html` — per-component HTML (one file per atom/molecule/organism). Used as the markup source when inlining components into `pages/*.html`. If missing, emit a warning and continue in spec-only mode (pages will reference components but markup won't be inlined).

If `design.md` or `components.json` is missing → ABORT with clear next-step instruction.

## Ref syntax (carryover)

- Format: `{scope.path.to.thing}` — DTCG-aligned brace alias.
- Regex: `^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$`
- Direction: `ui → patterns → components → design` (downward only). Any upward ref is an audit error.
- `dtcg_version` pinned to `draft-2024-08-09` in `$meta`.

## Execution Steps

### Step 1. Read `design.md`
- Parse the YAML frontmatter + body. Confirm `$meta.scope: design`.
- Note the mood (informs pattern decisions — `auth-split` density, `hero-grid` whitespace).
- Build a flat token registry for downstream ref resolution.

### Step 2. Read `components.json`
- Parse JSON. Confirm `$meta.scope: components`, `$meta.schema: uxui/components/v1`.
- Build an atomic catalog: list of all atoms, molecules, organisms (full keys with variants/sizes/states stripped to top-level names).
- This is what the agent uses to know **what's available to compose with** — no need to read the HTML files for this.

### Step 3. Read `components/*.html`
- Read every file in the components HTML directory.
- For each file, extract the **real component markup** — strip the demo wrapper (preview chrome, h1 titles, swatch grids, padding containers used only for the standalone preview).
- Build a markup manifest: `{ <component-name>: <inline-markup-string> }`.
- This is only used in Step 6 when inlining into pages. Patterns do NOT inline component markup — patterns hold slot placeholders.

### Step 4. Plan UI scope
Default categories: `page, pattern`. Use `--categories` to extend.

Ask the user (multi-select):
- **Pages**: which routes? (signin, signup, dashboard, settings, profile, billing, pricing, 404, …)
- **Patterns**: which shells? (auth-split, app-shell, empty-state, error-state, loading, hero-grid, modal-shell, split-view, …)
- **Sections**: which marketing blocks? (hero, pricing-table, testimonial, cta-banner, faq, feature-grid, logo-cloud, …)
- **Flows**: which sequences? (signup, onboarding, checkout, password-reset, invite-team, …)

For each picked pattern, also decide its slot contract (see Step 5).

### Step 5. Build `patterns.json` + `patterns/<name>.html`

For each pattern:

#### 5a. Add an entry to `patterns.json`

```json
{
  "$meta": {
    "schema": "uxui/patterns/v1",
    "scope": "patterns-only",
    "depends_on": ["./design.md", "./components.json"],
    "dtcg_version": "draft-2024-08-09",
    "version": "1.0.0",
    "generated_by": "design-ui-builder@4.0.0",
    "generated_at": "<ISO-8601>"
  },
  "auth-split": {
    "id": "auth-split",
    "summary": "Two-column auth layout — brand left, form right.",
    "slots": [
      { "name": "hero",   "required": true,  "accepts": ["component","section","inline_html","image"], "summary": "Left column brand panel" },
      { "name": "form",   "required": true,  "accepts": ["component"],                                  "summary": "Right column auth form" },
      { "name": "footer", "required": false, "accepts": ["component","inline_html","text"],            "default": "{components.molecule.legal-footer}" }
    ],
    "composes": [],
    "html_template": "patterns/auth-split.html",
    "tokens": {
      "background_hero": "{design.semantic.color.surface.brand}",
      "background_form": "{design.semantic.color.surface.canvas}",
      "gutter": "{design.semantic.spacing.layout.gutter-lg}"
    },
    "breakpoints": { "sm": { "layout": "stack", "hero_visible": false }, "md": { "layout": "two-column", "split_ratio": "1:1" } },
    "variants": { "reversed": { "slots_order": ["form","hero"] } },
    "a11y": { "landmarks": ["main"], "focus_order": ["form"] }
  }
}
```

**Rules:**
- Pattern keys are kebab-case at the root of `patterns.json` (no top-level wrapper object).
- `composes[]` lists components built INTO the pattern (not slot-fillable) — e.g. `app-shell` composes `{components.organism.navbar}` as a fixed structural part.
- `breakpoints` / `variants` are **diff-only** — include only keys that differ from base. Merge order: `base → variant → size → state` (last-write-wins, per ref-resolver §5).
- All token refs use `{design.semantic.*}` form.
- All component refs use `{components.<atom|molecule|organism>.*}` form.

#### 5b. Write `patterns/<name>.html`

A pattern HTML file is a **shell with `<slot>` placeholders** — NOT a self-contained page. It's the template a page renders into when it picks this pattern.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="../tokens.css">
  <style>
    /* pattern-specific layout: grid, slot positions, responsive rules */
    .auth-split { display: grid; grid-template-columns: 1fr 1fr; min-height: 100vh; }
    @media (max-width: 768px) { .auth-split { grid-template-columns: 1fr; } .auth-split [data-slot="hero"] { display: none; } }
  </style>
</head>
<body>
  <main class="auth-split">
    <aside data-slot="hero"><slot name="hero"></slot></aside>
    <section data-slot="form"><slot name="form"></slot></section>
    <footer data-slot="footer"><slot name="footer"></slot></footer>
  </main>
</body>
</html>
```

**Rules:**
- Each declared slot appears as `<slot name="<slot-name>"></slot>` inside an element with `data-slot="<slot-name>"`.
- Patterns include `<link rel="stylesheet" href="../tokens.css">` — never inline token values.
- Patterns may render in-browser as a hollow shell (useful for previewing layout); they are NOT self-contained — they expect pages to fill the slots.

### Step 6. Build `ui.json` + `pages/<name>.html`

For each page:

#### 6a. Add an entry to `ui.json`

Two shapes — **pattern-based** OR **direct composition**, never both:

**Pattern-based (preferred when a pattern fits):**
```json
"signin": {
  "id": "signin",
  "summary": "Sign-in screen using auth-split.",
  "pattern": "{patterns.auth-split}",
  "slot_fills": {
    "hero":   "{components.organism.marketing-brand-panel}",
    "form":   "{components.organism.signin-form}",
    "footer": "{components.molecule.legal-footer}"
  },
  "html_template": "pages/signin.html",
  "meta": { "title": "Sign in", "description": "Sign in to your account", "lang": "en" }
}
```

**Direct composition:**
```json
"dashboard": {
  "id": "dashboard",
  "summary": "Main app dashboard.",
  "composes": [
    "{components.organism.app-shell}",
    "{components.organism.nav-bar}",
    "{components.organism.side-nav}",
    "{components.organism.dashboard-stats}",
    "{components.organism.activity-feed}",
    "{components.organism.app-footer}"
  ],
  "html_template": "pages/dashboard.html",
  "meta": { "title": "Dashboard", "lang": "en" }
}
```

For sections + flows, follow `examples/ui.example.json`:
```json
"section": {
  "hero": {
    "id": "hero",
    "composes": ["{components.molecule.hero-headline}", "{components.atom.button.variants.primary}"],
    "html_template": "sections/hero.html"
  }
},
"flow": {
  "signup": {
    "id": "signup",
    "steps": [
      { "page": "{ui.page.signin}", "transitions": { "on_success": "{ui.page.onboarding}" } },
      { "page": "{ui.page.onboarding}", "transitions": { "on_success": "{ui.page.dashboard}", "on_back": "{ui.page.signin}" } }
    ]
  }
}
```

Flow `transitions` values are EITHER refs (`{ui.page.*}`) OR absolute URLs (`^https?://`).

#### 6b. Write `pages/<name>.html` — SELF-CONTAINED

Pages are end-to-end renderable in a browser with no build step. Component markup is **inlined** from the Step-3 manifest — NEVER iframed, NEVER `<link>`ed, NEVER fetched at runtime.

**For pattern-based pages:**
1. Open the pattern's `html_template` (e.g. `patterns/auth-split.html`) — use it as the structural scaffold.
2. For each entry in `slot_fills`, replace the corresponding `<slot name="X"></slot>` placeholder:
   - If the fill is a `{components.<...>}` ref → look up the markup in the Step-3 manifest and paste it inline.
   - If the fill is a `{patterns.<...>}` ref → recursively expand that pattern's shell + its slot fills.
   - If the fill is an inline string (no brace) → paste it as-is (inline HTML/text/image markup).
3. Validate that **every required slot** declared by the pattern is filled. If a required slot is missing in `slot_fills` AND the slot has no `default`, emit a "Known Gap" entry and leave the placeholder as `<!-- TODO: fill slot <name> -->`.

**For direct-composition pages:**
1. Build the page from scratch with the page's own layout `<style>`.
2. For each ref in `composes[]`, inline the component markup at the appropriate slot position.

**Common rules for both:**
- Include `<link rel="stylesheet" href="../tokens.css">` in `<head>`.
- Include a page-specific `<style>` block for layout only (grid, slot positions). Never duplicate component styles.
- Emit accessible structure per the page's `meta` + a11y conventions: `<title>` (from `meta.title`), `<a href="#main" class="skip-link">Skip to content</a>`, `<main id="main">…</main>`, exactly one `<h1>`, `<nav aria-label="...">` where applicable.
- When inlining, strip the demo wrapper from the source `components/*.html` — keep only the real component markup.
- `lang` attribute on `<html>` comes from `meta.lang` (default `en`).

**Skeleton:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><!-- from meta.title --></title>
  <link rel="stylesheet" href="../tokens.css">
  <style>/* page-specific layout */</style>
</head>
<body>
  <a href="#main" class="skip-link">Skip to content</a>
  <!-- inlined header markup -->
  <main id="main">
    <h1><!-- page heading --></h1>
    <!-- inlined slot fills OR direct composes -->
  </main>
  <!-- inlined footer markup -->
</body>
</html>
```

### Step 7. Legacy `--format=md` (deprecated)

If invoked with `--format=md`:
1. Do everything above (emit `ui.json`, `patterns.json`, `pages/*.html`, `patterns/*.html`).
2. ADDITIONALLY emit a legacy `ui.md` file (YAML-in-MD, v2 shape — `ui.page.*` / `ui.pattern.*` / `ui.section.*` / `ui.flow.*`) for v5/v6 consumers.
3. Emit a deprecation warning to stdout:
   ```
   ⚠️  DEPRECATION: --format=md is supported in v5 and v6 only and will be removed in v7.
       ui.md is a legacy artifact — new tooling should consume ui.json + patterns.json directly.
       Track migration in: docs/architecture-v5.md
   ```

The legacy `ui.md` MUST NOT be the source of truth — `ui.json` + `patterns.json` are canonical even when both are emitted.

## Slot Contract Details

### Pattern declares the contract
Every pattern in `patterns.json` declares its slots as an array of `Slot` objects:

```json
{
  "name": "hero",                                  // kebab-case slot identifier
  "required": true,                                // pages MUST fill this slot
  "accepts": ["component","section","inline_html","image"],  // allowed fill types
  "summary": "Left brand panel",                   // optional human description
  "default": "{components.molecule.brand-mark}"    // optional fallback if unfilled
}
```

`accepts` enum:
| Type | What a page may provide |
|---|---|
| `component` | A `{components.<atom\|molecule\|organism>.*}` ref |
| `section` | A `{ui.section.*}` ref |
| `pattern` | A nested `{patterns.<...>}` ref (pattern composition) |
| `inline_html` | A raw HTML string literal (no brace prefix) |
| `text` | A plain text string |
| `image` | A `{design.semantic.asset.*}` ref OR an inline `<img>` tag |
| `icon` | A `{design.iconography.*}` ref OR an inline `<svg>` |

### Page fills the contract

In `ui.json`, `slot_fills` is an object keyed by slot name:

```json
"slot_fills": {
  "hero":   "{components.organism.marketing-brand-panel}",   // component ref
  "form":   "{components.organism.signin-form}",             // component ref
  "footer": "<p class='legal'>© 2026 Example Inc.</p>"        // inline_html
}
```

**Validation rules (enforced by Step 7 + downstream audit):**
- Every `required: true` slot declared by the referenced pattern MUST appear in `slot_fills` (unless the slot has a `default`).
- Each fill's type MUST be in the slot's `accepts` array. A component ref into a `text`-only slot is an error.
- Inline strings are detected by `not matching ^\{(design|components|patterns|ui)\.`.

## Backward Compat (`--format=md`)

Same behavior as Step 7. Summary:
- **v4** — default `--format=json`; `--format=md` works, prints deprecation warning, emits both.
- **v5–v6** — `--format=md` still supported with warning.
- **v7** — flag removed entirely; only JSON output.

Legacy `ui.md` consumers (the old `design-styleguide` v1, hand-written reviewers) should migrate to JSON-aware tooling before v7.

## Validation Checklist

Run this before declaring done. Audit (`design-md-audit`) re-runs the same checks.

**Schema validity**
- [ ] `ui.json` validates against `schemas/ui.schema.json`
- [ ] `patterns.json` validates against `schemas/patterns.schema.json`
- [ ] `$meta.schema`, `$meta.scope`, `$meta.dtcg_version`, `$meta.version` present in both files

**Cross-file refs**
- [ ] Every ref matches the regex `^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$`
- [ ] Every `{components.*}` ref resolves to an entry in `components.json`
- [ ] Every `{patterns.*}` ref in `ui.json` resolves to an entry in `patterns.json`
- [ ] Every `{design.*}` ref resolves to a YAML path in `design.md`
- [ ] NO upward refs (audit error): `patterns → ui`, `components → patterns|ui`, `design → anything`
- [ ] NO bare-path refs (`{semantic.*}` without `design.` prefix → fail, unless explicitly running legacy-compat mode)

**Slot contract**
- [ ] Every page using `pattern` has `slot_fills` (or empty if all slots optional w/ defaults)
- [ ] Every `required: true` slot of the referenced pattern is filled (OR has a `default`)
- [ ] Every fill's type is allowed by the slot's `accepts` array
- [ ] No page declares BOTH `pattern` and `composes` (mutually exclusive per schema `oneOf`)

**HTML output**
- [ ] Every `page.<name>.html_template` file exists on disk
- [ ] Every `pattern.<name>.html_template` file exists on disk
- [ ] Every `section.<name>.html_template` file exists (if declared)
- [ ] `pages/*.html` are self-contained — no `<iframe>`, no `<link>` to component files, no runtime `fetch` of components
- [ ] `pages/*.html` and `patterns/*.html` include `<link rel="stylesheet" href="../tokens.css">`
- [ ] Each `pages/*.html` has exactly one `<h1>`, a skip link to `#main`, and `<main id="main">` landmark

**Composition quality**
- [ ] Pages prefer organism refs over atom refs (warn if a page composes 3+ atoms directly without an organism wrapper — promote to a molecule/organism in `components.json` first)
- [ ] Patterns have at least one slot declared
- [ ] Flows reference only `{ui.page.*}` refs OR absolute URLs in transitions

**Reporting**
- [ ] Dangling refs (component referenced but not in `components.json`) listed as Known Gaps in the agent's final report
- [ ] If `--format=md` used, deprecation warning emitted

## Output Format Rules (directory layout)

```
project-root/
├── design.md                      ← input (YAML-in-MD, unchanged)
├── components.json                ← input (from design-component-builder v4+)
├── components/                    ← input (one HTML file per component)
│   ├── button.html
│   ├── nav-bar.html
│   └── signin-form.html
├── tokens.css                     ← input (generated by design-builder)
│
├── patterns.json                  ← OUTPUT (NEW in v4) — pattern manifest
├── ui.json                        ← OUTPUT (NEW in v4) — page/section/flow manifest
├── ui.md                          ← OUTPUT (only if --format=md, deprecated)
│
├── patterns/                      ← OUTPUT (NEW in v4) — pattern shells with <slot> placeholders
│   ├── auth-split.html
│   ├── app-shell.html
│   ├── empty-state.html
│   └── hero-grid.html
│
├── pages/                         ← OUTPUT — self-contained, inline component markup
│   ├── signin.html
│   ├── dashboard.html
│   └── pricing.html
│
└── sections/                      ← OUTPUT (if section category built) — reusable marketing blocks
    ├── hero.html
    └── pricing-table.html
```

**Hard rules:**
- `ui.json` and `patterns.json` are the **canonical source of truth** — even when `ui.md` is emitted for legacy compat.
- `pages/*.html` MUST be openable in a browser with no server, no build, no extra fetches beyond `../tokens.css`.
- `patterns/*.html` are **shells** — they expect slot fills and may render hollow on their own.
- Do NOT touch `design.md`, `components.json`, or `components/*.html` — this skill is additive only on `ui.json` / `patterns.json` / `pages/*.html` / `patterns/*.html` / `sections/*.html`.
- READ inputs once at the start; do not re-read after each generated entity.

## Constraints

- READ `design.md` + `components.json` + every `components/*.html` once at start; cache in memory.
- Do NOT invent components — every `{components.*}` ref must resolve to something in `components.json` (otherwise flag as Known Gap and continue).
- Do NOT mix bare and prefixed refs — always prefix with scope.
- Pattern composition is **diff-only** for `variants` / `breakpoints` — only include keys that differ from base. Merge order: `base → variant → size → state`, last-write-wins.
- Slot-fill type validation is mandatory — a wrong type is an error, not a warning.
- `--format=md` emits the legacy `ui.md` ADDITIONALLY — never instead of `ui.json`.

## Quality Bar

A coding agent reading `ui.json` + `patterns.json` + `components.json` + `design.md` should be able to build the actual UI without further questions. Each page tells the agent:
- Which pattern to render into (or that it composes directly)
- Which components fill which slots
- What content fills inline slots (text / inline HTML / image)
- Which transitions go where (for flows)

A designer reading just `ui.json` + `patterns.json` should understand the page inventory + pattern shells + flow structure without opening `components.json`.

A stakeholder opening any `pages/<name>.html` directly in a browser sees the page render end-to-end with no build step, no server, and no extra files beyond `tokens.css`.

## References

- `schemas/ui.schema.json` — JSON Schema for `ui.json`
- `schemas/patterns.schema.json` — JSON Schema for `patterns.json`
- `schemas/components.schema.json` — JSON Schema for `components.json` (read-only input)
- `schemas/ref-resolver.md` — Ref syntax, direction rule, diff-merge algorithm
- `examples/ui.example.json` — worked example: pages + sections + signup flow
- `examples/patterns.example.json` — worked example: auth-split, app-shell, empty-state, hero-grid
- `examples/components.example.json` — worked example of the upstream input
- `docs/architecture-v5.md` — full context on the split architecture + per-skill versioning + `--format=md` deprecation timeline
