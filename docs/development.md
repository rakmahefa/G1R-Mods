# Development workflow

## Prerequisites

- Git with submodule support.
- Python 3.10 or newer.
- LuaJIT 2.1 (the runtime semantics targeted by the game).
- Pillow for upstream image/asset lint rules when a mod contains images.

Initialize the checkout:

~~~bash
make bootstrap
~~~

To create an isolated Python environment and install the development requirements:

~~~bash
scripts/bootstrap.sh --install-python-deps
source .venv/bin/activate
~~~

## Create a mod

~~~bash
make new MOD=my_mod
~~~

The command copies `templates/mod-template/` to `mods/my_mod/`, replaces the template tokens, and renames its smoke test. It never overwrites an existing directory.

Edit `manifest.json`, `main.lua`, `mod.card`, `README.md`, and the tests. New mods start with API 3 and target Gen 1 only. Add `gen2`, `gen3`, or individual games only after exercising those targets.

## Local commands

~~~bash
make list
make check
make test
make package
~~~

- `make check` checks directory/manifest consistency and runs upstream `modkit lint` for every mod.
- `make test` executes every `mods/<id>/tests/*_test.lua` file under the upstream engine checkout.
- `make package` creates deterministic installable ZIP files and a SHA-256 manifest in `dist/`.

The wrapper in `scripts/modkit.sh` invokes the pinned upstream `tools/modkit.py` with `--repo third_party/gen1recomp`, so absolute mod paths outside the engine checkout are supported.

## Writing ROM-free tests

Tests run from the upstream engine root so its `tests.modkit` modules resolve. The runner exports:

- `G1R_ENGINE_ROOT` — absolute path to the pinned engine checkout.
- `G1R_MOD_DIR` — absolute path to the mod under test.
- `G1R_MOD_ID` — directory/manifest ID.

Use `tests.modkit` and `T.sdk.loadMod(G1R_MOD_DIR, { root = G1R_ENGINE_ROOT })`. The SDK supplies the committed fixture dataset by default, so tests do not need a ROM or a local import cache.

A minimal test should assert that the mod loads cleanly, then assert its actual intended effect against fixture data or a small test-owned dataset. Always call `result.release()` and `T.finish()` so the runtime hooks/events are restored and failures affect the exit code.

Example shape:

~~~lua
local engine = assert(os.getenv("G1R_ENGINE_ROOT"))
package.path = engine .. "/?.lua;" .. engine .. "/?/init.lua;" .. package.path

local T = require("tests.modkit")
local result = T.sdk.loadMod(assert(os.getenv("G1R_MOD_DIR")), { root = engine })

T.eq(#result.errors, 0, "mod loads without errors")
T.check(result.mods[assert(os.getenv("G1R_MOD_ID"))] ~= nil, "mod is discovered")

result.release()
T.finish("my_mod")
~~~

Do not call `Data:load()` in ROM-free tests. For tests that genuinely require imported game data, keep them separate from the required CI suite and document the local prerequisites; never put ROM files or generated ROM caches in GitHub Actions artifacts.

## CI policy

The CI runs `modkit lint` and mod-authored headless SDK tests. It deliberately does not run `modkit validate --base fixture` indiscriminately: the upstream guide documents that fixture validation cannot resolve every real-game identifier, so a valid content mod can fail against the reduced fixture ID space.

A test that loads the mod through `T.sdk.loadMod` is the per-mod loader/manifest/merge gate. For a specialized mod that needs explicit `modkit validate` coverage, document the chosen base and add a targeted CI step rather than imposing fixture validation on every mod.
