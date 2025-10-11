local super = require("ui.component.loop_list_view_item")
local mainchatLoopItem = class("mainchatLoopItem", super)

function mainchatLoopItem:OnInit()
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
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
  local channelName
  if config then
    channelName = Z.RichTextHelper.ApplyStyleTag(string.zconcat("[", config.ChannelName, "]"), config.ChannelStyle)
  else
    channelName = Z.RichTextHelper.ApplyStyleTag(Lang("ChatPrivateChannel"), E.TextStyleTag.ChannelFriend)
  end
  local type = Z.ChatMsgHelper.GetMsgType(data)
  local content = self.chatMainVm_.GetShowMsg(data, self.uiBinder.lab_content, self.uiBinder.lab_content_ref)
  if type == E.ChitChatMsgType.EChatMsgTextMessage or type == E.ChitChatMsgType.EChatMsgTextNotice or type == E.ChitChatMsgType.EChatMsgHypertext then
    if channelId == E.ChatChannelType.ESystem then
      content = string.zconcat(channelName, content)
    else
      content = string.zconcat(channelName, Z.ChatMsgHelper.GetPlayerName(data), ":", content)
    end
  elseif type == E.ChitChatMsgType.EChatMsgPictureEmoji then
    local showContent = Z.ChatMsgHelper.GetEmojiText(data)
    if showContent ~= "" then
      content = string.zconcat(channelName, Z.ChatMsgHelper.GetPlayerName(data), ":", showContent)
    else
      content = string.zconcat(channelName, Z.ChatMsgHelper.GetPlayerName(data), ":", Lang("chat_pic"))
    end
  elseif type == E.ChitChatMsgType.EChatMsgVoice then
    content = string.zconcat(channelName, Z.ChatMsgHelper.GetPlayerName(data), ":", Lang("chatMiniVoice"))
  elseif type == E.ChitChatMsgType.EChatMsgClientTips then
    local type, _, _, systemContent = Z.ChatMsgHelper.GetSystemType(data)
    if type == E.ESystemTipInfoType.ItemInfo then
      content = Lang("ChaBubbleGet", {content = systemContent})
    else
      content = string.zconcat(channelName, content)
    end
  end
  content = string.zconcat("<nobr>", content, "</nobr>")
  self.uiBinder.lab_content:SetTextWithReplaceSpace(content)
  self.uiBinder.lab_content.raycastTarget = self.chatSettingData_:GetMainChatBubbleLink() and type == E.ChitChatMsgType.EChatMsgHypertext
  local size = self.uiBinder.lab_content:GetPreferredValues(content, self.width_, 32)
  local maxHeight = Z.IsPCUI and 20 or 32
  local height = math.max(size.y + 5, maxHeight)
  self.uiBinder.Trans:SetHeight(height)
  self.loopListView:OnItemSizeChanged(self.Index)
end

return mainchatLoopItem
