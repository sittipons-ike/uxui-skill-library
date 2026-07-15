# Ref Resolver Specification

> Algorithm for resolving cross-file references in the UXUI manifest system.
> Status: **Stable** (v6+)
> Applies to: `design.md`, `components.json`, `patterns.json`, `ui.json`
> Last updated: 2026-06-02

---

## 1. Overview

The UXUI design system spans four files, each with a single, well-defined scope:

| File | Format | Scope prefix | Role |
|---|---|---|---|
| `design.md` | YAML-in-Markdown | `design` | Design tokens (primitive + semantic), mood, iconography |
| `components.json` | JSON | `components` | Atomic component library (atom / molecule / organism) |
| `patterns.json` | JSON | `patterns` | Reusable cross-page structures (auth-split, app-shell, empty-state, etc.) |
| `ui.json` | JSON | `ui` | Page-level compositions (full screens, flows, sections) |

These files reference each other through a **brace-style ref syntax** (`{file.path.to.thing}`) modeled on the [DTCG](https://design-tokens.github.io/community-group/format/) token alias format. This document specifies the syntax, scope/direction rules, resolution algorithm, and the diff-merge algorithm used to render component variants × sizes × states.

---

## 2. Ref Syntax

### 2.1 Grammar

A reference is a string consisting of an opening brace, a scope prefix, a dot, a dot-separated path, and a closing brace.

```
ref        := "{" scope "." path "}"
scope      := "design" | "components" | "patterns" | "ui"
path       := segment ("." segment)*
segment    := [a-z0-9_\-]+
```

### 2.2 Regex

```regex
^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$
```

- **Group 1** = scope prefix
- **Group 2** = dot-path inside that scope

### 2.3 Examples

| Ref | Resolves to |
|---|---|
| `{design.semantic.color.primary.default}` | `design.md` → `semantic.color.primary.default` (YAML path) |
| `{design.primitive.color.blue.500}` | `design.md` → `primitive.color.blue.500` |
| `{components.atom.button}` | `components.json` → `atom.button` (full component object) |
| `{components.atom.button.variants.primary}` | `components.json` → `atom.button.variants.primary` (sub-path into a component) |
| `{components.molecule.field-text.states.disabled}` | `components.json` → `molecule.field-text.states.disabled` |
| `{patterns.auth-split}` | `patterns.json` → `auth-split` |
| `{patterns.app-shell.regions.sidebar}` | `patterns.json` → `app-shell.regions.sidebar` |
| `{ui.page.signin}` | `ui.json` → `page.signin` |
| `{ui.flow.checkout.step.payment}` | `ui.json` → `flow.checkout.step.payment` |

### 2.4 Sub-path rules

- A ref may target the **whole** entity (`{components.atom.button}`) or a **sub-path** inside it (`{components.atom.button.variants.primary}`).
- Sub-paths follow plain object-key descent. Array indexing is not supported — use named keys instead.
- Segments are restricted to lowercase `[a-z0-9_\-]`. CamelCase, dots-inside-keys, and spaces are not valid. This keeps refs unambiguous when parsed.

---

## 3. Scope Enforcement

Each manifest declares its scope in `$meta.scope`:

```json
// components.json
{
  "$meta": {
    "scope": "components",
    "version": "6.0.0",
    "dtcg_version": "1.0.0-draft",
    "depends_on": ["design"]
  },
  "atom": { /* ... */ }
}
```

### 3.1 Self-refs

A manifest **may not** reference its own scope through the prefixed form. Within `components.json`, refer to a sibling atom as `{components.atom.icon}` — but the resolver also accepts the unprefixed shorthand `atom.icon` inside the same file (treated as scope-local). Cross-file prefixed refs are mandatory once the scope crosses a file boundary.

### 3.2 Cross-scope refs — downward only

Refs are allowed strictly in the downward direction of the dependency graph:

```
ui  →  patterns  →  components  →  design
```

| From | May ref into |
|---|---|
| `ui` | `patterns`, `components`, `design` |
| `patterns` | `components`, `design` |
| `components` | `design` |
| `design` | (none — leaf) |

### 3.3 Direction violations = audit error

Any ref pointing **upward** is a hard audit failure. Examples:

- `design.md` referencing `{components.atom.button}` → **error**
- `components.json` referencing `{patterns.auth-split}` → **error**
- `patterns.json` referencing `{ui.page.signin}` → **error**

The reasoning: leaf files (`design.md`) must remain stable primitives that lower layers can rely on without circularity. Letting tokens depend on components would create chicken-and-egg builds.

---

## 4. Resolution Algorithm

### 4.1 Pseudocode

```js
// All four manifests are loaded into a single registry.
// design.md is parsed from YAML-in-Markdown; the others are plain JSON.
const manifests = {
  design:     parseYamlFromMarkdown("design.md"),
  components: parseJson("components.json"),
  patterns:   parseJson("patterns.json"),
  ui:         parseJson("ui.json"),
};

function resolve(ref, manifests, callerScope = null) {
  // 1. Parse the ref.
  const match = /^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$/.exec(ref);
  if (!match) {
    return { ok: false, error: "INVALID_SYNTAX", ref };
  }
  const [, scope, path] = match;

  // 2. Enforce direction (downward only).
  if (callerScope && !isDownward(callerScope, scope)) {
    return { ok: false, error: "UPWARD_REF", from: callerScope, to: scope, ref };
  }

  // 3. Walk the dot-path inside the target manifest.
  const root = manifests[scope];
  if (!root) {
    return { ok: false, error: "SCOPE_NOT_LOADED", scope };
  }

  let node = root;
  for (const segment of path.split(".")) {
    if (node == null || typeof node !== "object" || !(segment in node)) {
      return { ok: false, error: "PATH_NOT_FOUND", scope, path };
    }
    node = node[segment];
  }

  return { ok: true, value: node, scope, path };
}

// Order: ui (3) → patterns (2) → components (1) → design (0)
function rank(scope) {
  return { ui: 3, patterns: 2, components: 1, design: 0 }[scope];
}
function isDownward(from, to) {
  return rank(to) < rank(from);
}
```

### 4.2 Recursive resolution

Resolved values may themselves contain refs (e.g. a component's `tokens.background` field is a ref into `design`). Resolution is **lazy** — `resolve()` returns the raw stored value. Callers that need the fully-flattened render call `resolveDeep()`:

```js
function resolveDeep(value, manifests, callerScope, seen = new Set()) {
  if (typeof value === "string" && /^\{[\w\.\-]+\}$/.test(value)) {
    if (seen.has(value)) {
      return { ok: false, error: "CIRCULAR_REF", chain: [...seen, value] };
    }
    seen.add(value);
    const r = resolve(value, manifests, callerScope);
    if (!r.ok) return r;
    return resolveDeep(r.value, manifests, r.scope, seen);
  }
  if (Array.isArray(value)) {
    return { ok: true, value: value.map(v => resolveDeep(v, manifests, callerScope, new Set(seen)).value) };
  }
  if (value && typeof value === "object") {
    const out = {};
    for (const k of Object.keys(value)) {
      const r = resolveDeep(value[k], manifests, callerScope, new Set(seen));
      if (!r.ok) return r;
      out[k] = r.value;
    }
    return { ok: true, value: out };
  }
  return { ok: true, value };
}
```

`seen` is cloned per branch so siblings don't poison each other's cycle detection — only a single descending chain counts as circular.

---

## 5. Diff-Merge Algorithm (variants × sizes × states)

Components store variants, sizes, and states as **diffs from base** — not as fully-materialized copies. The renderer composes a final token map by deep-merging the base with each applied modifier in a fixed order, last-write-wins.

### 5.1 Stored shape

```json
// components.json (excerpt)
{
  "atom": {
    "button": {
      "tokens": {
        "background": "{design.semantic.color.primary.default}",
        "foreground": "{design.semantic.color.on-primary.default}",
        "radius":     "{design.semantic.radius.md}",
        "padding":    { "x": "{design.semantic.space.4}", "y": "{design.semantic.space.2}" },
        "typography": "{design.semantic.typography.label.md}"
      },
      "variants": {
        "primary":   { /* same as base — empty diff */ },
        "secondary": {
          "tokens": {
            "background": "{design.semantic.color.surface.muted}",
            "foreground": "{design.semantic.color.on-surface.default}"
          }
        },
        "ghost": {
          "tokens": {
            "background": "{design.semantic.color.surface.transparent}",
            "foreground": "{design.semantic.color.primary.default}"
          }
        }
      },
      "sizes": {
        "sm": { "tokens": { "padding": { "x": "{design.semantic.space.3}", "y": "{design.semantic.space.1}" }, "typography": "{design.semantic.typography.label.sm}" } },
        "md": { /* base — empty diff */ },
        "lg": { "tokens": { "padding": { "x": "{design.semantic.space.6}", "y": "{design.semantic.space.3}" }, "typography": "{design.semantic.typography.label.lg}" } }
      },
      "states": {
        "rest":     { /* base */ },
        "hover":    { "tokens": { "background": "{design.semantic.color.primary.hover}" } },
        "active":   { "tokens": { "background": "{design.semantic.color.primary.active}" } },
        "focus":    { "tokens": { "ring": "{design.semantic.color.primary.light}@60%" } },
        "disabled": { "tokens": { "background": "{design.semantic.color.surface.disabled}", "foreground": "{design.semantic.color.on-surface.disabled}" } }
      }
    }
  }
}
```

### 5.2 Render function

```js
function render(component, { variant = null, size = null, state = "rest" }) {
  let acc = deepClone(component);             // start with base
  if (variant && component.variants?.[variant]) acc = deepMerge(acc, component.variants[variant]);
  if (size    && component.sizes?.[size])      acc = deepMerge(acc, component.sizes[size]);
  if (state   && component.states?.[state])    acc = deepMerge(acc, component.states[state]);
  // Strip the modifier maps from the rendered output — they only exist on the source.
  delete acc.variants;
  delete acc.sizes;
  delete acc.states;
  return acc;
}

function deepMerge(target, source) {
  if (Array.isArray(source)) return source.slice();    // arrays replace, not concat
  if (source === null || typeof source !== "object") return source;
  const out = { ...target };
  for (const k of Object.keys(source)) {
    if (k in out && out[k] && typeof out[k] === "object" && !Array.isArray(out[k]) &&
        source[k] && typeof source[k] === "object" && !Array.isArray(source[k])) {
      out[k] = deepMerge(out[k], source[k]);
    } else {
      out[k] = deepMerge({}, source[k]); // overwrite (last-write-wins)
    }
  }
  return out;
}
```

### 5.3 Order matters

The merge order is **base → variant → size → state**. This order is fixed and not configurable:

- **variant** sets the semantic role (primary/secondary/ghost) — affects which color tokens apply.
- **size** then adjusts geometry (padding, typography scale) without revisiting variant choices.
- **state** is applied last so interaction feedback (hover/active/focus/disabled) overrides whatever variant+size produced.

Reversing this order would, for example, make a `disabled` button incorrectly inherit `primary` hover colors after the variant layer fires last.

### 5.4 Worked example — `button` variant=`secondary` size=`lg` state=`hover`

1. **Base**: `background = {design.semantic.color.primary.default}`, `padding.x = space.4`, `padding.y = space.2`, `typography = label.md`.
2. **+ variant `secondary`**: `background → {design.semantic.color.surface.muted}`, `foreground → {design.semantic.color.on-surface.default}`. Padding/typography unchanged.
3. **+ size `lg`**: `padding.x → space.6`, `padding.y → space.3`, `typography → label.lg`.
4. **+ state `hover`**: `background → {design.semantic.color.primary.hover}`.

Final rendered token map (before deref):

```json
{
  "background": "{design.semantic.color.primary.hover}",
  "foreground": "{design.semantic.color.on-surface.default}",
  "radius":     "{design.semantic.radius.md}",
  "padding":    { "x": "{design.semantic.space.6}", "y": "{design.semantic.space.3}" },
  "typography": "{design.semantic.typography.label.lg}"
}
```

After `resolveDeep()` runs against `design.md`, those refs flatten into concrete hex/px/font values for output (Style Dictionary, CSS, Figma variables, etc.).

> **Note on the example.** The `hover` state above keeps the *primary* hover color even though variant=secondary was applied. In practice, components express state colors as their own per-variant overrides (e.g. `variants.secondary.states.hover`). The merge order remains the same — variant first, then a state diff that's already scoped to that variant. The simple form shown here is for illustration; production schemas commonly nest `states` inside `variants` when the hover color differs per variant.

---

## 6. `$meta.depends_on` — Auto-Loading

Every manifest declares its downstream dependencies in `$meta.depends_on`:

```json
// ui.json
{ "$meta": { "scope": "ui", "depends_on": ["patterns", "components", "design"] } }

// patterns.json
{ "$meta": { "scope": "patterns", "depends_on": ["components", "design"] } }

// components.json
{ "$meta": { "scope": "components", "depends_on": ["design"] } }

// design.md (frontmatter)
$meta:
  scope: design
  depends_on: []
  dtcg_version: "1.0.0-draft"
```

Tools that consume manifests (audit, style-guide renderer, Style Dictionary transform) **must**:

1. Read the entry file's `$meta.depends_on`.
2. Recursively load each dependency from the conventional location (`./design.md`, `./components.json`, etc.).
3. Halt with a clear error if a dependency is missing — never silently skip refs into unloaded scopes.
4. Detect cycles in the dependency graph and refuse to proceed (cycles are already prevented by the downward-only rule, but tools should double-check).

---

## 7. Backward Compatibility

### 7.1 Legacy unprefixed refs

Pre-v6 manifests use bare paths without a file prefix, e.g. `{semantic.color.primary.default}` instead of `{design.semantic.color.primary.default}`. The resolver supports these in compatibility mode:

```js
function normalizeLegacyRef(ref) {
  // {semantic.*} or {primitive.*} or {mood.*} or {iconography.*} → assume design scope
  const legacyDesignRoots = /^\{(semantic|primitive|mood|iconography)\./;
  if (legacyDesignRoots.test(ref)) {
    return ref.replace(/^\{/, "{design.");
  }
  return ref;
}
```

Behavior:

- The audit emits a **deprecation warning** (not an error) for any legacy ref encountered.
- The `--format=md` legacy flag (v5 + v6) keeps these refs as-is on output; v7 removes both the flag and the compatibility shim.
- New files written by v6+ tools must use prefixed refs.

### 7.2 Legacy monolithic `DESIGN.md`

If only the old monolithic `DESIGN.md` is present (no split files), the resolver loads it as the `design` scope and treats `components`/`patterns`/`ui` as empty. Refs into those empty scopes resolve to `PATH_NOT_FOUND`, prompting the user to run the split-migration command.

---

## 8. Edge Cases & Errors

| Case | Behavior |
|---|---|
| Ref to non-existent path | `resolve()` returns `{ ok: false, error: "PATH_NOT_FOUND", scope, path }`. Audit reports the source location. |
| Circular ref chain (`A → B → A`) | `resolveDeep()` returns `{ ok: false, error: "CIRCULAR_REF", chain: [...] }` with the full chain for debugging. |
| Upward ref (e.g. `design` → `components`) | `resolve()` returns `{ ok: false, error: "UPWARD_REF" }` immediately, before path lookup. |
| Scope not loaded (manifest missing on disk) | `resolve()` returns `{ ok: false, error: "SCOPE_NOT_LOADED" }`. Tools surface this as a missing-dependency error. |
| Malformed ref (typo, missing brace, illegal chars) | `resolve()` returns `{ ok: false, error: "INVALID_SYNTAX" }`. The string is treated as a literal, not a ref. |
| Deeply nested sub-paths (`{components.atom.button.variants.primary.states.hover.tokens.background}`) | Supported. The dot-path walks arbitrary depth; only the per-segment regex restricts characters. |
| Ref inside a string template (`"radius {design.semantic.radius.md} applied"`) | **Not supported.** Only whole-string refs are recognized. Tools must store the ref as the entire value, never embedded inside prose. |
| Mixed-scope diff in variants/sizes/states | Allowed. A variant diff may add new refs to any downward scope, subject to the same direction rule. |
| Array values in diffs | Arrays **replace** rather than merge (see `deepMerge` above). To extend an array, the diff must spell out the full new array. |
| `null` in a diff | Treated as a literal value (`base.x = null` overwrites). To "unset" a key, use `null` explicitly — there is no separate sentinel. |

---

## 9. DTCG Alignment

The brace syntax `{group.token.name}` matches the [Design Tokens Community Group](https://design-tokens.github.io/community-group/format/#aliases-references) alias format exactly. Practical implications:

- The `design` manifest's `primitive` and `semantic` blocks can be emitted as-is to a DTCG-compliant JSON file with minimal transformation — only the YAML→JSON shape changes.
- A future Style Dictionary or `style-dictionary-utils` transform reads the `tokens` block directly without rewriting refs.
- `$meta.dtcg_version` pins the spec version the manifest targets (currently `1.0.0-draft`). Tools should fail loudly if they encounter a version they don't recognize, rather than silently degrade.
- Custom scopes (`components`, `patterns`, `ui`) extend the DTCG ref space but remain syntactically compatible — pure DTCG consumers can ignore them and still consume the `design` tokens.

---

## 10. Implementation Notes

- **Parsing.** `design.md` is YAML-in-Markdown — extract the fenced YAML block via a Markdown parser before YAML-parsing. Treat the entire YAML root as the `design` scope.
- **Caching.** `resolveDeep()` results are deterministic given the manifest set. Tools running over many components (style guide renderer, audit) should memoize by ref string.
- **Error reporting.** Always include the *source location* (file + JSON pointer or YAML line) of the offending ref in error messages — not just the ref string. This is the single biggest quality-of-life improvement for designers debugging broken refs.
- **Performance.** With ~10–50 atoms × ~5 variants × ~5 sizes × ~6 states, a full render of `components.json` produces ~7,500 rendered combinations. Merge is O(tokens-per-component) per combination; in practice well under 100 ms for typical libraries.

---

## 11. Versioning

This resolver spec follows **per-skill semantic versioning**. Breaking changes to the ref syntax, direction rule, or merge order require a major bump of the resolver itself, independent of the library-wide release cadence.

- **v6.0** — Current. Brace syntax, four-scope model, diff-only variants, `--format=md` legacy flag supported with deprecation warnings.
- **v7.0** *(planned)* — Removes `--format=md` and the legacy unprefixed-ref compatibility shim.

---

## 12. References

- [DTCG Format Spec — Aliases / References](https://design-tokens.github.io/community-group/format/#aliases-references)
- `schemas/components.schema.json` — JSON Schema for the components manifest (atomic-level keys, variants/sizes/states shape)
- `schemas/patterns.schema.json` — JSON Schema for cross-page patterns
- `schemas/ui.schema.json` — JSON Schema for page-level compositions
- `skills/design-md-audit.md` — Audit skill that enforces the direction rule and reports broken refs
