local openGmItemPopup = function()
  Z.UIMgr:OpenView("gm_item_popup")
end
local closeGmItemPopup = function()
  Z.UIMgr:CloseView("gm_item_popup")
end
local ret = {OpenGmItemPopup = openGmItemPopup, CloseGmItemPopup = closeGmItemPopup}
return ret
