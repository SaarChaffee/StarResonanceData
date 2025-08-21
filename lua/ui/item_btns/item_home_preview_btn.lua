local WorldProxy = require("zproxy.world_proxy")
local checkValid = function(itemUuid, configId, data)
  if Z.GlobalHome.HomePlayerFurniturePackageItemId == configId then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data, token)
  local ret = WorldProxy.QueryPlayerFurniture({}, token)
  if ret and ret.furnitureWarehouse then
    local index = 1
    local items = {}
    for _, value in pairs(ret.furnitureWarehouse.furnitureItems) do
      local item = value.ownerToStackMap[Z.ContainerMgr.CharSerialize.charId]
      items[index] = {
        awardId = value.ConfigId,
        awardNum = item.count
      }
      index = index + 1
    end
    if index == 1 then
      Z.TipsVM.ShowTips(1044025)
      return
    end
    local awardPreviewVM = Z.VMMgr.GetVM("awardpreview")
    awardPreviewVM.OpenRewardDetailViewByListData(items)
  else
    Z.TipsVM.ShowTips(1044025)
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("Preview")
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
