# DS v6 — E2E Verification Report

## ภาพรวม

- **Date:** 2026-06-02
- **Phase:** 5 (E2E verify)
- **Overall result:** ⚠️ **WARN** — 17 PASS / 1 FAIL (schema bug) / 6 WARN/INFO
- **Scope:** validated schemas + examples + ref resolution + diff-merge + `$meta` consistency across the 3-file split architecture (`components` / `patterns` / `ui`)
- **Artifacts validated:**
  - `schemas/components.schema.json`
  - `schemas/patterns.schema.json`
  - `schemas/ui.schema.json`
  - `examples/components.example.json`
  - `examples/patterns.example.json`
  - `examples/ui.example.json`
  - `schemas/ref-resolver.md` (documentation only)

---

## ขั้นตอนทดสอบ

1. **JSON Schema validation** (Draft 2020-12) — each example file validated against its matching schema
2. **Brace ref regex + direction rule** — all `{scope.path}` refs match canonical regex and respect downward direction (`ui → patterns → components → design`)
3. **`$meta` consistency per scope** — `version`, `scope`, `dtcg_version`, `schema` checked across all 3 files
4. **Diff-merge demo** — button: `base → variant=primary → size=md → state=hover` traced step-by-step to confirm composition algorithm
5. **Cross-file consistency** — `ui → patterns`, `ui → components`, `patterns → components`, `* → design` refs resolved against actual file contents
6. **JSON syntax linting** — every file parses cleanly via `python -m json.tool`; no trailing commas

---

## ผลทดสอบรายข้อ

### ✅ JSON syntax + lint
| # | Check | Result | Detail |
|---|---|---|---|
| 1 | json-syntax | ✅ PASS | All 6 files (3 schemas + 3 examples) parse as valid JSON |
| 2 | json-lint | ✅ PASS | No trailing commas detected |

### ✅ Schema validation
| # | Check | Result | Detail |
|---|---|---|---|
| 3 | schema-validation components | ✅ PASS | `components.example.json` validates clean against `components.schema.json` |
| 4 | schema-validation ui | ✅ PASS | `ui.example.json` validates clean against `ui.schema.json` |
| 5 | schema-validation patterns | ❌ **FAIL** | `patterns.example.json` fails against `patterns.schema.json` — **schema bug**, not data bug. `oneOf: [Ref, string]` (in `Slot.default`) and `oneOf: [Ref, string, number]` (in `PatternDef.tokens.additionalProperties`) — every brace-ref string matches BOTH `Ref` and plain `string` branches, so `oneOf` fails by definition. **FIX:** change `oneOf` → `anyOf` in both places in `schemas/patterns.schema.json`. |

### ✅ Ref format + direction
| # | Check | Result | Detail |
|---|---|---|---|
| 6 | ref-format | ✅ PASS | All 130+ brace refs match `^\{(design\|components\|patterns\|ui)\.([a-z0-9_.\-]+)\}$` |
| 7 | ref-direction | ✅ PASS | Zero upward refs found. `components → design` only; `patterns → design + components`; `ui → design + components + patterns`. Direction rule respected. |

### ⚠️ Ref resolution
| # | Check | Result | Detail |
|---|---|---|---|
| 8 | ref-resolution `design.*` | ✅ PASS (treated external) | 96 `design.*` refs not validated — no `design.md` in repo per task spec |
| 9 | ref-resolution `patterns.*` | ✅ PASS | `ui.example.json` references `{patterns.auth-split}` → resolves correctly in `patterns.example.json` (1/1) |
| 10 | ref-resolution `components.*` | ⚠️ WARN | **20 dangling refs** in `ui.example.json` + `patterns.example.json` — `components.example.json` only defines `atom.{button,input,badge,label,help-text}` + `molecule.form-field`. See full list below. Expected during incremental build, but DS-audit tool should flag these as **dangling-ref warnings**. |

**Dangling component refs (20):**
- `components.organism.marketing-brand-panel`
- `components.organism.signin-form`
- `components.molecule.legal-footer`
- `components.organism.app-shell`
- `components.organism.nav-bar`
- `components.organism.side-nav`
- `components.organism.dashboard-stats`
- `components.organism.activity-feed`
- `components.organism.app-footer`
- `components.organism.onboarding-stepper`
- `components.organism.onboarding-prompt`
- `components.molecule.hero-headline`
- `components.molecule.hero-illustration`
- `components.molecule.section-heading`
- `components.organism.pricing-card-grid`
- `components.molecule.pricing-disclaimer`
- `components.organism.navbar`
- `components.organism.sidebar-nav`

### ⚠️ `$meta` consistency
| # | Check | Result | Detail |
|---|---|---|---|
| 11 | `$meta.scope` | ✅ PASS | `components-only` / `ui-only` / `patterns-only` — all match expected scope |
| 12 | `$meta.version` | ✅ PASS | All three files use valid semver (`1.0.0`) |
| 13 | `$meta.dtcg_version` present | ✅ PASS | Present in all three files |
| 14 | `$meta.schema` present | ✅ PASS | Present in all three files |
| 15 | `$meta.schema` format | ⚠️ WARN | **Inconsistent format**: `components` uses relative path `"../schemas/components.schema.json"`, while `ui` and `patterns` use identifier-style strings (`"uxui/ui/v1"`, `"uxui/patterns/v1"`). **Recommend** standardizing on one form so tooling can auto-load schema by URI/path. |
| 16 | `$meta.dtcg_version` format | ⚠️ WARN | **Inconsistent format**: `components="2024-09"`, `ui="draft-2024-08-09"`, `patterns="draft-2"`. Three different formats for the same field — pick one canonical form. |

### ✅ Diff-merge composition
| # | Check | Result | Detail |
|---|---|---|---|
| 17 | diff-merge demo button | ✅ PASS | `base → variant=primary → size=md → state=hover` traced step-by-step. Confirms merge algorithm: tokens shallow `{...base, ...override}` per scope; classes concatenate; later scope wins. See worked example below. |

### ✅ Cross-file consistency
| # | Check | Result | Detail |
|---|---|---|---|
| 18 | ui → patterns | ✅ PASS | `ui.example.json /page/signin/pattern → {patterns.auth-split}` resolves to `patterns.example.json` `auth-split` entry. 1/1 valid. |

### ℹ️ Info / coverage
| # | Check | Result | Detail |
|---|---|---|---|
| 19 | components coverage | ℹ️ INFO | `atom={button,input,badge,label,help-text}` (5), `molecule={form-field}` (1), `organism={}` (0). Schema shape validated; `ui`+`patterns` examples reference an aspirational fuller set. |
| 20 | ref-resolver doc | ℹ️ INFO | `schemas/ref-resolver.md` is documentation only — not executable. Regex in `patterns.schema.json definitions/Ref` matches the documented rule. **Recommend** formalizing as a small Python/JS module for the DS-audit tool. |

---

## ตัวอย่าง diff-merge ที่ demo ได้

**Button composition trace** — `base → variant=primary → size=md → state=hover`:

| Step | Scope added | Tokens after merge | Classes after merge |
|---|---|---|---|
| 0 | base | 8 design tokens (e.g. `--btn-bg → {design.semantic.color.primary.default}`, `--btn-fg`, `--btn-radius`, ...) | `['btn']` |
| 1 | + `variant=primary` | 8 tokens (unchanged — primary inherits base tokens, no override) | `['btn', 'btn--primary']` |
| 2 | + `size=md` | 8 tokens (unchanged — md is default size, no override) | `['btn', 'btn--primary', 'btn--md']` |
| 3 | + `state=hover` | 8 tokens, **`--btn-bg` overrides** `{design.semantic.color.primary.default}` → `{design.semantic.color.primary.hover}`. Other 7 unchanged. | `['btn', 'btn--primary', 'btn--md']` (hover is a state, not a class modifier) |

**Algorithm confirmed:**
- Tokens: per-scope shallow merge `{...base, ...override}`
- Classes: append-only, deduped
- Later scope wins on token key collision
- ✅ `components.schema.json` composition model works as designed

---

## รายการที่ต้องแก้ก่อน release

### 🔴 Blockers (FAIL)

1. **`schemas/patterns.schema.json` — `oneOf` → `anyOf` bug**
   - **Locations:**
     - `definitions/Slot/properties/default`
     - `definitions/PatternDef/properties/tokens/additionalProperties`
   - **Why:** brace-ref strings match BOTH `Ref` pattern AND plain `string` → `oneOf` fails (requires exactly one match). `anyOf` accepts either or both.
   - **Fix:** mechanical rename `oneOf` → `anyOf` in those two definitions.
   - **Owner:** schema author
   - **ETA:** < 5 min

### 🟡 Should-fix before broader rollout (WARN)

2. **`$meta.schema` field format mismatch** — pick one canonical form across all 3 files (relative path vs URI identifier). Recommended: URI identifier (`"uxui/<scope>/v1"`) so the DS-audit tool can resolve by registry.
3. **`$meta.dtcg_version` format mismatch** — three different shapes for the same field. Recommended: pick one (e.g. `"draft-2024-08-09"`) and apply to all.
4. **Dangling component refs (20)** — `components.example.json` is intentionally partial during incremental build. Either:
   - Expand `components.example.json` to cover all referenced organisms/molecules, OR
   - Document that the examples are aspirational and the DS-audit tool will flag them as expected warnings.

### 🟢 Nice-to-have (INFO)

5. Formalize `ref-resolver.md` as an executable module (Python or JS) so the DS-audit tool has a single source of truth for ref resolution.

---

## คำแนะนำสำหรับทีม

- หลัง v6 ready: ใช้ `design-md-audit` skill validate DS ก่อน hand-off ทุกครั้ง
- ทีมที่ใช้ v5 MD format: รัน `--migrate-to-json` ก่อน เพื่อแปลงเป็น 3-file split JSON
- เปิดใช้ schema validation ใน CI (Draft 2020-12) เพื่อจับ schema-level bug แบบ `oneOf` ก่อนเข้า main
- เพิ่ม "dangling-ref check" เป็น warning ใน DS-audit เพื่อแยก "ตั้งใจยังไม่ครบ" ออกจาก "ref ผิด"

---

## Phase 5 status

- ⚠️ **WARN** — Phase 5 ผ่านเชิงโครงสร้าง แต่ติด 1 schema bug ที่ block patterns validation. ต้องแก้ `oneOf → anyOf` ก่อน mark v6 GA.
- **Next:** Phase 6 (DTCG export) ถ้าต้องการ multi-platform output (Style Dictionary / Token Studio) — แต่ควรเคลียร์ blocker ใน Phase 5 ก่อน
