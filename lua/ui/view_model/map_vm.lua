local worldProxy = require("zproxy.world_proxy")
local uidToUuidOfEntFlag = function(type, uid, isClient)
  local entityVM = Z.VMMgr.GetVM("entity")
  return entityVM.EntIdToUuid(uid, type, false, isClient)
end
local uidToUuidOfNoneEntFlag = function(id, type, uid, isQuest)
  local intQuest = isQuest and 1 or 0
  return id + (intQuest << 28 | type:ToInt() << 29 | uid << 32)
end
local getGlobalInfo = function(sceneId, posType, uid)
  if sceneId <= 0 then
    return
  end
  local flagDataId, levelTableType
  if posType == Z.GoalPosType.Point then
    flagDataId = uidToUuidOfNoneEntFlag(uid, posType, uid, false)
    levelTableType = E.LevelTableType.Point
  elseif posType == Z.GoalPosType.Npc then
    levelTableType = E.LevelTableType.Npc
  elseif posType == Z.GoalPosType.Monster then
    levelTableType = E.LevelTableType.Monster
  elseif posType == Z.GoalPosType.Zone then
    levelTableType = E.LevelTableType.Zone
  elseif posType == Z.GoalPosType.SceneObject then
    levelTableType = E.LevelTableType.SceneObject
  end
  if not levelTableType then
    return
  end
  local globalCfg = Z.TableMgr.GetLevelTableRow(levelTableType, sceneId, uid)
  if globalCfg then
    if flagDataId == nil then
      local entType = Z.GoalGuideMgr.PosTypeToEntType(posType)
      if posType == Z.GoalPosType.Point or posType == Z.GoalPosType.Monster then
        flagDataId = uidToUuidOfEntFlag(entType, uid, false)
      else
        flagDataId = uidToUuidOfEntFlag(entType, uid, globalCfg.SourceType == 1)
      end
    end
    return globalCfg, flagDataId
  end
end
local zoneOptionDataToTable = function(dataStr)
  local tbl = load("return " .. dataStr)()
  if type(tbl) ~= "table" then
    return
  end
  if tbl.IconId then
    tbl.IconId = tonumber(tbl.IconId)
  end
  if tbl.PointId then
    tbl.PointId = tonumber(tbl.PointId)
  end
  return tbl
end
local createEntityMapFlagData = function(uid, type, isClient, typeId, pos, subType)
  local unionVM = Z.VMMgr.GetVM("union")
  local flagData = {}
  flagData.Id = uidToUuidOfEntFlag(type, uid, isClient)
  flagData.Uid = uid
  flagData.Type = type
  flagData.SubType = subType
  flagData.FlagType = E.MapFlagType.Entity
  flagData.TypeId = typeId
  local sceneTagTbl = Z.TableMgr.GetTable("SceneTagTableMgr")
  local scenceData = sceneTagTbl.GetRow(typeId)
  if scenceData then
    if typeId == E.SceneTagId.UnionEnter and unionVM:CheckCanEnterUnionScene() then
      flagData.IconPath = scenceData.Icon2
    else
      flagData.IconPath = scenceData.Icon1
    end
    flagData.Pos = pos and Vector3.New(pos[1], pos[2], pos[3])
  end
  return flagData
end
local openFunc = function(tagId)
  if not tagId or tagId == 0 then
    return false
  end
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  local sceneTagTbl = Z.TableMgr.GetTable("SceneTagTableMgr")
  local data = sceneTagTbl.GetRow(tagId)
  if data and data.FunctionId then
    if data.FunctionId == 0 then
      return true
    elseif funcVm.CheckFuncCanUse(data.FunctionId, true) then
      return true
    end
  end
  return false
end
local checkTransferPointUnlock = function(transferPointId)
  local cfg = Z.TableMgr.GetTable("TransferTableMgr").GetRow(transferPointId)
  if cfg and cfg.IsOn then
    return true
  end
  return Z.ContainerMgr.CharSerialize.transferPoint.points[transferPointId] ~= nil
end
local loadWorldQuestEntityFlagData = function(curSceneId)
  local ret = {}
  local worldQuestData = Z.DataMgr.Get("worldquest_data")
  if worldQuestData.AcceptWorldQuest == false then
    return ret
  end
  local entNpcObjType = Z.PbEnum("EEntityType", "EntNpc")
  local entSceneObjType = Z.PbEnum("EEntityType", "EntSceneObject")
  local sceneTagTableMgr = Z.TableMgr.GetTable("SceneTagTableMgr")
  local dailyWorldEventMgr = Z.TableMgr.GetTable("DailyWorldEventTableMgr")
  local allFinished = true
  for _, v in pairs(Z.ContainerMgr.CharSerialize.worldEventMap.eventMap) do
    if v.award ~= 1 then
      allFinished = false
      break
    end
  end
  if not allFinished then
    for k, v in pairs(Z.ContainerMgr.CharSerialize.worldEventMap.eventMap) do
      local eventInfo = dailyWorldEventMgr.GetRow(v.id)
      if eventInfo then
        local entityType = eventInfo.Entity[1]
        local entityUId = eventInfo.Entity[2]
        if entityType == entNpcObjType and curSceneId == eventInfo.Scene then
          local npcRow = Z.TableMgr.GetLevelTableRow(E.LevelTableType.Npc, curSceneId, entityUId)
          if npcRow then
            local isClient = npcRow.SourceType == 1
            local data = createEntityMapFlagData(entityUId, entNpcObjType, isClient, Z.Global.WorldEventSceneTagIcon, npcRow.Position, E.SceneObjType.WorldQuest)
            if v.award == 1 then
              local scenceData = sceneTagTableMgr.GetRow(Z.Global.WorldEventSceneTagIcon)
              data.IconPath = scenceData.Icon2
            end
            data.Name = eventInfo.Name
            table.insert(ret, data)
          end
        elseif entityType == entSceneObjType and curSceneId == eventInfo.Scene then
          local sceneObjectRow = Z.TableMgr.GetLevelTableRow(E.LevelTableType.SceneObject, curSceneId, entityUId)
          if sceneObjectRow then
            local isClient = sceneObjectRow.SourceType == 1
            local data = createEntityMapFlagData(entityUId, entSceneObjType, isClient, Z.Global.WorldEventSceneTagIcon, sceneObjectRow.Position, E.SceneObjType.WorldQuest)
            if v.award == 1 then
              local scenceData = sceneTagTableMgr.GetRow(Z.Global.WorldEventSceneTagIcon)
              data.IconPath = scenceData.Icon2
            end
            data.Name = eventInfo.Name
            table.insert(ret, data)
          end
        end
      end
    end
  end
  return ret
end
local loadZoneEntityTableData = function(ret, curSceneId)
  local entZoneObjType = Z.PbEnum("EEntityType", "EntZone")
  local rowDict = Z.TableMgr.GetLevelTableDatas(E.LevelTableType.Zone, curSceneId)
  for uid, row in pairs(rowDict) do
    if row.OptionData and row.OptionData ~= "" then
      local config = zoneOptionDataToTable(row.OptionData)
      if config then
        local typeId = config.IconId
        if openFunc(typeId) then
          local isClient = row.SourceType == 1
          local data = createEntityMapFlagData(uid, entZoneObjType, isClient, typeId, row.Position)
          data.TpPointId = config.PointId
          table.insert(ret, data)
        end
      else
        logError("[Map] ZoneEntityTable OptionData\233\133\141\231\189\174\233\148\153\232\175\175, uid = {0}, sceneId = {1}", uid, curSceneId)
      end
    end
  end
end
local loadNpcEntityTableData = function(ret, curSceneId)
  local entNpcObjType = Z.PbEnum("EEntityType", "EntNpc")
  local npcTableMgr = Z.TableMgr.GetTable("NpcTableMgr")
  local worldQuestData = Z.DataMgr.Get("worldquest_data")
  local rowDict = Z.TableMgr.GetLevelTableDatas(E.LevelTableType.Npc, curSceneId)
  for uid, row in pairs(rowDict) do
    if worldQuestData:CheckIsWorldQuestEntity(uid) == false then
      local npcId = row.Id
      local npcRow = npcTableMgr.GetRow(npcId)
      if npcRow then
        local typeId = npcRow.SceneTagId
        if 0 < typeId and openFunc(typeId) then
          local isClient = row.SourceType == 1
          local data = createEntityMapFlagData(uid, entNpcObjType, isClient, typeId, row.Position)
          table.insert(ret, data)
        end
      end
    end
  end
end
local loadSceneEntityTableData = function(ret, curSceneId, targetIdDict)
  local entSceneObjType = Z.PbEnum("EEntityType", "EntSceneObject")
  local sceneObjectTableMgr = Z.TableMgr.GetTable("SceneObjectTableMgr")
  local sceneTagTableMgr = Z.TableMgr.GetTable("SceneTagTableMgr")
  local transferTableMgr = Z.TableMgr.GetTable("TransferTableMgr")
  local environmentResonanceTableMgr = Z.TableMgr.GetTable("EnvironmentResonanceTableMgr")
  local worldQuestData = Z.DataMgr.Get("worldquest_data")
  local rowDict = Z.TableMgr.GetLevelTableDatas(E.LevelTableType.SceneObject, curSceneId)
  for uid, row in pairs(rowDict) do
    if (targetIdDict == nil or targetIdDict[row.Id] ~= nil) and worldQuestData:CheckIsWorldQuestEntity(uid) == false then
      local sceneObjId = row.Id
      local sceneObjData = sceneObjectTableMgr.GetRow(sceneObjId)
      if sceneObjData then
        if sceneObjData.SceneObjType == E.SceneObjType.Pivot then
          local transferTableRow = transferTableMgr.GetRow(sceneObjId)
          if transferTableRow then
            local typeId = transferTableRow.SceneTag
            if openFunc(typeId) then
              local isClient = row.SourceType == 1
              local data = createEntityMapFlagData(uid, entSceneObjType, isClient, typeId, row.Position, E.SceneObjType.Pivot)
              local pivotVm = Z.VMMgr.GetVM("pivot")
              if pivotVm.CheckPivotUnlock(sceneObjId) == false then
                local scenceData = sceneTagTableMgr.GetRow(typeId)
                data.IconPath = scenceData.Icon2
              end
              data.TpPointId = transferTableRow.Id
              table.insert(ret, data)
            end
          end
        elseif sceneObjData.SceneObjType == E.SceneObjType.Transfer then
          local transferTableRow = transferTableMgr.GetRow(sceneObjId)
          if transferTableRow then
            local pivotVm = Z.VMMgr.GetVM("pivot")
            local typeId = transferTableRow.SceneTag
            local pivotUnlock = pivotVm.IsTransferAreaUnlock(transferTableRow.Id)
            local transferUnlock = checkTransferPointUnlock(sceneObjId)
            if openFunc(typeId) and (pivotUnlock or transferUnlock) then
              local isClient = row.SourceType == 1
              local data = createEntityMapFlagData(uid, entSceneObjType, isClient, typeId, row.Position, E.SceneObjType.Transfer)
              if checkTransferPointUnlock(sceneObjId) == false then
                local scenceData = sceneTagTableMgr.GetRow(typeId)
                data.IconPath = scenceData.Icon2
              end
              data.TpPointId = transferTableRow.Id
              table.insert(ret, data)
            end
          end
        elseif sceneObjData.SceneObjType == E.SceneObjType.Resonance then
          local envResonanceTblBase = environmentResonanceTableMgr.GetRow(sceneObjId)
          if envResonanceTblBase then
            local typeId = envResonanceTblBase.SceneTag
            if openFunc(typeId) then
              local isClient = row.SourceType == 1
              local data = createEntityMapFlagData(uid, entSceneObjType, isClient, typeId, row.Position, E.SceneObjType.Resonance)
              table.insert(ret, data)
            end
          end
        elseif row.OptionData and row.OptionData ~= "" then
          local config = zoneOptionDataToTable(row.OptionData)
          if config then
            local typeId = config.IconId
            if openFunc(typeId) then
              local isClient = row.SourceType == 1
              local data = createEntityMapFlagData(uid, entSceneObjType, isClient, typeId, row.Position)
              data.TpPointId = config.PointId
              table.insert(ret, data)
            end
          else
            logError("[Map] SceneObjectEntityTable OptionData\233\133\141\231\189\174\233\148\153\232\175\175, uid = {0}, sceneId = {1}", uid, curSceneId)
          end
        end
      end
    end
  end
end
local loadEntityTableData = function(curSceneId)
  local ret = {}
  loadZoneEntityTableData(ret, curSceneId)
  loadNpcEntityTableData(ret, curSceneId)
  loadSceneEntityTableData(ret, curSceneId)
  return ret
end
local getTeamFlagDataBySceneId = function(sceneId)
  local dataList = {}
  local teamData = Z.DataMgr.Get("team_data")
  local teamInfo = teamData.TeamInfo.baseInfo
  if not teamInfo.teamId or teamInfo.teamId == 0 then
    return dataList
  end
  local teamVm = Z.VMMgr.GetVM("team")
  local members = teamVm.GetTeamMemData()
  for index, mem in ipairs(members) do
    local socialData = mem.socialData
    if not mem.isAi and socialData.basicData.charID ~= Z.ContainerMgr.CharSerialize.charBase.charId and socialData and socialData.basicData.sceneId == sceneId and socialData.sceneData then
      local typeId = mem.charId == teamInfo.leaderId and 102 or 106
      local data = createEntityMapFlagData(socialData.basicData.charID, Z.PbEnum("EEntityType", "EntChar"), false, typeId)
      data.Pos = Vector3.New(socialData.sceneData.levelPos.x, socialData.sceneData.levelPos.y, socialData.sceneData.levelPos.z)
      data.CharId = socialData.basicData.charID
      data.Name = socialData.basicData.name
      data.SocialData = socialData
      data.IsTeam = true
      data.TeamIndex = index
      table.insert(dataList, data)
    end
  end
  return dataList
end
local createQuestMapFlagData = function(sceneId, questId, uid, posType)
  if uid == nil or uid <= 0 then
    logError("[CreateQuestMapFlagData] the uid is invalid, the questId = {0}, sceneId = {1}", questId, sceneId)
    return
  end
  local levelRow, flagDataId = getGlobalInfo(sceneId, posType, uid)
  if not levelRow then
    return
  end
  local entLayer = levelRow.VisualLayerId
  if entLayer and sceneId == Z.StageMgr.GetCurrentSceneId() and entLayer ~= Z.World.VisualLayer then
    return
  end
  local questVM = Z.VMMgr.GetVM("quest")
  local questIcon = questVM.GetQuestIconInScene(questId)
  if not questIcon or questIcon == "" then
    return
  end
  local flagData = {}
  flagData.Id = flagDataId
  flagData.Uid = uid
  flagData.Type = Z.GoalGuideMgr.PosTypeToEntType(posType)
  flagData.TypeId = E.SceneTagId.Quest
  flagData.QuestId = questId
  flagData.IconPath = questIcon
  if posType == Z.GoalPosType.Point then
    flagData.FlagType = E.MapFlagType.NotEntity
  elseif posType == Z.GoalPosType.Zone then
    flagData.FlagType = E.MapFlagType.Entity
    flagData.RangeDiameter = levelRow.ZoneParam[1]
  else
    flagData.FlagType = E.MapFlagType.Entity
  end
  local posArray = levelRow.Position
  flagData.Pos = Vector3.New(posArray[1], posArray[2], posArray[3])
  return flagData
end
local isQuestGoalShow = function(questId, goalIndex)
  local questVM = Z.VMMgr.GetVM("quest")
  if questVM.IsGoalCompleted(questId, goalIndex) then
    return false
  end
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return false
  end
  local stepId = quest.stepId
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if stepRow then
    if stepRow.StepTargetType == E.QuestGoalGroupType.Serial then
      for i = 1, goalIndex - 1 do
        if not questVM.IsGoalCompleted(questId, i) then
          return false
        end
      end
      return true
    else
      return true
    end
  end
end
local createQuestGoalMapFlagDataList = function(questId, sceneId, isBigMap)
  local dataList = {}
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return {}
  end
  local cfg = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  local configDataList = {}
  local questLimitRange = false
  if quest and isBigMap == false and #cfg.ContinueLimit > 0 then
    for _, limitData in ipairs(cfg.ContinueLimit) do
      if tonumber(limitData[1]) == Z.PbEnum("EAccessType", "AccessEnterZone") then
        table.insert(configDataList, {
          posType = Z.GoalPosType.Zone,
          uid = tonumber(limitData[2])
        })
        questLimitRange = true
        break
      end
    end
  end
  if questLimitRange == false then
    local stepId = quest.stepId
    local stepRow = questData:GetStepConfigByStepId(stepId)
    if not stepRow then
      return dataList
    end
    local goalNum = #stepRow.StepTargetPos
    if goalNum <= 0 then
      return dataList
    end
    for goalIndex = 1, goalNum do
      local toSceneId = tonumber(stepRow.StepParam[goalIndex][3])
      if toSceneId <= 0 then
        toSceneId = stepRow.StepTrackedSceneId[goalIndex] or 0
      end
      local goalPosArray = stepRow.StepTargetPos[goalIndex]
      local posType = Z.GoalPosType.IntToEnum(tonumber(goalPosArray[1]))
      local uid = tonumber(goalPosArray[2])
      if isQuestGoalShow(questId, goalIndex) then
        if sceneId == toSceneId then
          if posType ~= Z.GoalPosType.None and posType ~= Z.GoalPosType.Npc then
            table.insert(configDataList, {posType = posType, uid = uid})
          end
        elseif sceneId == Z.StageMgr.GetCurrentSceneId() then
          local zoneUid = Z.GoalGuideMgr:GetTpZoneUidBetweenScene(sceneId, toSceneId)
          if 0 < zoneUid then
            table.insert(configDataList, {
              posType = Z.GoalPosType.Zone,
              uid = zoneUid
            })
          end
        end
      end
    end
  end
  for _, configData in ipairs(configDataList) do
    local flagData = createQuestMapFlagData(sceneId, questId, configData.uid, configData.posType)
    if flagData then
      table.insert(dataList, flagData)
    end
  end
  return dataList
end
local getQuestGoalFlagDataBySceneId = function(sceneId, isBigMap)
  local questData = Z.DataMgr.Get("quest_data")
  if questData.QuestMgrStage < E.QuestMgrStage.LoadEnd then
    return {}
  end
  local idList = {}
  local trackId = questData:GetQuestTrackingId()
  if 0 < trackId then
    table.insert(idList, trackId)
  end
  if not questData:IsInForceTrack() then
    for i = 1, 2 do
      local option = questData:GetTrackOptionalIdByIndex(i)
      if 0 < option and option ~= trackId then
        table.insert(idList, option)
      end
    end
  end
  local dataList = {}
  for _, questId in ipairs(idList) do
    local tempList = createQuestGoalMapFlagDataList(questId, sceneId, isBigMap)
    table.zmerge(dataList, tempList)
  end
  return dataList
end
local getCanAcceptQuestNpcUidList = function(questId, sceneId)
  local questData = Z.DataMgr.Get("quest_data")
  local acceptInfo = questData:GetAcceptConfigByQuestId(questId)
  if not acceptInfo or acceptInfo.sceneId ~= sceneId then
    return {}
  end
  local uidList = {}
  local rowDict = Z.TableMgr.GetLevelTableDatas(E.LevelTableType.Npc, sceneId)
  for uid, row in pairs(rowDict) do
    if row.Id == acceptInfo.npcId then
      table.insert(uidList, uid)
    end
  end
  return uidList
end
local createQuestNpcMapFlagDataList = function(questId, sceneId)
  local questVM = Z.VMMgr.GetVM("quest")
  local questData = Z.DataMgr.Get("quest_data")
  local questNpcUidList
  if questData:IsCanAcceptQuest(questId) then
    questNpcUidList = getCanAcceptQuestNpcUidList(questId, sceneId)
  else
    local quest = questData:GetQuestByQuestId(questId)
    if quest then
      questNpcUidList = questVM.GetQuestNpcUidListByStepAndScene(questId, quest.stepId, sceneId)
    else
      return {}
    end
  end
  local dataList = {}
  for _, uid in ipairs(questNpcUidList) do
    local flagData = createQuestMapFlagData(sceneId, questId, uid, Z.GoalPosType.Npc)
    if flagData then
      table.insert(dataList, flagData)
    end
  end
  return dataList
end
local getQuestNpcFlagDataBySceneId = function(sceneId)
  local dataDict = {}
  local questData = Z.DataMgr.Get("quest_data")
  for questId, _ in pairs(questData:GetAllQuestDict()) do
    dataDict[questId] = createQuestNpcMapFlagDataList(questId, sceneId)
  end
  for questId, _ in pairs(Z.ContainerMgr.CharSerialize.questList.acceptQuestMap) do
    dataDict[questId] = createQuestNpcMapFlagDataList(questId, sceneId)
  end
  return dataDict
end
local getAreaNamePosBySceneId = function(sceneId)
  local ret = {}
  local sceneAreaTbl = Z.TableMgr.GetTable("SceneAreaTableMgr")
  for id, row in pairs(sceneAreaTbl.GetDatas()) do
    if id // 10000 == sceneId then
      local posArray = row.NamePosition
      if 0 < #posArray then
        local data = {}
        data.Name = row.Name
        data.Pos = {
          x = posArray[1],
          y = posArray[2]
        }
        table.insert(ret, data)
      end
    end
  end
  return ret
end
local checkTeleport = function(callback)
  local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
  if 0 < visualLayerId then
    Z.DialogViewDataMgr:OpenNormalDialog(Z.TipsVM.GetMessageContent(121003), function()
      Z.EventMgr:Dispatch("level_event", 13, visualLayerId)
      local proxy = require("zproxy.world_proxy")
      proxy.ExitVisualLayer()
      Z.DialogViewDataMgr:CloseDialogView()
      if callback then
        callback()
      end
    end)
  elseif callback then
    callback()
  end
end
local asyncUserTp = function(sceneId, transferId)
  local questData = Z.DataMgr.Get("quest_data")
  local questSet = questData:GetTpLimitQuestSetBySceneId(Z.StageMgr.GetCurrentSceneId())
  local questId = next(questSet)
  if questId then
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
    if questRow then
      local param = {
        str = questRow.QuestName
      }
      Z.TipsVM.ShowTipsLang(1001601, param)
      return
    end
  end
  if Z.StageMgr.GetIsInDungeon() then
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    if dungeonId == 0 then
      return
    end
    local dungeonRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if dungeonRow and dungeonRow.DisableTransport == 1 then
      Z.TipsVM.ShowTipsLang(1001602)
      return
    end
  end
  Z.LuaBridge.ClientReqSwitchSceneByTransfer(sceneId, transferId)
end
local setAreaData = function(data)
  if data.areaId then
    local mapData = Z.DataMgr.Get("map_data")
    mapData.CurAreaId = tonumber(data.areaId)
    mapData.IsHadShownAreaName = false
    logGreen("[MapAreaName] SetAreaId = " .. mapData.CurAreaId)
    Z.EventMgr:Dispatch(Z.ConstValue.MapAreaChange, mapData.CurAreaId)
  end
end
local findArroundFlagName = function(flagData)
  local name = ""
  if flagData.QuestId then
    local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(tonumber(flagData.QuestId))
    if questRow then
      name = questRow.QuestName
    end
  elseif flagData.Name then
    name = flagData.Name
  elseif flagData.MarkInfo then
    if flagData.MarkInfo.title == "" then
      local secenTagData = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(flagData.TypeId)
      if secenTagData then
        name = secenTagData.Name
      end
    else
      name = flagData.MarkInfo.title
    end
  else
    local secenTagData = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(flagData.TypeId)
    if secenTagData then
      name = secenTagData.Name
    end
  end
  return name
end
local setTraceEntity = function(src, sceneId, uid, posType, autoSelectTraceItem)
  if autoSelectTraceItem then
    local mapData = Z.DataMgr.Get("map_data")
    mapData.AutoSelectTrackSrc = src
  end
  local info = Panda.ZGame.GoalPosInfo.New(src, sceneId, uid, posType)
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  guideVM.SetGuideGoals(src, {info})
end
local setAutoSelect = function(flagDataId)
  local mapData = Z.DataMgr.Get("map_data")
  mapData.AutoSelectFlagId = flagDataId
end
local setIsShowRedInfo = function(isShow)
  local mapData = Z.DataMgr.Get("map_data")
  mapData.IsShowRedInfo = isShow
end
local checkIsTraceEntityBySrc = function(src, sceneId, uuid)
  local trackRow = Z.TableMgr.GetTable("TargetTrackTableMgr").GetRow(src)
  if trackRow and trackRow.MapTrack == 1 then
    local guideData = Z.DataMgr.Get("goal_guide_data")
    local goalList = guideData:GetGuideGoalsBySource(src)
    if goalList then
      for _, info in ipairs(goalList) do
        if info.SceneId == sceneId and info.EntUuid == uuid then
          return true
        end
      end
    end
  end
  return false
end
local getPosTypeByFlagData = function(flagData)
  local flagType = flagData.FlagType
  local posType = Z.GoalPosType.None
  if flagType == E.MapFlagType.Entity then
    posType = Z.GoalGuideMgr.EntTypeToPosType(flagData.Type)
  elseif flagType == E.MapFlagType.NotEntity then
    posType = Z.GoalPosType.Point
  elseif flagType == E.MapFlagType.Custom then
    posType = Z.GoalPosType.Point
  end
  return posType
end
local setMapTraceByFlagData = function(src, sceneId, flagData)
  local uid
  if flagData.FlagType ~= E.MapFlagType.Custom then
    uid = flagData.Uid
  else
    uid = flagData.Id
  end
  local pos = flagData.Pos or Vector3.New(0, 0, 0)
  local posType = getPosTypeByFlagData(flagData)
  local mapData = Z.DataMgr.Get("map_data")
  mapData.TracingFlagData = flagData
  if posType ~= Z.GoalPosType.None then
    local guideVM = Z.VMMgr.GetVM("goal_guide")
    local info = Panda.ZGame.GoalPosInfo.New(src, sceneId, uid, posType, pos)
    guideVM.SetGuideGoals(src, {info})
  end
end
local checkIsTracingFlagBySrcAndFlagData = function(src, sceneId, flagData)
  local posType = getPosTypeByFlagData(flagData)
  if posType == Z.GoalPosType.None then
    return false
  end
  local trackRow = Z.TableMgr.GetTable("TargetTrackTableMgr").GetRow(src)
  if trackRow and trackRow.MapTrack == 1 then
    local guideData = Z.DataMgr.Get("goal_guide_data")
    local goalList = guideData:GetGuideGoalsBySource(src)
    if goalList then
      if flagData.FlagType ~= E.MapFlagType.Custom then
        for _, info in ipairs(goalList) do
          if (sceneId == 0 or info.SceneId == sceneId) and info.Uid == flagData.Uid and info.PosType == posType then
            return true
          end
        end
      else
        for _, info in ipairs(goalList) do
          if info.Uid == flagData.Id then
            return true
          end
        end
      end
    end
  end
  return false
end
local checkIsTracingFlagByFlagData = function(sceneId, flagData)
  local guideData = Z.DataMgr.Get("goal_guide_data")
  for src, _ in pairs(guideData:GetAllGuideGoalsDict()) do
    if checkIsTracingFlagBySrcAndFlagData(src, sceneId, flagData) then
      return true
    end
  end
  return false
end
local clearFlagDataTrackSource = function(sceneId, flagData)
  local guideData = Z.DataMgr.Get("goal_guide_data")
  for src, _ in pairs(guideData:GetAllGuideGoalsDict()) do
    if checkIsTracingFlagBySrcAndFlagData(src, sceneId, flagData) then
      local guideVM = Z.VMMgr.GetVM("goal_guide")
      guideVM.SetGuideGoals(src, nil)
    end
  end
  local mapData = Z.DataMgr.Get("map_data")
  mapData.TracingFlagData = nil
end
local asyncSendSetMapMark = function(sceneId, markInfo, cancelToken)
  local ret = worldProxy.SetMapMark(sceneId, markInfo, cancelToken)
  return ret
end
local asyncSendDelMapMark = function(sceneId, markId, cancelToken)
  local ret = worldProxy.RemoveMapMark(sceneId, markId, cancelToken)
  return ret
end
local getMapShowSceneId = function()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local cfg = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  if cfg == nil then
    logError(string.format("SceneTable,\230\151\160 %d \233\133\141\231\189\174", sceneId))
    return
  end
  local reId
  if cfg.ParentId == nil or cfg.ParentId == 0 then
    reId = sceneId
  else
    reId = cfg.ParentId
  end
  return reId
end
local getMapFuncListShowTab = function(id)
  local cfgs = Z.TableMgr.GetTable("MapActivityTableMgr")
  local tabs = {}
  local sceneId = id or getMapShowSceneId()
  local CheckFuncSwitch = Z.VMMgr.GetVM("switch").CheckFuncSwitch
  for _, cfg in pairs(cfgs.GetDatas()) do
    if CheckFuncSwitch(cfg.FunctionId) then
      for i = 1, #cfg.Scene do
        if cfg.Scene[i] == sceneId then
          tabs[#tabs + 1] = cfg
        end
      end
    end
  end
  table.sort(tabs, function(a, b)
    return a.Id < b.Id
  end)
  return tabs
end
local sortAroundList = function(aroundList, selectTypeId)
  local sceneTagTableMgr = Z.TableMgr.GetTable("SceneTagTableMgr")
  local questVM = Z.VMMgr.GetVM("quest")
  table.sort(aroundList, function(flagData1, flagData2)
    local config1 = sceneTagTableMgr.GetRow(flagData1.TypeId)
    local config2 = sceneTagTableMgr.GetRow(flagData2.TypeId)
    if config1 and config2 then
      local typeWeight1 = selectTypeId and flagData1.TypeId == selectTypeId and 0 or 1
      local typeWeight2 = selectTypeId and flagData2.TypeId == selectTypeId and 0 or 1
      if typeWeight1 == typeWeight2 then
        if config1.Sort == config2.Sort then
          if flagData1.QuestId and flagData2.QuestId then
            return questVM.CompareQuestIdOrder(flagData1.QuestId, flagData2.QuestId)
          else
            return false
          end
        else
          return config1.Sort < config2.Sort
        end
      else
        return typeWeight1 < typeWeight2
      end
    end
    return false
  end)
end
local createDynamicTraceMapFlagData = function(sourceType, goalPosInfo)
  local globalCfg, flagDataId = getGlobalInfo(goalPosInfo.SceneId, goalPosInfo.PosType, goalPosInfo.Uid)
  if globalCfg == nil or flagDataId == nil then
    return
  end
  local flagData = {}
  flagData.Id = flagDataId
  flagData.Uid = goalPosInfo.Uid
  flagData.Type = Z.GoalGuideMgr.PosTypeToEntType(goalPosInfo.PosType)
  flagData.TypeId = E.SceneTagId.DynamicTrace
  local sceneTagTbl = Z.TableMgr.GetTable("SceneTagTableMgr")
  local scenceData = sceneTagTbl.GetRow(flagData.TypeId)
  if scenceData then
    flagData.IconPath = scenceData.Icon1
  end
  if goalPosInfo.PosType == Z.GoalPosType.Point then
    flagData.FlagType = E.MapFlagType.NotEntity
  elseif goalPosInfo.PosType == Z.GoalPosType.Zone then
    flagData.FlagType = E.MapFlagType.Entity
    flagData.RangeDiameter = globalCfg.ZoneParam[1]
  else
    flagData.FlagType = E.MapFlagType.Entity
  end
  local posArray = globalCfg.Position
  flagData.Pos = Vector3.New(posArray[1], posArray[2], posArray[3])
  local mapData = Z.DataMgr.Get("map_data")
  local dynamicTraceParam = mapData:GetDynamicTraceParam(sourceType, goalPosInfo.PosType, goalPosInfo.Uid)
  if dynamicTraceParam and dynamicTraceParam.Name then
    flagData.Name = dynamicTraceParam.Name
  end
  return flagData
end
local getCurSceneGroupList = function(curSceneId)
  local resultList = {}
  local mapInfoTableMgr = Z.TableMgr.GetTable("MapInfoTableMgr")
  local mapInfoRow = mapInfoTableMgr.GetRow(curSceneId)
  if mapInfoRow then
    local allMapInfoRow = mapInfoTableMgr.GetDatas()
    for sceneId, info in pairs(allMapInfoRow) do
      if sceneId == curSceneId or mapInfoRow.GroupId ~= 0 and info.GroupId == mapInfoRow.GroupId then
        table.insert(resultList, info)
      end
    end
  end
  table.sort(resultList, function(a, b)
    if a.GroupOrder == b.GroupOrder then
      return a.Id < b.Id
    else
      return a.GroupOrder > b.GroupOrder
    end
  end)
  return resultList
end
local ret = {
  CheckTeleport = checkTeleport,
  AsyncUserTp = asyncUserTp,
  GetAreaNamePosBySceneId = getAreaNamePosBySceneId,
  GetQuestNpcFlagDataBySceneId = getQuestNpcFlagDataBySceneId,
  GetQuestGoalFlagDataBySceneId = getQuestGoalFlagDataBySceneId,
  CreateQuestNpcMapFlagDataList = createQuestNpcMapFlagDataList,
  GetTeamFlagDataBySceneId = getTeamFlagDataBySceneId,
  LoadEntityTableData = loadEntityTableData,
  LoadWorldQuestEntityFlagData = loadWorldQuestEntityFlagData,
  SetAreaData = setAreaData,
  SetTraceEntity = setTraceEntity,
  SetAutoSelect = setAutoSelect,
  SetIsShowRedInfo = setIsShowRedInfo,
  CheckIsTraceEntityBySrc = checkIsTraceEntityBySrc,
  SetMapTraceByFlagData = setMapTraceByFlagData,
  CheckIsTracingFlagBySrcAndFlagData = checkIsTracingFlagBySrcAndFlagData,
  ClearFlagDataTrackSource = clearFlagDataTrackSource,
  CheckIsTracingFlagByFlagData = checkIsTracingFlagByFlagData,
  FindArroundFlagName = findArroundFlagName,
  AsyncSendSetMapMark = asyncSendSetMapMark,
  AsyncSendDelMapMark = asyncSendDelMapMark,
  GetMapShowSceneId = getMapShowSceneId,
  GetMapFuncListShowTab = getMapFuncListShowTab,
  CheckTransferPointUnlock = checkTransferPointUnlock,
  SortAroundList = sortAroundList,
  GetGlobalInfo = getGlobalInfo,
  CreateDynamicTraceMapFlagData = createDynamicTraceMapFlagData,
  GetCurSceneGroupList = getCurSceneGroupList,
  LoadSceneEntityTableData = loadSceneEntityTableData
}
return ret
