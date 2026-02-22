#!/usr/bin/env bash
# Tests: gemini install
# Verifies that build/install.js gemini appends the dev content to GEMINI.md idempotently.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: gemini (project scope) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/build/install.js" gemini ) >/dev/null 2>&1

assert_file_exists "$TMP/GEMINI.md" "GEMINI.md created"
assert_file_contains "$TMP/GEMINI.md" "k-mcp-devkit: dev" "GEMINI.md contains k-mcp-devkit dev section heading"
assert_file_contains "$TMP/GEMINI.md" "/dev" "GEMINI.md contains /dev command reference"

echo ""
echo "--- install: gemini (idempotent — no duplicate sections on re-install) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/build/install.js" gemini ) >/dev/null 2>&1

COUNT="$(grep -cF "k-mcp-devkit: dev" "$TMP/GEMINI.md")"
if [[ "$COUNT" -eq 1 ]]; then
  pass "section appears exactly once after two installs"
else
  fail "section duplicated after re-install (found $COUNT times)"
fi

echo ""
echo "--- install: gemini (global scope, HOME isolated) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" node "$REPO/build/install.js" gemini --global ) >/dev/null 2>&1

assert_file_exists "$FAKE_HOME/.gemini/GEMINI.md" "~/.gemini/GEMINI.md created"
assert_file_contains "$FAKE_HOME/.gemini/GEMINI.md" "k-mcp-devkit: dev" "global GEMINI.md contains dev section"

echo ""
echo "--- install: gemini (existing GEMINI.md is preserved) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT
echo "# Existing project notes" > "$TMP2/GEMINI.md"
echo "Do not delete this." >> "$TMP2/GEMINI.md"
( cd "$TMP2" && HOME="$TMP2/home" node "$REPO/build/install.js" gemini ) >/dev/null 2>&1

assert_file_contains "$TMP2/GEMINI.md" "Existing project notes" "pre-existing GEMINI.md content preserved"
assert_file_contains "$TMP2/GEMINI.md" "k-mcp-devkit: dev"     "new section appended alongside existing content"

echo ""
echo "--- install: gemini (content matches build/dev.md) ---"

TMP3="$(mktemp -d)"
trap 'rm -rf "$TMP3"' EXIT
( cd "$TMP3" && HOME="$TMP3/home" node "$REPO/build/install.js" gemini ) >/dev/null 2>&1

assert_file_contains "$TMP3/GEMINI.md" "Requirements Interview"  "GEMINI.md includes Requirements Interview content"
assert_file_contains "$TMP3/GEMINI.md" "Conventional Commits"    "GEMINI.md includes git practices content"

summary
