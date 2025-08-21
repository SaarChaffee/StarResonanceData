local goalVM = Z.VMMgr.GetVM("goal")
local questData = Z.DataMgr.Get("quest_data")
local getAutoTalkFlowId = function(sceneId)
  local talkData = Z.DataMgr.Get("talk_data")
  local questTalkData = talkData:GetQuestFlowTalk()
  if questTalkData[sceneId] and questTalkData[sceneId][0] then
    local flowId = next(questTalkData[sceneId][0])
    if flowId then
      return flowId
    end
  end
  if questTalkData[0] and questTalkData[0][0] then
    local flowId = next(questTalkData[0][0])
    if flowId then
      return flowId
    end
  end
end
local openAutoFlowTalk = function()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local flowId = getAutoTalkFlowId(sceneId)
  if flowId then
    local talkData = Z.DataMgr.Get("talk_data")
    local talkVM = Z.VMMgr.GetVM("talk")
    talkVM.OnBeforeBeginTalk()
    talkData:SetPlayFlowIdData(flowId, E.FlowPlayStateEnum.Loading, E.FlowPlaySourceEnum.AutoPlayFlow, nil)
    logGreen("[quest] openAutoFlowTalk flowId = " .. flowId)
    Z.EPFlowBridge.StartFlow(flowId)
  end
end
local addGoalTalkDataByQuestId = function(questId, isNotify)
  local quest = questData:GetQuestByQuestId(questId)
  if not quest or quest.state == Z.PbEnum("EQuestStatusType", "QuestNotEnough") then
    return
  end
  local stepRow = questData:GetStepConfigByStepId(quest.stepId)
  if not stepRow then
    return
  end
  local talkVM = Z.VMMgr.GetVM("talk")
  local talkData = Z.DataMgr.Get("talk_data")
  local stepParam = stepRow.StepParam
  for i = 1, #stepParam do
    local stepParamArray = stepParam[i]
    local toSceneId = tonumber(stepParamArray[3])
    local goalType = tonumber(stepParamArray[1])
    if goalType == E.GoalType.AutoPlayFlow then
      local flowId = tonumber(stepParamArray[4])
      talkData:AddQuestFlowTalk(toSceneId, 0, flowId, questId)
      if isNotify then
        openAutoFlowTalk()
      end
    elseif talkVM.IsAddTalkGoal(goalType) then
      local npcId = tonumber(stepParamArray[4])
      local flowId = tonumber(stepParamArray[5])
      talkData:AddQuestFlowTalk(toSceneId, npcId, flowId, questId)
    end
  end
end
local removeGoalTalkDataByStepId = function(stepId)
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if not stepRow then
    return
  end
  local talkVM = Z.VMMgr.GetVM("talk")
  local talkData = Z.DataMgr.Get("talk_data")
  local stepParam = stepRow.StepParam
  for i = 1, #stepParam do
    local stepParamArray = stepParam[i]
    local toSceneId = tonumber(stepParamArray[3])
    local goalType = tonumber(stepParamArray[1])
    if goalType == E.GoalType.AutoPlayFlow then
      local flowId = tonumber(stepParamArray[4])
      talkData:RemoveQuestFlowTalk(toSceneId, 0, flowId)
    elseif talkVM.IsAddTalkGoal(goalType) then
      local npcId = tonumber(stepParamArray[4])
      local flowId = tonumber(stepParamArray[5])
      talkData:RemoveQuestFlowTalk(toSceneId, npcId, flowId)
    end
  end
end
local addAcceptTalkDataByQuestId = function(questId)
  local acceptConfig = questData:GetAcceptConfigByQuestId(questId)
  if not acceptConfig then
    return
  end
  local talkData = Z.DataMgr.Get("talk_data")
  talkData:AddQuestFlowTalk(acceptConfig.sceneId, acceptConfig.npcId, acceptConfig.flowId, questId)
end
local removeAcceptTalkDataByQuestId = function(questId)
  local acceptConfig = questData:GetAcceptConfigByQuestId(questId)
  if not acceptConfig then
    return
  end
  local talkData = Z.DataMgr.Get("talk_data")
  talkData:RemoveQuestFlowTalk(acceptConfig.sceneId, acceptConfig.npcId, acceptConfig.flowId)
end
local updateNpcChangedTalkFlow = function(questId, stepId)
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if stepRow and stepRow.NpcTalkChange then
    local talkData = Z.DataMgr.Get("talk_data")
    for _, npcTalkArray in ipairs(stepRow.NpcTalkChange) do
      local npcId = npcTalkArray[1]
      local flowId = npcTalkArray[2]
      talkData:SetNpcChangedTalkFlow(npcId, questId, flowId)
    end
  end
end
local onEPFlowStop = function(flowId, endPort, isFinished)
  local args = questData.FlowBlackMaskArgsDict[flowId]
  if args then
    args.TimeOut = 10
    Z.UIMgr:FadeIn(args)
    questData.FlowBlackMaskArgsDict[flowId] = nil
  end
  if not isFinished then
    return false
  end
  local talkData = Z.DataMgr.Get("talk_data")
  local npcId = talkData:GetTalkingNpcId()
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local questTalkFlowDict = talkData:GetQuestTalkFlowDictByNpcAndScene(npcId, curSceneId)
  local questId = questTalkFlowDict[flowId]
  if not questId then
    return false
  end
  if questData:IsCanAcceptQuest(questId) then
    local acceptConfig = questData:GetAcceptConfigByQuestId(questId)
    if acceptConfig and acceptConfig.portId + 1 == endPort and acceptConfig.npcId == npcId and acceptConfig.sceneId == curSceneId then
      Z.CoroUtil.coro_call(function()
        local questVM = Z.VMMgr.GetVM("quest")
        questVM.AsyncAcceptQuest(questId)
      end)
    end
  else
    local goalType = 0 < npcId and E.GoalType.NpcFlowTalk or E.GoalType.AutoPlayFlow
    goalVM.SetGoalFinish(goalType, flowId, endPort)
  end
  return true
end
local ret = {
  OnEPFlowStop = onEPFlowStop,
  AddGoalTalkDataByQuestId = addGoalTalkDataByQuestId,
  RemoveGoalTalkDataByStepId = removeGoalTalkDataByStepId,
  AddAcceptTalkDataByQuestId = addAcceptTalkDataByQuestId,
  RemoveAcceptTalkDataByQuestId = removeAcceptTalkDataByQuestId,
  UpdateNpcChangedTalkFlow = updateNpcChangedTalkFlow,
  OpenAutoFlowTalk = openAutoFlowTalk
}
return ret
