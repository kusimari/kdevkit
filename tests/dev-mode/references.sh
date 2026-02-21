#!/usr/bin/env bash
# Tests: referenced files exist and content is correct
# - stub/dev.md must exist and point to the GitHub Pages URL
# - commands/dev.md must contain all inlined practices (it is the GitHub Pages source)

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

echo "--- dev-mode: referenced files exist ---"

# Context stubs (created by /dev on first run, but must exist in repo as templates)
assert_file_exists "$REPO/context/project.md"  "context/project.md exists"
assert_file_exists "$REPO/context/feature.md"  "context/feature.md exists"

# Practice files still exist in repo as source material
assert_file_exists "$REPO/practices/git.md"           "practices/git.md exists"
assert_file_exists "$REPO/practices/feature-setup.md" "practices/feature-setup.md exists"

# Stub and full command file both present
assert_file_exists "$REPO/stub/dev.md"     "stub/dev.md exists"
assert_file_exists "$REPO/commands/dev.md" "commands/dev.md exists"

echo ""
echo "--- dev-mode: stub points to GitHub Pages ---"

STUB="$REPO/stub/dev.md"
assert_file_contains "$STUB" "kusimari.github.io/k-mcp-devkit" "stub references GitHub Pages URL"
assert_file_contains "$STUB" "dev.md"                          "stub references dev.md on GitHub Pages"

echo ""
echo "--- dev-mode: commands/dev.md contains feature-setup interview structure ---"

DEV="$REPO/commands/dev.md"

# Four interview sections inlined into dev.md
assert_file_contains "$DEV" "Requirements Interview"    "dev.md includes Requirements Interview"
assert_file_contains "$DEV" "Design Interview"          "dev.md includes Design Interview"
assert_file_contains "$DEV" "Testing Interview"         "dev.md includes Testing Interview"
assert_file_contains "$DEV" "Implementation Interview"  "dev.md includes Implementation Interview"

# Git setup section inlined into dev.md
assert_file_contains "$DEV" "Git Setup"           "dev.md includes Git Setup section"
assert_file_contains "$DEV" "worktree add"        "git setup includes worktree command"
assert_file_contains "$DEV" "checkout -b"         "git setup includes branch command"
assert_file_contains "$DEV" "commit-ish"          "dev.md references commit-ish base"

# Feature file template sections inlined into dev.md
assert_file_contains "$DEV" "Feature Brief"                "dev.md template includes Feature Brief"
assert_file_contains "$DEV" "Requirements Specification"   "dev.md template includes Requirements Specification"
assert_file_contains "$DEV" "Technical Design"             "dev.md template includes Technical Design section"
assert_file_contains "$DEV" "Test Strategy"                "dev.md template includes Test Strategy section"
assert_file_contains "$DEV" "Session Log"                  "dev.md template includes Session Log"
assert_file_contains "$DEV" "Decision Log"                 "dev.md template includes Decision Log"

# Interview content present
assert_file_contains "$DEV" "Constraint"          "interview covers Constraints"
assert_file_contains "$DEV" "Dependenc"           "interview covers Dependencies"
assert_file_contains "$DEV" "one at a time"       "interview specifies asking one question at a time"

echo ""
echo "--- dev-mode: commands/dev.md contains git practices ---"

assert_file_contains "$DEV" "feat"               "dev.md covers feat branch type"
assert_file_contains "$DEV" "fix"                "dev.md covers fix branch type"
assert_file_contains "$DEV" "Conventional"       "dev.md references Conventional Commits"
assert_file_contains "$DEV" "global"             "dev.md contains global config restriction"

echo ""
echo "--- dev-mode: installer exists ---"

assert_file_exists "$REPO/install.js" "install.js exists"

if [[ -x "$REPO/install.js" ]]; then
  pass "install.js is executable"
else
  fail "install.js is not executable"
fi

summary
