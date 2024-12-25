local UI = Z.UI
local dataMgr = require("ui.model.data_manager")
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local super = require("ui.ui_subview_base")
local MinimapView = class("MinimapView", super)

function MinimapView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "main_minimap_sub", "main/main_minimap_pc_sub", UI.ECacheLv.High)
  else
    super.ctor(self, "main_minimap_sub", "main/main_minimap_sub", UI.ECacheLv.High)
  end
  self.mapFlagsComp_ = require("ui/component/map/map_flags_comp").new(self, false)
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.miniMapVM_ = Z.VMMgr.GetVM("minimap")
  self.mapData_ = Z.DataMgr.Get("map_data")
  self.planetmemoryVm = Z.VMMgr.GetVM("planetmemory")
  self.trialroadData = Z.DataMgr.Get("trialroad_data")
  self.weeklyHuntData_ = Z.DataMgr.Get("weekly_hunt_data")
end

function MinimapView:OnActive()
  self:initMaskData()
  self:BindLuaAttrWatchers()
  self:BindEvents()
  self:initComp()
  self:initInsightBtn()
  self:initAffixAndMonsterFunction()
  self:initRedDot()
  self:refreshSetting()
  self:refreshInsightBtn()
  self:weeklyHunt()
end

function MinimapView:OnDeActive()
  if Z.IsPCUI then
    keyIconHelper.UnInitKeyIcon(self.uiBinder.com_icon_key_map)
    keyIconHelper.UnInitKeyIcon(self.uiBinder.com_icon_key_insight)
  end
  self:clearMaskData()
  self.mapFlagsComp_:UnInit()
  Z.TipsVM.CloseItemTipsView(self.affixTipsId_)
  if self.dungeonRedpointID_ and self.dungeonRedpointID_ > 0 then
    Z.RedPointMgr.RemoveNodeItem(self.dungeonRedpointID_)
  end
end

function MinimapView:initMaskData()
  self.unlockingIndex_ = ZUtil.Pool.Collections.ZList_int.Rent()
  self.lockIndex_ = ZUtil.Pool.Collections.ZList_int.Rent()
  self.unlockIndex_ = ZUtil.Pool.Collections.ZList_int.Rent()
end

function MinimapView:clearMaskData()
  if self.unlockingIndex_ then
    ZUtil.Pool.Collections.ZList_int.Return(self.unlockingIndex_)
    self.unlockingIndex_ = nil
  end
  if self.lockIndex_ then
    ZUtil.Pool.Collections.ZList_int.Return(self.lockIndex_)
    self.lockIndex_ = nil
  end
  if self.unlockIndex_ then
    ZUtil.Pool.Collections.ZList_int.Return(self.unlockIndex_)
    self.unlockIndex_ = nil
  end
end

function MinimapView:initComp()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:AddAsyncClick(self.uiBinder.btn_open_map, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Map)
  end)
  self:AddAsyncClick(self.uiBinder.btn_pionner, function()
    self.miniMapVM_.OpenDungeonMainWindow()
  end)
  keyIconHelper.InitKeyIcon(self.uiBinder.com_icon_key_map, self.uiBinder.com_icon_key_map, 101)
  self.mapFlagsComp_:Init()
  self.uiBinder.comp_mini_map_base:ChangeMapTex()
end

function MinimapView:OnRefresh()
  self:refreshPionnerProgressView()
end

function MinimapView:GetCurSceneId()
  return Z.StageMgr.GetCurrentSceneId()
end

function MinimapView:refreshSetting()
  local mainvm = Z.VMMgr.GetVM("mainui")
  self:SetUIVisible(self.uiBinder.rimg_map_bg, mainvm.CheckSceneShowMiniMap())
  local proportion = self.mapData_:GetShowProportion()
  local mapSize = self.uiBinder.comp_mini_map_base.OriginSize
  local resultSize
  if proportion == E.ShowProportionType.High then
    resultSize = mapSize * 0.8
    self.uiBinder.comp_mini_map_base.MapSize = resultSize
  elseif proportion == E.ShowProportionType.Middle then
    resultSize = mapSize
    self.uiBinder.comp_mini_map_base.MapSize = resultSize
  elseif proportion == E.ShowProportionType.Low then
    resultSize = mapSize * 1.2
    self.uiBinder.comp_mini_map_base.MapSize = resultSize
  end
  self.uiBinder.trans_map_bg:SetWidthAndHeight(resultSize.x, resultSize.y)
  local focus = self.mapData_:GetViewFocus()
  self.uiBinder.comp_mini_map_base.isFocusDir_ = focus == E.ViewFocusType.focusDir
end

function MinimapView:BindLuaAttrWatchers()
  self.playerStateWatcher = self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrInsightFlag")
  }, Z.EntityMgr.PlayerEnt, self.onInsightChange)
end

function MinimapView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.MapSettingChange, self.onMapSettingRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.MiniMapSettingChange, self.onMiniMapSettingChange, self)
  Z.EventMgr:Add(Z.ConstValue.MapFollowFinish, self.onFollowFinish, self)
  Z.EventMgr:Add(Z.ConstValue.MapResLoaded, self.onMapResLoaded, self)
  Z.EventMgr:Add(Z.ConstValue.PlanetMemory.TipsChange, self.planetmemoryTipsChange, self)
  Z.EventMgr:Add(Z.ConstValue.PlanetMemory.FlowInfoChange, self.planetmemoryFlowInfoChange, self)
  Z.EventMgr:Add(Z.ConstValue.InsightEvent, self.insightBtnClick, self)
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionBtnState, self.refreshInsightState, self)
  Z.EventMgr:Add(Z.ConstValue.Pivot.OnPivotUnlock, self.setMapAreaMask, self)
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onUIClose, self)
end

function MinimapView:onMapResLoaded(isMiniMap)
  if not isMiniMap then
    return
  end
  self.mapFlagsComp_:RefreshMap()
  self:refreshSetting()
  self:setMapAreaMask()
end

function MinimapView:setMapAreaMask()
  Z.CoroUtil.create_coro_xpcall(function()
    self:SetUIVisible(self.uiBinder.rimg_map_bg, false)
    self.uiBinder.rimg_mapbg_mask.enabled = false
    local sceneId = self:GetCurSceneId()
    local mapInfoTableRow = Z.TableMgr.GetRow("MapInfoTableMgr", sceneId, true)
    if mapInfoTableRow and mapInfoTableRow.IsShowMask then
      local pivotVM = Z.VMMgr.GetVM("pivot")
      local lockList, unlockList, unlockingList = pivotVM.GetScenePivotAreaState(sceneId, true)
      self.lockIndex_:Clear()
      self.unlockIndex_:Clear()
      self.unlockingIndex_:Clear()
      for i, v in ipairs(lockList) do
        self.lockIndex_:Add(v.PivotArea)
      end
      for i, v in ipairs(unlockList) do
        self.unlockIndex_:Add(v.PivotArea)
      end
      for i, v in ipairs(unlockingList) do
        self.unlockingIndex_:Add(v.PivotArea)
      end
      local coro = Z.CoroUtil.async_to_sync(self.uiBinder.comp_mini_map_base.SetMapMask)
      coro(self.uiBinder.comp_mini_map_base, sceneId, self.unlockingIndex_, self.lockIndex_, self.unlockIndex_)
    end
    self:SetUIVisible(self.uiBinder.rimg_map_bg, true)
  end)()
end

function MinimapView:onUIClose(viewConfigKey)
  if viewConfigKey and viewConfigKey == "map_main" then
    self:setMapAreaMask()
  end
end

function MinimapView:onFollowFinish(id)
  local flagData = self.mapFlagsComp_:GetFlagDataByFlagId(id)
  if flagData and self.mapVM_.CheckIsTracingFlagBySrcAndFlagData(E.GoalGuideSource.MapFlag, self:GetCurSceneId(), flagData) then
    local guideVM = Z.VMMgr.GetVM("goal_guide")
    guideVM.SetGuideGoals(E.GoalGuideSource.MapFlag, nil)
  end
end

function MinimapView:onMapSettingRefresh(typeId)
  local isShow = self.mapData_:GetMapFlagVisibleSettingByTypeId(typeId)
  self.uiBinder.comp_mini_map_base:SetMapFlagVisibleByTypeId(typeId, isShow)
end

function MinimapView:onMiniMapSettingChange()
  self:refreshSetting()
end

function MinimapView:initInsightBtn()
  keyIconHelper.InitKeyIcon(self.uiBinder.com_icon_key_insight, self.uiBinder.com_icon_key_insight, 34)
  self:AddAsyncClick(self.uiBinder.btn_insight, function()
    self:insightBtnClick()
  end)
end

function MinimapView:insightBtnClick()
  local switchVm = Z.VMMgr.GetVM("switch")
  local isOpen = switchVm.CheckFuncSwitch(E.FunctionID.Insight)
  if isOpen then
    Z.CoroUtil.create_coro_xpcall(function()
      local curInsightState = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value
      local insightVm = Z.VMMgr.GetVM("insight")
      if curInsightState ~= 1 then
        insightVm.OpenInsight(self.cancelSource:CreateToken())
        local goalVM = Z.VMMgr.GetVM("goal")
        goalVM.SetGoalFinish(E.GoalType.OpenInsight)
      else
        insightVm.CloseInsight(self.cancelSource:CreateToken())
      end
    end)()
  end
end

function MinimapView:refreshInsightBtn()
  local switchVm = Z.VMMgr.GetVM("switch")
  local isOpen = switchVm.CheckFuncSwitch(E.FunctionID.Insight)
  self:SetUIVisible(self.uiBinder.btn_insight, isOpen)
end

function MinimapView:onInsightChange()
  local state = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value
  self:SetUIVisible(self.uiBinder.icon_on_insight, state == 1)
  self:SetUIVisible(self.uiBinder.icon_off_insight, state ~= 1)
end

function MinimapView:refreshInsightState(funcId, bSwitch)
  if funcId == E.FunctionID.Insight then
    self:refreshInsightBtn()
    self:onInsightChange()
  end
end

function MinimapView:refreshPionnerProgressView()
  local dungenid = Z.StageMgr.GetCurrentDungeonId()
  self:SetUIVisible(self.uiBinder.cont_pionner, false)
  if dungenid == 0 then
    return
  end
  local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungenid)
  if cfgData == nil or cfgData.ExploreConfig == nil or next(cfgData.ExploreConfig) == nil then
    return
  end
  if Z.VMMgr.GetVM("ui_enterdungeonscene").IsDungeon(dungenid) then
    Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(dungenid)
    self:SetUIVisible(self.uiBinder.cont_pionner, true)
    self:refreshPionnerProgress(false)
    Z.EventMgr:Add("NotifyPoinnersChange", self.onPionnerProgressChanged, self)
    self.dungeonRedpointID_ = Z.VMMgr.GetVM("dungeon").GetRedPointID(dungenid)
    if 0 < self.dungeonRedpointID_ then
      Z.RedPointMgr.LoadRedDotItem(self.dungeonRedpointID_, self, self.uiBinder.node_red_pionner)
    end
  end
end

function MinimapView:onPionnerProgressChanged()
  self:refreshPionnerProgress(true)
end

function MinimapView:refreshPionnerProgress(isChanged)
  local dungenid = Z.StageMgr.GetCurrentDungeonId()
  if dungenid == 0 then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(dungenid)
    local data = dataMgr.Get("dungeon_data")
    local pioneerInfo = data.PioneerInfos[dungenid]
    local progress = pioneerInfo.progress
    self:SetUIVisible(self.uiBinder.cont_pionner, true)
    if isChanged then
      self.uiBinder.comp_text_num_anim:SetIntNumTextAnim(progress, string.format("%s%s", Lang("Explore"), ":{0}%"))
    else
      self.uiBinder.lab_pionner_progress.text = string.format("%s%s", Lang("Explore"), progress .. "%")
    end
    self.uiBinder.comp_img_clip_anim:SetFilled(progress / 100, true)
  end)()
end

function MinimapView:initAffixAndMonsterFunction()
  local dungeonVm_ = Z.VMMgr.GetVM("dungeon")
  local showMonsterOrAffixBtn_ = dungeonVm_.CheckMonsterAndAffixTipShow()
  self:SetUIVisible(self.uiBinder.btn_monster, showMonsterOrAffixBtn_)
  self:SetUIVisible(self.uiBinder.icon_on_monster, false)
  self:AddClick(self.uiBinder.btn_monster, function()
    local dungeonVm_ = Z.VMMgr.GetVM("dungeon")
    dungeonVm_.OpenMonsterAndAffixTip(self.uiBinder.btn_monster.transform)
  end)
end

function MinimapView:planetmemoryTipsChange(eventData)
  if not self.planetmemoryVm.IsPlanetmemory() then
    return
  end
  if eventData.type == E.PlanetMemoryTipsType.Monster then
    self:SetUIVisible(self.uiBinder.icon_on_monster, eventData.state)
  end
end

function MinimapView:planetmemoryFlowInfoChange(flowInfo)
  if flowInfo.state == E.DungeonState.DungeonStateEnd then
    self.trialroadData:ClearPlanetCopyState()
  end
end

function MinimapView:weeklyHunt()
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_weekly_hunt, false)
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if dungeonId == 0 then
    return
  end
  local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if cfgData and cfgData.PlayType == E.DungeonType.WeeklyTower and self.weeklyHuntData_.DungeonLayers[dungeonId] then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_weekly_hunt, true)
    self.uiBinder.lab_hunt_layer.text = string.zconcat(self.weeklyHuntData_.DungeonLayers[dungeonId], "/", self.weeklyHuntData_.MaxLaler, Lang("Layer"))
  end
end

function MinimapView:initRedDot()
  local mainVM = Z.VMMgr.GetVM("mainui")
  if mainVM.CheckSceneShowMiniMap() == false then
    return
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.MapMain, self, self.uiBinder.node_reddot)
end

return MinimapView
