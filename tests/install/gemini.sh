#!/usr/bin/env bash
# Tests: gemini install
# Verifies that install.sh --agent gemini appends the right content to GEMINI.md
# and is idempotent on repeat installs.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: gemini (project scope) ---"

( cd "$TMP" && HOME="$TMP/home" bash "$REPO/install.sh" --agent gemini ) >/dev/null 2>&1

assert_file_exists "$TMP/GEMINI.md" "GEMINI.md created"
assert_file_contains "$TMP/GEMINI.md" "k-mcp-devkit: dev" "GEMINI.md contains k-mcp-devkit dev section heading"

# Content of commands/dev.md should appear in GEMINI.md
# Check a distinctive phrase from the source file
SAMPLE="$(head -3 "$REPO/commands/dev.md" | tail -1)"
assert_file_contains "$TMP/GEMINI.md" "$SAMPLE" "GEMINI.md contains content from commands/dev.md"

echo ""
echo "--- install: gemini (idempotent — no duplicate sections on re-install) ---"

( cd "$TMP" && HOME="$TMP/home" bash "$REPO/install.sh" --agent gemini ) >/dev/null 2>&1

COUNT="$(grep -cF "k-mcp-devkit: dev" "$TMP/GEMINI.md")"
if [[ "$COUNT" -eq 1 ]]; then
  pass "section appears exactly once after two installs"
else
  fail "section duplicated after re-install (found $COUNT times)"
fi

echo ""
echo "--- install: gemini (global scope, HOME isolated) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" bash "$REPO/install.sh" --agent gemini --global ) >/dev/null 2>&1

assert_file_exists "$FAKE_HOME/.gemini/GEMINI.md" "~/.gemini/GEMINI.md created"
assert_file_contains "$FAKE_HOME/.gemini/GEMINI.md" "k-mcp-devkit: dev" "global GEMINI.md contains dev section"

echo ""
echo "--- install: gemini (existing GEMINI.md is preserved) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT
echo "# Existing project notes" > "$TMP2/GEMINI.md"
echo "Do not delete this." >> "$TMP2/GEMINI.md"
( cd "$TMP2" && HOME="$TMP2/home" bash "$REPO/install.sh" --agent gemini ) >/dev/null 2>&1

assert_file_contains "$TMP2/GEMINI.md" "Existing project notes" "pre-existing GEMINI.md content preserved"
assert_file_contains "$TMP2/GEMINI.md" "k-mcp-devkit: dev"     "new section appended alongside existing content"

summary
