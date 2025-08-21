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
  self.quest_ = nil
  self.stepRow_ = nil
end

function QuestGoalComp:SetQuestId(questId)
  self.questId_ = questId
  self:refreshGoalInfo()
  self:refreshAll()
end

function QuestGoalComp:refreshGoalInfo()
  local quest = self.questData_:GetQuestByQuestId(self.questId_)
  if not quest then
    return
  end
  local stepRow = self.questData_:GetStepConfigByStepId(quest.stepId)
  if not stepRow then
    return
  end
  self.quest_ = quest
  self.stepRow_ = stepRow
end

function QuestGoalComp:GetTargetViewWidth()
  return self.uiBinder_.Trans:GetSize().x
end

function QuestGoalComp:getGoalContentDesc()
  local configData = self.questVM_.GetCurGoalConfigData(self.questId_, self.index_)
  if configData then
    local content = configData.Content
    local num1 = (self.quest_.targetNum[self.index_ - 1] or 0) .. "/" .. (self.quest_.targetMaxNum[self.index_ - 1] or 0)
    local placeholderParam = {num1 = num1}
    content = self.questVM_.PlaceholderTaskContent(content, placeholderParam)
    return content
  end
  return ""
end

function QuestGoalComp:getGoalGroupData()
  if not self.quest_ or not self.stepRow_ then
    return
  end
  return {
    targetNumDict = self.quest_.targetNum,
    targetMaxNumDict = self.quest_.targetMaxNum,
    stepTargetType = self.stepRow_.StepTargetType,
    stepTargetCondition = self.stepRow_.StepTargetCondition
  }
end

function QuestGoalComp:isHideGoalDistanceLab()
  if not self.quest_ or not self.stepRow_ then
    return true
  end
  return self.stepRow_:IsHideTrackedDis(self.index_)
end

function QuestGoalComp:getGoalPos()
  if self.quest_ == nil then
    return
  end
  local trackData = self.questData_:GetGoalTrackData(self.quest_.stepId, self.index_)
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

return QuestGoalComp
