local LevelMapFlagHelper = class("LevelMapFlagHelper")
local baseSrcList = {
  E.LevelMapFlagSrc.Function,
  E.LevelMapFlagSrc.WorldQuest
}
local questSrcList = {
  E.LevelMapFlagSrc.QuestGoal,
  E.LevelMapFlagSrc.QuestNpc
}

function LevelMapFlagHelper:ctor(isBigMap)
  self.isBigMap_ = isBigMap
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self.sceneId_ = 0
  self.allFlagDict_ = {}
  self.mergedDict_ = {}
end

function LevelMapFlagHelper:ResetAll(sceneId)
  self.sceneId_ = sceneId
  self.allFlagDict_ = {}
  self.mergedDict_ = {}
  local levelDataList = self.mapVM_.LoadEntityTableData(sceneId)
  for _, flagData in ipairs(levelDataList) do
    self:addFlagData(E.LevelMapFlagSrc.Function, flagData)
  end
  local worldQuestDataList = self.mapVM_.LoadWorldQuestEntityFlagData(sceneId)
  for _, flagData in ipairs(worldQuestDataList) do
    self:addFlagData(E.LevelMapFlagSrc.WorldQuest, flagData)
  end
  local questGoalList = self.mapVM_.GetQuestGoalFlagDataBySceneId(sceneId, self.isBigMap_)
  for _, flagData in ipairs(questGoalList) do
    self:addFlagData(E.LevelMapFlagSrc.QuestGoal, flagData, flagData.QuestId)
  end
  local questNpcDict = self.mapVM_.GetQuestNpcFlagDataBySceneId(sceneId)
  for _, dataList in pairs(questNpcDict) do
    for _, flagData in ipairs(dataList) do
      self:addFlagData(E.LevelMapFlagSrc.QuestNpc, flagData, flagData.QuestId)
    end
  end
  self:refreshAllMergedFlagData()
end

function LevelMapFlagHelper:GetAllMergedFlagData()
  local dataList = {}
  for _, flagData in pairs(self.mergedDict_) do
    table.insert(dataList, flagData)
  end
  return dataList
end

function LevelMapFlagHelper:GetMergedFlagDataByFlagId(flagId)
  return self.mergedDict_[flagId]
end

function LevelMapFlagHelper:GetMergedFlagDataByPosTypeAndUid(posType, uid)
  if self.sceneId_ <= 0 then
    return
  end
  local _, flagId = self.mapVM_.GetGlobalInfo(self.sceneId_, posType, uid)
  if flagId then
    return self.mergedDict_[flagId]
  end
end

function LevelMapFlagHelper:GetMergedFlagDataByEntSubType(uid, entType, subType)
  for flagId, srcDict in pairs(self.allFlagDict_) do
    for _, dict in pairs(srcDict) do
      for _, flagData in pairs(dict) do
        if flagData.Uid == uid and flagData.Type == entType and flagData.SubType == subType then
          return self.mergedDict_[flagId]
        end
      end
    end
  end
end

function LevelMapFlagHelper:GetOriginFlagListByFlagId(flagId)
  local list = {}
  local srcDict = self.allFlagDict_[flagId]
  if srcDict then
    for _, dict in pairs(srcDict) do
      for _, flagData in pairs(dict) do
        table.insert(list, flagData)
      end
    end
  end
  return list
end

function LevelMapFlagHelper:ChangeFlagDataBySrc(changeSrc, srcId)
  if self.sceneId_ <= 0 then
    return {}
  end
  local changeIdSet = {}
  for flagId, srcDict in pairs(self.allFlagDict_) do
    if srcDict[changeSrc] then
      if not srcId then
        srcDict[changeSrc] = nil
        changeIdSet[flagId] = true
      elseif srcDict[changeSrc][srcId] then
        srcDict[changeSrc][srcId] = nil
        changeIdSet[flagId] = true
      end
    end
  end
  if changeSrc == E.LevelMapFlagSrc.Function then
    local levelDataList = self.mapVM_.LoadEntityTableData(self.sceneId_)
    for _, flagData in ipairs(levelDataList) do
      self:addFlagData(E.LevelMapFlagSrc.Function, flagData)
      changeIdSet[flagData.Id] = true
    end
  elseif changeSrc == E.LevelMapFlagSrc.WorldQuest then
    local worldQuestDataList = self.mapVM_.LoadWorldQuestEntityFlagData(self.sceneId_)
    for _, flagData in ipairs(worldQuestDataList) do
      self:addFlagData(E.LevelMapFlagSrc.WorldQuest, flagData)
      changeIdSet[flagData.Id] = true
    end
  elseif changeSrc == E.LevelMapFlagSrc.QuestGoal then
    local questGoalList = self.mapVM_.GetQuestGoalFlagDataBySceneId(self.sceneId_, self.isBigMap_)
    for _, flagData in ipairs(questGoalList) do
      self:addFlagData(E.LevelMapFlagSrc.QuestGoal, flagData, flagData.QuestId)
      changeIdSet[flagData.Id] = true
    end
  elseif changeSrc == E.LevelMapFlagSrc.QuestNpc then
    local questNpcDict = self.mapVM_.GetQuestNpcFlagDataBySceneId(self.sceneId_)
    for _, dataList in pairs(questNpcDict) do
      for _, flagData in ipairs(dataList) do
        self:addFlagData(E.LevelMapFlagSrc.QuestNpc, flagData, flagData.QuestId)
        changeIdSet[flagData.Id] = true
      end
    end
  end
  local changeDataList = {}
  for flagId, _ in pairs(changeIdSet) do
    local newData = self:getMergedFlagData(flagId)
    if newData then
      table.insert(changeDataList, newData)
    else
      table.insert(changeDataList, self.mergedDict_[flagId])
    end
    self.mergedDict_[flagId] = newData
  end
  return changeDataList
end

function LevelMapFlagHelper:refreshAllMergedFlagData()
  self.mergedDict_ = {}
  for flagId, _ in pairs(self.allFlagDict_) do
    local flagData = self:getMergedFlagData(flagId)
    if flagData then
      self.mergedDict_[flagId] = flagData
    end
  end
end

function LevelMapFlagHelper:getMergedFlagData(flagId)
  local baseFlag = self:getMergedBaseFlagData(flagId)
  local baseQuestId
  if baseFlag then
    baseQuestId = baseFlag.QuestId
  end
  local questFlags = self:getMergedQuestFlagDatas(flagId, baseQuestId)
  local ret
  if baseFlag and questFlags then
    ret = table.zclone(baseFlag)
    ret.RelationQuestFlags = questFlags
  elseif baseFlag then
    ret = baseFlag
  elseif questFlags and 0 < #questFlags then
    ret = table.zclone(questFlags[1])
    table.remove(questFlags, 1)
    if 0 < #questFlags then
      ret.RelationQuestFlags = questFlags
    end
  end
  return ret or nil
end

function LevelMapFlagHelper:getMergedBaseFlagData(flagId)
  local srcDict = self.allFlagDict_[flagId]
  if srcDict then
    for _, src in ipairs(baseSrcList) do
      local idDict = srcDict[src]
      if idDict and idDict[1] then
        return idDict[1]
      end
    end
  end
end

function LevelMapFlagHelper:getMergedQuestFlagDatas(flagId, baseQuestId)
  local srcDict = self.allFlagDict_[flagId]
  if srcDict then
    local questDict = {}
    for _, src in ipairs(questSrcList) do
      local idDict = srcDict[src]
      if idDict then
        for questId, flagData in pairs(idDict) do
          if questId ~= baseQuestId then
            questDict[questId] = flagData
          end
        end
      end
    end
    local idList = table.zkeys(questDict)
    local ret = {}
    if 0 < #idList then
      table.sort(idList, self.questVM_.CompareQuestIdOrder)
      for index, value in ipairs(idList) do
        table.insert(ret, questDict[value])
      end
    end
    return ret
  end
end

function LevelMapFlagHelper:addFlagData(src, flagData, srcId)
  srcId = srcId or 1
  local dict = self.allFlagDict_
  local flagId = flagData.Id
  if not dict[flagId] then
    dict[flagId] = {}
  end
  if not dict[flagId][src] then
    dict[flagId][src] = {}
  end
  dict[flagId][src][srcId] = flagData
end

return LevelMapFlagHelper
