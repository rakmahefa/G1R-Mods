#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/common.sh"
g1r_require_engine
g1r_require_luajit

MOD_ID="g1r_ci_template_smoke"
MOD_DIR="$ROOT/mods/$MOD_ID"
OUTPUT_DIR="$ROOT/build/template-smoke-dist"

if [[ -e "$MOD_DIR" ]]; then
  echo "Reserved smoke-test directory already exists: $MOD_DIR" >&2
  exit 2
fi

cleanup() {
  rm -rf "$MOD_DIR" "$OUTPUT_DIR"
}
trap cleanup EXIT

"$ROOT/scripts/new-mod.sh" "$MOD_ID"
"$ROOT/scripts/modkit.sh" lint "$MOD_DIR"

(
  cd "$G1R_ENGINE"
  G1R_ENGINE_ROOT="$G1R_ENGINE" \
  G1R_MOD_DIR="$MOD_DIR" \
  G1R_MOD_ID="$MOD_ID" \
  "$G1R_LUAJIT" "$MOD_DIR/tests/"$MOD_ID"_test.lua"
)

G1R_DIST_DIR="$OUTPUT_DIR" "$ROOT/scripts/package.sh" "$MOD_ID"

"$G1R_PYTHON" - "$OUTPUT_DIR/$MOD_ID-0.1.0.zip" <<'PY'
from pathlib import Path
import sys
import zipfile

package = Path(sys.argv[1])
if not package.is_file():
    raise SystemExit(f"Expected package was not created: {package}")
with zipfile.ZipFile(package) as archive:
    names = set(archive.namelist())
    required = {"manifest.json", "main.lua", "README.md", "mod.card"}
    missing = required - names
    if missing:
        raise SystemExit(f"Package is missing required files: {sorted(missing)}")
    leaked = sorted(name for name in names if name.endswith("_test.lua"))
    if leaked:
        raise SystemExit(f"Test files leaked into package: {leaked}")
print(f"Template smoke test passed: {package.name}")
PY
