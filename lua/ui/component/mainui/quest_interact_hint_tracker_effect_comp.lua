local QuestInteractHintTrackerEffectComp = class("QuestInteractHintTrackerEffectComp")

function QuestInteractHintTrackerEffectComp:ctor()
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.interactionVM_ = Z.VMMgr.GetVM("interaction")
  self.isEffectActive_ = false
  self.cachedTrackDataList_ = nil
end

function QuestInteractHintTrackerEffectComp:Init(uiEffectComp, questId)
  self.uiEffectComp_ = uiEffectComp
  if self.uiEffectComp_ then
    self.uiEffectComp_:StopEffect()
  end
  self:SetQuestId(questId)
  self:bindEvents()
end

function QuestInteractHintTrackerEffectComp:UnInit()
  self:unbindEvents()
  self.uiEffectComp_ = nil
  self.questId_ = nil
  self.cachedTrackDataList_ = nil
  self.isEffectActive_ = false
end

function QuestInteractHintTrackerEffectComp:bindEvents()
  self:unbindEvents()
  Z.EventMgr:Add(Z.ConstValue.RefreshOption, self.refreshEffect, self)
  Z.EventMgr:Add(Z.ConstValue.DeActiveOption, self.refreshEffect, self)
end

function QuestInteractHintTrackerEffectComp:unbindEvents()
  Z.EventMgr:RemoveObjAll(self)
end

function QuestInteractHintTrackerEffectComp:SetQuestId(questId)
  self.questId_ = questId
  self.cachedTrackDataList_ = self:collectTrackData(questId)
  self:refreshEffect()
end

function QuestInteractHintTrackerEffectComp:refreshEffect()
  if not self.uiEffectComp_ or not self.questId_ then
    return
  end
  local trackQuestId = self.questData_:GetQuestTrackingId()
  if self.questId_ ~= trackQuestId then
    self:stopEffectIfNeeded()
    return
  end
  local trackList = self.cachedTrackDataList_ or {}
  local currentSceneId = Z.StageMgr:GetCurrentSceneId()
  for _, trackData in ipairs(trackList) do
    if trackData.SceneId == currentSceneId then
      local hasInteraction = self.interactionVM_.CheckHasInterationDataByUidAndEntType(trackData.EntUid, trackData.EntType)
      if hasInteraction then
        self:startEffectIfNeeded()
        return
      end
    end
  end
  self:stopEffectIfNeeded()
end

function QuestInteractHintTrackerEffectComp:collectTrackData(questId)
  local questStepRow = self.questData_:GetStepConfigByQuestId(questId)
  if not questStepRow or not questStepRow.StepParam then
    return {}
  end
  local trackList = {}
  for index, goalParamList in ipairs(questStepRow.StepParam) do
    local goalType = tonumber(goalParamList[1])
    if self:isGoalTypeValid(goalType) then
      local goalPosData = questStepRow.StepTargetPos[index]
      local toSceneId = tonumber(goalParamList[3])
      if goalPosData then
        local trackData = {
          SceneId = toSceneId,
          EntType = goalPosData[1],
          EntUid = tonumber(goalPosData[2]) or 0
        }
        if trackData.EntUid > 0 then
          table.insert(trackList, trackData)
        end
      end
    end
  end
  return trackList
end

function QuestInteractHintTrackerEffectComp:isGoalTypeValid(goalType)
  return goalType == E.GoalType.NpcFlowTalk or goalType == E.GoalType.SubmitItem or goalType == E.GoalType.ShowItem or goalType == E.GoalType.FinishOperate
end

function QuestInteractHintTrackerEffectComp:startEffectIfNeeded()
  if not self.isEffectActive_ then
    self.isEffectActive_ = true
  end
end

function QuestInteractHintTrackerEffectComp:stopEffectIfNeeded()
  if self.isEffectActive_ then
    self.isEffectActive_ = false
    if self.uiEffectComp_ then
    end
  end
end

return QuestInteractHintTrackerEffectComp
