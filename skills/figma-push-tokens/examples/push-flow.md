# Example: push-flow.md

A concrete walkthrough of `figma-push-tokens` v1.0.0 — from `tokens.json` to a working Figma Variable Collection with light + dark modes.

---

## Setup

- DS root: `/Users/dee/Projects/my-app/ds/`
- Source file: `tokens.json` (produced by `/design-export-dtcg`)
- Figma file open: "My App — UI Library"
- `figma-console` MCP: Connected
- Collection name (user choice): `DS Tokens`

---

## Sample input — `tokens.json` (excerpt)

```json
{
  "$schema": "https://design-tokens.github.io/community-group/format/",
  "color": {
    "primary": {
      "default": {
        "$value": "#2563eb",
        "$type": "color",
        "$description": "Primary action (blue.600)"
      },
      "dark": {
        "$value": "#1d4ed8",
        "$type": "color"
      }
    },
    "text": {
      "primary": {
        "$value": "#0f172a",
        "$type": "color"
      },
      "link": {
        "$value": "{color.primary.default}",
        "$type": "color",
        "$description": "Alias → primary.default"
      }
    }
  },
  "radius": {
    "sm": { "$value": "4px", "$type": "dimension" },
    "md": { "$value": "8px", "$type": "dimension" },
    "lg": { "$value": "12px", "$type": "dimension" }
  },
  "space": {
    "1": { "$value": "4px",  "$type": "dimension" },
    "2": { "$value": "8px",  "$type": "dimension" },
    "3": { "$value": "12px", "$type": "dimension" },
    "4": { "$value": "16px", "$type": "dimension" }
  }
}
```

And a sibling `tokens.dark.json` (or a `dark` mode export from Style Dictionary):

```json
{
  "color": {
    "primary": {
      "default": { "$value": "#3b82f6", "$type": "color" }
    },
    "text": {
      "primary": { "$value": "#f8fafc", "$type": "color" }
    }
  }
}
```

---

## Step-by-step run

### Step 1 — Pre-flight (AskUserQuestion)

```
Q: ไฟล์ Figma ใดที่จะ push?
A: ใช้ไฟล์ที่เปิดอยู่ — "My App — UI Library"

Q: Collection name?
A: DS Tokens

Q: รวม dark mode? (detected: yes)
A: ใช่ รวมด้วย
```

### Step 2 — Read source

Internal token map (abbreviated):

```
color.primary.default  COLOR  light=#2563eb  dark=#3b82f6
color.primary.dark     COLOR  light=#1d4ed8  dark=#1d4ed8
color.text.primary     COLOR  light=#0f172a  dark=#f8fafc
color.text.link        ALIAS  → color.primary.default
radius.sm              FLOAT  4
radius.md              FLOAT  8
radius.lg              FLOAT  12
space.1                FLOAT  4
space.2                FLOAT  8
space.3                FLOAT  12
space.4                FLOAT  16
```

### Step 3 — Check / create collection

```
mcp__figma-console__figma_get_variables
  → no collection named "DS Tokens" found

mcp__figma-console__figma_create_variable_collection
  name: "DS Tokens"
  → collectionId: "VariableCollectionId:42:1"
  → light mode id: "42:0"

mcp__figma-console__figma_add_mode
  collectionId: "VariableCollectionId:42:1"
  name: "dark"
  → dark mode id: "42:1"
```

### Step 4 — Push primitives (batch)

```
mcp__figma-console__figma_batch_create_variables
  collection: VariableCollectionId:42:1
  variables: [
    { name: "Color/Primary/Default", type: COLOR,
      valuesByMode: { "42:0": #2563eb, "42:1": #3b82f6 } },
    { name: "Color/Primary/Dark",    type: COLOR,
      valuesByMode: { "42:0": #1d4ed8, "42:1": #1d4ed8 } },
    { name: "Color/Text/Primary",    type: COLOR,
      valuesByMode: { "42:0": #0f172a, "42:1": #f8fafc } },
    { name: "Radius/Sm", type: FLOAT, valuesByMode: { "42:0": 4 } },
    { name: "Radius/Md", type: FLOAT, valuesByMode: { "42:0": 8 } },
    { name: "Radius/Lg", type: FLOAT, valuesByMode: { "42:0": 12 } },
    { name: "Space/1",   type: FLOAT, valuesByMode: { "42:0": 4 } },
    { name: "Space/2",   type: FLOAT, valuesByMode: { "42:0": 8 } },
    { name: "Space/3",   type: FLOAT, valuesByMode: { "42:0": 12 } },
    { name: "Space/4",   type: FLOAT, valuesByMode: { "42:0": 16 } }
  ]
  → created: 10
```

### Step 5 — Push aliases

```
Lookup id for "Color/Primary/Default" → "VariableID:42:101"

mcp__figma-console__figma_create_variable
  name: "Color/Text/Link"
  type: COLOR
  valuesByMode: {
    "42:0": { type: VARIABLE_ALIAS, id: VariableID:42:101 },
    "42:1": { type: VARIABLE_ALIAS, id: VariableID:42:101 }
  }
  → created
```

### Step 6 — Comp tier (skipped — no `components.json` in this example)

### Step 7 — Report

```
Created: 11
Updated: 0
Skipped (unchanged): 0
Errors:  0
Broken aliases: 0

Next step:
  ใน Figma → เลือก fill ของ component → คลิก variable icon → DS Tokens
```

---

## Re-run scenario (idempotency check)

User edits `tokens.json` — changes `radius.md` from `8px` → `10px`. Re-runs the skill.

```
Step 3:
  figma_get_variables → collection "DS Tokens" exists (id 42:1)

Step 4 (diff mode):
  Radius/Md → existing value 8, new value 10 → UPDATE
  All other variables match → SKIP

Step 7 report:
  Created: 0
  Updated: 1   (Radius/Md: 8 → 10)
  Skipped: 10
  Errors:  0
```

Any Figma component already bound to `Radius/Md` updates automatically.

---

## Add-dark-mode-later scenario

Initial push had light only. User adds a dark block to `design.md`, re-exports, re-runs:

```
Step 3:
  Collection "DS Tokens" exists, only light mode present
  figma_add_mode "dark" → mode id "42:1"

Step 4 (update):
  For each variable that gained a dark value → set valuesByMode["42:1"]
  Variables that did not change → SKIP

Report:
  Added dark mode; 47 variables now have dark values
  Updated: 47, Skipped: 40
```

---

## Failure example — gradient token

`tokens.json` contains:

```json
"surface": {
  "hero": {
    "$value": "linear-gradient(180deg, #2563eb, #1d4ed8)",
    "$type": "color"
  }
}
```

Skill output:

```
Skipped Color/Surface/Hero — type not supported in v1.0 (gradient).
  Hint: split into two color variables or use Figma styles instead.
```

Run continues; other tokens push normally.
