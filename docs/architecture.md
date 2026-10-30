# Repository architecture

## Top-level layout

~~~text
G1R-Mods/
├── .github/
│   ├── workflows/ci.yml
│   └── workflows/dev.yml
├── third_party/
│   └── gen1recomp/            # pinned Git submodule; upstream is read-only
├── mods/
│   ├── <mod-id>/              # one installable package per directory
│   └── ...
├── templates/
│   └── mod-template/
├── scripts/                  # repository wrappers and packaging
├── tests/repository/         # repository-level checks (not game mod tests)
├── docs/
├── build/                    # local transient output, ignored
├── dist/                     # installable ZIP artifacts, ignored
└── .cache/                   # optional local tool caches, ignored
~~~

## Mod layout

Every installable mod lives directly at `mods/<mod-id>/`. Do not group mods under category folders: the game's loader discovers mods one level below its `mods/` directory.

A mod should contain the upstream contract files:

- `manifest.json` — loader identity, API, game compatibility, dependencies.
- `main.lua` — entry chunk.
- `mod.card` — human-facing metadata for the launcher/index.
- `README.md` and `CHANGELOG.md`.
- `assets/` — authored assets only.
- `tests/*_test.lua` — headless SDK tests; excluded from release packages through exact `.modkitignore` paths.
- `tools/` — optional source generators, never required at runtime.

## Shared code

Code required by other mods should normally be distributed as a normal library mod under `mods/<library-id>/`, then declared as a dependency in each consumer's manifest. This keeps dependency resolution and sandboxing inside the engine's supported model.

Repository-only helpers belong in `scripts/`, not in runtime mods.

## Upstream engine

`third_party/gen1recomp` is a Git submodule pinned to one commit. It is used for the mod SDK, `modkit.py`, fixtures, and the LuaJIT setup action. Do not copy upstream files into this repository or modify the submodule's working tree for ordinary mod development.

A submodule update is a deliberate dependency update: fetch upstream `dev`, review the new commit, test all mods, and commit the changed gitlink in this repository.

## Distribution

Each mod is packaged independently as `<id>-<version>.zip`. The ZIP has `manifest.json` and the entry file at its root, matching the game's mod ZIP import format. The monorepo itself is not the installable unit.
