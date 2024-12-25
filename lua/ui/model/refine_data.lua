local super = require("ui.model.data_base")
local RefineData = class("RefineData", super)

function RefineData:ctor()
  super.ctor(self)
  self.SmashItemDict = {}
  self.AddEnergy = 0
  self.SmashItemConfigData = {}
  self.RefineItemListData = {}
end

function RefineData:SetSmashItemData(uuid, count)
  if count == 0 then
    self.SmashItemDict[uuid] = nil
    return
  end
  self.SmashItemDict[uuid] = count
end

function RefineData:GetSmashItemData(uuid)
  if uuid then
    return self.SmashItemDict[uuid] or 0
  end
  return self.SmashItemDict
end

function RefineData:SetSmashItemConfigData(configId, count, isAdd)
  if self.SmashItemConfigData[configId] then
    if isAdd then
      self.SmashItemConfigData[configId] = self.SmashItemConfigData[configId] + count
    else
      self.SmashItemConfigData[configId] = self.SmashItemConfigData[configId] - count
    end
  else
    self.SmashItemConfigData[configId] = count
  end
end

function RefineData:GetSmashItemConfigData()
  return self.SmashItemConfigData
end

function RefineData:ResetSmashItemData()
  self.SmashItemDict = {}
  self.SmashItemConfigData = {}
  self.AddEnergy = 0
end

function RefineData:SetAddEnergy(count)
  self.AddEnergy = count
end

function RefineData:GetAddEnergy(isShow)
  local energyItem = Z.ContainerMgr.CharSerialize.energyItem
  local energyLimit = energyItem.energyLimit
  local backpackVm = Z.VMMgr.GetVM("backpack")
  local nowData = backpackVm.GetItemCount(E.SpecialItem.RefineEnergy)
  local nowAddEnergy = self.AddEnergy + nowData
  if isShow then
    return nowAddEnergy
  else
    return self.AddEnergy
  end
end

function RefineData:SetRefineItemListData(queueIndex, columnIndex, status)
  if not self.RefineItemListData[queueIndex] then
    self.RefineItemListData[queueIndex] = {}
  end
  self.RefineItemListData[queueIndex][columnIndex] = status
end

function RefineData:GetRefineItemListData(queueIndex, columnIndex)
  if not self.RefineItemListData[queueIndex] then
    return Z.PbEnum("ERefineState", "Null")
  end
  return self.RefineItemListData[queueIndex][columnIndex]
end

return RefineData
