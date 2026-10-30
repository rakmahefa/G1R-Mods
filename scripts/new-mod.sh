#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${PYTHON:-python3}"
MOD_ID="${1:-}"

if [[ ! "$MOD_ID" =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "Usage: scripts/new-mod.sh <mod-id> (letters, numbers, _ and - only)" >&2
  exit 2
fi
TEMPLATE="$ROOT/templates/mod-template"
DEST="$ROOT/mods/$MOD_ID"
[[ -d "$TEMPLATE" ]] || { echo "Template directory missing: $TEMPLATE" >&2; exit 2; }
[[ ! -e "$DEST" ]] || { echo "Refusing to overwrite existing mod: $DEST" >&2; exit 2; }

mkdir -p "$ROOT/mods"
cp -R "$TEMPLATE" "$DEST"

"$PYTHON_BIN" - "$DEST" "$MOD_ID" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
mod_id = sys.argv[2]
display_name = " ".join(part.capitalize() for part in mod_id.replace("-", "_").split("_"))
for path in sorted(root.rglob("*")):
    if path.is_file():
        try:
            content = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        content = content.replace("__MOD_ID__", mod_id).replace("__MOD_NAME__", display_name)
        path.write_text(content, encoding="utf-8")
for path in sorted(root.rglob("*"), reverse=True):
    if path.is_file() and "__MOD_ID__" in path.name:
        path.rename(path.with_name(path.name.replace("__MOD_ID__", mod_id)))
PY

echo "Created $DEST"
echo "Next: edit manifest.json, main.lua, README.md, and mod.card; then run make check && make test."
