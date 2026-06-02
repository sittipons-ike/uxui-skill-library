---
name: design-styleguide
description: AGGREGATOR mode (default) — combines existing components/*.html + pages/*.html + patterns/*.html into single styleguide.html with TOC. Reads JSON manifests (components.json / ui.json / patterns.json) preferentially for TOC + section grouping; falls back to legacy MD spec (components.md / ui.md) if JSON not present. Auto-detects format. LEGACY render mode via --regenerate flag re-renders from spec instead of aggregating pre-built HTML.
version: 3.1.0
user-invokable: true
args:
  - name: source
    description: Path to DESIGN.md (default ./DESIGN.md) — only used in legacy mode
    required: false
  - name: output
    description: "html | figma | both — default: html"
    required: false
  - name: regenerate
    description: "Flag — force LEGACY spec-based rendering instead of aggregator mode"
    required: false
---

# 🎨 Design Styleguide

Generate a human-readable Style Guide so designers, PMs, and stakeholders can review and discuss the design system without reading YAML.

## Modes

### Aggregator mode (DEFAULT — v3.1.0)
Combines pre-rendered `components/*.html`, `pages/*.html`, and `patterns/*.html` (built by `design-component-builder` / `design-ui-builder`) into a single `styleguide.html` with TOC, theme toggle, and search. Fast, no re-rendering, always in sync with the actual built artifacts.

**Spec source for TOC + section grouping is auto-detected:**
- **JSON-first (v3.1+):** if `components.json` / `ui.json` / `patterns.json` exist, read them as the catalog of what to group + label
- **MD fallback:** if only `components.md` / `ui.md` exist (legacy `--format=md` output), parse prose for the same catalog
- **Mixed allowed:** can read components.json + ui.md if that's what's present (warn user, but proceed)

### Legacy render mode (`--regenerate` flag)
Renders styleguide.html directly from spec (JSON-first, MD fallback) without depending on pre-built component HTML files. Use when component/page HTML files don't exist yet, or when you want a fresh render.

### Figma mode
Unchanged from v2 — paints frames on Figma canvas via `figma-console` MCP. Available in both modes.

## When to use
- Designer wants to review tokens visually before approving the DESIGN.md
- Need a shareable link/Figma frame for stakeholder review
- Onboarding new team members
- Before/after comparison when iterating the DS

## When NOT to use
- File doesn't exist yet → use `design-builder` first
- Need machine-readable output → DESIGN.md already is that
- Want token-level audit → use `design-md-audit`

## Inputs (Reads)

**PREFERRED (JSON-first, v3.1+):**
- `./design.md` — designer-facing tokens (always MD, unchanged)
- `./components.json` — atom/molecule/organism catalog
- `./ui.json` — page list
- `./patterns.json` — reusable patterns
- `./components/*.html` — pre-rendered atomic component pages
- `./pages/*.html` — pre-rendered UI compositions
- `./patterns/*.html` — pre-rendered patterns (if present)

**FALLBACK (legacy MD spec, `--format=md` output from v5+v6 of builders):**
- `./design.md` (unchanged)
- `./components.md`
- `./ui.md`
- same `./components/*.html` + `./pages/*.html` + `./patterns/*.html`

**Auto-detect rule:**
- If `components.json` exists → JSON mode for components catalog
- If `ui.json` exists → JSON mode for pages catalog
- If `patterns.json` exists → JSON mode for patterns catalog
- For each scope, fall back to `.md` only if `.json` not present
- Log chosen mode per scope to stderr before proceeding

## Spec Format Detection

| Check | If present → use as | Fallback if missing |
|---|---|---|
| `components.json` | atom / molecule / organism catalog (JSON keys) | `components.md` (parse prose) |
| `ui.json` | page list (JSON keys) | `ui.md` (parse prose) |
| `patterns.json` | patterns catalog (JSON keys) | extract from `ui.md` "pattern" section (or skip) |

**Mixed-source warning:** if BOTH `<scope>.json` AND `<scope>.md` exist for the same scope, prefer `.json` and emit a warning to user: `"WARN: both components.json and components.md present — using components.json. Delete the stale .md file or re-run builder with consistent --format flag."`

## Scope
**INCLUDED:**
- Semantic colors (all role groups × scale)
- Semantic typography (every role rendered)
- Semantic spacing, radius, elevation
- Component examples (every variant × state where applicable)
- Do's and Don'ts (read from DESIGN.md body)

**EXCLUDED:**
- Primitive layer (raw hex / Tailwind hues) — too technical for design discussion
- YAML / code blocks — designers don't need them

## Execution Steps

### 0. Detect spec format (JSON vs MD)

Before anything else, decide where to read the catalog from. Run independently per scope:

```
COMPONENTS_SOURCE = exists("./components.json") ? "json" : exists("./components.md") ? "md" : "none"
UI_SOURCE         = exists("./ui.json") ? "json" : exists("./ui.md") ? "md" : "none"
PATTERNS_SOURCE   = exists("./patterns.json") ? "json" : exists("./ui.md#patterns") ? "md-embedded" : "none"
```

**Mixed-source warning:** for each scope, if BOTH `.json` AND `.md` exist, prefer `.json` and emit warning (see Spec Format Detection table above).

Log the resolved sources to stderr:
```
[styleguide] components: components.json
[styleguide] ui:         ui.md (fallback — ui.json not found)
[styleguide] patterns:   patterns.json
```

### 1. Detect render mode

```
if --regenerate flag is passed:
  → LEGACY render mode (skip to step 2-legacy)
elif glob("./components/*.html") returns ≥1 file:
  → AGGREGATOR mode (skip to step 2-aggregator)
else:
  → fall back to LEGACY render mode (no pre-built HTML to aggregate)
```

State the chosen mode explicitly to the user before proceeding.

### 2-aggregator. AGGREGATOR mode (default)

#### 2a. Glob inputs + resolve catalog from spec

Pre-rendered HTML files (always globbed):
- `components/*.html` — atomic components (one file per component)
- `pages/*.html` — UI compositions (one file per page)
- `patterns/*.html` — reusable patterns (if present)

**Catalog source — use Step 0 resolution:**

When `COMPONENTS_SOURCE == "json"`:
- Read `components.json`, iterate top-level keys: `atom`, `molecule`, `organism`
- Each child key (e.g., `atom.button`, `molecule.field-text`) → one TOC entry
- Section label = component spec's `name` field (or kebab→Title Case if absent)
- Tier grouping comes directly from the top-level key — no filename guessing

When `COMPONENTS_SOURCE == "md"`:
- Fall back to prose parsing of `components.md`
- Or categorize by filename hint (existing v3.0 logic):
  - `components/atom-*.html` or `<meta name="tier" content="atom">` → Atoms
  - `components/molecule-*.html` → Molecules
  - `components/organism-*.html` → Organisms

When `UI_SOURCE == "json"`:
- Read `ui.json`, iterate top-level `page` keys → TOC entries under "Pages"
- Section label = page spec's `name` or `title`

When `UI_SOURCE == "md"`:
- Parse `ui.md` prose for page list
- Or bucket all `pages/*.html` as "Pages" (filename → Title Case)

When `PATTERNS_SOURCE == "json"`:
- Read `patterns.json`, iterate top-level keys → TOC entries under "Patterns"

When `PATTERNS_SOURCE == "md-embedded"`:
- Extract pattern names from `ui.md` pattern section (legacy v5 ui.md format)

If catalog source is `"none"` for any scope and HTML files exist for that scope → fall back to filename-derived labels + bucket as "Components" / "Pages" / "Patterns" (uncategorized).

#### 2b. Build single styleguide.html

Output a self-contained `styleguide.html` next to the source directory with this structure:

```html
<!doctype html>
<html data-theme="light">
<head>
  <!-- Tailwind CDN, inline styles for theme toggle + search -->
</head>
<body>
  <header>
    <h1>{Brand} Style Guide</h1>
    <input type="search" id="filter" placeholder="Search sections…">
    <button id="theme-toggle">🌓 Toggle theme</button>
  </header>

  <nav id="toc">
    <details open><summary>Atoms</summary>
      <ul><li><a href="#atom-button">Button</a></li>…</ul>
    </details>
    <details open><summary>Molecules</summary>…</details>
    <details open><summary>Organisms</summary>…</details>
    <details open><summary>Patterns</summary>…</details>
    <details open><summary>Pages</summary>…</details>
  </nav>

  <main>
    <section id="atom-button" data-name="button" data-tier="atom">
      <h2>Button</h2>
      <iframe src="components/button.html" loading="lazy"
              width="100%" height="400" frameborder="0"></iframe>
    </section>
    <!-- one section per globbed file -->
  </main>

  <script>
    // theme toggle: flip data-theme on <html>, persist in localStorage
    // search: filter <section> by data-name on input
    // each section also propagates data-theme to its iframe via postMessage
  </script>
</body>
</html>
```

**Required features:**
- **TOC (`<nav>`)** — grouped by tier (Atoms / Molecules / Organisms / Patterns / Pages), each group collapsible via `<details>`. Group + label data comes from JSON catalog when available, else from filename hint.
- **Theme toggle** — sets `data-theme="light|dark"` on `<html>`, persists in `localStorage`, and posts message to each iframe so child docs can react
- **Search box** — filters `<section>` elements by `data-name` attribute (case-insensitive substring match); also auto-collapses TOC groups with no matches
- **Iframe lazy-loading** — `loading="lazy"` on every iframe so initial paint is fast even with 100+ components
- **No external assets** — Tailwind CDN OK, but no copied CSS/JS files; everything inline in `styleguide.html` except the iframe sources

#### 2c. Validate aggregator output
- [ ] Every globbed file has a corresponding `<section>` + TOC entry
- [ ] TOC groups are in canonical order: Atoms → Molecules → Organisms → Patterns → Pages
- [ ] Theme toggle persists across reload
- [ ] Search filters in <200ms with 100 sections
- [ ] All iframes have `loading="lazy"`
- [ ] No broken iframe src (every src points to a real file)
- [ ] WARN if both `<scope>.json` AND `<scope>.md` present for same scope (one is stale)
- [ ] If JSON catalog claims an entry that has no matching `*.html` file → log warning + skip TOC entry
- [ ] If `*.html` file exists but no JSON/MD catalog entry → still include, label from filename, log info

### 2-legacy. LEGACY render mode (`--regenerate` or no pre-built HTML)

Re-renders styleguide.html from spec. Honors Step 0 source resolution:

#### Load source
- **Tokens:** always read `./design.md` (designer-facing MD, unchanged).
- **Components catalog:**
  - JSON-first: `./components.json` → iterate `atom` / `molecule` / `organism` keys; resolve `{design.semantic.*}` refs against design.md tokens
  - MD fallback: `./components.md` → parse prose blocks for atoms/molecules/organisms
- **Pages catalog:**
  - JSON-first: `./ui.json` → iterate top-level page keys; resolve `{components.*}` refs
  - MD fallback: `./ui.md` → parse prose
- **Patterns catalog:**
  - JSON-first: `./patterns.json` → iterate top-level keys
  - MD fallback: extract from `ui.md` pattern section
- **Monolithic legacy:** if none of the above exist, look for `./DESIGN.md` (single file). All sections come from one file with bare-path refs.
- Parse YAML frontmatter from MD files; verify `scope:` matches filename. JSON manifests use `$schema` field instead of frontmatter.

#### Pick output mode
Based on `output` arg (default `html`):
- `html` — generate `STYLEGUIDE.html` next to DESIGN.md
- `figma` — paint frames on current Figma canvas via `figma-console` MCP
- `both` — do both

#### HTML output (legacy)

Generate a single self-contained file `STYLEGUIDE.html`:
- Tailwind CDN (no build step required)
- One `<section>` per category
- Final hex/px values inline (not as `{primitive.*}`-refs)
- Designer-friendly labels (semantic names, not paths)

**Sections (in this order):**

1. **Header** — brand name, last-updated date, version (from DESIGN.md frontmatter)
2. **Color roles** — each group renders as swatch grid:
   - `text` — sample text "Aa" + label + resolved hex
   - `surface` / `background` — solid swatch + label + hex
   - `primary` / `secondary` / `tertiary` × 5-stop scale — horizontal row of 5 swatches
   - `status` × 4 channels × 5-stop scale — grouped grid
   - `border` — line samples
3. **Typography** — every role rendered with actual text. Show: role label + `{family} {size}/{line-height} {weight}` + sample paragraph
4. **Spacing scale** — visual bars (xs to 3xl) with px labels
5. **Radius scale** — square samples with each radius
6. **Elevation** — cards with each shadow level
7. **Components** — for each component:
   - Variant name + size
   - All states rendered as live mockups (default, hover, pressed, focused, disabled)
   - Use CSS pseudo-classes for hover/focus so designers can actually interact
   - Below each: the semantic ref path (e.g., `bg.hover → {semantic.colors.primary.dark}`)
8. **Do's and Don'ts** — copy from DESIGN.md body, render as 2-column with ✓ / ✗

**HTML template requirements:**
- Mobile + desktop responsive
- Light + dark mode toggle (use `prefers-color-scheme` AND a manual toggle)
- Search/jump-to-section nav
- Copy-token button next to each swatch (clipboard semantic path)
- Print stylesheet (designers print these for reviews)

### 3. Figma output (BOTH modes)

Use `figma-console` MCP. Connection check first via `figma_get_status`.

**Frame layout (top-down on canvas):**

```
Section: Brand Header  (1440 × 200)
Section: Colors        (1440 × auto, grid of swatches)
Section: Typography    (1440 × auto, sample text per role)
Section: Spacing       (1440 × 400)
Section: Radius        (1440 × 400)
Section: Elevation     (1440 × 400)
Section: Components    (1440 × auto, per component)
Section: Do/Don't      (1440 × auto)
```

**Rules:**
- Create one `Section` per category (Figma section, not frame)
- Use existing design system components if found via `figma_search_components`
- Token swatches as auto-layout frames with text labels
- Label every swatch with semantic name (NOT hex — Figma users care about token name)
- DO NOT modify existing pages — create a new page named `Style Guide v<n>`
- Place all sections in one vertical column with 80px gap

**Component rendering rule:**
- For each variant × state combo → 1 frame
- Frame name: `Button / Primary / Hover` (Figma slash naming)
- This lets designers right-click → "Detach instance" to use as starting point

### 4. Validate output

**Aggregator mode self-check:**
- [ ] styleguide.html opens with no console errors
- [ ] TOC has every globbed file represented
- [ ] Theme toggle works + persists
- [ ] Search filter works
- [ ] All iframes load (no 404s)

**Legacy mode self-check:**
- [ ] No `{primitive.*}` refs visible in any output (resolve all to hex/px)
- [ ] No YAML / code blocks visible
- [ ] Every color swatch has: visual + label + resolved hex
- [ ] Every component variant has at least default state rendered
- [ ] Do/Don't section has at least 4 pairs
- [ ] HTML passes basic WCAG AA contrast for its OWN UI (not the swatches it shows)
- [ ] Figma output: no duplicate page named "Style Guide v<n>" (increment if exists)

### 5. Deliver
- HTML → tell user the file path + suggest `open styleguide.html`
- Figma → tell user the new page name + link to it via `figma_navigate`
- State which render mode ran (aggregator vs legacy) AND which catalog source per scope (e.g., "components: components.json, ui: ui.md fallback") so user knows what to expect
- The standalone `components.html` aggregator (built by `design-component-builder`) is NOT touched by this skill — styleguide.html is the unified parent view that links to all built artifacts via iframes

## Output Format Rules
- Designer-friendly: no jargon without definition
- Semantic names visible; primitive refs hidden
- Final hex/px shown (resolved, not symbolic)
- Real text in typography samples — not "Lorem ipsum"
- Use brand name from DESIGN.md frontmatter consistently

## Constraints
- Read-only on all spec files (design.md, components.json, components.md, ui.json, ui.md, patterns.json) and all pre-built HTML (components/*.html, pages/*.html, patterns/*.html) — never modify them
- HTML must be self-contained (single file, CDN dependencies OK)
- Figma: never delete existing pages
- Aggregator mode: if a globbed file is malformed → skip with warning, don't abort
- Aggregator mode: if both `<scope>.json` AND `<scope>.md` present → use `.json`, warn user one is stale
- Legacy mode: if `design.md` is incomplete (Phase 1 only / no semantic), output what exists + note "Component layer not yet defined" in a Known Gaps section
- Legacy mode: if `primitive:` block is missing → cannot resolve hexes → ABORT with clear message
- Ref resolution: brace syntax `{file.path}` per schemas/ref-resolver.md — `{design.semantic.*}`, `{components.atom.*}`, etc.

## Quality Bar
A designer should:
- Understand the entire DS in 5 minutes scanning the styleguide
- Identify which token to use for a new design without reading DESIGN.md
- Spot inconsistencies (e.g., 2 status colors that look identical) visually
- Be able to print + bring to a review meeting

A developer should:
- Use the styleguide as the visual reference + DESIGN.md as the machine reference
- NEVER read the styleguide to extract values — go to DESIGN.md instead
