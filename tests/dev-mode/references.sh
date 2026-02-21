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

assert_file_contains "$FS" "Name"                "interview includes Name step"
assert_file_contains "$FS" "Goal"                "interview includes Goal step"
assert_file_contains "$FS" "Acceptance"          "interview includes Acceptance Criteria step"
assert_file_contains "$FS" "Constraint"          "interview includes Constraints step"
assert_file_contains "$FS" "Dependenc"           "interview includes Dependencies step"
assert_file_contains "$FS" "Open Question"       "interview includes Open Questions step"
assert_file_contains "$FS" "Progress"            "interview output format includes Progress section"
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
