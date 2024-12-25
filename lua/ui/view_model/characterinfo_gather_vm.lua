local closeView = function()
  Z.UIMgr:CloseView("characterinfo_gather")
end
local openView = function(subViewType, data)
  local viewData = {}
  viewData.subViewType = subViewType
  viewData.data = data
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Demo_yzh, "characterinfo_gather", function()
    Z.UIMgr:OpenView("characterinfo_gather", viewData)
  end)
end
local ret = {CloseView = closeView, OpenView = openView}
return ret
