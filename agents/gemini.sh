#!/usr/bin/env bash
# Install k-mcp-devkit context for Gemini CLI.
#
# Gemini CLI reads persistent context from:
#   project scope  → <project-root>/GEMINI.md
#   global scope   → ~/.gemini/GEMINI.md
#
# Gemini CLI does not have a native slash command mechanism — it uses
# the GEMINI.md file as always-on project context. This installer
# appends each command file to that context under a named heading so
# you can activate it by mentioning "use dev mode" or similar.
#
# See: https://github.com/google-gemini/gemini-cli
#
# Usage:
#   agents/gemini.sh [--global]   (default: project scope)

set -euo pipefail

SCOPE="project"
[[ "${1:-}" == "--global" ]] && SCOPE="global"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/../commands"

if [[ "$SCOPE" == "global" ]]; then
  TARGET_FILE="$HOME/.gemini/GEMINI.md"
  mkdir -p "$HOME/.gemini"
else
  TARGET_FILE="$(pwd)/GEMINI.md"
fi

install_count=0
for src in "$COMMANDS_DIR"/*.md; do
  name="$(basename "$src" .md)"
  heading="## k-mcp-devkit: $name"

  # Append only if this heading is not already present
  if grep -qF "$heading" "$TARGET_FILE" 2>/dev/null; then
    echo "  skipped (already present): $name in $TARGET_FILE"
  else
    {
      echo ""
      echo "$heading"
      echo ""
      cat "$src"
    } >> "$TARGET_FILE"
    echo "  appended: $name → $TARGET_FILE"
    install_count=$(( install_count + 1 ))
  fi
done

echo ""
echo "Gemini CLI: $install_count command(s) added to $TARGET_FILE (scope: $SCOPE)"
echo "Activate in a session by asking the model to apply the relevant section."
