# Rename Flow — Walkthrough

## Scenario A: First-pass on Project A (existing Figma file)

### Pre-flight
User: `/design-figma-rename-tokens`

Skill asks:
- Q1: "Figma file ใดที่จะ rename?" → User: "current"
- Q2: "Target collection?" → User: "All collections (3 detected)"
- Q3: "Strategy?" → User: "auto-suggest"
- Q4: "Approval mode?" → User: "batch by confidence"

### Read phase
Skill output:
```
📋 Reading Figma file...
✓ Connected: My Project A (file id: abc123)
✓ Collections found: Brand Tokens, Spacing Vars, Component Styles
✓ Total variables: 32

📂 Brand Tokens (12 vars)
📂 Spacing Vars (8 vars)
📂 Component Styles (12 vars)

📖 Reading canonical from /repo paths/...
✓ Loaded canonical map: 47 expected paths
```

### Mapping phase
```
🎯 Mapping suggestions:

HIGH confidence (18) — value + name match:
| # | Current | Suggested |
|---|---|---|
| 1 | Primary Color (#2563eb) | Color/Primary/Default |
| 2 | Primary Dark (#1d4ed8) | Color/Primary/Dark |
| 3 | Body Text Color (#0f172a) | Color/Text/Primary |
| 4 | Light Text (#f8fafc) | Color/Text/On-bgcolor |
| 5 | Border Default (#e2e8f0) | Color/Border/Default |
| 6 | Card Surface (#ffffff) | Color/Surface/Base |
| 7 | space-4 (4px) | Space/Xs |
| 8 | space-8 (8px) | Space/Sm |
| 9 | space-16 (16px) | Space/Md |
| 10 | space-24 (24px) | Space/Lg |
| 11 | Radius Small (4px) | Radius/Sm |
| 12 | Radius Medium (8px) | Radius/Md |
| ... | ... | ... |

MEDIUM confidence (8) — name match, value differs from default:
| Current | Suggested | Reason |
|---|---|---|
| accent-yellow (#facc15) | Color/Accent/Default | name match, custom value |
| shadow-elevated | Shadow/Lg | semantic guess |
| heading-font | Font/Sans | guess |
| body-size (16) | Size/Md | matches default |

LOW confidence (6) — manual review needed:
| Current | Why |
|---|---|
| brand-pink-vibrant | no canonical match (custom) |
| legacy-spacing-3 | ambiguous — 12px between Sm(8) and Md(16) |
| typography-token-2 | unclear naming |
```

### Approval phase
Skill asks (multiSelect):
- ✅ Auto-rename 18 HIGH confidence
- ✅ Review 8 MEDIUM individually
- ❌ Skip 6 LOW (leave unchanged + flag)

User accepts.

### Apply phase
```
🔄 Renaming...
✓ [1/26] Primary Color → Color/Primary/Default
✓ [2/26] Primary Dark → Color/Primary/Dark
✓ [3/26] Body Text Color → Color/Text/Primary
...
✓ [18/26] HIGH batch complete (18/18 success)

📝 MEDIUM review (8 vars):
  Q: accent-yellow (#facc15) → Color/Accent/Default — approve?
     User: yes
  Q: shadow-elevated → Shadow/Lg — approve?
     User: yes
  ...
✓ [26/26] MEDIUM batch complete (7/8 approved, 1 skipped by user)

⏭️ LOW: 6 skipped (flagged in report)
```

### Final report
```
✅ Rename Complete (file: Project A)

📊 Summary:
   Total scanned: 32 variables
   Renamed: 25 (18 HIGH + 7 MEDIUM approved)
   Skipped: 7 (1 user-rejected + 6 LOW manual review)
   Errors: 0

⚠️ Manual review items (6):
   - "brand-pink-vibrant" (#ec4899)
     → No canonical match. Options:
        a) Extend DS: add Color/Brand/Pink (update NAMING.md)
        b) Keep as project-specific custom variable
   
   - "legacy-spacing-3" (12px)
     → No t-shirt slot for 12px in canonical Space scale (jumps Sm=8 → Md=16)
        a) Use Space/Sm (snap down, slightly tighter)
        b) Use Space/Md (snap up, slightly looser)
        c) Extend DS with Space/Sm-md (compound naming)
   ...

📋 Duplicate values detected (recommend merge in Figma):
   - Now: Color/Primary/Default (was "Primary Color") + Color/Primary/Default (was "brand-blue-600")
     → 2 variables share same canonical name — Figma will allow but recommend merge
     → To merge: in Figma, select both → right-click → "Merge variables"

🎯 Next steps:
   1. Verify components ใน Figma ยัง render ถูก (bindings preserved)
   2. Manually merge duplicates if desired
   3. Run /design-md-audit เทียบ DS spec
   4. หาก align ครบ → ทำ Phase B (Subscribe Team Library)
```

## Scenario B: Re-run after DS canonical updated

### Setup
- design-builder added new semantic tokens: Color/Accent/Soft, Space/Sm-md (compound)
- Run /design-figma-rename-tokens again on Project A

### Result
```
✅ Already canonical: 25/32 vars (no rename needed)
🎯 New canonical detected — opportunities:
   - "brand-pink-vibrant" (kept as custom last run)
     → Now matches new Color/Accent/Soft canonical → suggested rename
   
   - "legacy-spacing-3" (12px, kept as custom last run)
     → Now matches new Space/Sm-md canonical → suggested rename

Approve? (2 new renames)
```

## Scenario C: Conflict — target name already exists

### Setup
- Existing vars: "Primary Color" (#2563eb) AND "Color/Primary/Default" (#1d4ed8 — wrong value!)
- Two vars map to same canonical name but different values

### Result
```
⚠️ Conflict detected:
   - "Primary Color" (#2563eb) wants to be renamed to "Color/Primary/Default"
   - But "Color/Primary/Default" already exists with value #1d4ed8
   
   Decisions:
   a) Skip rename (keep both, manually decide later)
   b) Rename "Color/Primary/Default" to "Color/Primary/Dark" first, then rename "Primary Color" → "Color/Primary/Default"
   c) Manual cleanup in Figma

User picks (b):
   ✓ Renamed "Color/Primary/Default" → "Color/Primary/Dark"
   ✓ Renamed "Primary Color" → "Color/Primary/Default"
```

## Scenario D: Multi-collection same name

### Setup
- Collection "Brand Tokens": "primary" (#2563eb)
- Collection "Components": "primary" (#dc2626 — red!)

### Result
```
ℹ️ Same name across collections detected:
   - Brand Tokens / "primary" (#2563eb)
   - Components / "primary" (#dc2626)
   
   Suggested rename:
   - Brand Tokens / "primary" → "Color/Primary/Default" (value matches blue canonical)
   - Components / "primary" → "Color/Status/Error/Default" (value matches red canonical)
   
   Approve both? User: yes
```

## Failure mode: Figma not connected

### Output
```
❌ Pre-flight failed: figma-console not Connected

ที่ต้องทำ:
1. เปิด Figma desktop app
2. เปิด file ที่จะ rename
3. ใน Claude Code: /mcp
4. ดูว่า figma-console ขึ้นสถานะ Connected ไหม
5. ลอง /design-figma-rename-tokens ใหม่
```
