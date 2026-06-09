---
name: check-setup
description: Onboarding guide สำหรับทีม Designer ที่ไม่มี dev background — auto-detect ว่าเครื่องลงอะไรบ้าง (Node.js, Git, Claude Code, Figma MCP, working rules), แสดง diagnostic, แล้วพา install ที่ละ step ที่ขาด ใช้เมื่อ user พูดว่า "เริ่มยังไง", "เพิ่งติดตั้ง", "setup", "ติดตั้งครั้งแรก", "first time", "เริ่มต้น", หรือเรียกตรง /check-setup
license: MIT
---

# Setup Helper

> Auto-detect + guide ทีมตั้งแต่ zero — ทุกคนจบที่ state เดียวกัน

## 🎯 Trigger Conditions

Skill นี้ trigger เมื่อ user พูดว่า:
- "เริ่มยังไง", "เริ่มต้น", "ต้องทำอะไรบ้าง"
- "เพิ่งติดตั้ง", "ลงครั้งแรก", "ยังไม่เคยใช้"
- "first time", "getting started", "setup", "onboarding"
- เรียกตรง `/check-setup`

**Do NOT trigger when:** user อยู่กลาง task อื่น หรือถามเรื่อง skill ใดๆ เป็นการเฉพาะ

---

## 🔄 Execution Workflow

### Phase 1: ทักทาย

แสดงข้อความสั้น:
```
👋 ยินดีต้อนรับสู่ UXUI Skill Library

ผมจะเช็กว่าเครื่องคุณพร้อมหรือยัง แล้วพาติดตั้งสิ่งที่ขาด
ไม่ต้องรู้ code เลย — ทำตามที่บอกได้ทันที

⏱️ ใช้เวลา 5-30 นาทีตามว่าเครื่องลงอะไรไว้แล้วบ้าง
```

---

### Phase 2: Auto-Diagnostic (ใช้ Bash tool ตรวจจริง)

**MUST** รัน Bash check ทั้งหมดนี้ — **ห้ามถาม user แทน**:

```bash
echo "=== Auto-detect prerequisites ==="

# 1. Node.js
if command -v node &>/dev/null; then
  echo "✅ Node.js: $(node -v)"
else
  echo "❌ Node.js: ยังไม่ได้ติดตั้ง"
fi

# 2. Git
if command -v git &>/dev/null; then
  echo "✅ Git: $(git --version)"
else
  echo "❌ Git: ยังไม่ได้ติดตั้ง"
fi

# 3. Claude Code Desktop
if [ -d "/Applications/Claude.app" ]; then
  echo "✅ Claude Code Desktop: ติดตั้งแล้ว"
else
  echo "❌ Claude Code Desktop: ยังไม่ได้ติดตั้ง"
fi

# 4. Figma MCP config
CONFIG=~/Library/Application\ Support/Claude/claude_desktop_config.json
if [ -f "$CONFIG" ] && grep -q "figma-console" "$CONFIG"; then
  echo "✅ Figma MCP: config มีแล้ว (เช็กที่ /mcp ว่า Connected ไหม)"
else
  echo "❌ Figma MCP: ยังไม่ได้ตั้งค่า"
fi

# 5. Global CLAUDE.md (working rules)
if [ -f ~/.claude/CLAUDE.md ]; then
  SIZE=$(wc -l < ~/.claude/CLAUDE.md)
  echo "ℹ️ Global CLAUDE.md: มีอยู่แล้ว ($SIZE บรรทัด)"
else
  echo "❌ Global CLAUDE.md: ยังไม่มี (working rules ของทีม)"
fi
```

แสดงผลลัพธ์ให้ user เห็นเป็นตาราง summary:

```
📋 Diagnostic Report

| สิ่งที่ต้องมี | สถานะ |
|---|---|
| Node.js | ✅/❌ |
| Git | ✅/❌ |
| Claude Code Desktop | ✅/❌ |
| Figma MCP | ✅/❌ |
| Working Rules (CLAUDE.md) | ✅/❌ |
```

---

### Phase 3: Guide ทีละ step ที่ขาด

**สำหรับแต่ละ ❌ ให้ guide ละเอียด แสดงเฉพาะที่ขาด — ห้ามแสดงสิ่งที่มีแล้ว**

#### 🔧 ถ้าขาด Node.js

```
❌ Node.js ยังไม่ได้ติดตั้ง

Node.js คืออะไร: โปรแกรมที่ทำให้ Claude คุยกับ Figma ได้
ขนาดติดตั้ง: ~50 MB
เวลา: ~5 นาที

วิธีติดตั้ง (ไม่ต้องใช้ Terminal):
1. เปิด browser ไปที่ https://nodejs.org
2. มองหาปุ่ม "LTS" (สีเขียว) → กด Download
3. เปิดไฟล์ที่ดาวน์โหลด (.pkg)
4. กด "Continue" ไปเรื่อยๆ → "Install"
5. ใส่ password ของเครื่อง (Mac จะถาม)
6. รอจนขึ้น "The installation was successful"

ลองรัน /check-setup อีกครั้งหลังติดตั้งเสร็จ
```

#### 🔧 ถ้าขาด Git

```
❌ Git ยังไม่ได้ติดตั้ง

Git คืออะไร: เครื่องมือที่ Claude Code ใช้จัดการ session
เวลา: ~5-10 นาที

วิธีติดตั้ง:
1. เปิด Terminal (กด Cmd+Space → พิมพ์ "Terminal" → Enter)
2. copy คำสั่งนี้วาง → Enter:

   xcode-select --install

3. มี popup ขึ้นมา → กด "Install"
4. ยอมรับ Terms → รอ 5-10 นาที
5. ขึ้น "Software installed" = เสร็จ

ลองรัน /check-setup อีกครั้งหลังติดตั้งเสร็จ
```

#### 🔧 ถ้าขาด Claude Code Desktop

```
❌ Claude Code Desktop ยังไม่ได้ติดตั้ง

วิธีติดตั้ง:
1. เปิด browser ไปที่ https://claude.ai/download
2. กด "Download for Mac"
3. เปิดไฟล์ที่ดาวน์โหลด (.dmg)
4. ลาก Claude icon → folder Applications
5. เปิด Claude จาก Applications → Sign in ด้วย account ทีม

> หมายเหตุ: ถ้าคุณเห็นข้อความนี้ใน Claude Code อยู่แล้ว แสดงว่ามีติดตั้งแล้ว
```

#### 🔧 ถ้าขาด Figma MCP

```
❌ Figma MCP ยังไม่ได้ตั้งค่า

Figma MCP คืออะไร: ทำให้ Claude อ่าน/comment Figma file ได้

วิธีตั้งค่า (ทำตามลำดับ — สำคัญ):

ขั้น 1: สร้าง Figma Token
  1. เปิด Figma → คลิกรูปโปรไฟล์ขวาบน → Settings
  2. แท็บ Security → เลื่อนหา "Personal access tokens"
  3. กด "Generate new token" → ตั้งชื่อ "claude"
  4. ติ๊ก 4 scopes:
     - File content: Read
     - File versions: Read
     - Variables: Read
     - Comments: Read and write
  5. กด Generate → COPY token ทันที (เห็นแค่ครั้งเดียว!)

ขั้น 2: ใส่ token เข้า Claude
  1. เปิด Finder → กด Cmd+Shift+G
  2. พิมพ์ path นี้ → กด Go:
     ~/Library/Application Support/Claude
  3. หาไฟล์ชื่อ "claude_desktop_config.json"
     (ถ้าไม่มี → สร้างใหม่ใน TextEdit)
  4. เปิดด้วย TextEdit → ลบของเดิม → วางนี้:

     {
       "mcpServers": {
         "figma-console": {
           "command": "npx",
           "args": ["-y", "figma-console-mcp@latest"],
           "env": {
             "FIGMA_ACCESS_TOKEN": "ใส่_token_จาก_ขั้น1_ตรงนี้",
             "ENABLE_MCP_APPS": "true"
           }
         }
       }
     }

  5. แทนที่ "ใส่_token_จาก_ขั้น1_ตรงนี้" ด้วย token จริง
  6. กด Cmd+S บันทึก
  7. ปิด Claude Code → เปิดใหม่

ขั้น 3: ตรวจสอบ
  ใน Claude Code พิมพ์: /mcp
  ถ้าเห็น figma-console: Connected = สำเร็จ
```

#### 🔧 ถ้าขาด / อยากอัปเดต Global CLAUDE.md (working rules)

```
ℹ️ Global Working Rules (CLAUDE.md)

CLAUDE.md เป็นไฟล์กฎที่ Claude อ่านทุก session
ทีมเราใช้ rules ชุดเดียวกันเพื่อให้พฤติกรรม Claude เหมือนกัน

มี 2 หมวด:
- Security Rules (1-6) — การจัดการ API key, ห้ามทำอะไรกับ secrets
- Engineering Discipline (7-11) — วิธีคิด/ส่งมอบงาน

อยากใช้ rules ของทีมไหม?
```

ใช้ `AskUserQuestion` ถาม:
```
คำถาม: "อยาก install Working Rules ของทีมเป็น global CLAUDE.md ไหม?"
header: "Working Rules"
multiSelect: false
options:
  - "✅ ใช่ install ให้เลย"
  - "📋 ขอดู rules ก่อน (เปิดบน GitHub)"
  - "❌ ไม่ มีของตัวเองแล้ว"
```

**ถ้าตอบ "ใช่":**

1. ถ้ามี existing `~/.claude/CLAUDE.md` → backup ก่อน:
   ```bash
   if [ -f ~/.claude/CLAUDE.md ]; then
     cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup-$(date +%Y%m%d-%H%M%S)
     echo "✅ Backup ไฟล์เดิมไว้ที่ ~/.claude/CLAUDE.md.backup-*"
   fi
   ```

2. Download CLAUDE.md จาก repo:
   ```bash
   mkdir -p ~/.claude
   curl -fsSL https://raw.githubusercontent.com/sittipons-ike/uxui-skill-library/main/CLAUDE.md -o ~/.claude/CLAUDE.md
   echo "✅ Install สำเร็จ — restart Claude Code เพื่อให้ rules ใหม่ทำงาน"
   ```

3. บอก user: "เสร็จแล้ว → ปิดและเปิด Claude Code ใหม่"

**ถ้าตอบ "ขอดูก่อน":**
- แสดง URL: https://github.com/sittipons-ike/uxui-skill-library/blob/main/CLAUDE.md
- บอก: "ดูจบแล้วเรียก /check-setup อีกครั้งถ้าอยาก install"

**ถ้าตอบ "ไม่":**
- ข้ามไป Phase 4 ไม่ต้องทำอะไร

---

### Phase 4: Final State Check

หลัง guide ครบทุก step ที่ขาด — ขอให้ user รัน `/check-setup` อีกครั้งเพื่อ verify

ถ้า diagnostic ผ่านครบทุกข้อ → ไป Phase 5

---

### Phase 5: แนะนำ skill แรก (เมื่อพร้อมใช้งาน)

ใช้ `AskUserQuestion` ถามอยากลอง skill ไหน:

```
คำถาม: "พร้อมใช้งานแล้ว 🎉 อยากลอง skill อันไหนก่อน?"
header: "First skill"
multiSelect: false
options:
  - "🎨 audit-ui — ตรวจ Figma DS compliance"
  - "🗺️ ux-skill — วาง User Flow + IA"
  - "📋 prd — สร้าง Product Requirements Document"
  - "🏗️ design-builder — สร้าง Design System ใหม่"
```

แสดง example prompt ตามที่เลือก:

| skill | example prompt |
|---|---|
| audit-ui | "Audit Figma นี้: [วาง link] — ตรวจ DS compliance" |
| ux-skill | "วาง UX Blueprint ฟีเจอร์ X — User goal: Y, Business goal: Z" |
| prd | "/prd ฟีเจอร์ [ชื่อ feature]" |
| design-builder | "สร้าง design system ใหม่ — Brand vibe: [คำที่บรรยาย]" |

ปิดท้าย:
```
✅ พร้อมใช้งาน — copy prompt ข้างบน วางได้เลย

ใช้ไม่ได้/เจอ error → /check-setup อีกที
ติดต่อ: design@7solutions.co.th (@sittipon)
```

---

## 🚫 Constraints

- ✅ **MUST ใช้ Bash auto-detect** — ห้าม assume ว่ามี/ไม่มี
- ✅ **ภาษาไทย** เสมอ
- ✅ **ใช้ AskUserQuestion** สำหรับ choice — ห้ามถามด้วย text
- ❌ **ห้ามรัน skill อื่นแทน user** — แค่แนะนำ + ให้ prompt
- ❌ **ห้าม assume dev knowledge** — อธิบายให้คนที่ไม่เคยใช้ Terminal เข้าใจได้
- ❌ **ห้าม install Node.js / Git แทน user** — เป็น R0 action ที่ user ต้อง confirm เอง
- ✅ **backup ก่อนเขียนทับ** ~/.claude/CLAUDE.md เสมอ

---

## 🔗 Related

- ONBOARDING.md — คู่มือเต็มแบบ manual (อ่านเองได้)
- README.md — overview ของ skills ทั้งหมด
- ติดต่อ: design@7solutions.co.th (@sittipon)
