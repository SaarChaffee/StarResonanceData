local super = require("ui.component.loop_list_view_item")
local ChatMiniBubbleItem = class("ChatMiniBubbleItem", super)

function ChatMiniBubbleItem:OnRefresh(data)
  if not data then
    return
  end
  local showContext = Z.ChatMsgHelper.GetMsg(data)
  local msgType = Z.ChatMsgHelper.GetMsgType(data)
  local playName = Z.ChatMsgHelper.GetPlayerName(data)
  if msgType == E.ChitChatMsgType.EChatMsgHypertext then
    local chatData = Z.DataMgr.Get("chat_main_data")
    local config = chatData:GetConfigData(Z.ChatMsgHelper.GetChannelId(data))
    if config then
      local chatMainVm = Z.VMMgr.GetVM("chat_main")
      showContext = string.format("%s: %s", config.ChannelName, chatMainVm.GetShowMsg(data, self.uiBinder.lab_bubble, self.uiBinder.Trans))
    end
  elseif msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
    showContext = string.format("[%s]", Lang("chatMiniPic"))
  elseif msgType == E.ChitChatMsgType.EChatMsgVoice then
    showContext = string.format("[%s]", Lang("chatMiniVoice"))
  end
  if Z.ChatMsgHelper.GetCharId(data) == Z.ContainerMgr.CharSerialize.charId then
    local colorTag = Z.Global.Chat_FriendChatNoticeColor
    local strName = Z.RichTextHelper.ApplyStyleTag(playName, colorTag)
    showContext = string.format("%s: %s", strName, showContext)
  else
    showContext = string.format("%s: %s", playName, showContext)
  end
  self.uiBinder.lab_bubble.text = showContext
  local size = self.uiBinder.lab_bubble:GetPreferredValues(showContext, 520, 31)
  self.uiBinder.Trans:SetHeight(size.y)
  self.loopListView:OnItemSizeChanged(self.Index)
end

return ChatMiniBubbleItem
