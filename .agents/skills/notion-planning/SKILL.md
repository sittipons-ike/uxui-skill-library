---
name: notion-planning
description: สร้างระบบ planning ใน Notion แบบ 2-level hierarchy (Groups + Tasks) พร้อม Auto-updating Progress Bar — ใช้เมื่อ user ต้องการวางแผนงานลง Notion, สร้าง task tracker, หรือทำ project plan ที่มี nested structure
---

# Notion Planning Template

> Template สำหรับสร้างระบบ planning ใน Notion แบบ 2-level hierarchy (Groups + Tasks) พร้อม Auto-updating Progress Bar

---

## Concept

โครงสร้าง 2 ชั้น — **Groups** (หน่วยงานใหญ่) กับ **Tasks** (งานย่อย) โดย Groups จะดึง progress และ status จาก Tasks อัตโนมัติ

ตั้งชื่อได้ตามบริบท เช่น:
- Groups = Epics / Phases / Features / Streams / Milestones
- Tasks = Tasks / Stories / Actions / Items

---

## Database Structure

### Tasks DB

| Property | Type | Formula / Config |
|---|---|---|
| `Name` | Title | — |
| `Status` | Status | Backlog / In Progress / Review / Done |
| `Is Done` | Formula | `if(prop("Status") == "Done", 1, 0)` |
| `Status Score` | Formula | `if(prop("Status") == "Backlog", 0, if(prop("Status") == "In Progress", 50, if(prop("Status") == "Review", 80, if(prop("Status") == "Done", 100, 0))))` |
| `Progress Bar` | Formula | ดูด้านล่าง |
| `Related to Groups` | Relation | dual_property ↔ Groups DB |

**Tasks Progress Bar formula:**
```
if(prop("Status") == "Backlog", "░░░░░░░░░░  0%",
  if(prop("Status") == "In Progress", "█████░░░░░  50%",
    if(prop("Status") == "Review", "████████░░  80%",
      if(prop("Status") == "Done", "██████████  100%", "░░░░░░░░░░  0%"))))
```

---

### Groups DB

| Property | Type | Config |
|---|---|---|
| `Name` | Title | — |
| `Status` | Status | Not Started / In Progress / Done |
| `Tasks` | Relation | dual_property ↔ Tasks DB |
| `Done Count` | Rollup | Relation: Tasks / Property: Is Done / Function: Sum |
| `Total Count` | Rollup | Relation: Tasks / Property: Name / Function: Count values |
| `Score Sum` | Rollup | Relation: Tasks / Property: Status Score / Function: Sum |
| `Progress Bar` | Formula | ดูด้านล่าง |
| `Auto Status` | Formula | ดูด้านล่าง |

**Groups Progress Bar formula (weighted):**
```
if(prop("Total Count") == 0, "░░░░░░░░░░  0%",
  slice("██████████", 0, round(prop("Score Sum") / prop("Total Count") / 10))
  + slice("░░░░░░░░░░", 0, 10 - round(prop("Score Sum") / prop("Total Count") / 10))
  + "  " + format(round(prop("Score Sum") / prop("Total Count"))) + "%")
```

**Auto Status formula:**
```
if(prop("Total Count") == 0, "⚪ Not Started",
  if(prop("Score Sum") == prop("Total Count") * 100, "✅ Done",
    if(prop("Score Sum") == 0, "⚪ Not Started", "🔵 In Progress")))
```

---

## Weight Mapping (Status → Score)

| Task Status | Score | Progress Bar |
|---|---|---|
| Backlog | 0 | ░░░░░░░░░░  0% |
| In Progress | 50 | █████░░░░░  50% |
| Review | 80 | ████████░░  80% |
| Done | 100 | ██████████  100% |

Group progress = average score ของ Tasks ทั้งหมดที่ link อยู่

---

## Auto-Update Chain

```
Task Status เปลี่ยน
  → Status Score (formula) อัพเดท
    → Score Sum rollup ใน Group อัพเดท
      → Progress Bar formula ใน Group อัพเดท
      → Auto Status formula ใน Group อัพเดท
```

ทุกอย่าง real-time ไม่ต้อง manual update

---

## Overview Page Structure (แนะนำ)

```
[Header / Objective callout]
---
[Milestone หรือ Timeline callout]
---
## 📊 Progress Summary
[Tasks child_database — embedded]
---
[Other content]
```

**วิธีเพิ่ม heading via API:**
```bash
curl -X PATCH "https://api.notion.com/v1/blocks/{PAGE_ID}/children" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "children": [{
      "object": "block",
      "type": "heading_2",
      "heading_2": {
        "rich_text": [{"type": "text", "text": {"content": "📊 Progress Summary"}}]
      }
    }]
  }'
```

---

## Notion API — Setup Commands

### สร้าง formula properties ใน Tasks DB
```bash
curl -X PATCH "https://api.notion.com/v1/databases/{TASKS_DB_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {
      "Is Done": {
        "formula": { "expression": "if(prop(\"Status\") == \"Done\", 1, 0)" }
      },
      "Status Score": {
        "formula": { "expression": "if(prop(\"Status\") == \"Backlog\", 0, if(prop(\"Status\") == \"In Progress\", 50, if(prop(\"Status\") == \"Review\", 80, if(prop(\"Status\") == \"Done\", 100, 0))))" }
      }
    }
  }'
```

### สร้าง Rollup properties ใน Groups DB
```bash
curl -X PATCH "https://api.notion.com/v1/databases/{GROUPS_DB_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {
      "Done Count": {
        "rollup": {
          "relation_property_name": "Tasks",
          "rollup_property_name": "Is Done",
          "function": "sum"
        }
      },
      "Total Count": {
        "rollup": {
          "relation_property_name": "Tasks",
          "rollup_property_name": "Name",
          "function": "count_values"
        }
      },
      "Score Sum": {
        "rollup": {
          "relation_property_name": "Tasks",
          "rollup_property_name": "Status Score",
          "function": "sum"
        }
      }
    }
  }'
```

### Link Tasks กับ Group
```bash
curl -X PATCH "https://api.notion.com/v1/pages/{GROUP_PAGE_ID}" \
  -H "Authorization: Bearer {TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "properties": {
      "Tasks": {
        "relation": [
          {"id": "{TASK_PAGE_ID_1}"},
          {"id": "{TASK_PAGE_ID_2}"}
        ]
      }
    }
  }'
```

---

## Key Constraints

- **Status property ไม่รองรับ formula** — ต้องใช้ `Auto Status` เป็น formula property แยก (แสดงข้อความ ไม่ใช่ status จริง)
- **Relation cell ใน table** — click เปิด relation editor ไม่ใช่ navigate → ต้อง hover → ↗ เพื่อเปิด linked page
- **Rollup ต้องชี้ถูก relation** — ถ้า DB มีหลาย relation ต้องระวัง rollup ใช้ property ถูกตัว
- **dual_property relation** — PATCH Tasks ใน Group จะ sync กลับไป Tasks DB อัตโนมัติ

---

## Trigger Conditions

ใช้ skill นี้เมื่อ user พูดถึง:
- "สร้าง planning ใน Notion"
- "tracking งานแบบ group + tasks"
- "Progress Bar ที่ auto-update"
- "Notion relation + rollup"
- "weighted progress ตาม status"
- project planning / sprint / roadmap / milestone ใน Notion
