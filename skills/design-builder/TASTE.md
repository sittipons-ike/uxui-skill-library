# TASTE.md — Anti-slop / design-taste rules (agent-facing)

> Distilled and adapted from **Hallmark** by Nutlope / Together AI (MIT license) — https://github.com/Nutlope/hallmark
> Rephrased into this design system's vocabulary. We deliberately keep ONLY the composition / component-craft / motion / content rules that our tokens do **not** already govern.
> **Colour, typography, theme, and spacing values are owned by `design.md`** — not here. This file is about *how things are composed and behave*, not what colour they are.
>
> **Consumed as a self-critique gate by:**
> - `design-component-builder` → §1 Component · §3 Motion · §4 Content · §5 A11y/Perf
> - `design-ui-builder` → §2 Composition · §3 Motion · §4 Content · §5 A11y/Perf

---

## §0 Philosophy — warn, don't block (governed deviation)

These are **default-good rules, not hard laws.** Breaking one to make the design genuinely better is *allowed* — the rule is that a deviation must be **surfaced, never silent.**

Two kinds of deviation to report in the Taste Gate (§6):

1. **Taste deviation** — broke a rule below on purpose. State *why* it improves the design.
2. **DS gap** — the design needed a component or token that `design.md` / `components.json` doesn't have yet. Name it + propose adding it.

**Flow:** emit the work + report → human reviews → on approval, *promote* the gap into the DS (add the component to `components.json`, add the token to `design.md`) so it becomes reusable. This mirrors the governed `variant-extensions` escape valve — deviation is fine when it's named, justified, and can graduate into the system. See [[variant-extensions]].

**Never block emission.** Ship the best design + a clear report. The point is to base on the real DS without closing off good ideas.

---

## §1 Component-level  `[design-component-builder]`

- **Choose the button/chip shape on purpose** — rectangular, slab, or pill (pill only for playful/tactile tones). Don't default to a rounded rectangle. Adornment (arrow / plus / none) is a deliberate choice.
- **Prefer a typographic link** (word + arrow + 1px underline, no box) where a link fits — reach for a filled button only for the primary action.
- **Tabular numerals** — apply `font-variant-numeric: tabular-nums` to any component showing columns of prices / dates / metrics, so digits align vertically.
- **Never let a clickable label wrap to two lines** — shorten the copy (e.g. *Get started free → Start free*) or set `white-space: nowrap`; drop non-essential items at narrow widths.
- **One icon library per project** — don't mix Lucide + Heroicons + Material + emoji.
- **No side-stripe card** (thick 4–6px coloured border on one edge) — use a hairline border all around, no border, or a small accent square beside the heading.
- **One containment layer** — no card-in-card nesting; usually the outer wrapper is unnecessary.
- **Every hover affordance needs a focus state and a tap path** — nothing crucial appears on hover only (a11y on coarse pointers).
- **No inline colour/font values** in component CSS — always reference a named token (`var(--btn-background)`, `font-family: var(--font-display)`). (Reinforces our no-vocabulary-swap rule — see [[NAMING.md]].)

---

## §2 Composition-level  `[design-ui-builder]`

- **Don't centre everything** — bias the layout; break symmetry at least once per page (wide left margin / narrow right, or the reverse).
- **Break the 3-equal-column feature grid** — vary column widths, mix card heights, remove a card, pull icons inline, or drop cards for typographic rhythm.
- **Hero matches content height** — avoid the full-viewport (`100vh`) centred single-sentence + single-CTA hero; bias left/right, include more than one sentence.
- **Vary section padding** — not identical top/bottom/side spacing on every section; tighten one, expand another.
- **Eyebrows** (uppercase mono-caps over a heading like `01 / FEATURES`) — zero by default; cap at 1–2 per page; never a tag-left / header-right two-column section head.
- **Route nav & footer by context** — avoid the generic AI nav (wordmark-left · inline links centred · CTA hard-right · sticky · 1px bottom border) and the generic AI footer (4 link columns · social row · tiny copyright).
- **No icon-tile feature card** (icon-in-coloured-square top-left + heading + two lines) as a default — make it asymmetric, vary sizes, pull the icon inline, or drop it.
- **`width: 100%` + container padding, never `100vw`** (100vw overflows when a scrollbar is visible).

---

## §3 Motion  `[both]`

- **Never `transition: all`** — name the properties (`transition: background-color var(--dur-short) var(--ease-out)`).
- **One signal per element** — not every card gets `hover:scale`. Pick one: a 1px translate, a colour shift, or an underline change — not all of them.
- **UI easing = ease-out** — reserve bouncy / overshoot easings for genuine physical interactions, not buttons/modals/tooltips.
- **One orchestrated entrance on load** — don't fade-up every section on scroll; after the first paint, content just exists.
- **Focus rings appear instantly** — don't animate `outline` / `box-shadow` when an element gains focus (keyboard users need it immediately).
- **Spinners: delay-show ~150ms or min-show ~300ms** — prefer skeletons when the layout is known.
- **Toasts stack in a fixed corner** — a new toast doesn't shift page layout; success is silent unless its effect isn't visible on screen.
- **Carousels: no autoplay without pause** — pause on hover *and* focus, or manual-advance only (WCAG 2.2.2).

---

## §4 Content & copy  `[both]`

- **Typographer's punctuation** — curly quotes `" "` `' '`, em-dash `—`, ellipsis `…` (not `" '`, `--`, `...`).
- **No invented metrics** — never fabricate "10× faster", "50,000+ teams", "99.9% uptime". Use a labelled placeholder (`— metric to confirm`) or ask for the real number.
- **Plausible placeholder names** reflecting the audience (`Maya Okonkwo`, `Sam Tan`), not `Jane Doe` / `John Smith`.
- **Concrete product names**, not startup bingo (`Acme`, `Nexus`, `Pulse`, `Seamless`).
- **Icon library, not emoji** — no `✨ 🚀 ⚡ 🔥 🎯` as feature icons; use the chosen library or a custom SVG.
- **No fake UI chrome** — no drawn browser bar, phone frame, or IDE window. Use a real screenshot inside a hairline `<figure>`.

---

## §5 A11y & performance  `[both]`

- **LCP element** (hero image/video): `fetchpriority="high"`, never `loading="lazy"`. Lazy-load only below-fold media.
- **Named z-index scale**, not `z-index: 9999`.
- **Confirmation dialogs only for irreversible actions** — reversible actions use optimistic update + a 5–10s Undo toast; true destructive cases use type-the-name confirmation.
- **`<video>` heroes**: `autoplay muted loop playsinline`; add a separate audio toggle only if sound is genuinely useful.

---

## §6 Taste Gate — self-critique before emitting output

**Run this once, right before writing the output files.** Check the sections relevant to this skill (component builder → §1,3,4,5; ui builder → §2,3,4,5), then print a short report:

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

---

_Credit: rule set adapted from [Hallmark](https://github.com/Nutlope/hallmark) (Nutlope / Together AI, MIT). We took the composition/craft/motion/content principles and left out Hallmark's proprietary theme + macrostructure taxonomy — those roles are filled by our own `design.md`._
