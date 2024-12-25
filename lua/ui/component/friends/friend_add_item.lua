local super = require("ui.component.loopscrollrectitem")
local FriendAddItem = class("FriendAddItem", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function FriendAddItem:ctor()
end

function FriendAddItem:OnInit()
end

function FriendAddItem:Refresh()
  self:onInitData()
  if self.friendMainData_:IsFriendByCharId(self.data_.charId) then
    self:onRefreshIsFriend()
  elseif self.friendMainData_:GetIsSendedFriend(self.data_.charId) then
    self:onRefreshIsSend()
  else
    self:onRefreshNotSend()
  end
end

function FriendAddItem:onInitData()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  if not self.data_.socialData or not self.data_.socialData.basicData then
    return
  end
  self.uiBinder.lab_play_name.text = self.data_.socialData.basicData.name
  self.uiBinder.lab_grade.text = Lang("Lv") .. self.data_.socialData.basicData.level
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_play_head, self.data_.socialData)
  self:AddAsyncClick(self.uiBinder.img_bg, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data_.charId, self.parent.uiView.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.uiBinder.btn_add, function()
    local ret = self.friendsMainVm_.AsyncSendAddFriend(self.data_.charId, self.data_.source, self.parent.uiView.cancelSource:CreateToken())
    if ret then
      self:onRefreshIsSend()
    end
  end)
  self.uiBinder.lab_seek.text = ""
end

function FriendAddItem:onRefreshIsFriend()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_head, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
end

function FriendAddItem:onRefreshIsSend()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_head, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
end

function FriendAddItem:onRefreshNotSend()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_head, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, true)
end

function FriendAddItem:Selected(isSelected)
end

function FriendAddItem:onSelectedGroup()
end

function FriendAddItem:OnUnInit()
end

function FriendAddItem:OnReset()
end

return FriendAddItem
