-- Pokémon RPG Economy entry point.
-- Source modules stay separate in Git; the build emits one Lua source bundle.

local function loadLibrary(mod)
  local source, readError = mod:read("lib/runtime.bundle.lua")
  if type(source) ~= "string" then
    error(("cannot read lib/runtime.bundle.lua: %s"):format(tostring(readError)), 0)
  end

  local chunk, compileError = load(source, "@lib/runtime.bundle.lua")
  if type(chunk) ~= "function" then
    error(("cannot compile lib/runtime.bundle.lua: %s"):format(tostring(compileError)), 0)
  end

  local chunkOk, bundle = pcall(chunk)
  if not chunkOk then
    error(("runtime bundle initialization failed: %s"):format(tostring(bundle)), 0)
  end
  if type(bundle) ~= "table" or type(bundle.new) ~= "function" then
    error("runtime bundle must return a table with new()", 0)
  end

  local libraryOk, library = pcall(bundle.new)
  if not libraryOk then
    error(("runtime library initialization failed: %s"):format(tostring(library)), 0)
  end
  if type(library) ~= "table" or type(library.load) ~= "function" then
    error("runtime library must expose load()", 0)
  end
  return library
end

return function(mod)
  local library = loadLibrary(mod)
  local validation = library.load("validation")
  local result = library.load("result")
  local cache = library.load("cache")
  local persistence = library.load("persistence")
  local diagnostics = library.load("diagnostics")

  assert(type(validation.isFiniteNumber) == "function",
    "validation module is incomplete")
  assert(type(result.ok) == "function" and type(result.err) == "function",
    "result module is incomplete")

  local boundedCache = cache.new(32)
  local saveState = persistence.new(mod.save, result, mod.id)
  local diagnosticLog = diagnostics.new(mod.log, { enabled = false })

  assert(boundedCache:size() == 0, "new cache must be empty")
  assert(type(saveState.read) == "function"
      and type(saveState.write) == "function",
    "persistence module is incomplete")
  assert(type(diagnosticLog.info) == "function",
    "diagnostics module is incomplete")

  -- Suppress the full award pipeline: Gen 3 awards EVs before EXP.
  assert(type(mod.hooks) == "table" and type(mod.hooks.wrap) == "function",
    "battle reward hook API is unavailable")
  mod.hooks:wrap("battle.exp_award", function(_next, _context)
    return nil
  end)

  mod.log:info("Lua bundle loaded (API 3; Pokémon Emerald only)")
end
