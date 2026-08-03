# PRD Checklist — ก่อนส่งให้ AI ทำงานต่อ

> เช็คก่อนปล่อย PRD ให้ design chain (design-builder → ... → design-ui-builder)
> ที่มา: การทดลอง Taste บนโปรเจกต์ Rubstang (31 ก.ค. 2569) — ต้นตองานเพลน = **input ผิด** ไม่ใช่ AI

## Constraint discipline
```
□ ทุกข้อในหมวด Must มีเหตุผลกำกับ 1 ประโยค
□ ไม่มีคำ mood/style ใน Must (premium, minimal, bold, editorial, playful …)
□ ไม่มีค่าสี hex / ชื่อฟอนต์ ใน PRD → ไปอยู่ docs/brand/palette.md, typography.md
□ ไม่อ้างไฟล์ที่ยังไม่มีจริง (หรืออ้างแล้วต้องเขียนกำกับ "(not yet created)")
```

## Brand docs พร้อม
```
□ มี docs/brand/ ครบ 3 ไฟล์: brand-book.md · palette.md · typography.md
□ brand-book.md มี "asset inventory" ที่ระบุ:
     - path ทุกไฟล์ (รวม subfolder ลึก เช่น public/home/)
     - อันไหน = colour source of truth
     - อันไหน = composition reference
     - อันไหน = archive / ไม่ใช้แล้ว
□ ทุกสีใน palette.md มีค่า hex จริง (ไม่มีชื่อลอยๆ ที่ไม่มีค่า)
```

## Conflict & risk
```
□ ถ้ามี conflict เอกสาร↔asset → เขียนเป็น "UNRESOLVED, needs human" (ห้ามตัดสินแทน)
□ ระบุ "ความเสี่ยงที่กระทบดีไซน์" อย่างน้อย 1 ข้อ + ที่มา
     (ข้อนี้มักเป็น design brief ที่ดีที่สุด — เช่น "ความน่าเชื่อถือคือความเสี่ยงสูงสุด")
□ จุดขายของ product ถูกระบุว่าต้องแสดงออกทาง UI ยังไง
```

## กฎข้อเดียวที่จำง่ายสุด
> **ถ้าเขียนเป็น "Must" แล้วตอบ "ทำไม" ไม่ได้ใน 1 ประโยค → มันคือ preference ไม่ใช่ constraint → ย้ายไป docs/brand/**

## หลักคิด
> บอก **ปัญหา** แล้วให้ AI หาทางแก้ → ได้ผลดีกว่า **สั่งคำตอบ** (หน้าตาต้องเป็นยังไง)
