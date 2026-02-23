#!/usr/bin/env bash
# Tests: claude-code install
# Uses --local so tests run against build/dev.md without needing network.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: claude-code (project scope, --local) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" claude-code --local ) >/dev/null 2>&1

assert_dir_exists  "$TMP/.claude/commands"           ".claude/commands/ directory created"
assert_file_exists "$TMP/.claude/commands/dev.md"    "dev.md installed to .claude/commands/"
assert_files_identical \
  "$REPO/build/dev.md" \
  "$TMP/.claude/commands/dev.md" \
  "installed dev.md matches build/dev.md"

echo ""
echo "--- install: claude-code (global scope, --local) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" node "$REPO/install.js" claude-code --local --global ) >/dev/null 2>&1

assert_dir_exists  "$FAKE_HOME/.claude/commands"        "~/.claude/commands/ directory created"
assert_file_exists "$FAKE_HOME/.claude/commands/dev.md" "dev.md installed globally"
assert_files_identical \
  "$REPO/build/dev.md" \
  "$FAKE_HOME/.claude/commands/dev.md" \
  "globally installed dev.md matches build/dev.md"

echo ""
echo "--- install: claude-code (idempotent — re-install overwrites cleanly) ---"

echo "corrupted" > "$TMP/.claude/commands/dev.md"
( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" claude-code --local ) >/dev/null 2>&1
assert_files_identical \
  "$REPO/build/dev.md" \
  "$TMP/.claude/commands/dev.md" \
  "re-install restores build/dev.md"

echo ""
echo "--- install: claude-code (positional and --agent flag both work) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT
( cd "$TMP2" && HOME="$TMP2/home" node "$REPO/install.js" --agent claude-code --local ) >/dev/null 2>&1
assert_file_exists "$TMP2/.claude/commands/dev.md" "dev.md installed via --agent flag"
assert_files_identical \
  "$REPO/build/dev.md" \
  "$TMP2/.claude/commands/dev.md" \
  "--agent flag produces same result as positional arg"

summary
