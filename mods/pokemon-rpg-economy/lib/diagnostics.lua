-- Optional diagnostic forwarding with bounded duplicate suppression.
-- No clock, timer, polling, or per-frame work is created here.

local Diagnostics = {}
local LEVELS = { info = true, warn = true, error = true }
local HUGE = math.huge
local MAX_CATEGORY_BYTES = 64
local MAX_MESSAGE_BYTES = 512

local function validLimit(value)
  return type(value) == "number" and value == value
    and value ~= HUGE and value ~= -HUGE
    and value % 1 == 0 and value >= 1
end

function Diagnostics.new(logger, options)
  options = options or {}
  assert(type(options) == "table", "diagnostic options must be a table")
  local enabled = options.enabled == true
  local maxEntries = options.max_entries or 64
  assert(validLimit(maxEntries), "diagnostic max_entries must be a positive integer")
  assert(options.categories == nil or type(options.categories) == "table",
    "diagnostic categories must be a table")

  local categories = options.categories
  local seen = {}
  local order = {}
  local head, tail = 1, 0

  local function compact()
    if head <= maxEntries and head <= tail / 2 then return end
    local nextOrder = {}
    for index = head, tail do
      local key = order[index]
      if key ~= nil and seen[key] then
        nextOrder[#nextOrder + 1] = key
      end
    end
    order = nextOrder
    head = 1
    tail = #order
  end

  local function remember(key)
    while tail - head + 1 >= maxEntries do
      local oldest = order[head]
      order[head] = nil
      head = head + 1
      if oldest ~= nil then seen[oldest] = nil end
    end
    tail = tail + 1
    order[tail] = key
    seen[key] = true
    compact()
  end

  local api = {}

  function api:emit(level, category, message)
    if not enabled then return false, "disabled" end
    if not LEVELS[level] then return false, "invalid_level" end
    if type(category) ~= "string" or category == ""
        or #category > MAX_CATEGORY_BYTES
        or type(message) ~= "string" or message == ""
        or #message > MAX_MESSAGE_BYTES then
      return false, "invalid_message"
    end
    if categories ~= nil and categories[category] ~= true then
      return false, "category_disabled"
    end

    local key = level .. "\31" .. category .. "\31" .. message
    if seen[key] then return false, "duplicate" end

    local write = logger and logger[level]
    if type(write) ~= "function" then return false, "logger_unavailable" end
    local ok = pcall(write, logger, "[%s] %s", category, message)
    if not ok then return false, "log_failed" end

    remember(key)
    return true
  end

  function api:info(category, message)
    return self:emit("info", category, message)
  end

  function api:warn(category, message)
    return self:emit("warn", category, message)
  end

  function api:error(category, message)
    return self:emit("error", category, message)
  end

  function api:clear()
    seen = {}
    order = {}
    head, tail = 1, 0
  end

  return api
end

return Diagnostics
