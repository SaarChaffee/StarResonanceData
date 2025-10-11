local super = require("ui.ui_view_base")
local MainuiView = class("MainuiView", super)
local newKeyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local mainUIShortKeyDescUIComp = require("ui.view.main.mainui_shortkeydesc_ui_comp")
local mainUIBottomShortKeyDescUIComp = require("ui.view.main.mainui_bottomshortkeydesc_ui_comp")
local mainUILeftSidebarSwitcherComp = require("ui.view.main.mainui_left_sidebar_switcher_comp")
local STATE_ICON_QUIT = "ui/atlas/mainui/main_quit_icon"
local STATE_ICON_LINE = "ui/atlas/mainui/main_change_icon"

function MainuiView:ctor()
  self.uiBinder = nil
  super.ctor(self, "mainui", "main/main_main", true)
  self:initSubView()
  self:initParam()
  self:initComp()
end

function MainuiView:initParam()
  self.vm_ = Z.VMMgr.GetVM("mainui")
  self.fluxVM_ = Z.VMMgr.GetVM("flux_revolt_tooltip")
  self.parkourVM_ = Z.VMMgr.GetVM("parkourtips")
  self.thunderElementalVM_ = Z.VMMgr.GetVM("thunder_elemental")
  self.dungeonTimerVM_ = Z.VMMgr.GetVM("dungeon_timer")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.homeVM_ = Z.VMMgr.GetVM("home_editor")
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
  self.monthlyCardVM_ = Z.VMMgr.GetVM("monthly_reward_card")
  self.mainUIFuncsListVM_ = Z.VMMgr.GetVM("mainui_funcs_list")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.bossBattleVM_ = Z.VMMgr.GetVM("bossbattle")
  self.bubbleVM_ = Z.VMMgr.GetVM("bubble")
  self.topFuncItemList_ = {}
  self.isInLandScapeMode = false
  self.pcPosX = -44
  self.handPosX = -126
  self.seasonCenterBtn_ = nil
  self.upperRightBtn_ = {}
  self.mainuiSkillSlotObjs_ = {}
  self.leftTrackCurSelectedIndex_ = self.mainUIData_:GetLeftTrackCurSelectedIndex()
  
  function self.deepLinkDeal_(url)
    self.sdkVM_.DealOpenScheme(url)
    Z.ZDeepLinkUtil.MarkTokenLinkDealFalg()
  end
end

function MainuiView:initSubView()
  self.fighterBtnView = require("ui/view/fighterbtns_view").new(self)
  self.joystickView = require("ui/view/zjoystick_view").new()
  self.minimapView = require("ui/view/minimap_view").new(self)
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
  self.itemTraceView_ = require("ui.view.main_item_trace_sub_view").new()
  self.mainEvaluateTplView_ = require("ui/view/main_evaluate_tpl_view").new(self)
  self.mainChannelSubView_ = require("ui/view/main_channel_sub_view").new()
  self.worldTeamSignView = require("ui/view/world_team_sign_view").new()
  self.bubbleSubView = require("ui/view/bubble_bar_sub_view").new()
  self.dpsSubView = require("ui/view/main_dps_sub_view").new()
end

function MainuiView:initComp()
  self.mainUIShortKeyDescUIComp_ = mainUIShortKeyDescUIComp.new(self)
  self.mainuiBottomShortKeyDescUIComp_ = mainUIBottomShortKeyDescUIComp.new(self)
  self.mainUILeftSidebarSwitcherComp_ = mainUILeftSidebarSwitcherComp.new(self)
end

function MainuiView:OnActive()
  self:startAnimatedShow()
  self:initBubbleData()
  self.mainUIShortKeyDescUIComp_:Init(self.uiBinder)
  self.mainuiBottomShortKeyDescUIComp_:Init()
  self.mainUILeftSidebarSwitcherComp_:Init()
  self.nodeArea = {
    self.uiBinder.upper_left,
    self.uiBinder.lower_left,
    self.uiBinder.upper_right,
    self.uiBinder.lower_right
  }
  if not Z.IsPCUI then
    self.joystickView:Active(nil, self.uiBinder.joystick_node)
  end
  if Z.GameContext.StarterRun then
    return
  end
  self.uiBinder.group_sceneline.Ref.UIComp:SetVisible(false)
  if Z.IsPCUI then
    self:AddClick(self.uiBinder.btn_mount, function()
      self.funcVM_.GoToFunc(E.FunctionID.VehicleRide)
    end)
    self:AddClick(self.uiBinder.btn_esc, function()
      self.funcVM_.GoToFunc(E.FunctionID.MainFuncMenu)
    end)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_bubble, false)
    self:AddClick(self.uiBinder.btn_bubble, function()
      self:selectedLeftBtn(E.MainViewLeftTrackUIMark.Bubble)
    end)
    self:AddClick(self.uiBinder.btn_dps, function()
      if not self.funcVM_.CheckFuncCanUse(E.FunctionID.Dps) then
        return
      end
      self:selectedLeftBtn(E.MainViewLeftTrackUIMark.Dps)
    end)
    self:AddAsyncClick(self.uiBinder.quest_detail_btn, function()
      self:selectedLeftBtn(E.MainViewLeftTrackUIMark.Task)
    end)
    self:AddAsyncClick(self.uiBinder.scenery_btn, function()
      self:switchLandscapeMode()
    end)
    self.uiBinder.arrow_toggle:RemoveAllListeners()
    self.uiBinder.arrow_toggle:AddListener(function(isOn)
      self:isShowUpperBtn(isOn)
    end)
  end
  self:AddClick(self.uiBinder.group_sceneline.btn_switch_line, function()
    local isShowDungeonExit = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.ExitDungeon)
    if isShowDungeonExit then
      self.funcVM_.GoToFunc(E.FunctionID.ExitDungeon)
    else
      self.funcVM_.GoToFunc(E.FunctionID.SceneLine)
    end
  end)
  self:AddClick(self.uiBinder.group_sceneline_recycle.btn_switch_line, function()
    local isShowDungeonExit = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.ExitDungeon)
    if isShowDungeonExit then
      self.funcVM_.GoToFunc(E.FunctionID.ExitDungeon)
    else
      self.funcVM_.GoToFunc(E.FunctionID.SceneLine)
    end
  end)
  self:initRedDotItem()
  self:BindEvents()
  self:registerInputActions()
  self:checkViewStateOnActive()
  self:selectedCurLeftIndexFunc()
end

function MainuiView:selectedLeftBtn(type)
  if self.leftTrackCurSelectedIndex_ ~= type then
    self:unSelectedLastLeftIndexFunc()
  end
  self.leftTrackCurSelectedIndex_ = type
  self:selectedCurLeftIndexFunc()
  self.mainUIData_:SetLeftTrackCurSelectedIndex(self.leftTrackCurSelectedIndex_)
end

function MainuiView:checkViewStateOnActive()
  self.fighterBtnView:Active(nil, self.uiBinder.fighter_node)
  self.goalGuideView_:Active(nil, self.uiBinder.guide_flag_node)
  self.exploreMonsterArrowView:Active(nil, self.uiBinder.guide_flag_node)
  self.lockTargetPointerView:Active(nil, self.uiBinder.lock_target_pointer_node)
  self.interactionView:Active(nil, self.uiBinder.interaction_node)
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if 0 < dungeonId then
    local dungeonTable = Z.TableMgr.GetTable("DungeonsTableMgr")
    local tableRow = dungeonTable.GetRow(dungeonId)
    if not tableRow or tableRow.PlayType == E.DungeonType.WorldBoss then
    end
  end
  self.parkTplView:Active(nil, self.uiBinder.node_parkour)
  self:showMapAreaNameView()
  self:ShowNoticeCaption()
  if Z.IsPCUI then
    self.mainShortcutView:Active(nil, self.uiBinder.node_shortcut_key)
  else
    self.mainChannelSubView_:Active(nil, self.uiBinder.node_channel)
  end
  self.bottomUIView_:Active(nil, self.uiBinder.node_bottom_ui_sub)
end

function MainuiView:checkViewStateOnRefresh()
  local isCanShowMiniMap = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.MiniMap)
  self:setSubViewState(self.minimapView, isCanShowMiniMap, nil, self.uiBinder.minimap_node)
  local isCanShowTeam = self.vm_.CheckFunctionCanShowInScene(E.TeamFuncId.Team)
  self:setSubViewState(self.teamView, isCanShowTeam, nil, self.uiBinder.team_node)
  self:setSubViewState(self.teamHeadTipsView, isCanShowTeam, nil, self.uiBinder.node_team_head_tips)
  local matchActivityData = Z.DataMgr.Get("match_activity_data")
  local isCanShowWorldBoss = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.WorldBoss) and matchActivityData:GetCurMatchActivityType() == E.MatchActivityType.WorldBoseActivity
  self:setSubViewState(self.worldBossSignUpView, isCanShowWorldBoss, nil, self.uiBinder.team_node)
  local matchTeamVM = Z.VMMgr.GetVM("match_team")
  local isCanShowWorldMatch = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.WorldBoss) and (matchTeamVM.GetIsMatching() or matchActivityData:GetCurMatchActivityType() == E.MatchActivityType.CommonActivity)
  self:setSubViewState(self.worldTeamSignView, isCanShowWorldMatch, nil, self.uiBinder.team_node)
  self:setSubViewState(self.itemTraceView_, true, E.ItemTracePosType.Top, self.uiBinder.group_item_trace)
end

function MainuiView:checkViewStateOnShow()
  self:refreshSceneryShow()
  self:setViewOpenTag(true)
  self.interactionView:Show()
  self.mainEvaluateTplView_:Show()
  self.fighterBtnView:Show()
end

function MainuiView:checkViewStateOnHide()
  self:setViewOpenTag(false)
  self.interactionView:Hide()
  self.mainEvaluateTplView_:Hide()
  self.fighterBtnView:Hide()
  if Z.IsPCUI then
    self:clearPathFindingProgressTimer()
  end
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

function MainuiView:setViewOpenTag(isShow)
  self.fluxVM_.SetMainViewHideTag(isShow)
  self.parkourVM_.SetMainViewHideTag(isShow)
  self.thunderElementalVM_.SetMainViewHideTag(isShow)
  self.dungeonTimerVM_.SetMainViewHideTag(isShow)
  self.bossBattleVM_.SetMainViewHideTag(isShow)
end

function MainuiView:OnShow()
  self:checkViewStateOnShow()
  Z.UIRoot:ActiveDebug(true)
  self:OnDealScheme()
end

function MainuiView:OnHide()
  self:checkViewStateOnHide()
  Z.UIRoot:ActiveDebug(false)
end

function MainuiView:OnDeActive()
  self:unRegisterInputActions()
  self:UnBindEvents()
  self.mainUIShortKeyDescUIComp_:UnInit()
  self.mainuiBottomShortKeyDescUIComp_:UnInit()
  self.mainUILeftSidebarSwitcherComp_:UnInit()
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
  self.worldBossSignUpView:DeActive()
  self.worldTeamSignView:DeActive()
  self.itemTraceView_:DeActive()
  self.copyAdditionalView_:DeActive()
  self.mainEvaluateTplView_:DeActive()
  self.bubbleSubView:DeActive()
  self.dpsSubView:DeActive()
  self.chatMainVM_.CloseMainChatView()
  self.bottomUIView_:DeActive()
  if Z.IsPCUI then
    self.mainShortcutView:DeActive()
  else
    self.mainChannelSubView_:DeActive()
  end
  if self.unitTabList_ then
    for k, v in pairs(self.unitTabList_) do
      for i, item in pairs(v) do
        Z.RedPointMgr.RemoveNodeItem(item.Id)
      end
    end
    self.unitTabList_ = nil
  end
  self.leftTrackCurSelectedIndex_ = self.mainUIData_:GetLeftTrackCurSelectedIndex()
  self:clearAllTopFuncItem()
  self:clearRedDotItem()
  self:clearSeasonTimer()
  self:clearLineRecycleTimer()
  self:clearSkillBinder()
end

function MainuiView:BindEvents()
  Z.EventMgr:Add("ShowMapAreaName", self.showMapAreaNameView, self)
  Z.EventMgr:Add(Z.ConstValue.Team.HideView, self.hideTeamView, self)
  Z.EventMgr:Add("ShowNoticeCaption", self.ShowNoticeCaption, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.HideMainViewArea, self.hideArea, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.CompleteMainViewAnimShow, self.CompleteDoTweenAnimShow, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.ShowOrHideEvaluateUI, self.refreshEvaluateView, self)
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.TalkStateEnd, self.onTalkStateEnd, self)
  Z.EventMgr:Add(Z.ConstValue.QuestionnaireInfosRefresh, self.refreshQuestionnaireBtn, self)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, self.refreshQuestionnaireBtn, self)
  Z.EventMgr:Add(Z.ConstValue.SwitchLandSpaceMode, self.switchLandscapeMode, self)
  Z.EventMgr:Add(Z.ConstValue.EnterHomeLand, self.enterHomeLand, self)
  Z.EventMgr:Add(Z.ConstValue.SceneLine.RefreshSceneLineUI, self.refreshSceneLineUI, self)
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionIcon, self.refreshFunctionIcon, self)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStartTimeChange, self.refreshMatchState, self)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStateChange, self.refreshMatchState, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.SetParkourSingleActive, self.refreshParkourCountDownUI, self)
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.refreshRidingBtnState, self)
  Z.EventMgr:Add(Z.ConstValue.Union.UnionDataReady, self.unionReady, self)
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionBtnState, self.refreshResonanceSkill, self)
  Z.EventMgr:Add(Z.ConstValue.OnSceneSwitchComplete, self.OnSceneSwitchComplete, self)
  Z.EventMgr:Add(Z.ConstValue.PathFinding.onStageChange, self.onPathFindingStageChange, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.RefreshChatView, self.refreshChatView, self)
  Z.EventMgr:Add(Z.ConstValue.UIOpen, self.onUIOpen, self)
  Z.EventMgr:Add(Z.ConstValue.Bubble.CurrentIdChanged, self.onBubbleIdChanged, self)
  self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
    if Z.EntityMgr.PlayerEnt then
      self:refreshRidingBtnState()
    end
  end)
  self.pathFindingWatcher_ = Z.DIServiceMgr.AttrPathFindingComponentWatcherService:OnLocalAttrStateChanged(function()
    if Z.EntityMgr.PlayerEnt then
      self:refreshPathFindingBtn()
    end
  end)
  
  function self.refreshSeasonHandbookBtnFunc_()
    self:refreshSeasonHandbookBtn()
  end
  
  Z.ContainerMgr.CharSerialize.seasonQuestList.Watcher:RegWatcher(self.refreshSeasonHandbookBtnFunc_)
  Z.EventMgr:Add(Z.ConstValue.OnAttrIsCantRideChange, self.refreshRidingBtnState, self)
  Z.ZDeepLinkUtil.RigistTokenLink(self.deepLinkDeal_)
end

function MainuiView:ShowNoticeCaption()
  local noticeTipData = Z.DataMgr.Get("noticetip_data")
  if noticeTipData:CheckNpcDataCount() > 0 then
    self.noticeCaptionsView_:Active(nil, self.uiBinder.notice_captions_node)
  else
    self.noticeCaptionsView_:DeActive()
  end
end

function MainuiView:UnBindEvents()
  Z.ContainerMgr.CharSerialize.seasonQuestList.Watcher:UnregWatcher(self.refreshSeasonHandbookBtnFunc_)
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  if self.pathFindingWatcher_ ~= nil then
    self.pathFindingWatcher_:Dispose()
    self.pathFindingWatcher_ = nil
  end
  Z.EventMgr:RemoveObjAll(self)
  Z.ZDeepLinkUtil.UnRigistTokenLink(self.deepLinkDeal_)
end

function MainuiView:onDoTweenAnimShow()
  local mainViewHideMark = self.mainUIData_:GetMainUiAreaHideStyle()
  local isShowRightUp = table.zcount(mainViewHideMark[3]) < 1
  local isShowRightDown = 1 > table.zcount(mainViewHideMark[4])
  if isShowRightUp then
    self.uiBinder.anim_dotween:Restart(Z.DOTweenAnimType.Open)
  end
  if isShowRightDown and self.fighterBtnView.IsActive then
    self.fighterBtnView:OnOpenAnimShow()
  end
end

function MainuiView:CompleteDoTweenAnimShow()
  self.uiBinder.anim_dotween:Complete()
end

function MainuiView:OnRefresh()
  self:checkViewStateOnRefresh()
  self:CheckPopupQueueCanShow()
  self:checkViewStateOnShow()
  self:onDoTweenAnimShow()
  self:SetAsFirstSibling()
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.OnMainRefresh)
  self.upperRightBtn_ = {}
  self.seasonCenterBtn_ = nil
  self:initTopFuncItem()
  local bossBattleVM = Z.VMMgr.GetVM("bossbattle")
  bossBattleVM.DisplayBossUI(-1)
  local matchData = Z.DataMgr.Get("match_data")
  local curMatchType = matchData:GetMatchType()
  self:refreshMatchState(curMatchType)
  self:hideArea()
  self:refreshSceneLineUI()
  self:refreshCopyAdditionalUI()
  self:refreshRightBtnList()
  self:refreshResonanceSkill()
  self.mainuiBottomShortKeyDescUIComp_:OnRefresh()
  self.mainUILeftSidebarSwitcherComp_:OnRefresh()
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
  self.uiBinder.Ref:SetVisible(self.uiBinder.team_node, not hide)
end

function MainuiView:showMapAreaNameView()
  self.mapAreaNameView_:Active(nil, self.uiBinder.node_map_area_name_node)
end

function MainuiView:switchLandscapeMode(forceClose)
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  if forceClose then
    self.isInLandScapeMode = false
  else
    self.isInLandScapeMode = not self.isInLandScapeMode
  end
  self:refreshSceneryShow()
end

function MainuiView:refreshSceneryShow()
  if self.isInLandScapeMode then
    Z.AudioMgr:Play("UI_Event_SystemHide")
    self.uiBinder.do_tween_main:DoCanvasGroup(0, 0.1)
  else
    self.uiBinder.do_tween_main:DoCanvasGroup(1, 0.1)
  end
  if not Z.IsPCUI then
    local isCanShow = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.LandScapeMode)
    self:SetUIVisible(self.uiBinder.scenery_btn, isCanShow and self.isInLandScapeMode)
  end
  self:refreshChatView()
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  local unionWarDanceData = Z.DataMgr.Get("union_wardance_data")
  local isInArea = unionWarDanceData:IsInDanceArea()
  local isInActivity = unionWarDanceVM:isInWarDanceActivity() or unionWarDanceVM:isinWillOpenWarDanceActivity()
  local isCanShowUnionWarDance = isInArea and isInActivity
  if isCanShowUnionWarDance and not self.isInLandScapeMode then
    unionWarDanceVM:OpenDanceView()
  else
    unionWarDanceVM:CloseDanceView()
  end
end

function MainuiView:refreshChatView()
  local isCanShowChat = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.MainChat)
  if isCanShowChat and not self.isInLandScapeMode then
    self.chatMainVM_.OpenMainChatView()
  else
    self.chatMainVM_.CloseMainChatView()
  end
end

function MainuiView:refreshSceneryBtn()
  if Z.IsPCUI then
    return
  end
  local itemBinder = self.units[E.FunctionID.LandScapeMode]
  local config = Z.TableMgr.GetRow("MainIconTableMgr", E.FunctionID.LandScapeMode)
  if itemBinder then
    self:refreshTopFuncItemShowState(itemBinder, config)
  end
end

function MainuiView:OnSceneSwitchComplete()
  self:switchLandscapeMode(true)
end

function MainuiView:onUIOpen(viewConfigKey)
  if viewConfigKey and viewConfigKey == "loading_window" and Z.IsPCUI then
    self:clearPathFindingProgressTimer()
  end
end

function MainuiView:refreshParkourCountDownUI(parkourInfo)
  if parkourInfo.isOpenView then
    self.parkourCountDownView_:Active(parkourInfo.isFirstOpen, self.uiBinder.node_count_down)
  else
    self.parkourCountDownView_:DeActive()
  end
end

function MainuiView:refreshEvaluateView(level)
  if level == nil or level <= 0 then
    self.mainEvaluateTplView_:DeActive()
  else
    self.mainEvaluateTplView_:Active(level, self.uiBinder.node_common_sub)
  end
end

function MainuiView:enterHomeLand(fieldId, isEnter)
  logGreen("enterHomeLand, fieldId={0}, isEnter={1}", fieldId, isEnter)
  if Z.IsPCUI then
    self.mainuiBottomShortKeyDescUIComp_:RefreshHomeBtn()
  elseif self.upperRightBtn_[E.FunctionID.Home] then
    local houseData = Z.DataMgr.Get("house_data")
    local stageType = Z.StageMgr.GetCurrentStageType()
    local isShow = false
    if stageType == Z.EStageType.CommunityDungeon then
      isShow = isEnter and houseData:GetFieldId() == fieldId
    elseif stageType == Z.EStageType.HomelandDungeon then
      isShow = isEnter
    end
    self.upperRightBtn_[E.FunctionID.Home].Ref.UIComp:SetVisible(isShow)
    self.uiBinder.upper_right_layout_rebuild:ForceRebuildLayoutImmediate()
  end
end

function MainuiView:initTopFuncItem()
  if Z.IsPCUI then
    return
  end
  self:clearAllTopFuncItem()
  self.topFuncItemList_ = self.vm_.GetMainItem()
  if table.zcount(self.topFuncItemList_[E.MainUIPlaceType.RightTop]) <= 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.arrow_toggle, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.arrow_toggle, true)
  end
  self:loadAllTopFuncItem()
end

function MainuiView:loadAllTopFuncItem()
  self.areaComps_ = {
    self.uiBinder.minimap_node,
    self.uiBinder.group_bottom_layout,
    self.uiBinder.group_right_layout,
    self.uiBinder.fighter_node
  }
  local topItemPath = self.uiBinder.prefab_cache:GetString("mainIconTopTpl")
  local bottomItemPath = self.uiBinder.prefab_cache:GetString("mainIconBottomTpl")
  if not topItemPath or not bottomItemPath then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in pairs(self.topFuncItemList_) do
      for i, config in pairs(v) do
        local path
        if table.zcontains(config.SystemPlace, E.MainUIPlaceType.RightTop) then
          path = topItemPath
        elseif table.zcontains(config.SystemPlace, E.MainUIPlaceType.LeftBottom) then
          path = bottomItemPath
        else
          logError("[loadTopFuncItem] error, not support this type : " .. table.ztostring(config.SystemPlace))
        end
        if path and path ~= "" then
          for _, place in ipairs(config.SystemPlace) do
            local itemBinder = self:AsyncLoadUiUnit(path, config.Id, self.areaComps_[place], self.cancelSource:CreateToken())
            if place == E.MainUIPlaceType.RightTop then
              self.upperRightBtn_[config.Id] = itemBinder
            end
            self:refreshTopFuncItem(itemBinder, config)
          end
        end
      end
    end
    self:refreshQuestionnaireBtn()
    if Z.EntityMgr.PlayerEnt then
      self:refreshRidingBtnState()
    end
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

function MainuiView:refreshTopFuncItem(unit, config)
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
    local keyId = self.mainUIData_:GetKeyIdAndDescByFuncId(config.Id)
    if keyId then
      newKeyIconHelper.InitKeyIcon(unit, unit.cont_key_icon_uiBinder, keyId)
    else
      unit.cont_key_icon_uiBinder.Ref.UIComp:SetVisible(false)
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
  self:refreshTopFuncItemShowState(unit, config)
end

function MainuiView:refreshTopFuncItemShowState(unit, config)
  local isFuncOpen = self.funcVM_.FuncIsOn(config.Id, true)
  local isFuncItemShow = isFuncOpen
  if config.Id == E.FunctionID.Home then
    isFuncItemShow = isFuncItemShow and self.homeVM_.IsSelfResident()
  elseif config.Id == E.FunctionID.MainChat and not Z.IsPCUI then
    isFuncItemShow = false
  elseif table.zcontains(config.SystemPlace, E.MainUIPlaceType.RightTop) then
    if config.Id == E.FunctionID.Questionnaire then
      local questionnaireVM = Z.VMMgr.GetVM("questionnaire")
      isFuncItemShow = questionnaireVM.IsHaveMainIconAndRedDot() and self.mainUIData_.IsShowLeftBtn
    elseif config.Id == E.FunctionID.SeasonHandbook then
      isFuncItemShow = Z.VMMgr.GetVM("season_quest_sub").CheckHasSevenDayShow() and isFuncItemShow and self.mainUIData_.IsShowLeftBtn
    elseif config.Id ~= E.FunctionID.MainFuncMenu and isFuncItemShow then
      isFuncItemShow = self.mainUIData_.IsShowLeftBtn
    end
  end
  unit.Ref.UIComp:SetVisible(isFuncItemShow)
end

function MainuiView:refreshFunctionIcon()
  self:refreshAllTopFuncItemShowState()
  self.mainuiBottomShortKeyDescUIComp_:RefreshAllBottomFuncItemShowState()
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
        self:refreshTopFuncItemShowState(itemBinder, config)
      end
    end
  end
  self.uiBinder.upper_right_layout_rebuild:ForceRebuildLayoutImmediate()
end

function MainuiView:CheckPopupQueueCanShow()
  self.monthlyCardVM_:CheckEveryDayRewardPopupCanShow()
end

function MainuiView:refreshRightBtnList()
  self.mainUIData_:RefreshMainIconStorageCondition()
  self.mainUIData_:RecordCurSceneMainIconStorageCondition(self.mainUIData_.IsShowLeftBtn)
  self.uiBinder.arrow_toggle.isOn = self.mainUIData_.IsShowLeftBtn
end

function MainuiView:initRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.QuestMain, self, self.uiBinder.dot_node)
end

function MainuiView:onClickQuestRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.QuestMain)
end

function MainuiView:clearRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.QuestMain)
end

function MainuiView:startAnimatedShow()
end

function MainuiView:startAnimatedHide()
end

function MainuiView:registerInputActions()
  Z.FuncInputActionComp:Init()
  self:registerPathFinding()
end

function MainuiView:unRegisterInputActions()
  Z.FuncInputActionComp:UnInit()
  self:unRegisterPathFinding()
end

function MainuiView:registerPathFinding()
  if Z.IsPCUI then
    local keyId = self.mainUIData_:GetKeyIdAndDescByFuncId(E.FunctionID.PathFinding)
    if keyId then
      Z.FuncInputActionComp:EnableByKeyId(keyId, false)
    end
    
    function self.onPathFindingPressedAction_()
      self:createPathFindingProgressTimer()
    end
    
    function self.onPathFindingReleasedAction_()
      self:clearPathFindingProgressTimer()
    end
    
    Z.InputMgr:AddInputEventDelegate(self.onPathFindingPressedAction_, Z.InputActionEventType.ButtonJustPressed, Z.InputActionIds.PathFinding)
    Z.InputMgr:AddInputEventDelegate(self.onPathFindingReleasedAction_, Z.InputActionEventType.ButtonJustReleased, Z.InputActionIds.PathFinding)
  else
    self.uiBinder.btn_pathfinding.ClickCD = Z.Global.PathFindingCd
    self:AddClick(self.uiBinder.btn_pathfinding, function()
      if Z.ZPathFindingMgr.CurStage == Panda.ZGame.EPathFindingStage.EMove then
        Z.ZPathFindingMgr:StopPathFinding(false)
      else
        local pathFindingVM = Z.VMMgr.GetVM("path_finding")
        if not pathFindingVM:CheckState() then
          return
        end
        local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
        gotoFuncVM.GoToFunc(E.FunctionID.PathFinding)
      end
    end)
    self:refreshPathFindingBtn()
  end
end

function MainuiView:unRegisterPathFinding()
  if Z.IsPCUI then
    Z.InputMgr:RemoveInputEventDelegate(self.onPathFindingPressedAction_, Z.InputActionEventType.ButtonJustPressed, Z.InputActionIds.PathFinding)
    Z.InputMgr:RemoveInputEventDelegate(self.onPathFindingReleasedAction_, Z.InputActionEventType.ButtonJustReleased, Z.InputActionIds.PathFinding)
    self.onPathFindingPressedAction_ = nil
    self.onPathFindingReleasedAction_ = nil
    self:clearPathFindingProgressTimer()
  else
    self.uiBinder.btn_pathfinding:RemoveAllListeners()
  end
end

function MainuiView:refreshPathFindingBtn()
  if Z.IsPCUI then
    self.mainuiBottomShortKeyDescUIComp_:RefreshPathFindingBtn()
  else
    local pathFindingVM = Z.VMMgr.GetVM("path_finding")
    local isShow = self.funcVM_.CheckFuncCanUse(E.FunctionID.PathFinding, true) and pathFindingVM:CheckState()
    self:SetUIVisible(self.uiBinder.btn_pathfinding, isShow)
    self.uiBinder.anim:ResetAniState("anim_main_main_loop", 0)
    self.uiBinder.anim:Stop()
    if isShow then
      if Z.ZPathFindingMgr.CurStage == Panda.ZGame.EPathFindingStage.EMove then
        self.uiBinder.anim:PlayOnce("anim_main_main_loop")
      else
        self.uiBinder.anim:PlayOnce("anim_main_main_open")
      end
    end
  end
end

function MainuiView:onPathFindingStageChange(stage)
  if Z.IsPCUI then
    self.mainuiBottomShortKeyDescUIComp_:RefreshPathFindingBtn()
  else
    self.uiBinder.anim:ResetAniState("anim_main_main_loop", 0)
    self.uiBinder.anim:Stop()
    if stage == Panda.ZGame.EPathFindingStage.EMove then
      self.uiBinder.anim:PlayOnce("anim_main_main_loop")
    end
  end
end

function MainuiView:createPathFindingProgressTimer()
  self:clearPathFindingProgressTimer()
  local pathFindingVM = Z.VMMgr.GetVM("path_finding")
  if not pathFindingVM:CheckState() then
    return
  end
  self.pathFindingTimer_ = self.timerMgr:StartTimer(function()
    if Z.ZPathFindingMgr.CurStage == Panda.ZGame.EPathFindingStage.EMove then
      Z.ZPathFindingMgr:StopPathFinding(false)
    else
      local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
      gotoFuncVM.GoToFunc(E.FunctionID.PathFinding)
    end
  end, 1, 1)
  self:SetUIVisible(self.uiBinder.dotween_pathfinding, true)
  self.uiBinder.img_pathfinding.fillAmount = 0
  self.uiBinder.dotween_pathfinding:DoImageFillAmount(1, 1)
end

function MainuiView:clearPathFindingProgressTimer()
  if self.pathFindingTimer_ then
    self.pathFindingTimer_:Stop()
    self.pathFindingTimer_ = nil
  end
  self.uiBinder.dotween_pathfinding:ClearAll()
  self:SetUIVisible(self.uiBinder.dotween_pathfinding, false)
end

function MainuiView:hideArea()
  local mainViewHideMark = self.mainUIData_:GetMainUiAreaHideStyle()
  local isShow = true
  for k, v in pairs(mainViewHideMark) do
    isShow = table.zcount(v) < 1
    self:hideAreaByStyleMark(self.nodeArea[k], isShow)
    if k == E.MainUIArea.UpperRight and not isShow then
      for _, j in pairs(self.upperRightBtn_) do
        if j.effect then
          j.effect:SetEffectGoVisible(false)
        end
      end
    end
  end
  local bottomLeftCount = table.zcount(mainViewHideMark[E.MainUIPlaceType.LeftBottom])
  local bottomRightCount = table.zcount(mainViewHideMark[E.MainUIPlaceType.LeftBottom])
  if not Z.IsPCUI then
    self.mainUIData_:SetIsShowMainChat(bottomLeftCount < 1 and bottomRightCount < 1)
    Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpdateMainUIMainChat)
  else
    self.mainUIData_:SetIsShowMainChat(bottomLeftCount < 1)
    Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpdateMainUIMainChat)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.MainUI.UpDatePlayerStateBar, isShow)
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
      self.units[E.FunctionID.Questionnaire].Ref.UIComp:SetVisible(self.mainUIData_.IsShowLeftBtn)
    end
    Z.RedPointMgr.UpdateNodeCount(E.RedType.Surveys, 1)
  else
    if self.units[E.FunctionID.Questionnaire] ~= nil then
      self.units[E.FunctionID.Questionnaire].Ref.UIComp:SetVisible(false)
    end
    Z.RedPointMgr.UpdateNodeCount(E.RedType.Surveys, 0)
    Z.RedPointMgr.OnClickRedDot(E.RedType.Surveys)
  end
  self.uiBinder.upper_right_layout_rebuild:ForceRebuildLayoutImmediate()
end

function MainuiView:refreshSeasonHandbookBtn()
  if self.units[E.FunctionID.SeasonHandbook] ~= nil then
    local isShow = Z.VMMgr.GetVM("season_quest_sub").CheckHasSevenDayShow()
    isShow = isShow and self.mainUIData_.IsShowLeftBtn
    self.units[E.FunctionID.SeasonHandbook].Ref.UIComp:SetVisible(isShow)
    self.uiBinder.upper_right_layout_rebuild:ForceRebuildLayoutImmediate()
  end
end

function MainuiView:refreshRidingBtnState()
  self:refreshPathFindingBtn()
  if not Z.IsPCUI then
    return
  end
  local isFuncOpen = self.funcVM_.FuncIsOn(E.FunctionID.VehicleRide, true)
  local isFuncShow = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.VehicleRide)
  if not isFuncShow or not isFuncOpen then
    return
  end
  if Z.EntityMgr.PlayerEnt == nil then
    return
  end
  local canUse = false
  local isCantRide = Z.EntityMgr.PlayerEnt:GetLuaAttrIsCantRide()
  if Z.EntityMgr.PlayerEnt.IsRiding then
    canUse = true
  else
    canUse = Z.StatusSwitchMgr:CheckSwitchEnable(Z.EStatusSwitch.RideLandStateDefault)
  end
  if canUse and not isCantRide then
    self.uiBinder.node_run_jump.group_mount_canvas_group.alpha = 1
  else
    self.uiBinder.node_run_jump.group_mount_canvas_group.alpha = 0.2
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

function MainuiView:clearLineRecycleTimer()
  self.uiBinder.autoscroll_recycle:StopAutoScroll()
  if self.lineRecycleCdTimer_ then
    self.timerMgr:StopTimer(self.lineRecycleCdTimer_)
    self.lineRecycleCdTimer_ = nil
  end
  if self.lineRecycleMoveTimer_ then
    self.timerMgr:StopTimer(self.lineRecycleMoveTimer_)
    self.lineRecycleMoveTimer_ = nil
  end
end

function MainuiView:refreshSceneLineUI()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  if sceneRow == nil then
    return
  end
  local sceneLineData = Z.DataMgr.Get("sceneline_data")
  local isSceneLineFuncOpen = Z.VMMgr.GetVM("switch").CheckFuncSwitch(E.FunctionID.SceneLine)
  local sceneSupportLine = Z.VMMgr.GetVM("scene").IsStaticScene(sceneId)
  local isSceneLineRecycle = sceneLineData.RecycleEndTime > 0
  local showSceneLine = isSceneLineFuncOpen and sceneSupportLine
  local lineName = ""
  if sceneLineData.PlayerLineId then
    local param = {
      val = sceneLineData.PlayerLineId
    }
    lineName = Lang("Line", param)
  end
  if Z.IsPCUI then
    self.uiBinder.lab_map_name.text = sceneRow.Name
    if Z.StageMgr.IsDungeonStage() then
      local dungeonRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(sceneId)
      if dungeonRow then
        local dungeonTypeName = dungeonRow.DungeonTypeName
        if dungeonRow.PlayType == E.DungeonType.MasterChallengeDungeon then
          local diff = Z.ContainerMgr.DungeonSyncData.dungeonSceneInfo.difficulty
          dungeonTypeName = Z.VMMgr.GetVM("hero_dungeon_main").GetHeroDungeonTypeName(sceneId, diff)
        end
        if dungeonTypeName ~= "" then
          self.uiBinder.lab_map_name.text = dungeonRow.Name .. Lang("Whippletree") .. dungeonTypeName
        else
          self.uiBinder.lab_map_name.text = dungeonRow.Name
        end
      end
    end
    local isShowDungeonExit = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.ExitDungeon)
    if isShowDungeonExit then
      local str = Lang("QuitDungeon")
      local curDungeonType = Z.StageMgr.GetCurrentStageType()
      if curDungeonType == Z.EStageType.CommunityDungeon then
        str = Lang("HomeOutdoorName")
      elseif curDungeonType == Z.EStageType.HomelandDungeon then
        str = Lang("HomeIndoorName")
      end
      self.uiBinder.group_sceneline.lab_line_num.text = str
      self.uiBinder.img_state_icon:SetImage(STATE_ICON_QUIT)
    elseif sceneSupportLine then
      self.uiBinder.group_sceneline.lab_line_num.text = lineName
      self.uiBinder.img_state_icon:SetImage(STATE_ICON_LINE)
    else
      self.uiBinder.group_sceneline.lab_line_num.text = ""
      self.uiBinder.img_state_icon.enabled = false
    end
    self:SetUIVisible(self.uiBinder.group_sceneline.Ref, true)
    self.mainUIShortKeyDescUIComp_:SetExitDungeonVisible(isShowDungeonExit)
    self.mainUIShortKeyDescUIComp_:SetSceneLineVisible(sceneSupportLine)
  else
    self:SetUIVisible(self.uiBinder.group_sceneline.Ref, showSceneLine and not isSceneLineRecycle)
    self.uiBinder.group_sceneline.lab_line_num.text = lineName
  end
  self:SetUIVisible(self.uiBinder.group_sceneline_recycle.Ref, isSceneLineRecycle)
  if isSceneLineRecycle then
    if self.lineRecycleCdTimer_ ~= nil then
      self:clearLineRecycleTimer()
    end
    self.lineRecycleCdTimer_ = self.timerMgr:StartTimer(function()
      if sceneLineData.RecycleEndTime ~= nil then
        local serverTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
        local leftTIme = sceneLineData.RecycleEndTime - serverTime
        if leftTIme <= 0 then
          leftTIme = 0
          self:clearLineRecycleTimer()
        end
        local param = {
          lineId = sceneLineData.PlayerLineId,
          leftTime = Z.TimeFormatTools.FormatToDHMS(leftTIme)
        }
        local isDynamicScene = sceneRow.SceneType == E.ESceneType.Dynamic
        if isDynamicScene then
          self.uiBinder.group_sceneline_recycle.lab_recycle_tips.text = Lang("DynamicSceneLineRecycleTips", param)
        else
          self.uiBinder.group_sceneline_recycle.lab_recycle_tips.text = Lang("SceneLineRecycleTips", param)
        end
      end
    end, 1, -1, false, nil, true)
    self.uiBinder.autoscroll_recycle:StartAutoScroll()
  else
    self:clearLineRecycleTimer()
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

function MainuiView:refreshMatchState()
  local matchData = Z.DataMgr.Get("match_data")
  local curMatchType = matchData:GetMatchType()
  if curMatchType == E.MatchType.Activity then
    local matchActivityData = Z.DataMgr.Get("match_activity_data")
    local curMatchActivityType = matchActivityData:GetCurMatchActivityType()
    local matchActivityVM = Z.VMMgr.GetVM("match_activity")
    if matchActivityVM.GetIsMatching() then
      if curMatchActivityType == E.MatchActivityType.WorldBoseActivity then
        self.worldBossSignUpView:Active(nil, self.uiBinder.node_world_boss_sign_up)
      elseif curMatchActivityType == E.MatchActivityType.CommonActivity then
        self.worldTeamSignView:Active({matchType = curMatchType}, self.uiBinder.node_world_boss_sign_up)
      end
    elseif curMatchActivityType == E.MatchActivityType.WorldBoseActivity then
      self.worldBossSignUpView:DeActive()
    elseif curMatchActivityType == E.MatchActivityType.CommonActivity then
      self.worldTeamSignView:DeActive()
    end
  elseif curMatchType == E.MatchType.Team then
    local matchTeamVm = Z.VMMgr.GetVM("match_team")
    if matchTeamVm.GetIsMatching() then
      self.worldTeamSignView:Active({matchType = curMatchType}, self.uiBinder.node_world_boss_sign_up)
    else
      self.worldTeamSignView:DeActive()
    end
  else
    self.worldTeamSignView:DeActive()
  end
end

local mainui_skill_slot_obj = require("ui.player_ctrl_btns.mainui_skill_slot_obj")

function MainuiView:refreshResonanceSkill()
  if not Z.IsPCUI then
    return
  end
  local isFuncOpen = self.funcVM_.FuncIsOn(E.FunctionID.VehicleRide, true)
  local isFuncShow = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.VehicleRide)
  self.uiBinder.node_run_jump.Ref:SetVisible(self.uiBinder.node_run_jump.group_mount, isFuncOpen and isFuncShow)
  local keyId = self.mainUIData_:GetKeyIdAndDescByFuncId(E.FunctionID.VehicleRide)
  if keyId then
    newKeyIconHelper.InitKeyIcon(self, self.uiBinder.node_run_jump.com_icon_key, keyId)
  end
  local isEscFuncOpen = self.funcVM_.FuncIsOn(E.FunctionID.MainFuncMenu, true)
  local isEscFuncShow = self.vm_.CheckFunctionCanShowInScene(E.FunctionID.MainFuncMenu)
  self.uiBinder.node_run_jump.Ref:SetVisible(self.uiBinder.node_run_jump.group_esc, isEscFuncOpen and isEscFuncShow)
  local keyId = self.mainUIData_:GetKeyIdAndDescByFuncId(E.FunctionID.MainFuncMenu)
  if keyId then
    newKeyIconHelper.InitKeyIcon(self, self.uiBinder.node_run_jump.com_icon_key_esc, keyId)
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.EscMenu, self, self.uiBinder.node_run_jump.group_esc)
  local resonanceBinders = {
    [1] = self.uiBinder.node_run_jump.resonance_left,
    [2] = self.uiBinder.node_run_jump.resonance_right
  }
  local resonanceRoot = {
    [1] = self.uiBinder.node_run_jump.group_skill_extra_1,
    [2] = self.uiBinder.node_run_jump.group_skill_extra_2
  }
  for i = 1, 2 do
    if self.mainuiSkillSlotObjs_[i] == nil then
      self.mainuiSkillSlotObjs_[i] = mainui_skill_slot_obj.new(100 + i, resonanceBinders[i], resonanceRoot[i], self)
    end
    self.mainuiSkillSlotObjs_[i]:Active()
  end
end

function MainuiView:clearSkillBinder()
  if not Z.IsPCUI then
    return
  end
  for _, value in ipairs(self.mainuiSkillSlotObjs_) do
    value:DeActive()
  end
  self.mainuiSkillSlotObjs_ = {}
end

function MainuiView:OnTriggerInputAction(inputActionEventData)
  local actionId = inputActionEventData.ActionId
  if inputActionEventData.ActionId == Z.InputActionIds.EnableMap then
    if Z.UIMgr:CheckMainUIActionLimit(actionId) and Z.PlayerInputController:CheckChatAndMapAction(inputActionEventData) then
      self.vm_.GotoMainUIFunc(100302)
    end
    return
  end
  if Z.IsPCUI then
    local expressionVM = Z.VMMgr.GetVM("expression")
    Z.CoroUtil.create_coro_xpcall(function(...)
      expressionVM.QuickUseExpressionByInput(actionId)
    end)()
    if actionId == Z.InputActionIds.TrackUITurnRight then
      self:onChangeTrackView(false)
    elseif actionId == Z.InputActionIds.TrackUITurnLeft then
      self:onChangeTrackView(true)
    end
  end
end

function MainuiView:OnDealScheme()
  if not Z.IsPCUI and Z.ZDeepLinkUtil.NeedDealTokenLink then
    Z.ZDeepLinkUtil.DealDeepLink(Z.LuaBridge.GetAppScheme())
  end
end

function MainuiView:unSelectedLastLeftIndexFunc()
  if self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].unSelectedFunc then
    self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].unSelectedFunc()
    self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].isSelected = false
  end
end

function MainuiView:selectedCurLeftIndexFunc()
  if self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].selectedFunc then
    self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].selectedFunc()
  end
end

function MainuiView:onChangeTrackView(isLeft)
  self.lastChangeTypeIsLeft_ = isLeft
  self:unSelectedLastLeftIndexFunc()
  if isLeft then
    self.leftTrackCurSelectedIndex_ = self.leftTrackCurSelectedIndex_ - 1
    if self.leftTrackCurSelectedIndex_ < 1 then
      self.leftTrackCurSelectedIndex_ = #self.leftTrackSubView_
    end
  else
    self.leftTrackCurSelectedIndex_ = self.leftTrackCurSelectedIndex_ + 1
    if self.leftTrackCurSelectedIndex_ > #self.leftTrackSubView_ then
      self.leftTrackCurSelectedIndex_ = 1
    end
  end
  self.mainUIData_:SetLeftTrackCurSelectedIndex(self.leftTrackCurSelectedIndex_)
  if self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].isSelected then
    return
  end
  self:selectedCurLeftIndexFunc()
end

function MainuiView:onBubbleIdChanged()
  local bubbleData = Z.DataMgr.Get("bubble_data")
  local curBubbleId = bubbleData:GetCurBubbleId()
  if curBubbleId == 0 then
    if self.leftTrackSubView_[E.MainViewLeftTrackUIMark.Task].isSelected then
      return
    end
    self:selectedLeftBtn(E.MainViewLeftTrackUIMark.Task)
  else
    if not self.bubbleVM_:CheckBubbleInfo() or self.leftTrackSubView_[E.MainViewLeftTrackUIMark.Bubble].isSelected or bubbleData:GetDisplayedBubbleView() then
      return
    end
    bubbleData:SetDisplayedBubbleView(true)
    self:selectedLeftBtn(E.MainViewLeftTrackUIMark.Bubble)
  end
  self.mainUIData_:SetLeftTrackCurSelectedIndex(self.leftTrackCurSelectedIndex_)
  if not Z.IsPCUI then
    self:SetUIVisible(self.uiBinder.btn_bubble, curBubbleId ~= 0)
  end
end

function MainuiView:onSelectBubbleBtn()
  if not self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].isSelected then
    self:setLeftBtnState()
    self:setSubViewState(self.bubbleSubView, true, nil, self.uiBinder.node_track_sub)
    self:setQuestPcIconState(false)
  end
end

function MainuiView:onSelectDpsBtn()
  if not self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].isSelected then
    self:setLeftBtnState()
    self:setSubViewState(self.dpsSubView, true, nil, self.uiBinder.node_track_sub)
    self:setQuestPcIconState(false)
  end
end

function MainuiView:onSelectQuestDetailBtn()
  if self.leftTrackSubView_[self.leftTrackCurSelectedIndex_].isSelected then
    local questDetailVm_ = Z.VMMgr.GetVM("questdetail")
    questDetailVm_.OpenDetailView()
    self:onClickQuestRed()
  else
    self:setLeftBtnState()
    self:setSubViewState(self.questTrackBarView, true, nil, self.uiBinder.node_track_sub)
    self:setQuestPcIconState(true)
  end
end

function MainuiView:initBubbleData()
  self.leftTrackSubView_ = {
    {
      isSelected = false,
      img_line = self.uiBinder.img_quest_line,
      title = Lang("TrackingTask"),
      selectedFunc = function()
        self:onSelectQuestDetailBtn()
      end,
      unSelectedFunc = function()
        self.questTrackBarView:DeActive()
      end
    },
    {
      isSelected = false,
      title = Lang("BubbleActivity"),
      selectedFunc = function()
        if not self.bubbleVM_:CheckBubbleInfo() then
          self:onChangeTrackView(self.lastChangeTypeIsLeft_)
          return
        end
        self:onSelectBubbleBtn()
      end,
      unSelectedFunc = function()
        self.bubbleSubView:DeActive()
      end
    }
  }
end

function MainuiView:setLeftBtnState()
  local curSelectSubData = self.leftTrackSubView_[self.leftTrackCurSelectedIndex_]
  for k, v in pairs(self.leftTrackSubView_) do
    if not Z.IsPCUI and v.img_line then
      self.uiBinder.Ref:SetVisible(v.img_line, false)
    end
    v.isSelected = false
  end
  curSelectSubData.isSelected = true
  if Z.IsPCUI then
    self.uiBinder.lab_quest.text = curSelectSubData.title
    local preferredWidth = self.uiBinder.lab_quest.preferredWidth
    self.uiBinder.node_quest:SetWidth(preferredWidth)
    return
  end
  if curSelectSubData.img_line then
    self.uiBinder.Ref:SetVisible(curSelectSubData.img_line, true)
  end
end

function MainuiView:setQuestPcIconState(isShow)
  if not Z.IsPCUI then
    return
  end
  self.mainUIShortKeyDescUIComp_:SetQuestPcIconState(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.dot_node, isShow)
end

return MainuiView
