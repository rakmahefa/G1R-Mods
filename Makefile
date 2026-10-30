SHELL := /bin/bash

.PHONY: help bootstrap update-engine list new check test smoke-template bundle package clean

help:
	@printf '%s\n' \
	  'bootstrap       Initialize the pinned engine submodule and check prerequisites' \
	  'update-engine   Move the engine submodule to upstream dev (review the SHA)' \
	  'list            List discovered mod packages' \
	  'new MOD=<id>    Create a mod from templates/mod-template' \
	  'check           Check repository structure and run modkit lint' \
	  'test            Run mod tests with LuaJIT and the headless SDK' \
	  'smoke-template  Exercise the template through lint, SDK load, and ZIP packaging' \
	  'bundle MOD=<id> Generate a mod runtime Lua source bundle under build/' \
	  'package         Build deterministic installable ZIP files in dist/' \
	  'clean           Remove build, dist, and local cache outputs'

bootstrap:
	@./scripts/bootstrap.sh

update-engine:
	@git -C third_party/gen1recomp fetch --depth=1 origin dev
	@git -C third_party/gen1recomp checkout --detach FETCH_HEAD
	@printf 'Engine submodule now points to %s\n' "$$(git -C third_party/gen1recomp rev-parse HEAD)"
	@printf '%s\n' 'Review and commit the changed submodule pointer in the parent repository.'

list:
	@python3 scripts/discover_mods.py

new:
	@test -n "$(MOD)" || { echo 'Usage: make new MOD=my_mod' >&2; exit 2; }
	@./scripts/new-mod.sh "$(MOD)"

check:
	@./scripts/check.sh

test:
	@./scripts/test.sh

smoke-template:
	@./scripts/smoke-template.sh

bundle:
	@test -n "$(MOD)" || { echo 'Usage: make bundle MOD=pokemon-rpg-economy' >&2; exit 2; }
	@python3 scripts/build_lua_bundle.py --mod-dir "mods/$(MOD)" --output "build/bundles/$(MOD)/lib/runtime.bundle.lua"

package:
	@./scripts/package.sh

clean:
	@rm -rf build dist .cache __pycache__ scripts/__pycache__
