---
name: design-component-builder
description: Build the components layer of a 3-file split-architecture design system. Reads design.md (tokens + mood), and outputs HTML files (components/<name>.html) + tokens.css alongside components.md spec. Each atomic component becomes a self-contained HTML file with all states/variants, referencing CSS custom properties mapped from semantic tokens. components.md serves as the index/spec pointing to the HTML files. Mood-biased state mapping. Default initial atomic scope: button, input, select, checkbox, radio, textarea, label, card, badge. Molecule/organism remain spec-only in components.md (Phase 3 work). Triggers on "build components", "add components", "atomic components", "เพิ่ม component", "สร้าง components", "atomic design", "component layer". Uses 2-tier token strategy (sys + comp aliases) following Material 3 + Carbon hybrid for optimal agent intent + low output token cost.
version: 4.1.0
user-invokable: true
args:
  - name: source
    description: Path to design.md (default ./design.md)
    required: false
  - name: scope
    description: "Comma-separated component names to build. Default: button,input,select,checkbox,radio,textarea,label,card,badge"
    required: false
---

# 🧩 Design Component Builder (v4)

Tier-3 layer builder. Reads `design.md` and outputs:
1. `tokens.css` — CSS custom properties mapped from semantic tokens
2. `components/<name>.html` — self-contained HTML file per atomic component
3. `components.html` — showcase aggregating all components via iframes
4. `components.md` — index/spec pointing to the HTML files

## When to use
- Have a `design.md` with primitive + semantic already built (via `design-builder`)
- Want runnable, browser-previewable components (not just YAML)
- Want components that ship as HTML+CSS, ready for design QA

## When NOT to use
- No `design.md` yet → run `design-builder` first
- Want to add icons → use `design-icon-builder`
- Want to check what's there → use `design-md-audit`

## 3-tier atomic architecture

| Layer | Examples | Output in v4 |
|---|---|---|
| **atom** | button, input, select, checkbox, radio, textarea, label, card, badge | **HTML file + components.md entry** |
| **molecule** | form-field, nav-item, search-bar, stat-tile | components.md spec only (Phase 3) |
| **organism** | sidebar, topbar, hero, table | components.md spec only (Phase 3) |

Template + page tiers live in `ui.md` / app code, NOT in components.md.

## Default initial atomic scope (v4)

`button, input, select, checkbox, radio, textarea, label, card, badge`

Override via `scope` arg.

## Token Architecture (v4.1 — Hybrid Layered)

v4.1 introduces a **2-tier CSS custom property strategy** inspired by Material 3 + Carbon. The goal is to keep agent intent legible AND minimize output tokens in component CSS.

### The 2 tiers

| Tier | Prefix | Purpose | Who reads it | Who uses it |
|---|---|---|---|---|
| **sys** | `--sys-*` | Semantic, cross-component intent (e.g. `--sys-color-primary`, `--sys-spacing-md`, `--sys-radius-md`) | Agent reads to UNDERSTAND intent ("this is the primary brand color") | NOT used directly in component CSS |
| **comp** | `--{component}-*` | Component-scoped aliases pointing to sys (e.g. `--btn-bg`, `--btn-bg-hover`, `--input-border`) | Agent reads to understand component-local naming | Agent USES in component CSS via `var(--btn-bg)` |

### Why 2 tiers (priority order)

1. **Intent legibility** — `--sys-color-primary` tells the agent WHAT a color means semantically; `--btn-bg` tells the agent WHERE it goes.
2. **Usability** — component CSS reads naturally: `background: var(--btn-bg)` instead of `background: var(--sys-color-primary-default)`.
3. **Output token cost** — comp aliases are short (`--btn-bg` is 8 chars vs `--sys-color-primary-default` at 28). Across hundreds of CSS rules, this saves significant tokens in generated HTML files.
4. **Scalability** — re-theming a component only requires changing its comp aliases; sys layer stays stable. Dark mode only re-declares sys, comp inherits automatically.

### Naming rules

- **sys tier** — `--sys-{category}-{role}[-{variant}]`
  - `--sys-color-primary`, `--sys-color-primary-hover`, `--sys-color-bg-surface`, `--sys-color-text-on-primary`
  - `--sys-spacing-xs|sm|md|lg|xl`, `--sys-radius-sm|md|lg`, `--sys-font-size-sm|md|lg`
- **comp tier** — `--{component}-{property}[-{state}]`
  - `--btn-bg`, `--btn-bg-hover`, `--btn-bg-disabled`, `--btn-fg`, `--btn-border`, `--btn-radius`, `--btn-padding-x`
  - `--input-bg`, `--input-border`, `--input-border-focus`, `--input-border-error`

### Example pattern

```css
:root {
  /* --- sys tier (semantic, cross-component) --- */
  --sys-color-primary: #3B82F6;
  --sys-color-primary-hover: #2563EB;
  --sys-color-text-on-primary: #FFFFFF;
  --sys-spacing-md: 16px;
  --sys-radius-md: 8px;

  /* --- comp tier (component-scoped aliases → sys) --- */
  --btn-bg: var(--sys-color-primary);
  --btn-bg-hover: var(--sys-color-primary-hover);
  --btn-fg: var(--sys-color-text-on-primary);
  --btn-padding-x: var(--sys-spacing-md);
  --btn-radius: var(--sys-radius-md);
}

.ds-btn {
  background: var(--btn-bg);    /* ✅ uses comp alias */
  color: var(--btn-fg);
  padding: 0 var(--btn-padding-x);
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
  - e.g. `semantic.colors.primary.default` → value `#3B82F6`
  - e.g. `semantic.spacing.md` → value `16px`
  - e.g. `semantic.radius.md` → value `8px`
  - e.g. `semantic.typography.label.md` → composed value (font/size/weight/lh)

Hold this flat token map in memory for Step 2.

### Step 2 — Write `tokens.css` (2-tier structure REQUIRED)

`tokens.css` MUST contain BOTH tiers in this order:

1. **sys tier** — map each semantic token from design.md → `--sys-*` custom property
2. **comp tier** — for every component in scope, declare component-scoped aliases pointing to sys

Mapping convention (sys tier):

- Path `semantic.colors.primary.default` → `--sys-color-primary`
- Path `semantic.colors.primary.hover` → `--sys-color-primary-hover`
- Path `semantic.colors.text.on-bgcolor` → `--sys-color-text-on-bgcolor`
- Path `semantic.spacing.md` → `--sys-spacing-md`
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
  --sys-spacing-md: 16px;
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
  --btn-padding-x: var(--sys-spacing-md);
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

### Step 3 — For each component in scope, write `components/<name>.html`

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

**Always WRITE the file with the Write tool. Do NOT include file content in the chat response.**

### Step 4 — Write `components.html` showcase

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

### Step 5 — Write `components.md` as INDEX/SPEC

`components.md` is now an INDEX pointing to the HTML files, plus the spec for molecule/organism layers (which remain YAML-only in v4).

Frontmatter:
```yaml
---
scope: 'components-only'
depends-on: ['./design.md']
outputs:
  - ./tokens.css
  - ./components.html
  - ./components/*.html
version: 4.0.0
---
```

Body sections:
1. **Atomic component index** — table linking each built component to its HTML file
   ```
   | Component | HTML file | States | A11y notes |
   |---|---|---|---|
   | button | [components/button.html](./components/button.html) | rest, hover, active, focus, disabled × 5 variants | hit-area-min 44px, role=button |
   | input | [components/input.html](./components/input.html) | rest, hover, focus, disabled, error | label-for required, aria-describedby |
   | ...
   ```
2. **Tokens.css mapping reference** — short table: semantic path → CSS custom property name
3. **Molecule layer (Phase 3 — spec only)** — YAML block describing planned molecules (form-field, nav-item, search-bar) with `composed-of:` referencing atom HTML files. No HTML output in v4.
4. **Organism layer (Phase 3 — spec only)** — YAML block describing planned organisms. No HTML output in v4.
5. **Known Gaps** — list anything skipped from default scope.

**Write the file with the Write tool. Do not include full content in response.**

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

Each HTML file MUST include these:

- **button** — `role="button"` (implicit on `<button>`), hit-area ≥44px (use padding to enforce on small sizes), `aria-label` if icon-only
- **input** — `id`, `aria-describedby` linking to helper-text, `aria-invalid="true"` on error
- **select** — same as input + `aria-expanded` on open state
- **checkbox / radio** — `<label for>` association, `aria-checked` if using non-native, group with `role="radiogroup"` for radios
- **textarea** — same as input
- **label** — `for="<input-id>"` MUST point to the input
- **card (interactive)** — `role="button"` or wrap in `<a>`, keyboard handler (tabindex=0)
- **badge** — `aria-label` if status communicated by color alone

Each HTML file's top comment MUST list the a11y attrs used.

## Validation checklist

- [ ] `tokens.css` exists at repo root
- [ ] `tokens.css` contains BOTH tiers: sys (`--sys-*`) AND comp (`--{component}-*`)
- [ ] Every sys-tier custom property has a source-path comment
- [ ] Every comp-tier alias points to a `var(--sys-*)` reference
- [ ] Dark mode block re-declares ONLY sys-tier (not comp aliases)
- [ ] Every component in scope has a `components/<name>.html` file
- [ ] Every HTML file links `../tokens.css`
- [ ] Every HTML file uses `var(--...)` — NO raw hex, NO raw px
- [ ] **No `var(--sys-...)` refs inside component HTML** — components use comp-tier aliases ONLY
- [ ] Every HTML file has top comment listing comp-tier tokens used + a11y attrs
- [ ] Every HTML file uses semantic HTML elements
- [ ] Every HTML file shows ALL states/variants grouped by `<h2>/<h3>`
- [ ] `components.html` exists and iframes every component
- [ ] `components.md` index table links every HTML file
- [ ] `components.md` frontmatter declares `scope: components-only`, `depends-on: ['./design.md']`
- [ ] Molecule/organism remain YAML-only in components.md (no HTML output)
- [ ] No raw hex/px anywhere except in `tokens.css`
- [ ] Open `components.html` in browser → renders correctly

## Constraints
- READ design.md once at start; don't re-read
- Do NOT touch primitive/semantic blocks in design.md — additive only
- Do NOT change mood — read it, apply it
- **Hard cutoff — no v3 backward compat.** v4 always outputs HTML+CSS. If user wants legacy YAML-only output, point them to v3.
- Use the Write tool for every file; never paste full file contents into the chat response

## Quality Bar
A designer opening `components.html` in a browser should:
- See every atomic component with every state/variant rendered live
- Be able to inspect any element and see `var(--color-...)` instead of hex
- See visible focus rings, hit areas, and disabled states matching the design.md mood
- Click through to any `components/<name>.html` and see it work standalone
