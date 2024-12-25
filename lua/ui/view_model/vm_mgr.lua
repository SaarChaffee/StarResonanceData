local v2vm = {}
local config = require("common.require_paths_config")
local require = require
local pcall = pcall
local type = type
local createVm = function(vmName)
  local vm
  local vmPath = config.GetVmPath(vmName)
  local ret, err = pcall(function()
    vm = require("ui.view_model." .. vmPath .. "_vm")
  end)
  if ret then
    if type(vm) ~= "table" then
      logError("invalid view_model:path={0}, type={1}", "ui.view_model." .. vmPath .. "_vm", type(vm))
    else
      v2vm[vmName] = vm
    end
  else
    logError("load view_model failed:{0}, error={1}", "ui.view_model." .. vmPath .. "_vm", err)
  end
end
local getVm = function(vmName)
  if v2vm[vmName] == nil then
    createVm(vmName)
  end
  return v2vm[vmName]
end
local onLogin = function()
end
local onLogout = function()
end
local init = function()
end
local unInit = function()
  v2vm = {}
  onLogout()
end
local ret = {
  GetVM = getVm,
  Init = init,
  UnInit = unInit,
  OnLogin = onLogin,
  OnLogout = onLogout
}
return ret
