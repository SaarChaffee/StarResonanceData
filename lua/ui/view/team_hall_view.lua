local UI = Z.UI
local super = require("ui.ui_subview_base")
local Team_hallView = class("Team_hallView", super)
local loopListView = require("ui/component/loop_list_view")
local dropDownLoopItem = require("ui/component/team/dropdown_loop_item")
local teamLoopItem = require("ui.component.team.team_loop_item")
local keyPad = require("ui.view.cont_num_keyboard_view")

function Team_hallView:ctor(parent)
  self.uiBinder = nil
  if Z.IsPCUI then
    super.ctor(self, "team_hall_sub", "team/team_hall_sub_pc", UI.ECacheLv.None)
  else
    super.ctor(self, "team_hall_sub", "team/team_hall_sub", UI.ECacheLv.None)
  end
  self.targetId_ = E.TeamTargetId.All
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.matchData_ = Z.DataMgr.Get("match_data")
  self.matchTeamData_ = Z.DataMgr.Get("match_team_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.keypad_ = keyPad.new(self)
end

function Team_hallView:initBinder()
  self.anim_ = self.uiBinder.anim
  self.btn_create_ = self.uiBinder.btn_create
  self.btn_match_ = self.uiBinder.btn_match
  self.btn_cancel_ = self.uiBinder.btn_cancel
  self.loop_list_view_ = self.uiBinder.layout_scroll_team
  self.btn_refresh_ = self.uiBinder.btn_refresh
  self.scrollview_ = self.uiBinder.scrollview
  self.tog_leader_ = self.uiBinder.tog_leader
  self.cont_lab_tips_ = self.uiBinder.cont_lab_tips
  self.outBtn_ = self.uiBinder.btn_out
  self.hallBtnNode_ = self.uiBinder.node_btn_hall
  self.nearBtnNode_ = self.uiBinder.node_btn_nearby
  self.btn_near_join_ = self.uiBinder.btn_near_join
  self.btn_near_refresh_ = self.uiBinder.btn_near_refresh
  self.btn_near_create_ = self.uiBinder.btn_near_create
  self.btn_near_out_ = self.uiBinder.btn_near_out
  self.showFiltrateBtn_ = self.uiBinder.btn_filtrate
  self.filtrateNode_ = self.uiBinder.group_filtrate
  self.filtrateBtn_ = self.filtrateNode_.btn_filtrate
  self.refreshBtn_ = self.filtrateNode_.btn_refresh
  self.numberBtn_ = self.filtrateNode_.btn_number
  self.numberLab_ = self.filtrateNode_.lab_number
  self.keypadNode_ = self.filtrateNode_.node_keypad
  self.professionTog_ = self.filtrateNode_.tog_filter_type
end

function Team_hallView:OnActive()
  self:initBinder()
  self.uiBinder.Trans:SetOffsetMin(130, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.isNearTeam_ = false
  if E.TeamFuncId.Vicinity == self.viewData.type then
    self.isNearTeam_ = true
  end
  self.anim_:Restart(Z.DOTweenAnimType.Open)
  self:BindEvents()
  self:initBtns()
  self.filtrateNumber_ = 0
  self.filtrateIsNeedProfession_ = false
  self:setTarget()
  self:setHallInfo()
  self:setTargetInfo()
  self:updateHallRefreshBtn()
  self:compCd()
  self:refreshComp()
end

function Team_hallView:initBtns()
  self:AddClick(self.showFiltrateBtn_, function()
    self.filtrateNode_.Ref.UIComp:SetVisible(true)
  end)
  self:AddAsyncClick(self.btn_near_join_, function()
    local havTeam = self.teamVM_.CheckIsInTeam()
    if havTeam then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("QuitJoinTeam"), function()
        self.teamVM_.AsyncQuitTeam(self.cancelSource)
        self:oneKeyJoinTeam()
      end)
    else
      self:oneKeyJoinTeam()
    end
  end)
  self:AddAsyncClick(self.outBtn_, function()
    Z.EventMgr:Dispatch(Z.ConstValue.Team.QuitTeam)
  end)
  self:AddAsyncClick(self.btn_near_create_, function()
    self.teamVM_.AsyncCreatTeam(E.TeamTargetId.Costume, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.btn_near_out_, function()
    Z.EventMgr:Dispatch(Z.ConstValue.Team.QuitTeam)
  end)
  self:AddAsyncClick(self.btn_near_refresh_, function()
    self.btn_near_refresh_.interactable = false
    self.btn_near_refresh_.IsDisabled = true
    self.teamVM_.SetNearbyRefreshBtnTime()
    self:getNearTeamList(true)
  end)
  self:AddAsyncClick(self.btn_create_, function()
    self.teamVM_.AsyncCreatTeam(self.targetId_, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.btn_match_, function()
    local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(self.targetId_)
    if not teamTargetRow then
      return
    end
    self.matchVm_.RequestBeginMatch(E.MatchType.Team, teamTargetRow.RelativeDungeonId, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.btn_cancel_, function()
    self.matchVm_.AsyncCancelMatch()
  end)
  self:AddAsyncClick(self.btn_refresh_, function()
    if self.btnCanClick_ == true then
      self.btnCanClick_ = false
      self.btn_refresh_.interactable = false
      self.btn_refresh_.IsDisabled = true
      self.teamVM_.SetHallRefreshBtnTime()
      self:getTeamList(true)
    end
  end)
  self:AddClick(self.tog_leader_, function(isOn)
    self.settingVM_.AsyncSaveSetting({
      [Z.PbEnum("ESettingType", "ToBeLeader")] = isOn and "0" or "1"
    })
    self.isLeader_ = isOn
  end)
  self:AddClick(self.professionTog_, function(isOn)
    self.teamData_.IsNeedCurProfession = isOn
    self.filtrateIsNeedProfession_ = isOn
  end)
  self:AddClick(self.filtrateBtn_, function()
    self.filtrateNode_.Ref.UIComp:SetVisible(false)
  end)
  self:AddClick(self.refreshBtn_, function()
  end)
  self:AddClick(self.numberBtn_, function()
    self.keypad_:Active({max = 20}, self.keypadNode_)
  end)
  local listItemTplName = "team_item_list_tpl"
  if Z.IsPCUI then
    listItemTplName = "team_item_list_tpl_pc"
  end
  self.teamLoopListRect_ = loopListView.new(self, self.loop_list_view_, teamLoopItem, listItemTplName)
  self.teamLoopListRect_:Init({})
end

function Team_hallView:oneKeyJoinTeam()
  local teamIdList = {}
  for i = 1, #self.teamList_ do
    local teamId = self.teamList_[i].teamId
    local isApply = self.teamData_:GetTeamApplyStatus(teamId)
    if not isApply then
      teamIdList[#teamIdList + 1] = teamId
    end
  end
  Z.TipsVM.ShowTipsLang(1000631)
  self.btn_near_join_.interactable = false
  self.btn_near_join_.IsDisabled = true
  self.teamVM_.SetOneKeyJoinTime()
  self.teamVM_.AsyncApplyJoinTeam(teamIdList, self.cancelSource:CreateToken())
end

function Team_hallView:OnRefresh()
  self.isNearTeam_ = false
  if E.TeamFuncId.Vicinity == self.viewData.type then
    self.isNearTeam_ = true
  end
  self.uiBinder.Ref:SetVisible(self.hallBtnNode_, E.TeamFuncId.Vicinity ~= self.viewData.type)
  self.uiBinder.Ref:SetVisible(self.nearBtnNode_, E.TeamFuncId.Vicinity == self.viewData.type)
  self:setCompActive()
  self:getTeamList()
end

function Team_hallView:OnDeActive()
  self.keypad_:DeActive()
  if self.teamLoopListRect_ then
    self.teamLoopListRect_:UnInit()
    self.teamLoopListRect_ = nil
  end
  self.anim_:Play(Z.DOTweenAnimType.Close)
end

function Team_hallView:setHallInfo()
  local refreshCd = self.teamData_:GetTeamSimpleTime("hallTeamListRefresh")
  self.btnCanClick_ = refreshCd == 0
end

function Team_hallView:setTarget()
  if not self.isNearTeam_ then
    self.targetId_ = self.matchTeamData_:GetCurMatchingTargetId() or self.targetId_
  end
  local settingInfo = Z.ContainerMgr.CharSerialize.settingData.settingMap
  local isLeader = settingInfo[Z.PbEnum("ESettingType", "ToBeLeader")] or "0"
  self.isMatch_ = false
  self.isLeader_ = isLeader == "0"
  self.tog_leader_.isOn = self.isLeader_
end

function Team_hallView:updateHallRefreshBtn()
  local refreshCd = self.teamData_:GetTeamSimpleTime("hallTeamListRefresh")
  self.btn_refresh_.interactable = refreshCd == 0
  self.btn_refresh_.IsDisabled = refreshCd ~= 0
  self.btnCanClick_ = refreshCd == 0
end

function Team_hallView:setTargetInfo()
  local teamHallFirstTplPath, teamHallSecondTplPath
  if Z.IsPCUI then
    teamHallFirstTplPath = GetLoadAssetPath("TeamHallFirstTplPathPC")
    teamHallSecondTplPath = GetLoadAssetPath("TeamHallSecondTplPathPC")
  else
    teamHallFirstTplPath = GetLoadAssetPath("TeamHallFirstTplPath")
    teamHallSecondTplPath = GetLoadAssetPath("TeamHallSecondTplPath")
  end
  self.targetView = dropDownLoopItem.new(self, self.scrollview_.Content, teamHallFirstTplPath, teamHallSecondTplPath)
  self.targetView:createTargetItem()
end

function Team_hallView:setCompActive()
  local havTeam = self.teamVM_.CheckIsInTeam()
  local matching = self.matchVm_.IsMatching()
  matching = matching and self.matchTeamData_:GetCurMatchingTargetId() == self.targetId_
  local showMatch = false
  local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(self.targetId_)
  if teamTargetRow then
    showMatch = teamTargetRow.MatchID and teamTargetRow.MatchID > 0
  end
  self.uiBinder.Ref:SetVisible(self.cont_lab_tips_, not havTeam and matching and showMatch)
  self.uiBinder.Ref:SetVisible(self.btn_cancel_, not havTeam and matching and showMatch)
  self.uiBinder.Ref:SetVisible(self.btn_match_, not havTeam and not matching and showMatch)
  self.uiBinder.Ref:SetVisible(self.btn_create_, not havTeam)
  self.uiBinder.Ref:SetVisible(self.outBtn_, havTeam)
  self.uiBinder.Ref:SetVisible(self.tog_leader_, not havTeam)
  self:refreshComp()
end

function Team_hallView:getNearTeamList(isForce)
  Z.CoroUtil.create_coro_xpcall(function()
    local senceid = Z.StageMgr.GetCurrentSceneId()
    self.teamVM_.AsyncGetNearTeamList(senceid, isForce, self.cancelSource:CreateToken())
  end)()
end

function Team_hallView:getTeamList(isForce)
  if self.isNearTeam_ then
    self:getNearTeamList(isForce)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      self.teamVM_.AsyncGetTeamList(self.targetId_, isForce, self.cancelSource:CreateToken())
    end)()
  end
end

function Team_hallView:refreshHallTeamList(teamList)
  self.teamLoopListRect_:ClearAllSelect()
  if teamList then
    local teamMainVM = Z.VMMgr.GetVM("team_main")
    self.teamList_ = teamMainVM.GetTeamList(teamList, Z.Global.TeamSendNum, self.targetId_)
    self.viewData.parent:RefreshEmptyState(#self.teamList_ == 0)
    if #self.teamList_ > 0 then
      self.teamLoopListRect_:RefreshListView(self.teamList_, true)
    else
      self.teamLoopListRect_:RefreshListView({})
    end
  else
    self.teamLoopListRect_:RefreshListView({})
    self.viewData.parent:RefreshEmptyState(true)
  end
end

function Team_hallView:updateApplyBtn()
  local activeItems = self.teamLoopListRect_:GetAllItem()
  for k, v in pairs(activeItems) do
    v:refreshBtnInteractable()
  end
end

function Team_hallView:SetTargetid(targetid)
  self.targetId_ = targetid
  self:getTeamList()
  self:setCompActive()
end

function Team_hallView:compCd()
  self:updateNearByRefreshBtn()
  self:updateOneKeyJoinBtn()
end

function Team_hallView:updateNearByRefreshBtn()
  local refreshCd = self.teamData_:GetTeamSimpleTime("nearbyTeamListRefresh")
  self.btn_near_refresh_.interactable = refreshCd == 0
  self.btn_near_refresh_.IsDisabled = refreshCd ~= 0
end

function Team_hallView:updateOneKeyJoinBtn()
  local refreshCd = self.teamData_:GetTeamSimpleTime("oneKeyJoin")
  self.btn_near_join_.interactable = refreshCd == 0
  self.btn_near_join_.IsDisabled = refreshCd ~= 0
end

function Team_hallView:refreshComp()
  local havTeam = self.teamVM_.CheckIsInTeam()
  self.uiBinder.Ref:SetVisible(self.btn_near_create_, not havTeam)
  self.uiBinder.Ref:SetVisible(self.btn_near_out_, havTeam)
end

function Team_hallView:onMatchWantLeaderChange(wantLeader)
  self.tog_leader_:SetIsOnWithoutCallBack(wantLeader)
end

function Team_hallView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Team.MatchWaitTimeOut, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStateChange, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshHallList, self.refreshHallTeamList, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshNearByList, self.refreshHallTeamList, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateHallRefreshBtn, self.updateHallRefreshBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateApplyBtn, self.updateApplyBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Team.Refresh, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateNearByRefreshBtn, self.updateNearByRefreshBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateOneKeyJoinBtn, self.updateOneKeyJoinBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchWantLeaderChange, self.onMatchWantLeaderChange, self)
end

function Team_hallView:InputNum(num)
  self.numberLab_.text = num
  self.filtrateNumber_ = num
  self.teamData_.NeedMreMemberCount = num
end

function Team_hallView:setFiltrateInfo()
end

return Team_hallView
