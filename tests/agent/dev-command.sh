#!/usr/bin/env bash
# Tests: agent integration — /dev command via build/install.js
#
# Part 1: Install test (3 dummy projects, one per agent)
#   For each agent: create a dummy project, run build/install.js <agent>,
#   verify the correct file structure was created with the full dev.md content.
#
# Part 2: Agent invocation test (requires claude CLI + CLAUDE_API_KEY)
#   Installs dev command for claude-code into a dummy project, then invokes
#   the claude CLI with the dev instructions and verifies it creates
#   context/project.md and a context/<feature>.md file.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

# ---------------------------------------------------------------------------
# Part 1: install into three dummy projects
# ---------------------------------------------------------------------------

echo "--- agent/dev-command: install into dummy project (claude-code) ---"

TMP_CC="$(mktemp -d)"
trap 'rm -rf "$TMP_CC"' EXIT
( cd "$TMP_CC" && HOME="$TMP_CC/home" node "$REPO/build/install.js" claude-code ) >/dev/null 2>&1

assert_dir_exists  "$TMP_CC/.claude/commands"           ".claude/commands/ created"
assert_file_exists "$TMP_CC/.claude/commands/dev.md"    "dev.md installed for claude-code"
assert_files_identical \
  "$REPO/build/dev.md" \
  "$TMP_CC/.claude/commands/dev.md" \
  "claude-code: installed file matches build/dev.md"

echo ""
echo "--- agent/dev-command: install into dummy project (gemini) ---"

TMP_GEM="$(mktemp -d)"
trap 'rm -rf "$TMP_GEM"' EXIT
( cd "$TMP_GEM" && HOME="$TMP_GEM/home" node "$REPO/build/install.js" gemini ) >/dev/null 2>&1

assert_file_exists "$TMP_GEM/GEMINI.md" "GEMINI.md created for gemini"
assert_file_contains "$TMP_GEM/GEMINI.md" "k-mcp-devkit: dev" "GEMINI.md contains dev section heading"
assert_file_contains "$TMP_GEM/GEMINI.md" "Requirements Interview" "GEMINI.md contains full dev content"

echo ""
echo "--- agent/dev-command: install into dummy project (kiro) ---"

TMP_KI="$(mktemp -d)"
trap 'rm -rf "$TMP_KI"' EXIT
( cd "$TMP_KI" && node "$REPO/build/install.js" kiro ) >/dev/null 2>&1

assert_dir_exists  "$TMP_KI/.kiro/steering"           ".kiro/steering/ created"
assert_file_exists "$TMP_KI/.kiro/steering/dev.md"    "dev.md installed for kiro"
assert_files_identical \
  "$REPO/build/dev.md" \
  "$TMP_KI/.kiro/steering/dev.md" \
  "kiro: installed file matches build/dev.md"

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

# Create a minimal project context so the agent can skip the project interview
mkdir -p "$TMP_CC/context"
cat > "$TMP_CC/context/project.md" <<'EOF'
Test project used by k-mcp-devkit integration tests. Node.js. No hard constraints.
EOF

# Pass the full dev.md content as the prompt, with a feature name argument
DEV_CONTENT="$(cat "$TMP_CC/.claude/commands/dev.md")"
PROMPT="$(printf '%s\n\nThe feature argument is: ci-test' "$DEV_CONTENT")"

echo "  Invoking claude CLI (this may take a moment)..."
OUTPUT="$(cd "$TMP_CC" && claude --output-format text -p "$PROMPT" 2>&1)" || true

# The agent should have created context/ci-test.md after following Step 2
FEATURE_FILE="$TMP_CC/context/ci-test.md"
if [[ -f "$FEATURE_FILE" ]]; then
  pass "context/ci-test.md created by agent"
else
  FOUND="$(find "$TMP_CC/context" -name "*.md" ! -name "project.md" 2>/dev/null | head -1)"
  if [[ -n "$FOUND" ]]; then
    pass "context feature file created: $(basename "$FOUND")"
  else
    fail "no feature file created under context/ (agent output below)"
    echo "$OUTPUT" | head -40 | sed 's/^/    /'
  fi
fi

# project.md should still be present
assert_file_exists "$TMP_CC/context/project.md" "context/project.md preserved after agent run"

summary
