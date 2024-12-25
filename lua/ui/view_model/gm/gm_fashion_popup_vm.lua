local openGmFashionPopup = function()
  Z.UIMgr:OpenView("gm_fashion_popup")
end
local closeGmFashionPopup = function()
  Z.UIMgr:CloseView("gm_fashion_popup")
end
local ret = {OpenGmFashionPopup = openGmFashionPopup, CloseGmFashionPopup = closeGmFashionPopup}
return ret
