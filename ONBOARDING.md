# Design Agent Suite — คู่มือติดตั้งสำหรับทีม Designer

> ใช้เวลาประมาณ 30 นาที | ไม่ต้องเขียน code | ทำครั้งเดียวใช้ได้ตลอด

---

## 🚀 วิธีง่ายสุด — ใช้ /check-setup

ถ้าติดตั้ง Claude Code Desktop + plugin แล้ว (ขั้น 2 + ขั้น 4):

```
พิมพ์ในChat: /check-setup
```

`/check-setup` จะ:
- ✅ Auto-detect ว่าเครื่องคุณลงอะไรไปแล้วบ้าง
- ✅ แสดง diagnostic ว่าขาดอะไร
- ✅ Guide ติดตั้งทีละ step ตามที่ขาด
- ✅ ติดตั้ง working rules ของทีมให้
- ✅ แนะนำ skill แรกให้ลอง

**เริ่มต้นจาก zero ทำตามขั้นตอน manual ข้างล่างนี้:**

---

## ภาพรวม — ต้องทำ 5 อย่าง

```
1. ติดตั้ง Node.js + Git
2. ติดตั้ง Claude Code Desktop
3. ต่อ Figma เข้า Claude (แก้ไฟล์ config)
4. ลง Team Rules (กฎกลาง — สำคัญสุด, ต้องลงก่อน)
5. ลง Skills ของทีม (29 skills) → /check-setup
```

> **ทำไม Rules ก่อน Skills:** Rules = guardrails (กัน Claude เดา / leak secret / บอก "เสร็จ" ทั้งที่ยังไม่ verify). ติด skills โดยไม่มี rules = AI ลุยเดาในงานสำคัญ

> **ตัวเสริม (ไม่บังคับ):** ลง Design Skills จาก impeccable.style — เพิ่ม skills ด้าน visual design เช่น animate, polish, colorize

---

## ขั้นตอนที่ 1 — ติดตั้ง Node.js + Git

### 1a — ติดตั้ง Node.js

Node.js คือโปรแกรมที่ช่วยให้ Claude ต่อ Figma ได้

1. เปิด Browser ไปที่ **nodejs.org**
2. กดปุ่ม **LTS** (ฝั่งซ้าย) → Download
3. เปิดไฟล์ที่ดาวน์โหลด → กด Continue ไปเรื่อยๆ → Install
4. ตรวจสอบว่าติดตั้งสำเร็จ: เปิด **Terminal** แล้วพิมพ์

```
node -v
```

ถ้าขึ้นเลข เช่น `v22.0.0` แสดงว่าสำเร็จ

### 1b — ติดตั้ง Git (Command Line Tools)

Git ใช้สำหรับให้ Claude Code จัดการ session — ถ้าไม่ลง Claude Code จะขึ้น popup "Install Git"

1. เปิด **Terminal** (Spotlight: `Cmd + Space` → พิมพ์ `Terminal` → Enter)
2. copy คำสั่งนี้วางใน Terminal แล้วกด Enter:

```
xcode-select --install
```

3. จะมี popup ขึ้นมาให้กด **Install** → รอจนเสร็จ (5-10 นาที)
4. ตรวจสอบ: ใน Terminal พิมพ์

```
git --version
```

ถ้าขึ้นเลข เช่น `git version 2.39.0` แสดงว่าสำเร็จ

> ถ้าใน Claude Code มี popup **"Install Git"** ขึ้นมา — ทำตามขั้นตอนนี้ก่อน แล้วกลับมาเปิด Claude Code ใหม่

---

## ขั้นตอนที่ 2 — ติดตั้ง Claude Code Desktop

1. เปิด Browser ไปที่ **claude.ai/download**
2. กด Download สำหรับ Mac
3. ลาก Claude Code ไปไว้ใน Applications
4. เปิดแอป → Sign in

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

## ขั้นตอนที่ 4 — ติดตั้ง Team Rules (สำคัญสุด — ทำก่อน Skills)

**Team Rules คืออะไร** — กฎกลาง 13 ข้อที่ Claude apply ทุก session ทุก project:

| Layer | Rules |
|---|---|
| 🔒 Security | 1-6 (secret handling, scan ก่อน commit, rotation) |
| 🎯 Engineering | 7-11 (NO MAGIC, VERIFY BEFORE DONE, DISSENT, SCOPE, R0/R1/R2) |
| 📚 Persistence | 12-13 (per-project `MEMORY.md` + `spec.md` — กันลืม / กัน /clear) |

**ทำไมต้องลงก่อน Skills** — Rules = guardrails กัน Claude เดา / ลืม / commit secret / บอก "เสร็จ" ทั้งที่ยังไม่ตรวจ. ติด skills โดยไม่มี rules = AI ลุยเดาในงานสำคัญ

### ติดตั้ง (ทำครั้งเดียว)

```bash
git clone https://github.com/sittipons-ike/uxui-skill-library.git
cd uxui-skill-library
bash team-rules/install-team-rules.sh
```

Script จะ:
1. Backup `~/.claude/CLAUDE.md` เดิมไว้ (ถ้ามี)
2. Symlink `~/.claude/team-rules.md` → `<repo>/team-rules/CLAUDE.md`
3. ใส่ `@~/.claude/team-rules.md` ใน `~/.claude/CLAUDE.md` (idempotent)

### Verify

```bash
head -5 ~/.claude/CLAUDE.md          # ต้องเห็นบรรทัด @~/.claude/team-rules.md
readlink ~/.claude/team-rules.md     # ต้องชี้ไปที่ repo team-rules/CLAUDE.md
```

> **Personal customization** — ใส่ section ของตัวเองท้ายไฟล์ `~/.claude/CLAUDE.md` ได้ — ไม่หายตอน git pull (เพราะแก้คนละไฟล์)

---

## ขั้นตอนที่ 5 — ลง Skills ของทีม (29 skills)

หลัง rules ติดเรียบร้อย ติด skills ต่อ — เลือก 1 วิธี:

**วิธีที่ 1 — npx (แนะนำ — เร็ว, update บ่อย):**
```bash
npx skills add sittipons-ike/uxui-skill-library
```

**วิธีที่ 2 — Claude Code Plugin (ใช้เมื่อ npx ไม่ได้):**

เปิด **Claude Code Desktop** แล้วพิมพ์ทีละบรรทัด (Enter หลังแต่ละคำสั่ง):
```
claude plugin marketplace add https://github.com/sittipons-ike/uxui-skill-library
claude plugin install uxui-skills
```
รอจนขึ้น Installed — ได้ทุก skill อัตโนมัติ

### Verify ทั้งหมด

```
/check-setup
```
จะมี checklist และแนะนำ skill แรกให้ลอง

---

## ตัวเสริม — Design Skills จาก impeccable.style (ไม่บังคับ)

เพิ่มความสามารถด้าน visual design เช่น animate, polish, colorize, critique, typeset ฯลฯ

1. เปิด **Terminal** (Spotlight: `Cmd + Space` → พิมพ์ `Terminal` → Enter)
2. copy คำสั่งนี้วางใน Terminal แล้วกด Enter:

```
npx skills add pbakaus/impeccable
```

3. รอจนเสร็จ (1–2 นาที) — ได้ทุก skill อัตโนมัติ

---

## Skills ที่ได้มา

**จาก repo นี้ (npx skills add):**

| ไฟล์ | ใช้ทำอะไร |
|---|---|
| `audit-ui.md` | ตรวจ Figma ก่อน handoff |
| `ux-skill.md` | วาง User Flow + IA |
| `ui-skill.md` | map component + token |
| `ux-writing.md` | เขียน / rewrite copy |
| `masterprompt.md` | แปลง input คร่าวๆ เป็น structured prompt |
| `notion-planning.md` | วางแผนงานลง Notion |
| `email-summarizer.md` | สรุป + draft email |
| `jira-tracker.md` | manage Jira issues |

**จาก impeccable.style (ขั้นตอนที่ 4):**
animate, polish, colorize, critique, audit, adapt, arrange, bolder, clarify, distill, delight, extract, frontend-design, harden, normalize, onboard, optimize, overdrive, quieter, teach-impeccable, typeset

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

## อัปเดต Skills + Rules

**วิธีเร็ว (รวบ skills + rules ใน 1 command):**
```bash
cd uxui-skill-library && bash update.sh
```

Script ทำให้ทั้ง:
1. `git pull` — team-rules sync
2. `npx skills add` — skills latest
3. แนะนำให้รัน `/check-setup` verify

**Manual (ถ้าอยากอัพเดทแยก):**
- Skills เท่านั้น → `npx skills add sittipons-ike/uxui-skill-library`
- Rules เท่านั้น → `cd uxui-skill-library && git pull`

---

## อัปเดต Figma MCP

ไม่ต้องทำอะไร — ระบบดึงเวอร์ชันล่าสุดอัตโนมัติทุกครั้งที่เปิด Claude Desktop

---

## ติดต่อ

ติดตั้งไม่ได้ หรือ Figma ไม่ Connected → แจ้ง @sittipon (design@7solutions.co.th)
