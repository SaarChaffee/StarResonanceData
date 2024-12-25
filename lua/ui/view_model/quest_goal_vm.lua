local goalVM = Z.VMMgr.GetVM("goal")
local goalFuncDict = {
  [E.GoalType.AutoPlayCutscene] = function(cutsceneId)
    local cutsceneId = tonumber(cutsceneId)
    Z.LevelMgr.FireSceneEvent({
      eventType = 4,
      intParams = {cutsceneId}
    })
  end,
  [E.GoalType.AutoOpenUI] = function(functionId)
    local functionId = tonumber(functionId)
    local vm = Z.VMMgr.GetVM("gotofunc")
    vm.GoToFunc(functionId)
    goalVM.SetGoalFinish(E.GoalType.AutoOpenUI, functionId)
  end
}
local checkSceneLimit = function(goalArray)
  local sceneLimit = tonumber(goalArray[E.GoalParam.SceneLimit])
  return sceneLimit == 0 or sceneLimit == Z.StageMgr.GetCurrentSceneId()
end
local handleAutoGoalByConfigArray = function(goalArray)
  local goalType = tonumber(goalArray[E.GoalParam.Type])
  local func = goalFuncDict[goalType]
  if not func then
    return
  end
  if checkSceneLimit(goalArray) then
    func(table.unpack(goalArray, 4))
  end
end
local handleAutoGoalByStepId = function(stepId)
  local questData = Z.DataMgr.Get("quest_data")
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if stepRow then
    for _, goalArray in ipairs(stepRow.StepParam) do
      handleAutoGoalByConfigArray(goalArray)
    end
  end
end
local applyGoalArrayWithFuncByStepId = function(stepId, handleGoalType, handleFunc)
  local questData = Z.DataMgr.Get("quest_data")
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if stepRow then
    for _, goalArray in ipairs(stepRow.StepParam) do
      local goalType = tonumber(goalArray[E.GoalParam.Type])
      if goalType == handleGoalType and checkSceneLimit(goalArray) then
        handleFunc(goalArray)
      end
    end
  end
end
local handleOpenInsightGoalByStepId = function(stepId)
  applyGoalArrayWithFuncByStepId(stepId, E.GoalType.OpenInsight, function()
    local state = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value
    if state == 1 then
      goalVM.SetGoalFinish(E.GoalType.OpenInsight)
    end
  end)
end
local applyNpcFollowGoalWithFuncByQuestId = function(questId, handleFunc)
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return
  end
  applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.PlayerFollowNpc, handleFunc)
  applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.PlayerFollowNpcWalk, handleFunc)
  applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.NpcFollowPlayer, handleFunc)
end
local handleNpcFollowGoalByQuestId = function(questId)
  local entityVM = Z.VMMgr.GetVM("entity")
  local handleFunc = function(goalArray)
    local npcUid = tonumber(goalArray[4])
    local zoneUid = tonumber(goalArray[5])
    Z.QuestMgr:SetQuestZoneData(questId, zoneUid, npcUid)
  end
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return
  end
  applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.PlayerFollowNpc, function(goalArray)
    handleFunc(goalArray)
    local npcUid = tonumber(goalArray[4])
    local npcUuid = entityVM.EntIdToUuid(npcUid, Z.PbEnum("EEntityType", "EntNpc"), false, true)
    local enabled = tonumber(goalArray[6]) == 1
    local path = goalArray[7]
    local dist = tonumber(goalArray[8])
    local bubbleId = tonumber(goalArray[9])
    Z.QuestMgr:SetAiEnable(npcUuid, enabled)
    Z.QuestMgr:SetAiWayPointPath(npcUuid, path)
    Z.QuestMgr:SetAiNearByDistance(npcUuid, dist)
    Z.QuestMgr:SetAiBubble(npcUuid, bubbleId, 2)
  end)
  applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.PlayerFollowNpcWalk, function(goalArray)
    handleFunc(goalArray)
  end)
  applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.NpcFollowPlayer, function(goalArray)
    handleFunc(goalArray)
  end)
end
local onZoneRequestConditionMeet = function(questId)
  local handleFunc = function(goalArray)
    local goalType = tonumber(goalArray[E.GoalParam.Type])
    local checkParam = tonumber(goalArray[E.GoalParam.Check])
    goalVM.SetGoalFinish(goalType, checkParam)
  end
  applyNpcFollowGoalWithFuncByQuestId(questId, handleFunc)
end
local onEnterScene = function()
  local questData = Z.DataMgr.Get("quest_data")
  local questDict = questData:GetAllQuestDict()
  for questId, quest in pairs(questDict) do
    handleAutoGoalByStepId(quest.stepId)
    handleNpcFollowGoalByQuestId(questId)
  end
end
local handleAllQuestAutoGoal = function()
  local questData = Z.DataMgr.Get("quest_data")
  local questDict = questData:GetAllQuestDict()
  for questId, quest in pairs(questDict) do
    handleAutoGoalByStepId(quest.stepId)
  end
end
local ret = {
  OnEnterScene = onEnterScene,
  OnZoneRequestConditionMeet = onZoneRequestConditionMeet,
  HandleAutoGoalByStepId = handleAutoGoalByStepId,
  HandleOpenInsightGoalByStepId = handleOpenInsightGoalByStepId,
  HandleNpcFollowGoalByQuestId = handleNpcFollowGoalByQuestId,
  HandleAllQuestAutoGoal = handleAllQuestAutoGoal
}
return ret
