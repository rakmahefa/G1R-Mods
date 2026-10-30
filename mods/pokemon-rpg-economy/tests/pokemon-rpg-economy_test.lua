-- ROM-free library and real sandbox-loader tests.
local engine = assert(os.getenv("G1R_ENGINE_ROOT"), "G1R_ENGINE_ROOT is required")
local mod_dir = assert(os.getenv("G1R_MOD_DIR"), "G1R_MOD_DIR is required")
local mod_id = assert(os.getenv("G1R_MOD_ID"), "G1R_MOD_ID is required")

package.path = engine .. "/?.lua;" .. engine .. "/?/init.lua;" .. package.path

local T = require("tests.modkit")

-- Exercise the actual API 3 loader against a Gen 3 fixture. The exact
-- Emerald-only target and API level are checked from the parsed manifest.
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
run.release()

local bootstrap = dofile(mod_dir .. "/lib/bootstrap.lua")
local Validation = dofile(mod_dir .. "/lib/validation.lua")
local Result = dofile(mod_dir .. "/lib/result.lua")
local Cache = dofile(mod_dir .. "/lib/cache.lua")
local Persistence = dofile(mod_dir .. "/lib/persistence.lua")
local Diagnostics = dofile(mod_dir .. "/lib/diagnostics.lua")

local function expectError(callback, expected, label)
  local ok, message = pcall(callback)
  T.check(not ok and tostring(message):find(expected, 1, true) ~= nil, label)
end

-- Module cache: one source read and compile for repeated imports.
local reads, compiles = 0, 0
local loader = bootstrap.new({
  read = function(path)
    reads = reads + 1
    T.eq(path, "lib/validation.lua", "only the allowlisted module path is read")
    return "validation-source"
  end,
  compile = function(source, chunkname)
    compiles = compiles + 1
    T.eq(chunkname, "@lib/validation.lua", "module receives a stable chunk name")
    return function() return { marker = source } end
  end,
})
local first = loader.load("validation")
local second = loader.load("validation")
T.eq(first, second, "repeated module loads return the cached table")
T.eq(reads, 1, "module source is read once")
T.eq(compiles, 1, "module source is compiled once")
expectError(function() loader.load("not-allowlisted") end,
  "not allowlisted", "unknown modules are rejected")

local missingLoader = bootstrap.new({
  read = function() return nil, "test file missing" end,
  compile = function() error("compiler must not run") end,
})
expectError(function() missingLoader.load("validation") end,
  "test file missing", "missing module files fail explicitly")

local compileLoader = bootstrap.new({
  read = function() return "bad-source" end,
  compile = function() return nil, "synthetic syntax error" end,
})
expectError(function() compileLoader.load("validation") end,
  "synthetic syntax error", "compile errors include module context")

local runtimeLoader = bootstrap.new({
  read = function() return "runtime-error" end,
  compile = function()
    return function() error("synthetic module failure") end
  end,
})
expectError(function() runtimeLoader.load("validation") end,
  "synthetic module failure", "module initialization errors are surfaced")

local cyclicLoader
cyclicLoader = bootstrap.new({
  read = function() return "cycle" end,
  compile = function()
    return function()
      cyclicLoader.load("validation")
      return {}
    end
  end,
})
expectError(function() cyclicLoader.load("validation") end,
  "cyclic local library import", "recursive imports are rejected")

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
