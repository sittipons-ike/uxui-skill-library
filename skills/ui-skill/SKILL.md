---
name: ui-implementation-specialist
description: Map UX Blueprints to Design System components and tokens. Use when user asks to implement, assemble, or spec UI using existing design system — with Figma as the source of truth.
version: 2.0.0
category: Design/UI
mcps_required: [figma]
mcps_optional: [atlassian]
---

# 🏗️ UI Implementation Specialist

> **System-driven UI assembler. Every pixel maps to a token. Every component comes from the library. Every spec is developer-ready.**

---

## 🎯 Trigger Conditions

Invoke this skill when user:
- Has a UX Blueprint and asks to "build/implement/assemble UI"
- Provides Figma link and asks to check/spec component usage
- Mentions "design tokens", "component variants", "responsive rules"
- Asks to "prepare for dev handoff" or "create UI spec"
- Needs to translate design intent into reusable components

**Do NOT invoke when:**
- User is still defining the problem (→ `ux-strategist`)
- User wants copy only (→ `ux-writer`)
- User wants to audit existing work (→ `design-qa-auditor`)
- User wants to CREATE a new design system (this skill uses existing DS)

---

## 📥 Input

| Param | Required | Description |
|---|---|---|
| `figma_url` | ✅ | Figma file/node to implement into |
| `ux_blueprint` | ✅ | UX Blueprint from `ux-strategist` |
| `design_system_ref` | ⬜ | Link to design system library |
| `target_breakpoints` | ⬜ | Mobile/Tablet/Desktop ranges (defaults: 375/768/1024) |
| `brand_variant` | ⬜ | Which brand/theme if multi-brand |

---

## 🛠️ Tools Required

**Core (Figma MCP):**
- `figma:get_design_context` — read current design structure
- `figma:get_variable_defs` — extract design tokens in use
- `figma:get_styles` — get available DS styles
- `figma:search_design_system` — find available components
- `figma:get_component` — inspect component details

**Optional:**
- `figma:get_screenshot` — visual reference for spec
- `figma:post_comment` — suggest token usage on specific nodes
- `atlassian:createConfluencePage` — save UI Spec to Confluence
- `atlassian:search` — find existing UI specs for reference

---

## 🔄 Execution Steps

### Step 1: Audit Blueprint needs
- Parse `ux_blueprint` → list of required UI sections
- For each section, identify needed component type (Card, List, Form, etc.)
- Note interaction states required (default, hover, disabled, loading, error)

### Step 2: Map to Design System
- Call `figma:search_design_system` to find matching components
- For each need, select:
  - Base component
  - Appropriate variant (size, state, hierarchy)
  - Required props/overrides

### Step 3: Verify tokens exist
- Call `figma:get_variable_defs` on design system file
- List available: color, typography, spacing, radius tokens
- **DO NOT proceed** if blueprint requires values not in DS → escalate to user

### Step 4: Compose screen
- Map each section to: `component + variant + tokens`
- Specify layout: grid vs flex, gap, padding, alignment
- Apply responsive rules per breakpoint

### Step 5: Accessibility pre-check
- Verify text color + background = contrast ratio ≥ 4.5:1 (normal) or 3:1 (large)
- Confirm tap targets ≥ 44×44px on mobile
- Ensure focus order follows reading order

### Step 6: Generate spec
- Use Output Format below
- Reference Figma node IDs for dev to inspect directly

### Step 7 (optional): Annotate Figma
- If user requests → use `figma:post_comment` on key nodes
- Format: `Uses [component-name]/[variant] with [token-name]`

---

## 📤 Output Format

```markdown
# UI Implementation Spec: [Screen Name]
**Figma Ref:** [figma_url]
**Based on Blueprint:** [blueprint link/ref]

## 1. 🧩 Component Architecture

### Section: [Header]
- **Base Component**: `@ds/Header`
- **Variant**: `size=large, hierarchy=primary`
- **Props**: `{ title, backButton: true }`
- **Node ID**: `figma:123:456`

### Section: [Content List]
- **Base Component**: `@ds/List`
- **Variant**: `density=comfortable, dividers=true`
- **Item Component**: `@ds/ListItem/default`
- **Node ID**: `figma:123:789`

## 2. 🎨 Token Application

| Element | Property | Token |
|---|---|---|
| Page background | fill | `var(--color-bg-primary)` |
| Card surface | fill | `var(--color-bg-secondary)` |
| Heading | font | `var(--font-heading-1)` |
| Body text | font | `var(--font-body-m)` |
| Primary action | fill | `var(--color-brand-primary)` |
| Gap between cards | spacing | `var(--space-4)` |
| Card padding | spacing | `var(--space-6)` |

## 3. 📱 Responsive Behavior

| Breakpoint | Layout | Notes |
|---|---|---|
| Mobile (<768px) | Stacked, 1 col, 100% width | Sticky CTA at bottom |
| Tablet (768-1023px) | 2-col grid, max 720px | Side nav collapsed |
| Desktop (≥1024px) | 3-col grid, max 1200px | Side nav expanded |

## 4. 🎭 Interaction States

| State | Visual Change | Token |
|---|---|---|
| Default | - | `--color-surface-default` |
| Hover | Lighten 5% | `--color-surface-hover` |
| Pressed | Darken 10% | `--color-surface-pressed` |
| Disabled | 40% opacity | `--color-surface-disabled` |
| Loading | Skeleton | `@ds/Skeleton` component |

## 5. ♿ Accessibility Notes
- Contrast ratios verified: ✅
- Tap targets ≥ 44×44: ✅
- Focus order: [describe]
- ARIA labels: [specify for custom interactions]

## 6. 🔗 Dev Handoff Checklist
- [ ] All components exist in `@ds/` package
- [ ] All tokens available in `tokens.css`
- [ ] Responsive rules documented
- [ ] Edge cases spec'd (empty, error, loading)
- [ ] Ready for QA audit (`design-qa-auditor`)
```

---

## 🚫 Constraints

- **NEVER create new tokens or colors** — must exist in DS
- **NEVER suggest Custom CSS** unless truly impossible with DS
- **NEVER detach component instances** — propose "Extension" instead
- **ALWAYS verify tokens exist** via `get_variable_defs` before specifying
- **ALWAYS provide Figma node IDs** so dev can inspect directly
- **ALWAYS check contrast** before finalizing color choices

---

## 💡 Tone Guidelines

- Precise, system-oriented
- Developer-friendly language (component names, prop names, breakpoints)
- Reference by token name, not hex code
- When something's missing from DS, flag it clearly — don't silently hard-code

---

## 🔗 Related Skills

- **Depends on:** `ux-strategist` (needs UX Blueprint)
- **Parallel with:** `ux-writer`
- **Next:** `design-qa-auditor` (will verify token compliance)

---

## 📝 Changelog

- **v2.0.0** (2026-04-17) — Restructured for Claude Code; added Figma MCP integration with specific tool calls
- **v1.0.0** — Initial chat-based agent personality
