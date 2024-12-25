local refreshComboView = function(comboNumber)
  Z.UIMgr:OpenView("combo", comboNumber)
end
local closeComboView = function()
  Z.UIMgr:CloseView("combo")
end
local ret = {RefreshComboView = refreshComboView, CloseComboView = closeComboView}
return ret
