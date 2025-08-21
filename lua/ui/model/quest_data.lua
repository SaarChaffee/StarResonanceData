local QuestStepClass = require("goal.quest.quest_step")
local super = require("ui.model.data_base")
local QuestStepConfig = require("goal.quest.quest_step_config")
local QuestData = class("QuestData", super)

function QuestData:ctor()
  super.ctor(self)
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  if not questTbl then
    return
  end
  self:Clear()
end

function QuestData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.canAcceptQuestByQuestId_ = {}
  local rows = Z.TableMgr.GetTable("QuestTableMgr").GetDatas()
  local flowType = Z.PbEnum("EQuestAcceptType", "QuestAcceptTypeFlow")
  self.QuestGroupTypeInfos = nil
  for _, row in pairs(rows) do
    local acceptParams = row.AccpetType
    if acceptParams[1] == flowType then
      local info = {
        sceneId = acceptParams[2],
        npcId = acceptParams[3],
        flowId = acceptParams[4],
        portId = acceptParams[5],
        questId = row.QuestId
      }
      self.canAcceptQuestByQuestId_[row.QuestId] = info
    end
  end
end

function QuestData:UnInit()
  if self.CancelSource then
    self.CancelSource:Recycle()
    self.CancelSource = nil
  end
  self.canAcceptQuestByQuestId_ = {}
end

function QuestData:Clear()
  self.QuestGroupTypeInfos = nil
  self.IsLoginFinish = false
  self.QuestMgrStage = E.QuestMgrStage.UnInitEnd
  self.IsAutoTrackMainQuest = true
  self.IsShowGuideEffect = true
  self.FlowBlackMaskArgsDict = {}
  self.CutsceneBlackMaskArgsDict = {}
  self.LastTrackingId = 0
  self.GMSelectQuestId = 0
  self.loadedQuestSet_ = {}
  self.stepConfigCache_ = {}
  self.npcHudQuestDict_ = {}
  self.sceneTpLimitDict_ = {}
  self.questItemDict_ = {}
  self.selectTrackId_ = 0
  self.forceTrackId_ = 0
  self.trackOptionalIdList_ = {0, 0}
  self.followTrackQuest_ = 0
  self.goalTrackDataDict_ = {}
  self.questTimeLimitMessageIdDict_ = {}
  self.needRevertQuestStepDict_ = {}
  if self.guideGoalEffectIdDict_ then
    self:ClearGoalEffect()
  end
  self.guideGoalEffectIdDict_ = {}
  if self.stepDict_ then
    self:ClearAllQuestStep()
  end
  self.stepDict_ = {}
end

function QuestData:GetQuestByQuestId(id)
  if self.loadedQuestSet_[id] then
    return Z.ContainerMgr.CharSerialize.questList.questMap[id]
  end
end

function QuestData:GetAllQuestDict()
  local ret = {}
  for questId, quest in pairs(Z.ContainerMgr.CharSerialize.questList.questMap) do
    if self.loadedQuestSet_[questId] then
      ret[questId] = quest
    end
  end
  return ret
end

function QuestData:GetStepConfigByQuestId(questId)
  local quest = self:GetQuestByQuestId(questId)
  if not quest then
    return nil
  end
  local stepId = quest.stepId
  if stepId == nil or stepId == 0 then
    return nil
  end
  return self:GetStepConfigByStepId(stepId)
end

function QuestData:GetStepConfigByStepId(stepId)
  local questId = stepId // 1000
  if self.stepConfigCache_[questId] and self.stepConfigCache_[questId][stepId] then
    return self.stepConfigCache_[questId][stepId]
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if not questRow then
    logError("{0} \230\156\137\232\191\153\228\187\187\229\138\161\233\133\141\231\189\174\239\188\159", questId)
    return nil
  end
  if questRow.StepFlowPath == "" then
    logError("{0} \232\191\153\228\187\187\229\138\161\233\133\141\231\189\174\228\184\141\229\175\185\229\144\167\239\188\140\228\187\150\230\181\129\229\155\190\229\145\162\239\188\159\239\188\159\239\188\159", questId)
    return nil
  end
  local stepNode = Z.QuestFlowMgr:GetStepNode(questId, stepId)
  if not stepNode or not stepNode.stepRes then
    logError("{0}-{1} \230\178\161\230\156\137\232\191\153\228\184\170\230\181\129\229\155\190\232\138\130\231\130\185\229\149\138\239\188\159", questId, stepId)
    return nil
  end
  local config = QuestStepConfig.new(stepNode.stepRes, questId)
  if not self.stepConfigCache_[questId] then
    self.stepConfigCache_[questId] = {}
  end
  self.stepConfigCache_[questId][stepId] = config
  return config
end

function QuestData:GetAcceptConfigByQuestId(questId)
  return self.canAcceptQuestByQuestId_[questId]
end

function QuestData:IsCanAcceptQuest(questId)
  return self:GetAcceptConfigByQuestId(questId) ~= nil and Z.ContainerMgr.CharSerialize.questList.acceptQuestMap[questId] == true
end

function QuestData:IsAllQuestLoaded()
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  for questId, _ in pairs(Z.ContainerMgr.CharSerialize.questList.questMap) do
    local row = questTbl.GetRow(questId)
    if row and not self:IsQuestLoaded(questId) then
      return false
    end
  end
  return true
end

function QuestData:IsQuestLoaded(questId)
  if self.loadedQuestSet_[questId] then
    return true
  end
  return false
end

function QuestData:AddLoadedQuest(questId)
  self.loadedQuestSet_[questId] = true
end

function QuestData:RemoveLoadedQuest(questId)
  self.stepConfigCache_[questId] = nil
  Z.QuestFlowMgr:EndFlow(questId)
  self.loadedQuestSet_[questId] = nil
end

function QuestData:ClearLoadedQuest()
  self:ClearStepConfigCache()
  for questId, _ in pairs(self.loadedQuestSet_) do
    Z.QuestFlowMgr:EndFlow(questId)
  end
  self.loadedQuestSet_ = {}
end

function QuestData:ClearStepConfigCache()
  self.stepConfigCache_ = {}
end

function QuestData:GetQuestStep(questId)
  return self.stepDict_[questId]
end

function QuestData:SetQuestStep(questId, stepId)
  local lastStep = self.stepDict_[questId]
  if lastStep then
    lastStep:StepUnInit()
  end
  if stepId then
    local step = QuestStepClass.new(questId, stepId)
    step:StepInit()
    self.stepDict_[questId] = step
  else
    self.stepDict_[questId] = nil
  end
end

function QuestData:ClearAllQuestStep()
  for _, step in pairs(self.stepDict_) do
    step:StepUnInit()
  end
  self.stepDict_ = {}
end

function QuestData:AddNeedRevertQuestStepId(questId, stepId)
  if not self.needRevertQuestStepDict_[questId] then
    self.needRevertQuestStepDict_[questId] = {}
  end
  if not table.zcontains(self.needRevertQuestStepDict_[questId], stepId) then
    table.insert(self.needRevertQuestStepDict_[questId], stepId)
  end
end

function QuestData:RemoveNeedRevertQuestStepIds(questId)
  if self.needRevertQuestStepDict_[questId] then
    self.needRevertQuestStepDict_[questId] = nil
  end
end

function QuestData:ClearNeedRevertQuestStepIds()
  self.needRevertQuestStepDict_ = {}
end

function QuestData:GetNeedRevertQuestStepIds(questId)
  return self.needRevertQuestStepDict_[questId]
end

function QuestData:GetQuestTrackingId()
  if self.QuestMgrStage < E.QuestMgrStage.LoadEnd then
    return 0
  end
  if 0 < self.forceTrackId_ then
    return self.forceTrackId_
  end
  if 0 < self.followTrackQuest_ then
    return 0
  end
  if 0 < self.selectTrackId_ then
    return self.selectTrackId_
  end
  return self.trackOptionalIdList_[1]
end

function QuestData:GetSelectTrackId()
  return self.selectTrackId_
end

function QuestData:SetSelectTrackId(questId)
  self.selectTrackId_ = questId
  if Z.ContainerMgr.CharSerialize.questList.trackingId ~= questId then
    Z.CoroUtil.create_coro_xpcall(function()
      local worldProxy = require("zproxy.world_proxy")
      worldProxy.SetQuestTrackingId(questId)
    end)()
  end
end

function QuestData:GetForceTrackId()
  return self.forceTrackId_
end

function QuestData:SetForceTrackId(questId)
  self.forceTrackId_ = questId
end

function QuestData:GetTrackOptionalIdByIndex(index)
  return self.trackOptionalIdList_[index]
end

function QuestData:SetTrackOptionalId(index, questId)
  if index ~= 1 and index ~= 2 then
    return
  end
  self.trackOptionalIdList_[index] = questId or 0
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.TrackOptionChange, index, questId)
end

function QuestData:IsInForceTrack()
  if self.QuestMgrStage < E.QuestMgrStage.LoadEnd then
    return false
  end
  return self.forceTrackId_ > 0
end

function QuestData:IsShowInTrackBar(questId)
  if questId <= 0 then
    return false
  end
  if self.QuestMgrStage < E.QuestMgrStage.LoadEnd then
    return false
  end
  if self:IsInForceTrack() then
    return self.forceTrackId_ == questId
  else
    for _, optionalId in ipairs(self.trackOptionalIdList_) do
      if optionalId == questId then
        return true
      end
    end
    return false
  end
end

function QuestData:GetFollowTrackQuest()
  return self.followTrackQuest_
end

function QuestData:SetFollowTrackQuest(questId)
  self.followTrackQuest_ = questId
end

function QuestData:SetGoalTrackData(stepId, data)
  if not data then
    self.goalTrackDataDict_[stepId] = nil
    return
  end
  if not self.goalTrackDataDict_[stepId] then
    self.goalTrackDataDict_[stepId] = {}
  end
  self.goalTrackDataDict_[stepId][data.goalIndex] = data
end

function QuestData:GetGoalTrackData(stepId, goalIdx)
  if self.goalTrackDataDict_[stepId] then
    return self.goalTrackDataDict_[stepId][goalIdx]
  end
end

function QuestData:ClearGoalTrackData()
  self.goalTrackDataDict_ = {}
end

function QuestData:GetNpcHudQuestSet(npcId)
  return self.npcHudQuestDict_[npcId]
end

function QuestData:GetAllNpcWithHudQuest()
  return table.zkeys(self.npcHudQuestDict_)
end

function QuestData:AddNpcHudQuest(npcId, questId)
  if not self.npcHudQuestDict_[npcId] then
    self.npcHudQuestDict_[npcId] = {}
  end
  self.npcHudQuestDict_[npcId][questId] = true
end

function QuestData:RemoveNpcHudQuest(npcId, questId)
  if self.npcHudQuestDict_[npcId] then
    self.npcHudQuestDict_[npcId][questId] = nil
  end
end

function QuestData:ClearNpcHudQuest()
  self.npcHudQuestDict_ = {}
end

function QuestData:GetQuestOrder(questId)
  if self:GetSelectTrackId() == questId then
    return 0
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow then
    local typeRow = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questRow.QuestType)
    if typeRow then
      return typeRow.order
    end
  end
  return 0
end

function QuestData:GetGoalEffectDict()
  return self.guideGoalEffectIdDict_
end

function QuestData:SetGoalEffectUid(zoneUid, effectId)
  self.guideGoalEffectIdDict_[zoneUid] = effectId
end

function QuestData:ClearGoalEffect()
  for _, effectId in pairs(self.guideGoalEffectIdDict_) do
    Z.GoalGuideMgr:ClearGuideEffect(effectId)
  end
  self.guideGoalEffectIdDict_ = {}
end

function QuestData:GetTpLimitQuestSetBySceneId(sceneId)
  return self.sceneTpLimitDict_[sceneId] or {}
end

function QuestData:AddTpLimitQuest(questId, sceneId)
  if not self.sceneTpLimitDict_[sceneId] then
    self.sceneTpLimitDict_[sceneId] = {}
  end
  self.sceneTpLimitDict_[sceneId][questId] = true
end

function QuestData:DelTpLimitQuest(questId, sceneId)
  if sceneId then
    if self.sceneTpLimitDict_[sceneId] then
      self.sceneTpLimitDict_[sceneId][questId] = nil
    end
  else
    for _, questSet in pairs(self.sceneTpLimitDict_) do
      for k, _ in pairs(questSet) do
        if k == questId then
          questSet[k] = nil
        end
      end
    end
  end
end

function QuestData:GetItemConfigIdByQuestId(questId)
  local id = self.questItemDict_[questId] or 0
  return id
end

function QuestData:SetQuestItem(questId, itemConfigId)
  self.questItemDict_[questId] = itemConfigId
end

function QuestData:IsQuestAccessNotEnough(quest)
  if quest and quest.state == E.QuestState.NotEnough then
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(quest.id)
    if #questRow.ContinueLimit > 0 then
      local limitData = questRow.ContinueLimit[1]
      if tonumber(limitData[1]) == Z.PbEnum("EAccessType", "AccessEnterZone") then
        return true
      end
    end
  end
  return false
end

function QuestData:IsForceTrackQuest(questId)
  local isForce = false
  if 0 < questId then
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
    if questRow then
      local typeRow = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questRow.QuestType)
      if typeRow then
        isForce = typeRow.ForcedTracking
      end
    end
  end
  return isForce
end

function QuestData:SetQuestTimeLimitMessageId(questId, failMessageId, succeedMessageId)
  self.questTimeLimitMessageIdDict_[questId] = {failMessageId = failMessageId, succeedMessageId = succeedMessageId}
end

function QuestData:GetQuestTimeLimitMessageId(questId)
  return self.questTimeLimitMessageIdDict_[questId]
end

function QuestData:GetQuestTypeGroupInfos()
  return self.QuestGroupTypeInfos
end

function QuestData:SetQuestTypeGroupInfos(value)
  self.QuestGroupTypeInfos = value
end

return QuestData
