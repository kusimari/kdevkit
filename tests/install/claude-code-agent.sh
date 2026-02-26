#!/usr/bin/env bash
# Tests: claude-code-agent install
# Uses --local so tests run against build/agent.md without needing network.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: claude-code-agent (project scope, --local) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" claude-code-agent --local ) >/dev/null 2>&1

assert_dir_exists  "$TMP/.claude/agents"                            ".claude/agents/ directory created"
assert_file_exists "$TMP/.claude/agents/dev.md"                    "dev.md installed to .claude/agents/"
assert_file_exists "$TMP/.claude/agents/install-agent.md"          "install-agent.md installed to .claude/agents/"
assert_file_contains "$TMP/.claude/agents/dev.md" "name: dev"      "installed dev.md has name in frontmatter"
assert_file_contains "$TMP/.claude/agents/dev.md" "description:"   "installed dev.md has description in frontmatter"
assert_file_contains "$TMP/.claude/agents/dev.md" "kdevkit:built:" "installed dev.md has build timestamp"
assert_file_contains "$TMP/.claude/agents/dev.md" "kdevkit:source:local" "installed dev.md has source metadata"
assert_file_contains "$TMP/.claude/agents/dev.md" "feature-setup.md" "installed dev.md references companion files"
assert_dir_exists  "$TMP/.claude/agents/kdevkit"                           "kdevkit/ companion dir created"
assert_file_exists "$TMP/.claude/agents/kdevkit/feature-setup.md"          "feature-setup.md installed to kdevkit/"
assert_file_exists "$TMP/.claude/agents/kdevkit/git-practices.md"          "git-practices.md installed to kdevkit/"
assert_file_contains "$TMP/.claude/agents/kdevkit/feature-setup.md" "Requirements:" "feature-setup.md has interview content"
assert_file_contains "$TMP/.claude/agents/kdevkit/git-practices.md" "Conventional Commits" "git-practices.md has git content"
assert_file_contains "$TMP/.claude/agents/install-agent.md" "name: install-agent" "install-agent.md has correct name"
assert_file_contains "$TMP/.claude/agents/install-agent.md" "Step 1" "install-agent.md has instructions"

echo ""
echo "--- install: claude-code-agent (global scope, --local) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" node "$REPO/install.js" claude-code-agent --local --global ) >/dev/null 2>&1

assert_dir_exists  "$FAKE_HOME/.claude/agents"             "~/.claude/agents/ directory created"
assert_file_exists "$FAKE_HOME/.claude/agents/dev.md"      "dev.md installed globally"
assert_file_exists "$FAKE_HOME/.claude/agents/install-agent.md" "install-agent.md installed globally"
assert_file_contains "$FAKE_HOME/.claude/agents/dev.md" "kdevkit:source:local" "globally installed dev.md has source metadata"
assert_file_contains "$FAKE_HOME/.claude/agents/dev.md" "name: dev" "globally installed dev.md has frontmatter"

echo ""
echo "--- install: claude-code-agent (idempotent — re-install overwrites cleanly) ---"

echo "corrupted" > "$TMP/.claude/agents/dev.md"
( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" claude-code-agent --local ) >/dev/null 2>&1
assert_file_contains "$TMP/.claude/agents/dev.md" "kdevkit:built:"      "re-install restores build timestamp"
assert_file_contains "$TMP/.claude/agents/dev.md" "name: dev"           "re-install restores frontmatter"
assert_file_contains "$TMP/.claude/agents/kdevkit/feature-setup.md" "Requirements:" "re-install restores companion file"

echo ""
echo "--- install: claude-code-agent (agents/ not commands/) ---"

# Ensure no commands/ directory was created
if [[ -d "$TMP/.claude/commands" ]]; then
  fail ".claude/commands/ must not be created by claude-code-agent installer"
else
  pass ".claude/commands/ not created (correct: agents use .claude/agents/)"
fi

echo ""
echo "--- install: claude-code-agent (--agent flag works) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT
( cd "$TMP2" && HOME="$TMP2/home" node "$REPO/install.js" --agent claude-code-agent --local ) >/dev/null 2>&1
assert_file_exists "$TMP2/.claude/agents/dev.md" "dev.md installed via --agent flag"
assert_file_contains "$TMP2/.claude/agents/dev.md" "kdevkit:source:local" "--agent flag produces file with source metadata"

summary
