#!/usr/bin/env bash
# Tests: gemini install
# Uses --local so tests run against build/dev.md without needing network.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: gemini (project scope, --local) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" gemini --local ) >/dev/null 2>&1

assert_file_exists "$TMP/GEMINI.md" "GEMINI.md created"
assert_file_contains "$TMP/GEMINI.md" "kdevkit: dev"           "GEMINI.md contains dev section heading"
assert_file_contains "$TMP/GEMINI.md" "kdevkit: feature-setup" "GEMINI.md contains feature-setup section"
assert_file_contains "$TMP/GEMINI.md" "kdevkit: git-practices"  "GEMINI.md contains git-practices section"
assert_file_contains "$TMP/GEMINI.md" "/dev"                    "GEMINI.md contains /dev command reference"
assert_file_contains "$TMP/GEMINI.md" "Requirements Interview"  "GEMINI.md contains feature-setup content"
assert_file_contains "$TMP/GEMINI.md" "Conventional Commits"    "GEMINI.md contains git-practices content"

echo ""
echo "--- install: gemini (idempotent — no duplicate sections on re-install) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" gemini --local ) >/dev/null 2>&1

for SECTION in "kdevkit: dev" "kdevkit: feature-setup" "kdevkit: git-practices"; do
  COUNT="$(grep -cE "^## ${SECTION}$" "$TMP/GEMINI.md")"
  if [[ "$COUNT" -eq 1 ]]; then
    pass "'## $SECTION' heading appears exactly once after two installs"
  else
    fail "'## $SECTION' heading duplicated after re-install (found $COUNT times)"
  fi
done

echo ""
echo "--- install: gemini (global scope, --local) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" node "$REPO/install.js" gemini --local --global ) >/dev/null 2>&1

assert_file_exists "$FAKE_HOME/.gemini/GEMINI.md" "~/.gemini/GEMINI.md created"
assert_file_contains "$FAKE_HOME/.gemini/GEMINI.md" "kdevkit: dev" "global GEMINI.md contains dev section"

echo ""
echo "--- install: gemini (existing GEMINI.md is preserved) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT
echo "# Existing project notes" > "$TMP2/GEMINI.md"
echo "Do not delete this." >> "$TMP2/GEMINI.md"
( cd "$TMP2" && HOME="$TMP2/home" node "$REPO/install.js" gemini --local ) >/dev/null 2>&1

assert_file_contains "$TMP2/GEMINI.md" "Existing project notes" "pre-existing content preserved"
assert_file_contains "$TMP2/GEMINI.md" "kdevkit: dev"     "new section appended"

summary
