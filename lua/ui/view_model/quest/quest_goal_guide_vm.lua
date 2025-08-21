local QuestGoalGuideVM = {}

function QuestGoalGuideVM.isZoneInSameVisualLayer(zoneUid)
  local zoneRow = Z.TableMgr.GetTable("ZoneEntityTableMgr").GetRow(zoneUid)
  if zoneRow then
    return zoneRow.VisualLayerId == Z.World.VisualLayer
  end
  return false
end

function QuestGoalGuideVM.RefreshQuestGuideEffectVisible()
  if not Z.GoalGuideMgr then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  for zoneUid, effectId in pairs(questData:GetGoalEffectDict()) do
    local isVisible = questData.IsShowGuideEffect
    isVisible = isVisible and QuestGoalGuideVM.isZoneInSameVisualLayer(zoneUid)
    isVisible = isVisible and not Z.LuaBridge.IsPlayerInZone(zoneUid)
    Z.GoalGuideMgr:SetGuideEffectVisible(effectId, isVisible)
  end
end

function QuestGoalGuideVM.SetQuestGuideEffectVisible(isVisible)
  local questData = Z.DataMgr.Get("quest_data")
  questData.IsShowGuideEffect = isVisible
  QuestGoalGuideVM.RefreshQuestGuideEffectVisible()
end

function QuestGoalGuideVM.getGuideGoalInfo(stepId, goalIdx)
  local questData = Z.DataMgr.Get("quest_data")
  local trackData = questData:GetGoalTrackData(stepId, goalIdx)
  if not trackData then
    return
  end
  local posType, uid, pos
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local goalInfo
  local sourceGoalInfo = {
    sceneId = trackData.toSceneId,
    posType = trackData.posType,
    uid = trackData.uid,
    pos = trackData.pos
  }
  if trackData.toSceneId == curSceneId then
    goalInfo = sourceGoalInfo
  else
    posType = Z.GoalPosType.Zone
    uid = Z.GoalGuideMgr:GetTpZoneUidBetweenScene(curSceneId, trackData.toSceneId)
    if 0 < uid then
      local zoneRow = Z.TableMgr.GetTable("ZoneEntityTableMgr").GetRow(uid)
      if zoneRow then
        local posArray = zoneRow.Position
        pos = {
          x = posArray[1],
          y = posArray[2],
          z = posArray[3]
        }
      end
    end
  end
  if pos then
    goalInfo = {
      sceneId = curSceneId,
      posType = posType,
      uid = uid,
      pos = pos
    }
  end
  return goalInfo, sourceGoalInfo
end

function QuestGoalGuideVM.clearSceneGuideGoal()
  local questData = Z.DataMgr.Get("quest_data")
  questData:ClearGoalEffect()
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  guideVM.SetGuideGoals(E.GoalGuideSource.Quest, nil)
end

local handleZoneTrackGoalEffect = function(questData, goal, pos, stepId, isLastGoal)
  local effName = "effect/common_new/env/guide/p_fx_changjingzhuizong"
  local questTimeLimitVM = Z.VMMgr.GetVM("quest_time_limit")
  if questTimeLimitVM.IsTimeLimitStepByStepId(stepId) and isLastGoal then
    effName = "effect/common_new/env/p_fx_hint_terminus"
  end
  local effectIdDic = questData:GetGoalEffectDict()
  local effectId = effectIdDic[goal.uid]
  if not effectId then
    effectId = Z.GoalGuideMgr:ShowGuideEffect(Vector3.New(pos.x, pos.y, pos.z), effName)
    questData:SetGoalEffectUid(goal.uid, effectId)
  else
    logGreen("[quest] \233\135\141\229\164\141\229\136\155\229\187\186\229\140\186\229\159\159\232\191\189\232\184\170\231\137\185\230\149\136\229\140\186\229\159\159\228\184\186\239\188\154" .. goal.uid .. "  \230\173\165\233\170\164Id\228\184\186\239\188\154" .. stepId)
  end
end

function QuestGoalGuideVM.UpdateSceneGuideGoal()
  QuestGoalGuideVM.clearSceneGuideGoal()
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questData:GetQuestTrackingId())
  if not quest then
    return
  end
  local stepRow = questData:GetStepConfigByStepId(quest.stepId)
  if not stepRow then
    return
  end
  local questGoalVM = Z.VMMgr.GetVM("quest_goal")
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local posInfoList = {}
  local sourcePosInfoList = {}
  local goalNum = #stepRow.StepParam
  for idx = 1, goalNum do
    local hideTrackedIcon = stepRow:GetTargetIsHideTrackIcon(idx - 1)
    local goal, sourceGoal = QuestGoalGuideVM.getGuideGoalInfo(quest.stepId, idx)
    local curGoalStage = questGoalVM.IsGoalCompleted(quest.id, idx)
    if sourceGoal and sourceGoal.pos and not curGoalStage then
      local sourcePosInfo = Panda.ZGame.GoalPosInfo.New(E.GoalGuideSource.Quest, sourceGoal.sceneId, sourceGoal.uid, sourceGoal.posType, Vector3.New(sourceGoal.pos.x, sourceGoal.pos.y, sourceGoal.pos.z), not hideTrackedIcon)
      table.insert(sourcePosInfoList, sourcePosInfo)
    end
    if goal and not curGoalStage then
      local pos = goal.pos
      if goal.posType == Z.GoalPosType.Zone then
        handleZoneTrackGoalEffect(questData, goal, pos, quest.stepId, idx == goalNum)
      end
      local posInfo = Panda.ZGame.GoalPosInfo.New(E.GoalGuideSource.Quest, sceneId, goal.uid, goal.posType, Vector3.New(pos.x, pos.y, pos.z), not hideTrackedIcon)
      table.insert(posInfoList, posInfo)
      if stepRow.StepTargetType == E.QuestGoalGroupType.Serial then
        break
      end
    end
  end
  QuestGoalGuideVM.RefreshQuestGuideEffectVisible()
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  guideVM.SetGuideGoals(E.GoalGuideSource.Quest, posInfoList, sourcePosInfoList)
end

function QuestGoalGuideVM.CheckCantPathFindingQuest()
  local questData = Z.DataMgr.Get("quest_data")
  local questGoalVM = Z.VMMgr.GetVM("quest_goal")
  local questTrackVM = Z.VMMgr.GetVM("quest_track")
  local sceneVM = Z.VMMgr.GetVM("scene")
  local curTrackingQuestId = questData:GetQuestTrackingId()
  if curTrackingQuestId == nil or curTrackingQuestId == 0 then
    return false
  end
  if curTrackingQuestId == Z.Global.WorldEventQuestId then
    return false
  end
  local stepRow = questData:GetStepConfigByQuestId(curTrackingQuestId)
  if stepRow == nil then
    return false
  end
  for goalIdx = 1, #stepRow.StepParam do
    local trackData = questData:GetGoalTrackData(stepRow.StepId, goalIdx)
    if trackData and not questGoalVM.IsGoalCompleted(stepRow.StepId, goalIdx) and trackData.toSceneId ~= nil and not sceneVM.IsStaticScene(trackData.toSceneId) then
      questTrackVM.HandleRemoteScene(trackData)
      return true
    end
  end
  return false
end

function QuestGoalGuideVM.CanAcceptquestToGoalGuideSourceType(questId)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow == nil then
    return E.GoalGuideSource.CanAcceptSideQuest
  end
  local questType = questRow.QuestType
  if questType == E.QuestType.Side then
    return E.GoalGuideSource.CanAcceptSideQuest
  elseif questType == E.QuestType.Area then
    return E.GoalGuideSource.CanAcceptAreaQuest
  elseif questType == E.QuestType.Guide then
    return E.GoalGuideSource.CanAcceptGuideQuest
  elseif questType == E.QuestType.Event then
    return E.GoalGuideSource.CanAcceptEventQuest
  end
  return E.GoalGuideSource.CanAcceptSideQuest
end

return QuestGoalGuideVM
