local super = require("ui.component.loop_list_view_item")
local FriendChatItemPC = class("FriendChatItemPC", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function FriendChatItemPC:OnInit()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.uiBinder.img_bg:AddListener(function()
    self:asyncShowIdCared()
  end)
end

function FriendChatItemPC:OnRefresh(data)
  self.data_ = data
  self:refreshTop()
  self:refreshHeadByHeadId()
  self:refreshName()
  self:refreshState()
  self:refreshChatNum()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
end

function FriendChatItemPC:refreshHeadByHeadId()
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.node_head, self.data_.socialData, nil, self.parent.UIView.cancelSource:CreateToken())
end

function FriendChatItemPC:refreshName()
  local name = ""
  if self.data_.socialData and self.data_.socialData.basicData then
    name = self.data_.socialData.basicData.name
  end
  local friendData = self.friendMainData_:GetFriendDataByCharId(self.data_.charId)
  if friendData and (friendData:GetRemark() ~= "" or not name) then
    name = friendData:GetRemark()
  end
  self.uiBinder.lab_play_name.text = name
end

function FriendChatItemPC:refreshState()
  local offTime = 0
  if self.data_.socialData and self.data_.socialData.basicData then
    offTime = self.data_.socialData.basicData.offlineTime or 0
  end
  if offTime == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
    local persData = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOnline, true)
    self.uiBinder.img_icon:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
    self.uiBinder.lab_time.text = Lang("Online")
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
    local persData = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOutLine, true)
    self.uiBinder.img_icon:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
    self.uiBinder.lab_time.text = Z.VMMgr.GetVM("union"):GetLastTimeDesignText(offTime)
  end
end

function FriendChatItemPC:refreshChatNum()
  local unReadCount = self:getUnReadCount()
  if self.chatMainData_:GetPrivateSelectId() ~= self.data_.charId and 0 < unReadCount then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, true)
    if 99 < unReadCount then
      self.uiBinder.lab_num.text = "99+"
    else
      self.uiBinder.lab_num.text = unReadCount
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
  end
end

function FriendChatItemPC:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    if self.data_.isInitRecord then
      self:setRead()
    end
    self.friendMainData_:SetChatSelectCharId(self.data_.charId)
    if not self.data_.isInitRecord then
      self.data_.isInitRecord = true
      Z.CoroUtil.create_coro_xpcall(function()
        self.chatMainVM_.AsyncGetRecord(E.ChatChannelType.EChannelPrivate, self.data_.charId)
        self:setRead()
      end)()
    end
    self.parent.UIView:OnSelectChatItemPC(self.data_)
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncUpdataPrivateChat(self.data_, self.parent.UIView.cancelSource:CreateToken())
      self:refreshHeadByHeadId()
      self:refreshName()
      self:refreshState()
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.SocialDataUpdata)
    end)()
  end
end

function FriendChatItemPC:asyncShowIdCared()
  Z.CoroUtil.create_coro_xpcall(function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data_.charId, self.parent.UIView.cancelSource:CreateToken())
  end)()
end

function FriendChatItemPC:refreshTop()
  if self.data_ and self.data_.isTop then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_top, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_top, false)
  end
end

function FriendChatItemPC:getUnReadCount()
  if self.data_.maxReadMsgId and self.data_.latestMsg and self.data_.maxReadMsgId < self.data_.latestMsg.msgId then
    return self.data_.latestMsg.msgId - self.data_.maxReadMsgId
  else
    return 0
  end
end

function FriendChatItemPC:setRead()
  local maxRead = self.data_.maxReadMsgId or 0
  if self.data_.latestMsg and self.data_.latestMsg.msgId and maxRead < self.data_.latestMsg.msgId then
    Z.CoroUtil.create_coro_xpcall(function()
      local isSuccess = self.chatMainVM_.AsyncSetPrivateChatHasRead(self.data_.charId, self.data_.latestMsg.msgId, self.parent.UIView.cancelSource:CreateToken())
      if isSuccess then
        Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, self.chatMainData_:GetPrivateChatUnReadCount(), true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
      end
    end)()
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, self.chatMainData_:GetPrivateChatUnReadCount(), true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
  end
end

return FriendChatItemPC
