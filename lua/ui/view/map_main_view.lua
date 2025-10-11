local UI = Z.UI
local super = require("ui.ui_view_base")
local Map_mainView = class("Map_mainView", super)
local EntSceneObjectType = Z.PbEnum("EEntityType", "EntSceneObject")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local PC_FLAG_SCALE = 0.65
local LERP_RATE = 0.05
local MAX_MENU_FUNC_COUNT = 4
local MAP_HIGHLIGHT_PREFIX = "ui/textures/map/map_mask_"
local MAP_UNLOCK_ICON = "ui/textures/map/map_name_bg_on"
local MAP_LOCK_ICON = "ui/textures/map/map_name_bg_off"

function Map_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "map_main")
  self.mapData_ = Z.DataMgr.Get("map_data")
  self.mapVM_ = Z.VMMgr.GetVM("map")
  self.worldQuestVM_ = Z.VMMgr.GetVM("worldquest")
  self.enterDungeonSceneVM_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
  self.questIconVM_ = Z.VMMgr.GetVM("quest_icon")
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.mapFlagsComp_ = require("ui/component/map/map_flags_comp").new(self)
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.sceneVM_ = Z.VMMgr.GetVM("scene")
  self:initSubView()
end

function Map_mainView:initSubView()
  self.RightSubViewDic = {
    [E.MapSubViewType.Info] = require("ui/view/map_info_right_view").new(self),
    [E.MapSubViewType.NormalQuest] = require("ui/view/map_info_quest_right_view").new(self),
    [E.MapSubViewType.EventQuest] = require("ui/view/worldquest_main_sub_view").new(self),
    [E.MapSubViewType.Custom] = require("ui/view/map_custom_sub_view").new(self),
    [E.MapSubViewType.PivotReward] = require("ui/view/pivot_reward_sub_view").new(self),
    [E.MapSubViewType.PivotProgress] = require("ui/view/pivot_progress_sub_view").new(self),
    [E.MapSubViewType.DungeonEnter] = require("ui/view/map_info_entrance_sub_view").new(self),
    [E.MapSubViewType.DungeonAdd] = require("ui/view/dungeon_pioneer_sub_view").new(self),
    [E.MapSubViewType.Collection] = require("ui/view/map_life_profession_item_right_sub_view").new(self),
    [E.MapSubViewType.SceneLock] = require("ui/view/map_lock_sub_view").new(self)
  }
  self.LeftSubViewDic = {
    [E.MapSubViewType.LifeSystem] = require("ui/view/map_sys_left_sub_view").new(self)
  }
end

function Map_mainView:OnActive()
  Z.AudioMgr:Play("sys_map_open")
  self:initMaskData()
  self:BindEvents()
  self:initMapFuncListWidget()
  self:initProp()
  self:refreshWorldMapPos()
  self:initComp()
  self:showFuncListBtn()
end

function Map_mainView:OnRefresh()
  self.selectScene_ = self.viewData.sceneId or self.mapVM_.GetMapShowSceneId()
  self:checkSceneUnlock(self.selectScene_)
  self.isCanSwitchWorldMap_ = self.mapVM_.IsCanSwitchWorldMap(self.selectScene_)
  self:switchAreaMap()
  self:checkCallBack()
end

function Map_mainView:OnDeActive()
  self:clearMaskData()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.uiBinder.binder_world_map.comp_player_flag:UnInit()
  self:stopAllHighlight()
  self:clearTimer()
  self.mapFlagsComp_:UnInit()
  self.uiBinder.scroll_map:ClearAll()
  self:CloseLeftSubView()
  self:CloseRightSubView()
  self:removeRedTabDot()
  self:clearAreaMapName()
  self:clearWorldMapFlag()
  self:clearWorldMapAreaItem()
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
  self.areaItemUnitDict_ = {}
  self.curShowSubView_ = nil
  self.selectScene_ = self.viewData.sceneId or self.mapVM_.GetMapShowSceneId()
  self.isCanSwitchWorldMap_ = self.mapVM_.IsCanSwitchWorldMap(self.selectScene_)
  self.selectableSceneList_ = {}
  self.curScale_ = 1
  self.curScaleIdx_ = 0
  self.curLastIdx_ = 0
  self.inTouchCount_ = 0
  self.curMapMode_ = E.MapMode.Area
  self.adjustZoomValueDirty_ = true
  self.lastMapAnchorPos_ = nil
  self.lastMapZoomValue_ = nil
  self.isSwitching_ = false
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
      if self.curMapMode_ == E.MapMode.Area then
        if eventData.pointerId == 0 or eventData.pointerId == -2 then
          local isSuccess, localPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.node_custom_flags, eventData.position, nil)
          if isSuccess and not Z.StageMgr.GetIsInDungeon() then
            self:editCustomData(localPos)
          end
        end
      else
        local sceneId = self:getSceneIdByScreenPosition(eventData.position)
        if sceneId and self:checkSceneUnlock(sceneId) then
          self:switchAreaMapWithRevert(sceneId)
        end
      end
    end
    self.inTouchCount_ = self.inTouchCount_ > 0 and self.inTouchCount_ - 1 or 0
  end)
  self.uiBinder.event_trigger_map.onDown:AddListener(function(go, eventData)
    if self.inTouchCount_ > 0 then
      return
    end
    if self:isShowHighLight() then
      return
    end
    local sceneId = self:getSceneIdByScreenPosition(eventData.position)
    if sceneId then
      self:doHightLightShow(true, sceneId)
    end
  end)
  self.uiBinder.event_trigger_map.onUp:AddListener(function(go, eventData)
    if self:isShowHighLight() then
      return
    end
    self:stopAllHighlight()
  end)
  self:MarkListenerComp(self.uiBinder.event_trigger_map, true)
  self.uiBinder.scroll_map.OnDragEvent:AddListener(function()
    self.inTouchCount_ = 1
  end)
  self.uiBinder.scroll_map.OnScrollEvent:AddListener(function(value)
    if self.isSwitching_ then
      return
    end
    self.uiBinder.slider_zoom.value = self.uiBinder.slider_zoom.value + value * 0.05
  end)
  self.uiBinder.comp_double_touch.OnMoveEvent:AddListener(function(value)
    if self.isSwitching_ then
      return
    end
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
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_zoom_in, function()
    local value = self.uiBinder.slider_zoom.value
    self.uiBinder.slider_zoom.value = value + 0.1
  end)
  self:AddClick(self.uiBinder.btn_zoom_out, function()
    local value = self.uiBinder.slider_zoom.value
    self.uiBinder.slider_zoom.value = value - 0.1
  end)
  self:AddClick(self.uiBinder.btn_setting, function()
    self:SwitchLeftSubView(E.MapSubViewType.LifeSystem)
  end)
  self:AddClick(self.uiBinder.btn_return_world, function()
    if self.curMapMode_ == E.MapMode.Area and self.isCanSwitchWorldMap_ then
      local switchRatio = Z.Global.MapRatio[3]
      self.uiBinder.slider_zoom.value = switchRatio * 0.5
    end
  end)
  self:AddClick(self.uiBinder.btn_return_area, function()
    if self.curMapMode_ == E.MapMode.World then
      local curSceneId = self.mapVM_.GetMapShowSceneId()
      self:switchAreaMapWithRevert(curSceneId)
    end
  end)
  self.uiBinder.binder_world_map.comp_player_flag:Init()
  self:AddClick(self.uiBinder.binder_world_map.btn_player_flag, function()
    local curSceneId = self.mapVM_.GetMapShowSceneId()
    self:onWorldMapFlagClick(self.uiBinder.binder_world_map.comp_player_flag, curSceneId)
  end)
  self:initDropDown()
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
  self.uiBinder.drop_down:AddListener(function(index)
    local targetSceneId = self.selectableSceneList_[index + 1]
    if targetSceneId == self.selectScene_ then
      return
    end
    if not self:checkSceneUnlock(targetSceneId) then
      return
    end
    self.selectScene_ = targetSceneId
    self.curMapMode_ = E.MapMode.Area
    self.adjustZoomValueDirty_ = true
    self:refreshDropShow(false)
    self:switchMapMode()
  end, true)
  self.uiBinder.drop_down:AddOnClickListener(function()
    for index, sceneId in ipairs(self.selectableSceneList_) do
      local steerIds = Z.GuideMgr:GetLoadSteerIdByTypeAndParam(E.DynamicSteerType.SceneId, sceneId)
      for i = #steerIds, 1, -1 do
        self.uiBinder.drop_down:AddZUiSteerIdByIndex(index, steerIds[i])
      end
    end
    self:refreshDropShow(true)
  end)
  self.uiBinder.drop_down:AddHideListener(function()
    self:refreshDropShow(false)
  end)
  self:MarkListenerComp(self.uiBinder.drop_down, true)
end

function Map_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.MapSettingChange, self.onMapSettingRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.MapResLoaded, self.onMapResLoaded, self)
  Z.EventMgr:Add(Z.ConstValue.MapOpenSubView, self.onMapOpenSubView, self)
  Z.EventMgr:Add(Z.ConstValue.Pivot.OnPivotUnlock, self.setMapAreaMask, self)
  Z.EventMgr:Add(Z.ConstValue.Screen.UIResolutionChange, self.onScreenResolutionChange, self)
  Z.EventMgr:Add(Z.ConstValue.PathFinding.onStageChange, self.onPathFindingStageChange, self)
end

function Map_mainView:switchMapMode()
  if self.isSwitching then
    return
  end
  self.isSwitching_ = true
  self.uiBinder.slider_zoom.enabled = false
  self.uiBinder.comp_double_touch.enabled = false
  Z.UIMgr:FadeIn({
    TimeOut = 5,
    IsInstant = true,
    OpenAnimType = Z.DOTweenAnimType.Tween_0
  })
  self:CloseRightSubView()
  self:CloseLeftSubView()
  if self.curMapMode_ == E.MapMode.Area then
    self.uiBinder.comp_mini_map_base:SwitchSceneMap(self.selectScene_)
  else
    self.uiBinder.comp_mini_map_base:SwitchWorldMap()
  end
end

function Map_mainView:switchAreaMap(targetSceneId)
  self.curMapMode_ = E.MapMode.Area
  self.selectScene_ = targetSceneId or self.selectScene_
  for index, sceneId in ipairs(self.selectableSceneList_) do
    if sceneId == self.selectScene_ then
      self.uiBinder.drop_down.value = index - 1
      break
    end
  end
  self:switchMapMode()
end

function Map_mainView:switchWorldMap()
  if not self.isCanSwitchWorldMap_ then
    return
  end
  self.curMapMode_ = E.MapMode.World
  if self.lastMapAnchorPos_ == nil then
    local info = self.worldMapInfoDict_[self.selectScene_]
    local posX = info and info.PosX or 0
    local posY = info and info.PosY or 0
    self.lastMapAnchorPos_ = {
      -posX * self.curScale_,
      -posY * self.curScale_
    }
  end
  self:switchMapMode()
end

function Map_mainView:switchAreaMapWithRevert(sceneId)
  Z.AudioMgr:Play("UI_Event_MapIn")
  self.adjustZoomValueDirty_ = true
  self.lastMapZoomValue_ = self.uiBinder.slider_zoom.value
  local lastAnchorX, lastAnchorY = self.uiBinder.trans_map_bg:GetAnchorPosition(nil, nil)
  self.lastMapAnchorPos_ = {lastAnchorX, lastAnchorY}
  self:switchAreaMap(sceneId)
end

function Map_mainView:checkSceneUnlock(sceneId)
  if self.sceneVM_.CheckSceneUnlock(sceneId, false) then
    return true
  else
    self:SwitchRightSubView(E.MapSubViewType.SceneLock, {sceneId = sceneId})
    return false
  end
end

function Map_mainView:getCenterMapSceneId()
  local centerPointerPos = Vector2.New(UnityEngine.Screen.width * 0.5, UnityEngine.Screen.height * 0.5)
  return self:getSceneIdByScreenPosition(centerPointerPos)
end

function Map_mainView:getSceneIdByScreenPosition(screenPosition)
  local isSuccess, localPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.trans_map_bg, screenPosition, nil)
  if isSuccess then
    local x, y = self.uiBinder.trans_map_bg:GetSizeDelta(nil, nil)
    local clickPosX = localPos.x + x * 0.5
    local clickPosY = localPos.y + y * 0.5
    local ratioX = clickPosX / x
    local ratioY = clickPosY / y
    if 0 < ratioX and 0 < ratioY then
      local result, areaIndex = Z.MiniMapManager:GetWorldMapBitIndex(ratioX, ratioY, nil)
      if result and areaIndex then
        local sceneId = self.areaIndexDict_[areaIndex]
        return sceneId
      end
    end
  end
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

function Map_mainView:setDungeonAddView()
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
  local cfg = Z.TableMgr.GetRow("SceneTagTableMgr", flagData.TypeId)
  if cfg and cfg.Type == E.SceneTagType.Dungeon then
    local viewData = {
      data = flagData,
      param = tonumber(cfg.Param)
    }
    self:SwitchRightSubView(E.MapSubViewType.DungeonEnter, viewData)
  elseif cfg and cfg.Type == E.SceneTagType.SceneEnter then
    local targetSceneId = tonumber(cfg.Param)
    local curSceneId = self.curMapMode_ == E.MapMode.Area and self.selectScene_ or nil
    self:SwitchRightSubView(E.MapSubViewType.SceneLock, {
      sceneId = targetSceneId,
      curSceneId = curSceneId,
      flagData = flagData
    })
  elseif flagData.QuestId then
    self:SwitchRightSubView(E.MapSubViewType.NormalQuest, {flagData = flagData})
  elseif flagData.SubType == E.SceneObjType.WorldQuest then
    self:SwitchRightSubView(E.MapSubViewType.EventQuest, self.worldQuestVM_.GetWorldEventViewDataInMap(flagData))
  elseif flagData.SubType == E.SceneObjType.Collection then
    self:SwitchRightSubView(E.MapSubViewType.Collection, {flagData = flagData})
  elseif flagData.FlagType == E.MapFlagType.Custom then
    local viewData = {
      isCreate = false,
      flagData = flagData,
      sceneId = self.selectScene_
    }
    self:SwitchRightSubView(E.MapSubViewType.Custom, viewData)
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

function Map_mainView:showOrHideMapFunc(isVisible)
  self:SetUIVisible(self.uiBinder.node_func_menu_parent, isVisible)
end

function Map_mainView:SwitchRightSubView(mapSubViewType, viewData)
  local subView = self.RightSubViewDic[mapSubViewType]
  if subView == nil then
    return
  end
  if self.curShowSubView_ and self.curShowSubView_ ~= subView then
    self.curShowSubView_:DeActive()
  end
  self.curShowSubView_ = subView
  self.curShowSubView_:Active(viewData, self.uiBinder.node_right_sub_view)
  self:refreshMapFuncParent()
  self:SetUIVisible(self.uiBinder.node_right_info, false)
end

function Map_mainView:CloseRightSubView(isTogOff)
  if not isTogOff then
    self:CancelFlagSelect()
  end
  if self.curShowSubView_ then
    self.curShowSubView_:DeActive()
  end
  self.curShowSubView_ = nil
  self:removeOptions()
  self:refreshMapFuncParent()
  self:SetUIVisible(self.uiBinder.node_right_info, true)
end

function Map_mainView:SwitchLeftSubView(mapSubViewType, viewData)
  local subView = self.LeftSubViewDic[mapSubViewType]
  if subView == nil then
    return
  end
  self:SetUIVisible(self.uiBinder.node_left_info, false)
  if self.curShowLeftSubView_ and self.curShowLeftSubView_ ~= subView then
    self.curShowLeftSubView_:DeActive()
  end
  self.curShowLeftSubView_ = subView
  self.curShowLeftSubView_:Active(viewData, self.uiBinder.node_left_sub_view)
end

function Map_mainView:CloseLeftSubView()
  self:SetUIVisible(self.uiBinder.node_left_info, true)
  self:removeOptions()
  if self.curShowLeftSubView_ then
    self.curShowLeftSubView_:DeActive()
  end
  self.curShowLeftSubView_ = nil
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

function Map_mainView:IsWorldMap()
  return self.curMapMode_ == E.MapMode.World
end

function Map_mainView:GetCurSceneId()
  return self.selectScene_
end

function Map_mainView:CancelFlagSelect()
  self.uiBinder.togs_flag:SetAllTogglesOff()
end

function Map_mainView:GetCurrentAllFlagList()
  if self.curMapMode_ == E.MapMode.World then
    return {}
  else
    return self.mapFlagsComp_:GetAllFlagDataList()
  end
end

function Map_mainView:GetMapZoom()
  return self.curScale_
end

function Map_mainView:setMapZoom(value)
  if self.isSwitching_ then
    return
  end
  local offsetValue = value
  if self.isCanSwitchWorldMap_ then
    if value >= Z.Global.MapRatio[3] then
      offsetValue = (value - Z.Global.MapRatio[3]) * Z.Global.MapRatio[2]
    else
      offsetValue = (value - 0 + Z.Global.MapRatio[4]) * Z.Global.MapRatio[1]
    end
  end
  local lastScale = self.curScale_
  self.curScale_ = 1 + offsetValue
  local lastAnchorX, lastAnchorY = self.uiBinder.trans_map_bg:GetAnchorPosition(nil, nil)
  if not self:checkZoomValue(lastAnchorX, lastAnchorY, lastScale) then
    local newAnchorX = lastAnchorX * self.curScale_ / lastScale
    local newAnchorY = lastAnchorY * self.curScale_ / lastScale
    self.uiBinder.trans_map_bg:SetAnchorPosition(newAnchorX, newAnchorY)
    self.uiBinder.comp_mini_map_base:LuaUpdateWhenSlide(self.curScale_)
    self.mapFlagsComp_:OnMapZoomChange()
  end
  self:checkHighlightShow()
  self:checkAreaNameShow()
  self:checkScaleChange()
end

function Map_mainView:checkZoomValue(lastAnchorX, lastAnchorY, lastScale)
  if not self.isCanSwitchWorldMap_ then
    return false
  end
  local thresholdValue = Z.Global.MapRatio[3]
  if thresholdValue <= self.uiBinder.slider_zoom.value then
    if self.curMapMode_ == E.MapMode.World then
      local targetSceneId = self:getCenterMapSceneId()
      if targetSceneId and self:checkSceneUnlock(targetSceneId) then
        self:switchAreaMapWithRevert(targetSceneId)
        return true
      else
        self.curScale_ = lastScale
        self.uiBinder.slider_zoom:SetValueWithoutNotify(thresholdValue)
        return false
      end
    end
  elseif self.curMapMode_ == E.MapMode.Area then
    self:switchWorldMap()
    return true
  end
  return false
end

function Map_mainView:isShowHighLight()
  if self.uiBinder.slider_zoom.value < Z.Global.MapRatio[3] and self.uiBinder.slider_zoom.value >= Z.Global.MapRatio[5] then
    return true
  else
    return false
  end
end

function Map_mainView:checkHighlightShow()
  local isShowHighLight = self:isShowHighLight()
  for sceneId, info in pairs(self.worldMapInfoDict_) do
    self:doHightLightShow(isShowHighLight, sceneId)
  end
end

function Map_mainView:stopAllHighlight()
  for sceneId, info in pairs(self.worldMapInfoDict_) do
    self:doHightLightShow(false, sceneId, true)
  end
end

function Map_mainView:doHightLightShow(isHighLight, sceneId, isForce)
  if self.worldMapInfoDict_[sceneId].AreaId == 0 then
    return
  end
  if not isForce and (self.isSwitching_ or self.curMapMode_ == E.MapMode.Area) then
    return
  end
  local areaItem = self.areaItemUnitDict_["area_item_" .. sceneId]
  if areaItem == nil then
    return
  end
  if isHighLight and areaItem.canvas_group.alpha == 0 then
    areaItem.canvas_group.alpha = 1
    areaItem.comp_dotween:DoCanvasGroupYoyo(0.2, 1.5)
  elseif not isHighLight and 0 < areaItem.canvas_group.alpha then
    areaItem.comp_dotween:ClearAll()
    areaItem.canvas_group.alpha = 0
  end
end

function Map_mainView:checkScaleChange()
  if not self.isCanSwitchWorldMap_ then
    return
  end
  self.uiBinder.binder_world_map.Trans:SetScale(self.curScale_, self.curScale_, 1)
  local flagScale = self:getFlagScale()
  self.uiBinder.binder_world_map.node_world_player:SetScale(flagScale, flagScale, 1)
  if self.worldUnitDict_ then
    for unitName, unitItem in pairs(self.worldUnitDict_) do
      unitItem.Trans:SetScale(flagScale, flagScale, 1)
    end
  end
  if self.mapAreaUnitDict_ then
    for unitName, unitItem in pairs(self.mapAreaUnitDict_) do
      unitItem.Trans:SetScale(flagScale, flagScale, 1)
    end
  end
  if self.areaItemUnitDict_ then
    for unitName, unitItem in pairs(self.areaItemUnitDict_) do
      unitItem.btn_inner_icon.transform:SetScale(flagScale, flagScale, 1)
    end
  end
end

function Map_mainView:checkAreaNameShow()
  if self.mapAreaUnitDict_ == nil or self.worldMapInfoDict_ == nil then
    return
  end
  for sceneId, info in pairs(self.worldMapInfoDict_) do
    local unitName = "map_name_" .. sceneId
    local unitItem = self.mapAreaUnitDict_[unitName]
    if unitItem then
      if info.InnerIcon == "" then
        unitItem.Ref.UIComp:SetVisible(true)
      else
        unitItem.Ref.UIComp:SetVisible(self.uiBinder.slider_zoom.value >= Z.Global.MapRatio[6])
      end
    end
  end
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
  self:setDungeonAddView()
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
  if self.curMapMode_ == E.MapMode.World then
    self.uiBinder.comp_aspect_fitter.CurFitType = Panda.ZUi.ScreenFitType.FullScreenOutSide
  else
    self.uiBinder.comp_aspect_fitter.CurFitType = Panda.ZUi.ScreenFitType.FullScreenInside
  end
  self.uiBinder.comp_aspect_fitter:SetFullRect()
  self:refreshWorldMapPos()
  if self.adjustZoomValueDirty_ then
    self.adjustZoomValueDirty_ = false
    local switchRatio = Z.Global.MapRatio[3]
    local targetValue = 0
    if self.curMapMode_ == E.MapMode.Area then
      local defaultRatio = mapInfoTableRow.MainMapRatio == nil and 0 or mapInfoTableRow.MainMapRatio / 100
      if not self.isCanSwitchWorldMap_ then
        targetValue = 0.5
      else
        targetValue = switchRatio + defaultRatio * (1 - switchRatio)
      end
    else
      targetValue = switchRatio * 0.5
    end
    self.uiBinder.slider_zoom.value = targetValue
    self:setMapZoom(targetValue)
  end
  if self.curMapMode_ == E.MapMode.World and self.lastMapZoomValue_ then
    self.uiBinder.slider_zoom.value = self.lastMapZoomValue_
    self:setMapZoom(self.lastMapZoomValue_)
    self.lastMapZoomValue_ = nil
  end
  if self.curMapMode_ == E.MapMode.World and self.lastMapAnchorPos_ then
    self.uiBinder.trans_map_bg:SetAnchorPosition(self.lastMapAnchorPos_[1], self.lastMapAnchorPos_[2])
    self.lastMapAnchorPos_ = nil
  else
    self.uiBinder.trans_map_bg:SetAnchorPosition(0, 0)
  end
  self:refreshMapFuncParent()
  self:SetUIVisible(self.uiBinder.trans_player_arrow, self.selectScene_ == curSceneId)
  self:SetUIVisible(self.uiBinder.node_world, self.curMapMode_ == E.MapMode.World)
  self:SetUIVisible(self.uiBinder.node_world_map, self.curMapMode_ == E.MapMode.World)
  self:SetUIVisible(self.uiBinder.node_world_map_name, self.curMapMode_ == E.MapMode.World)
  self:SetUIVisible(self.uiBinder.node_area, self.curMapMode_ == E.MapMode.Area)
  self:SetUIVisible(self.uiBinder.node_area_map, self.curMapMode_ == E.MapMode.Area)
  self:SetUIVisible(self.uiBinder.node_area_map_name, self.curMapMode_ == E.MapMode.Area)
  self:SetUIVisible(self.uiBinder.btn_setting, self.curMapMode_ == E.MapMode.Area)
  self:SetUIVisible(self.uiBinder.btn_return_world, self.curMapMode_ == E.MapMode.Area and self.isCanSwitchWorldMap_)
  self:SetUIVisible(self.uiBinder.btn_return_area, self.curMapMode_ == E.MapMode.World)
  self.uiBinder.scroll_map:SetMovementType(self.curMapMode_ == E.MapMode.Area and 0 or 1)
  if self.curMapMode_ == E.MapMode.World then
    self:refreshWorldMapFlag(curSceneId)
  else
    self:refreshDropDownOption()
    local row = Z.TableMgr.GetRow("SceneTableMgr", self.selectScene_)
    if row then
      self.uiBinder.lab_area_map_name.text = row.Name
    end
  end
end

function Map_mainView:refreshMapFuncParent()
  local isSubViewShow = self.curShowSubView_ and self.curShowSubView_.IsActive
  self:showOrHideMapFunc(not isSubViewShow)
end

function Map_mainView:refreshDropDownOption()
  self.selectableSceneList_ = {}
  self.uiBinder.drop_down:ClearOptions()
  local optionList = {}
  local curOptionIndex = 0
  local groupInfoList = self.mapVM_.GetCurSceneGroupList(self.selectScene_)
  for i, info in ipairs(groupInfoList) do
    local row = Z.TableMgr.GetRow("SceneTableMgr", info.Id)
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
  self.uiBinder.drop_down.enabled = 1 < #optionList
  self:refreshDropShow(false)
end

function Map_mainView:refreshDropShow(dropDownShow)
  local isCanDropDown = #self.selectableSceneList_ > 1
  self:SetUIVisible(self.uiBinder.slider_zoom, not dropDownShow)
  self:SetUIVisible(self.uiBinder.trans_drop_down_line, dropDownShow)
  self:SetUIVisible(self.uiBinder.img_arrow_down, dropDownShow)
  self:SetUIVisible(self.uiBinder.img_arrow_up, not dropDownShow and isCanDropDown)
  self:SetUIVisible(self.uiBinder.img_arrow_down_1, dropDownShow)
  self:SetUIVisible(self.uiBinder.img_arrow_up_1, not dropDownShow and isCanDropDown)
end

function Map_mainView:getDiffRatio()
  local sourceWidth = Z.UIRoot.ScreenDesignSize.x
  local sourceHeight = Z.UIRoot.ScreenDesignSize.y
  local currentWidth = self.uiBinder.trans_map_bg.parent.rect.width
  local currentHeight = self.uiBinder.trans_map_bg.parent.rect.height
  local sourceSize
  if sourceWidth > sourceHeight then
    sourceSize = Vector2.New(sourceHeight, sourceHeight)
  else
    sourceSize = Vector2.New(sourceWidth, sourceWidth)
  end
  local currentSize
  if currentWidth > currentHeight then
    currentSize = Vector2.New(currentHeight, currentHeight)
  else
    currentSize = Vector2.New(currentWidth, currentWidth)
  end
  local xRatio = currentSize.x / sourceSize.x
  local yRatio = currentSize.y / sourceSize.y
  return xRatio, yRatio
end

function Map_mainView:getFlagScale()
  local flagScale = 1 / self.curScale_
  if Z.IsPCUI then
    flagScale = flagScale * PC_FLAG_SCALE
  end
  return flagScale
end

function Map_mainView:refreshWorldMapPos()
  local xDiffRatio, yDiffRatio = self:getDiffRatio()
  self.areaIndexDict_ = {}
  self.worldMapSceneIdList_ = {}
  self.worldMapInfoDict_ = {}
  local mapInfoData = Z.TableMgr.GetTable("MapInfoTableMgr").GetDatas()
  for id, info in pairs(mapInfoData) do
    if #info.WorldMapCenterPos > 0 then
      if 0 < info.AreaId then
        self.areaIndexDict_[info.AreaId] = id
      end
      local posX = info.WorldMapCenterPos[1] * xDiffRatio
      local posY = info.WorldMapCenterPos[2] * yDiffRatio
      local width = info.WorldMapCenterPos[3] * xDiffRatio
      local height = info.WorldMapCenterPos[4] * yDiffRatio
      self.worldMapInfoDict_[id] = {
        PosX = posX,
        PosY = posY,
        Width = width,
        Height = height,
        AreaId = info.AreaId,
        InnerIcon = info.InnerIcon
      }
      table.insert(self.worldMapSceneIdList_, id)
    end
  end
end

function Map_mainView:refreshWorldMapFlag(curSceneId)
  local posInfo = self.worldMapInfoDict_[curSceneId]
  if posInfo then
    self.uiBinder.binder_world_map.node_world_player:SetAnchorPosition(posInfo.PosX, posInfo.PosY)
    self.uiBinder.binder_world_map.comp_player_flag:ResetLocalPos(posInfo.PosX, posInfo.PosY)
    self.uiBinder.binder_world_map.anim_arrow:PlayLoop("anim_map_main_loop")
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:clearWorldMapAreaItem()
    self:createWorldMapAreaItem()
    self:clearWorldMapFlag()
    self:createWorldMapFlag()
    self:clearAreaMapName()
    self:createAreaMapName()
  end)()
end

function Map_mainView:createWorldMapAreaItem()
  local unitPath = GetLoadAssetPath("mapAreaItemAssetPath")
  local unitParent = self.uiBinder.binder_world_map.node_area
  for sceneId, info in pairs(self.worldMapInfoDict_) do
    local unitName = "area_item_" .. sceneId
    local unitToken = self.cancelSource:CreateToken()
    self.areaItemUnitTokenDict_[unitName] = unitToken
    local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, unitParent, unitToken)
    self.areaItemUnitDict_[unitName] = unitItem
    unitItem.Trans:SetAnchorPosition(info.PosX, info.PosY)
    unitItem.Trans:SetSizeDelta(info.Width, info.Height)
    local flagScale = self:getFlagScale()
    unitItem.btn_inner_icon.transform:SetScale(flagScale, flagScale, 1)
    if info.AreaId > 0 then
      unitItem.rimg_highlight:SetImage(MAP_HIGHLIGHT_PREFIX .. sceneId)
      unitItem.Ref:SetVisible(unitItem.node_highlight, true)
    else
      unitItem.Ref:SetVisible(unitItem.node_highlight, false)
    end
    if info.InnerIcon ~= "" then
      unitItem.img_inner_icon:SetImage(info.InnerIcon)
      unitItem.btn_inner_icon:AddListener(function()
        if self:checkSceneUnlock(sceneId) then
          self:switchAreaMapWithRevert(sceneId)
        end
      end)
      unitItem.Ref:SetVisible(unitItem.btn_inner_icon, true)
    else
      unitItem.Ref:SetVisible(unitItem.btn_inner_icon, false)
    end
  end
end

function Map_mainView:clearWorldMapAreaItem()
  if self.areaItemUnitTokenDict_ then
    for unitName, unitToken in pairs(self.areaItemUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.areaItemUnitTokenDict_ = {}
  if self.areaItemUnitDict_ then
    for unitName, unitItem in pairs(self.areaItemUnitDict_) do
      unitItem.comp_dotween:ClearAll()
      unitItem.canvas_group.alpha = 0
      self:RemoveUiUnit(unitName)
    end
  end
  self.areaItemUnitDict_ = {}
end

function Map_mainView:createWorldMapFlag()
  local goalInfoList = self.mapVM_.CollectWorldMapQuestGoalInfos(self.worldMapSceneIdList_)
  local unitPath = GetLoadAssetPath("mapWorldFlagAssetPath")
  local trackRow = Z.TableMgr.GetRow("TargetTrackTableMgr", E.GoalGuideSource.Quest)
  local sceneIndexDict = {}
  for i, goalInfo in ipairs(goalInfoList) do
    local areaItem = self.areaItemUnitDict_["area_item_" .. goalInfo.SceneId]
    if areaItem then
      local unitName = string.zconcat("world_flag_", goalInfo.SceneId, "_", goalInfo.Uid)
      local unitToken = self.cancelSource:CreateToken()
      self.worldUnitTokenDict_[unitName] = unitToken
      local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, areaItem.trans_flag_root, unitToken)
      self.worldUnitDict_[unitName] = unitItem
      if sceneIndexDict[goalInfo.SceneId] == nil then
        sceneIndexDict[goalInfo.SceneId] = {}
      end
      table.insert(sceneIndexDict[goalInfo.SceneId], unitItem)
      unitItem.world_map_flag:Init()
      unitItem.Ref:SetVisible(unitItem.effect_trace, true)
      unitItem.effect_trace:SetEffectGoVisible(true)
      unitItem.btn_icon:AddListener(function()
        self:onWorldMapFlagClick(unitItem.world_map_flag, goalInfo.SceneId)
      end)
      self:refreshWorldMapFlagUnit(unitItem, goalInfo, trackRow)
    end
  end
  self:refreshWorldMapFlagPos(sceneIndexDict)
end

function Map_mainView:clearWorldMapFlag()
  if self.worldUnitTokenDict_ then
    for unitName, unitToken in pairs(self.worldUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.worldUnitTokenDict_ = {}
  if self.worldUnitDict_ then
    for unitName, unitItem in pairs(self.worldUnitDict_) do
      unitItem.world_map_flag:UnInit()
      self:RemoveUiUnit(unitName)
    end
  end
  self.worldUnitDict_ = {}
end

function Map_mainView:createAreaMapName()
  local unitPath = GetLoadAssetPath("mapNameTplPath")
  for sceneId, info in pairs(self.worldMapInfoDict_) do
    local areaItem = self.areaItemUnitDict_["area_item_" .. sceneId]
    if areaItem then
      local unitName = "map_name_" .. sceneId
      local unitToken = self.cancelSource:CreateToken()
      self.mapAreaUnitTokenDict_[unitName] = unitToken
      local unitItem = self:AsyncLoadUiUnit(unitPath, unitName, areaItem.trans_flag_root, unitToken)
      self.mapAreaUnitDict_[unitName] = unitItem
      local config = Z.TableMgr.GetRow("SceneTableMgr", sceneId)
      if config then
        local sceneUnlock = self.sceneVM_.CheckSceneUnlock(sceneId, false)
        unitItem.rimg_unlock:SetImage(sceneUnlock and MAP_UNLOCK_ICON or MAP_LOCK_ICON)
        unitItem.lab_unlock.text = Z.RichTextHelper.ApplyColorTag(config.Name, sceneUnlock and "#FFFFFF" or "#D4D4D4")
      end
      local offSet = info.InnerIcon == "" and 40 or 10
      unitItem.Trans:SetAnchorPosition(0, offSet)
      local flagScale = self:getFlagScale()
      unitItem.Trans:SetScale(flagScale, flagScale, 1)
      if info.InnerIcon == "" then
        unitItem.Ref.UIComp:SetVisible(true)
      else
        unitItem.Ref.UIComp:SetVisible(self.uiBinder.slider_zoom.value >= Z.Global.MapRatio[6])
      end
    end
  end
end

function Map_mainView:clearAreaMapName()
  if self.mapAreaUnitTokenDict_ then
    for unitName, unitToken in pairs(self.mapAreaUnitTokenDict_) do
      Z.CancelSource.ReleaseToken(unitToken)
    end
  end
  self.mapAreaUnitTokenDict_ = {}
  if self.mapAreaUnitDict_ then
    for unitName, unitItem in pairs(self.mapAreaUnitDict_) do
      self:RemoveUiUnit(unitName)
    end
  end
  self.mapAreaUnitDict_ = {}
end

function Map_mainView:onWorldMapFlagClick(worldMapFlg, sceneId)
  if worldMapFlg.IsBorderLimit then
    local info = self.worldMapInfoDict_[sceneId]
    local posX = info and info.PosX or 0
    local posY = info and info.PosY or 0
    local targetAnchorPos = Vector2.New(-posX * self.curScale_, -posY * self.curScale_)
    self.uiBinder.comp_dotween:DoAnchorPosMove(targetAnchorPos, 0.2)
  elseif self:checkSceneUnlock(sceneId) then
    self:switchAreaMapWithRevert(sceneId)
  end
end

function Map_mainView:refreshWorldMapFlagUnit(unitItem, goalInfo, trackRow)
  local flagScale = self:getFlagScale()
  unitItem.Trans:SetScale(flagScale, flagScale, 1)
  if goalInfo.Source == E.GoalGuideSource.Quest then
    local questIconPath = self.questIconVM_.GetStateIconByQuestId(goalInfo.QuestId)
    unitItem.img_icon:SetImage(questIconPath)
    unitItem.img_icon.transform:SetSizeDelta(100, 100)
    local trackId = self.questData_:GetQuestTrackingId()
    local isTrace = trackId == goalInfo.QuestId
    unitItem.Ref:SetVisible(unitItem.effect_trace, isTrace)
    unitItem.effect_trace:SetEffectGoVisible(isTrace)
  else
    unitItem.img_icon:SetImage(trackRow.Icon)
    unitItem.img_icon.transform:SetSizeDelta(70, 70)
  end
end

function Map_mainView:refreshWorldMapFlagPos(sceneIndexDict)
  for sceneId, unitList in pairs(sceneIndexDict) do
    local totalCount = #unitList
    local centerCount = totalCount * 0.5 + 0.5
    for i, unitItem in ipairs(unitList) do
      local posX = (i - centerCount) * 10
      local posY = 10
      unitItem.Trans:SetAnchorPosition(posX, posY)
      unitItem.world_map_flag:ResetLocalPos(posX, posY)
    end
  end
end

function Map_mainView:OnMapFlagToggleChange(flagData, isOn, noFindAround)
  if isOn then
    if noFindAround then
      self:openSubView(flagData)
    else
      self:onSelectMapFlagWithAround(flagData)
    end
  else
    self:CloseRightSubView(true)
  end
end

function Map_mainView:editCustomData(localPos)
  self:CloseRightSubView()
  Z.AudioMgr:Play("sys_map_pin_put")
  local flagData = {}
  flagData.Id = -1
  flagData.Type = -1
  flagData.FlagType = E.MapFlagType.Custom
  flagData.TypeId = E.MapFlagTypeId.CustomTag1
  local sizeX, sizeY = self.uiBinder.trans_map_bg:GetSizeDelta(nil, nil)
  local w = localPos.x / sizeX
  local h = localPos.y / sizeY
  flagData.Pos = Vector2.New(w, h)
  local sceneTagRow = Z.TableMgr.GetRow("SceneTagTableMgr", flagData.TypeId)
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
  self:SwitchRightSubView(E.MapSubViewType.Custom, viewData)
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
    if aroundList[1].Id == flagData.Id then
      self:openSubView(aroundList[1])
    end
  elseif 1 < flagCount then
    self.mapVM_.SortAroundList(aroundList, flagData.Id)
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
          playerPortraitHgr.InsertNewPortraitBySocialData(unit.binder_head, flagData.SocialData, nil, self.cancelSource:CreateToken())
        else
          unit.img_icon:SetImage(flagData.IconPath)
        end
        unit.lab_content.text = self.mapVM_.FindAroundFlagName(flagData)
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
  self.isSwitching_ = false
  self.uiBinder.slider_zoom.enabled = true
  self.uiBinder.comp_double_touch.enabled = true
  self:showFuncListBtn()
  self:refreshMapInfo()
  self.uiBinder.comp_mini_map_base:LuaUpdateWhenSlide(self.curScale_)
  self:setMapAreaMask()
  Z.CoroUtil.create_coro_xpcall(function()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.Update, ZUtil.ZCancelSource.NeverCancelToken)
    Z.UIMgr:FadeOut({
      CloseAnimType = Z.DOTweenAnimType.Tween_1
    })
    self.uiBinder.anim_map_name:Play(Z.DOTweenAnimType.Tween_0)
  end)()
end

function Map_mainView:setMapAreaMask()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.curMapMode_ == E.MapMode.World then
      self.uiBinder.rimg_mapbg_mask.enabled = false
      return
    end
    self:SetUIVisible(self.uiBinder.trans_map_bg, false)
    self.uiBinder.rimg_cloud.enabled = false
    self.uiBinder.rimg_mapbg_mask.enabled = false
    local sceneId = self:GetCurSceneId()
    local mapInfoTableRow = Z.TableMgr.GetRow("MapInfoTableMgr", sceneId, true)
    if mapInfoTableRow and mapInfoTableRow.IsShowMask then
      self.uiBinder.comp_relative_uv:SetMatBound(false)
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
      if self.curMapMode_ == E.MapMode.World then
        self.uiBinder.rimg_mapbg_mask.enabled = false
        return
      end
      local isAllUnlock = #lockList == 0
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
        self.uiBinder.comp_mini_map_base:PlayMapMaskAnim(screenPos, isAllUnlock)
      else
        self.uiBinder.comp_mini_map_base:SetCloudUnlockState(isAllUnlock)
      end
      self.uiBinder.rimg_cloud.enabled = true
    end
    self:SetUIVisible(self.uiBinder.trans_map_bg, true)
  end)()
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
      if 0 < cfg.RedDotId then
        Z.RedPointMgr.LoadRedDotItem(cfg.RedDotId, self, binder_func.trans_dot)
        self.redTab_[#self.redTab_ + 1] = cfg.RedDotId
      end
    end
  end
  for i = count + 1, MAX_MENU_FUNC_COUNT do
    local binder_func = self.uiBinder["binder_map_func_" .. i]
    if binder_func then
      binder_func.Ref.UIComp:SetVisible(false)
    end
  end
end

function Map_mainView:checkCallBack()
  if self.viewData and self.viewData.callback then
    self.viewData.callback()
  end
  self.viewData = nil
end

function Map_mainView:onMapOpenSubView(subViewType, viewData)
  self:SwitchRightSubView(subViewType, viewData)
end

function Map_mainView:onScreenResolutionChange()
  self:refreshWorldMapPos()
end

function Map_mainView:onPathFindingStageChange(stage)
  if stage == Panda.ZGame.EPathFindingStage.EMove then
    Z.UIMgr:GotoMainView()
  end
end

return Map_mainView
