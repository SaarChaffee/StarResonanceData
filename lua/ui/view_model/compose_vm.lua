local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
local itemTypeTbl = Z.TableMgr.GetTable("ItemTypeTableMgr")
local composeTbl = Z.TableMgr.GetTable("ComposeTableMgr")
local itemsVM = Z.VMMgr.GetVM("items")
local openComposeView = function(selectId)
  Z.UIMgr:OpenView("compose", {selectId = selectId})
end
local closeComposeView = function()
  Z.UIMgr:CloseView("compose")
end
local getOwnNumDataByConsumeId = function(id)
  local ret = {bind = 0, unbind = 0}
  local package = itemsVM.GetPackageInfobyItemId(id)
  for _, item in pairs(package.items) do
    if item.configId == id and item.invalid == 0 then
      if item.bindFlag == 0 then
        ret.bind = ret.bind + item.count
      else
        ret.unbind = ret.unbind + item.count
      end
    end
  end
  return ret
end
local sortComposeCatalogueItemData = function(left, right)
  local leftComposeData = composeTbl.GetRow(left.configId)
  local rightComposeData = composeTbl.GetRow(right.configId)
  if leftComposeData == nil or rightComposeData == nil then
    return
  end
  local leftIsComposable = left.num > leftComposeData.Nums
  local rightIsComposable = right.num > rightComposeData.Nums
  if leftIsComposable ~= rightIsComposable then
    return leftIsComposable
  end
  local leftItemData = itemTbl.GetRow(left.configId)
  local rightItemData = itemTbl.GetRow(right.configId)
  if leftItemData == nil then
    return false
  end
  if rightItemData == nil then
    return false
  end
  local leftTypeData = itemTypeTbl.GetRow(leftItemData.Type)
  local rightTypeData = itemTypeTbl.GetRow(rightItemData.Type)
  if leftTypeData == nil or rightTypeData == nil then
    return false
  end
  if leftTypeData.SortId ~= rightTypeData.SortId then
    return leftTypeData.SortId > rightTypeData.SortId
  end
  return leftItemData.SortID > rightItemData.SortID
end
local getComposeCatalogueItemDataList = function()
  local itemDataList = {}
  for consumeId, _ in pairs(composeTbl.GetDatas()) do
    local ownData = getOwnNumDataByConsumeId(consumeId)
    local ownNum = ownData.bind + ownData.unbind
    if 0 < ownNum then
      local itemData_ = {configId = consumeId, num = ownNum}
      table.insert(itemDataList, itemData_)
    end
  end
  table.sort(itemDataList, sortComposeCatalogueItemData)
  return itemDataList
end
local asyncSendCompose = function(consumeId, composeTimes, isOnlyUseUnbind, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local notUseBindFlag = isOnlyUseUnbind and 1 or 0
  local ret = worldProxy.ComposeReq(consumeId, composeTimes, notUseBindFlag, cancelToken)
  Z.TipsVM.ShowTips(ret)
end
local ret = {
  AsyncSendCompose = asyncSendCompose,
  CloseComposeView = closeComposeView,
  GetComposeCatalogueItemDataList = getComposeCatalogueItemDataList,
  GetOwnNumDataByConsumeId = getOwnNumDataByConsumeId,
  OpenComposeView = openComposeView,
  SortComposeCatalogueItemData = sortComposeCatalogueItemData
}
return ret
