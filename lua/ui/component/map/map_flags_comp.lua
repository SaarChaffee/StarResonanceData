local MapFlagsComp = class("MapFlagsComp")
local levelMapFlagHelper = require("ui.component.map.level_map_flag_helper")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function MapFlagsComp:ctor(parentView, isBigMap)
  self.view_ = parentView
  self.isBigMap_ = isBigMap ~= false
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.mapData_ = Z.DataMgr.Get("map_data")
end

function MapFlagsComp:Init()
  self.miniMapNode_ = self.view_.uiBinder.comp_mini_map_base
  self.flagParentNode_ = self.view_.uiBinder.node_flags
  self.transferFlagParentNode_ = self.view_.uiBinder.node_transfer_flags
  self.questFlagParentNode_ = self.view_.uiBinder.node_quest_flags
  self.customFlagParentNode_ = self.view_.uiBinder.node_custom_flags
  self.areaFlagParentNode_ = self.view_.uiBinder.node_area_flags
  self.teamDataList_ = {}
  self.customDataList_ = {}
  self.dynamicTraceList_ = {}
  self.labDataList_ = {}
  self.redpointList_ = {}
  self.unitsName_ = {}
  self.noticeUpdateTimerDict_ = {}
  self.levelFlagHelper_ = levelMapFlagHelper.new(self.isBigMap_)
  self.worldQuestShowEffectId_ = self.mapData_.AutoSelectFlagId
  self:BindEventsAndWatcher()
end

function MapFlagsComp:UnInit()
  self:UnBindEventsAndWatcher()
  self.teamDataList_ = nil
  self.customDataList_ = nil
  self.dynamicTraceList_ = nil
  self.labDataList_ = nil
  self:clearNoticeUpdateTimer()
  self.noticeUpdateTimerDict_ = nil
  self.levelFlagHelper_ = nil
  for _, id in ipairs(self.redpointList_) do
    Z.RedPointMgr.RemoveNodeItem(id)
  end
  self.redpointList_ = nil
end

function MapFlagsComp:BindEventsAndWatcher()
  Z.EventMgr:Add(Z.ConstValue.NpcQuestIconChange, self.onNpcQuestIconChange, self)
  Z.EventMgr:Add(Z.ConstValue.Team.Refresh, self.onRefreshTeam, self)
  Z.EventMgr:Add(Z.ConstValue.Team.MemberChangeScene, self.onRefreshTeam, self)
  Z.EventMgr:Add(Z.ConstValue.Team.MemberInfoChange, self.onTeamMemberInfoChange, self)
  Z.EventMgr:Add(Z.ConstValue.Team.ChangeSceneId, self.onRefreshTeam, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.TrackingIdChange, self.onTrackingIdChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.TrackOptionChange, self.onQuestGoalChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StateChange, self.onQuestGoalChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepChange, self.onQuestGoalChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.GoalComplete, self.onQuestGoalChange, self)
  Z.EventMgr:Add(Z.ConstValue.WorldQuestListChange, self.onWorldQuestListChange, self)
  Z.EventMgr:Add(Z.ConstValue.MapOutRangeChange, self.onMapOutRangeChange, self)
  Z.EventMgr:Add(Z.ConstValue.GoalGuideChange, self.onGoalGuideChange, self)
  Z.EventMgr:Add(Z.ConstValue.AllGoalGuideChange, self.onDynamicTraceChange, self)
  Z.EventMgr:Add(Z.ConstValue.Pivot.OnPivotUnlock, self.onTransferPointChange, self)
  Z.EventMgr:Add(Z.ConstValue.PlayerEnterOrExitZone, self.onPlayerEnterOrExitZone, self)
  Z.EventMgr:Add(Z.ConstValue.VisualLayerChange, self.onVisualLayerChange, self)
  
  function self.onMapDataChange_(container, dirty)
    if dirty and dirty.markDataMap then
      self:onCustomFlagChange()
    end
  end
  
  function self.onTransferPointChange_(container, dirty)
    if dirty and dirty.points then
      self:onTransferPointChange(dirty.points)
    end
  end
  
  Z.ContainerMgr.CharSerialize.mapData.Watcher:RegWatcher(self.onMapDataChange_)
  Z.ContainerMgr.CharSerialize.transferPoint.Watcher:RegWatcher(self.onTransferPointChange_)
end

function MapFlagsComp:UnBindEventsAndWatcher()
  Z.EventMgr:RemoveObjAll(self)
  if self.onMapDataChange_ then
    Z.ContainerMgr.CharSerialize.mapData.Watcher:UnregWatcher(self.onMapDataChange_)
    self.onMapDataChange_ = nil
  end
  if self.onTransferPointChange_ then
    Z.ContainerMgr.CharSerialize.transferPoint.Watcher:UnregWatcher(self.onTransferPointChange_)
    self.onTransferPointChange_ = nil
  end
end

function MapFlagsComp:RefreshMap()
  self.miniMapNode_:ClearAllMapFlags()
  local sceneId = self:getCurSceneId()
  self.levelFlagHelper_:ResetAll(sceneId)
  self.teamDataList_ = self.mapVM_.GetTeamFlagDataBySceneId(sceneId)
  self.labDataList_ = self.mapVM_.GetAreaNamePosBySceneId(sceneId)
  self.dynamicTraceList_ = self:GetDynamicTraceList(sceneId)
  for _, id in ipairs(self.redpointList_) do
    Z.RedPointMgr.RemoveNodeItem(id)
  end
  self.redpointList_ = {}
  for _, value in ipairs(self.unitsName_) do
    self.view_:RemoveUiUnit(value)
  end
  self:clearNoticeUpdateTimer()
  self:createAllMapFlag()
  if self.isBigMap_ then
    self:createNameText()
  end
end

function MapFlagsComp:GetFlagDataByFlagId(flagId, ignoreDynamic)
  local list = {}
  self:findFlagDataById(flagId, self.teamDataList_, list)
  self:findFlagDataById(flagId, self.customDataList_, list)
  local mergedData = self.levelFlagHelper_:GetMergedFlagDataByFlagId(flagId)
  if mergedData then
    table.insert(list, mergedData)
  end
  if not ignoreDynamic then
    self:findFlagDataById(flagId, self.dynamicTraceList_, list)
  end
  if 1 < #list then
    logError("[MapFlagsComp] flagId \233\135\141\229\164\141")
  end
  if 1 <= #list then
    return list[1]
  end
end

function MapFlagsComp:GetOriginFlagListByFlagId(flagId)
  local list = {}
  self:findFlagDataById(flagId, self.teamDataList_, list)
  self:findFlagDataById(flagId, self.customDataList_, list)
  self:findFlagDataById(flagId, self.levelFlagHelper_:GetOriginFlagListByFlagId(flagId), list)
  self:findFlagDataById(flagId, self.dynamicTraceList_, list)
  return list
end

function MapFlagsComp:GetDynamicTraceList(sceneId)
  local list = {}
  local guideData = Z.DataMgr.Get("goal_guide_data")
  for sourceType, goalDict in pairs(self.mapData_.dynamicTraceParams_) do
    if next(goalDict) ~= nil then
      local goalPosInfoList = guideData:GetGuideGoalsBySource(sourceType) or {}
      for i, goalPosInfo in ipairs(goalPosInfoList) do
        if goalPosInfo.SceneId == sceneId then
          local trackRow = Z.TableMgr.GetTable("TargetTrackTableMgr").GetRow(sourceType)
          if trackRow and trackRow.MapTrack == 1 then
            local flagData = self.mapVM_.CreateDynamicTraceMapFlagData(sourceType, goalPosInfo)
            if flagData then
              local createdFlagData = self:GetFlagDataByFlagId(flagData.Id, true)
              if not createdFlagData then
                table.insert(list, flagData)
              end
            end
          end
        end
      end
    end
  end
  return list
end

function MapFlagsComp:OnMapZoomChange()
  for _, flagData in ipairs(self:getAllFlagDataList()) do
    local name = self:getFlagUnitNameByFlagData(flagData)
    local unit = self.view_.units[name]
    if unit then
      self:setFlagUnitRange(unit, flagData)
    end
  end
end

function MapFlagsComp:createAllMapFlag()
  self:createMapFlagByDataList(self.levelFlagHelper_:GetAllMergedFlagData())
  self:createMapFlagByDataList(self.teamDataList_)
  self:createMapFlagByDataList(self.dynamicTraceList_)
  self:createCustomFlag()
end

function MapFlagsComp:createNameText()
  local unitPath = GetLoadAssetPath("labAssetPath")
  for index, data in pairs(self.labDataList_) do
    Z.CoroUtil.create_coro_xpcall(function()
      local unitName = "lab" .. index
      local unit = self.view_:AsyncLoadUiUnit(unitPath, unitName, self.areaFlagParentNode_)
      table.insert(self.unitsName_, unitName)
      if unit then
        unit.lab_name.text = data.Name
        self.miniMapNode_:AddMapFlag(E.MapFlagType.AreaName, index, 0, data.Pos, unit.comp_map_flag)
        self:refreshFlagUIPos()
      end
    end)()
  end
end

function MapFlagsComp:createMapFlagByDataList(dataList)
  if not dataList then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for _, flagData in ipairs(dataList) do
      self:asyncCreateMapFlagByFlagData(flagData)
    end
  end)()
end

function MapFlagsComp:asyncCreateMapFlagByFlagData(flagData)
  if not flagData.FlagType then
    logError("[MapFlagsComp] flagData\230\178\161\230\156\137\230\140\135\229\174\154\229\155\190\230\160\135\231\177\187\229\158\139")
    return
  end
  local name = self:getFlagUnitNameByFlagData(flagData)
  local parent
  if flagData.QuestId then
    parent = self.questFlagParentNode_
  elseif flagData.FlagType == E.MapFlagType.Custom then
    parent = self.customFlagParentNode_
  elseif flagData.FlagType == E.MapFlagType.Entity and flagData.SubType == E.SceneObjType.Transfer then
    parent = self.transferFlagParentNode_
  else
    parent = self.flagParentNode_
  end
  local path = GetLoadAssetPath("mapFlagAssetPath")
  if flagData.IsTeam then
    path = GetLoadAssetPath("mapTeamFlagAssetPath")
  end
  local unit = self.view_:AsyncLoadUiUnit(path, name, parent)
  table.insert(self.unitsName_, name)
  if not unit then
    return
  end
  if self.isBigMap_ then
    Z.GuideMgr:SetSteerIdByComp(unit.comp_steer, E.DynamicSteerType.MapFlag, flagData.TpPointId)
  end
  self.miniMapNode_:AddMapFlag(flagData.FlagType, flagData.Id, flagData.TypeId, flagData.Pos, unit.comp_map_flag)
  self:initFlagUnit(unit, flagData)
  if not self.isBigMap_ then
    unit.Ref:SetVisible(unit.node_parent, false)
  end
  self:refreshFlagUIPos()
  return unit
end

function MapFlagsComp:getFlagUnitNameByFlagData(data)
  local flagType = data.FlagType
  if flagType == E.MapFlagType.Custom and data.Id == -1 then
    return Z.ConstValue.MapCustomFlagName
  end
  local pre
  if flagType == E.MapFlagType.Custom then
    pre = Z.ConstValue.MapCustomFlagName
  elseif flagType == E.MapFlagType.Entity then
    pre = 1
  elseif flagType == E.MapFlagType.NotEntity then
    pre = 0
  else
    logError("[MapFlagsComp] MapFlagType = {0} \230\178\161\230\156\137\229\175\185\229\186\148\231\154\132\229\144\141\231\167\176\229\137\141\231\188\128", flagType)
    pre = ""
  end
  return pre .. data.Id
end

function MapFlagsComp:initFlagUnit(unit, flagData)
  unit.Ref.UIComp:SetVisible(false)
  if flagData.IsTeam then
    playerPortraitHgr.InsertNewPortraitBySocialData(unit.binder_head, flagData.SocialData)
    unit.Ref.UIComp:SetVisible(true)
    unit.binder_head.lab_index.text = flagData.TeamIndex
  elseif flagData.IconPath and flagData.IconPath ~= "" then
    unit.img_icon:SetImage(flagData.IconPath)
    unit.Ref.UIComp:SetVisible(true)
  end
  self:setFlagUnitIconVisible(unit, flagData)
  self:setFlagUnitCornerIcon(unit, flagData)
  self:setFlagUnitRange(unit, flagData)
  self:setFlagUnitTeamIndex(unit, flagData)
  self:setFlagUnitEffect(unit, flagData)
  self:setFlagUnitBoardLimit(unit, flagData)
  local isShow = self.mapData_:GetMapFlagVisibleSettingByTypeId(flagData.TypeId)
  unit.Ref:SetVisible(unit.node_parent, isShow)
  unit.tog_select:RemoveAllListeners()
  unit.tog_select.isOn = false
  unit.dotween_provider:Rewind(Z.DOTweenAnimType.Tween_0)
  if self.isBigMap_ then
    unit.tog_select.interactable = true
    unit.tog_select.group = self.view_.uiBinder.togs_flag
    unit.tog_select:AddListener(function(isOn)
      self:changeMapFlagToggle(unit, flagData, isOn, false)
    end)
    if self.mapData_.AutoSelectTrackSrc then
      local isTracking = self.mapVM_.CheckIsTracingFlagBySrcAndFlagData(self.mapData_.AutoSelectTrackSrc, self:getCurSceneId(), flagData)
      if isTracking then
        unit.tog_select:SetIsOnWithoutCallBack(true)
        self:changeMapFlagToggle(unit, flagData, true, true)
        self.mapData_.AutoSelectTrackSrc = nil
      end
    elseif self.mapData_.AutoSelectFlagId and self.mapData_.AutoSelectFlagId == flagData.Id then
      unit.tog_select:SetIsOnWithoutCallBack(true)
      self:changeMapFlagToggle(unit, flagData, true, true)
      self.mapData_.AutoSelectFlagId = nil
    end
  else
    unit.tog_select.interactable = false
  end
  local cfg = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(flagData.TypeId)
  if cfg and cfg.Type == 4 then
    local dungeonId = tonumber(cfg.Param)
    local id = Z.VMMgr.GetVM("dungeon").GetRedPointID(dungeonId)
    if 0 < id then
      Z.RedPointMgr.LoadRedDotItem(id, self.view_, unit.node_red)
      self.redpointList_[#self.redpointList_ + 1] = id
    end
  end
end

function MapFlagsComp:changeMapFlagToggle(unit, flagData, isOn, noFindAround)
  self.view_:OnMapFlagToggleChange(flagData, isOn, noFindAround)
  if isOn then
    unit.dotween_provider:Restart(Z.DOTweenAnimType.Tween_0)
  else
    unit.dotween_provider:Restart(Z.DOTweenAnimType.Tween_1)
  end
end

function MapFlagsComp:setFlagUnitIconVisible(flagUnit, flagData)
  if flagData.QuestId and flagData.RangeDiameter and Z.LuaBridge.IsPlayerInZone(flagData.Uid) then
    flagUnit.Ref:SetVisible(flagUnit.img_icon, false)
  else
    flagUnit.Ref:SetVisible(flagUnit.img_icon, true)
  end
end

function MapFlagsComp:setFlagUnitCornerIcon(flagUnit, flagData)
  local questFlag
  if flagData.QuestId == nil then
    questFlag = flagData.RelationQuestFlags and flagData.RelationQuestFlags[1]
  end
  if questFlag and questFlag.IconPath and questFlag.IconPath ~= "" then
    flagUnit.img_icon_corner:SetImage(questFlag.IconPath)
    flagUnit.Ref:SetVisible(flagUnit.img_icon_corner, true)
  else
    flagUnit.Ref:SetVisible(flagUnit.img_icon_corner, false)
  end
end

function MapFlagsComp:setFlagUnitRange(flagUnit, flagData)
  if not flagData.RangeDiameter then
    flagUnit.Ref:SetVisible(flagUnit.img_range, false)
    return
  end
  if flagUnit.comp_map_flag.IsOutMiniMap then
    flagUnit.Ref:SetVisible(flagUnit.img_range, false)
    return
  end
  local scaleVector = self.miniMapNode_:GetMapScale()
  local w = flagData.RangeDiameter * scaleVector.x
  local h = flagData.RangeDiameter * scaleVector.y
  flagUnit.Ref:SetVisible(flagUnit.img_range, true)
  flagUnit.img_range.transform:SetSizeDelta(w, h)
end

function MapFlagsComp:isShowTracingEffect(flagData)
  local questData = Z.DataMgr.Get("quest_data")
  local curQuestTrackingId = questData:GetQuestTrackingId()
  local curSceneId = self:getCurSceneId()
  if flagData.QuestId and flagData.QuestId == curQuestTrackingId then
    return true
  end
  if flagData.RelationQuestFlags then
    for _, value in ipairs(flagData.RelationQuestFlags) do
      if value.QuestId == curQuestTrackingId then
        return true
      end
    end
  end
  local isTrace = self.mapVM_.CheckIsTracingFlagByFlagData(curSceneId, flagData)
  return isTrace
end

function MapFlagsComp:isShowWorldQuestEffect(flagData)
  local worldQuestData_ = Z.DataMgr.Get("worldquest_data")
  local showWorldQuest_ = flagData.TypeId == Z.Global.WorldEventSceneTagIcon and worldQuestData_.AcceptWorldQuest and flagData.SubType == E.SceneObjType.WorldQuest
  if showWorldQuest_ then
    local scenceData = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(Z.Global.WorldEventSceneTagIcon)
    if scenceData and flagData.IconPath == scenceData.Icon2 then
      showWorldQuest_ = false
    end
    if self.worldQuestShowEffectId_ and self.worldQuestShowEffectId_ ~= flagData.Id then
      showWorldQuest_ = false
    end
    if not self.isBigMap_ then
      showWorldQuest_ = false
    end
  end
  return showWorldQuest_
end

function MapFlagsComp:setFlagUnitEffect(flagUnit, flagData)
  local mapData_ = Z.DataMgr.Get("map_data")
  local showWorldQuest_ = self:isShowWorldQuestEffect(flagData)
  if showWorldQuest_ and not flagUnit.effect_worldquest.HasActiveEffectGo then
    flagUnit.effect_worldquest:CreatEFFGO(mapData_.MapEffectPathDict[E.MapFlagEffectType.WorldQuset], Vector3.zero, true)
  end
  flagUnit.Ref:SetVisible(flagUnit.effect_worldquest, showWorldQuest_)
  flagUnit.effect_worldquest:SetEffectGoVisible(showWorldQuest_)
  local isTrace = self:isShowTracingEffect(flagData)
  flagUnit.Ref:SetVisible(flagUnit.effect_trace, isTrace)
  flagUnit.effect_trace:SetEffectGoVisible(isTrace)
end

function MapFlagsComp:setFlagUnitTeamIndex(flagUnit, flagData)
  flagUnit.Ref:SetVisible(flagUnit.lab_num, flagData.TeamIndex ~= nil)
  if flagData.TeamIndex then
    flagUnit.lab_num.text = flagData.TeamIndex
  end
end

function MapFlagsComp:setFlagUnitBoardLimit(flagUnit, flagData)
  local isTracking = self.mapVM_.CheckIsTracingFlagByFlagData(self:getCurSceneId(), flagData)
  flagUnit.comp_map_flag.IsBorderLimit = isTracking
end

function MapFlagsComp:clearNoticeUpdateTimer()
  for key, value in pairs(self.noticeUpdateTimerDict_) do
    self.view_.timerMgr:StopTimer(value)
    self.noticeUpdateTimerDict_[key] = nil
  end
end

function MapFlagsComp:onMapOutRangeChange(id)
  local flagData = self:GetFlagDataByFlagId(id)
  if flagData then
    local name = self:getFlagUnitNameByFlagData(flagData)
    local flagUnit = self.view_.units[name]
    if flagUnit then
      self:setFlagUnitRange(flagUnit, flagData)
    end
  end
end

function MapFlagsComp:GetFalgData(uid, entityType, subType)
  return self.levelFlagHelper_:GetMergedFlagDataByEntSubType(uid, entityType, subType)
end

function MapFlagsComp:getCustomFlagDataList()
  local resultList = {}
  local markDataMap = Z.ContainerMgr.CharSerialize.mapData.markDataMap[self:getCurSceneId()]
  if not markDataMap then
    return resultList
  end
  for _, markInfo in pairs(markDataMap.markInfoMap) do
    local sceneTagRow = Z.TableMgr.GetTable("SceneTagTableMgr").GetRow(markInfo.iconId)
    local flagData = {
      Id = markInfo.tagId,
      FlagType = E.MapFlagType.Custom,
      Type = -1,
      TypeId = markInfo.iconId,
      Pos = Vector2.New(markInfo.position.x / Z.ConstValue.MapScalePercent, markInfo.position.y / Z.ConstValue.MapScalePercent),
      IconPath = sceneTagRow and sceneTagRow.Icon1 or "",
      MarkInfo = markInfo
    }
    table.insert(resultList, flagData)
  end
  return resultList
end

function MapFlagsComp:createCustomFlag()
  self.customDataList_ = self:getCustomFlagDataList()
  self:createMapFlagByDataList(self.customDataList_)
end

function MapFlagsComp:onCustomFlagChange()
  self:flagDataChangeHandler(self.customDataList_, self:getCustomFlagDataList())
end

function MapFlagsComp:AddTempMapFlagByFlagData(flagData)
  Z.CoroUtil.create_coro_xpcall(function()
    local unit = self:asyncCreateMapFlagByFlagData(flagData)
    if unit then
      unit.tog_select.isOn = true
    end
  end)()
end

function MapFlagsComp:RemoveTempMapFlagByFlagData()
  self.miniMapNode_:RemoveMapFlag(E.MapFlagType.Custom, -1)
  local name = Z.ConstValue.MapCustomFlagName
  local unit = self.view_.units[name]
  if unit and unit.tog_select then
    unit.tog_select.isOn = false
    unit.tog_select:RemoveAllListeners()
  end
  self.view_:RemoveUiUnit(name)
end

function MapFlagsComp:RemoveMapFlagAndUnit(flagData)
  self.miniMapNode_:RemoveMapFlag(flagData.FlagType, flagData.Id)
  local name = self:getFlagUnitNameByFlagData(flagData)
  local unit = self.view_.units[name]
  if unit and unit.tog_select then
    unit.tog_select.isOn = false
    unit.tog_select:RemoveAllListeners()
  end
  self.view_:RemoveUiUnit(name)
end

function MapFlagsComp:SetUnitSelectByFlagData(flagData)
  local name = self:getFlagUnitNameByFlagData(flagData)
  local unit = self.view_.units[name]
  if unit and unit.tog_select then
    unit.tog_select.isOn = true
  end
end

function MapFlagsComp:getAllFlagDataList()
  local list = {}
  table.zmerge(list, self.levelFlagHelper_:GetAllMergedFlagData())
  table.zmerge(list, self.teamDataList_)
  table.zmerge(list, self.customDataList_)
  table.zmerge(list, self.dynamicTraceList_)
  return list
end

function MapFlagsComp:findFlagDataById(flagId, dataList, tempList)
  if not dataList then
    return
  end
  for _, flagData in ipairs(dataList) do
    if flagId == flagData.Id and flagData.IconPath and flagData.IconPath ~= "" then
      local isShow = self.mapData_:GetMapFlagVisibleSettingByTypeId(flagData.TypeId)
      if isShow then
        table.insert(tempList, flagData)
      end
    end
  end
end

function MapFlagsComp:refreshFlagUIPos()
  if self.view_.GetMapZoom then
    self.miniMapNode_:LuaUpdateWhenSlide(self.view_:GetMapZoom())
  end
end

function MapFlagsComp:getCurSceneId()
  return self.view_:GetCurSceneId()
end

function MapFlagsComp:onNpcQuestIconChange(questId)
  self:refreshMapFlagUnitBySrc(E.LevelMapFlagSrc.QuestNpc, questId)
end

function MapFlagsComp:onRefreshTeam()
  local mapData = Z.DataMgr.Get("map_data")
  local uid = 0
  if mapData.TracingFlagData and mapData.TracingFlagData.IsTeam then
    uid = mapData.TracingFlagData.Uid
  end
  local curSceneId = self:getCurSceneId()
  self:flagDataChangeHandler(self.teamDataList_, self.mapVM_.GetTeamFlagDataBySceneId(curSceneId))
  local isHave = false
  if uid ~= 0 then
    for index, flagData in ipairs(self.teamDataList_) do
      if uid == flagData.Uid then
        isHave = true
      end
    end
    if not isHave then
      local guideVM = Z.VMMgr.GetVM("goal_guide")
      guideVM.SetGuideGoals(E.GoalGuideSource.MapFlag, nil)
    end
  end
end

function MapFlagsComp:onTeamMemberInfoChange(mem)
  local mapData = Z.DataMgr.Get("map_data")
  for _, flagData in ipairs(self.teamDataList_) do
    if flagData.Uid == mem.charId then
      flagData.Pos = Vector3.New(mem.sceneData.levelPos.x, mem.sceneData.levelPos.y, mem.sceneData.levelPos.z)
      self.miniMapNode_:UpdateMapFlagWorldPos(flagData.FlagType, flagData.Id, flagData.Pos)
      if mapData.TracingFlagData and mapData.TracingFlagData.IsTeam then
        local guideVM = Z.VMMgr.GetVM("goal_guide")
        guideVM.ChangeGuideDataBySrcId(E.GoalGuideSource.MapFlag, flagData)
      end
    end
  end
end

function MapFlagsComp:onGoalGuideChange(src, oldGoalList)
  for _, flagData in ipairs(self:getAllFlagDataList()) do
    local name = self:getFlagUnitNameByFlagData(flagData)
    local unit = self.view_.units[name]
    if unit then
      self:setFlagUnitEffect(unit, flagData)
      self:setFlagUnitBoardLimit(unit, flagData)
    end
  end
end

function MapFlagsComp:onDynamicTraceChange()
  local curSceneId = self:getCurSceneId()
  self:flagDataChangeHandler(self.dynamicTraceList_, self:GetDynamicTraceList(curSceneId))
end

function MapFlagsComp:onQuestGoalChange()
  self:refreshMapFlagUnitBySrc(E.LevelMapFlagSrc.QuestGoal)
end

function MapFlagsComp:onTrackingIdChange(curTrackId, oldTrackId)
  if curTrackId == oldTrackId then
    return
  end
  self:refreshMapFlagUnitBySrc(E.LevelMapFlagSrc.QuestGoal)
  self:refreshMapFlagUnitBySrc(E.LevelMapFlagSrc.QuestNpc, oldTrackId)
  self:refreshMapFlagUnitBySrc(E.LevelMapFlagSrc.QuestNpc, curTrackId)
end

function MapFlagsComp:onWorldQuestListChange()
  self:refreshMapFlagUnitBySrc(E.LevelMapFlagSrc.WorldQuest)
end

function MapFlagsComp:onTransferPointChange(targetIdDict)
  Z.CoroUtil.create_coro_xpcall(function()
    local changeList = {}
    self.mapVM_.LoadSceneEntityTableData(changeList, self:getCurSceneId(), targetIdDict)
    for i, flagData in ipairs(changeList) do
      self:RemoveMapFlagAndUnit(flagData)
      self:asyncCreateMapFlagByFlagData(flagData)
    end
  end)()
end

function MapFlagsComp:refreshMapFlagUnitBySrc(src, srcId)
  Z.CoroUtil.create_coro_xpcall(function()
    local changeList = self.levelFlagHelper_:ChangeFlagDataBySrc(src, srcId)
    for _, flagData in ipairs(changeList) do
      self:RemoveMapFlagAndUnit(flagData)
      if self.levelFlagHelper_:GetMergedFlagDataByFlagId(flagData.Id) then
        self:asyncCreateMapFlagByFlagData(flagData)
      end
    end
  end)()
end

function MapFlagsComp:onPlayerEnterOrExitZone(isEnter, zoneUid)
  if self:getCurSceneId() ~= Z.StageMgr.GetCurrentSceneId() then
    return
  end
  local flagData = self.levelFlagHelper_:GetMergedFlagDataByPosTypeAndUid(Z.GoalPosType.Zone, zoneUid)
  if flagData then
    local name = self:getFlagUnitNameByFlagData(flagData)
    local unit = self.view_.units[name]
    if unit then
      self:setFlagUnitIconVisible(unit, flagData)
    end
  end
end

function MapFlagsComp:onVisualLayerChange(isEnter, zoneUid)
  self:refreshMapFlagUnitBySrc(E.LevelMapFlagSrc.QuestGoal)
  self:refreshMapFlagUnitBySrc(E.LevelMapFlagSrc.QuestNpc)
end

function MapFlagsComp:flagDataChangeHandler(originFlagDataList, newFlagDataList)
  Z.CoroUtil.create_coro_xpcall(function()
    local waitRemoveDict = {}
    local waitAddList = {}
    for _, flagData in ipairs(originFlagDataList) do
      waitRemoveDict[flagData.Id] = flagData
    end
    for _, flagData in ipairs(newFlagDataList) do
      if not waitRemoveDict[flagData.Id] then
        table.insert(waitAddList, flagData)
      else
        waitRemoveDict[flagData.Id] = nil
      end
    end
    for id, flagData in pairs(waitRemoveDict) do
      self:RemoveMapFlagAndUnit(flagData)
    end
    for index, flagData in ipairs(originFlagDataList) do
      originFlagDataList[index] = nil
    end
    for index, flagData in ipairs(newFlagDataList) do
      originFlagDataList[index] = flagData
    end
    for i, flagData in ipairs(waitAddList) do
      self:asyncCreateMapFlagByFlagData(flagData)
    end
  end)()
end

return MapFlagsComp
