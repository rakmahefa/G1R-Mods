-- ROM-free smoke test using the upstream headless mod SDK.
local engine = assert(os.getenv("G1R_ENGINE_ROOT"), "G1R_ENGINE_ROOT is required")
local mod_dir = assert(os.getenv("G1R_MOD_DIR"), "G1R_MOD_DIR is required")
local mod_id = assert(os.getenv("G1R_MOD_ID"), "G1R_MOD_ID is required")

package.path = engine .. "/?.lua;" .. engine .. "/?/init.lua;" .. package.path

local T = require("tests.modkit")
local result = T.sdk.loadMod(mod_dir, { root = engine })

T.eq(#result.errors, 0, "mod loads without errors")
T.check(result.mods[mod_id] ~= nil, "mod is discovered by the loader")
T.eq(result.mods[mod_id] and result.mods[mod_id].state, "loaded",
  "mod reaches the loaded state")

result.release()
T.finish(mod_id)
