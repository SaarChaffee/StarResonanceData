local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleContent = class("ChatBubbleContent", super)

function ChatBubbleContent:OnInit()
  super.OnInit(self)
  self:AddAsyncListener(self.uiBinder.btn_content.OnLongPressEvent, function()
    self.parent.UIView:OpenChatTips(self.uiBinder.node_content_tips, E.ChatDialogueFuncType.CopyType, function()
      Z.LuaBridge.SystemCopy(Z.ChatMsgHelper.GetMsg(self.data_))
    end)
  end, nil, nil)
  if self.uiBinder.btn_repeatother then
    self:AddAsyncListener(self.uiBinder.btn_repeatother, function()
      self:reSendBtnClick()
    end)
  end
end

function ChatBubbleContent:OnRefresh(data)
  super.OnRefresh(self, data)
  local content = self.chatMainVm_.GetShowMsg(data, self.uiBinder.lab_msg, self.uiBinder.lab_msg_ref)
  self.uiBinder.lab_msg.text = content
  local size = self.uiBinder.lab_msg:GetPreferredValues(content, 584, 31)
  self.uiBinder.lab_msg_ref:SetWidth(size.x)
  self.uiBinder.lab_msg_ref:SetHeight(size.y)
  self.uiBinder.img_content:SetWidth(size.x + 32)
  self.uiBinder.img_content:SetHeight(size.y + 32)
  self.uiBinder.Trans:SetHeight(size.y + 90)
  self.loopListView:OnItemSizeChanged(self.Index)
  self:refreshIsRepeat()
end

function ChatBubbleContent:refreshIsRepeat()
  if not self.uiBinder.btn_repeatother then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_repeatother, false)
  if self.parent.UIView.viewData.chatChannelId == E.ChatChannelType.EComprehensive then
    return
  end
  local isRepeat = false
  if self:checkRepeat(self.data_) and self.Index > 2 then
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
  self.chatMainVm_.AsyncSendMessage(Z.ChatMsgHelper.GetChannelId(self.data_), Z.ChatMsgHelper.GetMsg(self.data_), Z.ChatMsgHelper.GetMsgType(self.data_), Z.ChatMsgHelper.GetEmojiConfigId(self.data_), self.parent.UIView.cancelSource:CreateToken())
end

function ChatBubbleContent:checkIsCd()
  if Z.ChatMsgHelper.GetChannelId(self.data_) == E.ChatChannelType.EChannelPrivate then
    return true
  end
  local sendId = Z.ChatMsgHelper.GetChannelId(self.data_)
  local cd = self.chatMainData_:GetChatCD(sendId)
  if cd and 0 < cd then
    return true
  end
  return false
end

return ChatBubbleContent
