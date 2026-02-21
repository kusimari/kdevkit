#!/usr/bin/env bash
# Install k-mcp-devkit slash commands for Claude Code.
#
# Claude Code resolves slash commands from:
#   project scope  → <project-root>/.claude/commands/<name>.md
#   global scope   → ~/.claude/commands/<name>.md
#
# Usage:
#   agents/claude-code.sh [--global]   (default: project scope)

set -euo pipefail

SCOPE="project"
[[ "${1:-}" == "--global" ]] && SCOPE="global"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/../commands"

if [[ "$SCOPE" == "global" ]]; then
  TARGET_DIR="$HOME/.claude/commands"
else
  TARGET_DIR="$(pwd)/.claude/commands"
fi

mkdir -p "$TARGET_DIR"

install_count=0
for src in "$COMMANDS_DIR"/*.md; do
  name="$(basename "$src")"
  dest="$TARGET_DIR/$name"
  cp "$src" "$dest"
  echo "  installed: $dest"
  (( install_count++ ))
done

echo ""
echo "Claude Code: $install_count command(s) installed (scope: $SCOPE)"
echo "Invoke with /$( ls "$COMMANDS_DIR"/*.md 2>/dev/null | xargs -I{} basename {} .md | tr '\n' ' '| sed 's/ $//')"
