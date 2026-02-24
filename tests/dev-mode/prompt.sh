#!/usr/bin/env bash
# Tests: dev.md prompt structure
# Verifies the orchestrator prompt contains the elements needed for /dev to work correctly.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

DEV="$REPO/build/dev.md"

echo "--- dev-mode: prompt structure ---"

assert_file_exists "$DEV" "build/dev.md exists"

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
assert_file_contains "$DEV" ".kdevkit/project.md"             "references .kdevkit/project.md"
assert_file_contains "$DEV" '.kdevkit/feature/<argument>.md'  "resolves feature path as .kdevkit/feature/<argument>.md"

# Git practices content is in companion file
assert_file_contains "$REPO/build/git-practices.md" "Conventional Commits" "git practices: Conventional Commits present"
assert_file_contains "$DEV" "git-practices.md"                              "git practices: companion file referenced"

# Feature setup content is in companion file
assert_file_contains "$REPO/build/feature-setup.md" "Requirements Interview" "feature setup: Requirements Interview present"
assert_file_contains "$DEV" "feature-setup.md"                               "feature setup: companion file referenced"

# Feature completion trigger
assert_file_contains "$DEV" ".kdevkit/project.md" \
  "project.md update mentioned (completion hook)"
if grep -qiF "complete" "$DEV" || grep -qiF "done" "$DEV" || grep -qiF "finish" "$DEV"; then
  pass "completion trigger language present (done/complete/finish)"
else
  fail "no completion trigger language found in dev.md"
fi

# Phase gating and YOLO mode
assert_file_contains "$DEV" "phase" "phase gating rule present"
assert_file_contains "$DEV" "yolo"  "YOLO mode toggle present"

# Confirmation format
assert_file_contains "$DEV" "Project:" "confirmation block contains Project: line"
assert_file_contains "$DEV" "Feature:" "confirmation block contains Feature: line"
assert_file_contains "$DEV" "Mode:"    "confirmation block contains Mode: line"

summary
