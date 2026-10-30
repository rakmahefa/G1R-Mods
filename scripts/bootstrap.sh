#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

INSTALL_PYTHON_DEPS=0
case "\${1:-}" in
  "") ;;
  --install-python-deps) INSTALL_PYTHON_DEPS=1 ;;
  -h|--help)
    echo "Usage: scripts/bootstrap.sh [--install-python-deps]"
    echo "Initializes the pinned Gen1Recomp submodule and checks local tools."
    exit 0
    ;;
  *) echo "Unknown option: $1" >&2; exit 2 ;;
esac

command -v git >/dev/null 2>&1 || { echo "git is required" >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "python3 is required" >&2; exit 2; }

git submodule sync --recursive
git submodule update --init --recursive --depth 1

ENGINE="$ROOT/third_party/gen1recomp"
test -f "$ENGINE/tools/modkit.py" || {
  echo "Gen1Recomp submodule checkout is incomplete: $ENGINE" >&2
  exit 2
}

if [ "$INSTALL_PYTHON_DEPS" = "1" ]; then
  python3 -m venv "$ROOT/.venv"
  "$ROOT/.venv/bin/python" -m pip install --upgrade pip
  "$ROOT/.venv/bin/python" -m pip install -r "$ROOT/requirements-dev.txt"
  echo "Python dependencies installed in .venv/"
elif ! python3 -c 'import PIL' >/dev/null 2>&1; then
  echo "Pillow is not installed. It is needed when mod assets are linted."
  echo "Install into an isolated environment with: scripts/bootstrap.sh --install-python-deps"
fi

if command -v luajit >/dev/null 2>&1; then
  luajit -v
else
  echo "LuaJIT is not installed. Install it before running make check or make test."
  echo "Ubuntu/Debian: sudo apt install luajit"
  echo "macOS:         brew install luajit"
fi

printf '\nEngine pinned at: '
git -C "$ENGINE" rev-parse HEAD
echo "Bootstrap complete."
