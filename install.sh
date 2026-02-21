#!/usr/bin/env bash
# k-mcp-devkit installer
#
# Installs slash commands / context files into the target coding agent.
#
# Usage:
#   ./install.sh --agent <name> [--global]
#
# Agents:
#   claude-code   Claude Code  (.claude/commands/ or ~/.claude/commands/)
#   gemini        Gemini CLI   (GEMINI.md or ~/.gemini/GEMINI.md)
#   kiro          Amazon Kiro  (.kiro/steering/)
#
# Flags:
#   --global      Install at user scope rather than project scope
#                 (not supported by all agents)
#
# Examples:
#   ./install.sh --agent claude-code
#   ./install.sh --agent claude-code --global
#   ./install.sh --agent gemini
#   ./install.sh --agent kiro

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENTS_DIR="$SCRIPT_DIR/agents"

AGENT=""
SCOPE_FLAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)   AGENT="${2:?"--agent requires a value"}"; shift 2 ;;
    --global)  SCOPE_FLAG="--global"; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \?//'; exit 0 ;;
    *)         echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$AGENT" ]]; then
  echo "Error: --agent is required." >&2
  echo "Run ./install.sh --help for usage." >&2
  exit 1
fi

AGENT_SCRIPT="$AGENTS_DIR/$AGENT.sh"
if [[ ! -f "$AGENT_SCRIPT" ]]; then
  echo "Error: unknown agent '$AGENT'." >&2
  echo "Available: $(ls "$AGENTS_DIR"/*.sh | xargs -I{} basename {} .sh | tr '\n' ' ')" >&2
  exit 1
fi

echo "Installing for: $AGENT${SCOPE_FLAG:+ (global)}"
echo ""
bash "$AGENT_SCRIPT" $SCOPE_FLAG
