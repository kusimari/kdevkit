#!/usr/bin/env bash
# Run all test suites and report overall results.
# Usage: bash tests/run.sh [suite-glob]
#   bash tests/run.sh                       # run everything
#   bash tests/run.sh tests/install/*.sh    # run only install suites

set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

if [[ $# -eq 0 ]]; then
  SUITES=(
    "$REPO/tests/install/claude-code.sh"
    "$REPO/tests/install/gemini.sh"
    "$REPO/tests/install/kiro.sh"
    "$REPO/tests/dev-mode/prompt.sh"
    "$REPO/tests/dev-mode/references.sh"
    "$REPO/tests/agent/dev-command.sh"
  )
else
  SUITES=("$@")
fi

SUITE_PASS=0
SUITE_FAIL=0
FAILED_SUITES=()

for suite in "${SUITES[@]}"; do
  [[ -z "$suite" ]] && continue
  echo ""
  echo -e "${BOLD}$(basename "$suite")${NC}"
  echo "=============================="
  if bash "$suite"; then
    SUITE_PASS=$(( SUITE_PASS + 1 ))
  else
    SUITE_FAIL=$(( SUITE_FAIL + 1 ))
    FAILED_SUITES+=("$(basename "$suite")")
  fi
done

echo ""
echo "=============================="
if [[ $SUITE_FAIL -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}All $SUITE_PASS suite(s) passed.${NC}"
  exit 0
else
  echo -e "${RED}${BOLD}$SUITE_FAIL suite(s) failed: ${FAILED_SUITES[*]}${NC}"
  echo -e "${GREEN}$SUITE_PASS suite(s) passed.${NC}"
  exit 1
fi
