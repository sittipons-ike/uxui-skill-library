# Brand Book — <Product Name>

> วางไฟล์นี้ที่ `docs/brand/brand-book.md` ของโปรเจกต์ · `design-builder` Phase 0a อ่านไฟล์นี้
> เป็นที่อยู่ของ **การตัดสินใจดีไซน์** (mood/style/การใช้สี) — ที่ไม่ควรอยู่ใน PRD

_Last updated: <YYYY-MM-DD> · Owner: <designer/PM>_

## Mood & tone
- **Primary mood:** `<bold-tech | friendly-warm | premium-editorial | playful-vivid | technical-dev | calm-focused>`
- **Secondary (optional):** `<...>`
- **Voice / personality:** <2-3 คำ เช่น trustworthy, concise>
- **สื่ออารมณ์อะไร / ไม่สื่ออะไร:** <"ควรรู้สึก...  ไม่ควรรู้สึก...">

## Colour usage (การตัดสินใจ ไม่ใช่ค่า hex — ค่าไปอยู่ palette.md)
- **Light / dark:** <light only | dark only | both + toggle | แถบสลับโทน>
- **Accent ใช้ยังไง:** <ทองใช้เป็นปุ่ม/badge/เส้น? · เป็นสีจริงหรือ decorative?>
- ⚠️ ถ้า "decorative-only" เพราะ contrast ไม่ผ่าน → เขียนว่าเป็น **ผลของการตรวจ** ไม่ใช่กฎแบรนด์

## Asset inventory (สำคัญสุด — list ทุกไฟล์ + role)

> `design-builder` ต้อง **เปิดดูไฟล์ visual จริง** ก่อนเขียน design.md — อย่าให้ prose บังของจริง

| path (รวม subfolder ลึก) | คืออะไร | role |
|---|---|---|
| `public/logo/logo.svg` | โลโก้หลัก | logo |
| `public/home/banner/Hero (desktop).png` | hero banner สำเร็จ | **colour source of truth** |
| `public/home/why/section.png` | section สำเร็จ | composition reference |
| `public/reference/old.jpg` | ของเก่า | archive-unused |

**role มี 4 แบบ:** `colour source of truth` · `composition reference` · `logo` · `archive-unused`

## Conflicts (ยังไม่ตัดสิน — ต้องถามคน)
> ถ้า doc ขัดกับ asset → เขียนที่นี่แบบ **UNRESOLVED** ห้ามตัดสินแทนแล้วเขียนเป็นข้อสรุป

- ⚠️ `<เรื่อง>` — doc บอก `<X>` แต่ asset `<file>` แสดง `<Y>` → **UNRESOLVED, needs human**
