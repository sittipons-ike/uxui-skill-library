# คู่มือ UXUI Skill Library (สำหรับทีม)

> ชุดสกิล Claude Code ของทีม UXUI · 29 สกิล · Owner: design@7solutions.co.th
> Repo: github.com/sittipons-ike/uxui-skill-library

---

## 1. ลงครั้งแรก (แนะนำ: global)

**ลงครั้งเดียว ทุก project ใช้ได้:**
```
npx skills add sittipons-ike/uxui-skill-library -g
```

- `-g` = ลงที่ระดับเครื่อง (user-level) → ทุก project เห็นเลย ไม่ต้องลงซ้ำแต่ละ project
- ✅ ไม่มีปัญหา project ดึงเวอร์ชันเก่า

**ถ้าเคยลงแบบ project (มีโฟลเดอร์ `.agents/` ใน project)** → ลบ `.agents/` ในแต่ละ project ทิ้ง ไม่งั้นมันทับ global
⚠️ `~/.agents` (ที่ home) ห้ามลบ — เป็นตัว global กลาง

**ถ้าต้องล็อกเวอร์ชันเฉพาะบาง project** (เช่น production) → ตัด `-g` ออก

---

## 2. วิธีอัพเดตสกิล

```
npx skills add sittipons-ike/uxui-skill-library -g
```

⚠️ **ต้องรันเองทุกครั้ง** ที่ repo มีอัพเดต — มันไม่ auto-update จาก GitHub

---

## 3. มีสกิลอะไรบ้าง (29 สกิล)

### กลุ่ม UX / UI
| สกิล | ทำอะไร |
|---|---|
| check-setup | เช็กว่าเครื่องพร้อมไหม + แนะนำสกิลแรก |
| ux-strategist | วาง user flow + information architecture |
| ui-implementation-specialist | map component + token จาก blueprint |
| ux-writer | เขียน/แก้ microcopy บน UI |
| modal-writer | เขียน/รีวิว modal ภาษาไทย (6 ประเภท) |
| masterprompt | แปลง idea คร่าวๆ เป็น prompt ที่ดี |
| figma-audit-ui | ตรวจ Figma ตรง DS ไหม |
| audit | ตรวจคุณภาพ UI (a11y/perf/responsive) |
| user-personas | สร้าง persona จาก research |

### กลุ่ม Product & Planning
| สกิล | ทำอะไร |
|---|---|
| prd | สร้าง PRD (3 แบบ: ผู้บริหาร/dev/AI) |
| interview-me | ถามทีละคำจนเข้าใจ intent จริง ~95% |
| notion-planning | วางแผนงานลง Notion |
| spec-driven-development | เขียน spec ก่อนโค้ด |
| shipping-and-launch | checklist ก่อน launch |

### กลุ่ม Engineering
| สกิล | ทำอะไร |
|---|---|
| frontend-ui-engineering | best practice การเขียน UI |
| browser-testing-with-devtools | เทส UI ด้วย DevTools |

### กลุ่ม Design System (หัวใจ)
| สกิล | ทำอะไร |
|---|---|
| design-builder | สร้าง design.md (สี/ฟอนต์/token) |
| design-icon-builder | เลือก icon + ดึง SVG |
| design-component-builder | สร้าง component (JSON + CSS + HTML) |
| design-ui-builder | สร้าง page + pattern |
| design-md-audit | ตรวจ DS ทั้งระบบ |
| design-styleguide | รวม component เป็นหน้า styleguide |
| design-remix | ผสม design จากหลายแบรนด์ |
| design-export-dtcg | export token ข้าม platform (iOS/Android/Flutter/web) |

### กลุ่ม Figma
| สกิล | ทำอะไร |
|---|---|
| figma-push-tokens | ส่ง token ขึ้น Figma Variables |
| figma-push-components | ส่ง component ขึ้น Figma |
| figma-rename-tokens | จัดชื่อ Figma variable ให้ตรง DS |

### กลุ่ม Integration (ต้อง setup ก่อน)
| สกิล | ต้องมี |
|---|---|
| email-summarizer | Gmail MCP + Lark webhook |
| jira-tracker | Atlassian MCP + Lark webhook |

---

## 4. แต่ละสกิลรับอะไร ออกอะไร (Design System chain)

| ลำดับ | สกิล | อ่าน (input) | ออก (output) |
|---|---|---|---|
| 1 | design-builder | brand info · docs/brand/ · asset จริงใน public/ | design.md (token + mood + dials) |
| 2 | design-icon-builder | design.md (mood) | icons/*.svg + iconography block |
| 3 | design-component-builder | design.md + TASTE gate | components.json + tokens.css + HTML |
| 4 | design-ui-builder | design.md + components.json + TASTE (recipes/dials) | ui.json + patterns.json + pages/ |
| ตรวจ | design-md-audit | ทุกไฟล์ข้างบน | รายงาน validate (schema/refs/WCAG/naming) |
| รวม | design-styleguide | components/*.html + pages/*.html | styleguide.html |
| export | design-export-dtcg | design.md + components.json | tokens.json + Style Dictionary |

---

## 5. Pipeline — ทำงานเรียงยังไง

```
brand + PRD + asset
   ↓ design-builder            → design.md (สี/ฟอนต์/token + dials)
   ↓ design-icon-builder       → icons/
   ↓ design-component-builder  → components.json + CSS + HTML   (ผ่าน TASTE gate)
   ↓ design-ui-builder         → ui.json + patterns.json + pages/  (ผ่าน TASTE recipes)
   ↓ design-md-audit           → ตรวจทั้งหมด
   ↓ styleguide / export / figma-push → ส่งออก
```

**ทิศทาง:** ไหลลงล่างอย่างเดียว (ui → patterns → components → design) — ห้ามอ้างย้อนขึ้น

---

## 6. 3 ชั้นที่แยกหน้าที่กัน (สำคัญ)

| ไฟล์ | คุมอะไร |
|---|---|
| **design.md** | สี · ฟอนต์ · token (หน้าตา) |
| **TASTE.md** | การจัดวาง · รสนิยม (กัน UI โหล) — มี recipes ~50 ท่า + dials |
| **docs/brand/** | การตัดสินใจดีไซน์ (mood/style) — ไม่ใช่ PRD |

**หลักคิด PRD:** บอก "ปัญหา + ข้อจำกัดที่มีเหตุผล" ไม่ใช่ "หน้าตาต้องเป็นยังไง"
กฎ: ถ้าเขียนเป็น "Must" แล้วตอบ "ทำไม" ไม่ได้ใน 1 ประโยค → ย้ายไป docs/brand/

---

_อ้างอิงเต็ม: README ใน repo · docs/design-system-structure.md (โครงสร้าง DS ละเอียด)_
