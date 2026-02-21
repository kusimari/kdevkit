#!/usr/bin/env bash
# Shared test utilities. Source this file; do not execute it directly.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "${GREEN}PASS${NC}: $1"; PASS=$(( PASS + 1 )); }
fail() { echo -e "${RED}FAIL${NC}: $1"; FAIL=$(( FAIL + 1 )); }
skip() { echo -e "${YELLOW}SKIP${NC}: $1"; }

assert_file_exists() {
  local file="$1" desc="${2:-$1}"
  [[ -f "$file" ]] && pass "$desc" || fail "$desc (missing: $file)"
}

assert_dir_exists() {
  local dir="$1" desc="${2:-$1}"
  [[ -d "$dir" ]] && pass "$desc" || fail "$desc (missing dir: $dir)"
}

assert_file_contains() {
  local file="$1" pattern="$2" desc="${3:-contains '$2'}"
  if [[ ! -f "$file" ]]; then
    fail "$desc (file missing: $file)"
  elif grep -qF "$pattern" "$file"; then
    pass "$desc"
  else
    fail "$desc (pattern not found in $file: $pattern)"
  fi
}

assert_files_identical() {
  local a="$1" b="$2" desc="${3:-$1 matches $2}"
  if diff -q "$a" "$b" >/dev/null 2>&1; then
    pass "$desc"
  else
    fail "$desc (files differ)"
    diff "$a" "$b" | head -20 | sed 's/^/    /'
  fi
}

assert_exit_ok() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    pass "$desc"
  else
    fail "$desc (command failed: $*)"
  fi
}

# Print suite summary and exit with appropriate code.
summary() {
  echo ""
  echo "  $PASS passed, $FAIL failed"
  [[ $FAIL -eq 0 ]] && return 0 || return 1
}
