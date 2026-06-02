---
name: design-push-figma-tokens
description: Sync DS tokens (design.md or tokens.json DTCG) to Figma Variables via figma-console MCP. Creates Variable Collection with light/dark modes; aliases (comp tier) become Figma variable refs. Idempotent. Triggers on "push to figma", "sync figma variables", "figma tokens", "push tokens", "อัพ figma", "sync token ขึ้น figma".
version: 1.0.0
user-invokable: true
---

# design-push-figma-tokens

Sync a stable Design System token set (semantic colors, radius, spacing, typography, shadow) from `design.md` or DTCG `tokens.json` into a Figma **Variable Collection** — with light/dark modes and alias preservation. Idempotent: re-runs update only changed variables.

---

## When to use

- DS tokens are stable and ready for designer use in Figma
- You just ran `design-builder` or `design-export-dtcg` and want designers to bind variables
- You need to keep Figma Variables in sync with the DS source of truth

## When NOT to use

- Figma MCP not connected (check via `/mcp`)
- DS still in iteration — tokens will churn, causing noisy Figma diffs
- You want to push components/frames — use `design-push-figma-components` (Phase 8)
- You want to push icons — icons live in `design.md` and are exported separately

---

## Prerequisites (Pre-flight)

Before running, verify ALL of the following:

1. Target Figma file is open and on the desired page
2. `figma-console` MCP shows **Connected** (check via `/mcp`)
3. `design.md` OR `tokens.json` exists at the DS root
4. The acting user has Edit access to the target Figma file
5. (Optional) `components.json` exists if you want to push the comp tier too

If any check fails — stop and report to the user. Do not proceed.

---

## Inputs

| Input | Source | Notes |
|---|---|---|
| Token source | `tokens.json` (DTCG) preferred → fallback to `design.md` semantic block | DTCG is easier to parse and disambiguate |
| Collection name | User-supplied or default `"DS Tokens"` | Idempotent by name |
| Modes | Auto-detected: `light` always, `dark` if dark block exists | Mode IDs come from Figma after creation |
| Scopes | By category — color, radius, space, font, shadow | Applied per-variable |

---

## Outputs

- One Figma **Variable Collection** (default `"DS Tokens"`) containing 1–2 modes
- Variables grouped by category using slash naming (`Color/Primary/Default`, `Radius/Md`, …)
- Aliases stored as **Figma variable references** (not duplicated values)
- A summary report to the user: counts of **created / updated / skipped / errors** and any broken alias warnings

---

## Execution Steps

### Step 1 — Pre-flight confirmation (MANDATORY)

Use `AskUserQuestion` to confirm:

1. "Figma file ใดที่จะ push? (ระบุ link หรือใช้ file ปัจจุบัน)"
2. "Collection name: `DS Tokens` หรือชื่ออื่น?"
3. "รวม dark mode ด้วยไหม? (auto-detected from source)"

Do not proceed until the user confirms.

### Step 2 — Read source

- Prefer `tokens.json` (DTCG) if present
- Fallback: parse YAML semantic block from `design.md`
- Build an internal token map keyed by dot-path:

```
{
  "color.primary.default": {
    value: "#2563eb",
    type: "color",
    description: "…",
    modes: { light: "#2563eb", dark: "#3b82f6" }
  },
  "radius.md": { value: 8, type: "dimension", … }
}
```

### Step 3 — Connect + check existing collection

- Call `mcp__figma-console__figma_get_variables` to list existing collections + variables
- If collection (matching name) exists → reuse it (idempotent update mode)
- Otherwise → `mcp__figma-console__figma_create_variable_collection`
- Ensure modes: `light` always present; add `dark` via `mcp__figma-console__figma_add_mode` if dark values exist

### Step 4 — Push primitives first (no refs)

- Iterate every token whose value is a literal (not an alias)
- Use `mcp__figma-console__figma_batch_create_variables` for > 10 tokens
- For each: name = slashed path (`color/primary/default` → `Color/Primary/Default`), `resolvedType` per mapping table below, `valuesByMode = { light, dark }`

### Step 5 — Push aliases (semantic tier)

- For each semantic token that refs a primitive (`{primitive.colors.blue.600}`):
  - Resolve the target variable id (from the result of Step 4 or pre-existing list)
  - Create the variable with `valuesByMode` set to a Figma alias reference, NOT a literal

### Step 6 — Push comp tier (optional)

- If `components.json` provides comp aliases (e.g. `--btn-bg → {design.semantic.color.primary.default}`):
  - Create comp variables pointing to semantic variables by alias

### Step 7 — Report

Print a summary:

```
Created: 41
Updated: 6
Skipped (unchanged): 40
Errors: 0
Broken aliases: 0
```

Suggest next step:
> "ใน Figma → เลือก fill ของ component → คลิก variable icon → เลือกจาก collection 'DS Tokens'"

---

## Mapping: design.md/DTCG → Figma Variable

| DTCG `$type` | Figma `resolvedType` | Notes |
|---|---|---|
| `color` | `COLOR` | Hex / rgb / rgba → Figma `RGB` or `RGBA` |
| `dimension` | `FLOAT` | Strip `px` → number; `rem` → multiply by 16 |
| `fontFamily` | `STRING` | First family of stack only |
| `fontWeight` | `STRING` | Map `semibold` → `Semi Bold`, `bold` → `Bold`, etc. |
| `number` | `FLOAT` | Direct |
| `typography` | composite | Split into 4+ variables: `…/family`, `…/size`, `…/weight`, `…/line-height` |
| `shadow` | composite | Split into `…/x`, `…/y`, `…/blur`, `…/spread` (FLOAT) + `…/color` (COLOR) |
| `cubicBezier` | `STRING` | Stored as `cubic-bezier(…)` string |

**Naming convention:** dot-path → slash-path with PascalCase segments.
`color.primary.default` → `Color/Primary/Default`

**Aliases:** ref string `"{color.primary.default}"` → Figma variable alias `{ type: 'VARIABLE_ALIAS', id: '<varId>' }`

---

## Idempotency contract

- Pre-check existing variables via `figma_get_variables`
- Match by **name** (the slashed PascalCase path within the collection)
- If exists → `figma_update_variable` (or batch update) with new values
- If missing → `figma_create_variable` (or batch create)
- **Never delete** variables — designer may have manual ones we do not own
- Report explicitly shows what changed vs unchanged

---

## Light/Dark mode handling

- If `design.md` includes a `[data-theme="dark"]` block (or `dark:` YAML branch), or `tokens.json` includes a dark mode export — detect both light and dark values per token
- Push as `valuesByMode = { lightModeId: lightValue, darkModeId: darkValue }`
- If only light values exist — push to default mode only and skip dark mode creation
- Mode IDs are returned by `figma_create_variable_collection` / `figma_add_mode` — capture and reuse

---

## Constraints

- DO NOT modify existing Figma **components** — only variables
- DO NOT delete variables (additive + update only)
- DO NOT create variables outside the target collection
- USE batch APIs when pushing > 10 tokens to avoid rate spikes
- DO NOT push tokens whose value cannot be mapped (e.g. gradients in v1.0) — log a skip with reason

---

## Validation

After push, run:

1. `mcp__figma-console__figma_get_variables` → confirm variable count matches expected (created + updated)
2. For each alias variable → verify the alias resolves (not orphan / not pointing to deleted id)
3. Report broken aliases as **warnings** (not errors) so designer can fix manually if needed

---

## Related skills

- `design-export-dtcg` → generates `tokens.json` (preferred input for this skill)
- `design-builder` → writes `design.md` (alternative input)
- `design-component-builder` → consumes `tokens.css` (web), not Figma
- `design-styleguide` → renders `styleguide.html` (web preview)
- **Future:** `design-push-figma-components` (Phase 8) — pushes HTML atoms as Figma frames bound to these variables

---

## Workflow scenarios

### A — First-time push (new collection)

1. Designer finalises `design.md`
2. Run `/design-export-dtcg` → produces `tokens.json`
3. Open the target Figma file (correct page)
4. Run `/design-push-figma-tokens`
5. Confirm pre-flight prompts
6. Skill creates collection → reports `"Created 87 variables in collection 'DS Tokens' (light + dark)"`
7. In Figma: select fill → click variable icon → bind to `DS Tokens` collection

### B — Re-sync after token change

1. `design.md` updated (e.g. primary color tweak)
2. Run `/design-export-dtcg` → `tokens.json` refreshed
3. Run `/design-push-figma-tokens`
4. Skill detects existing collection, updates only changed variables → `"Updated 3 variables, 84 unchanged"`
5. Figma components already bound to those variables update automatically

### C — Add dark mode after launch

1. Add `dark:` block to `design.md` semantic tokens
2. `/design-export-dtcg` → tokens.json now has dark values
3. `/design-push-figma-tokens` → skill detects dark mode is new, adds `dark` mode to the existing collection and fills in dark values per variable
4. Report: `"Added dark mode; 47 variables now have dark values"`

---

## Failure modes (what to surface)

| Failure | User-facing message |
|---|---|
| `figma-console` MCP not connected | "Figma MCP ไม่ได้ต่อ — ตรวจที่ `/mcp` แล้วลองใหม่" |
| No Figma file open | "ไม่พบไฟล์ Figma ที่เปิดอยู่ — เปิดไฟล์เป้าหมายก่อน" |
| Source missing | "ไม่พบ `tokens.json` หรือ `design.md` ที่ DS root" |
| Token unmappable (gradient, etc.) | "Skipped `<path>` — type not supported in v1.0 (gradient)" |
| Alias target missing | "Warning: alias `<path>` → `<target>` not found — created without binding" |
| User lacks Edit access | "ไม่มีสิทธิ์แก้ไฟล์นี้ — ต้องเป็น Editor ขึ้นไป" |
