#!/usr/bin/env bash
# Tests: source files and build output are correct
# - src/ topic files must all exist with expected content
# - stub/dev.md must point to the GitHub Pages URL
# - commands/dev.md (the build output) must contain all combined content

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

echo "--- dev-mode: source files exist ---"

# Context stubs (created by /dev on first run, but must exist in repo as templates)
assert_file_exists "$REPO/context/project.md"  "context/project.md exists"
assert_file_exists "$REPO/context/feature.md"  "context/feature.md exists"

# All src/ topic files
assert_file_exists "$REPO/src/01-header.md"           "src/01-header.md exists"
assert_file_exists "$REPO/src/02-project-context.md"  "src/02-project-context.md exists"
assert_file_exists "$REPO/src/03-feature-context.md"  "src/03-feature-context.md exists"
assert_file_exists "$REPO/src/04-feature-setup.md"    "src/04-feature-setup.md exists"
assert_file_exists "$REPO/src/05-git-practices.md"    "src/05-git-practices.md exists"
assert_file_exists "$REPO/src/06-session-behaviour.md" "src/06-session-behaviour.md exists"
assert_file_exists "$REPO/src/07-confirm.md"          "src/07-confirm.md exists"

# Stub and built command file
assert_file_exists "$REPO/stub/dev.md"     "stub/dev.md exists"
assert_file_exists "$REPO/commands/dev.md" "commands/dev.md exists"

echo ""
echo "--- dev-mode: stub points to GitHub Pages ---"

STUB="$REPO/stub/dev.md"
assert_file_contains "$STUB" "kusimari.github.io/k-mcp-devkit" "stub references GitHub Pages URL"
assert_file_contains "$STUB" "dev.md"                          "stub references dev.md on GitHub Pages"

echo ""
echo "--- dev-mode: src/04-feature-setup.md interview structure ---"

FS="$REPO/src/04-feature-setup.md"
assert_file_contains "$FS" "Requirements Interview"    "feature-setup includes Requirements Interview"
assert_file_contains "$FS" "Design Interview"          "feature-setup includes Design Interview"
assert_file_contains "$FS" "Testing Interview"         "feature-setup includes Testing Interview"
assert_file_contains "$FS" "Implementation Interview"  "feature-setup includes Implementation Interview"
assert_file_contains "$FS" "Git Setup"                 "feature-setup includes Git Setup section"
assert_file_contains "$FS" "worktree add"              "git setup includes worktree command"
assert_file_contains "$FS" "checkout -b"               "git setup includes branch command"
assert_file_contains "$FS" "commit-ish"                "feature-setup references commit-ish base"
assert_file_contains "$FS" "Feature Brief"             "template includes Feature Brief"
assert_file_contains "$FS" "Requirements Specification" "template includes Requirements Specification"
assert_file_contains "$FS" "Technical Design"          "template includes Technical Design section"
assert_file_contains "$FS" "Test Strategy"             "template includes Test Strategy section"
assert_file_contains "$FS" "Session Log"               "template includes Session Log"
assert_file_contains "$FS" "Decision Log"              "template includes Decision Log"
assert_file_contains "$FS" "Constraint"                "interview covers Constraints"
assert_file_contains "$FS" "Dependenc"                 "interview covers Dependencies"
assert_file_contains "$FS" "one at a time"             "interview specifies asking one question at a time"

echo ""
echo "--- dev-mode: src/05-git-practices.md content ---"

GIT="$REPO/src/05-git-practices.md"
assert_file_contains "$GIT" "feat"         "git practices covers feat branch type"
assert_file_contains "$GIT" "fix"          "git practices covers fix branch type"
assert_file_contains "$GIT" "Conventional" "git practices references Conventional Commits"
assert_file_contains "$GIT" "global"       "git practices contains global config restriction"

echo ""
echo "--- dev-mode: commands/dev.md (build output) contains all content ---"

DEV="$REPO/commands/dev.md"
assert_file_contains "$DEV" "Requirements Interview"   "build output includes Requirements Interview"
assert_file_contains "$DEV" "Conventional Commits"     "build output includes Conventional Commits"
assert_file_contains "$DEV" "context/project.md"       "build output references context/project.md"
assert_file_contains "$DEV" 'context/<argument>.md'    "build output resolves feature path"

echo ""
echo "--- dev-mode: installer exists ---"

assert_file_exists "$REPO/install.js" "install.js exists"
assert_file_exists "$REPO/build.js"   "build.js exists"

if [[ -x "$REPO/install.js" ]]; then
  pass "install.js is executable"
else
  fail "install.js is not executable"
fi

summary
