local super = require("ui.component.goal.goal_comp_base")
local QuestGoalComp = class("QuestGoalComp", super)
local targetTypeEnum = {
  TargetNpcTalk = Z.PbEnum("ETargetType", "TargetNpcTalk"),
  TargetKillMonster = Z.PbEnum("ETargetType", "TargetKillMonster")
}

function QuestGoalComp:ctor(parentView, index, uiType)
  super.ctor(self, parentView, index, uiType)
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.guideVM_ = Z.VMMgr.GetVM("goal_guide")
end

function QuestGoalComp:Init(uiBinder)
  self.questId_ = 0
  super.Init(self, uiBinder)
end

function QuestGoalComp:UnInit()
  super.UnInit(self)
  self.questId_ = nil
end

function QuestGoalComp:SetQuestId(questId)
  self.questId_ = questId
  self:refreshAll()
end

function QuestGoalComp:GetTargetViewWidth()
  return self.uiBinder_.Trans:GetSize().x
end

function QuestGoalComp:getGoalContentDesc()
  local configData = self.questVM_.GetCurGoalConfigData(self.questId_, self.index_)
  if configData then
    local replaceText = self:getTargetReplaceText(configData.ParamArray)
    return Z.Placeholder.Placeholder_task(configData.Content, replaceText)
  end
  return ""
end

function QuestGoalComp:getGoalGroupData()
  local quest = self.questData_:GetQuestByQuestId(self.questId_)
  if not quest then
    return
  end
  local stepRow = self.questData_:GetStepConfigByStepId(quest.stepId)
  if not stepRow then
    return
  end
  return {
    targetNumDict = quest.targetNum,
    targetMaxNumDict = quest.targetMaxNum,
    stepTargetType = stepRow.StepTargetType,
    stepTargetCondition = stepRow.StepTargetCondition
  }
end

function QuestGoalComp:getGoalPos()
  local quest = self.questData_:GetQuestByQuestId(self.questId_)
  if quest then
    local trackData = self.questData_:GetGoalTrackData(quest.stepId, self.index_)
    if trackData and trackData.toSceneId == Z.StageMgr.GetCurrentSceneId() then
      local pos = trackData.pos
      if trackData.posType ~= Z.GoalPosType.Point then
        local entType = Z.GoalGuideMgr.PosTypeToEntType(trackData.posType)
        local entity = Z.EntityMgr:GetLevelEntity(entType, trackData.uid)
        if entity then
          pos = entity:GetLocalAttrVirtualPos()
        end
      end
      return pos
    end
  end
end

function QuestGoalComp:getDescUIData()
  local isNeedGuide = false
  local toSceneId = 0
  local quest = self.questData_:GetQuestByQuestId(self.questId_)
  if quest then
    local trackData = self.questData_:GetGoalTrackData(quest.stepId, self.index_)
    if trackData then
      isNeedGuide = true
      toSceneId = trackData.toSceneId
    end
  end
  return {isNeedGuide = isNeedGuide, toSceneId = toSceneId}
end

function QuestGoalComp:refreshAll()
  super.refreshAll(self)
  if self.uiType_ == E.GoalUIType.TrackBar and self.index_ == 1 then
    Z.EventMgr:Dispatch(Z.ConstValue.Quest.TrackBarWidthChange, self.questId_)
  end
end

function QuestGoalComp:getGoalZoneUid()
  local quest = self.questData_:GetQuestByQuestId(self.questId_)
  if quest then
    local trackData = self.questData_:GetGoalTrackData(quest.stepId, self.index_)
    if trackData and trackData.posType == Z.GoalPosType.Zone and trackData.toSceneId == Z.StageMgr.GetCurrentSceneId() then
      return trackData.uid
    end
  end
  return 0
end

function QuestGoalComp:getIsInGoalVisualLayer()
  local quest = self.questData_:GetQuestByQuestId(self.questId_)
  if quest then
    local trackData = self.questData_:GetGoalTrackData(quest.stepId, self.index_)
    if trackData and trackData.toSceneId == Z.StageMgr.GetCurrentSceneId() then
      local levelTbl = self.guideVM_.GetLevelTableByPosType(trackData.posType)
      if levelTbl then
        local levelRow = levelTbl.GetRow(trackData.uid)
        if levelRow and levelRow.VisualLayerId then
          return levelRow.VisualLayerId == Z.World.VisualLayer
        end
      end
    end
  end
  return true
end

function QuestGoalComp:getTargetReplaceText(singleStepParam)
  local index = self.index_
  local targetType = tonumber(singleStepParam[1])
  local replaceText = {}
  local quest = self.questData_:GetQuestByQuestId(self.questId_)
  if not quest then
    return replaceText
  end
  local targetNumDict = quest.targetNum
  local targetMaxNumDict = quest.targetMaxNum
  local paramIndex = 1
  if targetType == targetTypeEnum.TargetNpcTalk then
    for i = 5, #singleStepParam do
      local npcId = tonumber(singleStepParam[i])
      local npcData = Z.TableMgr.GetTable("NpcTableMgr").GetRow(npcId)
      if npcData then
        local npcName = npcData.Name
        replaceText["<npc" .. paramIndex .. ">"] = npcName
        paramIndex = paramIndex + 1
      end
    end
  elseif targetType == targetTypeEnum.TargetKillMonster then
    for i = 4, #singleStepParam do
      local monsterId = tonumber(singleStepParam[i])
      local monsterData = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(monsterId)
      if monsterData then
        local monsterName = monsterData.Name
        replaceText["<mon" .. paramIndex .. ">"] = monsterName
        paramIndex = paramIndex + 1
      end
    end
  end
  replaceText["<num1>"] = (targetNumDict[index - 1] or 0) .. "/" .. (targetMaxNumDict[index - 1] or 0)
  return replaceText
end

return QuestGoalComp
