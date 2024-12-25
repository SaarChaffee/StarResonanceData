local super = require("ui.component.loopscrollrectitem")
local FriendChatItem = class("FriendChatItem", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function FriendChatItem:ctor()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
end

function FriendChatItem:OnInit()
  self:AddAsyncClick(self.uiBinder.img_bg, function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(self.data_.charId, self.parent.uiView.cancelSource:CreateToken())
  end)
  self:EventAddAsyncListener(self.uiBinder.btn_item.OnLongPressEvent, function()
    self.parent.uiView:ShowBtnFunctionTips(self.data_.charId, self.uiBinder.node_tips.position, true, false)
  end)
end

function FriendChatItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  if not self.data_ then
    return
  end
  self:refreshTop()
  self:refreshChatNum()
  self:refreshChatCharInfo()
  self:refreshChatDataInfo()
end

function FriendChatItem:Selected(isSelected)
  self.isSelect_ = isSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    self:setRead()
    if self.data_.charId == self.friendMainData_:GetChatSelectCharId() then
      local rightList = self.friendMainData_:GetRightSubViewList()
      if table.zcount(rightList) > 0 then
        self.parent.uiView:ShowRightNodeByCacheList()
        return
      end
    end
    self:refreshChatNum()
    self.friendMainData_:SetChatSelectCharId(self.data_.charId)
    if not self.data_.isInitRecord then
      self.data_.isInitRecord = true
      Z.CoroUtil.create_coro_xpcall(function()
        self.chatMainVM_.AsyncGetRecord(E.ChatChannelType.EChannelPrivate, self.data_.charId)
      end)()
    end
    self:openSendMessage()
    Z.RedPointMgr.RefreshClientNodeCount(E.RedType.FriendChatTab, self.chatMainData_:GetPrivateChatUnReadCount())
  end
end

function FriendChatItem:openSendMessage()
  local viewData = {}
  viewData.IsNeedReturn = false
  viewData.CharId = self.data_.charId
  self.parent.uiView:ShowNodeRightSubView(E.FriendFunctionViewType.SendMessage, viewData, true)
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
      local errCode = self.chatMainVM_.AsyncSetPrivateChatHasRead(self.data_.charId, self.data_.latestMsg.msgId, self.parent.uiView.cancelSource:CreateToken())
      if errCode == 0 then
        self.data_.maxReadMsgId = self.data_.latestMsg.msgId
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
      msg = string.format("[%s]", Lang("chatMiniPic"))
    elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
      msg = string.format("[%s]", Lang("chatMiniVoice"))
    else
      msg = self.chatMainVM_.GetShowMsg({
        ChitChatMsg = self.data_.latestMsg
      })
    end
  end
  self.uiBinder.lab_chat.text = msg
end

function FriendChatItem:refreshHeadByHeadId(data)
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.cont_friend_select_head_tpl, data.socialData)
end

function FriendChatItem:OnUnInit()
end

function FriendChatItem:OnReset()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
end

function FriendChatItem:UpdateData()
  self:refreshChatDataInfo()
end

function FriendChatItem:OnPointerClick(go, eventData)
  if self.isSelect_ then
    self:openSendMessage()
  end
end

return FriendChatItem
