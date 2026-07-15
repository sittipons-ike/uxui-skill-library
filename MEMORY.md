# Project Memory — uxui-skill-library

> บทเรียนที่ AI/ทีมทำพลาดแล้วแก้ — อ่านก่อนแตะ SKILL.md ทุกครั้ง (ตาม Global RULE 12)

## 2026-07-15 · colon-space ใน SKILL.md description ทำ `npx skills` discovery พังเงียบ
- **เกิดอะไร:** `design-component-builder` ไม่เคยติดตั้งผ่าน `npx skills add` ได้เลยตั้งแต่สร้าง (ไม่เข้า `skills-lock.json`, ไม่ถูก symlink, Claude เรียกไม่ได้). ตอน trim description ยังเผลอ introduce บั๊กเดียวกันเพิ่มใน `design-builder` + `design-ui-builder`.
- **ทำไม:** description ใน YAML frontmatter เป็น unquoted scalar. กฎ YAML: plain scalar ห้ามมี `: ` (colon ตามด้วย space) — parser จะคิดว่าเป็น nested mapping แล้ว parse พัง. `npx skills` เจอ error → **ดรอปสกิลทั้งตัวออกจาก discovery แบบเงียบ ไม่ error ให้เห็น**. ตัวอย่างข้อความที่พัง: `"Default scope: button"`, `"Dual-path: build"`, `"dual-mode rendering: iframe"`.
- **ครั้งหน้าทำยังไง:** ห้ามใส่ `: ` (colon+space) ใน field `description` ของ SKILL.md. ถ้าต้องแยก label ใช้ ` — ` (em dash) หรือ `,` แทน. ก่อน commit สกิลใหม่/แก้ description ให้รัน `grep -m1 "^description:" skills/<name>/SKILL.md | sed 's/^description: //' | grep ': '` — ถ้า match = พัง ต้องแก้. Verify ครบด้วย `npx skills add <local-path> -l` แล้วนับว่าเห็นครบทุกตัวไหม.

## 2026-07-15 · `npx skills add --all` แปลง skills/ เป็น symlink ทำ working tree พัง
- **เกิดอะไร:** รัน `npx skills add sittipons-ike/uxui-skill-library --all` เพื่อ regenerate lock → flag `--all` (= `--skill '*' --agent '*'`) ไปแทนที่ `skills/<name>/` (source จริง) ด้วย symlink → `../.agents/skills/<name>` ทั้ง 29 ตัว + สร้าง `agent/` ขยะ. git เห็นไฟล์จริงเป็น deleted.
- **ทำไม:** `--all` สั่งติดตั้งไปทุก agent target ซึ่งใช้ symlink strategy กับ source dir. ไม่ใช่แค่ regenerate lock. เข้าใจ flag ผิด.
- **ครั้งหน้าทำยังไง:** regenerate lock อย่างเดียว → ใช้ `npx skills add <repo>` เฉยๆ (ไม่ใส่ `--all`). ถ้าเผลอทำพัง กู้ด้วย: `find skills/ -maxdepth 1 -type l -delete` (ลบ symlink) → `rm -rf agent/` → `git checkout -- skills/` (คืนไฟล์จริงจาก HEAD). Content จริงปลอดภัยใน git เสมอถ้ายังไม่ commit ทับ.

## 2026-07-15 · frontmatter field ที่สะกด/ตั้งชื่อผิด Claude Code เมินเงียบ
- **เกิดอะไร:** 12 สกิลใช้ `user-invokable` (ผิด) แทน official `user-invocable`. 6 สกิลใช้ `args:` (object list) แทน official `arguments:` (flat string list). ทั้งคู่ Claude Code ไม่รู้จัก → ไม่มีผล ไม่ error.
- **ทำไม:** สกิลถูกสร้างต่างที ต่าง template ไม่ตรง official spec. `skills-lock.json` ไม่ validate frontmatter keys เลย เลยไม่มีใครจับได้.
- **ครั้งหน้าทำยังไง:** official SKILL.md frontmatter keys = `name, description, when_to_use, argument-hint, arguments, disable-model-invocation, user-invocable, allowed-tools, disallowed-tools, model, effort, context, agent, hooks, paths, shell`. field นอกนี้ (version, license, category, mcps_required) เป็น human-metadata Claude เมิน — เก็บได้แต่รู้ว่าไม่มีผล runtime. `arguments:` รับแค่ list ของชื่อ string (positional `$name` substitution) ไม่มี description/required/default — ถ้าต้อง document arg แบบละเอียดให้เขียนใน body section `## Arguments` แทน.
