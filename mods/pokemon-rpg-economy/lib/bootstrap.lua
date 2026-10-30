-- Small private module loader. The allowlist is intentionally fixed in code:
-- runtime input can select a module name, never invent a file path.

local MODULE_PATHS = {
  cache = "lib/cache.lua",
  diagnostics = "lib/diagnostics.lua",
  persistence = "lib/persistence.lua",
  result = "lib/result.lua",
  validation = "lib/validation.lua",
}

local Bootstrap = {}

function Bootstrap.new(adapters)
  assert(type(adapters) == "table", "bootstrap adapters are required")
  assert(type(adapters.read) == "function", "bootstrap read adapter is required")
  assert(type(adapters.compile) == "function",
    "bootstrap compile adapter is required")

  local loaded = {}
  local loading = {}

  local function loadModule(name)
    if type(name) ~= "string" then
      error("local library module name must be a string", 2)
    end

    local path = MODULE_PATHS[name]
    if not path then
      error("local library module is not allowlisted: " .. name, 2)
    end
    if loaded[name] ~= nil then
      return loaded[name]
    end
    if loading[name] then
      error("cyclic local library import: " .. name, 2)
    end

    loading[name] = true

    local readOk, source, readError = pcall(adapters.read, path)
    if not readOk then
      loading[name] = nil
      error(("cannot read module %s: %s"):format(name, tostring(source)), 0)
    end
    if type(source) ~= "string" then
      loading[name] = nil
      error(("cannot read module %s: %s")
        :format(name, tostring(readError or "file is missing")), 0)
    end

    local compileOk, chunk, compileError =
      pcall(adapters.compile, source, "@" .. path)
    if not compileOk then
      loading[name] = nil
      error(("cannot compile module %s: %s")
        :format(name, tostring(chunk)), 0)
    end
    if type(chunk) ~= "function" then
      loading[name] = nil
      error(("cannot compile module %s: %s")
        :format(name, tostring(compileError or "compiler returned no chunk")), 0)
    end

    local runOk, module = pcall(chunk)
    loading[name] = nil
    if not runOk then
      error(("module %s failed while initializing: %s")
        :format(name, tostring(module)), 0)
    end
    if type(module) ~= "table" then
      error(("module %s must return a table"):format(name), 0)
    end

    -- Cache only a fully initialized module. Failed imports can be retried by
    -- the caller, and never leave a poisoned partial entry behind.
    loaded[name] = module
    return module
  end

  return {
    load = loadModule,
  }
end

return Bootstrap
