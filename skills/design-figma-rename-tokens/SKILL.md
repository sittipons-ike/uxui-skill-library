---
name: design-figma-rename-tokens
description: Normalize existing Figma Variable names to match canonical DS naming (Color/Primary/Default, Space/Md, etc.) via figma-console MCP. Non-destructive — preserves all bindings, values, modes. Hybrid auto-suggest + designer approval. Useful for aligning multi-project Figma files with team DS standard before subscribing to DS Library. Triggers on "rename figma variables", "normalize figma tokens", "align figma naming", "เปลี่ยนชื่อ variable figma", "rename token figma", "ทำชื่อ figma ให้ตรง DS".
version: 1.0.0
user-invokable: true
---

# design-figma-rename-tokens

Normalize existing Figma Variables to match the team's canonical DS naming (Color/Primary/Default, Space/Md, Radius/Md, ...). Non-destructive — preserves all bindings, values, and modes.

## When to use

- Existing Figma project has Variables with inconsistent naming (e.g. `primary-color`, `Brand/Blue 600`, `spacing-md`)
- Want to align with team DS naming standard before subscribing to Team Library
- Multiple projects need to share one naming convention
- After updating NAMING.md or design.md and want Figma to reflect new structure

## When NOT to use

- New Figma file with no Variables yet → use `/design-push-figma-tokens` instead
- Need to merge duplicate variables → must be done manually in Figma (skill flags only)
- Need to change a variable's value → use `/design-push-figma-tokens`
- Need to add new variables that don't exist in Figma yet → use `/design-push-figma-tokens`

## Prerequisites

- `figma-console` MCP Connected (verify with `figma_get_status`)
- Target Figma file open with Edit access
- Access to canonical reference files:
  - `skills/design-builder/NAMING.md`
  - `skills/design-component-builder/examples/tokens.css`
  - `skills/design-export-dtcg/examples/tokens.example.json`

## Canonical naming reference

Skill reads canonical naming from:

- `/Users/sittiponsorojsakul/AI_Agent/Claude_code_Agent/uxui-skill-library/skills/design-builder/NAMING.md`
- `/Users/sittiponsorojsakul/AI_Agent/Claude_code_Agent/uxui-skill-library/skills/design-component-builder/examples/tokens.css`
- `/Users/sittiponsorojsakul/AI_Agent/Claude_code_Agent/uxui-skill-library/skills/design-export-dtcg/examples/tokens.example.json`

### DTCG path → Figma slash-name mapping

| DTCG path | Figma name |
|---|---|
| `color.primary.default` | `Color/Primary/Default` |
| `color.primary.hover` | `Color/Primary/Hover` |
| `color.text.on-bgcolor` | `Color/Text/On-bgcolor` |
| `color.text.muted` | `Color/Text/Muted` |
| `color.surface.default` | `Color/Surface/Default` |
| `color.border.default` | `Color/Border/Default` |
| `space.xs` / `space.sm` / `space.md` / `space.lg` / `space.xl` | `Space/Xs` ... `Space/Xl` |
| `radius.sm` / `radius.md` / `radius.lg` / `radius.full` | `Radius/Sm` ... `Radius/Full` |
| `shadow.sm` / `shadow.md` / `shadow.lg` | `Shadow/Sm` ... `Shadow/Lg` |
| `font.sans` / `font.serif` / `font.mono` | `Font/Sans` / `Font/Serif` / `Font/Mono` |
| `a11y.touch-min` | `A11y/Touch-min` |

Rules:
- Slash `/` = hierarchy separator (Figma convention).
- Each segment is `PascalCase` or `Title-Case` (e.g. `On-bgcolor`).
- Numbers stay lowercase suffix-style (e.g. `Color/Brand/Blue-600`).

## Inputs

- Target Figma file (current open file by default)
- Target collection (default: scan all collections, prompt user to pick one or all)
- Mapping strategy: `auto-suggest` (default) | `manual`
- Approval mode: `batch` (group by confidence) | `individual` (each rename confirms)

## Outputs

- **In Figma**: variables renamed in place (bindings, values, modes preserved)
- **In session**: rename report — renamed N, skipped M, conflicts K, manual review W

---

## Execution Steps

### Step 1 — Pre-flight (MANDATORY)

Use `AskUserQuestion` to gather:

1. "Figma file ที่จะ rename ใช่ไฟล์ที่เปิดอยู่ตอนนี้มั้ย? (current / specify)"
2. "Target collection: scan ทุก collection หรือ pick collection เดียว?"
3. "Strategy: `auto-suggest` (recommended) หรือ `manual` (เลือกเอง one-by-one)?"
4. "Approval mode: `batch` (เร็ว — approve เป็นกลุ่ม confidence) หรือ `individual` (ปลอดภัย — confirm ทีละตัว)?"

Verify connection:

- Run `figma_get_status`. If not Connected → STOP and tell user to open Figma + run `/mcp`.

### Step 2 — Read canonical naming

Read these files into an in-memory canonical map:

- `NAMING.md` — extract atomic + alias rules
- `tokens.css` `:root` block — extract `--sys-*` variable list with values
- `tokens.example.json` — extract DTCG paths

Build `canonical_map`:

```
{
  "#2563eb": "Color/Primary/Default",
  "#1e40af": "Color/Primary/Hover",
  "16px": "Space/Md",
  "8px": "Radius/Md",
  ...
}
```

Also build `name_pattern_map` for fuzzy name lookup (lowercased keywords → canonical).

### Step 3 — Read current Figma variables

Call `figma_get_variables`. For each var collect:

- `id`
- `name` (current)
- `resolvedType` (`COLOR` / `FLOAT` / `STRING` / `BOOLEAN`)
- `valuesByMode` (use light mode value for matching)
- `collectionId` / `collectionName`

Group by collection.

### Step 4 — Build mapping suggestions

For each Figma var, compute best canonical match using tiers:

- **Tier 1 — Exact value match (HIGH)**: hex/number/string equals a canonical value
  - `#2563eb` → `Color/Primary/Default`
  - `16` (px) → `Space/Md`
- **Tier 2 — Fuzzy name match (HIGH or MEDIUM)**: normalize current name (lowercase, strip separators), compare to canonical keywords
  - `"Primary Color"` / `"primary-color"` / `"brand primary"` → `Color/Primary/Default`
  - `"spacing-md"` / `"Space MD"` / `"md spacing"` → `Space/Md`
- **Tier 3 — Category inference (MEDIUM)**: name contains category keyword
  - contains `shadow` → `Shadow/?`
  - contains `radius` / `corner` → `Radius/?`
  - contains `font` / `typeface` → `Font/?`
- **Tier 4 — Manual (LOW)**: no canonical match → ask designer

Attach confidence to each suggestion: `HIGH` / `MEDIUM` / `LOW`.

### Step 5 — Present mapping to user

Show grouped table:

```
Suggested Rename Plan (12 variables)

HIGH confidence (8) — auto-approve recommended:
| Current name         | Suggested              | Reason             |
|----------------------|------------------------|--------------------|
| Primary Color        | Color/Primary/Default  | value match #2563eb |
| Brand/Blue 600       | Color/Primary/Default  | value match #2563eb |
| spacing-md           | Space/Md               | name + value (16)  |
| Border Radius/Medium | Radius/Md              | name + value (8)   |
...

MEDIUM confidence (3) — review carefully:
| Current name | Suggested            | Reason                       |
|--------------|----------------------|------------------------------|
| Heading Font | Font/Sans            | name only, value differs     |
| shadow-card  | Shadow/Md            | category guess               |
| accent-color | Color/Accent/Default | semantic match               |

LOW confidence (1) — manual decision needed:
| Current name      | Suggested | Why                  |
|-------------------|-----------|----------------------|
| brand-secondary-2 | ???       | no canonical match   |
```

### Step 6 — Get approval

Use `AskUserQuestion` (multiSelect):

- "Auto-approve all HIGH confidence (8 renames)?"
- "Review MEDIUM confidence one-by-one?"
- "Skip LOW confidence (leave 1 var unchanged)?"

### Step 7 — Apply renames

For each approved rename:

- Call `figma_rename_variable(id, new_name)`
- On success: log `renamed: <old> → <new>`
- On error: log `FAILED: <old> — <error>`

Use `figma_batch_update_variables` if available for efficiency on large batches.

### Step 8 — Report

```
Rename Complete

Summary:
  Renamed: 8 variables (HIGH auto-applied)
  Approved + renamed: 2 (MEDIUM after review)
  Skipped: 1 (LOW left as-is)
  Conflicts: 0

Manual review needed:
  - "brand-secondary-2" — no canonical match. Options:
    a) Extend DS: create canonical Color/Brand/Secondary-2 in design.md
    b) Keep custom name (mark as project-specific)

Duplicates detected (same value, different name) — manual merge in Figma:
  - "Primary Color" + "Brand/Blue 600" both = #2563eb
    Both renamed to Color/Primary/Default (Figma allows but flags as duplicate)
    Recommend: keep one, swap bindings, delete other

Next steps:
  - Verify components binding renamed variables still render correctly
  - Consider subscribing DS Library (Phase B/C migration)
  - Run /design-md-audit to confirm DS spec alignment
```

---

## Mapping rules detail

- **Color variables**: hex value match takes priority over name match
- **Number variables (radius, space, size)**: exact value match > name pattern
- **String variables (font, weight)**: name match > value
- **Boolean variables**: name only
- **Aliased variables**: preserve alias target, just rename the alias var itself

## Conflict handling

- **"Target name already exists"**: skill flags + asks user to merge manually in Figma OR pick a different name
- **"Duplicate values across vars"**: flag for manual merge (cannot merge via API)
- **"Variable in multiple collections with same name"**: prefix with collection name (e.g. `Brand/Color/Primary/Default`)

## Idempotency

- Pre-check: if a var name already matches canonical → skip + log `already canonical`
- Re-run safe: 0 work if all aligned

## Non-destructive guarantee

`figma_rename_variable` preserves:

- Variable ID (internal — bindings stable)
- All mode values
- Component bindings (components keep rendering correctly)

No values changed. No variables created or deleted. Modes untouched.

---

## Workflow scenarios

### A — First-pass on existing project

1. Open Figma file with 32 Variables (mixed naming)
2. Run `/design-figma-rename-tokens`
3. Pre-flight Q&A — pick `auto-suggest` + `batch`
4. Skill reads vars → suggests 28 renames (20 HIGH / 6 MEDIUM / 2 LOW)
5. Designer approves HIGH bulk + reviews MEDIUM one-by-one + skips LOW
6. Skill renames 26 vars in ~30 seconds
7. Designer verifies components still render

### B — Re-run after design.md updates

1. NAMING.md extended with new semantic tokens
2. Run `/design-figma-rename-tokens`
3. Skill detects existing vars already aligned + suggests new mappings for newer DS additions
4. Apply or skip

### C — Multi-project rollout

1. Project A → rename (sprint week 1)
2. Project B → rename (sprint week 2)
3. Project C → rename (sprint week 3)
4. Run `/design-md-audit` on each → confirm alignment

---

## Related skills

- `/design-push-figma-tokens` — push canonical tokens to a fresh Figma file (Phase 7A)
- `/design-push-figma-components` — push DS components after vars are aligned
- `/design-md-audit` — audit DS structure for spec compliance
- Future: `/design-figma-migrate-project` — full migration (subscribe library + swap components)
