#!/usr/bin/env bash
# install-team-rules.sh — UXUI Designer team rules installer
#
# What this does:
#   1. Backup existing ~/.claude/CLAUDE.md (if any) → ~/.claude/CLAUDE.md.bak.<timestamp>
#   2. Symlink ~/.claude/team-rules.md → <repo>/team-rules/CLAUDE.md
#   3. Patch ~/.claude/CLAUDE.md to @import the team rules (idempotent — won't duplicate)
#
# Re-run any time. git pull in the repo = rules auto-update (symlink follows source).
#
# Usage:
#   cd /path/to/uxui-skill-library
#   bash team-rules/install-team-rules.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_RULES="$SCRIPT_DIR/CLAUDE.md"
CLAUDE_DIR="$HOME/.claude"
SYMLINK_PATH="$CLAUDE_DIR/team-rules.md"
USER_CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
IMPORT_LINE="@~/.claude/team-rules.md"
IMPORT_MARKER="# 🛡️ Team Rules — auto-imported from uxui-skill-library/team-rules"

# --- precondition checks -----------------------------------------------------

if [ ! -f "$REPO_RULES" ]; then
  echo "❌ team-rules/CLAUDE.md not found at: $REPO_RULES"
  echo "   Run this script from the repo root: bash team-rules/install-team-rules.sh"
  exit 1
fi

mkdir -p "$CLAUDE_DIR"

# --- step 1: backup ----------------------------------------------------------

if [ -f "$USER_CLAUDE_MD" ] && [ ! -L "$USER_CLAUDE_MD" ]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  BACKUP="$USER_CLAUDE_MD.bak.$TS"
  cp "$USER_CLAUDE_MD" "$BACKUP"
  echo "✅ backup: $BACKUP"
else
  echo "ℹ️  no existing ~/.claude/CLAUDE.md — will create new"
fi

# --- step 2: symlink ---------------------------------------------------------

if [ -L "$SYMLINK_PATH" ]; then
  CURRENT_TARGET="$(readlink "$SYMLINK_PATH")"
  if [ "$CURRENT_TARGET" = "$REPO_RULES" ]; then
    echo "✅ symlink already points at $REPO_RULES — skip"
  else
    echo "⚠️  existing symlink points elsewhere: $CURRENT_TARGET — replacing"
    rm "$SYMLINK_PATH"
    ln -s "$REPO_RULES" "$SYMLINK_PATH"
    echo "✅ symlinked: $SYMLINK_PATH → $REPO_RULES"
  fi
elif [ -e "$SYMLINK_PATH" ]; then
  echo "❌ $SYMLINK_PATH exists but is not a symlink. Move/delete it first."
  exit 1
else
  ln -s "$REPO_RULES" "$SYMLINK_PATH"
  echo "✅ symlinked: $SYMLINK_PATH → $REPO_RULES"
fi

# --- step 3: patch @import in user CLAUDE.md ---------------------------------

if [ ! -f "$USER_CLAUDE_MD" ]; then
  cat > "$USER_CLAUDE_MD" <<EOF
$IMPORT_MARKER
$IMPORT_LINE

# 👤 Personal Customizations (your own notes below — survive git pull)

EOF
  echo "✅ created fresh ~/.claude/CLAUDE.md with team rules @import"
elif grep -qF "$IMPORT_LINE" "$USER_CLAUDE_MD"; then
  echo "✅ ~/.claude/CLAUDE.md already imports team rules — skip"
else
  # prepend import block to existing file
  TMP="$(mktemp)"
  {
    echo "$IMPORT_MARKER"
    echo "$IMPORT_LINE"
    echo ""
    echo "---"
    echo ""
    cat "$USER_CLAUDE_MD"
  } > "$TMP"
  mv "$TMP" "$USER_CLAUDE_MD"
  echo "✅ prepended @import line to ~/.claude/CLAUDE.md"
fi

echo ""
echo "🎉 Done."
echo ""
echo "Verify:"
echo "  head -5 ~/.claude/CLAUDE.md          # should show @~/.claude/team-rules.md"
echo "  readlink ~/.claude/team-rules.md     # should point to repo team-rules/CLAUDE.md"
echo ""
echo "Update flow:"
echo "  cd $(dirname "$SCRIPT_DIR") && git pull   # rules auto-update via symlink"
