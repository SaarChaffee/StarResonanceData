local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_apply_subView = class("Friends_apply_subView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local friend_apply_item = require("ui.component.friends.friend_apply_item")

function Friends_apply_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_apply_sub", "friends/friends_apply_sub", UI.ECacheLv.None)
end

function Friends_apply_subView:OnActive()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.friendScrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll_group, self, friend_apply_item)
  self:AddClick(self.uiBinder.btn_close, function()
    self.friendsMainVm_.CloseSetView(E.FriendFunctionViewType.ApplyFriend)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ignore, function()
    local curApplicationList = self.friendMainData_:GetApplicationList()
    for _, friendData in pairs(curApplicationList) do
      self.friendsMainVm_.AsyncProcessAddRequest(friendData:GetCharId(), false, "", self.cancelSource:CreateToken())
    end
    self.friendScrollRect_:RefreshData({})
  end)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetWidth(766)
  self:BindEvents()
end

function Friends_apply_subView:OnDeActive()
  self:UnBindEvents()
  self.friendScrollRect_:ClearCells()
end

function Friends_apply_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshApplication, self)
end

function Friends_apply_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshApplication, self)
end

function Friends_apply_subView:OnRefresh()
  self:refreshApplication()
end

function Friends_apply_subView:refreshApplication()
  local curApplicationList = self.friendMainData_:GetApplicationList()
  self.friendScrollRect_:SetData(curApplicationList)
end

return Friends_apply_subView
