-- Pokémon RPG Economy entry point.
-- Keep all implementation modules inside this mod and load them through the
-- sandboxed mod:read + load pair. No engine-private modules are required.

local function runLocalModule(mod, path)
  local source, readError = mod:read(path)
  if type(source) ~= "string" then
    error(("cannot read %s: %s"):format(path, tostring(readError)), 0)
  end

  local chunk, compileError = load(source, "@" .. path)
  if type(chunk) ~= "function" then
    error(("cannot compile %s: %s"):format(path, tostring(compileError)), 0)
  end

  local ok, module = pcall(chunk)
  if not ok then
    error(("module %s failed while initializing: %s")
      :format(path, tostring(module)), 0)
  end
  if type(module) ~= "table" then
    error(("module %s must return a table"):format(path), 0)
  end
  return module
end

return function(mod)
  local bootstrap = runLocalModule(mod, "lib/bootstrap.lua")
  local library = bootstrap.new({
    read = function(path)
      return mod:read(path)
    end,
    -- load is the sandbox-provided compiler: child chunks inherit this mod's
    -- isolated environment under LuaJIT as well as on newer Lua runtimes.
    compile = function(source, chunkname)
      return load(source, chunkname)
    end,
  })

  local validation = library.load("validation")
  local result = library.load("result")
  local cache = library.load("cache")
  local persistence = library.load("persistence")
  local diagnostics = library.load("diagnostics")

  assert(type(validation.isFiniteNumber) == "function",
    "validation module is incomplete")
  assert(type(result.ok) == "function" and type(result.err) == "function",
    "result module is incomplete")

  -- Construct the reusable helpers once. No save data is read or written at
  -- startup; persistence is opened by a future feature when it has a schema.
  local boundedCache = cache.new(32)
  local saveState = persistence.new(mod.save, result, mod.id)
  local diagnosticLog = diagnostics.new(mod.log, { enabled = false })

  assert(boundedCache:size() == 0, "new cache must be empty")
  assert(type(saveState.read) == "function"
      and type(saveState.write) == "function",
    "persistence module is incomplete")
  assert(type(diagnosticLog.info) == "function",
    "diagnostics module is incomplete")

  -- Emerald rule: combats grant neither EXP nor EVs. The engine awards EVs
  -- before it applies EXP, so intercept the whole award pipeline here; an
  -- exp.gain hook returning zero would still leave EVs behind.
  assert(type(mod.hooks) == "table" and type(mod.hooks.wrap) == "function",
    "battle reward hook API is unavailable")
  mod.hooks:wrap("battle.exp_award", function(_next, _context)
    -- Intentionally do not call next(): this policy replaces the full reward.
    return nil
  end)

  mod.log:info("library foundation loaded (API 3; Pokémon Emerald only)")
end
