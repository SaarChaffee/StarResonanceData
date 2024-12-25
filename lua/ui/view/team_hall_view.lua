local UI = Z.UI
local super = require("ui.ui_subview_base")
local Team_hallView = class("Team_hallView", super)
local loopListView = require("ui/component/loop_list_view")
local dropDownLoopItem = require("ui/component/team/dropdown_loop_item")
local teamLoopItem = require("ui.component.team.team_loop_item")

function Team_hallView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "team_hall_sub", "team/team_hall_sub", UI.ECacheLv.None, parent)
  self.targetId_ = E.TeamTargetId.All
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.matchData_ = Z.DataMgr.Get("match_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
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
  self.prefab_cache_ = self.uiBinder.prefab_cache
  self.outBtn_ = self.uiBinder.btn_out
  self.hallBtnNode_ = self.uiBinder.node_btn_hall
  self.nearBtnNode_ = self.uiBinder.node_btn_nearby
  self.btn_near_join_ = self.uiBinder.btn_near_join
  self.btn_near_refresh_ = self.uiBinder.btn_near_refresh
  self.btn_near_create_ = self.uiBinder.btn_near_create
  self.btn_near_out_ = self.uiBinder.btn_near_out
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
  self:setTarget()
  self:setHallInfo()
  self:setTargetInfo()
  self:updateHallRefreshBtn()
  self:compCd()
  self:refreshComp()
end

function Team_hallView:initBtns()
  self:AddAsyncClick(self.btn_near_join_, function()
    local havTeam = self.teamVM_.CheckIsInTeam()
    if havTeam then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("QuitJoinTeam"), function()
        self.teamVM_.AsyncQuitTeam(self.cancelSource)
        self:oneKeyJoinTeam()
        Z.DialogViewDataMgr:CloseDialogView()
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
  self:AddAsyncClick(self.btn_match_, function()
    if self.targetId_ == E.TeamTargetId.All then
      Z.TipsVM.ShowTipsLang(100111)
      return
    end
    if self.targetId_ == E.TeamTargetId.Costume then
      Z.TipsVM.ShowTipsLang(1000622)
      return
    end
    local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(self.targetId_)
    if not teamTargetRow then
      return
    end
    if not teamTargetRow.MemberCountStopMatch or teamTargetRow.MemberCountStopMatch == 0 then
      Z.TipsVM.ShowTips(1000750)
      return
    end
    local matching = self.matchData_:GetSelfMatchData("matching")
    local matchType = self.matchData_:GetMatchType()
    if matching and matchType == E.MatchType.Team then
      Z.EventMgr:Add(Z.ConstValue.Team.RepeatCharCancelMatch, self.repeatCharMatch, self)
      self.matchVm_.AsyncCancelMatchNew(E.MatchType.Team, false, self.cancelSource:CreateToken())
    else
      local requestParam = {}
      requestParam.targetId = self.targetId_
      requestParam.checkTags = {}
      if self.isLeader_ then
        requestParam.wantLeader = 1
      else
        requestParam.wantLeader = 0
      end
      self.matchVm_.AsyncBeginMatchNew(E.MatchType.Team, requestParam, false, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.btn_cancel_, function()
    self.matchVm_.AsyncCancelMatchNew(E.MatchType.Team, false, self.cancelSource:CreateToken())
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
  self.tog_leader_.isOn = self.isLeader_
  self:AddClick(self.tog_leader_, function(isOn)
    self.settingVM_.AsyncSaveSetting({
      [Z.PbEnum("ESettingType", "ToBeLeader")] = isOn and "0" or "1"
    })
    self.isLeader_ = isOn
  end)
  self.teamLoopListRect_ = loopListView.new(self, self.loop_list_view_, teamLoopItem, "team_item_list_tpl")
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
    self.targetId_ = self.matchData_:GetSelfMatchData("targetId") or E.TeamTargetId.All
  end
  local settingInfo = Z.ContainerMgr.CharSerialize.settingData.settingMap
  local isLeader = settingInfo[Z.PbEnum("ESettingType", "ToBeLeader")] or "0"
  self.isMatch_ = false
  self.isLeader_ = isLeader == "0"
end

function Team_hallView:updateHallRefreshBtn()
  local refreshCd = self.teamData_:GetTeamSimpleTime("hallTeamListRefresh")
  self.btn_refresh_.interactable = refreshCd == 0
  self.btn_refresh_.IsDisabled = refreshCd ~= 0
  self.btnCanClick_ = refreshCd == 0
end

function Team_hallView:setTargetInfo()
  self.targetView = dropDownLoopItem.new(self, self.scrollview_.Content, self.prefab_cache_:GetString("dropdown1"), self.prefab_cache_:GetString("dropdown2"))
  self.targetView:createTargetItem()
end

function Team_hallView:repeatCharMatch()
  Z.CoroUtil.create_coro_xpcall(function()
    local requestParam = {}
    requestParam.targetId = self.targetId_
    requestParam.checkTags = {}
    if self.isLeader_ then
      requestParam.wantLeader = 1
    else
      requestParam.wantLeader = 0
    end
    self.matchVm_.AsyncBeginMatchNew(E.MatchType.Team, requestParam, false, self.cancelSource:CreateToken())
    Z.EventMgr:Remove(Z.ConstValue.Team.RepeatCharCancelMatch, self.repeatCharMatch, self)
  end)()
end

function Team_hallView:setCompActive()
  local havTeam = self.teamVM_.CheckIsInTeam()
  local matching = self.matchData_:GetSelfMatchData("matching")
  local matchType = self.matchData_:GetMatchType()
  matching = matching and matchType == E.MatchType.Team
  self.uiBinder.Ref:SetVisible(self.cont_lab_tips_, not havTeam and matching)
  self.uiBinder.Ref:SetVisible(self.btn_cancel_, not havTeam and matching)
  self.uiBinder.Ref:SetVisible(self.btn_match_, not havTeam and not matching)
  self.uiBinder.Ref:SetVisible(self.btn_create_, not havTeam)
  self.uiBinder.Ref:SetVisible(self.outBtn_, havTeam)
  self.uiBinder.Ref:SetVisible(self.tog_leader_, not havTeam)
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
      self.matchVm_.SetSelfMatchData(self.targetId, "targetId")
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
  self.setTargetId_ = targetid
  self.targetId_ = targetid
  self.matchVm_.SetSelfMatchData(self.targetId_, "targetId")
  self:setTarget()
  self:getTeamList()
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

function Team_hallView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Team.MatchWaitTimeOut, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshMatchingStatus, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshHallList, self.refreshHallTeamList, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshNearByList, self.refreshHallTeamList, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateHallRefreshBtn, self.updateHallRefreshBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateApplyBtn, self.updateApplyBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Team.Refresh, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateNearByRefreshBtn, self.updateNearByRefreshBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateOneKeyJoinBtn, self.updateOneKeyJoinBtn, self)
end

return Team_hallView
