local bagRed = require("rednode.bag_red")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.ResonanceSkill) then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if itemConfig and itemConfig.Type == E.ResonanceSkillItemType.Prop then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    if not gotoFuncVM.CheckFuncCanUse(E.FunctionID.WeaponAoyiSkill) then
      return
    end
    local skillAoyiItemTableRow = Z.TableMgr.GetRow("SkillAoyiItemTableMgr", configId)
    if skillAoyiItemTableRow then
      local weaponSkillVM = Z.VMMgr.GetVM("weapon_skill")
      weaponSkillVM.OpenWeaponSkillView(E.SkillType.MysteriesSkill, skillAoyiItemTableRow.SkillId)
    end
  elseif itemConfig and itemConfig.Type == E.ResonanceSkillItemType.Material then
    local resonancePowerVM = Z.VMMgr.GetVM("resonance_power")
    local weaponData = Z.DataMgr.Get("weapon_data")
    local itemId = weaponData:GetResonancePropIdByDrawId(configId)
    resonancePowerVM.OpenResonancePowerCreate(itemUuid, itemId)
  end
end
local getBtnName = function(itemUuid, configId)
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if itemConfig then
    if itemConfig.Type == E.ResonanceSkillItemType.Prop then
      return Lang("GoView")
    elseif itemConfig.Type == E.ResonanceSkillItemType.Material then
      return Lang("Make")
    end
  end
  return ""
end
local priority = function()
  return 2
end
local loadRedNode = function(itemUuid, configId)
  return bagRed.GetResonanceItemRedId(configId)
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority,
  LoadRedNode = loadRedNode
}
return ret
