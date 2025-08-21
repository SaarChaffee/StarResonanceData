local UI = Z.UI
local super = require("ui.ui_view_base")
local Team_requestView = class("Team_requestView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local applyLoopItem = require("ui.component.team.apply_loop_item")

function Team_requestView:ctor()
  self.uiBinder = nil
  super.ctor(self, "team_request")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.vm_ = Z.VMMgr.GetVM("team_request")
end

function Team_requestView:initBinder()
  self.sceneMask_ = self.uiBinder.scenemask
  self.anim_ = self.uiBinder.anim
  self.btn_ignore_ = self.uiBinder.btn_ignore
  self.btn_close_ = self.uiBinder.btn_close
  self.btn_refresh_ = self.uiBinder.btn_refresh
  self.loopscroll_ = self.uiBinder.loopscroll
  self.node_empty_ = self.uiBinder.empty
  self.group_title_ = self.uiBinder.group_title
  self.img_frame_ = self.uiBinder.img_frame
end

function Team_requestView:OnActive()
  self:initBinder()
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
  self:refreshViewState(true)
  self.anim_:Restart(Z.DOTweenAnimType.Open)
  self.applyLoopScrollRect = loopScrollRect.new(self.loopscroll_, self, applyLoopItem)
  self:AddAsyncClick(self.btn_close_, function()
    self.vm_.CloseRequestView()
  end)
  self:AddAsyncClick(self.btn_ignore_, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("TeamRefuseAll"), function()
      for i = 1, #self.applyList_ do
        local unitName = string.zconcat(E.InvitationTipsType.TeamRequest, "_", self.applyList_[i].charId, "_", Lang("RequestJoinTeam"))
        Z.EventMgr:Dispatch(Z.ConstValue.InvitationClearTipsUnit, unitName)
      end
      self.teamVM_.AsyncDenyAllApllyJoin(self.cancelSource:CreateToken())
      self.applyList_ = {}
      self:refreshViewState(true)
    end)
  end)
  self.btn_refresh_.interactable = true
  self.btn_refresh_.IsDisabled = false
  self:AddAsyncClick(self.btn_refresh_, function()
    self.teamVM_.AsyncLeaderGetApplyList(true, self.cancelSource:CreateToken())
  end)
  self:BindEvents()
end

function Team_requestView:refreshViewState(state)
  self.uiBinder.Ref:SetVisible(self.node_empty_, state)
  self.uiBinder.Ref:SetVisible(self.img_frame_, not state)
  self.uiBinder.Ref:SetVisible(self.loopscroll_, not state)
  self.uiBinder.Ref:SetVisible(self.group_title_, not state)
  self.uiBinder.Ref:SetVisible(self.btn_ignore_, not state)
end

function Team_requestView:ReomveScrollData(index)
  self.applyList_[index] = nil
  self.applyList_ = table.zvalues(self.applyList_)
  if #self.applyList_ > 0 then
    self.applyLoopScrollRect:SetData(self.applyList_)
  else
    self.uiBinder.loopscroll:ClearCells()
    self:refreshViewState(true)
  end
end

function Team_requestView:OnDeActive()
  self.applyList_ = {}
  self.anim_:Play(Z.DOTweenAnimType.Close)
  if self.applyLoopScrollRect then
    self.applyLoopScrollRect:ClearCells()
    self.applyLoopScrollRect = nil
  end
end

function Team_requestView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self.teamVM_.AsyncLeaderGetApplyList(false, self.cancelSource:CreateToken())
  end)()
end

function Team_requestView:refreshApplyList(applyList, isRefresh)
  self.applyList_ = applyList
  self:refreshViewState(not (0 < #applyList))
  self.applyLoopScrollRect:SetData(applyList, true, false, 0)
  if isRefresh then
    local refreshTime = Z.Global.TeamApplyRefreshCD
    local refreshBtn = self.btn_refresh_
    refreshBtn.interactable = false
    self.btn_refresh_.IsDisabled = true
    self.timerMgr:StartTimer(function()
      refreshBtn.interactable = true
    end, refreshTime)
  end
end

function Team_requestView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshApplyList, self.refreshApplyList, self)
end

return Team_requestView
