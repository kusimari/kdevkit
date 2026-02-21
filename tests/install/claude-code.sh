#!/usr/bin/env bash
# Tests: claude-code install
# Verifies that install.sh --agent claude-code puts the right files in the right places.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: claude-code (project scope) ---"

# Run install in a fresh temp project directory
( cd "$TMP" && HOME="$TMP/home" bash "$REPO/install.sh" --agent claude-code ) >/dev/null 2>&1

assert_dir_exists  "$TMP/.claude/commands"           ".claude/commands/ directory created"
assert_file_exists "$TMP/.claude/commands/dev.md"    "dev.md installed to .claude/commands/"
assert_files_identical \
  "$REPO/commands/dev.md" \
  "$TMP/.claude/commands/dev.md" \
  "installed dev.md matches source"

echo ""
echo "--- install: claude-code (global scope, HOME isolated) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" bash "$REPO/install.sh" --agent claude-code --global ) >/dev/null 2>&1

assert_dir_exists  "$FAKE_HOME/.claude/commands"        "~/.claude/commands/ directory created"
assert_file_exists "$FAKE_HOME/.claude/commands/dev.md" "dev.md installed globally"
assert_files_identical \
  "$REPO/commands/dev.md" \
  "$FAKE_HOME/.claude/commands/dev.md" \
  "globally installed dev.md matches source"

echo ""
echo "--- install: claude-code (idempotent — re-install overwrites cleanly) ---"

# Modify the installed file, re-install, and check it was restored
echo "corrupted" > "$TMP/.claude/commands/dev.md"
( cd "$TMP" && HOME="$TMP/home" bash "$REPO/install.sh" --agent claude-code ) >/dev/null 2>&1
assert_files_identical \
  "$REPO/commands/dev.md" \
  "$TMP/.claude/commands/dev.md" \
  "re-install restores dev.md to match source"

summary
