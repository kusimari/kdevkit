#!/usr/bin/env bash
# Tests: build output format and contents

set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO/tests/helpers.sh"

FILE="$REPO/build/kdevkit-dev.md"

echo "--- build: kdevkit-dev.md format ---"

assert_file_exists "$FILE" "build/kdevkit-dev.md exists"

FIRST_LINE=$(head -1 "$FILE")
if [[ "$FIRST_LINE" == "---" ]]; then
  pass "starts with YAML frontmatter"
else
  fail "must start with ---, got: $FIRST_LINE"
fi

assert_file_contains "$FILE" "name: kdevkit-dev"  "has name: kdevkit-dev"
assert_file_contains "$FILE" "description:"       "has description"
assert_file_contains "$FILE" "tools:"             "has tools"

echo ""
echo "--- build: kdevkit-dev.md contents ---"

assert_file_contains "$FILE" "Step 1"               "has Step 1 (project context)"
assert_file_contains "$FILE" "Step 2"               "has Step 2 (feature context)"
assert_file_contains "$FILE" "Feature Setup"        "has Feature Setup section (inlined)"
assert_file_contains "$FILE" "Conventional Commits" "has git practices (inlined)"
assert_file_contains "$FILE" "yolo"                 "has yolo mode"

echo ""
echo "--- build: self-contained (no external references) ---"

if grep -qF "raw.githubusercontent.com" "$FILE" || grep -qF "github.com" "$FILE"; then
  fail "agent file must not contain GitHub URLs"
else
  pass "no GitHub URLs in agent file"
fi

summary
