#!/usr/bin/env bash
# Tests: dev.md prompt structure
# Verifies the orchestrator prompt contains the elements needed for /dev to work correctly.
# These are structural checks — not AI behaviour, but the preconditions for correct behaviour.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

DEV="$REPO/commands/dev.md"

echo "--- dev-mode: prompt structure ---"

assert_file_exists "$DEV" "commands/dev.md exists"

# Feature path argument
assert_file_contains "$DEV" '$ARGUMENTS' \
  "dev.md uses \$ARGUMENTS for optional feature path"

# Required steps present
assert_file_contains "$DEV" "Step 1" "Step 1 (project context) present"
assert_file_contains "$DEV" "Step 2" "Step 2 (feature context) present"
assert_file_contains "$DEV" "Step 3" "Step 3 (git practices) present"
assert_file_contains "$DEV" "Step 4" "Step 4 (session behaviour) present"
assert_file_contains "$DEV" "Step 5" "Step 5 (confirm) present"

# Feature file paths referenced
assert_file_contains "$DEV" "context/project.md"      "references context/project.md"
assert_file_contains "$DEV" 'context/<argument>.md'   "resolves feature path as context/<argument>.md"

# Git practices content is inlined (check for key phrases rather than file references)
assert_file_contains "$DEV" "Conventional Commits"    "git practices: Conventional Commits present"
assert_file_contains "$DEV" "feat"                    "git practices: feat type present"

# Feature setup content is inlined (check for key interview section)
assert_file_contains "$DEV" "Requirements Interview"  "feature setup: Requirements Interview present"

# Feature completion trigger
assert_file_contains "$DEV" "context/project.md" \
  "project.md update mentioned (completion hook)"
if grep -qiF "complete" "$DEV" || grep -qiF "done" "$DEV" || grep -qiF "finish" "$DEV"; then
  pass "completion trigger language present (done/complete/finish)"
else
  fail "no completion trigger language found in dev.md"
fi

# Confirmation format
assert_file_contains "$DEV" "Project:" "confirmation block contains Project: line"
assert_file_contains "$DEV" "Feature:" "confirmation block contains Feature: line"

summary
