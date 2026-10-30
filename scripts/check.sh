#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
g1r_require_engine

if ! command -v "$G1R_PYTHON" >/dev/null 2>&1; then
  echo "Python interpreter not found: $G1R_PYTHON" >&2
  exit 2
fi
g1r_require_luajit

echo "== Repository structure"
"$G1R_PYTHON" "$ROOT/scripts/discover_mods.py" --check

echo "== Mod lint (upstream no-ROM-content rules)"
MOD_COUNT=0
while IFS= read -r MOD_DIR; do
  [[ -n "$MOD_DIR" ]] || continue
  MOD_COUNT=$((MOD_COUNT + 1))
  echo "==> $(basename "$MOD_DIR")"
  "$ROOT/scripts/modkit.sh" lint "$MOD_DIR"
done < <("$G1R_PYTHON" "$ROOT/scripts/discover_mods.py")

if [[ "$MOD_COUNT" -eq 0 ]]; then
  echo "No mods to lint yet."
fi
echo "Repository checks passed."
