local MOD_DEFINE = require("ui.model.mod_define")
local checkValid = function(itemUuid, configId, data)
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local modVM = Z.VMMgr.GetVM("mod")
  modVM.EnterModIntensifyView(MOD_DEFINE.ModIntensifyType.Intensify, itemUuid)
end
local getBtnName = function(itemUuid, configId)
  return Lang("Cultivate")
end
local priority = function()
  return 3
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
