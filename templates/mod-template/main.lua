-- Entry point for __MOD_NAME__.
-- Keep runtime dependencies inside the public mod API unless the manifest
-- explicitly declares a reviewed permission.

return function(mod)
  mod.log:info("__MOD_ID__ loaded")
end
