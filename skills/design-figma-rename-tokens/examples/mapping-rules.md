# Mapping Rules — Figma Variable Rename

## Canonical Naming Pattern
- Figma slash convention: `{Category}/{Role}/{Variant}`
- Example: `Color/Primary/Default`

## Categories
1. Color/
2. Space/
3. Radius/
4. Shadow/
5. Font/
6. Size/
7. Leading/
8. Weight/
9. Tracking/
10. A11y/

## Full Mapping Reference

### Color
| Canonical | DTCG path | Web CSS var | Hex (Tailwind default) |
|---|---|---|---|
| Color/Primary/Default | {color.primary.default} | --sys-color-primary-default | #2563eb |
| Color/Primary/Dark | {color.primary.dark} | --sys-color-primary-dark | #1d4ed8 |
| Color/Primary/Darker | {color.primary.darker} | --sys-color-primary-darker | #1e40af |
| Color/Primary/Soft | {color.primary.soft} | --sys-color-primary-soft | #eff6ff |
| Color/Text/Primary | {color.text.primary} | --sys-color-text-primary | #0f172a |
| Color/Text/Secondary | {color.text.secondary} | --sys-color-text-secondary | #475569 |
| Color/Text/On-bgcolor | {color.text.on-bgcolor} | --sys-color-text-on-bgcolor | #f8fafc |
| Color/Text/Disable | {color.text.disable} | --sys-color-text-disable | #94a3b8 |
| Color/Border/Default | {color.border.default} | --sys-color-border-default | #e2e8f0 |
| Color/Border/Disable | {color.border.disable} | --sys-color-border-disable | #e2e8f0 |
| Color/Border/Focus | {color.border.focus} | --sys-color-border-focus | #2563eb |
| Color/Border/Error | {color.border.error} | --sys-color-border-error | #dc2626 |
| Color/Surface/Base | {color.surface.base} | --sys-color-surface-base | #ffffff |
| Color/Surface/Raised | {color.surface.raised} | --sys-color-surface-raised | #f8fafc |
| Color/Surface/Sunken | {color.surface.sunken} | --sys-color-surface-sunken | #f1f5f9 |
| Color/Status/Success/Default | {color.status.success.default} | ... | #16a34a |
| Color/Status/Warning/Default | ... | ... | #f59e0b |
| Color/Status/Error/Default | ... | ... | #dc2626 |
| Color/Status/Info/Default | ... | ... | #0ea5e9 |

### Space (t-shirt)
| Canonical | Value | Common aliases |
|---|---|---|
| Space/Xs | 4px | xs, extra-small, 4 |
| Space/Sm | 8px | sm, small, 8 |
| Space/Md | 16px | md, medium, 16, base, default |
| Space/Lg | 24px | lg, large, 24 |
| Space/Xl | 32px | xl, x-large, 32 |
| Space/2xl | 48px | 2xl, xx-large, 48 |

### Radius
| Canonical | Value |
|---|---|
| Radius/None | 0 |
| Radius/Sm | 4px |
| Radius/Md | 8px |
| Radius/Lg | 16px |
| Radius/Xl | 24px |
| Radius/Pill | 9999px |

### Font (typography)
... (similar table)

## Fuzzy Match Rules

### Rule 1: Name normalization
- lowercase
- replace separators (`/`, `-`, ` `) with single space
- remove duplicate whitespace

### Rule 2: Keyword extraction
- detect category keyword first (color/space/radius/font/shadow)
- detect role keyword (primary/secondary/text/border/surface)
- detect modifier (default/hover/disabled/dark/darker/soft)

### Rule 3: Confidence scoring
- HIGH: both value AND name keywords match
- MEDIUM: only one matches (value OR name)
- LOW: neither matches strongly — needs manual

### Rule 4: Common patterns
| Pattern detected | Mapped to |
|---|---|
| "primary" alone (no category) | Color/Primary/Default (if value=color) OR ask |
| "spacing X" | Space/X (translate X) |
| "X spacing" | Space/X |
| "shadow X" | Shadow/X |
| "X font" | Font/X |
| "size X" / "X size" | Size/X |
| number alone (e.g. "8") | Space/Sm or Radius/Sm based on value |

## Conflict Resolution

When 2+ existing vars map to same canonical:
- Skill renames the first (or designer-preferred)
- Other vars stay unchanged + flagged in report
- Designer manually merges in Figma after rename

When canonical doesn't exist for a custom var:
- Designer decides: extend DS (add new canonical) OR keep custom name
- Skill does NOT auto-create new canonical entries

## Examples

### Example 1: Color rename
Input: `Primary Color` (value #2563eb)
- Tier 1: Value #2563eb matches canonical Color/Primary/Default → HIGH
- Output: rename to `Color/Primary/Default`

### Example 2: Space rename (with custom value)
Input: `spacing-md` (value 16)
- Tier 1: Value 16 matches Space/Md → HIGH
- Tier 2: Name "spacing-md" matches Space/Md → HIGH
- Output: rename to `Space/Md`

### Example 3: Custom value (no match)
Input: `brand-yellow` (value #fbbf24)
- Tier 1: #fbbf24 not in canonical color list → LOW
- Tier 2: name contains "yellow" → no canonical role match → LOW
- Output: flag for manual + suggest "Color/Accent/Default OR extend DS"
