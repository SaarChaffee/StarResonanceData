local vMPaths = require("common.vm_scripts_path")
local getVmPath = function(vmName)
  if vmName == nil then
    logError("vmName is nil , please check vmName !!!")
    return
  end
  local path = vMPaths[vmName]
  if path == nil then
    return vmName
  end
  return path
end
local ret = {GetVmPath = getVmPath}
return ret
