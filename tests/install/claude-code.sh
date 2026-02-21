#!/usr/bin/env bash
# Tests: claude-code install
# Verifies that install.js --agent claude-code puts the stub in the right places.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: claude-code (project scope) ---"

# Run install in a fresh temp project directory
( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" --agent claude-code ) >/dev/null 2>&1

assert_dir_exists  "$TMP/.claude/commands"           ".claude/commands/ directory created"
assert_file_exists "$TMP/.claude/commands/dev.md"    "dev.md installed to .claude/commands/"
assert_files_identical \
  "$REPO/stub/dev.md" \
  "$TMP/.claude/commands/dev.md" \
  "installed dev.md matches stub"

echo ""
echo "--- install: claude-code (global scope, HOME isolated) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" node "$REPO/install.js" --agent claude-code --global ) >/dev/null 2>&1

assert_dir_exists  "$FAKE_HOME/.claude/commands"        "~/.claude/commands/ directory created"
assert_file_exists "$FAKE_HOME/.claude/commands/dev.md" "dev.md installed globally"
assert_files_identical \
  "$REPO/stub/dev.md" \
  "$FAKE_HOME/.claude/commands/dev.md" \
  "globally installed dev.md matches stub"

echo ""
echo "--- install: claude-code (idempotent — re-install overwrites cleanly) ---"

# Modify the installed file, re-install, and check it was restored
echo "corrupted" > "$TMP/.claude/commands/dev.md"
( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" --agent claude-code ) >/dev/null 2>&1
assert_files_identical \
  "$REPO/stub/dev.md" \
  "$TMP/.claude/commands/dev.md" \
  "re-install restores stub"

echo ""
echo "--- install: claude-code (--local installs full commands/dev.md) ---"

TMP_LOCAL="$(mktemp -d)"
trap 'rm -rf "$TMP_LOCAL"' EXIT
( cd "$TMP_LOCAL" && HOME="$TMP_LOCAL/home" node "$REPO/install.js" --agent claude-code --local ) >/dev/null 2>&1

assert_dir_exists  "$TMP_LOCAL/.claude/commands"           ".claude/commands/ directory created (--local)"
assert_file_exists "$TMP_LOCAL/.claude/commands/dev.md"    "dev.md installed (--local)"
assert_files_identical \
  "$REPO/commands/dev.md" \
  "$TMP_LOCAL/.claude/commands/dev.md" \
  "--local installs full commands/dev.md (not stub)"

# Verify local build is NOT the stub (they should differ)
if ! diff -q "$REPO/stub/dev.md" "$TMP_LOCAL/.claude/commands/dev.md" >/dev/null 2>&1; then
  pass "--local install differs from stub (correct)"
else
  fail "--local install is identical to stub (should be the full build)"
fi

summary
