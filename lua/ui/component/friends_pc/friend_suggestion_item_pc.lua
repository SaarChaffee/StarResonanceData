local super = require("ui.component.loop_grid_view_item")
local FriendSuggestionItemPC = class("FriendSuggestionItemPC", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function FriendSuggestionItemPC:OnInit()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
end

function FriendSuggestionItemPC:OnRefresh(data)
  self.data_ = data
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_play_head, self.data_.socialData, nil, self.parent.UIView.cancelSource:CreateToken())
  self.uiBinder.lab_name.text = self.data_.socialData.basicData.name
  self.uiBinder.lab_grade.text = Lang("FriendAddItemPc", {
    val = self.data_.socialData.basicData.level
  })
  self.uiBinder.btn_add:AddListener(function()
    self:asyncAddFriend()
  end)
  self.uiBinder.btn_bg:AddListener(function()
    self:asyncShowIdCard()
  end)
  self:refreshState()
end

function FriendSuggestionItemPC:asyncAddFriend()
  Z.CoroUtil.create_coro_xpcall(function()
    local friendMainVM = Z.VMMgr.GetVM("friends_main")
    local ret = friendMainVM.AsyncSendAddFriend(self.data_.charId, E.FriendAddSource.ESuggestion, self.parent.UIView.cancelSource:CreateToken())
    if ret then
      self:refreshState()
    end
  end)()
end

function FriendSuggestionItemPC:asyncShowIdCard()
  Z.CoroUtil.create_coro_xpcall(function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data_.charId, self.parent.UIView.cancelSource:CreateToken())
  end)()
end

function FriendSuggestionItemPC:refreshState()
  if self.friendMainData_:IsFriendByCharId(self.data_.charId) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_send, false)
  else
    local isSend = self.friendMainData_:GetIsSendedFriend(self.data_.charId)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, not isSend)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_send, isSend)
  end
end

return FriendSuggestionItemPC
