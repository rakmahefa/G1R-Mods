#!/usr/bin/env python3
"""Discover and sanity-check first-level mod packages in mods/<id>/."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent.parent
MODS_DIR = ROOT / "mods"
MOD_ID_RE = re.compile(r"^[A-Za-z0-9_-]+$")
REQUIRED_FIELDS = ("id", "name", "version", "entry", "api")


def discover() -> list[dict[str, Any]]:
    mods: list[dict[str, Any]] = []
    errors: list[str] = []
    if not MODS_DIR.exists():
        return mods

    for folder in sorted(MODS_DIR.iterdir(), key=lambda p: p.name.casefold()):
        if not folder.is_dir() or folder.name.startswith("."):
            continue
        manifest_path = folder / "manifest.json"
        if not manifest_path.is_file():
            errors.append(f"{folder.relative_to(ROOT)}: missing manifest.json")
            continue
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            errors.append(f"{manifest_path.relative_to(ROOT)}: {exc}")
            continue
        if not isinstance(manifest, dict):
            errors.append(f"{manifest_path.relative_to(ROOT)}: manifest must be a JSON object")
            continue
        missing = [field for field in REQUIRED_FIELDS if field not in manifest]
        if missing:
            errors.append(f"{manifest_path.relative_to(ROOT)}: missing fields: {', '.join(missing)}")
            continue

        mod_id = manifest.get("id")
        if not isinstance(mod_id, str) or not MOD_ID_RE.fullmatch(mod_id):
            errors.append(f"{manifest_path.relative_to(ROOT)}: invalid mod id {mod_id!r}")
            continue
        if mod_id != folder.name:
            errors.append(f"{manifest_path.relative_to(ROOT)}: directory name must match manifest id {mod_id!r}")

        entry = manifest.get("entry")
        if not isinstance(entry, str) or not entry or not (folder / entry).is_file():
            errors.append(f"{manifest_path.relative_to(ROOT)}: entry must name an existing file")
        for field in ("name", "version"):
            if not isinstance(manifest.get(field), str) or not manifest[field].strip():
                errors.append(f"{manifest_path.relative_to(ROOT)}: {field} must be a non-empty string")
        if not isinstance(manifest.get("api"), int) or manifest["api"] < 1:
            errors.append(f"{manifest_path.relative_to(ROOT)}: api must be a positive integer")
        mods.append({
            "id": mod_id,
            "name": manifest.get("name", mod_id),
            "version": manifest.get("version", "0.0.0"),
            "path": str(folder.resolve()),
        })

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)
    return mods


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="validate all discovered mod manifests")
    parser.add_argument("--json", action="store_true", help="emit mod metadata as JSON")
    args = parser.parse_args()
    mods = discover()
    if args.check:
        print(f"Repository structure OK ({len(mods)} mod(s) discovered).")
    elif args.json:
        print(json.dumps(mods, indent=2))
    else:
        for mod in mods:
            print(mod["path"])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
