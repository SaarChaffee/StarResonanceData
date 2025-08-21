local super = require("ui.component.loop_list_view_item")
local FriendAddItem = class("FriendAddItem", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function FriendAddItem:OnInit()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.uiBinder.img_bg:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.data_.charId, self.parent.UIView.cancelSource:CreateToken())
    end)()
  end)
  self.uiBinder.btn_add:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local ret = self.friendsMainVm_.AsyncSendAddFriend(self.data_.charId, self.data_.source, self.parent.UIView.cancelSource:CreateToken())
      if ret then
        self:onRefreshIsSend()
      end
    end)()
  end)
end

function FriendAddItem:OnRefresh(data)
  self.data_ = data
  if not self.data_.socialData or not self.data_.socialData.basicData then
    return
  end
  self.uiBinder.lab_play_name.text = self.data_.socialData.basicData.name
  self.uiBinder.lab_grade.text = Lang("Level", {
    val = self.data_.socialData.basicData.level
  })
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_play_head, self.data_.socialData, nil, self.parent.UIView.cancelSource:CreateToken())
  if self.friendMainData_:IsFriendByCharId(self.data_.charId) then
    self:onRefreshIsFriend()
  elseif self.friendMainData_:GetIsSendedFriend(self.data_.charId) then
    self:onRefreshIsSend()
  else
    self:onRefreshNotSend()
  end
end

function FriendAddItem:onRefreshIsFriend()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_head, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
end

function FriendAddItem:onRefreshIsSend()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_head, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
end

function FriendAddItem:onRefreshNotSend()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_head, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, true)
end

return FriendAddItem
