#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
g1r_require_engine
g1r_require_luajit

MOD_COUNT=0
TEST_COUNT=0
FAIL_COUNT=0

while IFS= read -r MOD_DIR; do
  [[ -n "$MOD_DIR" ]] || continue
  MOD_COUNT=$((MOD_COUNT + 1))
  MOD_ID="$(basename "$MOD_DIR")"
  echo "==> Tests: $MOD_ID"
  if [[ ! -d "$MOD_DIR/tests" ]]; then
    echo "ERROR: $MOD_ID has no tests/ directory." >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
    continue
  fi

  MOD_TEST_COUNT=0
  while IFS= read -r TEST_FILE; do
    [[ -n "$TEST_FILE" ]] || continue
    MOD_TEST_COUNT=$((MOD_TEST_COUNT + 1))
    TEST_COUNT=$((TEST_COUNT + 1))
    echo "    RUN $TEST_FILE"
    if ! (
      cd "$G1R_ENGINE"
      G1R_ENGINE_ROOT="$G1R_ENGINE" \
      G1R_MOD_DIR="$MOD_DIR" \
      G1R_MOD_ID="$MOD_ID" \
      "$G1R_LUAJIT" "$TEST_FILE"
    ); then
      echo "    FAIL $TEST_FILE" >&2
      FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
  done < <(find "$MOD_DIR/tests" -type f -name '*_test.lua' -print | LC_ALL=C sort)

  if [[ "$MOD_TEST_COUNT" -eq 0 ]]; then
    echo "ERROR: $MOD_ID has no tests/*_test.lua files." >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done < <("$G1R_PYTHON" "$ROOT/scripts/discover_mods.py")

if [[ "$MOD_COUNT" -eq 0 ]]; then
  echo "No mods found; no test suites to run yet."
fi
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "Test run failed: $FAIL_COUNT failure(s), $TEST_COUNT suite(s) executed." >&2
  exit 1
fi
echo "Test run passed: $TEST_COUNT suite(s) across $MOD_COUNT mod(s)."
