#!/usr/bin/env bash
# Tests: kiro install
# Verifies that build/install.js kiro puts dev.md in .kiro/steering/.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: kiro (project scope) ---"

( cd "$TMP" && node "$REPO/build/install.js" kiro ) >/dev/null 2>&1

assert_dir_exists  "$TMP/.kiro/steering"           ".kiro/steering/ directory created"
assert_file_exists "$TMP/.kiro/steering/dev.md"    "dev.md installed to .kiro/steering/"
assert_files_identical \
  "$REPO/build/dev.md" \
  "$TMP/.kiro/steering/dev.md" \
  "installed dev.md matches build/dev.md"

echo ""
echo "--- install: kiro (--global warns but installs at project scope) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT

OUTPUT="$(cd "$TMP2" && node "$REPO/build/install.js" kiro --global 2>&1)"
assert_file_exists "$TMP2/.kiro/steering/dev.md" "dev.md still installed when --global passed"
if echo "$OUTPUT" | grep -qi "warn\|global.*not supported\|project scope"; then
  pass "--global triggers a warning about lack of global support"
else
  fail "--global should warn that Kiro has no global steering (got: $OUTPUT)"
fi

echo ""
echo "--- install: kiro (idempotent — re-install overwrites cleanly) ---"

echo "corrupted" > "$TMP/.kiro/steering/dev.md"
( cd "$TMP" && node "$REPO/build/install.js" kiro ) >/dev/null 2>&1
assert_files_identical \
  "$REPO/build/dev.md" \
  "$TMP/.kiro/steering/dev.md" \
  "re-install restores build/dev.md"

echo ""
echo "--- install: kiro (content matches build/dev.md) ---"

assert_file_contains "$TMP/.kiro/steering/dev.md" "Requirements Interview"  "steering file includes Requirements Interview"
assert_file_contains "$TMP/.kiro/steering/dev.md" "Conventional Commits"    "steering file includes git practices"

summary
