local equipVm_ = Z.VMMgr.GetVM("equip_system")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if not itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Equip) then
    return E.ItemBtnState.UnActive
  end
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, false)
  if equipTable == nil then
    return E.ItemBtnState.UnActive
  end
  local partId = equipTable.EquipPart
  local equipAttr = Z.ContainerMgr.CharSerialize.equip.equipList[partId]
  if equipAttr and equipAttr.itemUuid == itemUuid then
    if data.viewConfigKey == "backpack_main" then
      return E.ItemBtnState.Hide
    end
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, false)
  if equipTable then
    if data.viewConfigKey == "backpack_main" then
      equipVm_.OpenEquipSystemView(equipTable.EquipPart)
    elseif data.viewConfigKey == "equip_system" then
      local func = function()
        local equipVm = Z.VMMgr.GetVM("equip_system")
        equipVm.AsyncTakeOffEquip(equipTable.EquipPart, data.cancelToken)
      end
      if equipTable.EquipPart == E.EquipPart.Weapon then
        local equipWeaponRow = Z.TableMgr.GetTable("EquipWeaponTableMgr").GetRow(configId)
        if equipWeaponRow then
          local professionSystemTable = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(equipWeaponRow.ProfessionId)
          if professionSystemTable then
            Z.DialogViewDataMgr:OpenNormalDialog(Lang("UnloadingWeaponTips", {
              val = professionSystemTable.Name
            }), function()
              func()
            end)
          end
        end
      else
        func()
      end
    end
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("Remove")
end
local priority = function()
  return 4
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
