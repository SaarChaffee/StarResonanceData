local SeasonCultivateRed = {}
local seasonCultivateVm = Z.VMMgr.GetVM("season_cultivate")
local itemsVm = Z.VMMgr.GetVM("items")
local seasonVm = Z.VMMgr.GetVM("season")
local normalNodeIndex = {
  1,
  2,
  3,
  4,
  5,
  6
}
local normalNodeMoneyID = 0
local normalNodeMoneyNum = 0
local normalNodeItemOffered = {}
local coreMoneyId = 0
local coreItemIds = {}
local coreSlotRedTable = {}
local normalNodeRedTable = {}

function SeasonCultivateRed.commonCheck(tempHole)
  if tempHole == nil then
    return
  end
  local CoreNodeCondition = seasonCultivateVm.CheckCoreNodeCondition(tempHole.NodeCondition)
  if CoreNodeCondition == false then
    return false
  end
  local CoreCondition = seasonCultivateVm.CheckCoreCondition(tempHole.Condition)
  if CoreCondition == false then
    return false
  end
  return true
end

function SeasonCultivateRed.checkCoreIsShowRed()
  local max = seasonCultivateVm.GetHoleMaxLevel(E.SeasonCultivateHole.Core)
  local current = seasonCultivateVm.GetCoreNodeLevel() + 1
  local hasNext = max > current
  if not hasNext then
    return false
  end
  local level = seasonCultivateVm.GetCoreNodeLevel()
  local tempHole = seasonCultivateVm.GetHoleConfigByLevel(E.SeasonCultivateHole.Core, level + 1)
  if tempHole == nil then
    return
  end
  if not SeasonCultivateRed.commonCheck(tempHole) then
    return false
  end
  local moneyCoudition = seasonCultivateVm.CheckCoreMoneyCoudition()
  if moneyCoudition == false then
    return false
  end
  local itemCoudition = seasonCultivateVm.CheckCoreItemCoudition()
  if itemCoudition == false then
    return false
  end
  return true
end

function SeasonCultivateRed.setCoreSlotRed()
  local canSelectedCount = seasonCultivateVm.GetNowCanSelectedCoreCount()
  if canSelectedCount == 0 then
    for i = 1, #coreSlotRedTable do
      Z.RedPointMgr.UpdateNodeCount(coreSlotRedTable[i], 0)
    end
    return
  end
  for i = 1, canSelectedCount do
    local data = seasonCultivateVm.GetCoreNodeSlotInfoBySlotId(i)
    if data then
      Z.RedPointMgr.UpdateNodeCount(coreSlotRedTable[i], 0)
    else
      Z.RedPointMgr.UpdateNodeCount(coreSlotRedTable[i], 1)
    end
  end
end

function SeasonCultivateRed.SetNormalNodeRed()
  local totalMoney = 0
  if normalNodeMoneyID ~= 0 then
    totalMoney = itemsVm.GetItemTotalCount(normalNodeMoneyID)
    if totalMoney < normalNodeMoneyNum then
      for i = 1, #normalNodeRedTable do
        Z.RedPointMgr.UpdateNodeCount(normalNodeRedTable[i], 0)
      end
      return
    end
  end
  local flag = false
  for itemId, count in pairs(normalNodeItemOffered) do
    local hasCount = itemsVm.GetItemTotalCount(itemId)
    if 0 < hasCount and totalMoney >= count * normalNodeMoneyNum then
      flag = true
      break
    end
  end
  if flag == false then
    for i = 1, #normalNodeRedTable do
      Z.RedPointMgr.UpdateNodeCount(normalNodeRedTable[i], 0)
    end
    return
  end
  for i = 1, #normalNodeIndex do
    local curLevel = seasonCultivateVm.GetNodeLevel(normalNodeIndex[i])
    local maxLevel = seasonCultivateVm.GetHoleMaxLevel(normalNodeIndex[i])
    if curLevel >= maxLevel then
      Z.RedPointMgr.UpdateNodeCount(normalNodeRedTable[i], 0)
    else
      local tempHole = seasonCultivateVm.GetHoleConfigByLevel(normalNodeIndex[i], curLevel + 1)
      if tempHole then
        if not SeasonCultivateRed.commonCheck(tempHole) then
          Z.RedPointMgr.UpdateNodeCount(normalNodeRedTable[i], 0)
        else
          Z.RedPointMgr.UpdateNodeCount(normalNodeRedTable[i], 1)
        end
      end
    end
  end
end

function SeasonCultivateRed.setCoreRed()
  if SeasonCultivateRed.checkCoreIsShowRed() then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.SeasonCultivateCoreBtnRed, 1)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.SeasonCultivateCoreBtnRed, 0)
  end
end

function SeasonCultivateRed.addNormalNodeRed()
  for i = 1, #normalNodeIndex do
    local redName = "normalNodeRed" .. i
    normalNodeRedTable[i] = redName
    Z.RedPointMgr.AddChildNodeData(E.RedType.SeasonCultivateRed, E.RedType.SeasonCultivateNodeRed, redName)
  end
end

function SeasonCultivateRed.addCoreSlotRed()
  local limit = Z.Global.EffectiveNodeNum
  if limit then
    local slotCount = limit[#limit][2]
    for i = 1, slotCount do
      local redName = "coreSlotRed" .. i
      coreSlotRedTable[i] = redName
      Z.RedPointMgr.AddChildNodeData(E.RedType.SeasonCultivateRed, E.RedType.SeasonCultivateCoreSlotRed, redName)
    end
  end
end

function SeasonCultivateRed.setCoreData()
  if coreMoneyId ~= 0 then
    return
  end
  local current = seasonCultivateVm.GetCoreNodeLevel() + 1
  local max = seasonCultivateVm.GetHoleMaxLevel(E.SeasonCultivateHole.Core)
  if current > max then
    current = max
  end
  local tempHole = seasonCultivateVm.GetHoleConfigByLevel(E.SeasonCultivateHole.Core, current)
  if tempHole then
    coreMoneyId = tempHole.NumberConsume[1][1]
    coreItemIds = {}
    for i, v in pairs(tempHole.NumberConsume) do
      if i ~= 1 then
        coreItemIds[#coreItemIds + 1] = v[1]
      end
    end
  end
end

function SeasonCultivateRed.setNormalNodeData()
  if normalNodeMoneyID ~= 0 then
    return
  end
  local season = seasonVm.GetCurrentSeasonId()
  local money = Z.Global.ProgressMoneyNum
  if money[1] == season then
    normalNodeMoneyID = money[2]
    normalNodeMoneyNum = money[3]
  end
  local items = Z.Global.ProgressValueItem
  for _, v in pairs(items) do
    if v[1] == season then
      normalNodeItemOffered[v[2]] = v[3]
    end
  end
end

function SeasonCultivateRed.refreshRed()
  local season = seasonVm.GetCurrentSeasonId()
  if season == 0 then
    return
  end
  SeasonCultivateRed.setNormalNodeData()
  SeasonCultivateRed.setCoreData()
  SeasonCultivateRed.setCoreRed()
  SeasonCultivateRed.SetNormalNodeRed()
  SeasonCultivateRed.setCoreSlotRed()
end

function SeasonCultivateRed.Init()
  SeasonCultivateRed.addCoreSlotRed()
  SeasonCultivateRed.addNormalNodeRed()
  SeasonCultivateRed.bindEvents()
end

function SeasonCultivateRed.coreHoleNodeInfoChange(container, dirtys)
  SeasonCultivateRed.setCoreSlotRed()
  SeasonCultivateRed.setCoreRed()
  SeasonCultivateRed.SetNormalNodeRed()
end

function SeasonCultivateRed.itemChange(item)
  if item.configId == normalNodeMoneyID then
    SeasonCultivateRed.SetNormalNodeRed()
  end
  for itemId, count in pairs(normalNodeItemOffered) do
    if item.configId == itemId then
      SeasonCultivateRed.SetNormalNodeRed()
      break
    end
  end
  if item.configId == coreMoneyId then
    SeasonCultivateRed.setCoreRed()
  end
  for index, configId in pairs(coreItemIds) do
    if item.configId == configId then
      SeasonCultivateRed.setCoreRed()
      break
    end
  end
end

function SeasonCultivateRed.onSeasonTitleChange(container, dirtyKeys)
  if dirtyKeys.seasonRankList then
    SeasonCultivateRed.setCoreRed()
    SeasonCultivateRed.SetNormalNodeRed()
  end
end

function SeasonCultivateRed.bindEvents()
  function SeasonCultivateRed.coreHoleNodeInfoChangeFunc(container, dirtys)
    SeasonCultivateRed.coreHoleNodeInfoChange(container, dirtys)
  end
  
  function SeasonCultivateRed.onSeasonTitleChangeFunc(container, dirtyKeys)
    SeasonCultivateRed.onSeasonTitleChange(container, dirtyKeys)
  end
  
  Z.ContainerMgr.CharSerialize.seasonMedalInfo.Watcher:RegWatcher(SeasonCultivateRed.coreHoleNodeInfoChangeFunc)
  Z.ContainerMgr.CharSerialize.seasonRankList.Watcher:RegWatcher(SeasonCultivateRed.onSeasonTitleChangeFunc)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, SeasonCultivateRed.itemChange)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, SeasonCultivateRed.itemChange)
  Z.EventMgr:Add(Z.ConstValue.SyncSeason, SeasonCultivateRed.refreshRed)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, SeasonCultivateRed.itemChange)
end

function SeasonCultivateRed.UnInit()
  SeasonCultivateRed.coreHoleNodeInfoChangeFunc = nil
  Z.ContainerMgr.CharSerialize.seasonMedalInfo.Watcher:UnregWatcher(SeasonCultivateRed.coreHoleNodeInfoChangeFunc)
  Z.ContainerMgr.CharSerialize.seasonRankList.Watcher:UnregWatcher(SeasonCultivateRed.onSeasonTitleChangeFunc)
  Z.EventMgr:Remove(Z.ConstValue.SyncSeason, SeasonCultivateRed.refreshRed)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, SeasonCultivateRed.itemChange)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, SeasonCultivateRed.itemChange)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, SeasonCultivateRed.itemChange)
end

return SeasonCultivateRed
