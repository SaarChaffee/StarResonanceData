local QuestVM = {}
local questData = Z.DataMgr.Get("quest_data")
local questTalkVM = Z.VMMgr.GetVM("quest_talk")
local questGoalVM = Z.VMMgr.GetVM("quest_goal")
local questTimeLimitVM = Z.VMMgr.GetVM("quest_time_limit")
local questTrackVM = Z.VMMgr.GetVM("quest_track")

function QuestVM.UpdateQuestDataOnEnterScene(sceneId)
  if sceneId == 1 then
    questData.IsLoginFinish = false
    return
  end
  logGreen("[quest] updateQuestDataOnEnterScene sceneId = {0}", sceneId)
  local finishIdList = {}
  local finishQuest = Z.ContainerMgr.CharSerialize.questList.finishQuest
  for questId, _ in pairs(finishQuest) do
    table.insert(finishIdList, questId)
  end
  local questList = Z.ContainerMgr.CharSerialize.questList
  questList.Watcher:RegWatcher(QuestVM.OnQuestListChange)
  for questId, quest in pairs(questList.questMap) do
    quest.Watcher:RegWatcher(QuestVM.OnQuestChange)
    Z.QuestFlowMgr:StartFlow(questId)
  end
end

function QuestVM.ClearQuestDataOnLeaveScene()
  local questList = Z.ContainerMgr.CharSerialize.questList
  questList.Watcher:UnregWatcher(QuestVM.OnQuestListChange)
  for questId, quest in pairs(questList.questMap) do
    quest.Watcher:UnregWatcher(QuestVM.OnQuestChange)
  end
  questData.QuestMgrStage = E.QuestMgrStage.BeginUnInit
  questData:ClearAllQuestStep()
  questData:ClearGoalTrackData()
  questData:ClearNpcHudQuest()
  questData:ClearLoadedQuest()
  questData.QuestMgrStage = E.QuestMgrStage.UnInitEnd
  questTrackVM.OnLeaveScene()
  logGreen("[quest] clearQuestDataOnLeaveScene")
end

function QuestVM.OnQuestListChange(questList, dirtyKeys)
  local acceptQuestMap = dirtyKeys.acceptQuestMap or {}
  for questId, v in pairs(acceptQuestMap) do
    if v:IsNew() then
      logGreen("[quest] acceptQuestMap Add: questId = {0}", questId)
      QuestVM.AddCanAcceptQuest(questId)
    elseif v:IsDel() then
      logGreen("[quest] acceptQuestMap Remove: questId = {0}", questId)
      QuestVM.RemoveCanAcceptQuest(questId)
    end
  end
  local questMapDirty = dirtyKeys.questMap or {}
  for questId, v in pairs(questMapDirty) do
    if v:IsDel() then
      QuestVM.DelQuest(questId)
      logGreen("[quest] finishQuest Remove: questId = {0}", questId)
    end
  end
  if dirtyKeys.questMap then
    QuestVM.CheckIsAllQuestLoaded()
  end
end

function QuestVM.OnQuestChange(quest, dirtyKeys)
  if questData.QuestMgrStage < E.QuestMgrStage.LoadEnd or not questData:IsQuestLoaded(quest.id) then
    return
  end
  local stepDirty = dirtyKeys.stepId
  local questStateDirty = dirtyKeys.state
  QuestVM.onStepStateChange(quest, stepDirty, questStateDirty)
  if stepDirty then
    return
  end
  QuestVM.onGoalProgressChange(quest, dirtyKeys)
  if questTimeLimitVM.IsTimeLimitStepByStepId(quest.stepId) then
    QuestVM.HandleTimeLimitStep(quest, dirtyKeys)
  end
  if questData:IsShowInTrackBar(quest.id) then
    Z.EventMgr:Dispatch(Z.ConstValue.UpdateAllTargetView)
  end
end

function QuestVM.HandelQuestAccept(questIds)
  if not questIds then
    return
  end
  for _, questId in ipairs(questIds) do
    local quest = Z.ContainerMgr.CharSerialize.questList.questMap[questId]
    if quest then
      quest.Watcher:RegWatcher(QuestVM.OnQuestChange)
      questData:AddNeedRevertQuestStepId(questId, quest.stepId)
      Z.QuestFlowMgr:StartFlow(questId)
      local worldQuestVM = Z.VMMgr.GetVM("worldquest")
      worldQuestVM.HandleWorldQuestAccept(questId)
      local questTrackData = Z.DataMgr.Get("quest_track_data")
      if questTrackData:GetProactiveQuestId() == 0 then
        questTrackVM.SetProactiveByQuestId(questId)
      end
    else
      logError("[quest] add nil quest, questId = {0}", questId)
    end
  end
end

function QuestVM.OnQuestFlowLoaded(questId)
  questData:AddLoadedQuest(questId)
  if questData.QuestMgrStage < E.QuestMgrStage.LoadEnd then
    QuestVM.CheckIsAllQuestLoaded()
  else
    QuestVM.revertNewQuest(questId)
    QuestVM.UpdateStep(questId)
    questTrackVM.OnAcceptQuest(questId)
    if QuestVM.IsHiddenQuest(questId) then
      return
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Quest.Accept, questId)
    local quest = questData:GetQuestByQuestId(questId)
    Z.RedCacheContainer:GetQuestRed().CheckQuestRed(quest)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.QuestFlowLoaded, questId)
end

function QuestVM.revertNewQuest(questId)
  local needRevertStepIds = QuestVM.getNeedRevertQuestStepIds(questId)
  if needRevertStepIds == nil then
    return
  end
  if 0 < #needRevertStepIds then
    logGreen("[quest] revertNewQuest needRevertStepIds = {0}", table.zconcat(needRevertStepIds, ","))
    Z.QuestFlowMgr:RevertQuest(questId, needRevertStepIds)
  end
  questData:RemoveNeedRevertQuestStepIds(questId)
end

function QuestVM.getNeedRevertQuestStepIds(questId)
  local needRevertStepIds = questData:GetNeedRevertQuestStepIds(questId)
  local quest = questData:GetQuestByQuestId(questId)
  if not quest or needRevertStepIds == nil then
    return nil
  end
  local stepId = quest.stepId
  local ret = {}
  for _, value in ipairs(needRevertStepIds) do
    if value ~= stepId then
      table.insert(ret, value)
    end
  end
  return ret
end

function QuestVM.HandelQuestStepChange(questId, lastStepId, lastStepStatus, curStepId)
  local questData = Z.DataMgr.Get("quest_data")
  if not questData:IsQuestLoaded(questId) then
    questData:AddNeedRevertQuestStepId(questId, curStepId)
  end
  QuestVM.UpdateStep(questId, lastStepId, lastStepStatus)
end

function QuestVM.HandelQuestComplete(questId, bFinish)
  local step = questData:GetQuestStep(questId)
  if step then
    if bFinish then
      step:StepFinish()
    end
    questData:SetQuestStep(questId, nil)
  end
  Z.RedCacheContainer:GetQuestRed().CloseQuestRed(questId)
  questData:SetQuestItem(questId, nil)
  local talkData = Z.DataMgr.Get("talk_data")
  talkData:DelNpcChangedTalkFlowByQuestId(questId)
  if not bFinish then
    Z.QuestMgr:RemoveQuestDataByQuestId(questId)
  end
  if bFinish and not QuestVM.IsHiddenQuest(questId) then
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
    if questRow then
      if questRow.QuestType == E.QuestType.Main then
        questData.IsAutoTrackMainQuest = true
      elseif questRow.QuestType == E.QuestType.WorldQuest then
        local worldQuestVM = Z.VMMgr.GetVM("worldquest")
        worldQuestVM.WorldQuestEventFinish()
      end
      Z.EventMgr:Dispatch(Z.ConstValue.Quest.Finish, questId)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.NpcQuestIconChange, questId)
  questTrackVM.OnQuestEnd(questId, bFinish)
  questData:RemoveLoadedQuest(questId)
  Z.SDKReport.ReportMissionCompleted(questId)
end

function QuestVM.UpdateStep(questId, oldStepId, oldState)
  local quest = questData:GetQuestByQuestId(questId)
  if quest == nil then
    return
  end
  logGreen("[quest] step update : questId = {0}, stepId = {1}, state = {2}  oldState = {3}", questId, quest.stepId, quest.state, oldState)
  local oldStep = questData:GetQuestStep(questId)
  if oldStep then
    oldStep:StepFinish()
    questData:SetQuestStep(questId, nil)
  end
  questData:SetQuestStep(questId, quest.stepId)
  questTalkVM.UpdateNpcChangedTalkFlow(questId, quest.stepId)
  QuestVM.UpdateQuestItem(questId, quest.stepId)
  questGoalVM.HandleNpcFollowGoalByQuestId(questId)
  questGoalVM.HandleAutoGoalByStepId(quest.stepId)
  questGoalVM.HandleOpenInsightGoalByStepId(quest.stepId)
  if oldStepId then
    if questData:GetQuestTrackingId() == questId then
      local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
      questGoalGuideVm.UpdateSceneGuideGoal()
    end
    if not QuestVM.IsHiddenQuest(quest.id) then
      Z.EventMgr:Dispatch(Z.ConstValue.Quest.StepChange, quest.id, quest.stepId)
      Z.RedCacheContainer:GetQuestRed().CheckQuestRed(quest)
      Z.EventMgr:Dispatch(Z.ConstValue.UpdateAllTargetView)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.NpcQuestIconChange, questId)
  if QuestVM.IsQuestFinish() then
    return
  end
  local isCanProactive = questTrackVM.SetProactiveByQuestStepId(oldStepId)
  if questTimeLimitVM.IsTimeLimitStepByStepId(quest.stepId) or isCanProactive then
    questTrackVM.ReplaceAndTrackingQuest(questId)
    Z.EventMgr:Dispatch(Z.ConstValue.TimeLimitQuestAccept, questId)
  end
end

function QuestVM.onStepStateChange(quest, stepDirty, questStateDirty)
  if questStateDirty then
    local oldState = questStateDirty:GetLast()
    local newState = questStateDirty:Get()
    Z.RedCacheContainer:GetQuestRed().CheckQuestRed(quest)
    if not stepDirty then
      local step = questData:GetQuestStep(quest.id)
      if step then
        step:StepOnQuestStateChange(oldState, newState)
      end
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Quest.StateChange, quest.id, oldState, newState)
  end
end

function QuestVM.onGoalProgressChange(quest, dirtyKeys)
  local isGoalChange = false
  local targetNumDict = dirtyKeys.targetNum or {}
  for serverGoalIndex, v in pairs(targetNumDict) do
    local goalIndex = serverGoalIndex + 1
    local curCount = v:Get()
    local lastCount = v:GetLast() or 0
    if 0 < curCount - lastCount then
      if curCount == quest.targetMaxNum[serverGoalIndex] then
        isGoalChange = true
        local step = questData:GetQuestStep(quest.id)
        if step then
          step:SetGoalCompleted(goalIndex)
        end
      end
    elseif curCount == 0 and 0 < lastCount then
      isGoalChange = true
      local step = questData:GetQuestStep(quest.id)
      if step then
        step:ResetGoal(goalIndex)
      end
    end
  end
  if isGoalChange and quest.id == questData:GetQuestTrackingId() then
    local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
    questGoalGuideVm.UpdateSceneGuideGoal()
  end
end

function QuestVM.GetQuestNpcUidListByStepAndScene(questId, stepId, sceneId)
  local quest = questData:GetQuestByQuestId(questId)
  if quest and quest.state == E.QuestState.NotEnough then
    return {}
  end
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if not stepRow then
    return {}
  end
  local questGoalVM = Z.VMMgr.GetVM("quest_goal")
  local talkVM = Z.VMMgr.GetVM("talk")
  local stepParam = stepRow.StepParam
  local ret = {}
  for i = 1, #stepParam do
    local stepParamArray = stepParam[i]
    local toSceneId = tonumber(stepParamArray[3])
    local goalType = tonumber(stepParamArray[1])
    if sceneId == toSceneId then
      local checkType = talkVM.IsAddTalkGoal(goalType) or goalType == E.GoalType.FinishOperate
      if checkType and not questGoalVM.IsGoalCompleted(questId, i) then
        local posArray = (stepRow.StepTargetPos or {})[i]
        if posArray then
          local posType = Z.GoalPosType.IntToEnum(tonumber(posArray[1]))
          if posType == Z.GoalPosType.Npc then
            local uid = tonumber(posArray[2])
            table.insert(ret, uid)
          end
        end
      end
    end
  end
  return ret
end

function QuestVM.CompareQuestIdOrder(id1, id2)
  local trackingId = questData:GetQuestTrackingId()
  local aTrackWeight = trackingId == id1 and 1 or 0
  local bTrackWeight = trackingId == id2 and 1 or 0
  if aTrackWeight == bTrackWeight then
    local order1 = questData:GetQuestOrder(id1)
    local order2 = questData:GetQuestOrder(id2)
    if order1 == order2 then
      return id1 < id2
    else
      return order1 < order2
    end
  else
    return aTrackWeight > bTrackWeight
  end
end

function QuestVM.OnCanAcceptQuestChange(questId, npcId)
  local questIconVM = Z.VMMgr.GetVM("quest_icon")
  local stage = questData.QuestMgrStage
  if stage >= E.QuestMgrStage.InitEnd and stage < E.QuestMgrStage.BeginUnInit then
    questIconVM.UpdateNpcHudQuest(npcId)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.NpcQuestIconChange, questId)
end

function QuestVM.AddCanAcceptQuest(questId)
  local acceptConfig = questData:GetAcceptConfigByQuestId(questId)
  if not acceptConfig then
    return
  end
  questTalkVM.AddAcceptTalkDataByQuestId(questId)
  local npcId = acceptConfig.npcId
  questData:AddNpcHudQuest(npcId, questId)
  QuestVM.OnCanAcceptQuestChange(questId, npcId)
end

function QuestVM.RemoveCanAcceptQuest(questId)
  local acceptConfig = questData:GetAcceptConfigByQuestId(questId)
  if not acceptConfig then
    return
  end
  questTalkVM.RemoveAcceptTalkDataByQuestId(questId)
  local npcId = acceptConfig.npcId
  questData:RemoveNpcHudQuest(npcId, questId)
  QuestVM.OnCanAcceptQuestChange(questId, npcId)
end

function QuestVM.UpdateQuestItem(questId, stepId)
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if stepRow then
    for _, itemArray in ipairs(stepRow.QuestItems) do
      local isAdd = itemArray[1] == 1
      if isAdd then
        local itemId = itemArray[3]
        questData:SetQuestItem(questId, itemId)
      else
        questData:SetQuestItem(questId, nil)
      end
    end
  end
end

function QuestVM.RevertQuest(questId)
  questData:RemoveNeedRevertQuestStepIds(questId)
  local allQuestHistory = Z.ContainerMgr.CharSerialize.questList.historyMap
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local questHistory = allQuestHistory[questId]
  local quest = Z.ContainerMgr.CharSerialize.questList.questMap[questId]
  if questHistory and quest then
    local stepHistoryDict = questHistory.stepHistory
    local orderList = table.zkeys(stepHistoryDict)
    table.sort(orderList)
    local stepCount = table.zcount(orderList)
    local revertQuests = {}
    for i = 1, stepCount do
      local order = orderList[i]
      local stepId = stepHistoryDict[order]
      QuestVM.UpdateQuestItem(questId, stepId)
      questTalkVM.UpdateNpcChangedTalkFlow(questId, stepId)
      local questRow = questTbl.GetRow(questId)
      if questRow and questRow.StepFlowPath ~= "" and stepId ~= quest.stepId then
        table.insert(revertQuests, stepId)
      end
    end
    local revertQuestsCount = table.zcount(revertQuests)
    if 0 < revertQuestsCount then
      Z.QuestFlowMgr:RevertQuest(questId, revertQuests)
    end
  end
end

function QuestVM.CheckIsAllQuestLoaded()
  if questData.QuestMgrStage >= E.QuestMgrStage.LoadEnd then
    return
  end
  if not questData:IsAllQuestLoaded() then
    return
  end
  logGreen("[quest] current quest list is all loaded")
  questData.QuestMgrStage = E.QuestMgrStage.LoadEnd
  local questDict = questData:GetAllQuestDict()
  for questId, quest in pairs(questDict) do
    QuestVM.RevertQuest(questId)
    questData:SetQuestStep(questId, quest.stepId)
  end
  for questId, _ in pairs(Z.ContainerMgr.CharSerialize.questList.acceptQuestMap) do
    QuestVM.AddCanAcceptQuest(questId)
  end
  questData.QuestMgrStage = E.QuestMgrStage.InitEnd
  questTrackVM.OnEnterScene()
  questGoalVM.OnEnterScene()
  Z.RedCacheContainer:GetQuestRed().UpdateQuestRed()
  local questIconVM = Z.VMMgr.GetVM("quest_icon")
  questIconVM.UpdateAllNpcHudQuest()
  if not questData.IsLoginFinish then
    questData.IsLoginFinish = true
  end
end

function QuestVM.IsHiddenQuest(questId)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow then
    local typeRow = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questRow.QuestType)
    if typeRow and typeRow.ShowQuestUI then
      return false
    end
  end
  return true
end

function QuestVM.DelQuest(questId)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow and questRow.QuestType == E.QuestType.WorldQuest then
    local worldQuestVM = Z.VMMgr.GetVM("worldquest")
    worldQuestVM.WorldQuestEventRemove()
  end
end

function QuestVM.HandleTimeLimitStep(quest, dirtyKeys)
  local stepStatus = quest.stepStatus
  if stepStatus and quest.stepLimitTime ~= 0 then
    if (stepStatus == Z.PbEnum("EQuestStepStatus", "QuestStepFail") or stepStatus == Z.PbEnum("EQuestStepStatus", "QuestStepFinish")) and dirtyKeys.stepStatus then
      Z.EventMgr:Dispatch(Z.ConstValue.TimeLimitQuestEnd, quest.id)
    end
    if stepStatus == Z.PbEnum("EQuestStepStatus", "QuestStepGoing") then
      Z.AudioMgr:Play("sfx_questtimelimited_target")
      if dirtyKeys.stepLimitTime then
        Z.EventMgr:Dispatch(Z.ConstValue.Quest.StepLimitTimeChange, quest)
      end
    end
  end
end

function QuestVM.GetCurGoalConfigData(questId, goalIdx)
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if quest then
    local stepRow = questData:GetStepConfigByStepId(quest.stepId)
    if stepRow then
      local content = stepRow.StepTargetInfo[goalIdx]
      local param = stepRow.StepParam[goalIdx]
      if content and param then
        return {Content = content, ParamArray = param}
      end
    end
  end
end

function QuestVM.IsQuestFinish(questId)
  return Z.ContainerMgr.CharSerialize.questList.finishQuest[questId]
end

function QuestVM.IsQuestStepFinish(questId, stepId)
  if QuestVM.IsQuestFinish(questId) then
    return true
  end
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if quest and quest.stepId == stepId then
    return false
  end
  local history = Z.ContainerMgr.CharSerialize.questList.historyMap[questId]
  if history then
    for _, value in pairs(history.stepHistory) do
      if stepId == value then
        return true
      end
    end
  end
  return false
end

function QuestVM.GetPhotoQuestStepIds()
  local nowSceneId = Z.StageMgr.GetCurrentSceneId()
  local tab = {}
  for questId, quest in pairs(questData:GetAllQuestDict()) do
    local questStepCfgData = questData:GetStepConfigByStepId(quest.stepId)
    if questStepCfgData then
      for _, value in ipairs(questStepCfgData.StepParam) do
        local typeId = tonumber(value[1])
        local sceneId = tonumber(value[3])
        if nowSceneId == sceneId and typeId and typeId == E.GoalType.TargetEntityPhoto then
          table.insert(tab, {
            id = tonumber(value[6]),
            entityUid = tonumber(value[5]),
            entityType = tonumber(value[4])
          })
        end
      end
    end
  end
  return tab
end

function QuestVM.AsyncAcceptQuest(questId, cancelToken)
  cancelToken = cancelToken or questData.CancelSource:CreateToken()
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.AcceptQuest({questId = questId}, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end

function QuestVM.AsyncGiveUpQuest(questId, cancelToken)
  cancelToken = cancelToken or questData.CancelSource:CreateToken()
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GiveupQuest({questId = questId}, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end

function QuestVM.PlaceholderTaskContent(content, placeholderParam)
  placeholderParam = Z.Placeholder.SetItemName(placeholderParam)
  placeholderParam = Z.Placeholder.SetQuestName(placeholderParam)
  placeholderParam = Z.Placeholder.SetNpcName(placeholderParam)
  placeholderParam = Z.Placeholder.SetMonsterName(placeholderParam)
  placeholderParam = Z.Placeholder.SetCollectionName(placeholderParam)
  placeholderParam = Z.Placeholder.SetPlayerSelfPronoun(placeholderParam)
  local ret = Z.Placeholder.Placeholder(content, placeholderParam)
  return ret
end

function QuestVM.GetQuestName(questId)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow then
    local placeholderParam = Z.Placeholder.SetPlayerSelfPronoun()
    local ret = Z.Placeholder.Placeholder(questRow.QuestName, placeholderParam)
    return ret
  end
  return ""
end

return QuestVM
