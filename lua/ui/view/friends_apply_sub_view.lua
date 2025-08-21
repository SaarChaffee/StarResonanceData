local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_apply_subView = class("Friends_apply_subView", super)
local loopListView = require("ui.component.loop_list_view")
local friend_apply_item = require("ui.component.friends.friend_apply_item")

function Friends_apply_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_apply_sub", "friends/friends_apply_sub", UI.ECacheLv.None)
end

function Friends_apply_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetWidth(766)
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self:AddClick(self.uiBinder.btn_close, function()
    self.friendsMainVm_.CloseSetView(E.FriendFunctionViewType.ApplyFriend)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ignore, function()
    local charList = self.friendMainData_:GetApplicationCharList()
    for i = 1, #charList do
      self.friendsMainVm_.AsyncProcessAddRequest(charList[i], false, "", self.cancelSource:CreateToken())
    end
  end)
  self.friendLoopList_ = loopListView.new(self, self.uiBinder.loop_list, friend_apply_item, "friend_apply_item_tpl")
  local curApplicationList = self.friendMainData_:GetApplicationList()
  self.friendLoopList_:Init(curApplicationList)
  self:BindEvents()
end

function Friends_apply_subView:OnDeActive()
  self:UnBindEvents()
  self.friendLoopList_:UnInit()
end

function Friends_apply_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshApplication, self)
end

function Friends_apply_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshApplication, self)
end

function Friends_apply_subView:refreshApplication()
  local curApplicationList = self.friendMainData_:GetApplicationList()
  self.friendLoopList_:RefreshListView(curApplicationList, false)
end

return Friends_apply_subView
