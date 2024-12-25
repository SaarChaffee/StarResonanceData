local super = require("ui.ui_view_base")
local Union_wardance_windowView = class("Union_wardance_windowView", super)
local unionWardanceCountDown = require("ui.component.union.union_wardance_countdown")

function Union_wardance_windowView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.union_wardance_window.PrefabPath = "union_2/union_wardance_window_pc"
  else
    Z.UIConfig.union_wardance_window.PrefabPath = "union_2/union_wardance_window"
  end
  super.ctor(self, "union_wardance_window")
  self.unionWarDanceVM_ = Z.VMMgr.GetVM("union_wardance")
end

function Union_wardance_windowView:OnActive()
  self:initUi()
  Z.EventMgr:Add(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfIsDancing, self.changeSelfIsDancing, self)
  Z.EventMgr:Add(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfActivityStart, self.refreshStart, self)
end

function Union_wardance_windowView:changeSelfIsDancing(isDancing)
  self.uiBinder.Ref:SetVisible(self.btnCont, not isDancing)
end

function Union_wardance_windowView:refreshStart()
  self.activityStart = true
  self.uiBinder.Ref:SetVisible(self.btnCont, true)
end

function Union_wardance_windowView:initUi()
  self.btnCont = self.uiBinder.node_dance_btn
  self.countDownCont = self.uiBinder.node_count_down
  self:initSubView()
end

function Union_wardance_windowView:OnDeActive()
  if self.countDownBinder then
    self.countDownBinder:UnInit()
    self.countDownBinder = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfIsDancing, self.changeSelfIsDancing, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfActivityStart, self.refreshStart, self)
  self:ClearAllUnits()
end

function Union_wardance_windowView:OnRefresh()
end

function Union_wardance_windowView:initSubView()
  self:initCountdownUI()
  self:initDanceBtn()
end

function Union_wardance_windowView:initCountdownUI()
  local compName = "union_wardance_award"
  if Z.IsPCUI then
    compName = "union_wardance_award_pc"
  end
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, compName)
  Z.CoroUtil.create_coro_xpcall(function()
    local uiUnit_ = self:AsyncLoadUiUnit(path, compName, self.countDownCont, self.cancelSource:CreateToken())
    if not uiUnit_ then
      return
    end
    uiUnit_.Trans.anchoredPosition = Vector3.New(0, 0, 0)
    self.countDownBinder = unionWardanceCountDown.new(self)
    self.countDownBinder:Init(uiUnit_)
  end)()
end

function Union_wardance_windowView:initDanceBtn()
  local unionWarDanceData = Z.DataMgr.Get("union_wardance_data")
  self.uiBinder.Ref:SetVisible(self.btnCont, (not self.unionWarDanceVM_:isinWillOpenWarDanceActivity() or self.activityStart) and not unionWarDanceData:IsDancing())
  local compName = "union_wardance_btn"
  if Z.IsPCUI then
    compName = "union_wardance_btn_pc"
  end
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, compName)
  Z.CoroUtil.create_coro_xpcall(function()
    local uiUnit_ = self:AsyncLoadUiUnit(path, compName, self.btnCont, self.cancelSource:CreateToken())
    if not uiUnit_ then
      return
    end
    self:AddAsyncClick(uiUnit_.btn_dance, function()
      self.unionWarDanceVM_.RequestBeginDance()
    end)
  end)()
end

return Union_wardance_windowView
