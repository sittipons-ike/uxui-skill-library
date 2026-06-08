# `figma-push-components` — Concrete Walkthrough

> End-to-end examples showing how the skill behaves across first-time push, idempotent re-run, additive update, pre-flight failure, and Figma-model limitations.
> Reference inputs: `examples/components.example.json` (atom shape) + `skills/design-component-builder/examples/components/button.html` (HTML template).

---

## Scenario A — First-time push of `Button` atom

### A.1 User invocation

```
> /figma-push-components
```

### A.2 Pre-flight `AskUserQuestion` responses

| # | Question | Answer |
|---|---|---|
| 1 | Which `components.json` should I push? | `./design-system/components.json` |
| 2 | Target Figma file? | currently open — `DS / Foundations v2` |
| 3 | Which scope? | `atom` only (skip molecule/organism for now) |
| 4 | Which atoms? | `button` (skip input/badge/label/help-text) |
| 5 | Confirm DS Tokens variable collection exists? | yes — pushed via `/figma-push-tokens` 5 min ago |
| 6 | Naming convention? | `Component / <id> / <Variant> / <Size> / <State>` (default) |
| 7 | Dry-run first? | yes — preview before commit |

### A.3 Sample `components.json` input (button entry)

Taken directly from `examples/components.example.json → atom.button`:

```json
{
  "atom": {
    "button": {
      "id": "button",
      "summary": "Primary interactive control. Use for triggering actions, never for navigation.",
      "tokens": {
        "--btn-bg": "{design.semantic.color.primary.default}",
        "--btn-fg": "{design.semantic.color.on-primary}",
        "--btn-border": "{design.semantic.color.primary.default}",
        "--btn-radius": "{design.semantic.radius.md}",
        "--btn-padding-x": "{design.semantic.space.4}",
        "--btn-padding-y": "{design.semantic.space.2}",
        "--btn-font": "{design.semantic.typography.label.md}"
      },
      "variants": {
        "primary":   { "classes": ["btn--primary"] },
        "secondary": { "classes": ["btn--secondary"], "tokens": { "--btn-bg": "{design.semantic.color.surface.raised}", "--btn-fg": "{design.semantic.color.content.default}" } },
        "ghost":     { "classes": ["btn--ghost"],     "tokens": { "--btn-bg": "{design.semantic.color.transparent}",     "--btn-fg": "{design.semantic.color.primary.default}" } }
      },
      "sizes": {
        "sm": { "tokens": { "--btn-padding-x": "{design.semantic.space.3}", "--btn-padding-y": "{design.semantic.space.1}" } },
        "md": {},
        "lg": { "tokens": { "--btn-padding-x": "{design.semantic.space.5}", "--btn-padding-y": "{design.semantic.space.3}" } }
      },
      "states": {
        "rest":     {},
        "disabled": { "tokens": { "--btn-bg": "{design.semantic.color.surface.disabled}", "--btn-fg": "{design.semantic.color.content.disabled}" } }
      }
    }
  }
}
```

Generated variant matrix: **3 variants × 3 sizes × 2 push-able states = 18 frames** in one Component Set.

> Why only 2 states? `hover` / `active` / `focus` / `loading` map to Figma **Interactions**, not Variants — see Scenario E.

### A.4 Step-by-step MCP calls captured

```text
[step 1/8] figma_get_status()
  -> { connected: true, file: "DS / Foundations v2", page: "Cover" }

[step 2/8] figma_get_variables({ collection: "DS Tokens" })
  -> { collection_id: "VariableCollectionId:1:42", modes: ["Light","Dark"],
       variables: 187 (primary.default, on-primary, surface.disabled, radius.md, space.{1..5}, typography.label.{sm,md,lg}, ...) }
  // Pre-flight PASS — all referenced semantic tokens exist.

[step 3/8] figma_execute (idempotent page setup)
  // ensure page "DS / Atoms" exists
  let page = figma.root.children.find(p => p.name === "DS / Atoms");
  if (!page) { page = figma.createPage(); page.name = "DS / Atoms"; }
  await figma.setCurrentPageAsync(page);
  // ensure Section "Atoms"
  let section = page.findOne(n => n.type === "SECTION" && n.name === "Atoms")
              ?? (() => { const s = figma.createSection(); s.name = "Atoms"; s.x = 0; s.y = 0; return s; })();

[step 4/8] figma_execute (create base Button component)
  const base = figma.createComponent();
  base.name = "Button / primary / md / rest";
  base.resize(96, 40);
  base.layoutMode = "HORIZONTAL";
  base.primaryAxisAlignItems = "CENTER";
  base.counterAxisAlignItems = "CENTER";
  base.paddingLeft = base.paddingRight = 16;   // space.4
  base.paddingTop  = base.paddingBottom = 8;   // space.2
  base.cornerRadius = 6;                       // radius.md
  // bind fills/strokes via Variables
  await figma.variables.setBoundVariableForNode(base, "fills",
    figma.variables.getVariableById("Variable:semantic/color/primary/default"));
  // label
  const label = figma.createText();
  await figma.loadFontAsync({ family: "Inter", style: "Medium" });
  label.characters = "Button";
  label.fontSize = 14;
  base.appendChild(label);

[step 5/8] figma_execute (combine into Component Set, generate 18 variants)
  const variants = [];
  for (const v of ["primary","secondary","ghost"])
    for (const s of ["sm","md","lg"])
      for (const st of ["rest","disabled"]) {
        const clone = base.clone();
        clone.name = `Button / ${v} / ${s} / ${st}`;
        applyVariantTokens(clone, v, s, st);  // rebinds fills + padding via Variables
        variants.push(clone);
      }
  const set = figma.combineAsVariants(variants, section);
  set.name = "Button";
  // declare variant properties
  set.componentPropertyDefinitions = {
    Variant: { type: "VARIANT", defaultValue: "primary", variantOptions: ["primary","secondary","ghost"] },
    Size:    { type: "VARIANT", defaultValue: "md",      variantOptions: ["sm","md","lg"] },
    State:   { type: "VARIANT", defaultValue: "rest",    variantOptions: ["rest","disabled"] }
  };

[step 6/8] figma_take_screenshot({ node: set.id })
  -> validates 6×3 grid, no overlap, all variants render.

[step 7/8] figma_set_description({ node: set.id,
    description: "Primary interactive control. Use for triggering actions, never for navigation (use link).\nSource: components.json → atom.button\nMissing-in-Figma states: hover, active, focus, loading (apply via Interactions)." })

[step 8/8] figma_execute (publish-as-library check)
  // Reports whether file is a library; skill does NOT auto-publish.
```

### A.5 Final Figma structure

```text
Page: DS / Atoms
└── Section: Atoms
    └── Component Set: Button
        ├── Button / primary   / sm / rest
        ├── Button / primary   / sm / disabled
        ├── Button / primary   / md / rest
        ├── Button / primary   / md / disabled
        ├── Button / primary   / lg / rest
        ├── Button / primary   / lg / disabled
        ├── Button / secondary / sm / rest
        ├── Button / secondary / sm / disabled
        ├── Button / secondary / md / rest
        ├── Button / secondary / md / disabled
        ├── Button / secondary / lg / rest
        ├── Button / secondary / lg / disabled
        ├── Button / ghost     / sm / rest
        ├── Button / ghost     / sm / disabled
        ├── Button / ghost     / md / rest
        ├── Button / ghost     / md / disabled
        ├── Button / ghost     / lg / rest
        └── Button / ghost     / lg / disabled
```

### A.6 Final report shown to user

```text
✅ figma-push-components — done

File:    DS / Foundations v2
Page:    DS / Atoms (created)
Section: Atoms (created)

Created:
  • 1 Component Set: Button
  • 18 variant frames (3 variants × 3 sizes × 2 states)
  • 3 component properties: Variant, Size, State

Variable bindings:
  • fills:   18/18  ✓ bound to semantic.color.*
  • strokes: 18/18  ✓
  • padding: 18/18  ✓ (numeric — Variables not yet auto-bindable to padding in plugin API; values inlined from semantic.space.*)
  • radius:  18/18  ✓

Skipped (Figma model limits):
  • State: hover / active / focus / loading
    → Add via Interactions on the primary variant (see push-flow.md §E).

Next:
  • Run /figma-push-components again for input / badge / label / help-text
  • Publish file as Library (manual — Assets panel → Publish)
```

---

## Scenario B — Re-run after `design.md` token change

**Context:** Designer changed `semantic.color.primary.default` from `#3B82F6` → `#2563EB` in `design.md`, re-ran `/design-export-dtcg`, then `/figma-push-tokens`. Now wants components to reflect the new color.

### B.1 Invocation

```
> /figma-push-components
```

### B.2 Pre-flight

```text
figma_get_variables({ collection: "DS Tokens" })
  -> Variable "semantic/color/primary/default" updated 2 min ago. Light mode = #2563EB. ✓

Loading existing component sets…
  • Found: Button (id 12:88)
  • Hash of components.json:atom.button = sha256:a3f9… (unchanged since last push)
```

### B.3 Idempotent check

```text
[diff] Compare current Figma Component Set "Button" against components.json:atom.button
  • Variants:   3 expected, 3 found  ✓
  • Sizes:      3 expected, 3 found  ✓
  • States:     2 expected, 2 found  ✓
  • Frames:    18 expected, 18 found ✓
  • Variable bindings: all 18 frames still bound to same Variable IDs ✓
  -> No structural change required.
```

### B.4 Outcome

```text
✅ No structural change — 0 components created, 0 deleted.
Variables already updated upstream:
  • All 45 frames that reference primary.default now display the new value (#2563EB).
  • Verified via figma_take_screenshot on Button / primary / md / rest.

Tip: Run /design-styleguide to refresh the team-review page with the new color.
```

---

## Scenario C — Add new `danger` variant

**Context:** PM asks for a destructive-action variant. Designer edits `components.json`:

```json
"variants": {
  "primary":   { ... },
  "secondary": { ... },
  "ghost":     { ... },
  "danger":    {
    "classes": ["btn--danger"],
    "tokens": {
      "--btn-bg":     "{design.semantic.color.danger.default}",
      "--btn-fg":     "{design.semantic.color.on-danger}",
      "--btn-border": "{design.semantic.color.danger.default}"
    }
  }
}
```

### C.1 Invocation

```
> /figma-push-components
```

### C.2 Diff phase

```text
[diff] components.json:atom.button vs Figma Component Set "Button"
  • Variants:  4 expected, 3 found  → ADD: "danger"
  • Sizes:     3 expected, 3 found  ✓
  • States:    2 expected, 2 found  ✓
  • Net new frames: 4 × 3 sizes × 2 states − existing = +6 frames
    - Button / danger / sm / rest
    - Button / danger / sm / disabled
    - Button / danger / md / rest
    - Button / danger / md / disabled
    - Button / danger / lg / rest
    - Button / danger / lg / disabled
```

### C.3 Execute

```text
[step 1/3] figma_get_variables — confirm semantic.color.danger.default + on-danger exist ✓
[step 2/3] figma_execute — clone "Button / primary / md / rest", rebind to danger.* Variables,
           name "Button / danger / md / rest", append to Component Set 12:88.
           Repeat for the 5 remaining {size × state} combos.
[step 3/3] figma_execute — update componentPropertyDefinitions.Variant.variantOptions
           from ["primary","secondary","ghost"] → ["primary","secondary","ghost","danger"]
```

### C.4 Report

```text
✅ figma-push-components — additive update

Component Set: Button (id 12:88)
Added:
  • 6 variant frames (danger × sm/md/lg × rest/disabled)
  • Updated Variant property: now 4 options [primary, secondary, ghost, danger]

Untouched: 18 existing frames (no churn — variant IDs preserved so instances downstream stay linked)

Bindings:
  • fills:   6/6 ✓ semantic.color.danger.default / on-danger
  • strokes: 6/6 ✓

Downstream check:
  • 12 instances of Button across the file — none broke, all still resolve.
```

---

## Scenario D — Failure example: missing Variables (Phase 7A skipped)

**Context:** New teammate clones the repo, immediately runs the skill without pushing tokens first.

### D.1 Invocation

```
> /figma-push-components
```

### D.2 Pre-flight check fails

```text
[step 1/2] figma_get_status — connected ✓
[step 2/2] figma_get_variables({ collection: "DS Tokens" })
  -> ❌ Collection "DS Tokens" not found in this file.

Available collections:
  (none — file has no Variables)
```

### D.3 Skill stops + recovery suggestion

```text
🛑 Pre-flight failed — cannot push components without Variables.

Why this matters:
  Components in components.json reference semantic tokens like
  {design.semantic.color.primary.default}. Without Variables in Figma,
  the skill would have to inline raw hex values, breaking the round-trip
  back to design.md and defeating the purpose of a token-driven DS.

Fix:
  1. Run /figma-push-tokens   ← creates "DS Tokens" collection
  2. Re-run /figma-push-components

Don't have tokens yet?
  • Run /design-export-dtcg to generate tokens.json from design.md
  • Then /figma-push-tokens

No components were created. File untouched.
```

---

## Scenario E — Limitation example: `hover` state

**Context:** Designer reviews the pushed Button set and asks:

> "ทำไม hover state ไม่ได้ push เข้ามาในไฟล์ Figma ครับ — มีแต่ rest กับ disabled?"

### E.1 Skill explanation

```text
Short answer: Figma models hover/active/focus as Interactions (prototype
behavior), not as Variant properties. Pushing them as variants would create
"dead" frames that never auto-display on hover — designers would have to
manually toggle them, defeating the purpose.

State → Figma model mapping:

  State      Figma model            Pushed by this skill?
  ─────────────────────────────────────────────────────────
  rest       Variant                ✓ yes
  disabled   Variant                ✓ yes  (truly a different visual)
  hover      Interaction (On Hover) ✗ no   — apply manually
  active     Interaction (On Press) ✗ no   — apply manually
  focus      Interaction (Focus)    ✗ no   — apply manually
  loading    Variant OR Interaction △ optional — ask designer; default skip

Tokens for hover/active/focus ARE still pushed to Variables (you'll see
semantic.color.primary.hover in the DS Tokens collection). They're just
not wired into Variant frames.
```

### E.2 Manual steps in Figma to add hover Interaction

```text
1. Select   →  Button / primary / md / rest
2. Right rail → Prototype tab
3. Click "+" on the node → choose Trigger: While hovering
4. Action: Change to → pick a destination variant
   Problem: no "primary / md / hover" variant exists in our model.

Workaround (recommended):
   Create a single ad-hoc "hover preview" Component Set on a scratch page
   that includes hover frames for showcase ONLY. Don't combine with the
   production Button set — instances would explode in variant count
   (3 × 3 × 6 = 54 frames, most of which are never used directly).

Or use Figma's built-in "Smart animate hover" via States:
   1. Select Component Set "Button"
   2. Right rail → "+ Add interaction" → "While hovering"
   3. Action: Change color → pick semantic.color.primary.hover Variable
   This creates a runtime hover without adding variant frames. ✓ Preferred.
```

### E.3 Why the skill defaults to "skip"

```text
• Keeps variant count manageable (18 vs 54)
• Preserves 1:1 round-trip: every Figma variant = one row in components.json
• Avoids "ghost" hover frames that designers forget to update
• Hover/active/focus tokens still live in Variables → developers wire them
  in CSS (:hover, :active, :focus-visible) from the same source of truth
```

---

## Cross-scenario summary

| Scenario | Trigger | MCP calls | Frames Δ | User action needed |
|---|---|---|---|---|
| A — first push | `components.json` new | 8 | +18 | Publish library |
| B — token re-run | `design.md` color change | 3 | 0 | None |
| C — add variant | `components.json` edited | 5 | +6 | None |
| D — missing Variables | fresh file | 2 (fails) | 0 | Run `/figma-push-tokens` first |
| E — hover limit | designer question | 0 | 0 | Manual Interactions in Figma |
