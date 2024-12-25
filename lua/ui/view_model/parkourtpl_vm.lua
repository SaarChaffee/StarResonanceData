local openView = function()
  if Z.UIMgr:IsActive("parkour_tpl") then
    return
  end
  Z.UIMgr:OpenView("parkour_tpl")
end
local closeView = function()
  Z.UIMgr:CloseView("parkour_tpl")
end
local ret = {OpenView = openView, CloseView = closeView}
return ret
