#!/bin/bash

# UXUI Agent Workflow — Setup Script
# รันสคริปต์นี้เพื่อติดตั้ง Skills ลงเครื่อง

SKILLS_DIR="$HOME/.claude/skills"
SOURCE_DIR="$(dirname "$0")/skills"

echo ""
echo "🎨 UXUI Agent Workflow — Setup"
echo "================================"
echo ""

# สร้างโฟลเดอร์ถ้ายังไม่มี
if [ ! -d "$SKILLS_DIR" ]; then
  mkdir -p "$SKILLS_DIR"
  echo "✅ สร้างโฟลเดอร์ ~/.claude/skills/"
else
  echo "✅ โฟลเดอร์ ~/.claude/skills/ มีอยู่แล้ว"
fi

# Copy skills
echo ""
echo "📦 กำลัง copy skills..."
cp "$SOURCE_DIR"/*.md "$SKILLS_DIR/"

echo ""
echo "Skills ที่ติดตั้ง:"
for f in "$SOURCE_DIR"/*.md; do
  echo "  ✓ $(basename "$f")"
done

echo ""
echo "================================"
echo "✅ เสร็จแล้ว! Skills พร้อมใช้งาน"
echo ""
echo "ขั้นตอนถัดไป:"
echo "  1. เปิด Claude Code Desktop"
echo "  2. ดู ONBOARDING.md สำหรับตั้ง Figma MCP"
echo ""
