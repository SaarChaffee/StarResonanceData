local talkData = Z.DataMgr.Get("talk_data")
local questData = Z.DataMgr.Get("quest_data")
local openCommonTalkDialog = function(viewData)
  if Z.StatusSwitchMgr:TrySwitchToState(Z.EStatusSwitch.StatusNormalDialogue) then
    Z.UIMgr:OpenView("talk_dialog_window", viewData)
  end
end
local closeCommonTalkDialog = function()
  Z.EventMgr:Dispatch(Z.ConstValue.Talk.CloseTalkDialog)
end
local openCommonTalk = function(viewData)
  Z.UIMgr:OpenView("talk_main", viewData)
end
local closeCommonTalk = function()
  Z.UIMgr:CloseView("talk_main")
end
local getChangedTalkFlow = function(npcId)
  local flowDict = talkData:GetChangedTalkFlowDictByNpcId(npcId)
  if flowDict then
    local _, flowId = next(flowDict)
    if flowId then
      return flowId
    end
  end
  return nil
end
local getNpcEntity = function(uuid)
  local npcEntity = Z.EntityMgr:GetEntity(uuid)
  if not npcEntity then
    logError("[Quest] getNpcDefaultTalkFlow npcEntity is nil")
    return nil
  end
  return npcEntity
end
local getNpcDefaultTalkFlow = function(data)
  local npcId = data.npcId
  local uuid = data.uuid
  local flowId = getChangedTalkFlow(npcId)
  if flowId then
    return flowId
  end
  local npcEntity = getNpcEntity(uuid)
  if not npcEntity then
    return 0
  end
  local row = Z.TableMgr.GetTable("NpcTableMgr").GetRow(npcId)
  if not (row and row.DialogFlow) or #row.DialogFlow == 0 then
    return 0
  end
  if #row.DialogFlow == 1 and #row.DialogFlow[1] == 1 then
    return row.DialogFlow[1][1]
  end
  local npcState = npcEntity:GetAttrObjStateValue() or 0
  for _, v in ipairs(row.DialogFlow) do
    if v[1] == npcState then
      return v[2]
    end
  end
  return 0
end
local getTalkFlowByNpcId = function(data)
  local npcId = data.npcId
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local questTalkFlowDict = talkData:GetQuestTalkFlowDictByNpcAndScene(npcId, curSceneId)
  local questTalkFlowDictCount = table.zcount(questTalkFlowDict)
  if questTalkFlowDictCount == 1 then
    local flowId = next(questTalkFlowDict)
    return flowId
  end
  local defaultFlowId = getNpcDefaultTalkFlow(data)
  if (defaultFlowId == 0 or defaultFlowId == nil) and 1 < questTalkFlowDictCount then
    return Z.Global.DefaultDialogFlow
  end
  return defaultFlowId
end
local notifyNpcQuestTalkFlowChange = function(npcId)
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local questTalkFlowDict = talkData:GetQuestTalkFlowDictByNpcAndScene(npcId, curSceneId)
  local questTalkFlowDictCount = table.zcount(questTalkFlowDict)
  if 0 < questTalkFlowDictCount then
    return Z.QuestMgr:SetNpcQuestTalkState(npcId, Panda.ZGame.ENpcQuestTalkState.Have)
  end
  local flowId = getChangedTalkFlow(npcId)
  if flowId then
    if flowId == 0 then
      return Z.QuestMgr:SetNpcQuestTalkState(npcId, Panda.ZGame.ENpcQuestTalkState.ChangedNone)
    else
      return Z.QuestMgr:SetNpcQuestTalkState(npcId, Panda.ZGame.ENpcQuestTalkState.Have)
    end
  end
  return Z.QuestMgr:SetNpcQuestTalkState(npcId, Panda.ZGame.ENpcQuestTalkState.None)
end
local onBeforeBeginTalk = function()
  Z.LuaBridge.BeginTalk()
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.TalkEnd)
  local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
  questGoalGuideVm.SetQuestGuideEffectVisible(false)
end
local beginNpcTalkState = function(data, token)
  local flowId = getTalkFlowByNpcId(data)
  if flowId <= 0 then
    logError("[Quest] beginNpcTalkState invalid flowId:" .. flowId)
    return
  end
  local info = talkData:GetPlayFlowIdInfo(flowId)
  if info ~= nil then
    logError("[Quest] beginNpcTalkState flowId:" .. flowId .. " is playing")
    return
  end
  logGreen("[Quest] beginNpcTalkState flowId:" .. flowId)
  onBeforeBeginTalk()
  talkData:SetPlayFlowIdData(flowId, E.FlowPlayStateEnum.WaitNpc, E.FlowPlaySourceEnum.TalkPlayFlow, nil, data.uuid)
  Z.NpcBehaviourMgr:BeginTalk(data.uuid)
end
local beginNpcTalkFlow = function(data, token)
  local flowId = talkData:GetFlowIdByOwner(data.uuid)
  if flowId == nil or flowId <= 0 then
    logGreen("[Quest] BeginFlow flowId is nil or <= 0")
    return
  end
  talkData:SetTalkingNpcData(data)
  talkData:RefreshPlayFlowIdState(flowId, E.FlowPlayStateEnum.Loading)
  talkData:InitConfrontation()
  local row = Z.TableMgr.GetTable("PresentationEPFlowTableMgr").GetRow(flowId)
  if row and not row.IsDefaultCameraDisabled and not row.IsModelDialogue then
    Z.NpcBehaviourMgr:SetDialogCameraByConfigId(1)
    talkData.IsDelayQuit = true
  end
  logGreen("[Quest] StartFlow flowId:" .. flowId)
  Z.EPFlowBridge.StartFlow(flowId)
end
local setNodeIsAllowSkip = function(isAllow)
  if talkData:GetNodeIsAllowSkip() ~= isAllow then
    talkData:SetNodeIsAllowSkip(isAllow)
    Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.IsAllowSkipTalkChange, isAllow)
  end
end
local onEPFlowStart = function(flowId)
  talkData:SetTalkCurFlow(flowId)
  talkData:RefreshPlayFlowIdState(flowId, E.FlowPlayStateEnum.Playing)
end
local onEndTalk = function()
  logGreen("[Quest] onEndTalk")
  local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
  questGoalGuideVm.SetQuestGuideEffectVisible(true)
  Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.TalkStateEnd)
  Z.LuaBridge.EndTalk()
end
local endTalkState = function(flowId)
  Z.CameraMgr:CloseDialogCamera()
  if talkData.IsDelayQuit then
    Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.TalkEnd, function()
    end, 1.3, 1, nil, onEndTalk)
    talkData.IsDelayQuit = false
  else
    onEndTalk()
  end
  closeCommonTalk()
  local talkModelVm = Z.VMMgr.GetVM("talk_model")
  talkModelVm.CloseModelTalk(false)
end
local onEPFlowStop = function(flowId, endPort, isFinished)
  logGreen("[Quest] Stop flowId:" .. flowId)
  local questTalkVM = Z.VMMgr.GetVM("quest_talk")
  local isQuest = questTalkVM.OnEPFlowStop(flowId, endPort, isFinished)
  if isFinished then
    if not isQuest then
      local goalVM = Z.VMMgr.GetVM("goal")
      goalVM.SetGoalFinish(E.GoalType.AutoPlayFlow, flowId, 0)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnStopEPFlow, flowId)
  end
  local curFlow = talkData:GetTalkCurFlow()
  if 0 < curFlow and curFlow == flowId then
    talkData:SetTalkCurFlow(0)
  end
  local flowInfo = talkData:GetPlayFlowIdInfo(flowId)
  if flowInfo == nil then
    logGreen("[Quest] Stop flowId:" .. flowId .. " flowInfo is nil ")
    return
  end
  talkData:RefreshPlayFlowIdState(flowId, E.FlowPlayStateEnum.Finish)
  if flowInfo.childFlowIds and 0 < #flowInfo.childFlowIds then
    logGreen("[Quest] Stop flowId:" .. flowId .. " has childFlowIds")
    return
  end
  endTalkState()
  if flowInfo.owner ~= nil and (flowInfo.flowPlaySource == E.FlowPlaySourceEnum.TalkPlayFlow or flowInfo.flowPlaySource == E.FlowPlaySourceEnum.OptionPlayFlow) then
    talkData:SetTalkingNpcData(nil)
    Z.NpcBehaviourMgr:EndTalk()
  end
end
local stopWaitNpcTalkState = function(uuid)
  if uuid == nil then
    logError("[Quest] stopWaitNpcTalkState uuid is nil")
    return
  end
  local flowId = talkData:GetFlowIdByOwner(uuid)
  if flowId == nil or flowId <= 0 then
    return
  end
  local flowInfo = talkData:GetPlayFlowIdInfo(flowId)
  if flowInfo == nil then
    return
  end
  if flowInfo.state == E.FlowPlayStateEnum.WaitNpc then
    logError("[Quest] stopWaitNpcTalkState flowId:" .. flowId)
    local curFlow = talkData:GetTalkCurFlow()
    if 0 < curFlow and curFlow == flowId then
      talkData:SetTalkCurFlow(0)
    end
    talkData:RefreshPlayFlowIdState(flowId, E.FlowPlayStateEnum.Finish)
    endTalkState()
    Z.NpcBehaviourMgr:EndTalk()
  end
end
local handlePlaceholderStr = function(content)
  local holderParam = {}
  Z.Placeholder.SetMePlaceholder(holderParam)
  local parkourtipsVm = Z.VMMgr.GetVM("parkourtips")
  holderParam = parkourtipsVm.SetParkourRecordPlaceholder(holderParam)
  holderParam = Z.Placeholder.SetPlayerSelfPronoun(holderParam)
  local content = Z.Placeholder.Placeholder(content, holderParam)
  return content
end
local isAddTalkGoal = function(goalType)
  return goalType == E.GoalType.NpcFlowTalk or goalType == E.GoalType.SubmitItem or goalType == E.GoalType.ShowItem
end
local isCurFlowDefaultFlow = function()
  local talkData = Z.DataMgr.Get("talk_data")
  local npcData = talkData:GetTalkingNpcData()
  if npcData == nil then
    return false
  end
  local curFlow = talkData:GetTalkCurFlow()
  if curFlow == Z.Global.DefaultDialogFlow then
    return true
  end
  local defaultFlow = getNpcDefaultTalkFlow(npcData)
  if defaultFlow == nil or defaultFlow <= 0 then
    return false
  end
  return curFlow == defaultFlow
end
local isTalking = function()
  local talkData = Z.DataMgr.Get("talk_data")
  local curFlow = talkData:GetTalkCurFlow()
  if 0 < curFlow then
    return true
  end
  return false
end
local ret = {
  IsAddTalkGoal = isAddTalkGoal,
  BeginNpcTalkState = beginNpcTalkState,
  BeginNpcTalkFlow = beginNpcTalkFlow,
  OpenCommonTalk = openCommonTalk,
  CloseCommonTalk = closeCommonTalk,
  OpenCommonTalkDialog = openCommonTalkDialog,
  CloseCommonTalkDialog = closeCommonTalkDialog,
  SetNodeIsAllowSkip = setNodeIsAllowSkip,
  GetNpcDefaultTalkFlow = getNpcDefaultTalkFlow,
  OnBeforeBeginTalk = onBeforeBeginTalk,
  OnEPFlowStart = onEPFlowStart,
  OnEPFlowStop = onEPFlowStop,
  HandlePlaceholderStr = handlePlaceholderStr,
  EndTalkState = endTalkState,
  IsCurFlowDefaultFlow = isCurFlowDefaultFlow,
  NotifyNpcQuestTalkFlowChange = notifyNpcQuestTalkFlowChange,
  IsTalking = isTalking,
  StopWaitNpcTalkState = stopWaitNpcTalkState
}
return ret
