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
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if not gotoFuncVM.CheckFuncCanUse(E.FunctionID.WeaponAoyiSkill) then
    return
  end
  local row = Z.TableMgr.GetRow("SkillAoyiItemTableMgr", configId)
  if row then
    local weaponSkillVM = Z.VMMgr.GetVM("weapon_skill")
    weaponSkillVM.OpenWeaponSkillView(E.SkillType.MysteriesSkill, row.SkillId)
  end
end
local getBtnName = function(itemUuid, configId)
  local config = Z.TableMgr.GetRow("SkillAoyiItemTableMgr", configId)
  if config == nil then
    return ""
  end
  local weaponSkillVM = Z.VMMgr.GetVM("weapon_skill")
  local isUnlock = weaponSkillVM:CheckSkillUnlock(config.SkillId)
  if isUnlock then
    return Lang("GoToCultivate")
  else
    return Lang("GotoActive")
  end
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
