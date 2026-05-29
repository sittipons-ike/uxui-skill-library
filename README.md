# UXUI library skill

Skills และคู่มือสำหรับทีม Designer ใช้ Claude Code ร่วมกับ Figma

## Workflow — Claude ใช้ Skill ยังไง

```mermaid
graph TD
    subgraph Setup["🔧 Setup (ครั้งเดียว)"]
        S1[Terminal: npx skills add ...] --> S2[Download skills จาก GitHub]
        S2 --> S3[~/.claude/skills/]
    end

    subgraph Usage["🎯 Usage (ทุกครั้งที่ใช้งาน)"]
        U1[User พิมพ์ prompt<br/>ใน Claude Code] --> U2{Claude วิเคราะห์<br/>เจอ trigger ของ skill?}
        U2 -->|No| U3[Claude ตอบปกติ]
        U2 -->|Yes| U4[โหลด SKILL.md<br/>จาก ~/.claude/skills/]
        U4 --> U5{มี Pre-flight check?<br/>เช่น email-summarizer, jira-tracker}
        U5 -->|Yes| U6[AskUserQuestion:<br/>Setup ครบหรือยัง?]
        U5 -->|No| U8[Execute skill steps]
        U6 -->|ครบ| U8
        U6 -->|ยังไม่ครบ| U7[แสดง setup guide<br/>+ หยุดทำงาน]
        U8 --> U9[ใช้ MCP tools<br/>Figma / Gmail / Atlassian / etc.]
        U9 --> U10[Output ส่งกลับ user]
    end

    S3 -.ใช้ skills ที่ติดตั้งไว้.-> U4
```

---

## ติดตั้ง

### วิธีที่ 1 — Claude Code Plugin (แนะนำ)

ใช้ได้ในทุก environment แม้ network บล็อก npm:

```
claude plugin marketplace add https://github.com/sittipons-ike/uxui-skill-library
claude plugin install uxui-skills
```

### วิธีที่ 2 — npx (ถ้า network เปิด npm)

```
npx skills add sittipons-ike/uxui-skill-library
```

> อยากดูคู่มือฉบับเต็ม (ลง Node.js, ต่อ Figma MCP, ฯลฯ) → อ่าน **[ONBOARDING.md](ONBOARDING.md)**

## Skills ที่มี

**พร้อมใช้ทันที**

| Skill | หน้าที่ |
|---|---|
| `setup-helper` | Guide ทีมตอน install ครั้งแรก — เช็ก prerequisites + แนะนำ skill แรก |
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

**Plugin:**
```
claude plugin marketplace update
```

**npx:**
```
npx skills add sittipons-ike/uxui-skill-library
```
