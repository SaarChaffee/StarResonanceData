local bagRed = require("rednode.bag_red")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.ResonanceSkill) then
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
    if itemRow.Type == E.ResonanceSkillItemType.Material then
      return E.ItemBtnState.Active
    end
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.TraceOrSwitchFunc(E.ResonanceFuncId.Create)
end
local getBtnName = function(itemUuid, configId)
  return Lang("GoToMake")
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
