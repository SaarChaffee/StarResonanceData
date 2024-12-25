local isQuestShowTrackBar = function(questId)
  local isVisible = false
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if questData:IsQuestAccessNotEnough(quest) then
    return false
  end
  if quest then
    local stepRow = questData:GetStepConfigByStepId(quest.stepId)
    if stepRow and not stepRow.HideTrackBar and #stepRow.StepTargetInfo > 0 then
      isVisible = true
    end
  end
  return isVisible
end
local isMainQuest = function(questId)
  if questId <= 0 then
    return false
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow and questRow.QuestType == E.QuestType.Main then
    return true
  end
  return false
end
local checkIsAllowReplaceTrack = function(isShowTips)
  local questData = Z.DataMgr.Get("quest_data")
  if questData:IsInForceTrack() then
    if isShowTips then
      local questId = questData:GetForceTrackId()
      local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
      if questRow then
        local param = {
          str = questRow.QuestName
        }
        Z.TipsVM.ShowTipsLang(140201, param)
      end
    end
    return false
  end
  return true
end
local isZoneInSameVisualLayer = function(zoneUid)
  local zoneRow = Z.TableMgr.GetTable("ZoneEntityTableMgr").GetRow(zoneUid)
  if zoneRow then
    return zoneRow.VisualLayerId == Z.World.VisualLayer
  end
  return false
end
local refreshQuestGuideEffectVisible = function()
  if not Z.GoalGuideMgr then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  for zoneUid, effectId in pairs(questData:GetGoalEffectDict()) do
    local isVisible = questData.IsShowGuideEffect
    isVisible = isVisible and isZoneInSameVisualLayer(zoneUid)
    isVisible = isVisible and not Z.LuaBridge.IsPlayerInZone(zoneUid)
    Z.GoalGuideMgr:SetGuideEffectVisible(effectId, isVisible)
  end
end
local setQuestGuideEffectVisible = function(isVisible)
  local questData = Z.DataMgr.Get("quest_data")
  questData.IsShowGuideEffect = isVisible
  refreshQuestGuideEffectVisible()
end
local getGuideGoalInfo = function(stepId, goalIdx)
  local questData = Z.DataMgr.Get("quest_data")
  local trackData = questData:GetGoalTrackData(stepId, goalIdx)
  if not trackData then
    return
  end
  local posType, uid, pos
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  if trackData.toSceneId == curSceneId then
    posType = trackData.posType
    uid = trackData.uid
    pos = trackData.pos
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
    return {
      posType = posType,
      uid = uid,
      pos = pos
    }
  end
end
local clearSceneGuideGoal = function()
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
local updateSceneGuideGoal = function()
  clearSceneGuideGoal()
  local questData = Z.DataMgr.Get("quest_data")
  local questVM = Z.VMMgr.GetVM("quest")
  local quest = questData:GetQuestByQuestId(questData:GetQuestTrackingId())
  if not quest then
    return
  end
  local stepRow = questData:GetStepConfigByStepId(quest.stepId)
  if not stepRow then
    return
  end
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local posInfoList = {}
  local goalNum = #stepRow.StepParam
  for idx = 1, goalNum do
    local goal = getGuideGoalInfo(quest.stepId, idx)
    local curGoalStage = questVM.IsGoalCompleted(quest.id, idx)
    if goal and not curGoalStage then
      local pos = goal.pos
      local hideTrackedIcon = stepRow:GetTargetIsHideTrackIcon(idx - 1)
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
  refreshQuestGuideEffectVisible()
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  guideVM.SetGuideGoals(E.GoalGuideSource.Quest, posInfoList)
end
local updateTrackingQuest = function()
  local questVM = Z.VMMgr.GetVM("quest")
  local questData = Z.DataMgr.Get("quest_data")
  local questId = questData:GetQuestTrackingId()
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.TrackingIdChange, questId, questData.LastTrackingId)
  if questId == questData.LastTrackingId then
    return
  end
  local quest = questData:GetQuestByQuestId(questId)
  local stepId = quest and quest.stepId or 0
  logGreen("[quest] SetQuestTrackingId questId = {0}, stepId = {1}", questId, stepId)
  questData.LastTrackingId = questId
  questVM.UpdateAllNpcHudQuest()
  questVM.CloseQuestRed(questId)
  updateSceneGuideGoal()
end
local updateForceTrack = function(questId)
  local questData = Z.DataMgr.Get("quest_data")
  local isForceTrack = questData:IsForceTrackQuest(questId)
  if isForceTrack and questData:GetForceTrackId() ~= questId then
    questData:SetForceTrackId(questId)
    updateTrackingQuest()
  end
end
local switchTrackOptionalQuest = function(index, questId)
  local questData = Z.DataMgr.Get("quest_data")
  questData:SetTrackOptionalId(index, questId)
  logGreen("[quest] SetTrackOption index = {0}, questId = {1}", index, questId)
  local serverQuestId = Z.ContainerMgr.CharSerialize.questList.trackOptionalQuest[index] or 0
  if serverQuestId ~= questId then
    Z.CoroUtil.create_coro_xpcall(function()
      local worldProxy = require("zproxy.world_proxy")
      worldProxy.SetTrackOptionalQuest(index, questId)
    end)()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.TrackOptionChange, index, questId)
end
local replaceTrackOptionWithRule = function(questId)
  if questId <= 0 then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  if questData:IsForceTrackQuest(questId) then
    return
  end
  local option1 = questData:GetTrackOptionalIdByIndex(1)
  local option2 = questData:GetTrackOptionalIdByIndex(2)
  if questId == option1 or questId == option2 then
    return
  end
  local curIsMain = isMainQuest(questId)
  local option1IsMain = isMainQuest(option1)
  local replaceIndex = 0
  if option1 <= 0 and option2 <= 0 then
    replaceIndex = 1
  elseif 0 < option1 and 0 < option2 then
    local option1Order = questData:GetQuestOrder(option1)
    local option2Order = questData:GetQuestOrder(option2)
    local selectId = questData:GetSelectTrackId()
    if curIsMain then
      replaceIndex = 1
      if option1Order <= option2Order and option2 ~= selectId then
        switchTrackOptionalQuest(2, option1)
      end
    elseif option1IsMain then
      replaceIndex = 2
    else
      replaceIndex = 1
      if option1Order <= option2Order and option2 ~= selectId then
        switchTrackOptionalQuest(2, option1)
      end
    end
  elseif curIsMain then
    replaceIndex = 1
    if 0 < option1 then
      switchTrackOptionalQuest(2, option1)
    end
  elseif option1IsMain then
    replaceIndex = 2
  else
    replaceIndex = 1
    if 0 < option1 and option2 <= 0 then
      switchTrackOptionalQuest(2, option1)
    end
  end
  switchTrackOptionalQuest(replaceIndex, questId)
  updateTrackingQuest()
end
local replaceAndTrackingQuest = function(questId)
  if questId <= 0 then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  if questData:IsForceTrackQuest(questId) then
    return
  end
  questData:SetSelectTrackId(questId)
  replaceTrackOptionWithRule(questId)
  updateTrackingQuest()
end
local cancelTrackOptionByQuestId = function(questId)
  if questId <= 0 then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  local option1 = questData:GetTrackOptionalIdByIndex(1)
  local option2 = questData:GetTrackOptionalIdByIndex(2)
  if questId == option2 then
    switchTrackOptionalQuest(2, 0)
  elseif questId == option1 then
    if 0 < option2 then
      switchTrackOptionalQuest(1, option2)
      switchTrackOptionalQuest(2, 0)
    else
      switchTrackOptionalQuest(1, 0)
    end
  end
end
local cancelTrackingQuest = function(questId)
  if questId <= 0 then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  if questData:GetSelectTrackId() == questId then
    questData:SetSelectTrackId(0)
    if isMainQuest(questId) then
      questData.IsAutoTrackMainQuest = false
    end
  end
  cancelTrackOptionByQuestId(questId)
  updateTrackingQuest()
end
local autoTrackMainQuest = function()
  local questData = Z.DataMgr.Get("quest_data")
  if not questData.IsAutoTrackMainQuest or questData:GetQuestTrackingId() > 0 then
    return
  end
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  for questId, _ in pairs(questData:GetAllQuestDict()) do
    local questRow = questTbl.GetRow(questId)
    if questRow and questRow.QuestType == E.QuestType.Main then
      replaceAndTrackingQuest(questId)
      break
    end
  end
end
local getQuestAutoTrackConfig = function(questId)
  local questData = Z.DataMgr.Get("quest_data")
  if questId ~= questData:GetQuestTrackingId() then
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
    if questRow then
      local typeRow = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questRow.QuestType)
      if typeRow and typeRow.ShowQuestUI and not questData:IsForceTrackQuest(questId) then
        local autoType = typeRow.AutoTracking
        if 0 < autoType and (autoType == 1 or isQuestShowTrackBar(questId)) then
          return {
            id = questId,
            order = questData:GetQuestOrder(questId),
            autoType = autoType
          }
        end
      end
    end
  end
end
local replaceOptionWhenAutoTrack = function(replaceId)
  local questData = Z.DataMgr.Get("quest_data")
  local option1 = questData:GetTrackOptionalIdByIndex(1)
  local option2 = questData:GetTrackOptionalIdByIndex(2)
  local selectId = questData:GetSelectTrackId()
  if option2 <= 0 then
    replaceTrackOptionWithRule(replaceId)
  elseif 0 < option1 and 0 < option2 and replaceId ~= option1 and replaceId ~= option2 then
    local replaceIndex = 0
    if isMainQuest(option1) then
      replaceIndex = 2
    else
      replaceIndex = selectId == option2 and 1 or 2
    end
    if 0 < replaceIndex then
      if selectId == questData:GetTrackOptionalIdByIndex(replaceIndex) then
        questData:SetSelectTrackId(replaceId)
      end
      switchTrackOptionalQuest(replaceIndex, replaceId)
      updateTrackingQuest()
    end
  end
end
local updateQuestAutoTrack = function(srcId)
  local questData = Z.DataMgr.Get("quest_data")
  local followId = questData:GetFollowTrackQuest()
  if 0 < followId then
    return
  end
  local srcAutoType
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(srcId)
  if questRow then
    local typeRow = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questRow.QuestType)
    if typeRow then
      srcAutoType = typeRow.AutoTracking
    end
  end
  if not srcAutoType then
    return
  end
  local resultConfig
  for questId, _ in pairs(questData:GetAllQuestDict()) do
    local curConfig = getQuestAutoTrackConfig(questId)
    if curConfig then
      local isChange = false
      if not resultConfig then
        isChange = true
      elseif curConfig.order < resultConfig.order then
        isChange = true
      elseif curConfig.order == resultConfig.order and curConfig.id < resultConfig.id then
        isChange = true
      end
      if isChange then
        resultConfig = curConfig
      end
    end
  end
  if resultConfig then
    local replaceId = resultConfig.id
    if resultConfig.autoType == 1 then
      if srcAutoType == 1 then
        replaceAndTrackingQuest(replaceId)
      else
        replaceOptionWhenAutoTrack(replaceId)
      end
    elseif resultConfig.autoType == 2 then
      replaceOptionWhenAutoTrack(replaceId)
    end
  end
end
local refreshWorldQuestTrack = function(questId)
  local mapData = Z.DataMgr.Get("map_data")
  local flagData = mapData.TracingFlagData
  if flagData == nil then
    return
  end
  local mapVM = Z.VMMgr.GetVM("map")
  if flagData.QuestId == questId then
    mapVM.ClearFlagDataTrackSource(0, flagData)
    if checkIsAllowReplaceTrack(true) then
      replaceAndTrackingQuest(questId)
    end
    return
  end
end
local afterSelectTrackQuestInView = function()
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questData:GetQuestTrackingId())
  if not quest then
    return
  end
  local questVM = Z.VMMgr.GetVM("quest")
  local goalIndex = questVM.GetUncompletedGoalIndex(quest.id)
  local trackData = questData:GetGoalTrackData(quest.stepId, goalIndex)
  if trackData then
    local toSceneId = trackData.toSceneId
    local curSceneId = Z.StageMgr.GetCurrentSceneId()
    if toSceneId ~= curSceneId then
      if false then
        local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
        gotoFuncVM.GoToFunc(E.FunctionID.Map, toSceneId)
      else
        local isNeighbour = false
        local row = Z.TableMgr.GetTable("NeighbouringSceneTableMgr").GetRow(curSceneId, true)
        if row then
          for _, id in ipairs(row.NeighbouringScene) do
            if toSceneId == id then
              isNeighbour = true
              break
            end
          end
        end
        if not isNeighbour then
          local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(toSceneId)
          if sceneRow then
            local param = {
              str = sceneRow.Name
            }
            Z.TipsVM.ShowTipsLang(140301, param)
          end
        end
      end
    else
      local guideVM = Z.VMMgr.GetVM("goal_guide")
      local tbl = guideVM.GetLevelTableByPosType(trackData.posType)
      if tbl then
        local row = tbl.GetRow(trackData.uid)
        if row and row.VisualLayerId and row.VisualLayerId ~= Z.World.VisualLayer then
          Z.TipsVM.ShowTipsLang(140202)
        end
      end
    end
  end
end
local onQuestEnd = function(questId, isFinish)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if not questRow then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  local trackingId = questData:GetQuestTrackingId()
  cancelTrackOptionByQuestId(questId)
  if questData:GetSelectTrackId() == questId then
    questData:SetSelectTrackId(0)
  end
  if questData:GetForceTrackId() == questId then
    questData:SetForceTrackId(0)
  end
  if trackingId == questId and isFinish and 0 < questRow.FollowQuest then
    questData:SetFollowTrackQuest(questRow.FollowQuest)
  end
  if not questData:IsForceTrackQuest(questId) then
    local isNeedAutoTrack = false
    if not isFinish then
      local option1 = questData:GetTrackOptionalIdByIndex(1)
      local option2 = questData:GetTrackOptionalIdByIndex(2)
      if option1 <= 0 and option2 <= 0 then
        isNeedAutoTrack = true
      end
    else
      isNeedAutoTrack = true
    end
    if isNeedAutoTrack then
      updateQuestAutoTrack(questId)
    end
  end
  updateTrackingQuest()
end
local onAcceptQuest = function(questId)
  updateForceTrack(questId)
  local questData = Z.DataMgr.Get("quest_data")
  local followId = questData:GetFollowTrackQuest()
  if 0 < followId then
    if followId == questId then
      questData:SetFollowTrackQuest(0)
      replaceAndTrackingQuest(questId)
    end
  else
    if not questData:IsForceTrackQuest(questId) then
      updateQuestAutoTrack(questId)
    end
    refreshWorldQuestTrack(questId)
  end
end
local onEnterScene = function()
  local questData = Z.DataMgr.Get("quest_data")
  local selectId = 0
  local optionIdList = {0, 0}
  if not questData.IsLoginFinish then
    selectId = Z.ContainerMgr.CharSerialize.questList.trackingId
    for i = 1, 2 do
      optionIdList[i] = Z.ContainerMgr.CharSerialize.questList.trackOptionalQuest[i] or 0
    end
  else
    selectId = questData:GetSelectTrackId()
    for i = 1, 2 do
      optionIdList[i] = questData:GetTrackOptionalIdByIndex(i)
    end
  end
  if 0 < selectId and not questData:GetQuestByQuestId(selectId) then
    selectId = 0
  end
  questData:SetSelectTrackId(selectId)
  questData:SetFollowTrackQuest(0)
  for i = 1, #optionIdList do
    if not questData:GetQuestByQuestId(optionIdList[i]) then
      optionIdList[i] = 0
    end
  end
  if optionIdList[1] == 0 and optionIdList[2] ~= 0 then
    optionIdList[1] = optionIdList[2]
    optionIdList[2] = 0
  end
  if not isMainQuest(optionIdList[1]) and isMainQuest(optionIdList[2]) then
    local option = optionIdList[1]
    optionIdList[1] = optionIdList[2]
    optionIdList[2] = option
  end
  for i = 1, #optionIdList do
    switchTrackOptionalQuest(i, optionIdList[i])
  end
  local questDict = questData:GetAllQuestDict()
  questData:SetForceTrackId(0)
  for questId, _ in pairs(questDict) do
    updateForceTrack(questId)
  end
  autoTrackMainQuest()
  updateTrackingQuest()
  updateSceneGuideGoal()
  Z.EventMgr:Dispatch(Z.ConstValue.UpdateAllTargetView)
end
local onLeaveScene = function()
  updateTrackingQuest()
end
local ret = {
  OnEnterScene = onEnterScene,
  OnLeaveScene = onLeaveScene,
  OnAcceptQuest = onAcceptQuest,
  OnQuestEnd = onQuestEnd,
  IsQuestShowTrackBar = isQuestShowTrackBar,
  UpdateSceneGuideGoal = updateSceneGuideGoal,
  RefreshQuestGuideEffectVisible = refreshQuestGuideEffectVisible,
  SetQuestGuideEffectVisible = setQuestGuideEffectVisible,
  ReplaceAndTrackingQuest = replaceAndTrackingQuest,
  CancelTrackingQuest = cancelTrackingQuest,
  AfterSelectTrackQuestInView = afterSelectTrackQuestInView,
  CheckIsAllowReplaceTrack = checkIsAllowReplaceTrack
}
return ret
