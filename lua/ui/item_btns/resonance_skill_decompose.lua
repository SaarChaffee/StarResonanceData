local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.ResonanceSkill) then
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
    if itemRow.Type == E.ResonanceSkillItemType.Prop then
      return E.ItemBtnState.Active
    end
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local resonancePowerVM_ = Z.VMMgr.GetVM("resonance_power")
  resonancePowerVM_.OpenResonancePowerDecompose(itemUuid, configId)
end
local getBtnName = function(itemUuid, configId)
  return Lang("Decompose")
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
