local openItemShowView = function(viewData, audioName, title, isShowPrivilege)
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.ItemShow, "com_rewards_window", {
    title = title,
    itemList = viewData,
    audio = audioName,
    isShowPrivilege = isShowPrivilege
  }, 1)
end
local closeItemShowView = function()
  Z.UIMgr:CloseView("com_rewards_window")
end
local openEquipAcquireViewByItems = function(itemData, audioName, title)
  local coldItems = {}
  local noOverlapItems = {}
  local overlapItems = {}
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  for _, value in pairs(itemData) do
    local itemBase = itemTableMgr.GetRow(value.configId)
    if itemBase then
      if itemBase.Overlap == 1 then
        local data = {
          configId = value.configId,
          uuid = value.uuid,
          count = value.count,
          itemInfo = value
        }
        noOverlapItems[#noOverlapItems + 1] = data
      else
        local serverTime = Z.ServerTime:GetServerTime() / 1000
        local coolDownTime = value.coolDownExpireTime or 0
        local isCold = serverTime < coolDownTime
        if isCold then
          local data = {
            configId = value.configId,
            uuid = value.uuid,
            count = value.count,
            itemInfo = value
          }
          coldItems[#coldItems + 1] = data
        elseif overlapItems[value.configId] then
          overlapItems[value.configId].count = overlapItems[value.configId].count + value.count
        else
          local data = {
            cout = value.count,
            configId = value.configId,
            uuid = value.uuid,
            count = value.count
          }
          overlapItems[value.configId] = data
        end
      end
    end
  end
  overlapItems = table.zvalues(overlapItems)
  table.zmerge(overlapItems, noOverlapItems)
  table.zmerge(overlapItems, coldItems)
  table.sort(overlapItems, function(left, right)
    local leftItemRow = itemTableMgr.GetRow(left.configId)
    local rightItemRow = itemTableMgr.GetRow(right.configId)
    if leftItemRow and rightItemRow then
      return leftItemRow.SortID > rightItemRow.SortID
    end
    return false
  end)
  openItemShowView(overlapItems, audioName, title)
end
local mergeRepeatedItems = function(items)
  local temp = {}
  if items ~= nil or 0 < #items then
    for index, value in ipairs(items) do
      local key = value.configId .. "_" .. value.bindFlag
      local tempItem = temp[key]
      if tempItem == nil then
        temp[key] = value
      else
        tempItem.count = tempItem.count + value.count
      end
    end
  end
  local list = {}
  for _, value in pairs(temp) do
    table.insert(list, value)
  end
  return list
end
local assembleData = function(itemData)
  local temp = {}
  local awardTab = {}
  for k, v in pairs(itemData) do
    temp[k] = {
      awardId = v.configId,
      awardNum = v.count,
      awardNumExtend = v.count
    }
  end
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local itemList = awardPreviewVm.mergeAwardItems(temp)
  for k, v in pairs(itemList) do
    awardTab[k] = {
      configId = v.awardId,
      count = v.awardNum
    }
  end
  return awardTab
end
local openItemShowViewByItems = function(items, isShowPrivilege)
  if items == nil or #items == 0 then
    return
  end
  local itemsData = mergeRepeatedItems(items)
  openItemShowView(itemsData, nil, nil, isShowPrivilege)
end
local ret = {
  OpenItemShowView = openItemShowView,
  CloseItemShowView = closeItemShowView,
  MergeRepeatedItems = mergeRepeatedItems,
  AssembleData = assembleData,
  OpenEquipAcquireViewByItems = openEquipAcquireViewByItems,
  OpenItemShowViewByItems = openItemShowViewByItems
}
return ret
