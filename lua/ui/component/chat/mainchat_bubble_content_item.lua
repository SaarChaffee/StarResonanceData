local super = require("ui.component.loop_list_view_item")
local MainChatBubbleContentItem = class("MainChatBubbleContentItem", super)

function MainChatBubbleContentItem:OnInit()
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
  self.idCardVm_ = Z.VMMgr.GetVM("idcard")
  self.uiBinder.btn_card:AddListener(function()
    self:showCardView()
  end)
end

function MainChatBubbleContentItem:showCardView()
  Z.CoroUtil.create_coro_xpcall(function()
    local charId = Z.ChatMsgHelper.GetCharId(self.data_)
    if charId and type(charId) == "number" and 0 < charId then
      self.idCardVm_.AsyncGetCardData(charId, self.parent.UIView.cancelSource:CreateToken())
    end
  end)()
end

function MainChatBubbleContentItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_icon:SetImage(Z.ChatMsgHelper.GetMainChatBubbleIcon(data))
  local msgType = Z.ChatMsgHelper.GetMsgType(data)
  local name = self:getBubbleName(data, msgType)
  self.uiBinder.lab_name.text = name
  local size = self.uiBinder.lab_name:GetPreferredValues(name)
  self.uiBinder.btn_card_ref:SetWidth(size.x + 22)
  local channelId = Z.ChatMsgHelper.GetChannelId(data)
  local channelName
  local config = self.chatMainData_:GetConfigData(channelId)
  if config then
    if Z.IsPCUI then
      channelName = Z.RichTextHelper.ApplyStyleTag(string.zconcat("[", config.ChannelName, "]"), config.ChannelStylePC)
    else
      channelName = Z.RichTextHelper.ApplyStyleTag(string.zconcat("[", config.ChannelName, "]"), config.ChannelStyle)
    end
  elseif Z.IsPCUI then
    channelName = Z.RichTextHelper.ApplyStyleTag(Lang("ChatPrivateChannel"), E.TextStyleTag.ChannelFriendPC)
  else
    channelName = Z.RichTextHelper.ApplyStyleTag(Lang("ChatPrivateChannel"), E.TextStyleTag.ChannelFriend)
  end
  local content = ""
  if msgType == E.ChitChatMsgType.EChatMsgVoice then
    content = Lang("chatMiniVoicePC")
  else
    content = self.chatMainVm_.GetShowMsg(data, self.uiBinder.lab_info, self.uiBinder.lab_info_ref, Z.IsPCUI)
  end
  content = string.zconcat(channelName, content)
  content = string.zconcat("<nobr>", content, "</nobr>")
  self.uiBinder.lab_info:SetTextWithReplaceSpace(content)
  self:refreshSize(name, content)
  self.loopListView:OnItemSizeChanged(self.Index)
  self.uiBinder.lab_info.raycastTarget = self.chatSettingData_:GetMainChatBubbleLink() and msgType == E.ChitChatMsgType.EChatMsgHypertext
end

function MainChatBubbleContentItem:getBubbleName(data, msgType)
  local name = Z.ChatMsgHelper.GetPlayerName(data)
  if name ~= "" then
    return name
  end
  if msgType ~= E.ChitChatMsgType.EChatMsgHypertext then
    return ""
  end
  local chatLink = Z.ChatMsgHelper.GetChatHyperlink(data)
  if not chatLink then
    return
  end
  return chatLink.NpcHeadEscape
end

function MainChatBubbleContentItem:refreshSize(name, content)
  local nameSize = self.uiBinder.lab_name:GetPreferredValues(name, 275, 15)
  self.uiBinder.lab_name_ref:SetWidth(nameSize.x)
  local contentSize = self.uiBinder.lab_info:GetPreferredValues(content, 290, 18)
  self.uiBinder.lab_info_ref:SetWidth(contentSize.x)
  self.uiBinder.lab_info_ref:SetHeight(contentSize.y)
  local width = math.max(nameSize.x + 35, contentSize.x + 18)
  local height = math.max(contentSize.y + 36, 54)
  self.uiBinder.img_pic_ref:SetWidth(width)
  self.uiBinder.img_pic_ref:SetHeight(height)
  self.uiBinder.Trans:SetHeight(height + 5)
end

return MainChatBubbleContentItem
