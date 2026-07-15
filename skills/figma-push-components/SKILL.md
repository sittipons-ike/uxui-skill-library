---
name: figma-push-components
description: Push DS atoms (button, input, badge, label, card) from components.json + HTML into Figma as Component Sets with auto-layout + Variable bindings. Every padding/radius/fill binds to Figma Variables (from figma-push-tokens). Variants per atom (primary/secondary/ghost × sm/md/lg). States rest + disabled only (hover/focus via designer Interactions). Idempotent. Triggers on "push components to figma", "sync figma components", "figma components", "push atoms", "อัพ component figma", "สร้าง component figma".
version: 1.0.0
user-invocable: true
---

# figma-push-components

Push DS atoms from `components.json` + `components/*.html` into a Figma file as **Component Sets** with auto-layout and **Variable bindings**. Every padding, radius, gap, fill, and stroke binds to a Figma Variable created in Phase 7A (`figma-push-tokens`) — so token changes propagate automatically without re-pushing components.

Scope v1.0: 5 atoms (button, input, badge, label, card), 2 states (rest + disabled).

---

## When to use

- Phase 7A done — Variables already pushed to Figma (collection `DS Tokens` exists)
- DS atoms in `components.json` are stable and ready for designer reuse
- Designer wants reusable, token-bound Components in the Figma library

## When NOT to use

- Variables not yet pushed → run `/figma-push-tokens` first
- Atoms still iterating (props/structure churning) — wait until stable
- Need pixel-perfect 1:1 match with web — do it manually in Figma
- Need all interactive states (hover, focus, active) — designer wires those via Interactions panel; this skill only encodes static Variants

---

## Prerequisites (Pre-flight)

1. `figma-console` MCP shows **Connected** (`/mcp`)
2. Phase 7A done — Variable Collection `DS Tokens` exists in target file (verified via `figma_get_variables`)
3. `components.json` + `components/*.html` present at DS root
4. Target Figma file open + Edit access
5. (Recommended) `design.md` semantic block matches `tokens.json` used for Phase 7A

If any check fails — stop and surface to user. Do not proceed.

---

## Inputs

| Input | Source | Notes |
|---|---|---|
| Atom specs | `components.json` (atom entries) | render/tokens/variants/sizes/states blocks |
| Atom markup | `components/<atom>.html` | structural reference (slot positions, child order) |
| Variable map | Figma Variable Collection `DS Tokens` | resolved via `figma_get_variables` |
| Target page | User-supplied (default `DS / Atoms`) | created if missing |
| Atom scope | User-supplied (default all 5) | can subset |
| State scope | User-supplied (default rest + disabled) | can skip disabled |

---

## Outputs (in Figma)

- 1 **Component Set** per atom (button, input, badge, label, card)
- Variants encoded as **Component Properties** (`variant`, `size`, `state`)
- All numeric props **bound** to Variables (`setBoundVariable`)
- All color fills **bound** to Variables (`setBoundVariableForPaint`)
- Page section `DS / Atoms` (auto-organized in a grid)
- Report to user with counts per atom + total bindings

---

## Execution Steps

### Step 1 — Pre-flight confirmation (MANDATORY)

Use `AskUserQuestion` to confirm:

1. "Figma file ใดที่จะ push? (link หรือ current)"
2. "Page name: `DS / Atoms` หรือชื่ออื่น?"
3. "Atoms scope: ทั้ง 5 (button, input, badge, label, card) หรือเลือก?"
4. "States: rest + disabled (v1.0) หรือ skip disabled?"

Do not proceed until the user confirms.

Verify Phase 7A:

- Call `mcp__figma-console__figma_get_variables`
- If collection `DS Tokens` missing → **STOP** + suggest `/figma-push-tokens first`

### Step 2 — Read sources

- Parse `components.json` → extract each atom's `render`, `tokens`, `variants`, `sizes`, `states`
- Read corresponding `components/<atom>.html` for structural reference (slot order, text positions)
- Build internal `AtomSpec`:

```
{
  name: "button",
  base_render: { layout: "horizontal", padding: {...}, radius: "md", ... },
  variants: { primary: {...}, secondary: {...}, ghost: {...} },
  sizes: { sm: {...}, md: {...}, lg: {...} },
  states: { rest: {...}, disabled: {...} },
  tokens_map: { "--btn-bg": "color.primary.default", ... }
}
```

### Step 3 — Build Variable id lookup

- `figma_get_variables` → list all variables in `DS Tokens`
- Build map: `{ "Color/Primary/Default": variableId, "Space/Md": variableId, ... }`
- For each token in atom's `tokens` block → resolve target Variable id
- If a token lacks a matching Variable → log warning, fall back to raw value, flag in report

### Step 4 — For each atom, push as Component Set

Use `figma_execute` with code patterned like:

```javascript
// Pseudo — generated per atom from AtomSpec
const set = figma.createComponentSet();
set.name = "Button";

for (const variant of variants) {
  for (const size of sizes) {
    for (const state of states) {  // rest + disabled only
      const comp = figma.createComponent();
      comp.name = `Variant=${variant}, Size=${size}, State=${state}`;

      // Auto-layout
      comp.layoutMode = "HORIZONTAL";
      comp.primaryAxisSizingMode = "AUTO";   // hug
      comp.counterAxisSizingMode = "AUTO";

      // Bind padding to Variables (diff-merged token map)
      comp.setBoundVariable("paddingTop",    varIdMap[tokens["--btn-py"]]);
      comp.setBoundVariable("paddingBottom", varIdMap[tokens["--btn-py"]]);
      comp.setBoundVariable("paddingLeft",   varIdMap[tokens["--btn-px"]]);
      comp.setBoundVariable("paddingRight",  varIdMap[tokens["--btn-px"]]);
      comp.setBoundVariable("itemSpacing",   varIdMap[tokens["--btn-gap"]]);

      // Bind corner radius (all 4)
      ["topLeftRadius","topRightRadius","bottomLeftRadius","bottomRightRadius"]
        .forEach(p => comp.setBoundVariable(p, varIdMap[tokens["--btn-radius"]]));

      // Bind fill (variant + state aware)
      const bgVarId = varIdMap[tokens["--btn-bg"]];
      comp.fills = [
        figma.variables.setBoundVariableForPaint(
          figma.util.solidPaint("#ffffff"), "color", figma.variables.getVariableById(bgVarId)
        )
      ];

      // Text child
      const text = figma.createText();
      text.characters = "Button";
      text.fontName = { family: "Inter", style: "Semi Bold" };
      text.setBoundVariable("fontSize", varIdMap[tokens["--btn-font-size"]]);
      text.fills = [
        figma.variables.setBoundVariableForPaint(
          figma.util.solidPaint("#000000"), "color",
          figma.variables.getVariableById(varIdMap[tokens["--btn-text"]])
        )
      ];

      comp.appendChild(text);
      set.appendChild(comp);
    }
  }
}

// Component Properties
set.addComponentProperty("variant", "VARIANT", "primary");
set.addComponentProperty("size",    "VARIANT", "md");
set.addComponentProperty("state",   "VARIANT", "rest");
```

### Step 5 — Diff-merge for variant tokens

- Apply the same diff-merge algorithm as `schemas/ref-resolver.md`
- Order: `base` → `variant` → `size` → `state` (last-write-wins)
- For each `(variant, size, state)` combination → compute final token map → resolve Variable ids → bind
- Result: minimum spec per combination, maximum reuse of base tokens

### Step 6 — Auto-organize on canvas

- Find or create page named per user input (default `DS / Atoms`)
- Find or create a `Section` named `DS / Atoms` on that page (per MCP placement rule)
- Position each Component Set in a grid: button at `(0,0)`, input at `(400,0)`, badge at `(800,0)`, label at `(0,400)`, card at `(400,400)`
- All sets placed **inside** the Section

### Step 7 — Validation

- `figma_take_screenshot` of the Section
- Count check: number of Component Sets matches scope
- Binding check: iterate components → verify no orphan bindings
- Report: created N sets, M variants total, K bindings, W warnings

### Step 8 — Report to user

```
Pushed 5 component sets to Figma:
  - Button — 18 variants (3 variant × 3 size × 2 state)
  - Input  — 12 variants
  - Badge  — 10 variants
  - Label  — 2 variants
  - Card   — 3 variants

Total: 45 components, ~234 variable bindings, 0 warnings
Screenshot: <url>

Next steps:
- Figma → Assets panel → drag Button into any frame
- Hover/focus → select component → Interactions panel → On Hover → Change to (different variant)
- Edit design.md → re-run /figma-push-tokens — variables update; components inherit automatically
```

---

## Variant + Size + State matrix (v1.0 default scope)

| Atom | Variants | Sizes | States | Total |
|---|---|---|---|---|
| Button | primary, secondary, ghost | sm, md, lg | rest, disabled | 18 |
| Input  | default, error | sm, md, lg | rest, disabled | 12 |
| Badge  | success, warning, error, info, neutral | sm, md | — | 10 |
| Label  | required, optional | — | — | 2 |
| Card   | default, elevated, outlined | — | — | 3 |

Grand total: **45 Figma components** across 5 Component Sets.

---

## Variable binding mapping (`components.json` token → Figma Variable)

| Comp token | Figma Variable | Bound to |
|---|---|---|
| `--btn-bg` | `Color/Primary/Default` | `fills[0].color` |
| `--btn-text` | `Color/Text/On-bgcolor` | text node `fills[0].color` |
| `--btn-radius` | `Radius/Md` | all 4 corner radii |
| `--btn-px` | `Space/Md` | `paddingLeft` + `paddingRight` |
| `--btn-py` | `Space/Sm` | `paddingTop` + `paddingBottom` |
| `--btn-gap` | `Space/Sm` | `itemSpacing` |
| `--input-border` | `Color/Border/Default` | `strokes[0].color` |
| `--input-border-error` | `Color/Border/Error` | `strokes[0].color` (error variant) |
| `--input-bg` | `Color/Surface/Default` | `fills[0].color` |
| `--badge-radius` | `Radius/Full` | corner radius |
| `--card-shadow` | `Shadow/Sm/*` (composite) | effect (split per Phase 7A mapping) |

---

## Idempotency

- Pre-check: for each atom, search target page for Component Set with the same name (e.g. `Button`)
- If exists → update its variants + bindings in place (no duplicate Component Set)
- If new → create from scratch
- Match by **name** only (not node id) → safe across sessions
- New variants added to an existing set are appended; existing variants get bindings refreshed
- **Never delete** variants designer added manually outside this skill's scope

---

## State limitations (v1.0)

- **rest + disabled only** — these are static, encode cleanly as Variant frames
- **hover, active, focus** — NOT created as Variants
  - Figma model: these belong in the Interactions panel, not as static variant copies
  - Designer wires manually: select component → Interactions panel → On Hover → Change to `Variant=primary, State=...`
- v1.0 covers the static portion; designer wires the interaction in 1–2 clicks per atom

---

## Failure modes

| Failure | User-facing message |
|---|---|
| `DS Tokens` collection not found | "ไม่พบ Variable Collection `DS Tokens` — รัน `/figma-push-tokens` ก่อน" |
| Variable `X` missing for a token | "Warning: token `<--btn-bg>` → `Color/Primary/Default` not found — used raw value as fallback" |
| Component Set already exists | "Updated existing `Button` set — added/refreshed N variants" |
| Image fill needed (atom has bg image) | "Skipped image fill on `<atom>` — auto-layout binding not applied to image atoms" |
| `figma-console` MCP not connected | "Figma MCP ไม่ได้ต่อ — ตรวจที่ `/mcp` แล้วลองใหม่" |
| User lacks Edit access | "ไม่มีสิทธิ์แก้ไฟล์นี้ — ต้องเป็น Editor ขึ้นไป" |

---

## Limitations + designer manual work

After this skill runs, designer still does:

- **Interactions** for hover / focus / active (Interactions panel)
- **Font weights** outside Inter — bind manually if DS uses a custom font
- **Shadow opacity nuances** — Figma effects render slightly differently from CSS `box-shadow`
- **Icons** — push icons as separate Figma components (use Figma's icon library or instances)
- **Constraints / responsive resize** — Figma auto-layout handles most cases; designer tunes edge cases

---

## Workflow scenarios

### A — First-time push

1. Phase 7A done — Variables in Figma
2. Open the target Figma file (correct page)
3. Run `/figma-push-components`
4. Confirm pre-flight + scope
5. Skill reports: `"Pushed 5 atoms, 45 components, 234 bindings"`
6. In Figma → `DS / Atoms` section → drag Button into any frame
7. Properties panel → pick `variant=primary, size=md, state=rest`

### B — Token change propagation (no re-push needed)

1. Designer tweaks `design.md` (e.g. primary color)
2. `/design-export-dtcg` → tokens.json refreshed
3. `/figma-push-tokens` → Variables update
4. **Skip re-push of components** — components already bound to Variables → new color appears automatically
5. Re-run `/figma-push-components` only when atom structure changes (new variant, new slot)

### C — Add a new variant

1. Edit `components.json` → add variant `danger` to `button.variants`
2. Run `/figma-push-components`
3. Skill detects existing `Button` Component Set + new variant → appends variant frames to existing set
4. Report: `"Updated Button: +3 variants (danger × 3 sizes)"`

---

## Related skills

- `figma-push-tokens` — Phase 7A prerequisite (Variables)
- `design-component-builder` — writes `components.json` + `components/*.html` (input source)
- `design-export-dtcg` — keeps `tokens.json` in sync with `design.md`
- `design-md-audit` — verify components.json refs resolve before pushing
- **Future:** `figma-push-patterns` (Phase 8B) — push patterns (auth-split, app-shell) built from these atoms

---

## Constraints

- DO NOT modify existing Figma Variables — that is Phase 7A's responsibility
- DO NOT delete Component Sets — additive + update only
- DO NOT create components outside the target Section
- DO NOT push pixel-perfect bitmap copies — bind everything via Variables instead
- USE `figma_execute` batched per atom (one transaction per Component Set) to avoid partial state on error
