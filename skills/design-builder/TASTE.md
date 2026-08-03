# TASTE.md — Anti-slop / design-taste (agent-facing)

> Adapted from **Hallmark** (Nutlope / Together AI, MIT) + the **Taste Skill** (Leon Si, MIT).
> **Colour, typography, theme, and spacing values are owned by `design.md`** — not here. This file is about *how things are composed*, not what colour they are.
>
> **Scope note (v2):** the earlier prose rule-sets (§1–§5 anti-slop do/don'ts) were removed — an A/B experiment showed the model already satisfies ~95% of them unprompted, so they mostly added token cost. What remains is the part that measurably helped: the **governed-deviation philosophy (§0)**, the **Taste Gate with objective mechanical checks (§6)**, the **recipe menu (§7)**, and the **dials (§8)**. (History is in git if the rules are ever needed back.)
>
> **Consumed as a self-critique gate by:** `design-component-builder` and `design-ui-builder` — both run §6 (gate + mechanical checks), pick from §7 (recipes), and honour §8 (dials).

---

## §0 Philosophy — warn, don't block (governed deviation)

These are **default-good rules, not hard laws.** Breaking one to make the design genuinely better is *allowed* — the rule is that a deviation must be **surfaced, never silent.**

Two kinds of deviation to report in the Taste Gate (§6):

1. **Taste deviation** — broke a rule below on purpose. State *why* it improves the design.
2. **DS gap** — the design needed a component or token that `design.md` / `components.json` doesn't have yet. Name it + propose adding it.

**Flow:** emit the work + report → human reviews → on approval, *promote* the gap into the DS (add the component to `components.json`, add the token to `design.md`) so it becomes reusable. This mirrors the governed `variant-extensions` escape valve — deviation is fine when it's named, justified, and can graduate into the system. See [[variant-extensions]].

**Never block emission.** Ship the best design + a clear report. The point is to base on the real DS without closing off good ideas.

---

## §6 Taste Gate — self-critique before emitting output

**Run this once, right before writing the output files.** Run the mechanical checks below, confirm the picked §7 recipes fit the §8 dials, then print a short report:

```
TASTE REPORT
✅ passed:  <n> checks clean
⚠️ deviations (on purpose):
   - <rule broken> — <why this improves the design>
🧩 DS gaps (needed but not in the DS yet):
   - <component/token missing> — proposed: add to components.json / design.md as <name>
```

Rules for the gate:
- **Emit the output regardless** — this gate reports, it does not block.
- If there are **zero** deviations and gaps, print `TASTE REPORT: clean` — keep it short.
- On a **DS gap**, don't silently invent-and-forget: name the missing piece and propose promoting it into the DS. If the human approves, add it to `components.json` (governed, like `variant-extensions`: with a short reason) so it becomes reusable.
- Keep the report to what actually matters — don't pad it with every rule that passed.

**Mechanical checks (count, don't eyeball)** — these are objective; run them literally and report any breach:

| Check | Rule | How to verify |
|---|---|---|
| Eyebrow ratio | ≤ `ceil(sections ÷ 3)` uppercase-tracked eyebrows per page | count them |
| Bento cell count | a bento grid has **exactly** as many cells as content items | count cells vs items |
| CTA single line | primary CTA / nav link text fits one line at desktop | check for wrap |
| Zigzag cap | no more than **2** consecutive image+text zigzag sections | count run length |
| No split-header | no section head = headline-left + explainer-paragraph-right | scan section heads |
| Hero restraint | hero has ≤ 4 text elements; subtext ≤ 20 words AND ≤ 4 lines | count |
| Feature grid | not 3 equal feature cards as the default | check grid |

(Mechanical checks adapted from the Taste Skill — see credit.)

---

## §7 Recipes — positive composition patterns  `[design-ui-builder mainly; c* also design-component-builder]`

A menu of *good ways to compose*. These are techniques, not a fixed look; the point is to have enough options that you can match the brand, never that you use them all.

**Selection rule (run before picking any recipe):**
1. Read `docs/brand/` (mood, tone) + `docs/blueprints/` (the page's UX intent) — this is the existing **Phase 0** scan.
2. Derive the three **dials** (§8) from that context.
3. Pick recipes whose *fit tags* match the brand × UX, within the dial range (e.g. low VARIANCE → prefer symmetric recipes; high → asymmetric).
4. **Don't reuse the same recipe on every page/section** — rotate deliberately (this is the anti-slop point; a big menu used repetitively is still slop).
5. If nothing fits, build a new arrangement and surface it in the Taste Report (§6).

Fit tags: `neutral` = works anywhere · others = reach for it when the brand leans that way.

**Navigation**

| recipe | technique | fit tags |
|---|---|---|
| wordmark + 2 links | minimal bar, two links right | neutral, personal |
| SaaS three-section | wordmark · centred links · CTA right | saas — ⚠️ near the generic AI-nav; use only when genuinely fitting |
| floating chip | small fixed corner chip | playful, portfolio |
| side-rail | thin vertical strip, rotated wordmark | editorial, unconventional |
| hidden-behind-⌘K | no visible nav, command palette | dev-tool, power-user |
| floating pill | rounded pill detached from edges | playful, modern |
| newspaper masthead | large centred wordmark + issue line | editorial, publication |
| brutal slab | heavy full-width, 2px border, all-caps | bold, brutalist |
| terminal command | nav as a CLI prompt | dev-tool, technical |
| edge-aligned minimal | wordmark left, CTA right, vast gap | minimal, premium |
| scroll-morph | top bar morphs into floating pill on scroll | modern, saas |
| mega-menu | full-width multi-column panel | saas, large catalog |
| banner + retracting nav | promo banner above real nav | marketing, announcement |
| inline ⌘K pill | visible search pill in the bar | saas, search-heavy |

**Hero**

| recipe | technique | fit tags |
|---|---|---|
| split diptych | headline+lede one side, asset other (6/6 or 7/5) | neutral, saas (workhorse) |
| marquee | one statement fills the fold, no CTA | bold, statement |
| quote-led | a pull-quote is the hero | editorial, credibility |
| stat-led | a giant number is the hero + qualifier | data, saas, results |
| letter hero | first-person "Dear reader," opening | personal, narrative |
| photographic fold | full-bleed image + corner caption | premium, media |
| demo-video clipped | headline left, demo video clipped by right edge | saas, demo |
| mockup split | headline left, browser-framed mockup tilted 1–3° | saas, app |
| custom illustration | one hand-built SVG centrepiece | playful, creative |

**Section layout & heading style**

| recipe | technique | fit tags |
|---|---|---|
| bento grid | mixed-span tiles, cell count = content count | modern, saas |
| sticky-scroll stack | sticky pane + scrolling companion | saas, storytelling |
| tabular spec sheet | rows=features, tabular-nums columns | technical, comparison |
| step sequence | numbered stages flow vertically | onboarding, process |
| annotated screenshot | real capture + pointing labels | saas, demo |
| product card grid | card = a product (image·name·price) | e-commerce, catalog |
| heading: hanging | heading floats in negative space | minimal, editorial |
| heading: sticky-pinned | heading stays while content scrolls | docs, long-form |
| heading: inline no-break | small-caps head emerges inside body | editorial, prose |
| heading: bottom-anchored | label sits below the content | editorial, unconventional |
| heading: left-margin numbered | `01 — LABEL` in a narrow left column | editorial — ⚠️ eyebrow risk, use sparingly |

**Social proof**

| recipe | technique | fit tags |
|---|---|---|
| pull-quote + marginalia | quote in wide column, note in margin | editorial |
| logo wall (hairline) | monochrome logos, hairline dividers, no cards | saas, b2b |
| single huge quote | one big quote fills a section | bold, premium |
| numbered stat strip | 3–5 stats in a row, tabular-nums | data, saas, results |

**Footer**

| recipe | technique | fit tags |
|---|---|---|
| mast-headed | wordmark + tagline band + few links | neutral |
| inline-rule single line | one line of credits under a hairline | minimal |
| dense typographic | one block of mono/serif colophon | editorial, colophon |
| statement | one display sentence closes the page | bold, narrative |
| letter close | closes like a letter ("Yours, the team.") | personal |
| newsletter-first | the form is the primary element | content, media |
| marquee scroll | infinite-scroll tagline line | playful, edgy |
| index-style columns | 4 columns of links | large hub only — ⚠️ this is the generic AI-footer; use only with a real sitemap |

**Component**  `[design-component-builder]`

| recipe | technique | fit tags |
|---|---|---|
| outlined chip | bordered transparent button + verb | neutral |
| typographic link | word + arrow + 1px underline, no box | neutral, minimal, editorial |
| inline form-as-CTA | the CTA *is* the form (input + submit) | marketing, newsletter |
| sticky mobile CTA | bottom bar: action + reassurance, ≥44px | mobile, conversion |

---

## §8 Dials — tune boldness to the brand  `[both]`

Three knobs (1–10). **Single source of truth:** if `design.md` already records a `**Design dials:**` line in its `## Overview` (written by `design-builder` Step 1b-dials), **reuse those exact numbers** — do not re-derive. Only when no design.md dials exist, derive them here from `docs/brand/` + `docs/blueprints/` (Phase 0) using the table below. This keeps the token layer (`design.md`) and the composition layer (this file) tuned to the *same* brand reading.

They gate how far the recipes and motion push, so "distinctive" stays *on-brand* instead of random.

| dial | 1 (low) | 10 (high) | gates |
|---|---|---|---|
| **VARIANCE** | symmetric, predictable | asymmetric, masonry | which §7 layout recipes are eligible |
| **MOTION** | static | choreographed / scroll-driven | animation scope (entrances, scroll effects) |
| **DENSITY** | airy, gallery | packed, cockpit/dashboard | spacing + how much data per screen |

**Deriving the dials from the brief (examples):**

| brand / product signal | VARIANCE | MOTION | DENSITY |
|---|---|---|---|
| minimalist / Linear-style / premium | 5–6 | 3–4 | 2–3 |
| bold / brutalist / creative agency | 8–10 | 6–8 | 4–6 |
| enterprise SaaS / dashboard / data-heavy | 3–5 | 2–4 | 7–9 |
| editorial / narrative / personal | 6–8 | 3–5 | 2–4 |
| e-commerce / marketing landing | 5–7 | 4–6 | 5–7 |

**How the dials drive output:**
- **VARIANCE** low → pick symmetric recipes (split diptych, clean grid); high → asymmetric (bento, side-rail, hanging heads).
- **MOTION** low → one orchestrated entrance on load, no scroll effects; high → sticky-scroll / scroll-morph allowed. Regardless of level: name transition properties (never `transition: all`), use ease-out for UI state changes (Carbon standard `cubic-bezier(0.5,0,0.1,1)`), and respect `prefers-reduced-motion`.
- **DENSITY** low → generous section padding, few elements; high → tighter spacing, tabular data, more per screen.

Report the chosen dial values in the Taste Report (§6) so the human can see the intended register and correct it.

---

_Credit: this file adapts two MIT-licensed skills. **Composition / craft / motion / content rules and the §7 recipe menu** are adapted from [Hallmark](https://github.com/Nutlope/hallmark) (Nutlope / Together AI). The **§6 mechanical checks and the §8 VARIANCE/MOTION/DENSITY dials** are adapted from the [Taste Skill](https://github.com/Leonxlnx/taste-skill) (Leon Si). We left out both skills' proprietary theme/palette systems — colour, typography, and theme are owned by our `design.md`. Where the two disagree (e.g. Taste bans the em-dash `—`, Hallmark uses it), we keep the em-dash: it is correct typography; the fix for AI over-use is using it *well*, not banning it._
