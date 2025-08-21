local checkValid = function(itemUuid, configId, data)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId, true)
  if itemRow.Type == E.ItemType.Blueprint or itemRow.Type == E.ResonanceSkillItemType then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local itemMaterialVm = Z.VMMgr.GetVM("item_material")
  local materialData = itemMaterialVm.GetItemMaterialData(configId)
  if materialData == nil or not next(materialData) then
    return
  end
  local itemSourceVm = Z.VMMgr.GetVM("item_source")
  local data = itemSourceVm.GetSourceByFunctionId(materialData[1][1])
  if data then
    itemSourceVm.JumpToSource(data)
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("Make")
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
