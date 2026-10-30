# Pokémon RPG Economy

Pokémon RPG Economy is an API 3 mod targeting **Pokémon Emerald only**. Its first implementation establishes a small, isolated Lua library; it does not yet change battles, items, money, Pokémon, trainers, maps, or progression.

The mod is deliberately kept gameplay-neutral until its public API assumptions and safety tests are proven. In particular, it does not access engine-private modules or mutate Pokémon records.

## Current scope

- Local module loading through the sandboxed `mod:read` and `load` functions.
- An explicit module allowlist, load cache, and cycle detection.
- Shared validation and result helpers.
- A bounded FIFO cache for static or derived data.
- Versioned, data-only state stored through the public `mod.save` facade.
- Optional, bounded diagnostic deduplication.
- Headless tests of the library and actual API 3 loader path.

No other mod is a dependency. No permissions are requested.

## Development

From the G1R-Mods repository root, run:

~~~bash
make check
make test
make package
~~~

The test suite is excluded from the installable package through `.modkitignore`.

## Compatibility

- Mod API: 3
- Game target: Pokémon Emerald (`games: ["emerald"]`)
- Engine compatibility: see `manifest.json`

The mod must not expand its game target until it has been tested against each additional game.

## Credits

- Code and design: rakmahefa.
- Engine API: Gen1Recomp, through its public mod API.
