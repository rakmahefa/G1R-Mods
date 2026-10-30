-- ROM-free library and real sandbox-loader tests.
local engine = assert(os.getenv("G1R_ENGINE_ROOT"), "G1R_ENGINE_ROOT is required")
local mod_dir = assert(os.getenv("G1R_MOD_DIR"), "G1R_MOD_DIR is required")
local mod_id = assert(os.getenv("G1R_MOD_ID"), "G1R_MOD_ID is required")

package.path = engine .. "/?.lua;" .. engine .. "/?/init.lua;" .. package.path

local T = require("tests.modkit")

-- Prove the native award path first with an empty loader: this fixture
-- must receive both battle EXP and EVs before the mod is enabled.
local baselineData = T.sdk.gen3Data()
local baselineRun = T.sdk.loadNone({
  root = engine,
  data = baselineData,
  generation = 3,
})

local Pokemon = require("src.core.game3.pokemon")
for key, value in pairs(baselineData.gen3Pokemon) do
  Pokemon[key] = value
end
-- Pidgey's Gen 3 metadata is the test foe's native HP EV yield.
Pokemon._speciesMeta[16].evHp = 1
local Experience = require("src.core.game3.battle.experience")

local function freshBattle(wild)
  local function newMon()
    return {
      species = 4, level = 5, growthRate = 0, exp = 125,
      hp = 10, maxHp = 10, item = 0, pokerus = 0, friendship = 70,
      personality = 0,
      evs = { hp = 0, atk = 0, def = 0, spe = 0, spa = 0, spd = 0 },
    }
  end
  local playerMon, shareMon = newMon(), newMon()
  shareMon.item = 182 -- Gen 3 Exp. Share.
  local foe = {
    species = 16,
    mon = { species = 16, level = 1 },
    participants = { [1] = true },
  }
  local state = {
    wild = wild,
    playerParty = { playerMon, shareMon },
    player = { mon = playerMon, partyIndex = 1 },
    enemy = foe,
    session = {},
  }
  return state, foe, playerMon, shareMon
end

local function rewardOptions()
  return {
    getOpts = function()
      return { traded = false, luckyEgg = false }
    end,
  }
end

for _, wild in ipairs({ true, false }) do
  local state, foe, participant, shareHolder = freshBattle(wild)
  local nativeAwards = Experience.awardFoe(state, foe, rewardOptions())
  T.eq(#nativeAwards, 2,
    (wild and "wild" or "trainer") .. " baseline awards participant and Exp. Share")
  T.check(participant.exp > 125 and shareHolder.exp > 125,
    (wild and "wild" or "trainer") .. " baseline grants battle EXP")
  T.eq(participant.evs.hp, 1,
    (wild and "wild" or "trainer") .. " baseline grants participant EVs")
  T.eq(shareHolder.evs.hp, 1,
    (wild and "wild" or "trainer") .. " baseline grants Exp. Share holder EVs")
end
baselineRun.release()

-- Exercise the actual API 3 loader against the Emerald-targeted mod.
local run = T.sdk.loadMod(mod_dir, {
  root = engine,
  data = T.sdk.gen3Data(),
  generation = 3,
})
T.eq(#run.errors, 0, "mod loads clean in the headless Gen 3 sandbox")
T.check(run.mods[mod_id] ~= nil, "mod is discovered by the SDK loader")
T.eq(run.mods[mod_id] and run.mods[mod_id].state, "loaded",
  "mod reaches the loaded state")
T.eq(run.mods[mod_id] and run.mods[mod_id].manifest.api, 3,
  "mod uses API 3")
T.same(run.mods[mod_id] and run.mods[mod_id].manifest.games, { "emerald" },
  "manifest targets Emerald and no other game")
T.eq(rawget(_G, "MODULE_PATHS"), nil,
  "the local module allowlist does not leak into engine globals")

-- A high-priority observer sees the real public hook call and delegates to
-- the mod's hook. The mod hook then deliberately stops the native award path.
local observedCalls, observedContext = 0, nil
local removeObserver = run.loader.hooks:wrap(
  "battle.exp_award",
  function(nextFn, context)
    observedCalls = observedCalls + 1
    observedContext = context
    return nextFn(context)
  end,
  1000,
  "pokemon-rpg-economy-test-observer"
)

for _, wild in ipairs({ true, false }) do
  local state, foe, participant, shareHolder = freshBattle(wild)
  local participantExp, shareExp = participant.exp, shareHolder.exp
  local blockedAwards = Experience.awardFoe(state, foe, rewardOptions())
  T.eq(#blockedAwards, 0,
    (wild and "wild" or "trainer") .. " mod hook suppresses the whole reward")
  T.eq(participant.exp, participantExp,
    (wild and "wild" or "trainer") .. " battles grant no EXP")
  T.eq(shareHolder.exp, shareExp,
    (wild and "wild" or "trainer") .. " Exp. Share grants no EXP")
  T.eq(participant.evs.hp, 0,
    (wild and "wild" or "trainer") .. " battles grant no participant EVs")
  T.eq(shareHolder.evs.hp, 0,
    (wild and "wild" or "trainer") .. " battles grant no Exp. Share EVs")
end
removeObserver()
T.eq(observedCalls, 2, "the Emerald battle reward hook runs for wild and trainer battles")
T.check(type(observedContext) == "table" and observedContext.loser ~= nil,
  "battle reward hook receives its documented context")

run.release()

local bundle = dofile(mod_dir .. "/lib/runtime.bundle.lua")
T.check(type(bundle) == "table" and type(bundle.new) == "function",
  "generated runtime bundle exposes its library factory")

local library = bundle.new()
local Validation = library.load("validation")
local Result = library.load("result")
local Cache = library.load("cache")
local Persistence = library.load("persistence")
local Diagnostics = library.load("diagnostics")

local function expectError(callback, expected, label)
  local ok, message = pcall(callback)
  T.check(not ok and tostring(message):find(expected, 1, true) ~= nil, label)
end

T.eq(library.load("validation"), Validation,
  "repeated imports return the cached module table")
expectError(function() library.load("not-included") end,
  "not present in generated bundle", "modules outside the bundle are rejected")

-- Validation: finite values, bounds, integers, identifiers and dense arrays.
T.check(Validation.isFiniteNumber(12.5), "finite numbers are accepted")
T.eq(Validation.isFiniteNumber(0 / 0), false, "NaN is rejected")
T.eq(Validation.isFiniteNumber(math.huge), false, "infinity is rejected")
T.check(Validation.integer(5, 1, 10), "bounded integers are accepted")
T.eq(Validation.integer(5.5), false, "fractional integers are rejected")
T.eq(Validation.integer(11, 1, 10), false, "out-of-range integers are rejected")
T.eq(Validation.numberInRange(5, 10, 1), false, "inverted bounds are rejected")
T.check(Validation.identifier("contract_01"), "safe identifiers are accepted")
T.eq(Validation.identifier("../unsafe"), false, "path-like identifiers are rejected")
T.check(Validation.oneOf("emerald", { "ruby", "emerald" }),
  "enum membership is checked")
T.check(Validation.array({ "a", "b" }, 2), "dense arrays within bounds are accepted")
T.eq(Validation.array({ [1] = "a", [3] = "c" }), false,
  "sparse arrays are rejected")

-- Result values have a stable success/error shape.
local success = Result.ok({ amount = 10 })
local failure = Result.err("insufficient_funds", "Not enough money.")
T.check(Result.is(success) and success.ok, "success result is recognized")
T.check(Result.is(failure) and not failure.ok, "error result is recognized")
T.eq(failure.error.code, "insufficient_funds", "error code remains stable")
local unwrapped = Result.unwrap(success)
T.eq(unwrapped.amount, 10, "success values can be unwrapped")

-- The cache is bounded, accepts false values, and evicts its oldest entry.
local cache = Cache.new(2)
cache:set("first", false)
local cachedValue, found = cache:get("first")
T.eq(cachedValue, false, "false is a valid cached value")
T.check(found, "cache distinguishes a stored false from a miss")
cache:set("second", 2)
cache:set("third", 3)
T.eq(cache:get("first"), nil, "the oldest cache entry is evicted")
T.eq(cache:size(), 2, "cache size never exceeds its configured bound")
T.check(cache:remove("second"), "cache entries can be removed")
T.eq(cache:size(), 1, "removal updates the cache size")

-- Versioned save data is cloned, validated and migrated as a single envelope.
local stored = {}
local saveApi = {
  get = function(_, key) return stored[key] end,
  set = function(_, key, value) stored[key] = value end,
}
local persistence = Persistence.new(saveApi, Result, "test_mod")
local fresh = persistence:read("wallet", 1, { balance = 0 })
T.check(fresh.ok and fresh.metadata.fresh, "missing save state returns fresh defaults")
T.check(persistence:write("wallet", 1, { balance = 25 }).ok,
  "versioned state is written")
T.eq(stored.test_mod_wallet.schema_version, 1, "schema version is stored")
T.eq(persistence:read("wallet", 1, {}).value.balance, 25,
  "saved state can be read back")

stored.test_mod_wallet = { schema_version = 1, data = { balance = 40 } }
local migrated = persistence:read("wallet", 2, { balance = 0 }, {
  [1] = function(data)
    data.balance = data.balance + 1
    return data
  end,
})
T.check(migrated.ok and migrated.metadata.migrated, "old schemas are migrated")
T.eq(migrated.value.balance, 41, "migration output is returned")
T.eq(stored.test_mod_wallet.schema_version, 2,
  "successful migration is persisted at the new schema")

local cyclic = {}
cyclic.self = cyclic
local rejected = persistence:write("wallet", 2, cyclic)
T.eq(rejected.ok, false, "cyclic values are rejected before save")
T.eq(rejected.error.code, "invalid_data", "invalid data has a stable error code")
T.eq(persistence:write("wallet", 2, { amount = math.huge }).error.code,
  "invalid_data", "non-finite saved values are rejected")
T.eq(persistence:read("wallet", 2, {}, "not-a-migration-table").error.code,
  "invalid_migrations", "invalid migration tables are rejected")
T.eq(persistence:read("wallet", 3, {}, {}).error.code,
  "migration_missing", "missing migration steps are not skipped")
T.eq(persistence:read("wallet", 1, {}).error.code,
  "future_schema", "newer save schemas are not silently downgraded")

local corrupt = persistence:read("wallet", 2, {})
stored.test_mod_wallet = { schema_version = "old", data = {} }
corrupt = persistence:read("wallet", 2, {})
T.eq(corrupt.ok, false, "corrupt envelopes are rejected")
T.eq(corrupt.error.code, "corrupt_state", "corrupt state has a stable error code")

local failingPersistence = Persistence.new({
  get = function() error("synthetic read failure") end,
  set = function() error("synthetic write failure") end,
}, Result, "test_mod")
T.eq(failingPersistence:read("wallet", 1, {}).error.code,
  "read_failed", "save read failures become typed results")
local failedWrite = failingPersistence:write("wallet", 1, { balance = 1 })
T.eq(failedWrite.error.code, "write_failed",
  "save write failures become typed results")

-- Diagnostics are opt-in, bounded, and suppress identical repeated messages.
local logs = {}
local logger = {
  info = function(_, format, ...)
    logs[#logs + 1] = format:format(...)
  end,
  warn = function(_, format, ...)
    logs[#logs + 1] = format:format(...)
  end,
  error = function(_, format, ...)
    logs[#logs + 1] = format:format(...)
  end,
}
local diagnostics = Diagnostics.new(logger, {
  enabled = true, max_entries = 2, categories = { library = true },
})
T.check(diagnostics:info("library", "ready"), "first diagnostic is emitted")
T.eq(diagnostics:info("library", "ready"), false,
  "identical diagnostic is suppressed")
T.eq(diagnostics:info("other", "hidden"), false,
  "categories outside the allowlist are not logged")
T.check(diagnostics:warn("library", "warning"), "a second diagnostic is emitted")
T.check(diagnostics:error("library", "failure"), "a third diagnostic is emitted")
T.check(diagnostics:info("library", "ready"),
  "an evicted diagnostic may be emitted again")
T.eq(#logs, 4, "diagnostic history remains bounded without duplicate spam")
T.eq(diagnostics:info("library", string.rep("x", 513)), false,
  "oversized diagnostic messages are rejected")

local disabled = Diagnostics.new(logger, { enabled = false })
T.eq(disabled:warn("library", "hidden"), false,
  "diagnostics stay silent unless explicitly enabled")
T.eq(#logs, 4, "disabled diagnostics do not call the logger")

T.finish(mod_id)
