local ChatMsgHelper = {}
local iconPathRoot = "ui/atlas/mainui/chat/"
local iconPath = {
  [E.ChatChannelType.EChannelWorld] = "chat_world",
  [E.ChatChannelType.EChannelScene] = "chat_world",
  [E.ChatChannelType.EChannelTeam] = "chat_teammate",
  [E.ChatChannelType.EChannelUnion] = "chat_association",
  [E.ChatChannelType.EChannelPrivate] = {
    [1] = "chat_private_chat",
    [2] = "chat_friend"
  }
}

function ChatMsgHelper.GetChatHyperlink(chatMsgData)
  local chatHyperlinkId
  if chatMsgData.ChitChatMsg then
    if not chatMsgData.ChitChatMsg.msgInfo or not chatMsgData.ChitChatMsg.msgInfo.chatHypertext then
      return
    end
    chatHyperlinkId = chatMsgData.ChitChatMsg.msgInfo.chatHypertext.configId
  else
    if not chatMsgData.NoticeConfigId then
      return
    end
    chatHyperlinkId = chatMsgData.NoticeConfigId
  end
  local chatHyperLink = Z.TableMgr.GetTable("ChatHyperlinkMgr").GetRow(chatHyperlinkId, true)
  return chatHyperLink
end

function ChatMsgHelper.GetChannelId(chatMsgData)
  return chatMsgData.ChannelId
end

function ChatMsgHelper.GetMsgId(chatMsgData)
  if chatMsgData.ChitChatMsg then
    return chatMsgData.ChitChatMsg.msgId
  else
    return 0
  end
end

function ChatMsgHelper.GetMsgType(chatMsgData)
  if chatMsgData.ChitChatMsg then
    if chatMsgData.ChitChatMsg.msgInfo then
      return chatMsgData.ChitChatMsg.msgInfo.msgType
    else
      return E.ChitChatMsgType.EChatMsgTextMessage
    end
  else
    local msgType = chatMsgData.MsgType or E.ChitChatMsgType.EChatMsgClientTips
    return msgType
  end
end

function ChatMsgHelper.GetChatHyperLinkShowType(chatMsgData)
  if chatMsgData.ChatHyperLinkShowType then
    return chatMsgData.ChatHyperLinkShowType
  end
  local link = ChatMsgHelper.GetChatHyperlink(chatMsgData)
  if link then
    return link.Type
  end
end

function ChatMsgHelper.GetSendTime(chatMsgData)
  if chatMsgData.ChitChatMsg then
    return chatMsgData.ChitChatMsg.timestamp
  else
    return chatMsgData.TimeStamp
  end
end

function ChatMsgHelper.GetCharId(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.sendCharInfo and chatMsgData.ChitChatMsg.sendCharInfo then
    return chatMsgData.ChitChatMsg.sendCharInfo.charID
  end
  local charId = chatMsgData.SendCharId or 0
  return charId
end

function ChatMsgHelper.GetTargetCharId(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.msgInfo and chatMsgData.ChitChatMsg.msgInfo.targetId then
    return chatMsgData.ChitChatMsg.msgInfo.targetId
  else
    return 0
  end
end

function ChatMsgHelper.GetPrivateChatTargetId(chatMsgData)
  if chatMsgData.ChannelId ~= E.ChatChannelType.EChannelPrivate then
    return
  end
  local targetId
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.msgInfo then
    targetId = chatMsgData.ChitChatMsg.msgInfo.targetId
  end
  if targetId == Z.ContainerMgr.CharSerialize.charBase.charId and chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.sendCharInfo then
    targetId = chatMsgData.ChitChatMsg.sendCharInfo.charID
  end
  return targetId
end

function ChatMsgHelper.GetPlayerName(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.sendCharInfo then
    return chatMsgData.ChitChatMsg.sendCharInfo.name
  else
    return ""
  end
end

function ChatMsgHelper.GetPlayerIsNewbie(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.sendCharInfo then
    return chatMsgData.ChitChatMsg.sendCharInfo.isNewbie
  else
    return false
  end
end

function ChatMsgHelper.GetSenderLevel(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.sendCharInfo then
    return chatMsgData.ChitChatMsg.sendCharInfo.level
  else
    return 0
  end
end

function ChatMsgHelper.GetMsg(chatMsgData)
  if chatMsgData.ChitChatMsg then
    if chatMsgData.ChitChatMsg.msgInfo and chatMsgData.ChitChatMsg.msgInfo.msgText then
      if not chatMsgData.ChitChatMsgMsgInfoMsgText then
        chatMsgData.ChitChatMsgMsgInfoMsgText = Z.RichTextHelper.RemoveTagsOtherThanEmojis(chatMsgData.ChitChatMsg.msgInfo.msgText)
      end
      return chatMsgData.ChitChatMsgMsgInfoMsgText
    else
      return ""
    end
  else
    local msgText = chatMsgData.MsgText or ""
    return msgText
  end
end

function ChatMsgHelper.GetEmojiConfigId(chatMsgData)
  if not chatMsgData then
    return 0
  end
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.msgInfo and chatMsgData.ChitChatMsg.msgInfo.pictureEmoji and chatMsgData.ChitChatMsg.msgInfo.pictureEmoji.configId then
    return chatMsgData.ChitChatMsg.msgInfo.pictureEmoji.configId
  else
    return 0
  end
end

function ChatMsgHelper.GetEmojiRow(chatMsgData)
  local configId = ChatMsgHelper.GetEmojiConfigId(chatMsgData)
  if not configId then
    return
  end
  local row = Z.TableMgr.GetTable("ChatStickersTableMgr").GetRow(configId, true)
  return row
end

function ChatMsgHelper.GetEmojiText(chatMsgData)
  local configId = ChatMsgHelper.GetEmojiConfigId(chatMsgData)
  if not configId then
    return ""
  end
  local row = Z.TableMgr.GetTable("ChatStickersTableMgr").GetRow(configId, true)
  if not row then
    return ""
  end
  return row.Text
end

function ChatMsgHelper.GetIsSelfMessage(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.sendCharInfo and chatMsgData.ChitChatMsg.sendCharInfo.charID == Z.ContainerMgr.CharSerialize.charBase.charId then
    return true
  else
    return false
  end
end

function ChatMsgHelper.GetIsUnionHuntStar(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.sendCharInfo and chatMsgData.ChitChatMsg.sendCharInfo.unionHuntRandIdx then
    return chatMsgData.ChitChatMsg.sendCharInfo.unionHuntRandIdx == 1
  else
    return false
  end
end

function ChatMsgHelper.GetSystemType(chatMsgData)
  local headStr = chatMsgData.HeadStr or Lang("Acquire")
  return chatMsgData.SystemType, chatMsgData.SystemId, headStr
end

function ChatMsgHelper.GetVoiceFileId(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.msgInfo and chatMsgData.ChitChatMsg.msgInfo.voice and chatMsgData.ChitChatMsg.msgInfo.voice.fileId then
    return chatMsgData.ChitChatMsg.msgInfo.voice.fileId
  else
    return ""
  end
end

function ChatMsgHelper.SetVoiceFilePath(chatMsgData, filePath)
  chatMsgData.VoicePath = filePath
end

function ChatMsgHelper.GetVoiceFilePath(chatMsgData)
  return chatMsgData.VoicePath
end

function ChatMsgHelper.GetVoiceText(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.msgInfo and chatMsgData.ChitChatMsg.msgInfo.voice and chatMsgData.ChitChatMsg.msgInfo.voice.text then
    return chatMsgData.ChitChatMsg.msgInfo.voice.text
  else
    return ""
  end
end

function ChatMsgHelper.SetVoiceTextShow(chatMsgData)
  chatMsgData.VoiceIsShow = true
end

function ChatMsgHelper.GetVoiceTextShow(chatMsgData)
  return chatMsgData.VoiceIsShow
end

function ChatMsgHelper.SetVoiceIsPlay(chatMsgData, isPlay)
  chatMsgData.VoiceIsPlay = isPlay
end

function ChatMsgHelper.GetVoiceIsPlay(chatMsgData)
  return chatMsgData.VoiceIsPlay
end

function ChatMsgHelper.GetVoiceSeconds(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.msgInfo and chatMsgData.ChitChatMsg.msgInfo.voice and chatMsgData.ChitChatMsg.msgInfo.voice.seconds then
    return chatMsgData.ChitChatMsg.msgInfo.voice.seconds
  else
    return 0
  end
end

function ChatMsgHelper.GetNoticeConfigId(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.msgInfo and chatMsgData.ChitChatMsg.msgInfo.chatHypertext and chatMsgData.ChitChatMsg.msgInfo.chatHypertext.configId then
    return chatMsgData.ChitChatMsg.msgInfo.chatHypertext.configId
  else
    local noticeId = chatMsgData.NoticeConfigId or 0
    return noticeId
  end
end

function ChatMsgHelper.GetNoticeParamList(chatMsgData)
  if chatMsgData.ChitChatMsg and chatMsgData.ChitChatMsg.msgInfo and chatMsgData.ChitChatMsg.msgInfo.chatHypertext and chatMsgData.ChitChatMsg.msgInfo.chatHypertext.hypertextContents then
    return chatMsgData.ChitChatMsg.msgInfo.chatHypertext.hypertextContents
  else
    return chatMsgData.NoticeParamList
  end
end

function ChatMsgHelper.SetUnionBuild(chatMsgData, buildId)
  chatMsgData.UnionBuild = buildId
end

function ChatMsgHelper.GetUnionBuild(chatMsgData)
  return chatMsgData.UnionBuild
end

function ChatMsgHelper.GetMainChatBubbleIcon(chatMsgData)
  local iconName
  if chatMsgData.ChannelId == E.ChatChannelType.EChannelPrivate then
    local charId = ChatMsgHelper.GetCharId(chatMsgData)
    local friendMainData = Z.DataMgr.Get("friend_main_data")
    if friendMainData:IsFriendByCharId(charId) then
      iconName = iconPath[chatMsgData.ChannelId][2]
    else
      iconName = iconPath[chatMsgData.ChannelId][1]
    end
  else
    iconName = iconPath[chatMsgData.ChannelId]
  end
  iconName = iconName or iconPath[E.ChatChannelType.EChannelWorld]
  return string.zconcat(iconPathRoot, iconName)
end

function ChatMsgHelper.GetChatChannelIconByChannelId(channelId)
  local iconName = ""
  if channelId == E.ChatChannelType.EChannelPrivate then
    iconName = iconPath[channelId][1]
  else
    iconName = iconPath[channelId]
  end
  return string.zconcat(iconPathRoot, iconName)
end

function ChatMsgHelper.CheckChatMsgCanShow(chatMsgData)
  local channelId = ChatMsgHelper.GetChannelId(chatMsgData)
  if channelId == E.ChatChannelType.ESystem then
    return true
  end
  local msgType = ChatMsgHelper.GetMsgType(chatMsgData)
  if msgType == E.ChitChatMsgType.EChatMsgTextNotice or msgType == E.ChitChatMsgType.EChatMsgMultiLangNotice or msgType == E.ChitChatMsgType.EChatMsgHypertext then
    return true
  end
  local senderId = ChatMsgHelper.GetCharId(chatMsgData)
  if senderId == Z.ContainerMgr.CharSerialize.charId then
    return true
  end
  local charId = ChatMsgHelper.GetPrivateChatTargetId(chatMsgData)
  local chatMainData = Z.DataMgr.Get("chat_main_data")
  if chatMainData:IsInBlack(charId) then
    return false
  end
  local settingData = Z.DataMgr.Get("chat_setting_data")
  local limit = settingData:GetMessageLevel(channelId)
  if not limit then
    return true
  end
  local level = ChatMsgHelper.GetSenderLevel(chatMsgData)
  local messageLevelLimit = math.modf(limit)
  if messageLevelLimit and level and level < messageLevelLimit then
    return false
  else
    return true
  end
end

return ChatMsgHelper
