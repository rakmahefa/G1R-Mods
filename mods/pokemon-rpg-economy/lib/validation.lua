-- Pure input validation helpers shared by the mod's services.

local Validation = {}
local HUGE = math.huge

function Validation.isFiniteNumber(value)
  return type(value) == "number"
    and value == value
    and value ~= HUGE
    and value ~= -HUGE
end

function Validation.numberInRange(value, minimum, maximum)
  if not Validation.isFiniteNumber(value) then
    return false, "invalid_number"
  end
  if (minimum ~= nil and not Validation.isFiniteNumber(minimum))
      or (maximum ~= nil and not Validation.isFiniteNumber(maximum))
      or (minimum ~= nil and maximum ~= nil and minimum > maximum) then
    return false, "invalid_bounds"
  end
  if minimum ~= nil and value < minimum then
    return false, "below_minimum"
  end
  if maximum ~= nil and value > maximum then
    return false, "above_maximum"
  end
  return true
end

function Validation.integer(value, minimum, maximum)
  local valid, code = Validation.numberInRange(value, minimum, maximum)
  if not valid then return false, code end
  if value % 1 ~= 0 then return false, "not_integer" end
  return true
end

function Validation.nonEmptyString(value, maximumLength)
  if type(value) ~= "string" or value == "" then
    return false, "invalid_string"
  end
  if maximumLength ~= nil then
    if not Validation.integer(maximumLength, 1) then
      return false, "invalid_maximum_length"
    end
    if #value > maximumLength then return false, "string_too_long" end
  end
  return true
end

function Validation.identifier(value)
  return type(value) == "string"
    and value:match("^[%w_-]+$") ~= nil
end

function Validation.oneOf(value, choices)
  if type(choices) ~= "table" then return false end
  for _, choice in ipairs(choices) do
    if value == choice then return true end
  end
  return false
end

-- Validate a dense 1-based array. Non-array keys and holes are rejected so
-- list limits cannot be bypassed by sparse or mixed-key tables.
function Validation.array(value, maximumItems)
  if type(value) ~= "table" then return false, "invalid_array" end
  if maximumItems ~= nil and not Validation.integer(maximumItems, 0) then
    return false, "invalid_maximum_items"
  end

  local count, largest = 0, 0
  for key in next, value do
    if not Validation.integer(key, 1) then
      return false, "invalid_array_key"
    end
    count = count + 1
    if key > largest then largest = key end
    if maximumItems ~= nil and count > maximumItems then
      return false, "too_many_items"
    end
  end
  if count ~= largest then return false, "sparse_array" end
  return true
end

return Validation
