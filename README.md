# G1R-Mods

A development monorepo for mods targeting [Gen1Recomp](https://github.com/bryanthaboi/gen1recomp).

## Quick start

~~~bash
git clone --recurse-submodules https://github.com/rakmahefa/G1R-Mods.git
cd G1R-Mods
make bootstrap
make new MOD=my_first_mod
make check
make test
make package
~~~

LuaJIT and Python 3 are required locally. The DEV workflow installs its own LuaJIT toolchain; `make bootstrap` initializes the engine submodule and checks local prerequisites.

## Repository layout

- `mods/<mod-id>/` — independently versioned, installable mods.
- `third_party/gen1recomp/` — upstream engine checkout, pinned by the Git submodule entry.
- `templates/mod-template/` — starter structure for new mods.
- `scripts/` — repository-aware wrappers for checks, tests, and packaging.
- `.github/workflows/ci.yml` — ROM-free checks for pushes and pull requests.
- `.github/workflows/dev.yml` — downloadable ZIP artifacts from the development branch.

See [docs/architecture.md](docs/architecture.md), [docs/development.md](docs/development.md), and [docs/compatibility.md](docs/compatibility.md).

The first mod's design dossier is in [docs/mods/pokemon-rpg-economy/](docs/mods/pokemon-rpg-economy/README.md). It is a design-only proposal; implementation has not started.

## Design rules

1. Keep each mod self-contained in `mods/<mod-id>/`; do not nest mods by category.
2. Treat `third_party/gen1recomp` as read-only. Change its pinned commit only in a deliberate engine-update commit.
3. Use the upstream mod API and tooling. Do not copy engine source into this repository.
4. New mods start on API 3 and Gen 1 by default. Expand the `games` declaration only after testing those generations.
5. Tests must run against upstream headless SDK fixtures and must not require a ROM.
6. Never commit ROMs, ROM-derived bytes, generated game caches, or private save data.
7. Do not set the manifest `github` field to this monorepo yet: each mod has its own version, while the engine's basic release updater expects one mod per repository. See [docs/releases.md](docs/releases.md).

## Useful commands

| Command | Purpose |
| --- | --- |
| `make bootstrap` | Initialize the pinned engine submodule |
| `make list` | List discovered mods |
| `make new MOD=<id>` | Create a mod from the local template |
| `make check` | Check repository structure and run upstream `modkit lint` |
| `make test` | Run each mod's headless LuaJIT test suite |
| `make smoke-template` | Exercise template creation, lint, SDK loading, and ZIP packaging |
| `make package` | Build deterministic ZIP files in `dist/` |
| `make update-engine` | Move to upstream `dev` (review before committing) |
| `make clean` | Remove local outputs |
