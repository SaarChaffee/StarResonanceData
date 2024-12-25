local openUsePopup = function(viewData)
  if viewData == nil or viewData.maxUseCount <= 1 then
    return
  end
  local useItemData_ = Z.DataMgr.Get("user_item_popup_data")
  local count = 0
  if viewData.itemCount <= viewData.maxUseCount then
    count = viewData.itemCount
  else
    count = viewData.maxUseCount
  end
  useItemData_:SetMaxUseCount(count)
  Z.UIMgr:OpenView("c_com_select_use_popup", viewData)
end
local openDeletePopup = function(viewData)
  if viewData == nil then
    return
  end
  local useItemData_ = Z.DataMgr.Get("user_item_popup_data")
  useItemData_:SetMaxUseCount(viewData.maxUseCount)
  Z.UIMgr:OpenView("c_com_select_use_popup", viewData)
end
local closeUsePopup = function()
  Z.UIMgr:CloseView("c_com_select_use_popup")
end
local ret = {
  OpenUsePopup = openUsePopup,
  CloseUsePopup = closeUsePopup,
  OpenDeletePopup = openDeletePopup
}
return ret
