---
name: design-component-builder
description: Build the components layer of a split-architecture design system. Reads design.md (tokens + mood) and emits components.json — a JSON manifest (per schemas/components.schema.json) describing atoms/molecules/organisms with DTCG-aligned ref syntax {design.semantic.*} — alongside tokens.css and self-contained components/<name>.html files plus a components.html showcase. Atoms encode variants/sizes/states as DIFF-ONLY overrides (merge order base → variant → size → state, last-write-wins). One-off variants outside the canonical set go in a governed variant-extensions block (reason + expiry required, never silently added to canonical variants — prevents variant sprawl seen in production apps). Molecule/organism remain spec stubs (status=planned). Mood-biased state mapping. Default initial atomic scope: button, input, select, checkbox, radio, textarea, label, card, badge. Triggers on "build components", "add components", "atomic components", "เพิ่ม component", "สร้าง components", "atomic design", "component layer". Uses 2-tier token strategy (sys + comp aliases) following Material 3 + Carbon hybrid for optimal agent intent + low output token cost. Legacy --format=md flag dual-emits components.md (deprecated, removed in v7).
version: 5.1.0
user-invokable: true
args:
  - name: source
    description: Path to design.md (default ./design.md)
    required: false
  - name: scope
    description: "Comma-separated component names to build. Default: button,input,select,checkbox,radio,textarea,label,card,badge"
    required: false
  - name: format
    description: "Output format. 'json' (default) emits components.json only. 'md' (LEGACY, deprecated v5+v6, removed v7) ALSO emits components.md for tools still parsing Markdown."
    required: false
---

# 🧩 Design Component Builder (v5)

Tier-3 layer builder. Reads `design.md` and outputs:
1. `components.json` — JSON manifest (primary spec) per `schemas/components.schema.json`
2. `tokens.css` — CSS custom properties mapped from semantic tokens (2-tier)
3. `components/<name>.html` — self-contained HTML file per atomic component
4. `components.html` — showcase aggregating all components via iframes
5. `components.md` — *only if* `--format=md` (legacy dual-emit, deprecated)

## What changed from v4.1 → v5.0

- **Primary spec is JSON, not Markdown.** `components.json` replaces `components.md` as the authoritative manifest.
- **DTCG-aligned ref syntax.** All cross-file refs use brace form `{design.semantic.path.to.token}` matching the DTCG 2024-09 spec. Direction is downward only: `ui → patterns → components → design`. Upward refs are an audit error.
- **Diff-only variants/sizes/states.** Each atom declares a base, then variants/sizes/states list ONLY the fields that change. Agents/builders merge `base → variant → size → state` (last-write-wins).
- **Per-skill SemVer.** Version bumps independently of the library. Pinned `dtcg_version: 2024-09`.
- **`--format=md` legacy flag.** Supported in v5 and v6 with a deprecation warning. Removed in v7. Default is `json`.

## When to use
- Have a `design.md` with primitive + semantic already built (via `design-builder`)
- Want runnable, browser-previewable components (not just YAML)
- Want components that ship as HTML+CSS, ready for design QA

## When NOT to use
- No `design.md` yet → run `design-builder` first
- Want to add icons → use `design-icon-builder`
- Want to check what's there → use `design-md-audit`

## 3-tier atomic architecture

| Layer | Examples | Output in v5 |
|---|---|---|
| **atom** | button, input, select, checkbox, radio, textarea, label, card, badge | **components.json entry + HTML file** |
| **molecule** | form-field, nav-item, search-bar, stat-tile | components.json stub (`status: "planned"`), no HTML |
| **organism** | sidebar, topbar, hero, table | components.json stub (`status: "planned"`), no HTML |

Patterns + pages live in `patterns.json` / `ui.json` (separate files), NOT in components.json.

## Default initial atomic scope (v5)

`button, input, select, checkbox, radio, textarea, label, card, badge`

Override via `scope` arg.

## Token Architecture (v5 — Hybrid Layered, JSON-bound)

The **2-tier CSS custom property strategy** (Material 3 + Carbon inspired) is unchanged from v4.1. The new piece in v5 is that the **mapping from `--comp-*` aliases → `{design.semantic.*}` refs is recorded inside `components.json`** under each atom's `tokens` block. `tokens.css` continues to be the runtime artifact; `components.json` is the authoritative source of the binding.

### The 2 tiers

| Tier | Prefix | Purpose | Who reads it | Who uses it |
|---|---|---|---|---|
| **sys** | `--sys-*` | Semantic, cross-component intent (e.g. `--sys-color-primary`, `--sys-space-md`, `--sys-radius-md`) | Agent reads to UNDERSTAND intent ("this is the primary brand color") | NOT used directly in component CSS |
| **comp** | `--{component}-*` | Component-scoped aliases pointing to sys (e.g. `--btn-bg`, `--btn-bg-hover`, `--input-border`) | Agent reads to understand component-local naming | Agent USES in component CSS via `var(--btn-bg)` |

### Why 2 tiers (priority order)

1. **Intent legibility** — `--sys-color-primary` tells the agent WHAT a color means semantically; `--btn-bg` tells the agent WHERE it goes.
2. **Usability** — component CSS reads naturally: `background: var(--btn-bg)` instead of `background: var(--sys-color-primary-default)`.
3. **Output token cost** — comp aliases are short (`--btn-bg` is 8 chars vs `--sys-color-primary-default` at 28). Across hundreds of CSS rules, this saves significant tokens in generated HTML files.
4. **Scalability** — re-theming a component only requires changing its comp aliases; sys layer stays stable. Dark mode only re-declares sys, comp inherits automatically.

### Naming rules

- **sys tier** — `--sys-{category}-{role}[-{variant}]`
  - `--sys-color-primary`, `--sys-color-primary-hover`, `--sys-color-bg-surface`, `--sys-color-text-on-primary`
  - `--sys-space-xs|sm|md|lg|xl`, `--sys-radius-sm|md|lg`, `--sys-font-size-sm|md|lg`
- **comp tier** — `--{component}-{property}[-{state}]`
  - `--btn-bg`, `--btn-bg-hover`, `--btn-bg-disabled`, `--btn-fg`, `--btn-border`, `--btn-radius`, `--btn-px`
  - `--input-bg`, `--input-border`, `--input-border-focus`, `--input-border-error`

### Example pattern

```css
:root {
  /* --- sys tier (semantic, cross-component) --- */
  --sys-color-primary: #3B82F6;
  --sys-color-primary-hover: #2563EB;
  --sys-color-text-on-primary: #FFFFFF;
  --sys-space-md: 16px;
  --sys-radius-md: 8px;

  /* --- comp tier (component-scoped aliases → sys) --- */
  --btn-bg: var(--sys-color-primary);
  --btn-bg-hover: var(--sys-color-primary-hover);
  --btn-fg: var(--sys-color-text-on-primary);
  --btn-px: var(--sys-space-md);
  --btn-radius: var(--sys-radius-md);
}

.ds-btn {
  background: var(--btn-bg);    /* ✅ uses comp alias */
  color: var(--btn-fg);
  padding: 0 var(--btn-px);
  border-radius: var(--btn-radius);
}
.ds-btn:hover { background: var(--btn-bg-hover); }
```

### Dark mode pattern (only sys re-declared)

```css
[data-theme="dark"] {
  /* Only sys tier overridden — comp aliases inherit automatically */
  --sys-color-primary: #60A5FA;
  --sys-color-primary-hover: #3B82F6;
  --sys-color-text-on-primary: #0F172A;
}
```

Comp aliases (`--btn-bg`, etc.) do NOT need re-declaration — they resolve through their `var(--sys-*)` reference at use-time.

## Execution Steps

### Step 1 — Read design.md + extract semantic tokens

- Default source: `./design.md`
- Parse YAML frontmatter — verify `scope: 'tokens-only'`
- Verify `primitive:` AND `semantic:` blocks exist — ABORT if missing
- Read `mood.primary` for state-mapping bias
- Walk the `semantic:` tree and collect every leaf token with its dotted path:
  - e.g. `semantic.color.primary.default` → value `#3B82F6`
  - e.g. `semantic.space.4` → value `16px`
  - e.g. `semantic.radius.md` → value `8px`
  - e.g. `semantic.typography.label.md` → composed value (font/size/weight/lh)

Hold this flat token map in memory for the later steps. Each semantic path will be used (a) directly as a `{design.semantic.*}` ref inside `components.json`, and (b) as the source of a `--sys-*` declaration in `tokens.css`.

### Step 2 — Plan atomic scope

- Resolve the `scope` arg (default: `button,input,select,checkbox,radio,textarea,label,card,badge`).
- For each atom in scope, plan:
  - `id` (kebab-case)
  - One-line `summary` (intent)
  - `render` shape: `tag`, optional `role`, base `classes`, optional `slots`, `html_template` path
  - Base `tokens` block — every `--{comp}-*` alias the atom needs, each mapped to a `{design.semantic.*}` ref
  - `variants` / `sizes` / `states` as **diff-only** overrides
  - `a11y` block (`touch_min`, `required_attrs`, `contrast_pair`)

### Step 3 — Assemble `components.json` (schemas/components.schema.json)

Build a single JSON object with this shape (see `examples/components.example.json` for a worked reference):

```jsonc
{
  "$meta": {
    "schema": "../schemas/components.schema.json",
    "scope": "components-only",
    "depends_on": ["./design.md", "./tokens.css"],
    "dtcg_version": "2024-09",
    "version": "1.0.0"
  },
  "atom": {
    "button": {
      "id": "button",
      "summary": "Primary interactive control. Use for triggering actions, never for navigation (use link).",
      "render": {
        "tag": "button",
        "classes": ["btn"],
        "slots": ["icon-leading", "label", "icon-trailing", "spinner"],
        "html_template": "./components/button.html"
      },
      "tokens": {
        "--btn-bg":     "{design.semantic.color.primary.default}",
        "--btn-fg":     "{design.semantic.color.on-primary}",
        "--btn-border": "{design.semantic.color.primary.default}",
        "--btn-radius": "{design.semantic.radius.md}",
        "--btn-padding-x": "{design.semantic.space.4}",
        "--btn-padding-y": "{design.semantic.space.2}",
        "--btn-font":   "{design.semantic.typography.label.md}",
        "--btn-focus-ring": "{design.semantic.color.focus-ring}"
      },
      "variants": {
        "primary":   { "classes": ["btn--primary"] },
        "secondary": {
          "classes": ["btn--secondary"],
          "tokens": {
            "--btn-bg":     "{design.semantic.color.surface.raised}",
            "--btn-fg":     "{design.semantic.color.content.default}",
            "--btn-border": "{design.semantic.color.edge.subtle}"
          }
        }
      },
      "sizes": {
        "md": { "classes": ["btn--md"] },
        "lg": {
          "classes": ["btn--lg"],
          "tokens": {
            "--btn-padding-x": "{design.semantic.space.5}",
            "--btn-padding-y": "{design.semantic.space.3}",
            "--btn-font":      "{design.semantic.typography.label.lg}"
          }
        }
      },
      "states": {
        "hover":  { "tokens": { "--btn-bg": "{design.semantic.color.primary.hover}" } },
        "active": { "tokens": { "--btn-bg": "{design.semantic.color.primary.active}" } },
        "focus":  { "classes": ["btn--focus-visible"] },
        "disabled": {
          "tokens": {
            "--btn-bg":     "{design.semantic.color.surface.disabled}",
            "--btn-fg":     "{design.semantic.color.content.disabled}",
            "--btn-border": "{design.semantic.color.edge.disabled}"
          },
          "a11y": { "required_attrs": ["aria-disabled"] }
        }
      },
      "a11y": {
        "touch_min": "44px",
        "role": "button",
        "required_attrs": ["type"],
        "contrast_pair": {
          "fg": "{design.semantic.color.on-primary}",
          "bg": "{design.semantic.color.primary.default}",
          "min_ratio": 4.5
        }
      }
    }
    /* … one entry per atom in scope … */
  },
  "molecule": {
    "form-field": {
      "id": "form-field",
      "summary": "Planned in Phase 3. Labeled input wiring label[for] + input[id] + help-text[id] via aria-describedby.",
      "status": "planned",
      "composes": [
        "{components.atom.label}",
        "{components.atom.input}",
        "{components.atom.help-text}"
      ],
      "render": { "tag": "div", "classes": ["form-field"], "html_template": "./components/form-field.html" },
      "tokens": {}
    }
  },
  "organism": {}
}
```

**Diff-only encoding rules (variants/sizes/states):**
- The base atom declares every token alias and every base class.
- Each entry under `variants`, `sizes`, `states` lists ONLY the keys that change from base.
- `tokens` overrides are KEY-level (override one alias, keep the rest).
- `classes` arrays are appended (modifier classes), not replaced.
- Merge order at consumption time: `base → variant → size → state` (last-write-wins per key).

**Ref syntax (DTCG-aligned):**
- Regex: `^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$`
- Direction: `ui → patterns → components → design`. Downward only.
- Inside `components.json`, ONLY `{design.*}` refs are allowed in token bindings. Composition refs (`composes`) may reference `{components.*}` for sibling atoms inside this same file.

### Step 4 — Write `components.json`

- Path: `./components.json` at repo root.
- `$meta.schema` → relative path to `schemas/components.schema.json`
- `$meta.scope` → MUST be `"components-only"`
- `$meta.depends_on` → MUST include `"./design.md"` and `"./tokens.css"`
- `$meta.dtcg_version` → `"2024-09"`
- `$meta.version` → SemVer, bumped independently of skill version (start `1.0.0` on first emit, then bump per change)
- Write the file with the Write tool. Do NOT paste the full JSON into the chat response.

### Step 5 — Write `tokens.css` (2-tier structure REQUIRED)

`tokens.css` MUST contain BOTH tiers in this order:

1. **sys tier** — map each semantic token from design.md → `--sys-*` custom property
2. **comp tier** — for every component in scope, declare component-scoped aliases pointing to sys

Mapping convention (sys tier):

- Path `semantic.colors.primary.default` → `--sys-color-primary`
- Path `semantic.colors.primary.hover` → `--sys-color-primary-hover`
- Path `semantic.colors.text.on-bgcolor` → `--sys-color-text-on-bgcolor`
- Path `semantic.spacing.md` → `--sys-space-md`
- Path `semantic.radius.md` → `--sys-radius-md`
- Path `semantic.typography.label.md.font-size` → `--sys-font-size-label-md` (flatten composed tokens)

Use CSS comments showing source paths above each sys block. comp aliases need a brief inline comment naming the sys they point to.

Structure:
```css
/* tokens.css — generated by design-component-builder v4.1 */
/* Source: ./design.md (semantic layer) */
/* Architecture: 2-tier — sys (semantic, cross-component) + comp (per-component aliases) */

:root {
  /* ============================================ */
  /* TIER 1 — sys (semantic, cross-component)     */
  /* ============================================ */

  /* --- sys: colors --- */
  /* source: {semantic.colors.primary.default} */
  --sys-color-primary: #3B82F6;
  /* source: {semantic.colors.primary.hover} */
  --sys-color-primary-hover: #2563EB;
  /* source: {semantic.colors.text.on-primary} */
  --sys-color-text-on-primary: #FFFFFF;
  /* ... */

  /* --- sys: spacing --- */
  /* source: {semantic.spacing.md} */
  --sys-space-md: 16px;
  /* ... */

  /* --- sys: radius --- */
  /* source: {semantic.radius.md} */
  --sys-radius-md: 8px;
  /* ... */

  /* --- sys: typography --- */
  /* source: {semantic.typography.label.md} */
  --sys-font-size-label-md: 14px;
  --sys-font-weight-label-md: 500;
  --sys-line-height-label-md: 1.4;

  /* ============================================ */
  /* TIER 2 — comp (per-component aliases → sys)  */
  /* ============================================ */

  /* --- comp: button --- */
  --btn-bg: var(--sys-color-primary);
  --btn-bg-hover: var(--sys-color-primary-hover);
  --btn-fg: var(--sys-color-text-on-primary);
  --btn-px: var(--sys-space-md);
  --btn-radius: var(--sys-radius-md);

  /* --- comp: input --- */
  --input-bg: var(--sys-color-bg-surface);
  --input-border: var(--sys-color-border-default);
  --input-border-focus: var(--sys-color-primary);
  --input-radius: var(--sys-radius-md);
  /* ... one block per component in scope ... */
}

/* Dark mode — ONLY sys tier re-declared; comp aliases inherit via var() resolution */
[data-theme="dark"] {
  /* source: {semantic.colors.primary.default} @ dark */
  --sys-color-primary: #60A5FA;
  --sys-color-primary-hover: #3B82F6;
  --sys-color-text-on-primary: #0F172A;
  /* ... */
}
```

**Write the file with the Write tool. Do not include the full file content in the chat response.**

`tokens.css` is the runtime artifact; `components.json` is the authoritative source of which `--comp-*` aliases exist and which `{design.semantic.*}` ref each one points to. The two MUST stay in sync — every `--comp-*` declared in `tokens.css` must also appear in some atom's `tokens` block in `components.json`, and vice versa.

### Step 6 — For each component in scope, write `components/<name>.html`

For every atomic component in scope (default: `button, input, select, checkbox, radio, textarea, label, card, badge`):

**COMMON RULES for HTML components:**
- Self-contained `.html` file: `<!DOCTYPE html> ... </html>`
- `<link rel="stylesheet" href="../tokens.css">` in `<head>`
- Component-specific CSS in `<style>` tag
- NEVER use raw hex/px — only `var(--name)` from tokens.css
- **CRITICAL — reference comp-tier aliases ONLY** (e.g. `var(--btn-bg)`, `var(--input-border)`). NEVER reference `var(--sys-*)` directly inside component CSS. If a needed token alias doesn't exist, ADD it to `tokens.css` comp section first, then use it.
- Class prefix `.ds-<component>` (e.g. `.ds-btn`, `.ds-input`)
- Show ALL states/variants in `<body>` grouped with `<h2>`/`<h3>`
- Use semantic HTML (`<button>`, `<input>`, `<select>`, etc.)
- a11y: aria-* attrs, label-for, role attrs
- HTML comment at top: `<!-- Component: <name> | Tokens used: --btn-bg, --btn-fg, ... | A11y: ... -->` (list comp aliases used)
- Open in browser standalone (with `../tokens.css` present) = works

Apply mood-biased state mapping (see Mood Overrides below) when picking which token each state hooks into. States to cover per component:

| Component | States / Variants |
|---|---|
| button | variants: primary, secondary, tertiary, ghost, destructive × states: rest, hover, active, focus, disabled |
| input | states: rest, hover, focus, disabled, error |
| select | states: rest, hover, focus, disabled, open, error |
| checkbox | states: rest, hover, focus, disabled × checked / unchecked / indeterminate |
| radio | states: rest, hover, focus, disabled × selected / unselected |
| textarea | states: rest, hover, focus, disabled, error |
| label | variants: rest, required, disabled |
| card | variants: default (display), interactive — interactive gets rest/hover/active/focus |
| badge | variants: solid, soft, outline × status: neutral, info, success, warning, error |

### One-off variants — use `variant-extensions`, never add to canonical `variants`

If the user asks for a variant outside the canonical set above (e.g. "ทำปุ่มสีเขียวสำหรับ campaign นี้" / "add a special color for this promo") — do NOT expand `variants` to include it silently. Real production apps that did this ended up with 11+ ungoverned button variants over time (`green`, `green_line`, `green_light`, `red_outline`, `transparent`, ...) with no record of why each exists or whether they're still needed.

Instead, add it under `variant-extensions` on the atom (per `schemas/components.schema.json`):

```json
"variant-extensions": {
  "campaign-green": {
    "reason": "Songkran campaign 2026 — marketing requested a green CTA for the promo banner only",
    "expires": "2026-04-20",
    "extends": "primary",
    "tokens": {
      "--btn-bg": "{design.primitive.colors.green.600}"
    }
  }
}
```

Rules:
- **`extends` is required** — every extension inherits from a canonical variant (`primary`/`secondary`/`tertiary`/`ghost`/`destructive`), it's a diff on top, not a from-scratch variant
- **`expires` is required** — a real date, not indefinite. `design-md-audit` flags expired extensions as Major ("promote to canonical or remove")
- **`reason` is required** — one sentence, who asked + why, so a future designer/agent doesn't have to reverse-engineer intent
- Ask the user for the expiry date if they don't volunteer one — default to +90 days if they have no preference, and say so

**Always WRITE the file with the Write tool. Do NOT include file content in the chat response.**

### Step 7 — Write `components.html` showcase

Single page that aggregates every atomic component built in Step 3 via iframes.

Structure:
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Components — Showcase</title>
  <link rel="stylesheet" href="./tokens.css">
  <style>
    body { font-family: system-ui, sans-serif; padding: var(--spacing-lg, 24px); }
    .showcase-section { margin-bottom: var(--spacing-xl, 32px); }
    .showcase-section h2 { margin-bottom: var(--spacing-md, 16px); }
    iframe {
      width: 100%;
      min-height: 400px;
      border: 1px solid var(--color-border-default, #e5e5e5);
      border-radius: var(--radius-md, 8px);
    }
  </style>
</head>
<body>
  <h1>Design System — Components</h1>
  <section class="showcase-section">
    <h2>button</h2>
    <iframe src="components/button.html" title="button component"></iframe>
  </section>
  <!-- repeat for each component in scope -->
</body>
</html>
```

**Write with the Write tool. Do not include full content in response.**

### Step 8 — *(only if `--format=md`)* Write legacy `components.md`

ONLY when invoked with `--format=md`:

1. Emit a deprecation warning to stderr (NOT in the chat response):
   `[design-component-builder] WARN: --format=md is deprecated. components.md will be removed in v7. Migrate consumers to components.json.`
2. Write `components.md` as a *human-readable index* derived from `components.json`. It must NOT be the source of truth.

Frontmatter:
```yaml
---
scope: 'components-only'
depends-on: ['./design.md', './components.json']
outputs:
  - ./tokens.css
  - ./components.html
  - ./components/*.html
version: 5.0.0
legacy: true
---
```

Body sections (derived from `components.json`):
1. **Atomic component index** — table linking each built component to its HTML file + a11y notes
2. **Token bindings reference** — short table: `--comp-*` alias → `{design.semantic.*}` ref (sourced from `components.json` atom `tokens` blocks)
3. **Molecule layer (Phase 3 — planned)** — list of `molecule` stubs with `status: planned`
4. **Organism layer (Phase 3 — planned)** — list of `organism` stubs with `status: planned`
5. **Known Gaps** — list anything skipped from default scope

**Write the file with the Write tool. Do not include full content in response.**

## Backward Compat (`--format=md`)

| Skill version | Default output | `--format=md` behavior |
|---|---|---|
| v5.x | `components.json` only | Dual-emit: `components.json` + legacy `components.md` (deprecation warning to stderr) |
| v6.x | `components.json` only | Dual-emit retained; warning escalates to `WARN-DEPRECATED` |
| v7.0 | `components.json` only | **Flag removed.** Passing `--format=md` errors out with a migration hint |

**Why dual-emit during the transition:** existing tooling (audits, style-guide renderers, ad-hoc Markdown readers) still parses `components.md`. v5 + v6 give consumers two full release windows to migrate to the JSON manifest before the legacy format is dropped.

**Migration guidance for downstream consumers:**
- Read `components.json` directly (it is JSON, parseable in any language).
- Validate against `schemas/components.schema.json` (Draft-07).
- Resolve `{design.semantic.*}` refs via `schemas/ref-resolver.md`.
- If you previously parsed `components.md` frontmatter, the same fields (`scope`, `depends_on`, `version`) live under `$meta` in JSON.

## Mood-biased state mapping

| Mood | Override |
|---|---|
| `bold-tech` | hover bumps 2 stops (`darker` not `dark`), active adds inner shadow, focus ring thick @60% |
| `friendly-warm` | hover uses `soft-light` (gentler), active uses `light`, focus ring @30% |
| `premium-editorial` | hover stays `default` + border color change only, active `dark`, focus ring @20% subtle |
| `playful-vivid` | hover scales/shifts saturation, active darker + slight scale, focus ring colored @50% |
| `technical-dev` | hover `dark`, active `darker`, focus thick outline, no shadow change |
| `calm-focused` | canonical mapping (no override) |

Apply this when picking which `--color-*` token each state uses in the component HTML.

## Required a11y attrs per atom (WCAG AA)

These constraints are now recorded **in `components.json`** under each atom's `a11y` block (`touch_min`, `role`, `required_attrs`, `contrast_pair`). The HTML files MUST honor them at render time, and each HTML file's top comment MUST still list the attrs used (for in-browser inspection).

- **button** — `role="button"` (implicit on `<button>`), hit-area ≥44px (use padding to enforce on small sizes), `aria-label` if icon-only
- **input** — `id`, `aria-describedby` linking to helper-text, `aria-invalid="true"` on error
- **select** — same as input + `aria-expanded` on open state
- **checkbox / radio** — `<label for>` association, `aria-checked` if using non-native, group with `role="radiogroup"` for radios
- **textarea** — same as input
- **label** — `for="<input-id>"` MUST point to the input
- **card (interactive)** — `role="button"` or wrap in `<a>`, keyboard handler (tabindex=0)
- **badge** — `aria-label` if status communicated by color alone

`contrast_pair` blocks in `components.json` are what `design-md-audit` reads to verify WCAG ratios against `design.md`. Set `min_ratio: 4.5` for body text, `3` for large text / non-text UI.

## Validation checklist

**JSON manifest:**
- [ ] `components.json` exists at repo root and parses as valid JSON
- [ ] `components.json` validates against `schemas/components.schema.json` (Draft-07)
- [ ] `$meta.scope == "components-only"`
- [ ] `$meta.depends_on` includes `"./design.md"` and `"./tokens.css"`
- [ ] `$meta.dtcg_version == "2024-09"`
- [ ] `$meta.version` is a valid SemVer (`x.y.z`)
- [ ] Every atom has `id`, `render`, `tokens` (per schema)
- [ ] Every `render.html_template` path resolves to an existing file in `./components/`
- [ ] Every token ref matches the regex `^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$`
- [ ] Every `{design.semantic.*}` ref in `tokens` resolves to a real path in `design.md`
- [ ] **No upward refs** — components.json contains NO `{patterns.*}` or `{ui.*}` refs (audit error)
- [ ] Variants/sizes/states are **diff-only** — they do NOT duplicate base keys that aren't changing
- [ ] Every `composes` entry (molecule/organism) references an atom that exists in this file
- [ ] Molecule/organism stubs use `status: "planned"` and have no HTML output yet
- [ ] Prop names use current vocabulary only — `background`/`foreground`/`border`/`shadow`/`ring` (per NAMING.md § Prop names). Flag `surface`/`content`/`edge`/`elevation`/`focus-halo` used as a component prop as deprecated — does not apply to the semantic color role `surface`
- [ ] `disabled` never appears as a variant name — only as a state on every variant (real-world anti-pattern to catch: a `variant: "disabled"` entry alongside a proper `disabled` state)

**Tokens.css:**
- [ ] `tokens.css` exists at repo root
- [ ] Contains BOTH tiers: sys (`--sys-*`) AND comp (`--{component}-*`)
- [ ] Every sys-tier custom property has a source-path comment
- [ ] Every comp-tier alias points to a `var(--sys-*)` reference
- [ ] Dark mode block re-declares ONLY sys-tier (not comp aliases)
- [ ] Every `--comp-*` alias declared in `tokens.css` appears in some atom's `tokens` block in `components.json` (and vice versa)

**HTML files:**
- [ ] Every component in scope has a `components/<name>.html` file
- [ ] Every HTML file links `../tokens.css`
- [ ] Every HTML file uses `var(--...)` — NO raw hex, NO raw px
- [ ] **No `var(--sys-...)` refs inside component HTML** — components use comp-tier aliases ONLY
- [ ] Every HTML file has top comment listing comp-tier tokens used + a11y attrs
- [ ] Every HTML file uses semantic HTML elements
- [ ] Every HTML file shows ALL states/variants grouped by `<h2>/<h3>`
- [ ] `components.html` exists and iframes every component
- [ ] Open `components.html` in browser → renders correctly

**Legacy md (only if `--format=md`):**
- [ ] `components.md` derived from `components.json` (NOT hand-authored)
- [ ] Frontmatter has `legacy: true` and points `depends-on` at `./components.json`
- [ ] Deprecation warning emitted to stderr

## Constraints
- READ design.md once at start; don't re-read
- Do NOT touch primitive/semantic blocks in design.md — additive only
- Do NOT change mood — read it, apply it
- **Hard cutoff — no v3 backward compat.** v5 always outputs JSON + HTML + CSS. If user wants legacy YAML-only output, point them to v3. If they need Markdown index, use `--format=md` (v5–v6 only).
- Use the Write tool for every file; never paste full file contents into the chat response

## Quality Bar

**`components.json` (authoritative spec):**
- Token map completeness — every atom in scope binds every `--comp-*` alias it uses; no orphan aliases, no missing bindings
- Diff-only consistency — variants/sizes/states contain ONLY changed keys; no copy-paste of unchanged base tokens
- Ref hygiene — every ref is downward (`{design.*}` only inside `tokens`), every path resolves
- Schema-valid — passes `components.schema.json` validation with no warnings

**Runtime artifacts:**
A designer opening `components.html` in a browser should:
- See every atomic component with every state/variant rendered live
- Be able to inspect any element and see `var(--...)` instead of hex
- See visible focus rings, hit areas, and disabled states matching the `design.md` mood
- Click through to any `components/<name>.html` and see it work standalone
