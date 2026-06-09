---
name: design-remix
description: Combine multiple DESIGN.md references into a new design system. Pick traits from existing brands in design-library/ (e.g. "Linear's typography + Notion's spacing + Stripe's color"), synthesize, and emit a coherent DESIGN.md. Triggers on "mix design", "combine brands", "remix design system", "blend styles", "ผสม design", "รวม design จาก".
version: 1.0.0
user-invokable: true
---

# 🎛️ Design Remix

Take 2-4 existing DESIGN.md references and synthesize a new one. Useful when "we want Linear's clarity + Notion's warmth + Stripe's component depth."

## When to use
- Have a `design-library/` with multiple installed brand styles
- Want a hybrid that doesn't exist as a single reference
- Need to inherit specific traits (e.g., "Apple's spacing, Spotify's colors")

## When NOT to use
- Starting blank → use `design-builder`
- Just need to copy one brand → `cp design-library/<brand>/DESIGN.md ./DESIGN.md`
- Want to QA existing DS → use `design-md-audit`

## Execution Steps

### 1. Discover references
- Scan `./design-library/*/DESIGN.md`
- If none → tell user to run `npx getdesign@latest add <brand>` first
- List available brands to user

### 2. Gather remix intent (ask user)
- **Which brands to remix** (2-4 max — more = muddy result)
- **Per-trait assignment** — explicit mapping. Example:
  - Colors from: Spotify
  - Typography from: Claude
  - Spacing / Layout from: Apple
  - Components style from: Linear
  - Tone / Do-Don't from: Airbnb
- **Target product context** — what is the new DS for?
- **Conflicts policy** — when sources disagree (e.g., both have shadow scales), which wins?

### 3. Synthesize
For each section in the backbone:
- Read the chosen source's section
- Adapt token names to a unified convention (don't keep brand-specific names like `apple-blue` — rename to `primary`)
- Resolve conflicts using the policy from step 2
- Note the source inline as a comment: `<!-- spacing scale: Apple -->`

### 4. Output `DESIGN.md` with this structure
Same backbone as design-builder:
```
[YAML frontmatter tokens]
## Overview        ← write fresh for the new product
## Colors          ← from source X
## Typography      ← from source Y
## Layout          ← from source Z
## Elevation
## Shapes
## Components
## Do's and Don'ts ← merge, dedupe
## Responsive Behavior
## Iteration Guide
## Known Gaps      ← flag any section pulled from a weak source
## Agent Prompt Guide
## Remix Provenance ← NEW — table showing source per section
```

The **Remix Provenance** section is a table:
```
| Section       | Source brand | Adaptation notes |
| Colors        | Spotify      | Renamed spotify-green → primary |
| Typography    | Claude       | Kept Tiempos pairing |
...
```

### 5. Validate output
- [ ] No brand-specific names leak (`apple-*`, `spotify-*`, etc.)
- [ ] Token references resolve (no orphan refs)
- [ ] Remix Provenance table covers every major section
- [ ] Components don't mix conflicting paradigms (e.g., neumorphic shadow + flat color)
- [ ] Pass `design-md-audit` with no Critical issues

### 6. Save location
- Default: `./DESIGN.md`
- If exists: save to `./design-library/_remix-<name>/DESIGN.md`

## Output Format Rules
- Same as design-builder
- ADD inline source comments at top of each section: `<!-- source: <brand> -->`
- Remix Provenance table is mandatory

## Constraints
- Max 4 source brands (more = incoherent)
- Do NOT blend opposing aesthetics without warning user (e.g., maximalist + minimalist)
- Do NOT keep brand-specific token names
- If user picks only 1 brand → suggest `cp` command instead
- If references are missing required sections, flag in Known Gaps

## Quality Bar
Reader should NOT be able to tell it's a remix unless they read Remix Provenance.
The result must feel like a single coherent system, not a patchwork.
