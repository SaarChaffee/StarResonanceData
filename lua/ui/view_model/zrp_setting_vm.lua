local openZrpSetting = function()
  Z.UIMgr:OpenView("zrp_setting")
end
local closeZrpSetting = function()
  Z.UIMgr:CloseView("zrp_setting")
end
local ret = {OpenZrpSetting = openZrpSetting, CloseZrpSetting = closeZrpSetting}
return ret
