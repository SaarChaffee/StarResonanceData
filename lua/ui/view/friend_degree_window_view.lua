local UI = Z.UI
local super = require("ui.ui_view_base")
local Friend_degree_windowView = class("Friend_degree_windowView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local friend_degree_item = require("ui.component.friends.friend_degree_item")

function Friend_degree_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "friend_degree_window")
end

function Friend_degree_windowView:OnActive()
  self:onStartAnimatedShow()
  self:initData()
  self:initFunc()
  self:bindEvent()
end

function Friend_degree_windowView:OnDeActive()
  self:onStartAnimatedHide()
  self:unBindEvent()
  self.linessLevelScrollRect_:ClearCells()
end

function Friend_degree_windowView:OnRefresh()
end

function Friend_degree_windowView:initData()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.friendMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.linessLevelScrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll, self, friend_degree_item)
end

function Friend_degree_windowView:initFunc()
  self:AddClick(self.uiBinder.btn_return, function()
    Z.UIMgr:CloseView("friend_degree_window")
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(30022)
  end)
  self:refreshFriendLiness()
end

function Friend_degree_windowView:updateLinessValue()
  local param = {
    level = self.friendMainData_:GetFriendlinessLevel()
  }
  self.uiBinder.lab_friend_degree.text = Lang("degreeWindowLevel", param)
  local paramExp = {}
  local friendshipTotalValue = Z.TableMgr.GetTable("FriendshipTotalValueMgr").GetRow(self.friendMainData_:GetFriendlinessLevel() + 1)
  if friendshipTotalValue then
    paramExp = {
      value1 = self.friendMainData_:GetFriendlinessExp(),
      value2 = friendshipTotalValue.Exp
    }
  else
    friendshipTotalValue = Z.TableMgr.GetTable("FriendshipTotalValueMgr").GetRow(self.friendMainData_:GetFriendlinessLevel())
    paramExp = {
      value1 = friendshipTotalValue.Exp,
      value2 = friendshipTotalValue.Exp
    }
  end
  self.uiBinder.lab_num.text = Lang("degreeExpValue", paramExp)
end

function Friend_degree_windowView:updateTodayLinessValue()
  local param = {
    value1 = self.friendMainData_:GetFriendlinessTodayAddExp(),
    value2 = Z.Global.FriendshipTotalValueDayLimit
  }
  self.uiBinder.lab_get.text = Lang("friendDegree", param)
end

function Friend_degree_windowView:updateLevelRewardInfo()
  local awardConfig = {}
  for _, friendshipTotalValueBase in pairs(self.friendMainData_:GetFriendshipTotalData()) do
    if friendshipTotalValueBase.IsAwardLevel then
      awardConfig[#awardConfig + 1] = friendshipTotalValueBase
    end
  end
  self.linessLevelScrollRect_:SetData(awardConfig)
end

function Friend_degree_windowView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendLinessChange, self.refreshFriendLiness, self)
end

function Friend_degree_windowView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendLinessChange, self.refreshFriendLiness, self)
end

function Friend_degree_windowView:refreshFriendLiness()
  self:updateLinessValue()
  self:updateTodayLinessValue()
  self:updateLevelRewardInfo()
end

function Friend_degree_windowView:onStartAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Friend_degree_windowView:onStartAnimatedHide()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Close)
end

return Friend_degree_windowView
