# UXUI library skill

Skills และคู่มือสำหรับทีม Designer ใช้ Claude Code ร่วมกับ Figma

## ติดตั้ง (คำสั่งเดียวจบ)

เปิด Terminal แล้วรัน:

```
npx skills add sittipons-ike/uxui-agent-library
```

> ครั้งแรกอาจถามขอ permission ติดตั้ง package `skills` — กด `y` ได้เลย

อยากดูคู่มือฉบับเต็ม (ลง Node.js, ต่อ Figma MCP, ฯลฯ) → อ่าน **[ONBOARDING.md](ONBOARDING.md)**

## Skills ที่มี

**พร้อมใช้ทันที**

| Skill | หน้าที่ |
|---|---|
| `audit-ui` | ตรวจ Figma DS compliance ก่อน handoff |
| `ux-skill` | วาง User Flow + Information Architecture |
| `ui-skill` | Map component + design token จาก Blueprint |
| `ux-writing` | เขียน / rewrite microcopy บน UI |
| `masterprompt` | แปลง idea คร่าวๆ เป็น structured prompt |
| `notion-planning` | วางแผนงานลง Notion |
| `prd` | สร้าง Product Requirements Document |
| `audit` | ตรวจ interface quality ด้าน accessibility, performance, responsive |

**ต้อง setup ก่อนใช้** ⚠️

| Skill | ต้องการ |
|---|---|
| `email-summarizer` | Gmail MCP + (optional) Lark webhook |
| `jira-tracker` | Atlassian MCP + Lark webhook + config Jira project |

> skill ที่มี ⚠️ จะแสดง checklist setup ให้กรอกก่อนทุกครั้งที่รัน

**ตัวเสริม (ติดตั้งแยก)**

animate, polish, colorize, critique, audit, adapt, arrange, bolder, clarify, distill, delight, extract, frontend-design, harden, normalize, onboard, optimize, overdrive, quieter, teach-impeccable, typeset

ติดตั้งด้วย:
```
npx skills add pbakaus/impeccable
```

## อัปเดต Skills

รันคำสั่งเดิมซ้ำเพื่อดึงเวอร์ชันล่าสุด:

```
npx skills add sittipons-ike/uxui-agent-library
```
