#!/usr/bin/env bash
# Tests: agent integration — /dev command via local install
#
# Part 1: Install test
#   Creates a dummy project, runs node install.js --agent claude-code --local,
#   and verifies the installed file is the full built commands/dev.md.
#
# Part 2: Agent invocation test (requires claude CLI + CLAUDE_API_KEY)
#   Invokes the claude CLI with the /dev command and verifies it creates
#   context/project.md and a context/<feature>.md file.

set -euo pipefail
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
source "$REPO/tests/helpers.sh"

# ---------------------------------------------------------------------------
# Part 1: install verification in a dummy project
# ---------------------------------------------------------------------------

echo "--- agent/dev-command: install into dummy project (--local) ---"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Install local build into the dummy project
( cd "$TMP" && HOME="$TMP/home" node "$REPO/install.js" --agent claude-code --local ) >/dev/null 2>&1

assert_dir_exists  "$TMP/.claude/commands"           ".claude/commands/ created in dummy project"
assert_file_exists "$TMP/.claude/commands/dev.md"    "dev.md installed into dummy project"
assert_files_identical \
  "$REPO/commands/dev.md" \
  "$TMP/.claude/commands/dev.md" \
  "installed file matches local build (commands/dev.md)"

# Sanity: installed file is NOT the stub
if ! diff -q "$REPO/stub/dev.md" "$TMP/.claude/commands/dev.md" >/dev/null 2>&1; then
  pass "installed file is the full build, not the stub"
else
  fail "installed file is identical to stub — --local had no effect"
fi

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

# Create a minimal project context so the agent can skip the interview
mkdir -p "$TMP/context"
cat > "$TMP/context/project.md" <<'EOF'
Test project used by k-mcp-devkit integration tests. Node.js. No hard constraints.
EOF

FEATURE_FILE="$TMP/context/ci-test.md"

# Invoke claude with the /dev command and a feature name argument.
# We use --output-format text and pipe /dev to stdin as a prompt.
# Claude Code's /dev command is a slash command; when invoked non-interactively
# we pass it as a plain prompt so the model processes the instructions.
DEV_CONTENT="$(cat "$TMP/.claude/commands/dev.md")"

PROMPT="$(cat <<EOF
${DEV_CONTENT}

The feature argument is: ci-test
EOF
)"

echo "  Invoking claude CLI (this may take a moment)..."
OUTPUT="$(cd "$TMP" && claude --output-format text -p "$PROMPT" 2>&1)" || true

# The agent should have created context/ci-test.md after following Step 2
if [[ -f "$FEATURE_FILE" ]]; then
  pass "context/ci-test.md created by agent"
else
  # Some runs create the file with a slightly different name; check broadly
  FOUND="$(find "$TMP/context" -name "*.md" ! -name "project.md" 2>/dev/null | head -1)"
  if [[ -n "$FOUND" ]]; then
    pass "context feature file created: $(basename "$FOUND")"
  else
    fail "no feature file created under context/ (agent output below)"
    echo "$OUTPUT" | head -40 | sed 's/^/    /'
  fi
fi

# project.md should still be present (not deleted by the agent)
assert_file_exists "$TMP/context/project.md" "context/project.md preserved after agent run"

summary
