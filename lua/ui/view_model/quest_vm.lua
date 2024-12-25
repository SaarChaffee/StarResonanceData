local questData = Z.DataMgr.Get("quest_data")
local questTalkVM = Z.VMMgr.GetVM("quest_talk")
local questGoalVM = Z.VMMgr.GetVM("quest_goal")
local questTimeLimitVM = Z.VMMgr.GetVM("quest_time_limit")
local questTrackVM = Z.VMMgr.GetVM("quest_track")
local isGoalCompleted = function(questId, goalIndex)
  local quest = Z.ContainerMgr.CharSerialize.questList.questMap[questId]
  if not quest then
    return false
  end
  local serverGoalIndex = goalIndex - 1
  if quest.targetNum[serverGoalIndex] and quest.targetMaxNum[serverGoalIndex] then
    return quest.targetNum[serverGoalIndex] == quest.targetMaxNum[serverGoalIndex]
  else
    return false
  end
end
local getUncompletedGoalIndex = function(questId)
  local quest = questData:GetQuestByQuestId(questId)
  if quest then
    local stepRow = questData:GetStepConfigByStepId(quest.stepId)
    if stepRow then
      for i = 1, #stepRow.StepParam do
        if not isGoalCompleted(quest.id, i) then
          return i
        end
      end
    end
  end
  return 0
end
local getQuestIconInScene = function(questId)
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local questRow = questTbl.GetRow(questId)
  if not questRow then
    return ""
  end
  local questType = questRow.QuestType
  local questTypeTbl = Z.TableMgr.GetTable("QuestTypeTableMgr")
  local questTypeRow = questTypeTbl.GetRow(questType)
  if not questTypeRow or not questTypeRow.ShowQuestUI then
    return ""
  end
  local questDetailVM = Z.VMMgr.GetVM("questdetail")
  if questData:IsCanAcceptQuest(questId) then
    return questDetailVM.GetStateIconByQuestId(questId)
  else
    local quest = questData:GetQuestByQuestId(questId)
    if quest and quest.state ~= E.QuestState.End and quest.state ~= E.QuestState.NotEnough then
      return questDetailVM.GetStateIconByQuestId(questId)
    else
      return ""
    end
  end
end
local getQuestNpcUidListByStepAndScene = function(questId, stepId, sceneId)
  local quest = questData:GetQuestByQuestId(questId)
  if quest and quest.state == E.QuestState.NotEnough then
    return {}
  end
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if not stepRow then
    return {}
  end
  local talkVM = Z.VMMgr.GetVM("talk")
  local stepParam = stepRow.StepParam
  local ret = {}
  for i = 1, #stepParam do
    local stepParamArray = stepParam[i]
    local toSceneId = tonumber(stepParamArray[3])
    local goalType = tonumber(stepParamArray[1])
    if sceneId == toSceneId then
      local checkType = talkVM.IsAddTalkGoal(goalType) or goalType == E.GoalType.FinishOperate
      if checkType and not isGoalCompleted(questId, i) then
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
local compareQuestIdOrder = function(id1, id2)
  local trackingId = questData:GetQuestTrackingId()
  if trackingId == id1 then
    return true
  end
  if trackingId == id2 then
    return false
  end
  local order1 = questData:GetQuestOrder(id1)
  local order2 = questData:GetQuestOrder(id2)
  if order1 ~= order2 then
    return order1 < order2
  end
  return id1 < id2
end
local updateNpcHudQuest = function(npcId)
  local idSet = questData:GetNpcHudQuestSet(npcId) or {}
  local trackingId = questData:GetQuestTrackingId()
  local hudQuest
  if 0 < trackingId and idSet[trackingId] then
    hudQuest = trackingId
  else
    local idList = {}
    for questId, _ in pairs(idSet) do
      table.insert(idList, questId)
    end
    table.sort(idList, compareQuestIdOrder)
    hudQuest = idList[1]
  end
  local iconPath = hudQuest and getQuestIconInScene(hudQuest) or ""
  Z.QuestMgr:SetNpcQuestIcon(npcId, iconPath)
end
local updateAllNpcHudQuest = function()
  local npcList = questData:GetAllNpcWithHudQuest()
  for _, npcId in ipairs(npcList) do
    updateNpcHudQuest(npcId)
  end
end
local isShowQuestRed = function(questId)
  if Z.LocalUserDataMgr.GetBool("BkrQuestRed" .. questId, false) then
    return true
  end
  return false
end
local getQuestRedCount = function()
  local count = 0
  local questDetailVM = Z.VMMgr.GetVM("questdetail")
  local typeGroupList = questDetailVM.GetQuestTypeGroupList()
  if 0 < #typeGroupList then
    for i = 1, #typeGroupList do
      if 0 < #typeGroupList[i].QuestIdList then
        for j = 1, #typeGroupList[i].QuestIdList do
          if isShowQuestRed(typeGroupList[i].QuestIdList[j]) then
            count = count + 1
          end
        end
      end
    end
  end
  return count
end
local updateQuestRed = function()
  local count = getQuestRedCount()
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.QuestList, count)
end
local closeQuestRed = function(questId)
  if isShowQuestRed(questId) then
    Z.LocalUserDataMgr.RemoveKey("BkrQuestRed" .. questId)
    updateQuestRed()
  end
end
local closeAllQuestRed = function()
  local count = getQuestRedCount()
  if count == 0 then
    return
  end
  local questDic = Z.ContainerMgr.CharSerialize.questList.questMap
  if questDic == nil then
    return
  end
  for questId, _ in pairs(questDic) do
    closeQuestRed(questId)
  end
end
local checkQuestRed = function(quest)
  local questId = quest.id
  if questData:IsShowInTrackBar(questId) then
    return
  end
  local state = quest.state
  if state == Z.PbEnum("EQuestStatusType", "QuestAccept") or state == Z.PbEnum("EQuestStatusType", "QuestFinish") then
    Z.LocalUserDataMgr.SetBool("BkrQuestRed" .. questId, true)
    updateQuestRed()
  else
    closeQuestRed(questId)
  end
end
local onCanAcceptQuestChange = function(questId, npcId)
  local stage = questData.QuestMgrStage
  if stage >= E.QuestMgrStage.InitEnd and stage < E.QuestMgrStage.BeginUnInit then
    updateNpcHudQuest(npcId)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.NpcQuestIconChange, questId)
end
local addCanAcceptQuest = function(questId)
  local acceptConfig = questData:GetAcceptConfigByQuestId(questId)
  if not acceptConfig then
    return
  end
  questTalkVM.AddAcceptTalkDataByQuestId(questId)
  local npcId = acceptConfig.npcId
  questData:AddNpcHudQuest(npcId, questId)
  onCanAcceptQuestChange(questId, npcId)
end
local removeCanAcceptQuest = function(questId)
  local acceptConfig = questData:GetAcceptConfigByQuestId(questId)
  if not acceptConfig then
    return
  end
  questTalkVM.RemoveAcceptTalkDataByQuestId(questId)
  local npcId = acceptConfig.npcId
  questData:RemoveNpcHudQuest(npcId, questId)
  onCanAcceptQuestChange(questId, npcId)
end
local updateQuestItem = function(questId, stepId)
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
local revertQuest = function(questId)
  local allQuestHistory = Z.ContainerMgr.CharSerialize.questList.historyMap
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local questHistory = allQuestHistory[questId]
  if questHistory then
    local stepHistoryDict = questHistory.stepHistory
    local orderList = table.zkeys(stepHistoryDict)
    table.sort(orderList)
    local stepCount = table.zcount(orderList)
    for i = 1, stepCount do
      local order = orderList[i]
      local stepId = stepHistoryDict[order]
      updateQuestItem(questId, stepId)
      questTalkVM.UpdateNpcChangedTalkFlow(questId, stepId)
      local questRow = questTbl.GetRow(questId)
      if questRow and questRow.StepFlowPath ~= "" then
        local stepNode = Z.QuestFlowMgr:GetStepNode(questId, stepId)
        if stepNode then
          local isCurrent = i == stepCount
          stepNode:RevertStep(isCurrent)
        end
      end
    end
  end
end
local checkIsAllQuestLoaded = function()
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
    questData:SetQuestStep(questId, quest.stepId)
    revertQuest(questId)
  end
  for questId, _ in pairs(Z.ContainerMgr.CharSerialize.questList.acceptQuestMap) do
    addCanAcceptQuest(questId)
  end
  questData.QuestMgrStage = E.QuestMgrStage.InitEnd
  questTrackVM.OnEnterScene()
  questGoalVM.OnEnterScene()
  updateQuestRed()
  updateAllNpcHudQuest()
  if not questData.IsLoginFinish then
    questData.IsLoginFinish = true
  end
end
local isAcceptingQuest = function(quest, oldStepId, oldState)
  local stateList = {
    Z.PbEnum("EQuestStatusType", "QuestAccept"),
    Z.PbEnum("EQuestStatusType", "QuestFinish"),
    Z.PbEnum("EQuestStatusType", "QuestNotEnough")
  }
  local curState = quest.state
  if oldStepId then
    if oldState == Z.PbEnum("EQuestStatusType", "QuestCanAccept") and table.zcontains(stateList, curState) then
      return true
    end
  elseif table.zcontains(stateList, curState) then
    return true
  end
  return false
end
local isHiddenQuest = function(questId)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow then
    local typeRow = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questRow.QuestType)
    if typeRow and typeRow.ShowQuestUI then
      return false
    end
  end
  return true
end
local acceptQuest = function(quest)
  local questId = quest.id
  if isHiddenQuest(questId) then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.Accept, questId)
  checkQuestRed(quest)
end
local endQuest = function(questId, bFinish)
  local step = questData:GetQuestStep(questId)
  if step then
    if bFinish then
      step:StepFinish()
    end
    questData:SetQuestStep(questId, nil)
  end
  closeQuestRed(questId)
  questData:SetQuestItem(questId, nil)
  local talkData = Z.DataMgr.Get("talk_data")
  talkData:DelNpcChangedTalkFlowByQuestId(questId)
  if not bFinish then
    Z.QuestMgr:RemoveQuestEntByQuestId(questId)
  end
  if bFinish and not isHiddenQuest(questId) then
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
  questTrackVM.OnQuestEnd(questId, bFinish)
  questData:RemoveLoadedQuest(questId)
end
local delQuest = function(questId)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow and questRow.QuestType == E.QuestType.WorldQuest then
    local worldQuestVM = Z.VMMgr.GetVM("worldquest")
    worldQuestVM.WorldQuestEventRemove()
  end
end
local handleTimeLimitStep = function(quest, dirtyKeys)
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
local updateStep = function(quest, oldStepId, oldState)
  logGreen("[quest] step update : questId = {0}, stepId = {1}, state = {2}", quest.id, quest.stepId, quest.state)
  local questId = quest.id
  local isAccepting = isAcceptingQuest(quest, oldStepId, oldState)
  local oldStep = questData:GetQuestStep(questId)
  if oldStep then
    oldStep:StepFinish()
    questData:SetQuestStep(questId, nil)
  end
  questData:SetQuestStep(questId, quest.stepId)
  questTalkVM.UpdateNpcChangedTalkFlow(questId, quest.stepId)
  updateQuestItem(questId, quest.stepId)
  questGoalVM.HandleNpcFollowGoalByQuestId(questId)
  questGoalVM.HandleAutoGoalByStepId(quest.stepId)
  questGoalVM.HandleOpenInsightGoalByStepId(quest.stepId)
  if isAccepting then
    acceptQuest(quest)
  end
  if oldStepId then
    if questData:GetQuestTrackingId() == questId then
      questTrackVM.UpdateSceneGuideGoal()
    end
    if not isHiddenQuest(quest.id) then
      Z.EventMgr:Dispatch(Z.ConstValue.Quest.StepChange, quest.id, quest.stepId)
      checkQuestRed(quest)
      Z.EventMgr:Dispatch(Z.ConstValue.UpdateAllTargetView)
    end
  end
  if isAccepting then
    questTrackVM.OnAcceptQuest(questId)
  end
  if questTimeLimitVM.IsTimeLimitStepByStepId(quest.stepId) then
    questTrackVM.ReplaceAndTrackingQuest(questId)
    Z.EventMgr:Dispatch(Z.ConstValue.TimeLimitQuestAccept, questId)
  end
end
local onQuestChange = function(quest, dirtyKeys)
  if questData.QuestMgrStage < E.QuestMgrStage.LoadEnd or not questData:IsQuestLoaded(quest.id) then
    return
  end
  local stepDirty = dirtyKeys.stepId
  local questStateDirty = dirtyKeys.state
  if stepDirty then
    local oldState
    if questStateDirty then
      oldState = questStateDirty:GetLast()
    end
    updateStep(quest, stepDirty:GetLast(), oldState)
  end
  if questStateDirty then
    local oldState = questStateDirty:GetLast()
    local newState = questStateDirty:Get()
    checkQuestRed(quest)
    if not stepDirty then
      local step = questData:GetQuestStep(quest.id)
      if step then
        step:StepOnQuestStateChange(oldState, newState)
      end
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Quest.StateChange, quest.id, oldState, newState)
  end
  if stepDirty then
    return
  end
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
    questTrackVM.UpdateSceneGuideGoal()
  end
  if questTimeLimitVM.IsTimeLimitStepByStepId(quest.stepId) then
    handleTimeLimitStep(quest, dirtyKeys)
  end
  if questData:IsShowInTrackBar(quest.id) then
    Z.EventMgr:Dispatch(Z.ConstValue.UpdateAllTargetView)
  end
end
local onQuestListChange = function(questList, dirtyKeys)
  local finishQuest = dirtyKeys.finishQuest or {}
  for questId, v in pairs(finishQuest) do
    if v:IsNew() then
      logGreen("[quest] finishQuest Add: questId = {0}", questId)
      endQuest(questId, true)
    elseif v:IsDel() then
      logGreen("[quest] finishQuest Remove: questId = {0}", questId)
    end
  end
  local acceptQuestMap = dirtyKeys.acceptQuestMap or {}
  for questId, v in pairs(acceptQuestMap) do
    if v:IsNew() then
      logGreen("[quest] acceptQuestMap Add: questId = {0}", questId)
      addCanAcceptQuest(questId)
    elseif v:IsDel() then
      logGreen("[quest] acceptQuestMap Remove: questId = {0}", questId)
      removeCanAcceptQuest(questId)
    end
  end
  local questMapDirty = dirtyKeys.questMap or {}
  for questId, v in pairs(questMapDirty) do
    if v:IsNew() then
      local quest = questList.questMap[questId]
      if quest then
        quest.Watcher:RegWatcher(onQuestChange)
        Z.QuestFlowMgr:StartFlow(questId)
        local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
        if questRow.QuestType == E.QuestType.WorldQuest then
          local worldQuestData_ = Z.DataMgr.Get("worldquest_data")
          worldQuestData_.AcceptWorldQuest = true
          Z.LevelMgr:OnLevelEventTrigger(E.LevelEventType.OnWorldQuestRefresh)
          Z.EventMgr:Dispatch(Z.ConstValue.WorldQuestListChange)
        end
      else
        logError("[quest] add nil quest, questId = {0}", questId)
      end
    elseif v:IsDel() then
      delQuest(questId)
      logGreen("[quest] finishQuest Remove: questId = {0}", questId)
    end
  end
  if dirtyKeys.questMap then
    checkIsAllQuestLoaded()
  end
end
local getCurGoalConfigData = function(questId, goalIdx)
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
local isQuestFinish = function(questId)
  return Z.ContainerMgr.CharSerialize.questList.finishQuest[questId]
end
local isQuestStepFinish = function(questId, stepId)
  if isQuestFinish(questId) then
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
local clearQuestDataOnLeaveScene = function()
  local questList = Z.ContainerMgr.CharSerialize.questList
  questList.Watcher:UnregWatcher(onQuestListChange)
  for questId, quest in pairs(questList.questMap) do
    quest.Watcher:UnregWatcher(onQuestChange)
  end
  questData.QuestMgrStage = E.QuestMgrStage.BeginUnInit
  questData:ClearAllQuestStep()
  questData:ClearGoalTrackData()
  questData:ClearNpcHudQuest()
  questData:ClearLoadedQuest()
  Z.QuestMgr:ClearAllQuestData()
  questData.QuestMgrStage = E.QuestMgrStage.UnInitEnd
  questTrackVM.OnLeaveScene()
  logGreen("[quest] clearQuestDataOnLeaveScene")
end
local updateQuestDataOnEnterScene = function(sceneId)
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
  questList.Watcher:RegWatcher(onQuestListChange)
  for questId, quest in pairs(questList.questMap) do
    quest.Watcher:RegWatcher(onQuestChange)
    Z.QuestFlowMgr:StartFlow(questId)
  end
end
local onQuestFlowLoaded = function(loadedQuestId)
  questData:AddLoadedQuest(loadedQuestId)
  if questData.QuestMgrStage < E.QuestMgrStage.LoadEnd then
    checkIsAllQuestLoaded()
  else
    local quest = questData:GetQuestByQuestId(loadedQuestId)
    if quest then
      updateStep(quest)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.QuestFlowLoaded, loadedQuestId)
end
local getPhotoQuestStepIds = function()
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
local asyncAcceptQuest = function(questId, cancelToken)
  cancelToken = cancelToken or questData.CancelSource:CreateToken()
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.AcceptQuest({questId = questId}, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end
local asyncGiveUpQuest = function(questId, cancelToken)
  cancelToken = cancelToken or questData.CancelSource:CreateToken()
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GiveupQuest({questId = questId}, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end
local ret = {
  UpdateQuestDataOnEnterScene = updateQuestDataOnEnterScene,
  ClearQuestDataOnLeaveScene = clearQuestDataOnLeaveScene,
  OnQuestFlowLoaded = onQuestFlowLoaded,
  GetQuestIconInScene = getQuestIconInScene,
  GetQuestNpcUidListByStepAndScene = getQuestNpcUidListByStepAndScene,
  UpdateNpcHudQuest = updateNpcHudQuest,
  UpdateAllNpcHudQuest = updateAllNpcHudQuest,
  GetCurGoalConfigData = getCurGoalConfigData,
  IsShowQuestRed = isShowQuestRed,
  CloseQuestRed = closeQuestRed,
  CloseAllQuestRed = closeAllQuestRed,
  IsGoalCompleted = isGoalCompleted,
  GetUncompletedGoalIndex = getUncompletedGoalIndex,
  IsQuestFinish = isQuestFinish,
  EndQuest = endQuest,
  GetPhotoQuestStepIds = getPhotoQuestStepIds,
  IsQuestStepFinish = isQuestStepFinish,
  AsyncGiveUpQuest = asyncGiveUpQuest,
  AsyncAcceptQuest = asyncAcceptQuest,
  CompareQuestIdOrder = compareQuestIdOrder
}
return ret
