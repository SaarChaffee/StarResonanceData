local MOD_DEFINE = require("ui.model.mod_define")
local checkValid = function(itemUuid, configId, data)
  local modVM = Z.VMMgr.GetVM("mod")
  local itemsVM = Z.VMMgr.GetVM("items")
  local isEquip, pos = modVM.IsModEquip(itemUuid)
  if itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Mod) and data and data.viewConfigKey and data.viewConfigKey == "mod_window" and isEquip and pos ~= data.slotId then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local modVM = Z.VMMgr.GetVM("mod")
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemInfo = itemsVM.GetItemInfo(itemUuid, E.BackPackItemPackageType.Mod)
  if itemInfo and itemInfo.bindFlag == 1 then
    local confirmFunc = function()
      modVM.AsyncEquipMod(itemUuid, data.slotId, data.cancelToken)
    end
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("ModWearingBindingTips"), confirmFunc, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.ModEquipBindFlag)
    return
  else
    modVM.AsyncEquipMod(itemUuid, data.slotId, data.cancelToken)
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("Replace")
end
local priority = function()
  return 2
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
