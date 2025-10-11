local getLimitCount = function(configId)
  local itemFuctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local funcData = itemFuctionTableMgr.GetRow(configId, true)
  local limitCount = 0
  if funcData and funcData.CounterId ~= 0 then
    limitCount = Z.CounterHelper.GetResidueLimitCountByCounterId(funcData.CounterId)
    if limitCount == 0 then
      Z.TipsVM.ShowTips(1000655)
      return limitCount, true
    end
  end
  return limitCount
end
local openUsePopup = function(viewData)
  if viewData == nil or viewData.maxUseCount <= 1 then
    return
  end
  local limitCount, isReturn = getLimitCount(viewData.configId)
  if isReturn then
    return
  end
  if limitCount == 0 then
    limitCount = viewData.maxUseCount
  end
  local useItemData_ = Z.DataMgr.Get("user_item_popup_data")
  local count = 0
  if viewData.itemCount <= viewData.maxUseCount then
    count = viewData.itemCount
  else
    count = viewData.maxUseCount
  end
  count = math.min(limitCount, count)
  useItemData_:SetMaxUseCount(count)
  Z.UIMgr:OpenView("c_com_select_use_popup", viewData)
end
local openDeletePopup = function(viewData)
  if viewData == nil or viewData.maxUseCount <= 0 then
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
local closeUsePopup = function()
  Z.UIMgr:CloseView("c_com_select_use_popup")
end
local ret = {
  OpenUsePopup = openUsePopup,
  CloseUsePopup = closeUsePopup,
  OpenDeletePopup = openDeletePopup
}
return ret
