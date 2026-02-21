#!/usr/bin/env bash
# Install k-mcp-devkit steering files for Amazon Kiro.
#
# Kiro reads persistent context from "steering" files:
#   project scope  → <project-root>/.kiro/steering/<name>.md
#
# Each steering file is always-on (inclusion: "always") by default,
# so the dev mode conventions will be active in every Kiro session
# without needing to invoke a slash command explicitly.
#
# To make a file conditional (opt-in), add this front-matter:
#
#   ---
#   inclusion: manual
#   ---
#
# See: https://kiro.dev/docs/steering
#
# Usage:
#   agents/kiro.sh   (project scope only — Kiro has no global steering)

set -euo pipefail

if [[ "${1:-}" == "--global" ]]; then
  echo "Warning: Kiro does not support global steering files. Installing at project scope."
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMANDS_DIR="$SCRIPT_DIR/../commands"
TARGET_DIR="$(pwd)/.kiro/steering"

mkdir -p "$TARGET_DIR"

install_count=0
for src in "$COMMANDS_DIR"/*.md; do
  name="$(basename "$src")"
  dest="$TARGET_DIR/$name"
  cp "$src" "$dest"
  echo "  installed: $dest"
  install_count=$(( install_count + 1 ))
done

echo ""
echo "Kiro: $install_count steering file(s) installed → $TARGET_DIR"
echo "These are active in every Kiro session for this project."
