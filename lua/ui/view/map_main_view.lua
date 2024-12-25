local UI = Z.UI
local super = require("ui.ui_view_base")
local Map_mainView = class("Map_mainView", super)
local sceneTableMgr = Z.TableMgr.GetTable("SceneTableMgr")
local sceneTagTableMgr = Z.TableMgr.GetTable("SceneTagTableMgr")
local EntSceneObjectType = Z.PbEnum("EEntityType", "EntSceneObject")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local LERP_RATE = 0.05
local MAX_MENU_FUNC_COUNT = 4

function Map_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "map_main")
  self.mapData_ = Z.DataMgr.Get("map_data")
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.worldQuestVM_ = Z.VMMgr.GetVM("worldquest")
  self.enterDungeonSceneVM_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
  self.mapFlagsComp_ = require("ui/component/map/map_flags_comp").new(self)
  
  function self.onInputAction_(inputActionEventData)
    self:CloseViewByAnim()
  end
  
  self:initSubView()
end

function Map_mainView:initSubView()
  self.RightSubViewDic = {
    [E.MapSubViewType.Info] = require("ui/view/map_info_right_view").new(self),
    [E.MapSubViewType.NormalQuest] = require("ui/view/map_info_quest_right_view").new(self),
    [E.MapSubViewType.EventQuest] = require("ui/view/worldquest_main_sub_view").new(self),
    [E.MapSubViewType.Setting] = require("ui/view/map_setting_sub_view").new(self),
    [E.MapSubViewType.Custom] = require("ui/view/map_custom_sub_view").new(self),
    [E.MapSubViewType.PivotReward] = require("ui/view/pivot_reward_sub_view").new(self),
    [E.MapSubViewType.PivotProgress] = require("ui/view/pivot_progress_sub_view").new(self),
    [E.MapSubViewType.DungeonEnter] = require("ui/view/map_info_entrance_sub_view").new(self),
    [E.MapSubViewType.DungeonAdd] = require("ui/view/dungeon_pioneer_sub_view").new(self)
  }
end

function Map_mainView:OnActive()
  self:initMaskData()
  self:BindEvents()
  self:initMapFuncListWidget()
  self:startAnimatedShow()
  self:initProp()
  self:initComp()
  self:showFuncListBtn()
  self:RegisterInputActions()
  self:initShopBtnState()
  self:showShopBtn()
end

function Map_mainView:OnRefresh()
  self.selectScene_ = self.viewData.sceneId or self.mapVM_.GetMapShowSceneId()
  self:checkCallBack()
end

function Map_mainView:OnDeActive()
  self:clearMaskData()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.uiBinder.dotween_provider_main:Pause()
  self:clearTimer()
  self:UnRegisterInputActions()
  self.mapFlagsComp_:UnInit()
  self.uiBinder.scroll_map:ClearAll()
  self:CloseRightSubview()
  self:removeRedTabDot()
end

function Map_mainView:clearTimer()
  if self.timer_ then
    self.timer_:Stop()
    self.timer_ = nil
  end
end

function Map_mainView:initMaskData()
  self.unlockingIndex_ = ZUtil.Pool.Collections.ZList_int.Rent()
  self.lockIndex_ = ZUtil.Pool.Collections.ZList_int.Rent()
  self.unlockIndex_ = ZUtil.Pool.Collections.ZList_int.Rent()
end

function Map_mainView:clearMaskData()
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
  Z.DataMgr.Get("pivot_data"):SetUnlockPivotId()
end

function Map_mainView:initProp()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.optionNameList_ = {}
  self.optionTokenDict_ = {}
  self.curShowSubView_ = nil
  self.selectScene_ = self.viewData.sceneId or self.mapVM_.GetMapShowSceneId()
  self.selectableSceneList_ = {}
  self.curScale_ = 1
  self.curScaleIdx_ = 0
  self.curLastIdx_ = 0
  self.inTouchCount_ = 0
  self.isLoadEvent_ = false
end

function Map_mainView:GetCacheData()
  local viewData = self.viewData or {}
  viewData.sceneId = self.selectScene_
  viewData.callback = nil
  return viewData
end

function Map_mainView:initComp()
  self.mapFlagsComp_:Init()
  self.uiBinder.node_tips_content:SetLocalPos(960, 0, 0)
  self.uiBinder.event_trigger_map.onClick:AddListener(function(go, eventData)
    if self.inTouchCount_ < 1 then
      local tog = self.uiBinder.togs_flag:GetFirstActiveToggle()
      if tog then
        tog.isOn = false
      end
      local isOk, localPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.node_custom_flags, eventData.position, nil)
      if isOk and not Z.StageMgr.GetIsInDungeon() then
        self:editCustomData(localPos)
      end
    end
    self.inTouchCount_ = self.inTouchCount_ > 0 and self.inTouchCount_ - 1 or 0
  end)
  self:MarkListenerComp(self.uiBinder.event_trigger_map, true)
  self.uiBinder.scroll_map.OnDragEvent:AddListener(function()
    self.inTouchCount_ = 1
  end)
  self.uiBinder.scroll_map.OnScrollEvent:AddListener(function(value)
    self.uiBinder.slider_zoom.value = self.uiBinder.slider_zoom.value + value * 0.1
  end)
  self.uiBinder.comp_double_touch.OnMoveEvent:AddListener(function(value)
    self.inTouchCount_ = 2
    self:doubleGesture(value)
  end)
  self.uiBinder.comp_double_touch.OnBeginMoveEvent:AddListener(function(value)
    self.uiBinder.scroll_map:SetHorizontalOrVertical(false, false)
  end)
  self.uiBinder.comp_double_touch.OnEndMoveEvent:AddListener(function(value)
    self.uiBinder.scroll_map:SetHorizontalOrVertical(true, true)
  end)
  self.uiBinder.comp_double_touch.OnEndTouchEvent:AddListener(function(value)
    self.inTouchCount_ = 0
  end)
  self:MarkListenerComp(self.uiBinder.comp_double_touch, true)
  self.uiBinder.slider_zoom:AddListener(function(value)
    self:setMapZoom(value)
  end)
  self:MarkListenerComp(self.uiBinder.slider_zoom, true)
  self:AddClick(self.uiBinder.btn_close, function()
    self:CloseViewByAnim()
  end)
  self:AddClick(self.uiBinder.btn_setting, function()
    self:SwitchRightSubView(E.MapSubViewType.Custom)
  end)
  self:AddClick(self.uiBinder.btn_zoom_in, function()
    local value = self.uiBinder.slider_zoom.value
    self.uiBinder.slider_zoom.value = value + 0.1
  end)
  self:AddClick(self.uiBinder.btn_zoom_out, function()
    local value = self.uiBinder.slider_zoom.value
    self.uiBinder.slider_zoom.value = value - 0.1
  end)
  self:AddClick(self.uiBinder.btn_goto_shop, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.ShopReputation)
  end)
  self:initDropDown()
  self.uiBinder.comp_mini_map_base:SwitchSceneMap(self.selectScene_)
  local isDungeon, isCanExplore = self:getDungeonState()
  if isDungeon and isCanExplore then
    self:SwitchRightSubView(E.MapSubViewType.DungeonAdd)
  end
end

function Map_mainView:removeRedTabDot()
  if self.redTab_ then
    for _, redId in ipairs(self.redTab_) do
      Z.RedPointMgr.RemoveNodeItem(redId)
    end
    self.redTab_ = nil
  end
end

function Map_mainView:initDropDown()
  self.uiBinder.drop_down:RemoveAllListeners()
  self:refreshDropDownOption()
  self.uiBinder.trans_arrow:SetLocalEuler(0, 180, 0)
  self.uiBinder.drop_down:AddListener(function(index)
    if self.selectableSceneList_[index + 1] == self.selectScene_ then
      return
    end
    self.selectScene_ = self.selectableSceneList_[index + 1]
    self.uiBinder.comp_mini_map_base:SwitchSceneMap(self.selectScene_)
    self.uiBinder.trans_arrow:SetLocalEuler(0, 180, 0)
    self:CloseRightSubview()
  end, true)
  self.uiBinder.drop_down:AddOnClickListener(function()
    self.uiBinder.trans_arrow:SetLocalEuler(180, 180, 0)
    for index, sceneId in ipairs(self.selectableSceneList_) do
      local steerIds = Z.GuideMgr:GetLoadSteerIdByTypeAndParm(E.DynamicSteerType.SceneId, sceneId)
      for i = #steerIds, 1, -1 do
        self.uiBinder.drop_down:AddZUiSteerIdByIndex(index, steerIds[i])
      end
    end
  end)
  self.uiBinder.drop_down:AddHideListener(function()
    self.uiBinder.trans_arrow:SetLocalEuler(0, 180, 0)
  end)
  self:MarkListenerComp(self.uiBinder.drop_down, true)
end

function Map_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.MapSettingChange, self.onMapSettingRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.MapResLoaded, self.onMapResLoaded, self)
  Z.EventMgr:Add(Z.ConstValue.MapOpenSubView, self.onMapOpenSubView, self)
  Z.EventMgr:Add(Z.ConstValue.Pivot.OnPivotUnlock, self.setMapAreaMask, self)
end

function Map_mainView:refreshWorldQuestComp()
  self:showFuncListBtn()
end

function Map_mainView:onMapSettingRefresh(typeId)
  local isShow = self.mapData_:GetMapFlagVisibleSettingByTypeId(typeId)
  self.uiBinder.comp_mini_map_base:SetMapFlagVisibleByTypeId(typeId, isShow)
end

function Map_mainView:getDungeonState()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if dungeonId == 0 then
    return false, false
  end
  local isDungeon = self.enterDungeonSceneVM_.IsDungeon(dungeonId)
  local isCanExplore = false
  if isDungeon then
    local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if cfgData and cfgData.ExploreConfig and next(cfgData.ExploreConfig) ~= nil then
      isCanExplore = true
    end
  end
  return isDungeon, isCanExplore
end

function Map_mainView:setdungeonAddView()
  local isDungeon, isCanExplore = self:getDungeonState()
  if not isDungeon then
    return
  end
  if isCanExplore then
    self.RightSubViewDic[E.MapSubViewType.DungeonAdd]:Show()
  else
    self.RightSubViewDic[E.MapSubViewType.DungeonAdd]:Hide()
  end
end

function Map_mainView:openSubView(flagData, extraParams)
  local cfg = sceneTagTableMgr.GetRow(flagData.TypeId)
  if cfg and cfg.Type == 4 then
    local viewData = {
      data = flagData,
      param = tonumber(cfg.Param)
    }
    self:SwitchRightSubView(E.MapSubViewType.DungeonEnter, viewData)
  elseif flagData.QuestId then
    self:SwitchRightSubView(E.MapSubViewType.NormalQuest, {flagData = flagData})
  elseif flagData.SubType == E.SceneObjType.WorldQuest then
    self:SwitchRightSubView(E.MapSubViewType.EventQuest, self.worldQuestVM_.GetWorldEventViewDataInMap(flagData))
  elseif flagData.FlagType == E.MapFlagType.Custom then
    local viewData = {
      isCreate = false,
      flagData = flagData,
      sceneId = self.selectScene_
    }
    self:SwitchRightSubView(E.MapSubViewType.Setting, viewData)
  elseif flagData.Type == EntSceneObjectType and (flagData.SubType == E.SceneObjType.Pivot or flagData.SubType == E.SceneObjType.Resonance) then
    local id = self.selectScene_ * Z.ConstValue.GlobalLevelIdOffset + flagData.Uid
    local sceneObjectEntityGlobalDataDict = Z.TableMgr.GetLevelGlobalTableDatas(E.LevelTableType.SceneObject)
    local config = sceneObjectEntityGlobalDataDict[id]
    if config ~= nil then
      local sceneObjTbl = Z.TableMgr.GetTable("SceneObjectTableMgr").GetRow(config.Id)
      if sceneObjTbl == nil then
        return
      end
      if sceneObjTbl.SceneObjType ~= E.SceneObjType.Pivot and sceneObjTbl.SceneObjType ~= E.SceneObjType.Resonance then
        return
      end
      local viewData = {
        flagData = flagData,
        isMap = true,
        pivotId = config.Id,
        sceneObjType = sceneObjTbl.SceneObjType,
        extraParams = extraParams
      }
      self:SwitchRightSubView(E.MapSubViewType.PivotReward, viewData)
    else
      logError("[Map] SceneObjectEntityGlobalTable \230\137\190\228\184\141\229\136\176\229\175\185\229\186\148\230\149\176\230\141\174, Id = {0} ", id)
    end
  else
    self:SwitchRightSubView(E.MapSubViewType.Info, {flagData = flagData})
  end
end

function Map_mainView:showOrHideOption(isVisible)
  self:SetUIVisible(self.uiBinder.trans_switch, isVisible)
  self:SetUIVisible(self.uiBinder.trans_left_bg, isVisible)
end

function Map_mainView:showOrHideMapFunc(isVisible)
  self:SetUIVisible(self.uiBinder.node_func_menu_parent, isVisible)
  if self.mapActivityCfgs_ then
    local isBgShow = isVisible and #self.mapActivityCfgs_ > 0
    self:SetUIVisible(self.uiBinder.trans_right_bg, isBgShow)
  else
    self:SetUIVisible(self.uiBinder.trans_right_bg, false)
  end
end

function Map_mainView:SwitchRightSubView(mapSubViewType, viewData)
  local subView = self.RightSubViewDic[mapSubViewType]
  if subView == nil then
    return
  end
  self:showOrHideOption(false)
  self:showOrHideMapFunc(false)
  self:SetUIVisible(self.uiBinder.node_tips_content, false)
  self:SetUIVisible(self.uiBinder.trans_btn_shop, false)
  self:SetUIVisible(self.uiBinder.binder_close_new.Ref, false)
  if self.curShowSubView_ and self.curShowSubView_ ~= subView then
    self.curShowSubView_:DeActive()
  end
  self.curShowSubView_ = subView
  self.curShowSubView_:Active(viewData, self.uiBinder.node_right)
end

function Map_mainView:CloseRightSubview(isTogOff)
  if not isTogOff then
    self:CancelFlagSelect()
  end
  self:showOrHideOption(true)
  self:showOrHideMapFunc(true)
  self:SetUIVisible(self.uiBinder.node_tips_content, true)
  self:SetUIVisible(self.uiBinder.trans_btn_shop, true)
  self:SetUIVisible(self.uiBinder.binder_close_new.Ref, true)
  self:removeOptions()
  if self.curShowSubView_ then
    self.curShowSubView_:DeActive()
  end
  self.curShowSubView_ = nil
end

function Map_mainView:DelCustomFlag()
  self.mapFlagsComp_:RemoveTempMapFlagByFlagData()
end

function Map_mainView:DelCustomFlagById(id)
  local flagData = self.mapFlagsComp_:GetFlagDataByFlagId(id)
  if flagData == nil then
    return
  end
  if self.mapVM_.CheckIsTracingFlagBySrcAndFlagData(E.GoalGuideSource.CustomMapFlag, self.selectScene_, flagData) then
    local guideVM = Z.VMMgr.GetVM("goal_guide")
    guideVM.SetGuideGoals(E.GoalGuideSource.CustomMapFlag, nil)
  end
  self.mapFlagsComp_:RemoveMapFlagAndUnit(flagData)
end

function Map_mainView:GetCurSceneId()
  return self.selectScene_
end

function Map_mainView:CancelFlagSelect()
  self.uiBinder.togs_flag:SetAllTogglesOff()
end

function Map_mainView:GetMapZoom()
  return self.curScale_
end

function Map_mainView:setMapZoom(value)
  local lastScale = self.curScale_
  self.curScale_ = 1 + value
  local x, y = self.uiBinder.trans_map_bg:GetAnchorPosition(nil, nil)
  x = x * self.curScale_ / lastScale
  y = y * self.curScale_ / lastScale
  self.uiBinder.trans_map_bg:SetAnchorPosition(x, y)
  self.uiBinder.comp_mini_map_base:LuaUpdateWhenSlide(self.curScale_)
  self.mapFlagsComp_:OnMapZoomChange()
end

function Map_mainView:doubleGesture(value)
  local scale = self.uiBinder.slider_zoom.value
  self.curScaleIdx_ = self.curScaleIdx_ + value
  local lerp = 0
  if self.curScaleIdx_ ~= self.curLastIdx_ then
    lerp = math.abs(self.curScaleIdx_ - self.curLastIdx_)
  end
  if 0 < value then
    self.uiBinder.slider_zoom.value = scale + lerp / 1 * LERP_RATE
  elseif value < 0 then
    self.uiBinder.slider_zoom.value = scale - lerp / 1 * LERP_RATE
  end
  self.curLastIdx_ = self.curScaleIdx_
end

function Map_mainView:refreshMapInfo()
  self:refreshMap()
  self:setdungeonAddView()
end

function Map_mainView:refreshMap()
  self.mapFlagsComp_:RefreshMap()
  self:refreshStaticInfo()
end

function Map_mainView:refreshStaticInfo()
  local curSceneId = self.mapVM_.GetMapShowSceneId()
  local mapInfoTableRow = Z.TableMgr.GetRow("MapInfoTableMgr", curSceneId)
  if mapInfoTableRow == nil then
    return
  end
  local defaultRatio = mapInfoTableRow.MainMapRatio == nil and 0 or mapInfoTableRow.MainMapRatio / 100
  self.uiBinder.slider_zoom.value = defaultRatio
  self:setMapZoom(defaultRatio)
  self.uiBinder.trans_map_bg:SetAnchorPosition(0, 0)
  self:SetUIVisible(self.uiBinder.trans_player_arrow, self.selectScene_ == curSceneId)
  self:SetUIVisible(self.uiBinder.binder_close_new.Ref, true)
  local isSubViewShow = self.curShowSubView_ and self.curShowSubView_.IsActive
  self:showOrHideOption(not isSubViewShow)
  self:showOrHideMapFunc(not isSubViewShow)
  self:SetUIVisible(self.uiBinder.trans_btn_shop, not isSubViewShow)
end

function Map_mainView:refreshDropDownOption()
  self.selectableSceneList_ = {}
  self.uiBinder.drop_down:ClearOptions()
  local optionList = {}
  local curOptionIndex = 0
  local groupInfoList = self.mapVM_.GetCurSceneGroupList(self.selectScene_)
  for i, info in ipairs(groupInfoList) do
    local row = sceneTableMgr.GetRow(info.Id)
    if row then
      table.insert(self.selectableSceneList_, info.Id)
      table.insert(optionList, row.Name)
      if info.Id == self.selectScene_ then
        curOptionIndex = i - 1
      end
    end
  end
  self.uiBinder.drop_down:AddOptions(optionList)
  self.uiBinder.drop_down.value = curOptionIndex
end

function Map_mainView:OnMapFlagToggleChange(flagData, isOn, noFindAround)
  if isOn then
    if noFindAround then
      self:openSubView(flagData)
    else
      self:onSelectMapFlagWithAround(flagData)
    end
  else
    self:CloseRightSubview(true)
  end
end

function Map_mainView:editCustomData(localPos)
  self:CloseRightSubview()
  local flagData = {}
  flagData.Id = -1
  flagData.Type = -1
  flagData.FlagType = E.MapFlagType.Custom
  flagData.TypeId = E.MapFlagTypeId.CustomTag1
  local sizeX, sizeY = self.uiBinder.trans_map_bg:GetSizeDelta(nil, nil)
  local w = localPos.x / sizeX
  local h = localPos.y / sizeY
  flagData.Pos = Vector2.New(w, h)
  local sceneTagRow = sceneTagTableMgr.GetRow(flagData.TypeId)
  if sceneTagRow then
    flagData.IconPath = sceneTagRow.Icon1
  end
  self.mapFlagsComp_:AddTempMapFlagByFlagData(flagData)
  local viewData = {
    isCreate = true,
    sceneId = self.selectScene_,
    position = {
      x = math.floor(w * Z.ConstValue.MapScalePercent),
      y = math.floor(h * Z.ConstValue.MapScalePercent)
    }
  }
  self:SwitchRightSubView(E.MapSubViewType.Setting, viewData)
end

function Map_mainView:CustomFlagIconChange(path, id)
  local unit
  if id and id ~= 0 then
    unit = self.units[Z.ConstValue.MapCustomFlagName .. id]
  else
    unit = self.units[Z.ConstValue.MapCustomFlagName]
  end
  if unit then
    unit.img_icon:SetImage(path)
  end
end

function Map_mainView:onSelectMapFlagWithAround(flagData)
  local idList = self.uiBinder.comp_mini_map_base:GetAroundList(flagData.Id)
  local aroundList = {}
  for i = 0, idList.count - 1 do
    local flagId = idList[i]
    local originDataList = self.mapFlagsComp_:GetOriginFlagListByFlagId(flagId)
    table.zmerge(aroundList, originDataList)
  end
  local flagCount = table.zcount(aroundList)
  if flagCount == 1 then
    if aroundList[1].TypeId == flagData.TypeId then
      self:openSubView(aroundList[1])
    end
  elseif 1 < flagCount then
    self.mapVM_.SortAroundList(aroundList, flagData.TypeId)
    self:createOptions(aroundList)
  end
end

function Map_mainView:createOptions(aroundList)
  Z.CoroUtil.create_coro_xpcall(function()
    self:removeOptions()
    for idx, flagData in ipairs(aroundList) do
      local unitName = "option" .. idx
      local unitPath = GetLoadAssetPath("mapTagTplPath")
      if flagData.IsTeam then
        unitPath = GetLoadAssetPath("mapTeamTagTplPath")
      end
      local unitToken = self.cancelSource:CreateToken()
      self.optionTokenDict_[unitName] = unitToken
      local unit = self:AsyncLoadUiUnit(unitPath, unitName, self.uiBinder.node_tips_content, unitToken)
      table.insert(self.optionNameList_, unitName)
      if unit then
        if flagData.IsTeam then
          playerPortraitHgr.InsertNewPortraitBySocialData(unit.binder_head, flagData.SocialData)
        else
          unit.img_icon:SetImage(flagData.IconPath)
        end
        unit.lab_content.text = self.mapVM_.FindArroundFlagName(flagData)
        self:AddClick(unit.btn_item, function()
          self:openSubView(flagData)
        end)
      end
    end
  end)()
end

function Map_mainView:removeOptions()
  for _, unitToken in pairs(self.optionTokenDict_) do
    Z.CancelSource.ReleaseToken(unitToken)
  end
  self.optionTokenDict_ = {}
  for _, unitName in ipairs(self.optionNameList_) do
    self:RemoveUiUnit(unitName)
  end
  self.optionNameList_ = {}
end

function Map_mainView:onMapResLoaded(isMiniMap)
  if isMiniMap then
    return
  end
  self:showFuncListBtn()
  self:refreshMapInfo()
  self.uiBinder.comp_mini_map_base:LuaUpdateWhenSlide(self.curScale_)
  self:setMapAreaMask()
  self:showShopBtn()
end

function Map_mainView:setMapAreaMask()
  Z.CoroUtil.create_coro_xpcall(function()
    self:SetUIVisible(self.uiBinder.trans_map_bg, false)
    self.uiBinder.rimg_mapbg_mask.enabled = false
    local sceneId = self:GetCurSceneId()
    local mapInfoTableRow = Z.TableMgr.GetRow("MapInfoTableMgr", sceneId, true)
    if mapInfoTableRow and mapInfoTableRow.IsShowMask then
      local pivotVM = Z.VMMgr.GetVM("pivot")
      local lockList, unlockList, unlockingList = pivotVM.GetScenePivotAreaState(sceneId, false)
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
      if not self.IsActive then
        return
      end
      if 0 < #unlockingList then
        local pivotId = unlockingList[1].Id
        local worldPos = pivotVM.GetPivotWorldPos(sceneId, pivotId)
        if worldPos == nil then
          logError("[MapMainView] Cant find pivot pos, pivotId = " .. pivotId)
          return
        end
        Z.DataMgr.Get("pivot_data"):SetUnlockPivotId()
        local localPos = self.uiBinder.comp_mini_map_base:GetMapPos(worldPos[1], worldPos[2], worldPos[3])
        local worldPos = self.uiBinder.trans_map_bg:TransformPoint(localPos)
        local screenPos = ZTransformUtility.WorldToScreenPoint(worldPos, true)
        self.uiBinder.comp_mini_map_base:PlayMapMaskAnim(screenPos)
      end
    end
    self:SetUIVisible(self.uiBinder.trans_map_bg, true)
  end)()
end

function Map_mainView:startAnimatedShow()
  self.uiBinder.dotween_provider_main:Restart(Z.DOTweenAnimType.Open)
end

function Map_mainView:CloseViewByAnim()
  Z.UIMgr:CloseViewByAnim(self.ViewConfigKey, self.uiBinder.dotween_provider_main, Z.DOTweenAnimType.Close)
end

function Map_mainView:initMapFuncListWidget()
  for i = 1, MAX_MENU_FUNC_COUNT do
    local binder_func = self.uiBinder["binder_map_func_" .. i]
    if binder_func then
      self:AddClick(binder_func.btn_pivot, function()
        self:onMenuBtnClick(i)
      end)
    end
  end
end

function Map_mainView:initShopBtnState()
  local functionTableMgr = Z.TableMgr.GetTable("FunctionTableMgr")
  local functionTableRow = functionTableMgr.GetRow(E.FunctionID.ShopReputation)
  if functionTableRow ~= nil then
    self.uiBinder.lab_goto_shop.text = functionTableRow.Name
  end
end

function Map_mainView:onMenuBtnClick(index)
  Z.VMMgr.GetVM("gotofunc").GoToFunc(self.mapActivityCfgs_[index].FunctionId, self.selectScene_)
end

function Map_mainView:showFuncListBtn()
  self.mapActivityCfgs_ = self.mapVM_.GetMapFuncListShowTab(self.selectScene_)
  local count = #self.mapActivityCfgs_
  if count <= 0 then
    self:SetUIVisible(self.uiBinder.node_func_menu, false)
    return
  end
  self:SetUIVisible(self.uiBinder.node_func_menu, true)
  self:removeRedTabDot()
  self.redTab_ = {}
  count = count > MAX_MENU_FUNC_COUNT and MAX_MENU_FUNC_COUNT or count
  for i = 1, count do
    local binder_func = self.uiBinder["binder_map_func_" .. i]
    if binder_func then
      local cfg = self.mapActivityCfgs_[i]
      binder_func.img_icon:SetImage(cfg.Icon)
      binder_func.lab_name.text = cfg.Name
      binder_func.Ref:SetVisible(binder_func.img_bg, cfg.FunctionId == E.FunctionID.WorldEvent)
      Z.GuideMgr:SetSteerIdByComp(binder_func.comp_steer, E.DynamicSteerType.MapActivityId, cfg.FunctionId)
      binder_func.Ref.UIComp:SetVisible(true)
      Z.RedPointMgr.LoadRedDotItem(cfg.RedDotId, self, binder_func.trans_dot)
      self.redTab_[#self.redTab_ + 1] = cfg.RedDotId
    end
  end
  for i = count + 1, MAX_MENU_FUNC_COUNT do
    local binder_func = self.uiBinder["binder_map_func_" .. i]
    if binder_func then
      binder_func.Ref.UIComp:SetVisible(false)
    end
  end
end

function Map_mainView:showShopBtn()
  if Z.Global.MapShowShopBtnSceneIDs == nil then
    self:SetUIVisible(self.uiBinder.btn_goto_shop, false)
    return
  end
  for i = 0, #Z.Global.MapShowShopBtnSceneIDs do
    if Z.Global.MapShowShopBtnSceneIDs[i] == self.selectScene_ then
      self:SetUIVisible(self.uiBinder.btn_goto_shop, true)
      return
    end
  end
  self:SetUIVisible(self.uiBinder.btn_goto_shop, false)
end

function Map_mainView:checkCallBack()
  if self.viewData and self.viewData.callback then
    self.viewData.callback()
  end
  self.viewData = nil
end

function Map_mainView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.EnableMap)
end

function Map_mainView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.EnableMap)
end

function Map_mainView:startClickBtnAnimatedShow()
  self.uiBinder.dotween_provider_main:Restart(Z.DOTweenAnimType.Tween_0)
end

function Map_mainView:startClickBtnAnimatedHide()
  self.uiBinder.dotween_provider_main:Restart(Z.DOTweenAnimType.Tween_1)
end

function Map_mainView:onMapOpenSubView(subViewType, viewData)
  self:SwitchRightSubView(subViewType, viewData)
end

return Map_mainView
