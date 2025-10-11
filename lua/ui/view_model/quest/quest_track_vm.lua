local isQuestShowTrackBar = function(questId)
  local isVisible = false
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if questData:IsQuestAccessNotEnough(quest) then
    return false
  end
  if quest then
    local stepRow = questData:GetStepConfigByStepId(quest.stepId)
    if stepRow and not stepRow.HideTrackBar and (#stepRow.StepTargetInfo > 0 or stepRow.StepMainTitle ~= "") then
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
local canAdvanceQuest = function(questId)
  local questLimitVm = Z.VMMgr.GetVM("quest_limit")
  if questId <= 0 then
    return true
  end
  return questLimitVm.IsQuestCanBeAdvance(questId)
end
local checkIsAllowReplaceTrack = function(isShowTips)
  local questData = Z.DataMgr.Get("quest_data")
  local questVm = Z.VMMgr.GetVM("quest")
  if questData:IsInForceTrack() then
    if isShowTips then
      local questId = questData:GetForceTrackId()
      local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
      if questRow then
        local param = {
          str = questVm.GetQuestName(questRow.QuestId)
        }
        Z.TipsVM.ShowTipsLang(140201, param)
      end
    end
    return false
  end
  return true
end
local updateTrackingQuest = function()
  local questIconVM = Z.VMMgr.GetVM("quest_icon")
  local questData = Z.DataMgr.Get("quest_data")
  local questGoalGuideVm = Z.VMMgr.GetVM("quest_goal_guide")
  questGoalGuideVm.UpdateSceneGuideGoal()
  local questId = questData:GetQuestTrackingId()
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.TrackingIdChange, questId, questData.LastTrackingId)
  Z.QuestMgr:OnTrackedQuestChanged(questId)
  if questId == questData.LastTrackingId then
    return
  end
  local quest = questData:GetQuestByQuestId(questId)
  local stepId = quest and quest.stepId or 0
  logGreen("[quest] SetQuestTrackingId questId = {0}, stepId = {1}", questId, stepId)
  questData.LastTrackingId = questId
  questIconVM.UpdateAllNpcHudQuest()
  Z.RedCacheContainer:GetQuestRed().CloseQuestRed(questId)
end
local updateForceTrack = function(questId)
  local questData = Z.DataMgr.Get("quest_data")
  local questTrackData = Z.DataMgr.Get("quest_track_data")
  local isForceTrack = questData:IsForceTrackQuest(questId)
  if isForceTrack and questData:GetForceTrackId() ~= questId then
    questData:SetForceTrackId(questId)
    questTrackData:SetProactiveQuestId(0)
    updateTrackingQuest()
    return true
  end
  return false
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
end
local handleSingleOptionValid = function(questId, option1, isMain, opt1IsMain, isProactive, opt1CanAdvance, questData)
  local opt1Valid = 0 < option1
  if isMain then
    if opt1Valid then
      switchTrackOptionalQuest(2, option1)
    end
    return 1
  elseif opt1IsMain then
    return not (not isProactive or opt1CanAdvance) and 1 or 2
  else
    if opt1Valid then
      switchTrackOptionalQuest(2, option1)
    end
    return 1
  end
end
local handleBothOptionsValid = function(questId, option1, option2, isMain, opt1IsMain, isProactive, opt1CanAdvance, questData)
  local option1Order = questData:GetQuestOrder(option1)
  local option2Order = questData:GetQuestOrder(option2)
  local selectId = questData:GetSelectTrackId()
  if isMain then
    if option1Order <= option2Order and option2 ~= selectId then
      switchTrackOptionalQuest(2, option1)
    end
    return 1
  elseif opt1IsMain then
    return not (not isProactive or opt1CanAdvance) and 1 or 2
  else
    if option1Order <= option2Order and option2 ~= selectId then
      switchTrackOptionalQuest(2, option1)
    end
    return 1
  end
end
local getReplaceIndex = function(questId, option1, option2, isProactive, questData)
  local isMain = isMainQuest(questId)
  local opt1IsMain = isMainQuest(option1)
  local opt1CanAdvance = canAdvanceQuest(option1)
  local opt1Valid = 0 < option1
  local opt2Valid = 0 < option2
  if not opt1Valid and not opt2Valid then
    return 1
  end
  if opt1Valid and opt2Valid then
    return handleBothOptionsValid(questId, option1, option2, isMain, opt1IsMain, isProactive, opt1CanAdvance, questData)
  else
    return handleSingleOptionValid(questId, option1, isMain, opt1IsMain, isProactive, opt1CanAdvance, questData)
  end
end
local isQuestTrackReplaceable = function(questId, questData)
  if questId <= 0 then
    return false
  end
  if questData:IsForceTrackQuest(questId) then
    return false
  end
  local option1 = questData:GetTrackOptionalIdByIndex(1)
  local option2 = questData:GetTrackOptionalIdByIndex(2)
  if questId == option1 or questId == option2 then
    return false
  end
  return true
end
local replaceTrackOptionWithRule = function(questId)
  local questData = Z.DataMgr.Get("quest_data")
  local questTrackData = Z.DataMgr.Get("quest_track_data")
  local isProactive = questTrackData:GetProactiveQuestId() == questId
  questTrackData:SetProactiveQuestId(0)
  if not isQuestTrackReplaceable(questId, questData) then
    return
  end
  local option1 = questData:GetTrackOptionalIdByIndex(1)
  local option2 = questData:GetTrackOptionalIdByIndex(2)
  local replaceIndex = getReplaceIndex(questId, option1, option2, isProactive, questData)
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
local checkIsNeighbouringScene = function(curSceneId, toSceneId)
  local row = Z.TableMgr.GetTable("NeighbouringSceneTableMgr").GetRow(curSceneId, true)
  if not row then
    return false
  end
  for _, id in ipairs(row.NeighbouringScene) do
    if toSceneId == id then
      return true
    end
  end
  return false
end
local playTrackEffectAndDispatch = function(questId)
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.ClickTrackBar)
  Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnClickChangeGuideQuestId, questId)
end
local handleSameScene = function(trackData, questId)
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  if not guideVM then
    return
  end
  local tbl = guideVM.GetLevelTableByPosType(trackData.posType)
  if not tbl then
    return
  end
  local row = tbl.GetRow(trackData.uid)
  if row and row.VisualLayerId and row.VisualLayerId ~= Z.World.VisualLayer then
    Z.TipsVM.ShowTipsLang(140202)
    return
  end
  playTrackEffectAndDispatch(questId)
end
local handleNeighbourScene = function(questId)
  playTrackEffectAndDispatch(questId)
end
local handleRemoteScene = function(trackData)
  local miniMapVM = Z.VMMgr.GetVM("minimap")
  if not miniMapVM then
    return
  end
  local toSceneId = trackData.toSceneId
  if miniMapVM.CheckSceneID(toSceneId, true) then
    miniMapVM.OpenEnlargedminimap(toSceneId)
  else
    local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(toSceneId)
    local sceneName = sceneRow and sceneRow.Name or ""
    local param = {str = sceneName}
    Z.TipsVM.ShowTipsLang(140203, param)
  end
end
local checkGoalIsInCurScene = function(stepRow, questId)
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  if not stepRow or not questId then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  local questGoalVM = Z.VMMgr.GetVM("quest_goal")
  for goalIdx = 1, #stepRow.StepParam do
    local trackData = questData:GetGoalTrackData(stepRow.StepId, goalIdx)
    if trackData and not questGoalVM.IsGoalCompleted(stepRow.StepId, goalIdx) then
      if trackData.toSceneId == curSceneId then
        handleSameScene(trackData, questId)
      elseif checkIsNeighbouringScene(curSceneId, trackData.toSceneId) then
        handleNeighbourScene(questId)
      else
        handleRemoteScene(trackData)
      end
    end
  end
end
local handleWorldquestTrack = function(questId)
  local worldQuestVM = Z.VMMgr.GetVM("worldquest")
  worldQuestVM.OpenWorldQuestWorldMap()
  playTrackEffectAndDispatch(questId)
end
local handleGotoFunc = function(stepRow)
  if not stepRow then
    return false
  end
  local funcId = stepRow.QuestClickJump
  if funcId and 0 < funcId then
    local gotoVM = Z.VMMgr.GetVM("gotofunc")
    if gotoVM then
      gotoVM.GoToFunc(funcId)
      return true
    end
  end
  return false
end
local onTrackBtnClick = function(questId)
  if not questId then
    logError("[Quest] Invalid questId in onTrackBtnClick!")
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  if not questData then
    return
  end
  logGreen("[Quest] onTrackBtnClick questId = {0}", questId)
  if questData:GetQuestTrackingId() ~= questId then
    replaceAndTrackingQuest(questId)
  end
  if questId == Z.Global.WorldEventQuestId then
    handleWorldquestTrack(questId)
    return
  end
  local stepRow = questData:GetStepConfigByQuestId(questId)
  if not stepRow then
    logWarning("[Quest] No step config found for questId: {0}", questId)
    return
  end
  if stepRow.StepTips ~= "" then
    Z.TipsVM.OpenMessageViewByContext(stepRow.StepTips, E.TipsType.MiddleTips)
  end
  if not handleGotoFunc(stepRow) then
    checkGoalIsInCurScene(stepRow, questId)
  end
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
  local questTimeLimitVM = Z.VMMgr.GetVM("quest_time_limit")
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local allQuest = questData:GetAllQuestDict()
  for questId, quest in pairs(allQuest) do
    local questRow = questTbl.GetRow(questId)
    if questRow and questRow.QuestType == E.QuestType.Main and not questTimeLimitVM.IsTimeLimitStepByStepId(quest.stepId) then
      replaceAndTrackingQuest(questId)
      return true
    end
  end
  return false
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
  local questGoalVM = Z.VMMgr.GetVM("quest_goal")
  local goalIndex = questGoalVM.GetUncompletedGoalIndex(quest.id)
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
local checkCanSetProactiveId = function(questId)
  local questData = Z.DataMgr.Get("quest_data")
  local questTrackData = Z.DataMgr.Get("quest_track_data")
  local questVm = Z.VMMgr.GetVM("quest")
  questTrackData:SetProactiveQuestId(0)
  if questData:IsInForceTrack() or questVm.IsHiddenQuest(questId) then
    return false
  end
  return true
end
local setProactiveByQuestStepId = function(stepId)
  local questTrackData = Z.DataMgr.Get("quest_track_data")
  if stepId == nil or stepId == 0 then
    questTrackData:SetProactiveQuestId(0)
    return false
  end
  local questId = stepId // 1000
  if questId <= 0 then
    return false
  end
  if not checkCanSetProactiveId(questId) then
    return false
  end
  local questData = Z.DataMgr.Get("quest_data")
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if not stepRow or not stepRow.IsProactiveStep then
    return false
  end
  questTrackData:SetProactiveQuestId(questId)
  return true
end
local setProactiveByQuestId = function(questId)
  if not checkCanSetProactiveId(questId) then
    return false
  end
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if not questRow then
    return
  end
  local questTrackData = Z.DataMgr.Get("quest_track_data")
  local accessLimits = questRow.AccessLimit
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  if accessLimits ~= nil and next(accessLimits) ~= nil then
    for index, accessLimit in ipairs(accessLimits) do
      local acceptLimitType = tonumber(accessLimit[1])
      local acceptLimitValue = tonumber(accessLimit[2])
      if acceptLimitType == 12 and curSceneId == acceptLimitValue then
        questTrackData:SetProactiveQuestId(questId)
        return true
      end
    end
  end
  local acceptType = questRow.AcceptType
  if acceptType ~= nil then
    local type = acceptType[1]
    if type and type == 1 then
      questTrackData:SetProactiveQuestId(questId)
      return true
    end
  end
  return false
end
local onAcceptQuest = function(questId)
  if updateForceTrack(questId) then
    return
  end
  local questData = Z.DataMgr.Get("quest_data")
  local followId = questData:GetFollowTrackQuest()
  if 0 < followId then
    if followId == questId then
      questData:SetFollowTrackQuest(0)
      replaceAndTrackingQuest(questId)
    end
  else
    if not questData:IsForceTrackQuest(questId) then
      local questTrackData = Z.DataMgr.Get("quest_track_data")
      if questTrackData:GetProactiveQuestId() == questId then
        replaceAndTrackingQuest(questId)
      else
        updateQuestAutoTrack(questId)
      end
    end
    refreshWorldQuestTrack(questId)
  end
end
local getInitialTrackIds = function()
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
  return selectId, optionIdList
end
local validateTrackIds = function(selectId, optionIdList)
  local questData = Z.DataMgr.Get("quest_data")
  if 0 < selectId and not questData:GetQuestByQuestId(selectId) then
    selectId = 0
  end
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
    optionIdList[1], optionIdList[2] = optionIdList[2], optionIdList[1]
  end
  return selectId, optionIdList
end
local applyTrackState = function(selectId, optionIdList)
  local questData = Z.DataMgr.Get("quest_data")
  questData:SetSelectTrackId(selectId)
  questData:SetFollowTrackQuest(0)
  for i = 1, #optionIdList do
    switchTrackOptionalQuest(i, optionIdList[i])
  end
end
local updateForceTrackedQuests = function()
  local questData = Z.DataMgr.Get("quest_data")
  local questDict = questData:GetAllQuestDict()
  questData:SetForceTrackId(0)
  for questId, _ in pairs(questDict) do
    updateForceTrack(questId)
  end
end
local tryTrackProactiveQuest = function()
  local questTrackData = Z.DataMgr.Get("quest_track_data")
  local proactiveQuestId = questTrackData:GetProactiveQuestId()
  local questData = Z.DataMgr.Get("quest_data")
  if 0 < proactiveQuestId and questData:GetQuestTrackingId() ~= proactiveQuestId then
    if questData:GetQuestTrackingId() == proactiveQuestId then
      questTrackData:SetProactiveQuestId(0)
    else
      onAcceptQuest(proactiveQuestId)
    end
    return true
  end
  return autoTrackMainQuest()
end
local onEnterScene = function()
  local selectId, optionIdList = getInitialTrackIds()
  selectId, optionIdList = validateTrackIds(selectId, optionIdList)
  applyTrackState(selectId, optionIdList)
  updateForceTrackedQuests()
  local isNotNeedUpdate = tryTrackProactiveQuest()
  if not isNotNeedUpdate then
    updateTrackingQuest()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.UpdateAllTargetView)
end
local onLeaveScene = function()
end
local ret = {
  OnEnterScene = onEnterScene,
  OnLeaveScene = onLeaveScene,
  OnAcceptQuest = onAcceptQuest,
  OnQuestEnd = onQuestEnd,
  IsQuestShowTrackBar = isQuestShowTrackBar,
  ReplaceAndTrackingQuest = replaceAndTrackingQuest,
  CancelTrackingQuest = cancelTrackingQuest,
  AfterSelectTrackQuestInView = afterSelectTrackQuestInView,
  CheckIsAllowReplaceTrack = checkIsAllowReplaceTrack,
  OnTrackBtnClick = onTrackBtnClick,
  SetProactiveByQuestId = setProactiveByQuestId,
  SetProactiveByQuestStepId = setProactiveByQuestStepId,
  HandleRemoteScene = handleRemoteScene
}
return ret
