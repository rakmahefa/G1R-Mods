-- Versioned, data-only state on the public per-mod save facade.
-- This module deliberately does not claim multi-resource or engine-level
-- transaction semantics. Each key stores one schema envelope.

local Persistence = {}
local HUGE = math.huge
local MAX_DEPTH = 64
local MAX_NODES = 8192
local MAX_STRING_BYTES = 65536
local MAX_TOTAL_STRING_BYTES = 1024 * 1024

local function validIdentifier(value)
  return type(value) == "string" and value:match("^[%w_-]+$") ~= nil
end

local function finite(value)
  return type(value) == "number" and value == value
    and value ~= HUGE and value ~= -HUGE
end

local function cloneData(value, state, depth)
  state.nodes = state.nodes + 1
  if state.nodes > MAX_NODES then return nil, "save data node limit exceeded" end

  local kind = type(value)
  if kind == "string" then
    if #value > MAX_STRING_BYTES then return nil, "save data string is too long" end
    state.stringBytes = state.stringBytes + #value
    if state.stringBytes > MAX_TOTAL_STRING_BYTES then
      return nil, "save data string budget exceeded"
    end
    return value
  end
  if kind == "boolean" then return value end
  if kind == "number" then
    if not finite(value) then return nil, "non-finite numbers are not save data" end
    return value
  end
  if kind ~= "table" then
    return nil, "unsupported save data type: " .. kind
  end
  if getmetatable(value) ~= nil then
    return nil, "save data tables must not have metatables"
  end
  if depth > MAX_DEPTH then return nil, "save data nesting limit exceeded" end
  if state.active[value] then return nil, "cyclic save data is not supported" end

  state.active[value] = true
  local copy = {}
  for key, entry in next, value do
    local keyType = type(key)
    if keyType ~= "string" and keyType ~= "number" then
      state.active[value] = nil
      return nil, "save data keys must be strings or numbers"
    end
    if keyType == "string" then
      if #key > MAX_STRING_BYTES then
        state.active[value] = nil
        return nil, "save data key is too long"
      end
      state.stringBytes = state.stringBytes + #key
      if state.stringBytes > MAX_TOTAL_STRING_BYTES then
        state.active[value] = nil
        return nil, "save data string budget exceeded"
      end
    elseif not finite(key) then
      state.active[value] = nil
      return nil, "save data keys must be finite numbers"
    end

    local cloned, cloneError = cloneData(entry, state, depth + 1)
    if cloneError then
      state.active[value] = nil
      return nil, cloneError
    end
    copy[key] = cloned
  end
  state.active[value] = nil
  return copy
end

local function copyData(value)
  if type(value) ~= "table" then
    return nil, "save data root must be a table"
  end
  return cloneData(value, { active = {}, nodes = 0, stringBytes = 0 }, 1)
end

local function validateData(data, validator)
  if validator == nil then return true end
  if type(validator) ~= "function" then
    return false, "invalid_validator", "validator must be a function"
  end
  local ok, valid, code, message = pcall(validator, data)
  if not ok then
    return false, "validator_failed", tostring(valid)
  end
  if valid ~= true then
    return false,
      type(code) == "string" and code or "validation_failed",
      type(message) == "string" and message or "stored data failed validation"
  end
  return true
end

local function validSchemaVersion(value)
  return finite(value) and value % 1 == 0 and value >= 1
end

function Persistence.new(saveApi, resultApi, namespace)
  assert(type(saveApi) == "table"
      and type(saveApi.get) == "function"
      and type(saveApi.set) == "function",
    "persistence requires the public mod.save get/set facade")
  assert(type(resultApi) == "table"
      and type(resultApi.ok) == "function"
      and type(resultApi.err) == "function",
    "persistence requires the result module")
  assert(validIdentifier(namespace), "persistence namespace must be a safe identifier")

  local function storageKey(key)
    if not validIdentifier(key) then return nil end
    return namespace .. "_" .. key
  end

  local function errorResult(code, message, details)
    return resultApi.err(code, message, details)
  end

  local api = {}

  function api:read(key, schemaVersion, initialData, migrations, validator)
    local fullKey = storageKey(key)
    if not fullKey then
      return errorResult("invalid_key", "State key must be a non-empty identifier.")
    end
    if not validSchemaVersion(schemaVersion) then
      return errorResult("invalid_schema", "Schema version must be a positive finite integer.")
    end
    if migrations ~= nil and type(migrations) ~= "table" then
      return errorResult("invalid_migrations", "Migrations must be a table of functions.")
    end
    migrations = migrations or {}

    local readOk, stored = pcall(saveApi.get, saveApi, fullKey)
    if not readOk then
      return errorResult("read_failed", "Could not read mod save data.", tostring(stored))
    end

    if stored == nil then
      local fresh, cloneError = copyData(initialData)
      if not fresh then
        return errorResult("invalid_initial_data",
          "Initial state must be bounded data-only data.", cloneError)
      end
      local valid, code, message = validateData(fresh, validator)
      if not valid then return errorResult(code, message) end
      return resultApi.ok(fresh, { fresh = true, migrated = false })
    end

    if type(stored) ~= "table"
        or not validSchemaVersion(stored.schema_version)
        or type(stored.data) ~= "table" then
      return errorResult("corrupt_state", "Stored state envelope is invalid.")
    end
    if stored.schema_version > schemaVersion then
      return errorResult("future_schema",
        "Stored state was written by a newer version of this mod.")
    end

    local data, cloneError = copyData(stored.data)
    if not data then
      return errorResult("corrupt_state", "Stored state is not safe data.", cloneError)
    end

    local version = stored.schema_version
    local migrated = false
    while version < schemaVersion do
      local migration = migrations[version]
      if type(migration) ~= "function" then
        return errorResult("migration_missing",
          ("No migration is registered from schema version %d."):format(version))
      end
      local migrationOk, nextData = pcall(migration, data)
      if not migrationOk then
        return errorResult("migration_failed",
          ("Migration from schema version %d failed."):format(version),
          tostring(nextData))
      end
      local safeData, migrationError = copyData(nextData)
      if not safeData then
        return errorResult("migration_failed",
          ("Migration from schema version %d returned invalid data."):format(version),
          migrationError)
      end
      data = safeData
      version = version + 1
      migrated = true
    end

    local valid, code, message = validateData(data, validator)
    if not valid then return errorResult(code, message) end

    if migrated then
      local writeOk, writeError = pcall(saveApi.set, saveApi, fullKey, {
        schema_version = schemaVersion,
        data = data,
      })
      if not writeOk then
        return errorResult("migration_write_failed",
          "Migrated state could not be saved.", tostring(writeError))
      end
    end
    return resultApi.ok(data, { fresh = false, migrated = migrated })
  end

  function api:write(key, schemaVersion, data, validator)
    local fullKey = storageKey(key)
    if not fullKey then
      return errorResult("invalid_key", "State key must be a non-empty identifier.")
    end
    if not validSchemaVersion(schemaVersion) then
      return errorResult("invalid_schema", "Schema version must be a positive finite integer.")
    end

    local safeData, cloneError = copyData(data)
    if not safeData then
      return errorResult("invalid_data",
        "State must be bounded data-only data.", cloneError)
    end
    local valid, code, message = validateData(safeData, validator)
    if not valid then return errorResult(code, message) end

    local writeOk, writeError = pcall(saveApi.set, saveApi, fullKey, {
      schema_version = schemaVersion,
      data = safeData,
    })
    if not writeOk then
      return errorResult("write_failed", "Could not write mod save data.",
        tostring(writeError))
    end
    return resultApi.ok(true)
  end

  return api
end

return Persistence
