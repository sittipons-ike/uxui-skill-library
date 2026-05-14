# Design Agent Suite — คู่มือติดตั้งสำหรับทีม Designer

> ใช้เวลาประมาณ 30 นาที | ไม่ต้องเขียน code | ทำครั้งเดียวใช้ได้ตลอด

---

## ภาพรวม — ต้องทำ 4 อย่าง

```
1. ติดตั้ง Node.js
2. ติดตั้ง Claude Code Desktop
3. ต่อ Figma เข้า Claude (แก้ไฟล์ config)
4. ลง Skills ของทีม (รัน setup.sh)
```

---

## ขั้นตอนที่ 1 — ติดตั้ง Node.js

Node.js คือโปรแกรมที่ช่วยให้ Claude ต่อ Figma ได้

1. เปิด Browser ไปที่ **nodejs.org**
2. กดปุ่ม **LTS** (ฝั่งซ้าย) → Download
3. เปิดไฟล์ที่ดาวน์โหลด → กด Continue ไปเรื่อยๆ → Install
4. ตรวจสอบว่าติดตั้งสำเร็จ: เปิด **Terminal** แล้วพิมพ์

```
node -v
```

ถ้าขึ้นเลข เช่น `v22.0.0` แสดงว่าสำเร็จ

---

## ขั้นตอนที่ 2 — ติดตั้ง Claude Code Desktop

1. เปิด Browser ไปที่ **claude.ai/download**
2. กด Download สำหรับ Mac
3. ลาก Claude Code ไปไว้ใน Applications
4. เปิดแอป → Sign in ด้วย account ทีม

เปิดแล้วเห็นหน้าต่างสีดำ — ถูกต้องแล้ว ปิดทิ้งไว้ก่อน

---

## ขั้นตอนที่ 3 — ต่อ Figma เข้า Claude

### 3a — สร้าง Figma Token

1. เปิด Figma → คลิกรูปโปรไฟล์ด้านบนขวา → **Settings**
2. เลือกแท็บ **Security**
3. เลื่อนลงหา **Personal access tokens** → กด **Generate new token**
4. ตั้งชื่อ เช่น `claude`
5. ติ๊ก Scope ให้ครบ 4 อัน:

| Scope | สิทธิ์ |
|---|---|
| File content | Read |
| File versions | Read |
| Variables | Read |
| Comments | Read and write |

6. กด Generate → **Copy token ทันที** จะเห็นแค่ครั้งเดียว

### 3b — แก้ไฟล์ Config ของ Claude

เปิด **Finder** → กด `Cmd + Shift + G` → พิมพ์ path นี้ → กด Go:

```
~/Library/Application Support/Claude
```

เปิดไฟล์ชื่อ **`claude_desktop_config.json`** ด้วย TextEdit

> ถ้าไม่มีไฟล์นี้: สร้างไฟล์ใหม่ใน TextEdit (`Cmd + N`) แล้ว Save As ชื่อ `claude_desktop_config.json` ใน folder นั้น

ลบเนื้อหาเดิมออกทั้งหมด แล้ววางข้อความนี้แทน:

```json
{
  "mcpServers": {
    "figma-console": {
      "command": "npx",
      "args": ["-y", "figma-console-mcp@latest"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "วาง_token_ที่ copy มาจาก_Figma_ตรงนี้",
        "ENABLE_MCP_APPS": "true"
      }
    }
  }
}
```

แทนที่ `วาง_token_ที่ copy มาจาก_Figma_ตรงนี้` ด้วย token จาก 3a

บันทึกไฟล์ (`Cmd + S`) → **ปิดแล้วเปิด Claude Code Desktop ใหม่**

### 3c — ตรวจสอบว่าต่อ Figma สำเร็จ

ใน Claude Code พิมพ์:
```
/mcp
```

ถ้าเห็น **figma-console** ขึ้นสถานะ Connected — พร้อมใช้แล้ว

---

## ขั้นตอนที่ 4 — ลง Skills ของทีม

เปิด **Terminal** → `cd` เข้าโฟลเดอร์ที่ดาวน์โหลด repo นี้มา แล้วรัน:

```
bash setup.sh
```

รอสักครู่ ถ้าขึ้น `✅ เสร็จแล้ว!` แสดงว่า Skills พร้อมใช้งาน

> **ไม่รู้จัก git?** กด **Code → Download ZIP** บน GitHub → แตกไฟล์ → เปิด Terminal → `cd` ไปที่โฟลเดอร์ที่แตกแล้ว → รัน `bash setup.sh`

---

## Skills ที่ได้มา

| ไฟล์ | ใช้ทำอะไร |
|---|---|
| `audit-ui.md` | ตรวจ Figma ก่อน handoff |
| `ux-skill.md` | วาง User Flow + IA |
| `ui-skill.md` | map component + token |
| `ux-writing.md` | เขียน / rewrite copy |

---

## เริ่มใช้งาน

เปิด Claude Code Desktop แล้วพิมพ์ตาม use case:

**ตรวจ Figma ก่อน handoff**
```
Audit นี้: [วาง Figma link]
ตรวจ DS compliance และ pin comment Critical issues บน Figma
```

**วาง UX Blueprint ใหม่**
```
ช่วยวาง UX Blueprint สำหรับฟีเจอร์ [ชื่อ]
User goal: [เป้าหมาย user]
Business goal: [เป้าหมายทีม]
```

**Rewrite copy บนหน้าจอ**
```
Rewrite copy ใน Figma นี้: [วาง Figma link]
โทน: [professional / friendly / urgent]
```

---

## อัปเดต Skills เมื่อทีม lead เพิ่ม skill ใหม่

```
git pull
bash setup.sh
```

สองคำสั่งนี้ดึง skill ใหม่ลงเครื่องให้อัตโนมัติ

---

## อัปเดต Figma MCP

ไม่ต้องทำอะไร — ระบบดึงเวอร์ชันล่าสุดอัตโนมัติทุกครั้งที่เปิด Claude Desktop

---

## ติดต่อ

ติดตั้งไม่ได้ หรือ Figma ไม่ Connected → แจ้ง @sittipon (design@7solutions.co.th)
