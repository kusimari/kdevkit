#!/usr/bin/env bash
# Tests: claude-code install
# Uses --local so tests run against build/dev.md without needing network.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "--- install: claude-code (project scope, --local) ---"

( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" claude-code --local ) >/dev/null 2>&1

assert_dir_exists  "$TMP/.claude/commands"           ".claude/commands/ directory created"
assert_file_exists "$TMP/.claude/commands/dev.md"    "dev.md installed to .claude/commands/"
assert_file_contains "$TMP/.claude/commands/dev.md" "kdevkit:built:"     "installed dev.md has build timestamp"
assert_file_contains "$TMP/.claude/commands/dev.md" "kdevkit:source:local" "installed dev.md has source metadata"
assert_file_contains "$TMP/.claude/commands/dev.md" "feature-setup.md"   "installed dev.md references companion files"
assert_dir_exists  "$TMP/.claude/commands/kdevkit"                            "kdevkit/ companion dir created"
assert_file_exists "$TMP/.claude/commands/kdevkit/feature-setup.md"           "feature-setup.md installed to kdevkit/"
assert_file_exists "$TMP/.claude/commands/kdevkit/git-practices.md"           "git-practices.md installed to kdevkit/"
assert_file_contains "$TMP/.claude/commands/kdevkit/feature-setup.md" "Requirements:" "feature-setup.md has interview content"
assert_file_contains "$TMP/.claude/commands/kdevkit/git-practices.md" "Conventional Commits"   "git-practices.md has git content"

echo ""
echo "--- install: claude-code (global scope, --local) ---"

FAKE_HOME="$TMP/home"
( cd "$TMP" && HOME="$FAKE_HOME" node "$REPO/install.js" claude-code --local --global ) >/dev/null 2>&1

assert_dir_exists  "$FAKE_HOME/.claude/commands"        "~/.claude/commands/ directory created"
assert_file_exists "$FAKE_HOME/.claude/commands/dev.md" "dev.md installed globally"
assert_file_contains "$FAKE_HOME/.claude/commands/dev.md" "kdevkit:source:local" "globally installed dev.md has source metadata"

echo ""
echo "--- install: claude-code (idempotent — re-install overwrites cleanly) ---"

echo "corrupted" > "$TMP/.claude/commands/dev.md"
( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" claude-code --local ) >/dev/null 2>&1
assert_file_contains "$TMP/.claude/commands/dev.md" "kdevkit:built:"      "re-install restores build timestamp"
assert_file_contains "$TMP/.claude/commands/kdevkit/feature-setup.md" "Requirements:" "re-install restores companion file"

echo ""
echo "--- install: claude-code (positional and --agent flag both work) ---"

TMP2="$(mktemp -d)"
trap 'rm -rf "$TMP2"' EXIT
( cd "$TMP2" && HOME="$TMP2/home" node "$REPO/install.js" --agent claude-code --local ) >/dev/null 2>&1
assert_file_exists "$TMP2/.claude/commands/dev.md" "dev.md installed via --agent flag"
assert_file_contains "$TMP2/.claude/commands/dev.md" "kdevkit:source:local" "--agent flag produces file with source metadata"

summary
