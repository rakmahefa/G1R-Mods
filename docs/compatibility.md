# Engine and mod compatibility

## Pinned engine revision

The initial submodule target is:

- Repository: https://github.com/bryanthaboi/gen1recomp
- Branch used for update discovery: `dev`
- Pinned commit: `0be34bc76cecf996e91d2f905d1b4bb5f14d43ae`
- Current engine development version at that revision: `0.0.0-dev`
- Mod API supported there: API 3

The exact revision is stored as the Git submodule gitlink in the parent commit. `.gitmodules` records `dev` as the update branch, but clones do not float to its latest commit.

## Update the engine deliberately

~~~bash
make update-engine
git diff --submodule=log -- third_party/gen1recomp
make check
make test
make package
git add third_party/gen1recomp
git commit -m "chore: update gen1recomp submodule"
~~~

Review upstream breaking changes and mod API notes before merging the gitlink update. If a mod stops loading, fix its manifest/API usage or pin the prior engine; do not patch upstream source from inside this monorepo.

## Mod API and game declarations

New mods scaffold with `api: 3`, the canonical portable API, and `games: ["gen1"]`. API 3 is available in the pinned engine. A mod should expand its `games` list only after it has been tested against the generation-specific behavior and data it uses.

The manifest's `game_version` should describe the engine range the mod actually supports. Review this value during engine upgrades.

## Compatibility test expectations

- Manifest and loader compatibility: tested via the upstream SDK fixture loader.
- ROM-free static/legal checks: upstream `modkit lint`.
- Game-specific behavior: authored fixture tests for each claimed generation where the SDK supports it.
- ROM-dependent behavior: local developer validation using privately supplied data; never commit the source dumps or derived cache.
