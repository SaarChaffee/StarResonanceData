local openUILoading = function(loadingType)
  Z.UIMgr:OpenView("loading_window", loadingType)
end
local closeUILoading = function()
  Z.UIMgr:CloseView("loading_window")
end
local ret = {OpenUILoading = openUILoading, CloseUILoading = closeUILoading}
return ret
