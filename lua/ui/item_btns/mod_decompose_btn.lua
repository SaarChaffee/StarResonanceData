local MOD_DEFINE = require("ui.model.mod_define")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Mod) and data and data.viewConfigKey and data.viewConfigKey ~= "mod_window" then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local modVM = Z.VMMgr.GetVM("mod")
  modVM.EnterModIntensifyView(MOD_DEFINE.ModIntensifyType.Decompose, nil)
end
local getBtnName = function(itemUuid, configId)
  return Lang("Decompose")
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
