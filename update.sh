#!/usr/bin/env bash
# update.sh — UXUI Skill Library: pull latest rules + skills in one shot
#
# What this does:
#   1. git pull → team-rules/CLAUDE.md auto-syncs (because ~/.claude/team-rules.md is a symlink)
#   2. npx skills add sittipons-ike/uxui-skill-library → re-fetch all skill SKILL.md files
#   3. Hint to run /check-setup in Claude Code
#
# Run any time you want latest. Safe to re-run.
#
# Usage:
#   cd /path/to/uxui-skill-library
#   bash update.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔄 UXUI Skill Library — update"
echo ""

# --- step 1: pull team-rules ------------------------------------------------

echo "→ Pulling latest team-rules..."
if [ -d ".git" ]; then
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  git pull --ff-only
  echo "✅ git pull done (branch: $CURRENT_BRANCH)"
else
  echo "⚠️  not a git repo — skip git pull"
fi

echo ""

# --- step 2: refresh skills via npx -----------------------------------------

echo "→ Refreshing skills via npx..."
if command -v npx >/dev/null 2>&1; then
  npx --yes skills add sittipons-ike/uxui-skill-library
  echo "✅ skills refreshed"
else
  echo "❌ npx not found — install Node.js first (https://nodejs.org)"
  echo "   Fallback: claude plugin marketplace update"
  exit 1
fi

echo ""
echo "🎉 Done."
echo ""
echo "Next: open Claude Code and run /check-setup to verify."
