---
name: design-ui-builder
description: Build the ui.json + patterns.json manifests plus per-page and per-pattern HTML in a split-architecture design system. Reads design.md + components.json + components/*.html; emits page/section/flow compositions and reusable pattern shells (auth-split, app-shell, empty-state, hero-grid) with slot contracts. Downward refs only (ui → patterns → components → design). v5 dual-mode rendering: iframe (default — live designer iteration) or --render=inline (self-contained dev hand-off). Legacy --format=md. Triggers on "build ui", "build pages", "build patterns", "ui compositions", "create ui.json", "patterns.json", "สร้าง pages", "ui layer", "page composition", "slot fills".
version: 5.1.0
user-invocable: true
---

# 🖼️ Design UI Builder — v5.0.0

Top layer of the split-architecture design system. Reads `design.md` + `components.json` + `components/*.html` → emits `ui.json` + `patterns.json` + `pages/*.html` + `patterns/*.html`.

## Arguments

_All optional — the skill applies sensible defaults when an argument is omitted._

| Argument | Description |
|---|---|
| `source-design` | Path to design.md (default ./design.md) |
| `source-components` | Path to components.json (default ./components.json) |
| `components-html-dir` | Directory containing per-component HTML files (default ./components/) |
| `categories` | Comma-separated categories to build: page,pattern,section,flow or 'all'. Default: page,pattern |
| `format` | Output format. 'json' (default v4+) emits ui.json + patterns.json. 'md' (legacy, v5–v6, removed v7) ALSO emits ui.md alongside ui.json. Emits a deprecation warning. |
| `render` | Page render mode. 'iframe' (default v5+) — pages use <iframe src='../components/<name>.html'> so designer edits to a component HTML are reflected on next page reload, no rebuild needed. 'inline' — pages inline component markup at build time (self-contained for dev hand-off; legacy v4 behavior). |

## What changed in v5 (vs v4)

| v4 | v5 (current) |
|---|---|
| Pages always inline component markup (self-contained) | Pages have TWO render modes — `iframe` (DEFAULT, live designer iteration) and `inline` (export / dev hand-off) |
| Component edits required re-running `design-ui-builder` to refresh pages | In iframe mode, designer edits component HTML → page reflects on reload, NO rebuild |
| No companion stylesheet for pages | iframe mode emits `pages.css` (iframe sizing per component class) |
| One output shape per page | Per-page shape now depends on `--render` flag |
| Validation: "no iframes in pages" | Validation forks by mode — iframe mode verifies iframe src exists; inline mode verifies markup matches latest `components/<name>.html` (warns on drift) |

The iframe mode keeps `components/` as the single source of truth, so designer iteration loops feel instant. The inline mode is still available (and recommended) for dev hand-off or production archives.

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

## Page Rendering Modes

v5 introduces dual-mode page rendering. The mode is chosen at build time via `--render=iframe` (default) or `--render=inline`.

### Mode 1: Iframe (default) — Designer iteration

Pages reference components via `<iframe>`:

```html
<!-- pages/signin.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Sign in</title>
    <link rel="stylesheet" href="../tokens.css">
    <link rel="stylesheet" href="../pages.css">
  </head>
  <body>
    <a href="#main" class="skip-link">Skip to content</a>
    <main id="main" class="page-signin">
      <h1>Sign in</h1>
      <iframe src="../components/signin-form.html"     class="ds-iframe ds-iframe--signin-form"></iframe>
      <iframe src="../components/legal-footer.html"    class="ds-iframe ds-iframe--legal-footer"></iframe>
    </main>
  </body>
</html>
```

Iframes get class `ds-iframe ds-iframe--<component-name>` for sizing/positioning via `pages.css`.

**PROS**
- Designer edit component HTML → reload page → see new version instantly
- No re-run of `/design-ui-builder` needed for component changes
- Single source of truth (`components/` folder); pages never go stale

**CONS**
- Pages NOT self-contained (require `components/` folder alongside)
- Iframe overhead in browser (one HTTP/file fetch per slot)
- Print / PDF may render iframes differently than inline markup

**USE WHEN** — active development, designer iteration, QA / stakeholder review

### Mode 2: Inline (`--render=inline`) — Dev hand-off

Pages inline component markup at build time (v4 behavior):

```html
<!-- pages/signin.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Sign in</title>
    <link rel="stylesheet" href="../tokens.css">
  </head>
  <body>
    <a href="#main" class="skip-link">Skip to content</a>
    <main id="main" class="page-signin">
      <h1>Sign in</h1>
      <!-- snapshot of components/signin-form.html markup -->
      <form class="signin-form">
        <input type="email" class="input" />
        <button class="btn btn--primary">Sign in</button>
      </form>
      <!-- snapshot of components/legal-footer.html markup -->
      <footer class="legal-footer">© 2026 Example Inc.</footer>
    </main>
  </body>
</html>
```

**PROS**
- Pages self-contained (copy 1 file → works)
- No iframe overhead
- Print / PDF works cleanly
- Dev hand-off ready

**CONS**
- Component change → re-run `/design-ui-builder` to refresh pages
- Pages have stale markup if component edited but builder not re-run

**USE WHEN** — export, dev hand-off, final delivery, production archive

### Iframe sizing

Each iframe needs explicit dimensions in CSS — at minimum `height` (iframes have no intrinsic height); `width` is optional (defaults to container width). `pages.css` (emitted only in iframe mode) holds sizing per component class:

```css
/* pages.css — iframe layout overrides (iframe mode only) */
.ds-iframe { border: 0; display: block; }
.ds-iframe--button         { height: 44px;  width: auto; }
.ds-iframe--input          { height: 44px;  width: 100%; }
.ds-iframe--card           { height: 200px; width: 320px; }
.ds-iframe--signin-form    { height: 320px; width: 100%; }
.ds-iframe--legal-footer   { height: 48px;  width: 100%; }
.ds-iframe--nav-bar        { height: 64px;  width: 100%; }
.ds-iframe--side-nav       { height: 100vh; width: 240px; }
```

Component intrinsic size (its rendered height inside the standalone `components/<name>.html`) is the baseline; per-page overrides can be added by extending the class list (e.g. `class="ds-iframe ds-iframe--card ds-iframe--card--compact"`).

### When to switch modes

| Phase | Mode |
|---|---|
| Active design iteration | iframe (default) |
| Designer review on local | iframe |
| QA / stakeholder review | iframe (live updates) |
| Dev hand-off | inline (`--render=inline`) |
| Production / archive | inline |

### Migration from v4 (inline-only) to v5

- Existing v4 pages are byte-identical to v5 inline-mode output — they keep working as-is.
- To switch a project to live iteration mode: re-run `/design-ui-builder` (defaults to iframe). Existing `pages/*.html` are overwritten with iframe shells + a new `pages.css` is emitted.
- To stay on v4 behavior: pass `--render=inline` — output matches v4 exactly (no `pages.css`, no iframes).
- `.gitignore` recommendation:
  - **Iframe mode**: keep `pages/*.html` + `pages.css` in git for review (they're cheap to regenerate but useful in PRs).
  - **Inline mode**: same — track in git so reviewers see the snapshot a dev will receive.

### Slot composition across modes

Slot fills work in **both** modes:
- **Iframe mode**: each slot fill becomes an `<iframe src="../components/<name>.html">` inside the slot's `data-slot` container. Inline-string fills (text / `inline_html` / image) are rendered directly without iframing.
- **Inline mode**: each slot fill is inlined as markup (current v4 behavior).

Page-level slot overrides (e.g. swapping a different component into the `footer` slot) work identically in both modes — only the rendering of the chosen ref differs.

## Ref syntax (carryover)

- Format: `{scope.path.to.thing}` — DTCG-aligned brace alias.
- Regex: `^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$`
- Direction: `ui → patterns → components → design` (downward only). Any upward ref is an audit error.
- `dtcg_version` pinned to `draft-2024-08-09` in `$meta`.

## Execution Steps

### Step 0a. Phase 0 — Auto-scan `docs/blueprints/` (NEW v5.1.0)

**Before asking page scope (Step 4)**, scan project for UX Blueprints from `ux-strategist`:

| File | Provides |
|---|---|
| `docs/blueprints/ux-<feature>.md` | feature name · user flow · IA · edge cases · page list |
| `docs/blueprints/ux-page-<name>.md` | single-page spec · purpose · primary action · IA |
| `docs/blueprints/ux-product-overview.md` | product-level structure |

**If found**, derive **Step 4 page list automatically** from the blueprint's "User Flow" + "Information Architecture" sections:

```
PHASE 0 SCAN RESULTS:
  ✓ docs/blueprints/ux-checkout.md (2026-06-22)
    → flow: Cart → Login → Address → Payment → Confirm → Success
    → pages needed: cart, login, address-form, payment, confirm, success
  ✓ docs/blueprints/ux-onboarding.md
    → flow: Welcome → SignUp → OTP → Dashboard
    → pages needed: welcome, signup, otp, dashboard

Pre-filled page scope: [cart, login, address-form, payment, confirm, success,
                       welcome, signup, otp, dashboard]
Patterns inferred:     [auth-split (for login/signup/otp), app-shell (for dashboard)]
```

→ **Skip Step 4 AskUserQuestion** if blueprint already defines page scope. Just confirm with user:
```
Q: ใช้ page list จาก blueprint ทั้งหมด หรือ subset?
   A. ใช้ทั้งหมด (default)
   B. subset — ระบุ
```

If `docs/blueprints/` empty / missing → continue to Step 4 ask-fresh (legacy behavior).

#### Source attribution

Each page generated must include in its `ui.json` entry:
```json
"sourceBlueprint": "docs/blueprints/ux-checkout.md",
"sourceFlowStep": "Cart → Login → Address"
```

→ Audit trail: dev / QA / reviewer รู้ว่า page นี้มาจาก blueprint ส่วนไหน

---

### Step 0. Pre-flight — pick render mode

Before reading any input, confirm the render mode with the user via `AskUserQuestion`:

```
Question: How should pages be rendered?

  [1] iframe (default, recommended) — pages reference components via <iframe>.
      Designer edits to components/<name>.html show up on next page reload, no rebuild.
      Best for active iteration / QA / stakeholder review.

  [2] inline — pages inline component markup at build time (self-contained, v4 behavior).
      Component edits require re-running this skill. Best for dev hand-off / production export.
```

If the user passed `--render=iframe` or `--render=inline` on the CLI, skip the prompt and respect the flag.
Default when neither prompt-answer nor flag is provided → `iframe`.

Cache the chosen mode as `<MODE>` for the remainder of the run.

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

#### 6b. Write `pages/<name>.html` — mode-dependent

Behavior forks on the `<MODE>` cached in Step 0.

##### Mode A — `iframe` (default)

Pages reference components via `<iframe>` rather than inlining markup.

**For pattern-based pages:**
1. Open the pattern's `html_template` (e.g. `patterns/auth-split.html`) — use it as the structural scaffold.
2. For each entry in `slot_fills`, replace the corresponding `<slot name="X"></slot>` placeholder:
   - If the fill is a `{components.<atom|molecule|organism>.<name>}` ref → emit `<iframe src="../components/<name>.html" class="ds-iframe ds-iframe--<name>"></iframe>` (use the leaf segment after the last dot as `<name>`).
   - If the fill is a `{patterns.<...>}` ref → recursively expand that pattern's shell + its slot fills (the inner pattern keeps its iframes too).
   - If the fill is an inline string (no brace) → paste it as-is (raw text / HTML / image markup). Inline strings do NOT get wrapped in an iframe.
3. Validate that every `required: true` slot is filled; on miss, emit a "Known Gap" + leave the placeholder as `<!-- TODO: fill slot <name> -->`.

**For direct-composition pages:**
1. Build the page from scratch with the page's own layout `<style>`.
2. For each `{components.<...>}` ref in `composes[]`, emit one iframe (same `ds-iframe ds-iframe--<name>` class pair).

**Companion file (iframe mode only):** also emit / merge into `./pages.css` at the project root, containing iframe sizing per component class encountered:
```css
.ds-iframe { border: 0; display: block; }
.ds-iframe--<name> { height: <h>px; width: <w>; }
```
Sizing defaults: pick height from the component's intrinsic rendered height (eyeball via the standalone `components/<name>.html` preview, or fall back to sane defaults — atoms 44px, molecules 80px, organisms 200px+); `width` defaults to `100%`. Merge into an existing `pages.css` rather than overwriting — preserve any designer customizations.

**Skeleton (iframe):**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><!-- from meta.title --></title>
  <link rel="stylesheet" href="../tokens.css">
  <link rel="stylesheet" href="../pages.css">
  <style>/* page-specific layout */</style>
</head>
<body>
  <a href="#main" class="skip-link">Skip to content</a>
  <main id="main">
    <h1><!-- page heading --></h1>
    <iframe src="../components/<name>.html" class="ds-iframe ds-iframe--<name>"></iframe>
    <!-- … more slot iframes / direct composes -->
  </main>
</body>
</html>
```

##### Mode B — `inline` (`--render=inline`)

Pages are end-to-end renderable in a browser with no build step. Component markup is **inlined** from the Step-3 manifest — NEVER iframed, NEVER `<link>`ed, NEVER fetched at runtime. (This is the v4 behavior.)

**For pattern-based pages:**
1. Open the pattern's `html_template` — use it as the structural scaffold.
2. For each entry in `slot_fills`, replace the corresponding `<slot name="X"></slot>` placeholder:
   - If the fill is a `{components.<...>}` ref → look up the markup in the Step-3 manifest and paste it inline.
   - If the fill is a `{patterns.<...>}` ref → recursively expand that pattern's shell + its slot fills (also inlined).
   - If the fill is an inline string → paste as-is.
3. Validate required slots same as iframe mode.

**For direct-composition pages:**
1. Build the page from scratch with the page's own layout `<style>`.
2. For each ref in `composes[]`, inline the component markup at the appropriate position.

**Companion file (inline mode):** none — pages are self-contained beyond `../tokens.css`.

**Skeleton (inline):**
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

##### Common rules (both modes)

- Include `<link rel="stylesheet" href="../tokens.css">` in `<head>`.
- Iframe mode adds a second link to `../pages.css`.
- Include a page-specific `<style>` block for layout only (grid, slot positions). Never duplicate component styles.
- Emit accessible structure per the page's `meta` + a11y conventions: `<title>` (from `meta.title`), `<a href="#main" class="skip-link">Skip to content</a>`, `<main id="main">…</main>`, exactly one `<h1>`, `<nav aria-label="...">` where applicable.
- When inlining (inline mode), strip the demo wrapper from the source `components/*.html` — keep only the real component markup.
- `lang` attribute on `<html>` comes from `meta.lang` (default `en`).

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

**HTML output (common)**
- [ ] Every `page.<name>.html_template` file exists on disk
- [ ] Every `pattern.<name>.html_template` file exists on disk
- [ ] Every `section.<name>.html_template` file exists (if declared)
- [ ] `pages/*.html` and `patterns/*.html` include `<link rel="stylesheet" href="../tokens.css">`
- [ ] Each `pages/*.html` has exactly one `<h1>`, a skip link to `#main`, and `<main id="main">` landmark

**HTML output (iframe mode)**
- [ ] Every `<iframe src="../components/<name>.html">` in `pages/*.html` resolves to an existing file on disk
- [ ] Every iframe has the `ds-iframe ds-iframe--<name>` class pair
- [ ] `pages.css` exists at project root and contains a sizing rule for each `ds-iframe--<name>` class used
- [ ] Each `pages/*.html` includes `<link rel="stylesheet" href="../pages.css">`

**HTML output (inline mode)**
- [ ] `pages/*.html` are self-contained — no `<iframe>`, no `<link>` to component files, no runtime `fetch` of components
- [ ] Inlined component markup matches the latest `components/<name>.html` source (compare normalized markup; warn on drift but do not fail — drift means the component changed after the last builder run)
- [ ] No `pages.css` is emitted (inline mode does not need it)

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
├── pages.css                      ← OUTPUT (NEW in v5, iframe mode only) — iframe sizing per component class
│
├── patterns/                      ← OUTPUT (NEW in v4) — pattern shells with <slot> placeholders
│   ├── auth-split.html
│   ├── app-shell.html
│   ├── empty-state.html
│   └── hero-grid.html
│
├── pages/                         ← OUTPUT — iframe shells (v5 default) OR inline (v4-style, --render=inline)
│   ├── signin.html
│   ├── dashboard.html
│   └── pricing.html
│
└── sections/                      ← OUTPUT (if section category built) — reusable marketing blocks
    ├── hero.html
    └── pricing-table.html
```

**Per-mode outputs:**
| File | iframe mode | inline mode |
|---|---|---|
| `ui.json` | ✓ | ✓ |
| `patterns.json` | ✓ | ✓ |
| `patterns/*.html` | ✓ | ✓ |
| `pages/*.html` | ✓ (iframe shells) | ✓ (self-contained) |
| `pages.css` | ✓ (NEW) | — (not emitted) |
| `sections/*.html` | ✓ (if requested) | ✓ (if requested) |

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

## Workflow scenarios

### Scenario A — Designer iterating on `signin-form` (iframe mode)

1. Run `/design-ui-builder` once → produces `pages/signin.html` (iframe shell) + `pages.css`.
2. Designer opens `pages/signin.html` in a browser → sees current state.
3. Designer edits `components/signin-form.html` (e.g. tweaks padding, fixes label copy).
4. Designer reloads `pages/signin.html` → new component version is reflected immediately. No rebuild.
5. Designer is happy → commits both `components/signin-form.html` + `pages/signin.html` (unchanged iframe shell).

**Why iframe wins here:** zero rebuild loop. The page is a thin reference; the component is the source of truth.

### Scenario B — Dev hand-off (inline mode)

1. After designer is happy, designer runs `/design-ui-builder --render=inline`.
2. Skill regenerates every `pages/*.html` with current component markup inlined. `pages.css` is removed (or left in place but unused — note in a final report).
3. Dev receives the project; opens any `pages/<name>.html` directly → renders end-to-end with only `tokens.css`.
4. Dev uses inlined markup as the spec for their framework implementation (React / Vue / Svelte).

**Why inline wins here:** self-contained snapshot, no dependency on `components/` folder layout, no iframe quirks in print/PDF.

### Scenario C — Stakeholder review (iframe mode, live)

1. Designer pushes branch with iframe-mode output.
2. Stakeholder opens `pages/signin.html` locally; comments "make the button rounder".
3. Designer edits `components/button.html` while screen-sharing.
4. Stakeholder reloads → sees the change. No round-trip with dev.

### Scenario D — Mixing modes is fine

A project can switch between modes any time. Re-running `/design-ui-builder` always overwrites `pages/*.html` based on the chosen mode at that run. There's no persistent "mode" state file — each run is authoritative.

## References

- `schemas/ui.schema.json` — JSON Schema for `ui.json`
- `schemas/patterns.schema.json` — JSON Schema for `patterns.json`
- `schemas/components.schema.json` — JSON Schema for `components.json` (read-only input)
- `schemas/ref-resolver.md` — Ref syntax, direction rule, diff-merge algorithm
- `examples/ui.example.json` — worked example: pages + sections + signup flow
- `examples/patterns.example.json` — worked example: auth-split, app-shell, empty-state, hero-grid
- `examples/components.example.json` — worked example of the upstream input
- `docs/architecture-v5.md` — full context on the split architecture + per-skill versioning + `--format=md` deprecation timeline
