-- Standard return shape for expected, recoverable service outcomes.

local Result = {}

function Result.ok(value, metadata)
  return {
    ok = true,
    value = value,
    metadata = metadata,
  }
end

function Result.err(code, message, details)
  assert(type(code) == "string" and code:match("^[%w_-]+$"),
    "result error code must be a stable identifier")
  assert(type(message) == "string" and message ~= "",
    "result error message is required")
  return {
    ok = false,
    error = {
      code = code,
      message = message,
      details = details,
    },
  }
end

function Result.is(value)
  return type(value) == "table" and type(value.ok) == "boolean"
    and (value.ok or (type(value.error) == "table"
      and type(value.error.code) == "string"))
end

function Result.unwrap(value)
  assert(Result.is(value), "cannot unwrap an invalid result")
  if value.ok then return value.value end
  return nil, value.error
end

return Result
