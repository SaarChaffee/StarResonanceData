local super = require("ui.ui_view_base")
local MainuiView = class("MainuiView", super)
local newKeyIconHelper = require("ui.component.mainui.new_key_icon_helper")

function MainuiView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.mainui.PrefabPath = "main/main_main_pc"
  else
    Z.UIConfig.mainui.PrefabPath = "main/main_main"
  end
  super.ctor(self, "mainui")
  self:initSubView()
  self:initParam()
end

function MainuiView:initParam()
  self.vm_ = Z.VMMgr.GetVM("mainui")
  self.fluxVM_ = Z.VMMgr.GetVM("flux_revolt_tooltip")
  self.parkourVM_ = Z.VMMgr.GetVM("parkourtips")
  self.thunderElementalVM_ = Z.VMMgr.GetVM("thunder_elemental")
  self.dungeonTimerVM_ = Z.VMMgr.GetVM("dungeon_timer")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.homeVM_ = Z.VMMgr.GetVM("home")
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
  self.topFuncItemList_ = {}
  self.isInLandScapeMode = false
  self.isIgnoreHotKey = false
  self.seasonCenterBtn_ = nil
  
  function self.onInputAction_(inputActionEventData)
    self:onInputAction(inputActionEventData)
  end
end

function MainuiView:initSubView()
  self.fighterBtnView = require("ui/view/fighterbtns_view").new(self)
  self.joystickView = require("ui/view/zjoystick_view").new()
  self.minimapView = require("ui/view/minimap_view").new()
  self.questTrackBarView = require("ui/view/track_bar_view").new()
  self.goalGuideView_ = require("ui/view/goal_guide_view").new()
  self.lockTargetPointerView = require("ui/view/pointer_lock_target_sub_view").new()
  self.interactionView = require("ui/view/interaction_view").new()
  self.teamView = require("ui/view/team_view").new()
  self.parkTplView = require("ui/view/parkour_tpl_view").new()
  self.mapAreaNameView_ = require("ui/view/map_area_name_view").new()
  self.noticeCaptionsView_ = require("ui/view/noticetip_captions_view").new()
  self.exploreMonsterArrowView = require("ui/view/explore_monster_arrow_sub_view").new()
  self.worldBossSignUpView = require("ui/view/world_boss_sign_up_view").new()
  self.worldBossContributionView = require("ui/view/world_boss_contribution_view").new()
  self.teamHeadTipsView = require("ui/view/team_head_tips_window_view").new()
  self.mainShortcutView = require("ui/view/main_shortcut_key_view").new()
  self.bottomUIView_ = require("ui/view/main_bottom_ui_sub_view").new()
  self.parkourCountDownView_ = require("ui/view/parkour_tooltip_single_window_view").new()
  self.copyAdditionalView_ = require("ui.view.main_copy_additional_sub_view").new()
end

function MainuiView:OnActive()
  self:initComp()
  self:startAnimatedShow()
  self.areaComps_ = {
    self.miniMapNode_,
    self.group_bottom_layout_,
    self.group_right_layout_,
    self.fighter_node_
  }
  self.nodeArea = {
    self.upper_left_,
    self.lower_left_,
    self.upper_right_,
    self.lower_right_
  }
  if not Z.IsPCUI then
    self.joystickView:Active(nil, self.joystick_node_)
  end
  if Z.GameContext.StarterRun then
    return
  end
  self:AddAsyncClick(self.quest_detail_btn_, function()
    local questDetailVm_ = Z.VMMgr.GetVM("questdetail")
    questDetailVm_.OpenDetailView()
    self:onClickQuestRed()
  end)
  self:AddClick(self.uiBinder.group_sceneline.img_refresh, function()
    local sceneLineVM = Z.VMMgr.GetVM("sceneline")
    sceneLineVM.OpenSceneLineView()
  end)
  self:AddAsyncClick(self.scenery_btn_, function()
    self:switchLandscapeMode()
  end)
  self.arrow_toggle_:RemoveAllListeners()
  self.arrow_toggle_:AddListener(function(isOn)
    self:isShowUpperBtn(isOn)
  end)
  self:initRedDotItem()
  self:BindLuaAttrWatchers()
  self:BindEvents()
  self:registerInputActions()
  self:checkViewStateOnActive()
end

function MainuiView:initComp()
  self.miniMapNode_ = self.uiBinder.minimap_node
  self.group_bottom_layout_ = self.uiBinder.group_bottom_layout
  self.scenery_btn_ = self.uiBinder.scenery_btn
  self.group_right_layout_ = self.uiBinder.group_right_layout
  self.fighter_node_ = self.uiBinder.fighter_node
  self.joystick_node_ = self.uiBinder.joystick_node
  self.quest_track_node_ = self.uiBinder.node_quest_sub
  self.count_down_node_ = self.uiBinder.node_count_down
  self.guide_flag_node_ = self.uiBinder.guide_flag_node
  self.lock_target_pointer_node_ = self.uiBinder.lock_target_pointer_node
  self.node_pos_pointer_ = self.uiBinder.node_pos_pointer
  self.interaction_node_ = self.uiBinder.interaction_node
  self.team_node_ = self.uiBinder.team_node
  self.notice_captions_node_ = self.uiBinder.notice_captions_node
  self.node_map_area_name_node_ = self.uiBinder.node_map_area_name_node
  self.anim_ = self.uiBinder.anim
  self.anim_dotween_ = self.uiBinder.anim_dotween
  self.team_head_tips_node_ = self.uiBinder.node_team_head_tips
  self.scenery_img_ = self.uiBinder.scenery_img
  self.upper_left_ = self.uiBinder.upper_left
  self.upper_right_ = self.uiBinder.upper_right
  self.lower_left_ = self.uiBinder.lower_left
  self.lower_right_ = self.uiBinder.lower_right
  self.quest_detail_btn_ = self.uiBinder.quest_detail_btn
  self.dot_node_ = self.uiBinder.dot_node
  self.prefab_cache_ = self.uiBinder.prefab_cache
  self.upper_right_layout_rebuild_ = self.uiBinder.upper_right_layout_rebuild
  self.arrow_img_node_ = self.uiBinder.arrow_img_node
  self.arrow_toggle_ = self.uiBinder.arrow_toggle
  self.lv_lab_ = self.uiBinder.lv_lab
  self.experience_num_lab_ = self.uiBinder.experience_num_lab
  self.exp_img_ = self.uiBinder.exp_img
  self.uiBinder.group_sceneline.Ref.UIComp:SetVisible(false)
end

function MainuiView:checkViewStateOnActive()
  self.fighterBtnView:Active(nil, self.fighter_node_)
  self.goalGuideView_:Active(nil, self.guide_flag_node_)
  self.exploreMonsterArrowView:Active(nil, self.guide_flag_node_)
  self.lockTargetPointerView:Active(nil, self.lock_target_pointer_node_)
  self.interactionView:Active(nil, self.interaction_node_)
  self.bottomUIView_:Active(nil, self.uiBinder.node_bottom_ui_sub)
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if 0 < dungeonId then
    local dungeonTable = Z.TableMgr.GetTable("DungeonsTableMgr")
    local tableRow = dungeonTable.GetRow(dungeonId)
    if tableRow and tableRow.PlayType == E.DungeonType.WorldBoss then
      self.worldBossContributionView:Active(nil, self.uiBinder.node_world_contribution)
    end
  end
  self.parkTplView:Active(nil, self.uiBinder.Trans)
  local mapData = Z.DataMgr.Get("map_data")
  if not mapData.IsShownNameAfterChangeScene then
    self:showMapAreaNameView()
  end
  self:ShowNoticeCaption()
  if Z.IsPCUI then
    local shortcutViewData = {
      keyList = Z.Global.SetKeyboardShow,
      isShowShortcut = self.vm_.IsShowKeyHint()
    }
    self.mainShortcutView:Active(shortcutViewData, self.uiBinder.node_shortcut_key)
  end
end

function MainuiView:checkViewStateOnRefresh()
  local isCanShowMiniMap = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.MiniMap)
  self:setSubViewState(self.minimapView, isCanShowMiniMap, nil, self.miniMapNode_)
  local isCanShowTask = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.Task)
  self:setSubViewState(self.questTrackBarView, isCanShowTask, nil, self.quest_track_node_)
  self.uiBinder.Ref:SetVisible(self.quest_detail_btn_, isCanShowTask)
  local isCanShowTeam = self.vm_.CheckFunctionCanShowInScene(E.TeamFuncId.Team)
  self:setSubViewState(self.teamView, isCanShowTeam, nil, self.team_node_)
  self:setSubViewState(self.teamHeadTipsView, isCanShowTeam, nil, self.team_head_tips_node_)
  local worldBossVM = Z.VMMgr.GetVM("world_boss")
  local isCanShowWorldBoss = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.WorldBoss) and worldBossVM:GetIsMatching()
  self:setSubViewState(self.worldBossSignUpView, isCanShowWorldBoss, nil, self.team_node_)
end

function MainuiView:checkViewStateOnShow()
  local isCanShowChat = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.MainChat)
  if isCanShowChat then
    Z.UIMgr:OpenView("main_chat")
  else
    Z.UIMgr:CloseView("main_chat")
  end
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  local unionWarDanceData = Z.DataMgr.Get("union_wardance_data")
  local isInArea = unionWarDanceData:IsInDanceArea()
  local isInActivity = unionWarDanceVM:isInWarDanceActivity() or unionWarDanceVM:isinWillOpenWarDanceActivity()
  local isCanShowUnionWarDance = isInArea and isInActivity
  if isCanShowUnionWarDance then
    unionWarDanceVM:OpenDanceView()
  else
    unionWarDanceVM:CloseDanceView()
  end
  self:openDungeonTime(true)
  self.interactionView:Show()
end

function MainuiView:checkViewStateOnHide()
  self:openDungeonTime(false)
  self.interactionView:Hide()
end

function MainuiView:setSubViewState(subView, viewState, viewData, viewParent)
  if viewState then
    if subView.IsActive then
      subView:Show()
    else
      subView:Active(viewData, viewParent)
    end
  else
    subView:Hide()
  end
end

function MainuiView:openDungeonTime(isShow)
  self.fluxVM_.SetMainViewHideTag(isShow)
  self.parkourVM_.SetMainViewHideTag(isShow)
  self.thunderElementalVM_.SetMainViewHideTag(isShow)
  self.dungeonTimerVM_.SetMainViewHideTag(isShow)
end

function MainuiView:OnShow()
  self:checkViewStateOnShow()
  Z.UIRoot:ActiveDebug(true)
end

function MainuiView:OnHide()
  self:checkViewStateOnHide()
  Z.UIRoot:ActiveDebug(false)
end

function MainuiView:OnDeActive()
  self:unRegisterInputActions()
  self:UnBindEvents()
  self.fighterBtnView:DeActive()
  self.joystickView:DeActive()
  self.minimapView:DeActive()
  self.questTrackBarView:DeActive()
  self.goalGuideView_:DeActive()
  self.exploreMonsterArrowView:DeActive()
  self.lockTargetPointerView:DeActive()
  self.teamView:DeActive()
  self.interactionView:DeActive()
  self.parkTplView:DeActive()
  self.mapAreaNameView_:DeActive()
  self.noticeCaptionsView_:DeActive()
  self.teamHeadTipsView:DeActive()
  self.mainShortcutView:DeActive()
  self.bottomUIView_:DeActive()
  self.worldBossSignUpView:DeActive()
  self.worldBossContributionView:DeActive()
  self.copyAdditionalView_:DeActive()
  Z.UIMgr:CloseView("main_chat")
  if self.unitTabList_ then
    for k, v in pairs(self.unitTabList_) do
      for i, item in pairs(v) do
        Z.RedPointMgr.RemoveNodeItem(item.Id)
      end
    end
  end
  self.unitTabList_ = nil
  self:switchLandscapeMode(true)
  self:clearAllTopFuncItem()
  self:clearRedDotItem()
  self:clearSeasonTimer()
end

function MainuiView:BindEvents()
  Z.EventMgr:Add("ShowMapAreaName", self.showMapAreaNameView, self)
  Z.EventMgr:Add(Z.ConstValue.Team.HideView, self.hideTeamView, self)
  Z.EventMgr:Add("ShowNoticeCaption", self.ShowNoticeCaption, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.HideMainViewArea, self.hideArea, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.CompleteMainViewAnimShow, self.CompleteDoTweenAnimShow, self)
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.TalkStateEnd, self.onTalkStateEnd, self)
  Z.EventMgr:Add(Z.ConstValue.QuestionnaireInfosRefresh, self.refreshQuestionnaireBtn, self)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, self.refreshQuestionnaireBtn, self)
  Z.EventMgr:Add(Z.ConstValue.SwitchLandSpaceMode, self.switchLandscapeMode, self)
  Z.EventMgr:Add(Z.ConstValue.EnterHomeLand, self.enterHomeLand, self)
  Z.EventMgr:Add(Z.ConstValue.SceneLine.RefreshPlayerSceneLine, self.refreshSceneLineUI, self)
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionIcon, self.refreshAllTopFuncItemShowState, self)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStartTimeChange, self.refreshMatchState, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.SetParkourSingleActive, self.refreshParkourCountDownUI, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.refreshRidingBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Union.UnionDataReady, self.unionReady, self)
end

function MainuiView:ShowNoticeCaption()
  local noticeTipData = Z.DataMgr.Get("noticetip_data")
  if noticeTipData:CheckNpcDataCount() > 0 then
    self.noticeCaptionsView_:Active(nil, self.notice_captions_node_)
  else
    self.noticeCaptionsView_:DeActive()
  end
end

function MainuiView:UnBindEvents()
  if Z.IsPCUI then
    newKeyIconHelper.UnInitKeyIcon(self.uiBinder.scenery_key_icon_bind)
    newKeyIconHelper.UnInitKeyIcon(self.uiBinder.quest_track_key_icon_bind)
  end
  Z.EventMgr:RemoveObjAll(self)
end

function MainuiView:onDoTweenAnimShow()
  local mainViewHideMark = self.mainUIData_:GetMainUiAreaHideStyle()
  local isShowRightUp = table.zcount(mainViewHideMark[3]) < 1
  local isShowRightDown = 1 > table.zcount(mainViewHideMark[4])
  if isShowRightUp then
    self.anim_dotween_:Restart(Z.DOTweenAnimType.Open)
  end
  if isShowRightDown and self.fighterBtnView.IsActive then
    self.fighterBtnView:OnOpenAnimShow()
  end
end

function MainuiView:CompleteDoTweenAnimShow()
  self.anim_dotween_:Complete()
end

function MainuiView:OnRefresh()
  self:checkViewStateOnRefresh()
  self:checkViewStateOnShow()
  self:onDoTweenAnimShow()
  self:SetAsFirstSibling()
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.OnMainRefresh)
  self.upperRightBtn_ = {}
  self.seasonCenterBtn_ = nil
  self:initTopFuncItem()
  local bossBattleVM = Z.VMMgr.GetVM("bossbattle")
  bossBattleVM.DisplayBossUI(-1)
  self:refreshMatchState(E.MatchType.WorldBoss)
  self:hideArea()
  self:initShortcutKey()
  self:refreshSceneLine()
  self:refreshCopyAdditionalUI()
  self:refreshRightBtnList()
end

function MainuiView:initShortcutKey()
  if Z.IsPCUI then
    newKeyIconHelper.InitKeyIcon(self.uiBinder.scenery_key_icon_bind, self.uiBinder.scenery_key_icon_bind, 30)
    newKeyIconHelper.InitKeyIcon(self.uiBinder.quest_track_key_icon_bind, self.uiBinder.quest_track_key_icon_bind, 102)
  end
end

function MainuiView:BindLuaAttrWatchers()
  self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrState")
  }, Z.EntityMgr.PlayerEnt, self.onPlayerStateChange)
end

function MainuiView:ShowWarDance()
  local unionWarDanceVm = Z.VMMgr.GetVM("union_wardance")
  local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
  local isInArea = unionWarDanceData_:IsInDanceArea()
  if isInArea and (unionWarDanceVm:isInWarDanceActivity() or unionWarDanceVm:isinWillOpenWarDanceActivity()) then
    unionWarDanceVm:OpenDanceView()
  end
end

function MainuiView:hideTeamView(hide)
  self.uiBinder.Ref:SetVisible(self.team_node_, not hide)
end

function MainuiView:showMapAreaNameView()
  if Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value > 0 then
    return
  end
  self.mapAreaNameView_:Active(nil, self.node_map_area_name_node_)
end

function MainuiView:onPlayerStateChange()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  local isGlide = Z.PbEnum("EActorState", "ActorStateGlide") == stateId
  self.uiBinder.Ref:SetVisible(self.scenery_btn_, isGlide)
  if self.isInLandScapeMode and not isGlide then
    self:switchLandscapeMode(true)
  end
end

function MainuiView:switchLandscapeMode(forceClose)
  if forceClose then
    self.isInLandScapeMode = false
  else
    if not self.isInLandScapeMode then
      local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
      if Z.PbEnum("EActorState", "ActorStateGlide") ~= stateId then
        return
      end
    end
    self.isInLandScapeMode = not self.isInLandScapeMode
  end
  local imgPath = self.prefab_cache_:GetString("openSceneryIcon")
  if self.isInLandScapeMode then
    imgPath = self.prefab_cache_:GetString("closeSceneryIcon")
  end
  self.scenery_img_:SetImage(imgPath)
  if self.isInLandScapeMode then
    if not self.isIgnoreHotKey then
      self.isIgnoreHotKey = true
      Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, Panda.ZGame.EInputMask.DoByFuncId:ToInt(), true)
    end
  elseif self.isIgnoreHotKey then
    self.isIgnoreHotKey = false
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, Panda.ZGame.EInputMask.DoByFuncId:ToInt(), false)
  end
  Z.EntityMgr.PlayerEnt:SetLuaAttr(Z.LocalAttr.ELandscapeMode, self.isInLandScapeMode)
  self:hideTeamView(self.isInLandScapeMode)
  self.uiBinder.Ref:SetVisible(self.miniMapNode_, not self.isInLandScapeMode)
  self.uiBinder.Ref:SetVisible(self.interaction_node_, not self.isInLandScapeMode)
  self.uiBinder.Ref:SetVisible(self.guide_flag_node_, not self.isInLandScapeMode)
  self.uiBinder.Ref:SetVisible(self.quest_track_node_, not self.isInLandScapeMode)
  self.uiBinder.Ref:SetVisible(self.group_bottom_layout_, not self.isInLandScapeMode)
  self.uiBinder.Ref:SetVisible(self.count_down_node_, not self.isInLandScapeMode)
end

function MainuiView:refreshParkourCountDownUI(parkourInfo)
  if parkourInfo.isOpenView then
    self.parkourCountDownView_:Active(parkourInfo.isFirstOpen, self.count_down_node_)
  else
    self.parkourCountDownView_:DeActive()
  end
end

function MainuiView:enterHomeLand(homeId, isEnter)
  if self.upperRightBtn_[E.FunctionID.Home] then
    self.upperRightBtn_[E.FunctionID.Home].Ref.UIComp:SetVisible(self.homeVM_.IsSelfResident())
  end
end

function MainuiView:initTopFuncItem()
  self:clearAllTopFuncItem()
  self.topFuncItemList_ = self.vm_.GetMainItem()
  if table.zcount(self.topFuncItemList_[E.MainUiArea.UpperRight]) <= 0 then
    self.uiBinder.Ref:SetVisible(self.arrow_toggle_, false)
  else
    self.uiBinder.Ref:SetVisible(self.arrow_toggle_, true)
  end
  self:loadAllTopFuncItem()
end

function MainuiView:loadAllTopFuncItem()
  local topItemPath = self.prefab_cache_:GetString("mainIconTopTpl")
  local bottomItemPath = self.prefab_cache_:GetString("mainIconBottomTpl")
  if Z.IsPCUI then
    topItemPath = self.prefab_cache_:GetString("mainIconTopPCTpl")
    bottomItemPath = self.prefab_cache_:GetString("mainIconBottomPCTpl")
  end
  if not topItemPath or not bottomItemPath then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in pairs(self.topFuncItemList_) do
      for i, config in pairs(v) do
        local path
        if config.SystemPlace == E.MainUiArea.UpperRight then
          path = topItemPath
        elseif config.SystemPlace == E.MainUiArea.BottomLeft then
          path = bottomItemPath
        else
          logError("[loadTopFuncItem] error, not support this type : " .. config.SystemPlace)
        end
        if path and path ~= "" then
          local itemBinder = self:AsyncLoadUiUnit(path, config.Id, self.areaComps_[config.SystemPlace], self.cancelSource:CreateToken())
          if config.SystemPlace == E.MainUiArea.UpperRight then
            self.upperRightBtn_[config.Id] = itemBinder
          end
          self:refreshTopfuncItem(itemBinder, config)
        end
      end
    end
    self:refreshQuestionnaireBtn()
    self:refreshRidingBtn(Z.EntityMgr.PlayerEnt.Uuid, Z.EntityMgr.PlayerEnt:GetLuaRidingId())
  end)()
end

function MainuiView:clearAllTopFuncItem()
  if self.topFuncItemList_ ~= nil then
    for k, v in pairs(self.topFuncItemList_) do
      for i, config in pairs(v) do
        Z.RedPointMgr.RemoveNodeItem(config.Id)
        self:RemoveUiUnit(config.Id)
      end
    end
  end
  self.topFuncItemList_ = {}
end

function MainuiView:refreshTopfuncItem(unit, config)
  if not unit or not config then
    return
  end
  self:AddAsyncClick(unit.func_btn, function()
    self.funcVM_.GoToFunc(config.Id)
  end)
  Z.GuideMgr:SetSteerIdByComp(unit.uisteer, E.DynamicSteerType.FunctionId, config.Id)
  Z.RedPointMgr.LoadRedDotItem(config.Id, self, unit.node_red)
  unit.func_btn_audio:AddAudioEvent(config.Path, 3)
  unit.func_btn_img:SetImage(config.Icon)
  if unit.bottom_icon_img then
    unit.Ref:SetVisible(unit.bottom_icon_img, false)
  end
  if unit.effect_season then
    unit.effect_season:SetEffectGoVisible(false)
  end
  if Z.IsPCUI then
    local keyId = self:getKeyIdByFuncId(config.Id)
    if keyId then
      newKeyIconHelper.InitKeyIcon(unit, unit.cont_key_icon_uiBinder, keyId)
    end
  else
    unit.Ref:SetVisible(unit.cont_key_icon_node, false)
  end
  if config.Id == E.FunctionID.MainFuncMenu then
    Z.EventMgr:Add(Z.ConstValue.ShowMainFeatureUnLockEffect, function(self, functionId)
      local vm = Z.VMMgr.GetVM("switch")
      if vm.IsMainFunction(functionId) and unit.effect then
        unit.effect:SetEffectGoVisible(true)
      end
    end, unit)
  elseif config.Id == E.FunctionID.SeasonCenter then
    self.seasonCenterBtn_ = unit
    self:refreshSeasonCenterBtn()
    self:clearSeasonTimer()
    self.seasonTimer_ = self.timerMgr:StartTimer(function()
      self:refreshSeasonCenterBtn()
    end, 1, -1)
    local seasonActivationVM = Z.VMMgr.GetVM("season_activation")
    if seasonActivationVM.CheckShowMainIconEffect() then
      unit.effect_season:SetEffectGoVisible(true)
    end
  elseif config.Id == E.FunctionID.SeasonActivity then
    local recommendedPlayVM = Z.VMMgr.GetVM("recommendedplay")
    if recommendedPlayVM.CheckShowMainIconEffect() then
      unit.effect_season:SetEffectGoVisible(true)
    end
  end
  self:refreshTopfuncItemShowState(unit, config)
end

function MainuiView:refreshTopfuncItemShowState(unit, config)
  local isFuncOpen = self.funcVM_.FuncIsOn(config.Id, true)
  local isFuncItemShow = isFuncOpen
  if config.Id == E.FunctionID.MainChat and not Z.IsPCUI then
    isFuncItemShow = false
  elseif config.SystemPlace == E.MainUiArea.UpperRight then
    if config.Id == E.FunctionID.Questionnaire then
      local questionnaireVM = Z.VMMgr.GetVM("questionnaire")
      isFuncItemShow = questionnaireVM.IsHaveMainIconAndRedDot() and self.mainUIData_.IsShowLeftBtn
    elseif config.Id ~= E.FunctionID.MainFuncMenu and isFuncItemShow then
      isFuncItemShow = self.mainUIData_.IsShowLeftBtn
    end
  end
  unit.Ref.UIComp:SetVisible(isFuncItemShow)
end

function MainuiView:refreshAllTopFuncItemShowState()
  if self.topFuncItemList_ == nil then
    return
  end
  for k, v in pairs(self.topFuncItemList_) do
    for i, config in pairs(v) do
      local itemName = config.Id
      local itemBinder = self.units[itemName]
      if itemBinder then
        self:refreshTopfuncItemShowState(itemBinder, config)
      end
    end
  end
  self.upper_right_layout_rebuild_:ForceRebuildLayoutImmediate()
end

function MainuiView:refreshRightBtnList()
  self.mainUIData_:RefreshMainIconStorageCondition()
  self.mainUIData_:RecordCurSceneMainIconStorageCondition(self.mainUIData_.IsShowLeftBtn)
  self.arrow_toggle_.isOn = self.mainUIData_.IsShowLeftBtn
end

function MainuiView:getKeyIdByFuncId(funcId)
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  for keyId, row in pairs(keyTbl.GetDatas()) do
    if row.KeyboardDes == 2 and row.FunctionId == funcId then
      return keyId
    end
  end
end

function MainuiView:initRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.QuestMain, self, self.dot_node_)
end

function MainuiView:onClickQuestRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.QuestMain)
end

function MainuiView:clearRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.QuestMain)
end

function MainuiView:startAnimatedShow()
  local clipName = Z.IsPCUI and "anim_mainui_pc_001" or "anim_mainui_001"
  self.anim_:PlayOnce(clipName)
end

function MainuiView:startAnimatedHide()
  local asyncCall = Z.CoroUtil.async_to_sync(self.anim_.CoroPlayOnce)
  local clipName = Z.IsPCUI and "anim_mainui_pc_002" or "anim_mainui_002"
  asyncCall(self.anim_, clipName, self.cancelSource:CreateToken())
  self.anim_:ResetAniState(clipName)
end

function MainuiView:registerInputActions()
  local actionIdTab = self.vm_.GetInputFuncActionIds()
  for _, actionIds in ipairs(actionIdTab) do
    for _, actionId in ipairs(actionIds) do
      Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, actionId)
    end
  end
end

function MainuiView:unRegisterInputActions()
  local actionIdTab = self.vm_.GetInputFuncActionIds()
  for _, actionIds in ipairs(actionIdTab) do
    for _, actionId in ipairs(actionIds) do
      Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, actionId)
    end
  end
end

function MainuiView:onInputAction(inputActionEventData)
  if not self.IsVisible or not Z.UIRoot:GetLayerVisible(self.uiLayer) then
    return
  end
  self.vm_.TriggerInputFuncAction(inputActionEventData.actionId)
end

function MainuiView:hideArea()
  local mainViewHideMark = self.mainUIData_:GetMainUiAreaHideStyle()
  local isShow = true
  for k, v in pairs(mainViewHideMark) do
    isShow = table.zcount(v) < 1
    self:hideAreaByStyleMark(self.nodeArea[k], isShow)
    if k == E.MainUiArea.UpperRight and not isShow then
      for _, j in pairs(self.upperRightBtn_) do
        if j.effect then
          j.effect:SetEffectGoVisible(false)
        end
      end
    end
  end
  local bottomLeftCount = table.zcount(mainViewHideMark[E.MainUiArea.BottomLeft])
  local bottomRightCount = table.zcount(mainViewHideMark[E.MainUiArea.BottomLeft])
  if not Z.IsPCUI then
    self.mainUIData_:SetIsShowMainChat(bottomLeftCount < 1 and bottomRightCount < 1)
    Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpdateMainUIMainChat)
  else
    self.mainUIData_:SetIsShowMainChat(bottomLeftCount < 1)
    Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpdateMainUIMainChat)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpDatePlayerStateBar, bottomLeftCount < 1 and bottomRightCount < 1)
  if Z.IsPCUI then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_shortcut_key, 1 > table.zcount(mainViewHideMark[E.MainViewHideStyle.Bottom]))
  end
end

function MainuiView:hideAreaByStyleMark(hideArea, isShow)
  if not hideArea then
    return
  end
  self.uiBinder.Ref:SetVisible(hideArea, isShow)
end

function MainuiView:onTalkStateEnd()
  self:startAnimatedShow()
end

function MainuiView:refreshQuestionnaireBtn()
  local questionnaireVM = Z.VMMgr.GetVM("questionnaire")
  if questionnaireVM.IsHaveMainIconAndRedDot() then
    if self.units[E.FunctionID.Questionnaire] ~= nil then
      self.units[E.FunctionID.Questionnaire].Ref.UIComp:SetVisible(true)
    end
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.Surveys, 1)
  else
    if self.units[E.FunctionID.Questionnaire] ~= nil then
      self.units[E.FunctionID.Questionnaire].Ref.UIComp:SetVisible(false)
    end
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.Surveys, 0)
    Z.RedPointMgr.OnClickRedDot(E.RedType.Surveys)
  end
  self.upper_right_layout_rebuild_:ForceRebuildLayoutImmediate()
end

function MainuiView:refreshRidingBtn(uuid, rideId)
  if Z.EntityMgr.PlayerEnt.Uuid ~= uuid then
    return
  end
  if self.units[E.FunctionID.VehicleRide] ~= nil then
    if rideId ~= 0 then
      self.units[E.FunctionID.VehicleRide].func_btn_img:SetImage(Z.ConstValue.MainUI.DownVehicleIcon)
    else
      self.units[E.FunctionID.VehicleRide].func_btn_img:SetImage(Z.ConstValue.MainUI.UpVehicleIcon)
    end
  end
end

function MainuiView:unionReady()
  self:initTopFuncItem()
end

function MainuiView:refreshSeasonCenterBtn()
  if self.seasonCenterBtn_ == nil then
    return
  end
  local seasonIconStartCondition = Z.Global.SeasonIconStartCondition
  for _, value in ipairs(seasonIconStartCondition) do
    if Z.ConditionHelper.CheckSingleCondition(tonumber(value[1]), nil, tonumber(value[2]), value[3], value[4]) then
      self.seasonCenterBtn_.Ref:SetVisible(self.seasonCenterBtn_.bottom_icon_img, true)
      local path = Z.Global.SeasonIconStartPicture
      self.seasonCenterBtn_.bottom_icon_img:SetImage(path)
      self:clearSeasonTimer()
      break
    end
  end
  local seasonIconEndCondition = Z.Global.SeasonIconEndCondition
  for _, value in ipairs(seasonIconEndCondition) do
    if Z.ConditionHelper.CheckSingleCondition(tonumber(value[1]), nil, tonumber(value[2]), value[3], value[4]) then
      self.seasonCenterBtn_.Ref:SetVisible(self.seasonCenterBtn_.bottom_icon_img, true)
      local path = Z.Global.SeasonIconEndPicture
      self.seasonCenterBtn_.bottom_icon_img:SetImage(path)
      self:clearSeasonTimer()
      break
    end
  end
end

function MainuiView:clearSeasonTimer()
  if self.seasonTimer_ then
    self.timerMgr:StopTimer(self.seasonTimer_)
    self.seasonTimer_ = nil
  end
end

function MainuiView:isShowUpperBtn(isOn)
  self.mainUIData_.IsShowLeftBtn = isOn
  self.mainUIData_:RecordCurSceneMainIconStorageCondition(isOn)
  self:refreshAllTopFuncItemShowState()
end

function MainuiView:refreshSceneLineUI()
  local sceneLineData = Z.DataMgr.Get("sceneline_data")
  local isSceneLineFuncOpen = Z.VMMgr.GetVM("switch").CheckFuncSwitch(101010)
  local sceneSupportLine = false
  if sceneLineData.playerSceneLine ~= nil then
    local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneLineData.playerSceneLine.sceneId)
    local sceneId = Z.StageMgr.GetCurrentSceneId()
    if sceneRow and sceneRow.SceneType == 1 and sceneId ~= 5002 then
      sceneSupportLine = true
    end
  end
  self.uiBinder.group_sceneline.Ref.UIComp:SetVisible(isSceneLineFuncOpen and sceneLineData.playerSceneLine ~= nil and sceneSupportLine)
  if isSceneLineFuncOpen and sceneLineData.playerSceneLine ~= nil then
    self.uiBinder.group_sceneline.lab_line_num.text = sceneLineData.playerSceneLine.lineName
  end
end

function MainuiView:refreshCopyAdditionalUI()
  local show = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.ExitDungeon)
  if show then
    self.copyAdditionalView_:Active(nil, self.uiBinder.node_copy_addition)
  else
    self.copyAdditionalView_:DeActive()
  end
end

function MainuiView:refreshSceneLine()
  local scenelineVM_ = Z.VMMgr.GetVM("sceneline")
  scenelineVM_.RefreshPlayerSceneLine()
end

function MainuiView:refreshMatchState(matchType)
  if matchType ~= E.MatchType.WorldBoss then
    return
  end
  local worldBossVM = Z.VMMgr.GetVM("world_boss")
  if worldBossVM:GetIsMatching() then
    self.worldBossSignUpView:Active(nil, self.uiBinder.node_world_boss_sign_up)
  else
    self.worldBossSignUpView:DeActive()
  end
end

return MainuiView
