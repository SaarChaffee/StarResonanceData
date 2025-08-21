local QuestGoalVM = {}
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

function QuestGoalVM.checkSceneLimit(goalArray)
  local sceneLimit = tonumber(goalArray[E.GoalParam.SceneLimit])
  return sceneLimit == 0 or sceneLimit == Z.StageMgr.GetCurrentSceneId()
end

function QuestGoalVM.handleAutoGoalByConfigArray(goalArray)
  local goalType = tonumber(goalArray[E.GoalParam.Type])
  local func = goalFuncDict[goalType]
  if not func then
    return
  end
  if QuestGoalVM.checkSceneLimit(goalArray) then
    func(table.unpack(goalArray, 4))
  end
end

function QuestGoalVM.HandleAutoGoalByStepId(stepId)
  local questData = Z.DataMgr.Get("quest_data")
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if stepRow then
    for _, goalArray in ipairs(stepRow.StepParam) do
      QuestGoalVM.handleAutoGoalByConfigArray(goalArray)
    end
  end
end

function QuestGoalVM.applyGoalArrayWithFuncByStepId(stepId, handleGoalType, handleFunc)
  local questData = Z.DataMgr.Get("quest_data")
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if stepRow then
    for _, goalArray in ipairs(stepRow.StepParam) do
      local goalType = tonumber(goalArray[E.GoalParam.Type])
      if goalType == handleGoalType and QuestGoalVM.checkSceneLimit(goalArray) then
        handleFunc(goalArray)
      end
    end
  end
end

function QuestGoalVM.HandleOpenInsightGoalByStepId(stepId)
  QuestGoalVM.applyGoalArrayWithFuncByStepId(stepId, E.GoalType.OpenInsight, function()
    if Z.EntityMgr.PlayerEnt then
      local state = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value
      if state == 1 then
        goalVM.SetGoalFinish(E.GoalType.OpenInsight)
      end
    end
  end)
end

function QuestGoalVM.applyNpcFollowGoalWithFuncByQuestId(questId, handleFunc)
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return
  end
  QuestGoalVM.applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.PlayerFollowNpc, handleFunc)
  QuestGoalVM.applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.PlayerFollowNpcWalk, handleFunc)
  QuestGoalVM.applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.NpcFollowPlayer, handleFunc)
end

function QuestGoalVM.HandleNpcFollowGoalByQuestId(questId)
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
  QuestGoalVM.applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.PlayerFollowNpc, function(goalArray)
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
  QuestGoalVM.applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.PlayerFollowNpcWalk, function(goalArray)
    handleFunc(goalArray)
  end)
  QuestGoalVM.applyGoalArrayWithFuncByStepId(quest.stepId, E.GoalType.NpcFollowPlayer, function(goalArray)
    handleFunc(goalArray)
  end)
end

function QuestGoalVM.OnZoneRequestConditionMeet(questId)
  local handleFunc = function(goalArray)
    local goalType = tonumber(goalArray[E.GoalParam.Type])
    local checkParam = tonumber(goalArray[E.GoalParam.Check])
    goalVM.SetGoalFinish(goalType, checkParam)
  end
  QuestGoalVM.applyNpcFollowGoalWithFuncByQuestId(questId, handleFunc)
end

function QuestGoalVM.OnEnterScene()
  local questData = Z.DataMgr.Get("quest_data")
  local questDict = questData:GetAllQuestDict()
  for questId, quest in pairs(questDict) do
    QuestGoalVM.HandleAutoGoalByStepId(quest.stepId)
    QuestGoalVM.HandleNpcFollowGoalByQuestId(questId)
  end
end

function QuestGoalVM.HandleAllQuestAutoGoal()
  local questData = Z.DataMgr.Get("quest_data")
  local questDict = questData:GetAllQuestDict()
  for questId, quest in pairs(questDict) do
    QuestGoalVM.HandleAutoGoalByStepId(quest.stepId)
  end
end

function QuestGoalVM.IsGoalCompleted(questId, goalIndex)
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

function QuestGoalVM.GetUncompletedGoalIndex(questId)
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if quest then
    local stepRow = questData:GetStepConfigByStepId(quest.stepId)
    if stepRow then
      for i = 1, #stepRow.StepParam do
        if not QuestGoalVM.IsGoalCompleted(quest.id, i) then
          return i
        end
      end
    end
  end
  return 0
end

return QuestGoalVM
