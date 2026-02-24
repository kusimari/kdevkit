#!/usr/bin/env bash
# Tests: kiro install
# Uses --local so tests run against build/dev.md without needing network.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: kiro (project scope, --local) ---"

( cd "$TMP" && node "$REPO/install.js" kiro --local ) >/dev/null 2>&1

assert_dir_exists  "$TMP/.kiro/steering"           ".kiro/steering/ directory created"
assert_file_exists "$TMP/.kiro/steering/dev.md"    "dev.md installed to .kiro/steering/"
assert_file_contains "$TMP/.kiro/steering/dev.md" "kdevkit:built:"      "installed dev.md has build timestamp"
assert_file_contains "$TMP/.kiro/steering/dev.md" "kdevkit:source:local" "installed dev.md has source metadata"
assert_file_contains "$TMP/.kiro/steering/dev.md" "feature-setup.md"    "installed dev.md references companion files"
assert_dir_exists  "$TMP/.kiro/steering/kdevkit"                             "kdevkit/ companion dir created"
assert_file_exists "$TMP/.kiro/steering/kdevkit/feature-setup.md"            "feature-setup.md installed to kdevkit/"
assert_file_exists "$TMP/.kiro/steering/kdevkit/git-practices.md"            "git-practices.md installed to kdevkit/"
assert_file_contains "$TMP/.kiro/steering/kdevkit/feature-setup.md" "Requirements Interview" "feature-setup.md has interview content"
assert_file_contains "$TMP/.kiro/steering/kdevkit/git-practices.md" "Conventional Commits"   "git-practices.md has git content"

echo ""
echo "--- install: kiro (--global warns but installs at project scope) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT

OUTPUT="$(cd "$TMP2" && node "$REPO/install.js" kiro --local --global 2>&1)"
assert_file_exists "$TMP2/.kiro/steering/dev.md" "dev.md still installed when --global passed"
if echo "$OUTPUT" | grep -qi "warn\|global.*not supported\|project scope"; then
  pass "--global triggers a warning about lack of global support"
else
  fail "--global should warn that Kiro has no global steering (got: $OUTPUT)"
fi

echo ""
echo "--- install: kiro (idempotent — re-install overwrites cleanly) ---"

echo "corrupted" > "$TMP/.kiro/steering/dev.md"
( cd "$TMP" && node "$REPO/install.js" kiro --local ) >/dev/null 2>&1
assert_file_contains "$TMP/.kiro/steering/dev.md" "kdevkit:built:"      "re-install restores build timestamp"
assert_file_contains "$TMP/.kiro/steering/kdevkit/feature-setup.md" "Requirements Interview" "re-install restores companion file"

summary
