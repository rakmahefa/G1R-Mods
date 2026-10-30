-- Bounded FIFO cache for immutable or derived data only.
-- Callers own invalidation; this cache never holds a game/session reference
-- on their behalf and does not create timers or background work.

local Cache = {}
local HUGE = math.huge

local function validKey(key)
  if type(key) == "string" then return key ~= "" end
  return type(key) == "number" and key == key
    and key ~= HUGE and key ~= -HUGE
end

local function validLimit(limit)
  return type(limit) == "number" and limit == limit
    and limit ~= HUGE and limit ~= -HUGE
    and limit % 1 == 0 and limit >= 1
end

function Cache.new(maxEntries)
  assert(validLimit(maxEntries), "cache maxEntries must be a positive integer")

  local values = {}
  local order = {}
  local head, tail, count = 1, 0, 0

  local function compact()
    if head <= maxEntries and head <= tail / 2 then return end
    local nextOrder = {}
    for index = head, tail do
      local key = order[index]
      if key ~= nil and values[key] ~= nil then
        nextOrder[#nextOrder + 1] = key
      end
    end
    order = nextOrder
    head = 1
    tail = #order
  end

  local function evictOldest()
    while head <= tail do
      local key = order[head]
      order[head] = nil
      head = head + 1
      if key ~= nil and values[key] ~= nil then
        values[key] = nil
        count = count - 1
        compact()
        return
      end
    end
    compact()
  end

  local api = {}

  function api:get(key)
    if not validKey(key) then return nil, false end
    local value = values[key]
    return value, value ~= nil
  end

  function api:set(key, value)
    assert(validKey(key), "cache key must be a non-empty string or finite number")
    assert(value ~= nil, "cache values cannot be nil")
    if values[key] ~= nil then
      values[key] = value
      return true
    end
    if count >= maxEntries then evictOldest() end
    tail = tail + 1
    order[tail] = key
    values[key] = value
    count = count + 1
    return true
  end

  function api:remove(key)
    if not validKey(key) or values[key] == nil then return false end
    values[key] = nil
    count = count - 1
    compact()
    return true
  end

  function api:clear()
    values = {}
    order = {}
    head, tail, count = 1, 0, 0
  end

  function api:size()
    return count
  end

  return api
end

return Cache
