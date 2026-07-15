---
name: design-icon-builder
description: Populate the iconography layer of design.md and optionally fetch real SVG files from one of 8 free icon libraries (Phosphor, Tabler, Heroicons, Lucide, Iconoir, Material Symbols, Bootstrap, Remix) via CDN — no npm install. Picks a library by mood, downloads a starter set to ./icons/, and locks the choice into design.md. Falls back to monolithic DESIGN.md if split files aren't present. Triggers on "build icons", "icon system", "iconography", "fetch icons", "download icons", "เพิ่ม icon set", "ดึง icon มาใช้", "ทำ icon style guide".
version: 2.3.0
user-invocable: true
---

# 🎯 Design Icon Builder

Fills the `iconography` block in `DESIGN.md` with mood-driven defaults. Optional SVG starter set.

## Arguments

_All optional — the skill applies sensible defaults when an argument is omitted._

| Argument | Description |
|---|---|
| `source` | Path to design.md (default ./design.md) — falls back to ./DESIGN.md |
| `fetch` | If true, download SVGs via CDN to ./icons/. Default true. |
| `library` | Override mood-default library: phosphor \| tabler \| heroicons \| lucide \| iconoir \| material-symbols \| bootstrap \| remix |
| `scope` | Icon set size: starter (12) \| common (36) \| extended (60) \| custom. Default: starter |
| `custom-icons` | Comma-separated icon concepts (only when scope=custom). Example: 'receipt,invoice,bank,chart-line' |

## When to use
- DESIGN.md has primitive + semantic + mood already set
- Need to lock icon style decisions BEFORE handing to a designer or third-party icon library

## When NOT to use
- No mood declared in DESIGN.md → run `design-builder` first
- Want to add components → use `design-component-builder` (emits `components.json`, DTCG-aligned manifest)

## Pipeline position
This skill writes the **iconography layer of `design.md`** only. Icons stay in `design.md` as a resource layer — NOT migrated to JSON — because icons are visual assets (SVG files + style tokens), not interactive components with props/states. This mirrors industry practice (Material Symbols, Carbon, Tailwind ship icons separately from component libraries).

**Hand-off:**
- ⬅ Upstream: `design-builder` writes primitive + semantic + mood in `design.md`
- ➡ Downstream: `design-component-builder` reads `design.md` (incl. iconography) and emits `components.json` — atoms can reference `{design.iconography.*}` via cross-file refs

## Mood → Library map (with CDN routes)

All libraries below are MIT/Apache 2.0 licensed and ship SVGs reachable via CDN.

| Mood | Default library | Style | CDN base URL |
|---|---|---|---|
| `bold-tech` | **Tabler** | filled | `https://cdn.jsdelivr.net/npm/@tabler/icons@latest/icons/filled/<name>.svg` |
| `friendly-warm` | **Phosphor** | regular | `https://unpkg.com/@phosphor-icons/core/assets/regular/<name>.svg` |
| `premium-editorial` | **Phosphor** | thin | `https://unpkg.com/@phosphor-icons/core/assets/thin/<name>.svg` |
| `playful-vivid` | **Iconoir** | solid | `https://cdn.jsdelivr.net/npm/iconoir@latest/icons/solid/<name>.svg` |
| `technical-dev` | **Lucide** | outlined | `https://cdn.jsdelivr.net/npm/lucide-static@latest/icons/<name>.svg` |
| `calm-focused` | **Heroicons** | outline | `https://cdn.jsdelivr.net/npm/heroicons@latest/24/outline/<name>.svg` |

### Full library catalog (CDN URL patterns)

| Library | Count | Styles | CDN URL pattern (verified) |
|---|---|---|---|
| Phosphor | 1,500 × 6 weights | thin / light / regular / bold / fill / duotone | `https://unpkg.com/@phosphor-icons/core/assets/<weight>/<name>-<weight>.svg` (regular weight uses bare `<name>.svg`) |
| Tabler | 5,400 | outline / filled | `https://cdn.jsdelivr.net/npm/@tabler/icons@latest/icons/<outline\|filled>/<name>.svg` |
| Heroicons | 350 | outline / solid / mini / micro | `https://cdn.jsdelivr.net/npm/heroicons@latest/<24\|20\|16>/<outline\|solid>/<name>.svg` |
| Lucide | 1,600 | outlined only | `https://cdn.jsdelivr.net/npm/lucide-static@latest/icons/<name>.svg` |
| Iconoir | 1,600 regular / partial solid | regular / solid | `https://cdn.jsdelivr.net/npm/iconoir@latest/icons/<regular\|solid>/<name>.svg` ⚠️ solid is partial — fallback to regular |
| Material Symbols | 3,400 | outlined / rounded / sharp (× fill 0\|1) | Use Google Fonts API — JSDelivr path varies; recommend `@material-symbols/svg-400` package |
| Bootstrap Icons | 2,000 | outline / filled | `https://cdn.jsdelivr.net/npm/bootstrap-icons@latest/icons/<name>.svg` (suffix `-fill` for filled, e.g. `house-fill.svg`) |
| Remix Icon | 2,800 | line / fill | `https://cdn.jsdelivr.net/npm/remixicon@latest/icons/<Category>/<name>-<line\|fill>.svg` ⚠️ requires category prefix (Buildings/Business/etc.) |

## Execution Steps

### 0. Confirm scope + library (REQUIRED — never skip)

**MUST** call `AskUserQuestion` once with 2 questions (multi-question, single round) BEFORE loading source — unless BOTH `scope` AND `library` args were passed explicitly by user.

Questions:

1. **เลือก icon scope** — กี่ icons ที่จะดึงเข้า?
   - Option A: **starter (12)** — proof-of-concept / landing
   - Option B: **common (36)** — MVP SaaS
   - Option C: **extended (60)** — production SaaS
   - Option D: **custom** — ระบุเอง (ตามด้วย comma-separated list)

2. **เลือก icon library** — หรือให้ skill เลือกตาม mood?
   - Option A: **ใช้ mood-default** (อ่าน `mood.primary` แล้ว apply mood map)
   - Option B: **Phosphor** / **Tabler** / **Heroicons** / **Lucide** / **Iconoir** / **Material Symbols** / **Bootstrap** / **Remix** (multiSelect: false — pick one)

Rules:
- ห้าม default scope=starter เงียบๆ — ถ้า user ไม่ตอบ ABORT พร้อม error: "scope is required — re-run with /design-icon-builder scope=starter|common|extended|custom"
- ถ้า user เลือก `custom` → ถาม follow-up: "ระบุ icon concepts (comma-separated):" (free text)
- ถ้า args `scope=` AND `library=` ถูกส่งมาตอนเรียก skill → SKIP Phase 0 (treat as explicit choice)

### 1. Load source
- Default: `./design.md` (split-architecture)
- Legacy fallback: `./DESIGN.md` (monolithic) — supported but emit INFO
- Parse YAML — read `mood.primary` AND `mood.secondary`
- Verify `scope: 'tokens-only'` if split; iconography block lives inside this file's `semantic:` siblings
- ABORT with clear message if `mood.primary` is `'tbd'` or missing — icons need mood to decide style
- Read `semantic.spacing` (icon sizes ref this)

### 2. Pick icon style
- Apply mood map above
- If user wants override (e.g., "I want filled instead of outlined"), record reasoning in YAML comment
- Document the choice in the ## Iconography body section

### 3. Populate `iconography` YAML block

Replace placeholder:
```yaml
  iconography:
    style: 'outlined'              # mood: calm-focused → outlined
    stroke-width: 1.5              # mood-recommended
    grid: 24                       # canonical
    corner: 'rounded'              # mood-driven
    library: 'phosphor-regular'    # suggested library to start from
    sizes:                         # ref semantic.spacing
      sm: '{semantic.spacing.md}'  # 16px
      md: '{semantic.spacing.lg}'  # 24px
      lg: '{semantic.spacing.xl}'  # 32px
    color-default:    '{semantic.colors.text.primary}'
    color-secondary:  '{semantic.colors.text.secondary}'
    color-tertiary:   '{semantic.colors.text.tertiary}'
    color-on-bgcolor: '{semantic.colors.text.on-bgcolor}'
    color-primary:    '{semantic.colors.primary.default}'
    color-status:
      success: '{semantic.colors.status.success.default}'
      warning: '{semantic.colors.status.warning.default}'
      error:   '{semantic.colors.status.error.default}'
      info:    '{semantic.colors.status.info.default}'
```

Sizes always ref semantic spacing. Colors always ref semantic text/status. NEVER raw hex.

### 4. Define icon set per scope

Pick scope by `scope` arg (default `starter`). Each scope is cumulative — `common` includes all 12 from `starter`, `extended` includes all 36 from `common`.

#### Scope: `starter` (12 — proof-of-concept / landing)
Universal — every app needs these:
1. home · 2. search · 3. settings · 4. user · 5. add · 6. delete
7. edit · 8. close · 9. menu · 10. arrow-right · 11. check · 12. info

#### Scope: `common` (36 — MVP SaaS) = starter + 24
Navigation arrows:
- chevron-up · chevron-down · chevron-left · chevron-right (4)

Utility:
- sort · filter · refresh · download · upload · share (6)

Social / temporal:
- calendar · clock · bell · heart · bookmark · star (6)

Controls:
- more-horizontal · lock · eye · eye-slash · copy · link (6)

Status:
- alert-triangle · alert-circle (2)

#### Scope: `extended` (60 — production SaaS) = common + 24
Arrows + charts:
- arrow-up · arrow-down · arrow-left · chart-bar · chart-line · chart-pie (6)

Finance / commerce:
- dollar · credit-card · receipt · shopping-cart · tag (5)

Contact:
- mail · phone · location · globe (4)

Media:
- folder · file · image · video (4)

Help / states:
- help-circle · question · play · pause · moon · sun (6) (note: only 5 here — see exhaustive list below)

Total 60.

#### Scope: `custom`
Pass `custom-icons` arg with comma-separated concepts:
```
custom-icons: "receipt,invoice,bank,chart-line,coffee,scale,box"
```

Resolver looks up each concept name in the library's catalog. If not found, log warning + skip (designer adds manually).

### 4b. Phosphor name mappings (extended)

For `common` scope additions:
| Concept | Phosphor | Tabler | Heroicons | Lucide |
|---|---|---|---|---|
| chevron-up | `caret-up` | `chevron-up` | `chevron-up` | `chevron-up` |
| chevron-down | `caret-down` | `chevron-down` | `chevron-down` | `chevron-down` |
| chevron-left | `caret-left` | `chevron-left` | `chevron-left` | `chevron-left` |
| chevron-right | `caret-right` | `chevron-right` | `chevron-right` | `chevron-right` |
| sort | `arrows-down-up` | `arrows-sort` | `bars-arrow-up` | `arrow-up-down` |
| filter | `funnel` | `filter` | `funnel` | `filter` |
| refresh | `arrows-clockwise` | `refresh` | `arrow-path` | `refresh-cw` |
| download | `download-simple` | `download` | `arrow-down-tray` | `download` |
| upload | `upload-simple` | `upload` | `arrow-up-tray` | `upload` |
| share | `share-network` | `share` | `share` | `share-2` |
| calendar | `calendar` | `calendar` | `calendar` | `calendar` |
| clock | `clock` | `clock` | `clock` | `clock` |
| bell | `bell` | `bell` | `bell` | `bell` |
| heart | `heart` | `heart` | `heart` | `heart` |
| bookmark | `bookmark` | `bookmark` | `bookmark` | `bookmark` |
| star | `star` | `star` | `star` | `star` |
| more-horizontal | `dots-three` | `dots` | `ellipsis-horizontal` | `more-horizontal` |
| lock | `lock` | `lock` | `lock-closed` | `lock` |
| eye | `eye` | `eye` | `eye` | `eye` |
| eye-slash | `eye-slash` | `eye-off` | `eye-slash` | `eye-off` |
| copy | `copy` | `copy` | `clipboard-document` | `copy` |
| link | `link` | `link` | `link` | `link` |
| alert-triangle | `warning` | `alert-triangle` | `exclamation-triangle` | `triangle-alert` |
| alert-circle | `warning-circle` | `alert-circle` | `exclamation-circle` | `circle-alert` |

For `extended` scope additions:
| Concept | Phosphor | Tabler | Heroicons | Lucide |
|---|---|---|---|---|
| arrow-up | `arrow-up` | `arrow-up` | `arrow-up` | `arrow-up` |
| arrow-down | `arrow-down` | `arrow-down` | `arrow-down` | `arrow-down` |
| arrow-left | `arrow-left` | `arrow-left` | `arrow-left` | `arrow-left` |
| chart-bar | `chart-bar` | `chart-bar` | `chart-bar` | `chart-column` |
| chart-line | `chart-line-up` | `chart-line` | `chart-bar-square` | `trending-up` |
| chart-pie | `chart-pie` | `chart-pie` | `chart-pie` | `pie-chart` |
| dollar | `currency-dollar` | `currency-dollar` | `currency-dollar` | `dollar-sign` |
| credit-card | `credit-card` | `credit-card` | `credit-card` | `credit-card` |
| receipt | `receipt` | `receipt` | `receipt-percent` | `receipt` |
| shopping-cart | `shopping-cart` | `shopping-cart` | `shopping-cart` | `shopping-cart` |
| tag | `tag` | `tag` | `tag` | `tag` |
| mail | `envelope` | `mail` | `envelope` | `mail` |
| phone | `phone` | `phone` | `phone` | `phone` |
| location | `map-pin` | `map-pin` | `map-pin` | `map-pin` |
| globe | `globe` | `world` | `globe-alt` | `globe` |
| folder | `folder` | `folder` | `folder` | `folder` |
| file | `file` | `file` | `document` | `file` |
| image | `image` | `photo` | `photo` | `image` |
| video | `video-camera` | `video` | `video-camera` | `video` |
| help-circle | `question` | `help-circle` | `question-mark-circle` | `circle-help` |
| play | `play` | `player-play` | `play` | `play` |
| pause | `pause` | `player-pause` | `pause` | `pause` |
| moon | `moon` | `moon` | `moon` | `moon` |
| sun | `sun` | `sun` | `sun-dim` | `sun` |

### 5. Write `## Iconography` section (markdown body)

```markdown
## Iconography

**Style:** outlined, 1.5px stroke, 24px grid, rounded corners
**Library suggestion:** Phosphor (regular weight) — closest match to calm-focused mood
**Mood reasoning:** Outlined icons echo the hairline borders + soft surfaces. Stroke weight matches `{semantic.border-width.hairline}` for consistency.

### Sizes
| Token | Value | Use |
|---|---|---|
| `sm` (16) | inline with body text | menu indicators, table actions |
| `md` (24) | default | nav, buttons, cards |
| `lg` (32) | feature | headers, empty states |

### Color tokens
- `color-default` — body text icons
- `color-secondary` — muted icons (sidebar inactive)
- `color-primary` — brand action icons
- `color-status.*` — alert/toast/badge icons

### Starter set (required 12 concepts)
- home, search, settings, user, add, delete, edit, close, menu, arrow-right, check, info

Pull SVGs from Phosphor or replace per brand. Maintain stroke + grid.

### Do's and Don'ts
- ✅ Use one library — don't mix Phosphor + Heroicons in the same screen
- ✅ Recolor via `currentColor` so CSS controls hue, not the SVG
- ❌ Don't import filled icons into an outlined system
- ❌ Don't scale icons off-grid (16, 24, 32 only — no 20, 28, 36)
```

### 6. Fetch SVGs from CDN (default: ON)

If `fetch` arg is not explicitly `false`, download the 12 starter icons from the chosen library's CDN.

**Concept → library-name map** (each library uses different names — map per library):

| Concept | Phosphor | Tabler | Heroicons | Lucide | Iconoir | Material Symbols |
|---|---|---|---|---|---|---|
| home | `house` | `home` | `home` | `house` | `home` | `home` |
| search | `magnifying-glass` | `search` | `magnifying-glass` | `search` | `search` | `search` |
| settings | `gear` | `settings` | `cog-6-tooth` | `settings` | `settings` | `settings` |
| user | `user` | `user` | `user` | `user` | `user` | `person` |
| add | `plus` | `plus` | `plus` | `plus` | `plus` | `add` |
| delete | `trash` | `trash` | `trash` | `trash` | `trash` | `delete` |
| edit | `pencil` | `pencil` | `pencil` | `pencil` | `edit-pencil` | `edit` |
| close | `x` | `x` | `x-mark` | `x` | `xmark` | `close` |
| menu | `list` | `menu-2` | `bars-3` | `menu` | `menu` | `menu` |
| arrow-right | `arrow-right` | `arrow-right` | `arrow-right` | `arrow-right` | `arrow-right` | `arrow_forward` |
| check | `check` | `check` | `check` | `check` | `check` | `check` |
| info | `info` | `info-circle` | `information-circle` | `info` | `info-circle` | `info` |

**Fetch command pattern** (use Bash + curl):
```bash
mkdir -p ./icons
# Example: Phosphor regular for calm-focused
for name in house magnifying-glass gear user plus trash pencil x list arrow-right check info; do
  curl -fsSL "https://unpkg.com/@phosphor-icons/core/assets/regular/${name}.svg" \
    -o "./icons/${name}.svg"
done
```

Rename to canonical concept names after download (so consumers don't care about library):
```bash
# Phosphor → canonical
mv ./icons/house.svg ./icons/home.svg
mv ./icons/magnifying-glass.svg ./icons/search.svg
mv ./icons/gear.svg ./icons/settings.svg
mv ./icons/x.svg ./icons/close.svg
mv ./icons/list.svg ./icons/menu.svg
# user, plus, trash, pencil, arrow-right, check, info already canonical
```

For each fetched SVG:
1. Verify HTTP 200 (curl `-f` flag fails fast on 404)
2. Quickly check it's valid SVG (starts with `<svg`)
3. If a name isn't in the library, log a warning and continue — designer can add manually later

**License attribution:** Add `./icons/LICENSE.md` with the library's license text + source URL. Required for MIT/Apache compliance.

### 7. Generate optional starter wrappers (skip unless asked)

If user wants React/TypeScript wrappers, generate one file `./icons/index.tsx`:
```tsx
// Auto-generated by design-icon-builder. Re-run to regenerate.
import HomeSvg from './home.svg';
import SearchSvg from './search.svg';
// ... etc

export const Home = (props: React.SVGProps<SVGSVGElement>) =>
  <HomeSvg {...props} aria-hidden="true" />;
// ... etc
```
Skip unless `--wrappers` flag passed.

### 7. Validate output
- [ ] `iconography:` YAML block has no `'tbd'` left
- [ ] All sizes ref `{semantic.spacing.*}`
- [ ] All colors ref `{semantic.colors.*}` (no raw hex)
- [ ] Style choice matches mood map (or has documented override reason)
- [ ] `## Iconography` body section exists with style + sizes + starter set
- [ ] Mood reasoning documented (1 sentence)

### 8. Update Known Gaps if needed
If `fetch=false` was passed, add: `- **Icon SVG files** — iconography spec defined; SVGs not downloaded. Re-run skill without fetch=false to fetch from CDN.`

### 9. Lock library + version in YAML

Record what was fetched:
```yaml
iconography:
  library: 'phosphor-regular'
  library-version: '2.1.7'          # pin from CDN response if available
  library-url: 'https://phosphoricons.com'
  license: 'MIT'
  fetched: 12                        # count of icons downloaded
  fetched-at: '2026-05-29'
```

This makes audit/migration trivial — future agents know which library to keep, which to swap.

## Constraints
- READ DESIGN.md once at start; don't re-read
- Do NOT touch primitive / semantic / component blocks — only iconography
- Do NOT invent style choices — apply mood map verbatim unless user overrides
- If mood is `'tbd'`, ABORT — icons cannot be styled without mood

## Quality Bar
A designer reading the final DESIGN.md should know:
- Which icon library to use (or what style to design custom icons in)
- Exact stroke weight + grid + corner style
- Which size token to apply where
- Which color token icons inherit from
- Which 12 concepts MUST exist before shipping
