local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleContent = class("ChatBubbleContent", super)

function ChatBubbleContent:OnInit()
  super.OnInit(self)
  self:AddAsyncListener(self.uiBinder.btn_content.OnLongPressEvent, function()
    self.parent.UIView:OpenChatTips(self.uiBinder.node_content_tips, E.ChatDialogueFuncType.CopyType, function()
      Z.LuaBridge.SystemCopy(Z.ChatMsgHelper.GetMsg(self.data_))
    end, Z.ChatMsgHelper.GetIsSelfMessage(self.data_), self.data_)
  end, nil, nil)
  if self.uiBinder.btn_repeatother then
    self:AddAsyncListener(self.uiBinder.btn_repeatother, function()
      self:reSendBtnClick()
    end)
  end
  self:refreshContentOffest()
end

function ChatBubbleContent:refreshContentOffest()
  if Z.IsPCUI then
    self.itemWidth_ = 420
  else
    self.itemWidth_ = 584
  end
end

function ChatBubbleContent:OnRefresh(data)
  super.OnRefresh(self, data)
  local content = self.chatMainVm_.GetShowMsg(data, self.uiBinder.lab_msg, self.uiBinder.lab_msg_ref)
  local msgType = Z.ChatMsgHelper.GetMsgType(data)
  if msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
    content = Z.ChatMsgHelper.GetEmojiText(data)
  end
  self.uiBinder.lab_msg.text = content
  if Z.ChatMsgHelper.GetChannelId(self.data_) == E.ChatChannelType.EChannelPrivate then
    if Z.IsPCUI then
      self.itemWidth_ = 300
    else
      self.itemWidth_ = 420
    end
  end
  local size = self.uiBinder.lab_msg:GetPreferredValues(content, self.itemWidth_, 31)
  local x = math.max(size.x, 5)
  local y = math.max(size.y, 16)
  self.uiBinder.lab_msg_ref:SetWidth(x)
  self.uiBinder.lab_msg_ref:SetHeight(y)
  local channelHuntNameWidth = Z.IsPCUI and self.channelHuntNameWidth_ or 0
  self.uiBinder.content_fitter:RefreshRectSize(channelHuntNameWidth)
  self.uiBinder.root_fitter:RefreshRectSize(channelHuntNameWidth)
  self.loopListView:OnItemSizeChanged(self.Index)
  self:refreshIsRepeat()
end

function ChatBubbleContent:refreshIsRepeat()
  if not self.uiBinder.btn_repeatother then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_repeatother, false)
  if self.parent.UIView.viewData.channelId == E.ChatChannelType.EComprehensive or self.parent.UIView.viewData.channelId == E.ChatChannelType.EChannelPrivate then
    return
  end
  local isRepeat = false
  if self:checkRepeat(self.data_) and self.Index >= 2 then
    local lastData = self.parent.DataList[self.Index - 1]
    if self:checkRepeat(lastData) then
      isRepeat = Z.ChatMsgHelper.GetMsg(lastData) == Z.ChatMsgHelper.GetMsg(self.data_)
    end
  end
  if isRepeat then
    self.uiBinder.lab_time.text = ""
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_repeatother, true)
  end
end

function ChatBubbleContent:checkRepeat(msgData)
  if Z.ChatMsgHelper.GetMsgType(msgData) ~= E.ChitChatMsgType.EChatMsgTextMessage then
    return false
  end
  if Z.ChatMsgHelper.GetCharId(msgData) == Z.ContainerMgr.CharSerialize.charId then
    return false
  end
  return true
end

function ChatBubbleContent:reSendBtnClick()
  if self:checkIsCd() then
    return
  end
  self.chatMainVm_.AsyncSendMessage(Z.ChatMsgHelper.GetChannelId(self.data_), Z.ChatMsgHelper.GetPrivateChatTargetId(self.data_), Z.ChatMsgHelper.GetMsg(self.data_), Z.ChatMsgHelper.GetMsgType(self.data_), Z.ChatMsgHelper.GetEmojiConfigId(self.data_), self.parent.UIView.cancelSource:CreateToken())
end

function ChatBubbleContent:checkIsCd()
  if Z.ChatMsgHelper.GetChannelId(self.data_) == E.ChatChannelType.EChannelPrivate then
    return false
  end
  local sendId = Z.ChatMsgHelper.GetChannelId(self.data_)
  local cd = self.chatMainData_:GetChatCD(sendId)
  if cd and 0 < cd then
    return true
  end
  return false
end

return ChatBubbleContent
