#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE="$ROOT/third_party/gen1recomp"
PYTHON_BIN="${PYTHON:-python3}"

if [[ ! -f "$ENGINE/tools/modkit.py" ]]; then
  echo "Gen1Recomp is not initialized. Run: make bootstrap" >&2
  exit 2
fi

export MODKIT_LUAJIT="${MODKIT_LUAJIT:-${LUAJIT:-luajit}}"
exec "$PYTHON_BIN" "$ENGINE/tools/modkit.py" --repo "$ENGINE" "$@"
