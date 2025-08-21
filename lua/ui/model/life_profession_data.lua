local super = require("ui.model.data_base")
E.LifeProfessionRewardState = {
  UnFinished = 0,
  UnGetReward = 1,
  GetReward = 2
}
local LifeProfessionData = class("LifeProfessionData", super)

function LifeProfessionData:ctor()
  self.lifeCollectionData = Z.DataMgr.Get("life_collection_data")
  self.lifeMenufactorData_ = Z.DataMgr.Get("life_menufacture_data")
end

function LifeProfessionData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.filterSceneTable = nil
  self.filterLevelTable = nil
  self.filterNameTable = nil
  self.filterConsumeTable = nil
  self.lockedRecipeTable = nil
  self.filterTypeTable = nil
end

function LifeProfessionData:Clear()
  self.lockedRecipeTable = nil
end

function LifeProfessionData:UnInit()
  self.lockedRecipeTable = nil
end

function LifeProfessionData:OnLanguageChange()
  self.lifeProfessionDatas = nil
  self.lifeProfessionExpDatas = nil
  self.lifeFormulaDatas = nil
end

function LifeProfessionData:GetProfessionDatas()
  if not self.lifeProfessionDatas then
    self.lifeProfessionDatas = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetDatas()
  end
  return self.lifeProfessionDatas
end

function LifeProfessionData:GetProfessionExpDatas()
  if not self.lifeProfessionExpDatas then
    self.lifeProfessionExpDatas = Z.TableMgr.GetTable("LifeExpTableMgr").GetDatas()
  end
  return self.lifeProfessionExpDatas
end

function LifeProfessionData:GetCurLVExp(proID, curLevel)
  local lifeProfessionExpDatas = self:GetProfessionExpDatas()
  for k, v in pairs(lifeProfessionExpDatas) do
    if v.ProId == proID and v.ProLevel == curLevel then
      if #v.Exp == 0 then
        return 0
      end
      return v.Exp[2]
    end
  end
  return 0
end

function LifeProfessionData:GetProfessionMaxLevel(proID)
  local maxLevel = 0
  local lifeProfessionExpDatas = self:GetProfessionExpDatas()
  for k, v in pairs(lifeProfessionExpDatas) do
    if v.ProId == proID then
      maxLevel = math.max(maxLevel, v.ProLevel)
    end
  end
  return maxLevel
end

function LifeProfessionData:GetRewardDatas(proID)
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(proID)
  if lifeProfessionTableRow == nil then
    return {}
  end
  local rewardDatas = {}
  for k, v in pairs(lifeProfessionTableRow.LevelAward) do
    local lifeAwardTargetTableRow = Z.TableMgr.GetTable("LifeAwardTargetTableMgr").GetRow(v)
    if lifeAwardTargetTableRow then
      table.insert(rewardDatas, lifeAwardTargetTableRow)
    end
  end
  return rewardDatas
end

function LifeProfessionData:GetSpeDatas()
  if not self.lifeFormulaDatas then
    self.lifeFormulaDatas = Z.TableMgr.GetTable("LifeFormulaTableMgr").GetDatas()
  end
  return self.lifeFormulaDatas
end

function LifeProfessionData:GetSpe2GroupTable(proID)
  local spe2GroupTable = {}
  local speDatas = self:GetSpeDatas()
  for k, v in pairs(speDatas) do
    if v.ProId == proID and not table.zcontains(spe2GroupTable, v.GroupId) and v.Level == 1 then
      spe2GroupTable[v.Id] = v.GroupId
    end
  end
  return spe2GroupTable
end

function LifeProfessionData:GetSpecializationRow(groupId, spcLevel)
  local speDatas = self:GetSpeDatas()
  for k, v in pairs(speDatas) do
    if v.GroupId == groupId and v.Level == spcLevel then
      return v
    end
  end
  return nil
end

function LifeProfessionData:GetSpecializationMaxLevel(proID, groupId)
  local maxLevel = 0
  local speDatas = self:GetSpeDatas()
  for k, v in pairs(speDatas) do
    if v.ProId == proID and v.GroupId == groupId then
      maxLevel = math.max(maxLevel, v.Level)
    end
  end
  return maxLevel
end

function LifeProfessionData:GetRedPointID(proID)
  local proBaseID = 1000000 + proID * 100
  local proRed = proBaseID + 1
  local proTabRed = proBaseID + 2
  local proRewardRed = proBaseID + 3
  local proSpecRed = proBaseID + 4
  return proRed, proTabRed, proRewardRed, proSpecRed
end

function LifeProfessionData:SetRecipeLockedData(proID, productID)
  if self.lockedRecipeTable == nil then
    self.lockedRecipeTable = {}
  end
  if self.lockedRecipeTable[proID] == nil then
    self.lockedRecipeTable[proID] = {}
  end
  self.lockedRecipeTable[proID][productID] = true
end

function LifeProfessionData:SetRecipeUnLockedData(proID, productID)
  if self.lockedRecipeTable[proID] and self.lockedRecipeTable[proID][productID] then
    self.lockedRecipeTable[proID][productID] = false
  end
end

function LifeProfessionData:GetRecipeLockedData()
  return self.lockedRecipeTable
end

function LifeProfessionData:SetIsSimpleList(isOn)
  self.isShowSimpleList = isOn
end

function LifeProfessionData:GetIsSimpleList()
  if self.isShowSimpleList == nil then
    self.isShowSimpleList = true
  end
  return self.isShowSimpleList
end

function LifeProfessionData:SetFilterSceneDatas(proID, sceneFilterDatas)
  local result = {}
  for k, v in pairs(sceneFilterDatas) do
    local sceneData = {}
    sceneData.sceneID = v.sceneID
    sceneData.isOn = v.isOn
    table.insert(result, sceneData)
  end
  self.filterSceneTable[proID] = result
end

function LifeProfessionData:GetFilterSceneDatas(proID)
  if self.filterSceneTable == nil then
    self:initAllFilterSceneDatas()
  end
  local result = {}
  if not table.zcontainsKey(self.filterSceneTable, proID) then
    return result
  end
  for k, v in pairs(self.filterSceneTable[proID]) do
    local sceneData = {}
    sceneData.sceneID = v.sceneID
    sceneData.isOn = v.isOn
    table.insert(result, sceneData)
  end
  return result
end

function LifeProfessionData:initAllFilterSceneDatas()
  self.filterSceneTable = {}
  local collectionDatas = self.lifeCollectionData:GetCollectionDatas()
  for k, v in pairs(collectionDatas) do
    local proID = v.LifeProId
    if not table.zcontainsKey(self.filterSceneTable, proID) then
      self.filterSceneTable[proID] = {}
    end
    local sceneFilterData = {}
    sceneFilterData.sceneID = v.Scene
    sceneFilterData.isOn = true
    self:addNewSceneData(self.filterSceneTable[proID], sceneFilterData)
  end
end

function LifeProfessionData:addNewSceneData(sceneFilterTable, sceneFilterData)
  for i = 1, #sceneFilterTable do
    if sceneFilterTable[i].sceneID == sceneFilterData.sceneID then
      return
    end
  end
  table.insert(sceneFilterTable, sceneFilterData)
end

function LifeProfessionData:SetFilterLevel(proID, minLevel, maxLevel)
  if not table.zcontainsKey(self.filterLevelTable, proID) then
    return
  end
  self.filterLevelTable[proID].min = minLevel
  self.filterLevelTable[proID].max = maxLevel
end

function LifeProfessionData:GetFilterLevel(proID)
  if self.filterLevelTable == nil then
    self:initAllFilterLevelDatas()
  end
  if not table.zcontainsKey(self.filterLevelTable, proID) then
    return 1, 1
  end
  return self.filterLevelTable[proID].min, self.filterLevelTable[proID].max
end

function LifeProfessionData:initAllFilterLevelDatas()
  self.filterLevelTable = {}
  local lifeProfessionExpDatas = self:GetProfessionExpDatas()
  for k, v in pairs(lifeProfessionExpDatas) do
    local proID = v.ProId
    if not table.zcontainsKey(self.filterLevelTable, proID) then
      local levelFilterData = {}
      levelFilterData.min = 1
      levelFilterData.max = self:GetProfessionMaxLevel(proID)
      self.filterLevelTable[proID] = levelFilterData
    end
  end
end

function LifeProfessionData:SetFilterConsume(proID, filterConsume, filterNoConsume)
  if not self.filterConsumeTable then
    self.filterConsumeTable = {}
  end
  self.filterConsumeTable[proID] = {}
  self.filterConsumeTable[proID].filterConsume = filterConsume
  self.filterConsumeTable[proID].filterNoConsume = filterNoConsume
end

function LifeProfessionData:GetFilterConsume(proID)
  if not self.filterConsumeTable then
    return true, true
  end
  if not table.zcontainsKey(self.filterConsumeTable, proID) then
    return true, true
  end
  return self.filterConsumeTable[proID].filterConsume, self.filterConsumeTable[proID].filterNoConsume
end

function LifeProfessionData:SetFilterTypeDatas(proID, sceneTypeDatas)
  local result = {}
  for k, v in pairs(sceneTypeDatas) do
    local sceneData = {}
    sceneData.type = v.type
    sceneData.isOn = v.isOn
    table.insert(result, sceneData)
  end
  self.filterTypeTable[proID] = result
end

function LifeProfessionData:GetFilterTypeDatas(proID)
  if self.filterTypeTable == nil then
    self:initAllFilterTypeDatas()
  end
  local result = {}
  if not table.zcontainsKey(self.filterTypeTable, proID) then
    return result
  end
  for k, v in pairs(self.filterTypeTable[proID]) do
    if v.type ~= 0 then
      local sceneTypeData = {}
      sceneTypeData.type = v.type
      sceneTypeData.isOn = v.isOn
      table.insert(result, sceneTypeData)
    end
  end
  return result
end

function LifeProfessionData:initAllFilterTypeDatas()
  self.filterTypeTable = {}
  local productionDatas = self.lifeMenufactorData_:GetProductionDatas()
  for k, v in pairs(productionDatas) do
    local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(v.productId)
    local proID = lifeProductionListTableRow.LifeProId
    if not table.zcontainsKey(self.filterTypeTable, proID) then
      self.filterTypeTable[proID] = {}
    end
    local sceneTypeData = {}
    sceneTypeData.type = lifeProductionListTableRow.Type
    sceneTypeData.isOn = true
    self:addNewTypeData(self.filterTypeTable[proID], sceneTypeData)
  end
end

function LifeProfessionData:addNewTypeData(typeFilterTable, sceneTypeData)
  for i = 1, #typeFilterTable do
    if typeFilterTable[i].type == sceneTypeData.type then
      return
    end
  end
  table.insert(typeFilterTable, sceneTypeData)
end

function LifeProfessionData:SetFilterConditionDatas(proID, levelCondition, speCondition, otherCondition)
  if not self.filterConditionTable then
    self.filterConditionTable = {}
  end
  self.filterConditionTable[proID] = {}
  self.filterConditionTable[proID].levelCondition = levelCondition
  self.filterConditionTable[proID].speCondition = speCondition
  self.filterConditionTable[proID].otherCondition = otherCondition
end

function LifeProfessionData:GetFilterConditionDatas(proID)
  if self.filterConditionTable == nil then
    return true, true, true
  end
  if not table.zcontainsKey(self.filterConditionTable, proID) then
    return true, true, true
  end
  return self.filterConditionTable[proID].levelCondition, self.filterConditionTable[proID].speCondition, self.filterConditionTable[proID].otherCondition
end

function LifeProfessionData:ClearFilterName()
  if not self.filterNameTable then
    return
  end
  for k, v in pairs(self.filterNameTable) do
    self.filterNameTable[k] = ""
  end
end

function LifeProfessionData:SetFilterName(proId, text)
  if not self.filterNameTable then
    self.filterNameTable = {}
  end
  self.filterNameTable[proId] = text
end

function LifeProfessionData:GetFilterName(proID)
  if not self.filterNameTable then
    return nil
  end
  if not table.zcontainsKey(self.filterNameTable, proID) then
    return nil
  end
  return self.filterNameTable[proID]
end

function LifeProfessionData:HasFilterChanged(proID)
  local sceneFilterDatas = self:GetFilterSceneDatas(proID)
  for k, v in pairs(sceneFilterDatas) do
    if not v.isOn then
      return true
    end
  end
  local sceneTypeDatas = self:GetFilterTypeDatas(proID)
  for k, v in pairs(sceneTypeDatas) do
    if not v.isOn then
      return true
    end
  end
  local filterConsume, filterNoConsume = self:GetFilterConsume(proID)
  if not filterConsume or not filterNoConsume then
    return true
  end
  local levelCondition, speCondition, otherCondition = self:GetFilterConditionDatas(proID)
  if not (levelCondition and speCondition) or not otherCondition then
    return true
  end
  local minLevel, maxLevel = self:GetFilterLevel(proID)
  local maxDefaultLevel = self:GetProfessionMaxLevel(proID)
  if maxDefaultLevel == 0 then
    maxDefaultLevel = 1
  end
  return maxLevel ~= maxDefaultLevel or minLevel ~= 1
end

function LifeProfessionData:ClearFilterDatas()
  self.filterTypeTable = nil
  self.filterSceneTable = nil
  self.filterConsumeTable = nil
  self.filterConditionTable = nil
  self.filterLevelTable = nil
  self.filterNameTable = nil
end

return LifeProfessionData
