local getItemfuncData = function(configId)
  local itemFuctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local funcData = itemFuctionTableMgr.GetRow(configId, true)
  return funcData
end
local checkValid = function(itemUuid, configId, data)
  local funcData = getItemfuncData(configId)
  if funcData == nil or funcData.Type == E.ItemFunctionType.FuncSwitch or funcData.NotShowBtn then
    return E.ItemBtnState.UnActive
  end
  return E.ItemBtnState.Active
end
local onClick = function(itemUuid, configId, data)
  local ret
  local itemsVM = Z.VMMgr.GetVM("items")
  local isOk = itemsVM.OpenSelectGiftPackageView(configId, itemUuid)
  if isOk then
    return true
  end
  local itemFuctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local funcData = itemFuctionTableMgr.GetRow(configId, true)
  if not funcData then
    return
  end
  local confirmFunc = function()
    local itemsData = Z.DataMgr.Get("items_data")
    local param = itemsVM.AssembleUseItemParam(configId, itemUuid, 1)
    itemsData:CreatCancelSource()
    ret = itemsVM.AsyncUseItemByUuid(param, itemsData.CancelSource:CreateToken())
    itemsData:RecycleCancelSource()
  end
  if funcData.Reconfirm == 1 and funcData.Type == E.ItemFunctionType.Gift then
    local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId, true)
    local data = {
      dlgType = E.DlgType.YesNo,
      onConfirm = confirmFunc,
      labDesc = Lang("ReconfirmUseItem", {
        itemName = itemTableRow.Name
      })
    }
    Z.DialogViewDataMgr:OpenDialogView(data)
  else
    confirmFunc()
  end
  return ret
end
local getBtnName = function(itemUuid, configId)
  local funcData = getItemfuncData(configId)
  if funcData == nil then
    return
  end
  return funcData.Button
end
local priority = function()
  return 1
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
