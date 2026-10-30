#!/usr/bin/env python3
"""Build the deterministic, sandbox-safe Lua source bundle for a mod."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path, PurePosixPath

CONFIG = ".lua-bundle.json"
NAME = re.compile(r"^[a-z][a-z0-9_]*$")


def build_bundle(mod_dir: Path):
    mod_dir = mod_dir.resolve()
    config_path = mod_dir / CONFIG
    if not config_path.is_file():
        return None
    if config_path.is_symlink():
        raise ValueError("bundle config must not be a symlink")
    config = json.loads(config_path.read_text(encoding="utf-8"))
    if not isinstance(config, dict) or config.get("version") != 1:
        raise ValueError("bundle config version must be 1")

    output = config.get("output")
    if not isinstance(output, str) or "\\" in output:
        raise ValueError("bundle output must be a relative POSIX path")
    output_path = PurePosixPath(output)
    if (output_path.is_absolute() or ".." in output_path.parts
            or output_path.parts[:1] != ("lib",) or output_path.suffix != ".lua"):
        raise ValueError("bundle output must be a safe Lua path under lib/")

    modules = config.get("modules")
    if (not isinstance(modules, list) or not modules
            or any(not isinstance(x, str) or not NAME.fullmatch(x) for x in modules)):
        raise ValueError("bundle modules must be a non-empty list of simple module names")
    if len(set(modules)) != len(modules) or output_path.stem in modules:
        raise ValueError("bundle module names must be unique and distinct from the output")

    lib_dir = mod_dir / "lib"
    expected = {f"lib/{name}.lua" for name in modules}
    actual = {p.relative_to(mod_dir).as_posix() for p in lib_dir.glob("*.lua")
              if p.name != Path(output).name}
    if expected != actual:
        raise ValueError(f"bundle module list mismatch; missing={sorted(expected-actual)}, unlisted={sorted(actual-expected)}")

    lines = [
        "-- GENERATED FILE: do not edit; run make bundle MOD=<mod-id>.",
        "-- This is Lua source compiled by the engine's sandboxed load() at startup.",
        "local MODULE_FACTORIES = {",
    ]
    for name in modules:
        relative = f"lib/{name}.lua"
        source_path = mod_dir / relative
        if source_path.is_symlink() or not source_path.is_file():
            raise ValueError(f"missing or symlinked Lua source: {relative}")
        source = source_path.read_text(encoding="utf-8")
        source = source.replace("\r\n", "\n").replace("\r", "\n")
        if not source.strip() or "\0" in source:
            raise ValueError(f"empty or invalid source: {relative}")
        lines.extend([
            f'  ["{name}"] = function(loadModule)',
            f"-- BEGIN SOURCE: {relative}",
            source.rstrip("\n"),
            f"-- END SOURCE: {relative}",
            "  end,",
        ])

    lines.extend([
        "}",
        "local Bundle = {}",
        "function Bundle.new()",
        "  local loaded, loading = {}, {}",
        "  local function loadModule(name)",
        '    if type(name) ~= "string" then error("library module name must be a string", 2) end',
        "    local factory = MODULE_FACTORIES[name]",
        '    if type(factory) ~= "function" then error("library module is not present in generated bundle: " .. name, 2) end',
        "    if loaded[name] ~= nil then return loaded[name] end",
        '    if loading[name] then error("cyclic library import: " .. name, 2) end',
        "    loading[name] = true",
        "    local ok, module = pcall(factory, loadModule)",
        "    loading[name] = nil",
        '    if not ok then error(("library module %s failed: %s"):format(name, tostring(module)), 0) end',
        '    if type(module) ~= "table" then error(("library module %s must return a table"):format(name), 0) end',
        "    loaded[name] = module",
        "    return module",
        "  end",
        "  return { load = loadModule }",
        "end",
        "return Bundle",
        "",
    ])
    return output_path.as_posix(), "\n".join(lines), expected


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mod-dir", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    bundle = build_bundle(args.mod_dir)
    if bundle is None:
        raise SystemExit(f"No {CONFIG} found in {args.mod_dir}")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(bundle[1], encoding="utf-8", newline="\n")
    print(f"Built {args.output} from {len(bundle[2])} source module(s)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, UnicodeDecodeError, json.JSONDecodeError, ValueError) as exc:
        print(f"lua-bundle: {exc}", file=sys.stderr)
        raise SystemExit(1)
