#!/usr/bin/env bash
# Tests: referenced files exist
# Every file that commands/dev.md or practices/feature-setup.md points to must exist
# in the repo so agents can read them after /dev is invoked.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

echo "--- dev-mode: referenced files exist ---"

# Context stubs (created by /dev on first run, but must exist in repo as templates)
assert_file_exists "$REPO/context/project.md"  "context/project.md exists"
assert_file_exists "$REPO/context/feature.md"  "context/feature.md exists"

# Practice files
assert_file_exists "$REPO/practices/git.md"           "practices/git.md exists"
assert_file_exists "$REPO/practices/feature-setup.md" "practices/feature-setup.md exists"

echo ""
echo "--- dev-mode: feature-setup.md interview structure ---"

FS="$REPO/practices/feature-setup.md"

# Four interview sections
assert_file_contains "$FS" "Requirements Interview"    "feature-setup.md includes Requirements Interview"
assert_file_contains "$FS" "Design Interview"          "feature-setup.md includes Design Interview"
assert_file_contains "$FS" "Testing Interview"         "feature-setup.md includes Testing Interview"
assert_file_contains "$FS" "Implementation Interview"  "feature-setup.md includes Implementation Interview"

# Git setup section
assert_file_contains "$FS" "Git Setup"           "feature-setup.md includes Git Setup section"
assert_file_contains "$FS" "worktree add"        "git setup includes worktree command"
assert_file_contains "$FS" "checkout -b"         "git setup includes branch command"
assert_file_contains "$FS" "commit-ish"          "git setup references commit-ish base"

# Template sections present
assert_file_contains "$FS" "Feature Brief"                "template includes Feature Brief"
assert_file_contains "$FS" "Requirements Specification"   "template includes Requirements Specification"
assert_file_contains "$FS" "Technical Design"             "template includes Technical Design section"
assert_file_contains "$FS" "Test Strategy"                "template includes Test Strategy section"
assert_file_contains "$FS" "Session Log"                  "template includes Session Log"
assert_file_contains "$FS" "Decision Log"                 "template includes Decision Log"

# Content still present
assert_file_contains "$FS" "Constraint"          "interview covers Constraints"
assert_file_contains "$FS" "Dependenc"           "interview covers Dependencies"
assert_file_contains "$FS" "one at a time"       "interview specifies asking one question at a time"

echo ""
echo "--- dev-mode: practices/git.md content ---"

GIT="$REPO/practices/git.md"

assert_file_contains "$GIT" "feat"               "git.md covers feat branch type"
assert_file_contains "$GIT" "fix"                "git.md covers fix branch type"
assert_file_contains "$GIT" "Conventional"       "git.md references Conventional Commits"
assert_file_contains "$GIT" "global"             "git.md contains global config restriction"

echo ""
echo "--- dev-mode: agent scripts exist ---"

assert_file_exists "$REPO/agents/claude-code.sh" "agents/claude-code.sh exists"
assert_file_exists "$REPO/agents/gemini.sh"      "agents/gemini.sh exists"
assert_file_exists "$REPO/agents/kiro.sh"        "agents/kiro.sh exists"

for script in "$REPO/agents/"*.sh "$REPO/install.sh"; do
  if [[ -x "$script" ]]; then
    pass "$(basename "$script") is executable"
  else
    fail "$(basename "$script") is not executable"
  fi
done

summary
