#!/usr/bin/env bash
# Tests: build output format and contents

set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
source "$REPO/tests/helpers.sh"

echo "--- build: kdevkit-dev.md format ---"

assert_file_exists "$REPO/build/kdevkit-dev.md" "build/kdevkit-dev.md exists"

FIRST_LINE=$(head -1 "$REPO/build/kdevkit-dev.md")
if [[ "$FIRST_LINE" == "---" ]]; then
  pass "file starts with --- (YAML frontmatter)"
else
  fail "file must start with --- (YAML frontmatter), got: $FIRST_LINE"
fi

assert_file_contains "$REPO/build/kdevkit-dev.md" "name: kdevkit-dev"  "has name: kdevkit-dev"
assert_file_contains "$REPO/build/kdevkit-dev.md" "description:"       "has description field"
assert_file_contains "$REPO/build/kdevkit-dev.md" "tools:"             "has tools field"

echo ""
echo "--- build: kdevkit-dev.md contents ---"

assert_file_contains "$REPO/build/kdevkit-dev.md" "Step 1"             "has project context step"
assert_file_contains "$REPO/build/kdevkit-dev.md" "Step 2"             "has feature context step"
assert_file_contains "$REPO/build/kdevkit-dev.md" "yolo"               "has yolo mode"
assert_file_contains "$REPO/build/kdevkit-dev.md" "feature-setup.md"  "references feature-setup companion"
assert_file_contains "$REPO/build/kdevkit-dev.md" "git-practices.md"  "references git-practices companion"

echo ""
echo "--- build: companion files ---"

assert_file_exists "$REPO/build/feature-setup.md"  "build/feature-setup.md exists"
assert_file_exists "$REPO/build/git-practices.md"  "build/git-practices.md exists"
assert_file_contains "$REPO/build/feature-setup.md" "Requirements:"        "feature-setup.md has content"
assert_file_contains "$REPO/build/git-practices.md" "Conventional Commits" "git-practices.md has content"

summary
