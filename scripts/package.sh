#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="\${PYTHON:-python3}"
OUTPUT_DIR="\${G1R_DIST_DIR:-$ROOT/dist}"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

if [[ -n "\${1:-}" ]]; then
  exec "$PYTHON_BIN" "$ROOT/scripts/package.py" --output-dir "$OUTPUT_DIR" --mod "$1"
else
  exec "$PYTHON_BIN" "$ROOT/scripts/package.py" --output-dir "$OUTPUT_DIR"
fi
