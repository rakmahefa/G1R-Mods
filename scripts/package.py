#!/usr/bin/env python3
"""Build deterministic installable ZIPs for mods in this monorepo."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import stat
import sys
import zipfile
from pathlib import Path

from build_lua_bundle import build_bundle

ROOT = Path(__file__).resolve().parent.parent
MODS_DIR = ROOT / "mods"


def load_mods(selected: str | None) -> list[Path]:
    candidates = sorted(
        (path for path in MODS_DIR.iterdir() if path.is_dir() and not path.name.startswith(".")),
        key=lambda path: path.name.casefold(),
    ) if MODS_DIR.exists() else []
    result: list[Path] = []
    for mod_dir in candidates:
        manifest_path = mod_dir / "manifest.json"
        if not manifest_path.is_file():
            continue
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        if selected and manifest.get("id") != selected:
            continue
        result.append(mod_dir)
    if selected and not result:
        raise SystemExit(f"No mod with id {selected!r} was found in mods/")
    return result


def files_for(mod_dir: Path) -> list[Path]:
    ignore_file = mod_dir / ".modkitignore"
    ignored = {
        line.strip()
        for line in ignore_file.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    } if ignore_file.is_file() else set()

    files: list[Path] = []
    for base, dirs, names in os.walk(mod_dir, followlinks=False):
        base_path = Path(base)
        dirs[:] = [name for name in dirs if not name.startswith(".")
                   and name not in {".git", "__pycache__", ".modkit", ".vscode"}]
        for name in names:
            path = base_path / name
            if path.is_symlink():
                raise SystemExit(f"Refusing to package symlink: {path.relative_to(mod_dir)}")
            if name.startswith(".") and name != ".luarc.json":
                continue
            relative = path.relative_to(mod_dir).as_posix()
            if relative in ignored or relative == ".modkitignore":
                continue
            files.append(path)
    return sorted(files, key=lambda path: path.relative_to(mod_dir).as_posix())


def build_one(mod_dir: Path, output_dir: Path) -> Path:
    manifest_path = mod_dir / "manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    mod_id = str(manifest.get("id", ""))
    version = str(manifest.get("version", ""))
    if not re.fullmatch(r"[A-Za-z0-9_-]+", mod_id):
        raise SystemExit(f"Invalid mod id in {manifest_path}")
    if mod_id != mod_dir.name:
        raise SystemExit(f"{mod_dir}: directory name must match manifest id {mod_id!r}")
    if not version or any(char in version for char in ("/", "\\", "\0")):
        raise SystemExit(f"Invalid version in {manifest_path}")

    files = files_for(mod_dir)
    relative_paths = {path.relative_to(mod_dir).as_posix() for path in files}
    if "manifest.json" not in relative_paths or manifest.get("entry") not in relative_paths:
        raise SystemExit(f"{mod_id}: manifest.json and its entry must be in the package")

    test_files = [
        path.relative_to(mod_dir).as_posix()
        for path in (mod_dir / "tests").rglob("*_test.lua")
    ] if (mod_dir / "tests").exists() else []
    ignore_file = mod_dir / ".modkitignore"
    ignored = {
        line.strip()
        for line in ignore_file.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    } if ignore_file.is_file() else set()
    missing = sorted(set(test_files) - ignored)
    if missing:
        raise SystemExit(f"{mod_id}: add test paths to .modkitignore: {', '.join(missing)}")

    bundle = build_bundle(mod_dir)
    bundle_output, bundle_text, bundled_sources = bundle or (None, None, set())
    entries: list[tuple[str, bytes, int]] = []
    for path in files:
        relative = path.relative_to(mod_dir).as_posix()
        if relative in bundled_sources:
            continue
        mode = 0o100755 if path.stat().st_mode & stat.S_IXUSR else 0o100644
        entries.append((relative, path.read_bytes(), mode))

    if bundle is not None:
        if any(rel == bundle_output for rel, _, _ in entries):
            raise SystemExit(f"{mod_id}: generated bundle path already exists in source files")
        entries.append((bundle_output, bundle_text.encode("utf-8"), 0o100644))
    entries.sort(key=lambda row: row[0])

    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{mod_id}-{version}.zip"
    with zipfile.ZipFile(output_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for relative, content, mode in entries:
            info = zipfile.ZipInfo(relative, date_time=(1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = mode << 16
            archive.writestr(info, content)

    with zipfile.ZipFile(output_path) as archive:
        names = set(archive.namelist())
        if "manifest.json" not in names or manifest.get("entry") not in names:
            raise SystemExit(f"Package verification failed for {output_path}")
        if any(name.endswith("_test.lua") for name in names):
            raise SystemExit(f"Test file leaked into package: {output_path}")
        if bundle is not None:
            if bundle_output not in names:
                raise SystemExit(f"Generated bundle missing from package: {bundle_output}")
            leaked = sorted(bundled_sources & names)
            if leaked:
                raise SystemExit(f"Unbundled Lua sources leaked into package: {leaked}")

    digest = hashlib.sha256(output_path.read_bytes()).hexdigest()
    print(f"{output_path.relative_to(ROOT)}  sha256:{digest}")
    if bundle is not None:
        print(f"  bundled {len(bundled_sources)} Lua modules -> {bundle_output}")
    return output_path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mod", help="package only this mod id")
    parser.add_argument("--output-dir", type=Path, default=ROOT / "dist")
    args = parser.parse_args()
    mods = load_mods(args.mod)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    outputs = [build_one(mod_dir, args.output_dir) for mod_dir in mods]
    if not outputs:
        print("No mods discovered; no ZIP packages or checksum manifest to produce.")
        return 0
    checksum_path = args.output_dir / "checksums.sha256"
    lines = [f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.name}" for path in outputs]
    checksum_path.write_text("".join(line + "\n" for line in lines), encoding="utf-8")
    print(f"Built {len(outputs)} package(s); checksum manifest: {checksum_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, json.JSONDecodeError, zipfile.BadZipFile, ValueError) as exc:
        print(f"package: {exc}", file=sys.stderr)
        raise SystemExit(1)
