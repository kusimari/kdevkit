#!/usr/bin/env bash
# Tests: gemini install
# Verifies that install.js --agent gemini appends the stub content to GEMINI.md
# and is idempotent on repeat installs.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: gemini (project scope) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" --agent gemini ) >/dev/null 2>&1

assert_file_exists "$TMP/GEMINI.md" "GEMINI.md created"
assert_file_contains "$TMP/GEMINI.md" "k-mcp-devkit: dev" "GEMINI.md contains k-mcp-devkit dev section heading"

# Stub content (GitHub Pages URL) should appear in GEMINI.md
assert_file_contains "$TMP/GEMINI.md" "kusimari.github.io/k-mcp-devkit" "GEMINI.md contains GitHub Pages URL from stub"

echo ""
echo "--- install: gemini (idempotent — no duplicate sections on re-install) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" --agent gemini ) >/dev/null 2>&1

COUNT="$(grep -cF "k-mcp-devkit: dev" "$TMP/GEMINI.md")"
if [[ "$COUNT" -eq 1 ]]; then
  pass "section appears exactly once after two installs"
else
  fail "section duplicated after re-install (found $COUNT times)"
fi

echo ""
echo "--- install: gemini (global scope, HOME isolated) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" node "$REPO/install.js" --agent gemini --global ) >/dev/null 2>&1

assert_file_exists "$FAKE_HOME/.gemini/GEMINI.md" "~/.gemini/GEMINI.md created"
assert_file_contains "$FAKE_HOME/.gemini/GEMINI.md" "k-mcp-devkit: dev" "global GEMINI.md contains dev section"

echo ""
echo "--- install: gemini (existing GEMINI.md is preserved) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT
echo "# Existing project notes" > "$TMP2/GEMINI.md"
echo "Do not delete this." >> "$TMP2/GEMINI.md"
( cd "$TMP2" && HOME="$TMP2/home" node "$REPO/install.js" --agent gemini ) >/dev/null 2>&1

assert_file_contains "$TMP2/GEMINI.md" "Existing project notes" "pre-existing GEMINI.md content preserved"
assert_file_contains "$TMP2/GEMINI.md" "k-mcp-devkit: dev"     "new section appended alongside existing content"

summary
