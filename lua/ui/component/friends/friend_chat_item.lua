local super = require("ui.component.loop_list_view_item")
local FriendChatItem = class("FriendChatItem", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function FriendChatItem:OnInit()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.uiBinder.img_bg:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.data_.charId, self.parent.UIView.cancelSource:CreateToken())
    end)()
  end)
  self.loopListViewItem.OnLongPressEvent:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      self.parent.UIView:AsyncShowBtnFunctionTips(self.data_.charId, self.uiBinder.node_tips.position, true, false)
    end)()
  end)
end

function FriendChatItem:OnRefresh(data)
  self.data_ = data
  self:refreshTop()
  self:refreshChatNum()
  self:refreshChatCharInfo()
  self:refreshChatDataInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
end

function FriendChatItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    if self.data_.isInitRecord then
      self:setRead()
    end
    if self.data_.charId == self.friendMainData_:GetChatSelectCharId() then
      local rightList = self.friendMainData_:GetRightSubViewList()
      if table.zcount(rightList) > 0 then
        self.parent.UIView:ShowRightNodeByCacheList()
        return
      end
    end
    self.friendMainData_:SetChatSelectCharId(self.data_.charId)
    if not self.data_.isInitRecord then
      self.data_.isInitRecord = true
      Z.CoroUtil.create_coro_xpcall(function()
        self.chatMainVM_.AsyncGetRecord(E.ChatChannelType.EChannelPrivate, self.data_.charId)
        if isSelected then
          self:setRead()
        end
      end)()
    end
    self:openSendMessage()
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncUpdataPrivateChat(self.data_, self.parent.UIView.cancelSource:CreateToken())
      self:refreshChatCharInfo()
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.SocialDataUpdata)
    end)()
  end
end

function FriendChatItem:openSendMessage()
  local viewData = {}
  viewData.IsNeedReturn = false
  viewData.CharId = self.data_.charId
  self.parent.UIView:ShowNodeRightSubView(E.FriendFunctionViewType.SendMessage, viewData, true)
end

function FriendChatItem:refreshTop()
  if self.data_ and self.data_.isTop then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_top, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_top, false)
  end
end

function FriendChatItem:refreshChatNum()
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

function FriendChatItem:getUnReadCount()
  if self.data_.maxReadMsgId and self.data_.latestMsg and self.data_.maxReadMsgId < self.data_.latestMsg.msgId then
    return self.data_.latestMsg.msgId - self.data_.maxReadMsgId
  else
    return 0
  end
end

function FriendChatItem:refreshChatCharInfo()
  self:refreshHeadByHeadId(self.data_)
  self:refreshShowState(self.data_)
  local name = ""
  if self.data_.socialData and self.data_.socialData.basicData then
    name = self.data_.socialData.basicData.name
  end
  local friendData = self.friendMainData_:GetFriendDataByCharId(self.data_.charId)
  if friendData and (friendData:GetRemark() ~= "" or not name) then
    name = friendData:GetRemark()
  end
  self:refreshName(name)
end

function FriendChatItem:setRead()
  local maxRead = self.data_.maxReadMsgId or 0
  if self.data_.latestMsg and self.data_.latestMsg.msgId and maxRead < self.data_.latestMsg.msgId then
    Z.CoroUtil.create_coro_xpcall(function()
      local isSuccess = self.chatMainVM_.AsyncSetPrivateChatHasRead(self.data_.charId, self.data_.latestMsg.msgId, self.parent.UIView.cancelSource:CreateToken())
      if isSuccess then
        Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, self.chatMainData_:GetPrivateChatUnReadCount(), true)
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, false)
      end
    end)()
  end
end

function FriendChatItem:refreshName(name)
  self.uiBinder.lab_play_name.text = name
end

function FriendChatItem:refreshShowState(data)
  if data.socialData and data.socialData.basicData and data.socialData.basicData.offlineTime == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
  end
end

function FriendChatItem:refreshChatDataInfo()
  local msg = ""
  if self.data_.latestMsg and self.data_.latestMsg.msgInfo then
    local msgType = self.data_.latestMsg.msgInfo.msgType
    if msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
      local content = Z.ChatMsgHelper.GetEmojiText(self.data_.latestMsg)
      if content ~= "" then
        msg = string.zconcat("[", content, "]")
      else
        msg = Lang("chat_pic")
      end
    elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
      msg = Lang("chatMiniVoice")
    else
      msg = self.chatMainVM_.GetShowMsg({
        ChitChatMsg = self.data_.latestMsg
      })
    end
  end
  self.uiBinder.lab_chat.text = msg
end

function FriendChatItem:refreshHeadByHeadId(data)
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.cont_friend_select_head_tpl, data.socialData, nil, self.parent.UIView.cancelSource:CreateToken())
end

function FriendChatItem:UpdateData()
  self:refreshChatDataInfo()
end

function FriendChatItem:OnPointerClick(go, eventData)
  if self.IsSelected then
    self:openSendMessage()
  end
end

return FriendChatItem
