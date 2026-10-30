#!/usr/bin/env bash
set -euo pipefail

G1R_ROOT="$(cd "$(dirname "\${BASH_SOURCE[0]}")/.." && pwd)"
G1R_ENGINE="\${G1R_ROOT}/third_party/gen1recomp"
G1R_PYTHON="\${PYTHON:-python3}"
G1R_LUAJIT="\${LUAJIT:-luajit}"

g1r_require_engine() {
  if [[ ! -f "\${G1R_ENGINE}/tools/modkit.py" ]]; then
    printf 'Gen1Recomp submodule is missing. Run: make bootstrap\n' >&2
    return 2
  fi
  if [[ ! -f "\${G1R_ENGINE}/.github/actions/setup-luajit/action.yml" ]]; then
    printf 'The pinned engine checkout is incomplete: %s\n' "\${G1R_ENGINE}" >&2
    return 2
  fi
}

g1r_require_luajit() {
  if ! command -v "\${G1R_LUAJIT}" >/dev/null 2>&1; then
    printf "LuaJIT was not found (looked for '%s'). Install LuaJIT or set LUAJIT=/path/to/luajit.\n" "\${G1R_LUAJIT}" >&2
    return 2
  fi
}
