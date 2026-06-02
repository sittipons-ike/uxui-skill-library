# Architecture v5 — JSON Manifest Migration

> Audience: ทีม UXUI (designer + dev + agent maintainers)
> Status: Approved — implementation in progress
> Owner: design@7solutions.co.th
> Last updated: 2026-06-02

---

## 1. ทำไมเปลี่ยน (Motivation)

เราใช้ split architecture (`design.md` + `components.md` + `ui.md`) มาพักหนึ่งแล้ว และเจอปัญหาซ้ำๆ ที่ทำให้ทีมเสียเวลาและ agent generate ผิดบ่อย:

### 1.1 Drift ระหว่าง spec กับ HTML จริง
- `components.md` เขียนเป็น prose + table — agent ต้องตีความ → ตีความผิดบ่อย โดยเฉพาะ state matrix (hover/active/focus/disabled)
- HTML output ที่ได้ ไม่ตรงกับสิ่งที่ spec บอก แต่ไม่มีใครจับได้จนถึง dev handoff
- Designer แก้ spec → agent ไม่รู้ว่า field ไหนเปลี่ยน → regenerate ทั้งไฟล์ → drift เพิ่ม

### 1.2 Agent token cost
- `components.md` ของจริงมักยาว 1,500–3,000 บรรทัด
- ทุกครั้งที่ build `ui.md` agent ต้องโหลดทั้งไฟล์ — ส่วนใหญ่เพื่ออ่าน reference ไม่กี่บรรทัด
- JSON manifest ให้ agent jump ตรง path ได้ → ลด context cost 40–60%

### 1.3 Scalability for DTCG / cross-framework
- ทีมเริ่มถามว่า "tokens export ไป Style Dictionary ได้มั้ย" / "ส่งให้ iOS team ใช้ได้มั้ย"
- Markdown prose แปลงไม่ได้ — ต้องเขียน parser เอง
- JSON ตรงเข้า DTCG (Design Tokens Community Group) spec → Style Dictionary / Tokens Studio อ่านได้ฟรี

### 1.4 Real workflow pain (จาก user feedback)
- "อ่าน components.md ไม่ไหวแล้วพี่ ยาวมาก" — designer
- "เปลี่ยน semantic.color.primary ที่เดียว แต่ agent ไป regenerate ทั้ง section" — designer
- "ทำไม audit บอก ref ถูก แต่ HTML ใช้สีผิด" — dev
- "อยาก diff ระหว่าง 2 version ของ DS ดูว่าอะไรเปลี่ยน — md diff อ่านไม่รู้เรื่อง" — lead

---

## 2. โครงสร้างใหม่ (Post-change File Layout)

```
project-root/
├── design.md              ← YAML-in-Markdown   (designer-facing, UNCHANGED)
├── components.json        ← JSON manifest      (agent-facing, NEW)
├── patterns.json          ← JSON manifest      (agent-facing, NEW, separate from ui)
├── ui.json                ← JSON manifest      (agent-facing, NEW)
├── styleguide.html        ← rendered preview   (designer + team review, UNCHANGED)
├── components.html        ← rendered preview   (UNCHANGED)
└── icons/                 ← SVG files          (UNCHANGED)
```

### Why this split

| Layer | Format | Why |
|---|---|---|
| `design.md` | YAML-in-Markdown | Designer reads + edits this directly. YAML is structured enough for agent, Markdown gives prose context. Don't break what works. |
| `components.json` | JSON | Atom/molecule/organism specs. Agent-only — never read by designer (they look at `styleguide.html`). |
| `patterns.json` | JSON, **separate file** | Reusable cross-page patterns (auth-split, app-shell, empty-state). Kept separate from `ui.json` because patterns are referenced by multiple pages — separating lets agents load only what they need. |
| `ui.json` | JSON | Page-level compositions, flows, sections. Largest file — separating from patterns keeps both manageable. |
| `*.html` | HTML | Universal output. Dev handoff, design review, browser preview. Unchanged. |

### Direction of refs (strict, enforced by audit)

```
ui.json  →  patterns.json  →  components.json  →  design.md
            (downward only — upward refs = audit error)
```

---

## 3. Migration Timeline

| Version | What changes | MD support |
|---|---|---|
| **v5** (current) | JSON output becomes default. Skills emit `*.json`. Audit understands both. | `--format=md` flag works, prints deprecation warning |
| **v6** (next) | Tooling matures around JSON. More warnings when `--format=md` used. | `--format=md` still works, louder warnings, doc says "removed in v7" |
| **v7** (future) | `--format=md` removed entirely. Audit only reads JSON. | Not supported. Team must migrate. |

### Per-skill versioning

- No library-wide major bump. Each skill versions independently.
- A skill that adds JSON output goes `design-component-builder v2.0` (major because output format changes).
- A skill that doesn't touch components.json stays on its current version.
- `--format=md` is a **feature flag** on individual skills, not a global mode.

---

## 4. The 6 Approved Decisions

These are locked in. Don't relitigate unless we learn something new from real usage.

### 4.1 `design.md` stays YAML-in-Markdown — UNCHANGED
- Designer-facing. They read and edit it.
- YAML inside MD gives both structure (for agent) and prose (for human context).
- No JSON conversion. Don't break the one file that works well.

### 4.2 `patterns.json` is a SEPARATE file from `ui.json`
- Patterns are referenced by multiple pages — separating them lets agents load only what they need.
- Editing a pattern shouldn't churn `ui.json` diff.
- Keeps both files under a manageable size.

### 4.3 Legacy `--format=md` supported in v5 + v6, removed in v7
- Two-version grace period for teams with existing pipelines.
- Deprecation warnings get louder each version.
- Hard removal in v7 — no "v8 maybe" extensions.

### 4.4 Variants / sizes / states stored as DIFF-ONLY from base
- Each component has a `base` spec.
- `variants.primary`, `sizes.lg`, `states.hover` store **only the fields that differ from base**.
- Agent merges at read time: **base + variant + size + state** (last-write-wins).
- Why: avoids 200-line state matrices repeating the same `border-radius` 16 times.
- Trade-off: agent must merge — but agents are good at merge, humans aren't good at reading repetition.

### 4.5 Ref syntax = BRACE `{file.path.to.thing}`
- Matches DTCG alias syntax (Design Tokens Community Group).
- Regex: `^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$`
- Future Style Dictionary integration is free — same syntax, same parser.

### 4.6 Per-skill version bump, no library-wide major
- Each skill ships when ready, not gated on others.
- `--format=md` is a per-skill feature flag.
- Teams can adopt JSON output skill-by-skill, not big-bang.

---

## 5. Ref Syntax + DTCG Alignment

### Brace syntax (kept from previous version)

**Regex**
```
^\{(design|components|patterns|ui)\.([a-z0-9_.\-]+)\}$
```

**Examples**
| Ref | Resolves to |
|---|---|
| `{design.semantic.color.primary.default}` | `design.md` YAML path `semantic.color.primary.default` |
| `{components.atom.button}` | `components.json` → `atom.button` |
| `{components.atom.button.variants.primary}` | `components.json` → `atom.button.variants.primary` (merged onto base) |
| `{patterns.auth-split}` | `patterns.json` → `auth-split` |
| `{ui.page.signin}` | `ui.json` → `page.signin` |

### Direction rule (strict)

```
ui  →  patterns  →  components  →  design
                                    ↑
                       (everything ultimately resolves to design tokens)
```

- Upward refs (e.g. `components` → `ui`) = **audit error**.
- Same-layer refs allowed (component → component) but flagged for review.

### DTCG alignment

- DTCG token aliases use `{group.token}` — **same syntax as our refs**.
- This is intentional. Phase 6 adds a Style Dictionary transform that reads the `tokens` block of `design.md` directly — zero conversion needed.
- We pin DTCG version in `$meta.dtcg_version` so future DTCG breaking changes don't break our pipeline silently.

---

## 6. ทีมจะเห็นอะไรเปลี่ยน

### Designer
- ✅ เปิด `design.md` เหมือนเดิม — YAML-in-MD ไม่เปลี่ยน
- ✅ ดู `styleguide.html` เหมือนเดิม — universal preview output
- ✅ **ไม่ต้องอ่าน `components.md` อีกแล้ว** — กลายเป็น `components.json` ให้ agent อ่าน
- ✅ Review การเปลี่ยนแปลงผ่าน HTML preview, ไม่ใช่ md diff

### Agent generation
- ⚡ เร็วขึ้น 40–60% (context cost ลดลง — jump ตรง path ได้)
- 🎯 Intent ชัดขึ้น (JSON schema บังคับ field, ไม่ตีความผิด)
- 🔁 Incremental updates ทำได้จริง (แก้ field เดียวไม่ regenerate ทั้งไฟล์)

### Dev handoff
- ✅ HTML files เหมือนเดิม — dev ไม่ต้องเรียนรู้อะไรใหม่
- ➕ Optional JSON export later — ส่ง `components.json` ให้ dev ทีมเอาเข้า design tokens pipeline ได้
- ➕ Style Dictionary / Tokens Studio อ่านได้ตรงๆ (Phase 6)

---

## 7. Phase ที่กำลังทำ + Roadmap

| Phase | Title | Status |
|---|---|---|
| **1A** | Approve architecture + 6 decisions | ✅ Done |
| **1B** | Write architecture-v5.md (this doc) | ✅ Done |
| **2A** | Add JSON output to `design-component-builder` | ⏳ Pending |
| **2B** | Add JSON output to `design-ui-builder` (split into ui.json + patterns.json) | ⏳ Pending |
| **3A** | Update `design-md-audit` to read both MD + JSON, enforce ref direction | ⏳ Pending |
| **3B** | Add JSON ref-resolver (handles base + variant + size + state merge) | ⏳ Pending |
| **4** | Update `design-styleguide` to render from JSON | ⏳ Pending |
| **5A** | Migration helper: `--migrate` flag (md → json one-shot) | ⏳ Pending |
| **5B** | Add deprecation warnings to `--format=md` | ⏳ Pending |
| **6** | Style Dictionary transform (DTCG export from design.md) | ⏳ Pending |
| **7** | Remove `--format=md` (v7 release) | ⏳ Future |

---

## 8. Risks ที่ตั้งใจรับ (Accepted Risks)

We discussed these. We're proceeding anyway. Documented so we don't forget.

1. **JSON harder to hand-edit than MD** — mitigated by: designers don't edit `components.json` directly (use `styleguide.html` preview + skill commands).
2. **Diff-only merge logic adds agent complexity** — accepted: agents handle merges well, humans handle repetition poorly. Trade is correct.
3. **Two-file split (patterns + ui) means cross-file refs** — mitigated by strict direction rule + audit enforcement.
4. **Migration helper might miss edge cases** — mitigated by v5+v6 grace period; teams can fall back to `--format=md`.
5. **DTCG spec might change before Phase 6** — mitigated by `$meta.dtcg_version` pin; we'll track changes manually.
6. **Per-skill versioning makes "what version is the library" ambiguous** — accepted: simplicity of independent ship > clarity of single version.
7. **Brace syntax `{...}` collides with template engines** — accepted: brace is industry standard (DTCG, Tokens Studio); we won't pre-process refs through a template engine.
8. **JSON files lose prose context that MD provided** — mitigated by: critical context moves to `design.md` (YAML-in-MD keeps prose); component-level prose goes into `description` fields in JSON.
9. **Tooling around `*.json` (lint, format) less standardized than `.md`** — accepted: JSON tooling exists, just less skill-specific. We'll write our own audit.

---

## Appendix — Quick reference for skill authors

When updating a skill to emit JSON:

- [ ] Add JSON output as default
- [ ] Keep `--format=md` flag for v5 + v6 (with deprecation warning)
- [ ] Use brace ref syntax `{file.path.thing}` — match the regex above
- [ ] Diff-only for variants/sizes/states (don't repeat base fields)
- [ ] Add `$meta` block at top: `{ "version": "...", "dtcg_version": "...", "generated_by": "skill-name" }`
- [ ] Bump skill's own version (major bump because output format changes)
- [ ] Update skill's docstring to note JSON is default, MD is deprecated

Questions → design@7solutions.co.th or post in the team channel.
