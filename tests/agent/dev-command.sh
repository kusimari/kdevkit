#!/usr/bin/env bash
# Tests: agent integration — /dev command via install.js --local
#
# Part 1: Install test (3 dummy projects, one per agent)
#   For each agent: create a dummy project, run install.js <agent> --local,
#   verify the correct file structure was created with the full dev.md content.
#
# Part 2: Agent invocation test (requires claude CLI + CLAUDE_API_KEY)
#   Installs dev command for claude-code, then invokes the claude CLI with the
#   dev instructions and verifies it creates .kdevkit/project.md and a feature file.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

# ---------------------------------------------------------------------------
# Part 1: install into three dummy projects
# ---------------------------------------------------------------------------

echo "--- agent/dev-command: install into dummy project (claude-code) ---"

TMP_CC="$(mktemp -d)"
trap 'rm -rf "$TMP_CC"' EXIT
( cd "$TMP_CC" && HOME="$TMP_CC/home" node "$REPO/install.js" claude-code --local ) >/dev/null 2>&1

assert_dir_exists  "$TMP_CC/.claude/commands"           ".claude/commands/ created"
assert_file_exists "$TMP_CC/.claude/commands/dev.md"    "dev.md installed for claude-code"
assert_file_contains "$TMP_CC/.claude/commands/dev.md" "kdevkit:source:local" "claude-code: installed file has source metadata"

echo ""
echo "--- agent/dev-command: install into dummy project (gemini) ---"

TMP_GEM="$(mktemp -d)"
trap 'rm -rf "$TMP_GEM"' EXIT
( cd "$TMP_GEM" && HOME="$TMP_GEM/home" node "$REPO/install.js" gemini --local ) >/dev/null 2>&1

assert_file_exists "$TMP_GEM/GEMINI.md" "GEMINI.md created for gemini"
assert_file_contains "$TMP_GEM/GEMINI.md" "kdevkit: dev" "GEMINI.md contains dev section heading"
assert_file_contains "$TMP_GEM/GEMINI.md" "Requirements Interview" "GEMINI.md contains feature-setup content"

echo ""
echo "--- agent/dev-command: install into dummy project (kiro) ---"

TMP_KI="$(mktemp -d)"
trap 'rm -rf "$TMP_KI"' EXIT
( cd "$TMP_KI" && node "$REPO/install.js" kiro --local ) >/dev/null 2>&1

assert_dir_exists  "$TMP_KI/.kiro/steering"           ".kiro/steering/ created"
assert_file_exists "$TMP_KI/.kiro/steering/dev.md"    "dev.md installed for kiro"
assert_file_contains "$TMP_KI/.kiro/steering/dev.md" "kdevkit:source:local" "kiro: installed file has source metadata"

# ---------------------------------------------------------------------------
# Part 2: agent invocation (skipped unless claude CLI + API key are present)
# ---------------------------------------------------------------------------

echo ""
echo "--- agent/dev-command: claude CLI invocation ---"

if ! command -v claude >/dev/null 2>&1; then
  skip "claude CLI not found — skipping live agent test"
  summary
  exit 0
fi

if [[ -z "${CLAUDE_API_KEY:-}" && -z "${ANTHROPIC_API_KEY:-}" ]]; then
  skip "CLAUDE_API_KEY / ANTHROPIC_API_KEY not set — skipping live agent test"
  summary
  exit 0
fi

# Pre-create project context so the agent can skip the project interview
mkdir -p "$TMP_CC/.kdevkit"
cat > "$TMP_CC/.kdevkit/project.md" <<'EOF'
Test project for kdevkit integration tests. Node.js. No hard constraints.
EOF

DEV_CONTENT="$(cat "$TMP_CC/.claude/commands/dev.md")"
PROMPT="$(printf '%s\n\nThe feature argument is: ci-test' "$DEV_CONTENT")"

echo "  Invoking claude CLI (this may take a moment)..."
OUTPUT="$(cd "$TMP_CC" && claude --output-format text -p "$PROMPT" 2>&1)" || true

FEATURE_FILE="$TMP_CC/.kdevkit/feature/ci-test.md"
if [[ -f "$FEATURE_FILE" ]]; then
  pass ".kdevkit/feature/ci-test.md created by agent"
else
  FOUND="$(find "$TMP_CC/.kdevkit/feature" -name "*.md" ! -name "project.md" 2>/dev/null | head -1)"
  if [[ -n "$FOUND" ]]; then
    pass "context feature file created: $(basename "$FOUND")"
  else
    fail "no feature file created under .kdevkit/feature/ (agent output below)"
    echo "$OUTPUT" | head -40 | sed 's/^/    /'
  fi
fi

assert_file_exists "$TMP_CC/.kdevkit/project.md" ".kdevkit/project.md preserved after agent run"

summary
