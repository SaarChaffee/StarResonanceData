local super = require("ui.component.loop_list_view_item")
local mainchatLoopItem = class("mainchatLoopItem", super)

function mainchatLoopItem:OnInit()
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.width_ = 376
  if Z.IsPCUI then
    self.width_ = 350
  end
  self.uiBinder.Trans:SetWidth(self.width_)
  self.uiBinder.lab_content_ref:SetWidth(self.width_)
end

function mainchatLoopItem:OnRefresh(data)
  local channelId = Z.ChatMsgHelper.GetChannelId(data)
  local config = self.chatMainData_:GetConfigData(channelId)
  local channelName = Z.RichTextHelper.ApplyStyleTag(string.format("[%s]", config.ChannelName), config.ChannelStyle)
  local type = Z.ChatMsgHelper.GetMsgType(data)
  local content = self.chatMainVm_.GetShowMsg(data)
  if type == E.ChitChatMsgType.EChatMsgTextMessage or type == E.ChitChatMsgType.EChatMsgTextNotice or type == E.ChitChatMsgType.EChatMsgHypertext then
    if channelId == E.ChatChannelType.ESystem then
      content = string.format("%s%s", channelName, content)
    else
      content = string.format("%s%s:%s", channelName, Z.ChatMsgHelper.GetPlayerName(data), content)
    end
  elseif type == E.ChitChatMsgType.EChatMsgPictureEmoji then
    content = string.format("%s%s:[%s]", channelName, Z.ChatMsgHelper.GetPlayerName(data), Lang("chat_pic"))
  elseif type == E.ChitChatMsgType.EChatMsgVoice then
    content = string.format("%s%s:[%s]", channelName, Z.ChatMsgHelper.GetPlayerName(data), Lang("chatMiniVoice"))
  end
  content = string.zconcat("<nobr>", content, "</nobr>")
  self.uiBinder.lab_content:SetTextWithReplaceSpace(content)
  local size = self.uiBinder.lab_content:GetPreferredValues(content, self.width_, 32)
  local maxHeight = Z.IsPCUI and 20 or 32
  local height = math.max(size.y + 5, maxHeight)
  self.uiBinder.Trans:SetHeight(height)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function mainchatLoopItem:OnSelected(isSelected)
end

function mainchatLoopItem:OnUnInit()
end

return mainchatLoopItem
