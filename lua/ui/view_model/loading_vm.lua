local openUILoading = function(loadingType)
  Z.UIMgr:OpenView("loading_window", loadingType)
end
local closeUILoading = function()
  Z.UIMgr:CloseView("loading_window")
end
local setLoadingProgress = function(value)
  local loadingData = Z.DataMgr.Get("loading_data")
  loadingData:SetTargetProgress(value)
  Z.EventMgr:Dispatch(Z.ConstValue.Loading.UpdateLoadingProgress)
end
local ret = {
  OpenUILoading = openUILoading,
  CloseUILoading = closeUILoading,
  SetLoadingProgress = setLoadingProgress
}
return ret
