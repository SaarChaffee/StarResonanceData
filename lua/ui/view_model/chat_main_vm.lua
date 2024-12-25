local ret = {}
local chatMainData = Z.DataMgr.Get("chat_main_data")
local settingData = Z.DataMgr.Get("chat_setting_data")
local friendMainData = Z.DataMgr.Get("friend_main_data")
local chitChatProxy = require("zproxy.chit_chat_proxy")
local worldProxy = require("zproxy.world_proxy")
local pb = require("pb2")
local recordCount = 30
local mainChannelQueueCount = 8
local oneDayTime = 86400
E.MiniChatType = {EChatBtn = 1, EChatView = 2}
E.ChitChatMsgType = {
  EChatMsgTextMessage = 0,
  EChatMsgTextNotice = 1,
  EChatMsgMultiLangNotice = 2,
  EChatMsgPictureEmoji = 3,
  EChatMsgPicture = 4,
  EChatMsgVoice = 5,
  EChatMsgHypertext = 6,
  EChatMsgClientTips = 99
}
E.PlaceHolderType = {
  PlaceHolderTypeVal = 1,
  PlaceHolderTypePlayer = 2,
  PlaceHolderTypeItem = 3,
  PlaceHolderTypeUnion = 4,
  PlaceHolderTypeBuff = 5,
  PlaceHolderTypeTimestamp = 6,
  PlaceHolderTypeString = 7,
  PlaceHolderTypeFishPersonalTotal = 8,
  PlaceHolderTypeFishItem = 9,
  PlaceHolderTypeFishRank = 10
}
E.ClientPlaceHolderType = {
  UnionHunt = 1,
  UnionGrow = 2,
  UnionAlbum = 3,
  UnionLock = 4,
  UnionUnlock = 5,
  ItemShare = 6,
  GoToWorldBoss = 7,
  UnionWarDance = 8,
  PersonalZone = 9
}
E.ChatHyperLinkShowType = {
  SystemTips = 1,
  UnionTips = 2,
  NpcHeadTips = 3,
  PictureBtnTips = 4,
  PictureBtnTipsNew = 5
}

function ret.AsyncInitChatData()
  if not chatMainData:GetIsInitChatRecord() then
    chatMainData:SetIsInitChatRecord(true)
    ret.asyncInitPrivateChatList()
    ret.asyncInitWorldChatChannelId()
    ret.asyncInitRecord()
    ret.asyncInitBlackList()
    ret.asyncInitBanData()
  end
end

function ret.asyncInitPrivateChatList()
  local privateReply = chitChatProxy.GetPrivateChatTargets({}, chatMainData.CancelSource:CreateToken())
  if privateReply.errCode == 0 then
    chatMainData:ClearChannelQueueByChannelId(E.ChatChannelType.EChannelPrivate)
    chatMainData:ClearPrivateChatList()
    if privateReply.targetList and 0 < #privateReply.targetList then
      for i = 1, #privateReply.targetList do
        chatMainData:AddPrivateChatListAddByTargetInfo(privateReply.targetList[i])
      end
      ret.AsyncUpdatePrivateChatCharInfo()
      Z.RedPointMgr.RefreshServerNodeCount(E.RedType.FriendChatTab, chatMainData:GetPrivateChatUnReadCount())
    end
  else
    Z.TipsVM.ShowTips(privateReply.errCode)
  end
end

function ret.AsyncUpdatePrivateChatCharInfo(isRefresh)
  local privateChatList = chatMainData:GetPrivateChatList()
  if 0 < #privateChatList then
    for i = 1, #privateChatList do
      if not privateChatList[i].socialData or isRefresh then
        local socialVM = Z.VMMgr.GetVM("social")
        local socialData = socialVM.AsyncGetHeadAndHeadFrameInfo(privateChatList[i].charId, chatMainData.CancelSource:CreateToken())
        privateChatList[i].socialData = socialData
      end
    end
  end
end

function ret.UpdatePrivateChatLastMsg(charId)
  local privateChatList = chatMainData:GetPrivateChatList()
  if 0 < #privateChatList then
    for i = 1, #privateChatList do
      if privateChatList[i].charId == charId then
        local chatQueue = chatMainData:GetChannelQueueByChannelId(E.ChatChannelType.EChannelPrivate, charId, false)
        if 0 < #chatQueue then
          privateChatList[i].latestMsg = chatQueue[#chatQueue]
        end
      end
    end
  end
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.FriendChatTab, chatMainData:GetPrivateChatUnReadCount())
end

function ret.AsyncUpdatePrivateChatList(data)
  chatMainData:AddPrivateChatListAddByTargetInfo(data.addTargetInfo)
  ret.AsyncUpdatePrivateChatCharInfo()
  chatMainData:DelPrivateChatByCharId(data.delTargetId)
end

function ret.asyncInitWorldChatChannelId()
  local worldReply = chitChatProxy.GetWorldChatChannelId({}, chatMainData.CancelSource:CreateToken())
  if worldReply.errCode == 0 then
    chatMainData:SetWorldGroupId(worldReply.channelId, worldReply.userNum, worldReply.maxNum)
  else
    Z.TipsVM.ShowTips(worldReply.errCode)
  end
end

function ret.AsyncChannelGroupSwitch(groupId, cancelToken)
  local setWorldChannelReply = chitChatProxy.SetWorldChatChannelId({channelId = groupId}, cancelToken)
  if setWorldChannelReply.errCode == 0 then
    chatMainData:SetWorldGroupId(groupId, setWorldChannelReply.userNum, setWorldChannelReply.maxNum)
    chatMainData:ClearClientChannelData(E.ChatChannelType.EComprehensive, E.ChatChannelType.EChannelWorld)
    ret.asyncUpdateWorldChannelRecord(E.ChatChannelType.EChannelWorld, setWorldChannelReply.userNum)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.RefreshFromEnd, E.ChatChannelType.EChannelWorld)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.RefreshChatViewEmptyState)
  else
    Z.TipsVM.ShowTips(setWorldChannelReply.errCode)
  end
end

function ret.ClearChannelQueueByChannelId(chatChannelType)
  chatMainData:ClearClientChannelData(E.ChatChannelType.EComprehensive, chatChannelType)
  chatMainData:ClearClientChannelData(E.ChatChannelType.EMain, chatChannelType)
  chatMainData:ClearChannelQueueByChannelId(chatChannelType)
  if settingData:GetSynthesis(chatChannelType) then
    chatMainData:ClearComprehensiveChannelChatTipsAndChannelMsg()
    ret.checkChatQueueTimeTips(E.ChatChannelType.EComprehensive)
  end
  chatMainData:SetChatDataFlg(E.ChatChannelType.EComprehensive, E.ChatWindow.Main, true, true)
  chatMainData:SetChatDataFlg(E.ChatChannelType.EMain, E.ChatWindow.Main, true, true)
end

function ret.asyncInitRecord()
  chatMainData:ClearChannelQueueByChannelId(E.ChatChannelType.EComprehensive)
  ret.asyncGetChannelChatRecord(E.ChatChannelType.EChannelWorld, 0)
  ret.asyncGetChannelChatRecord(E.ChatChannelType.EChannelScene, 0)
  ret.asyncGetChannelChatRecord(E.ChatChannelType.EChannelTeam, 0)
  ret.asyncGetChannelChatRecord(E.ChatChannelType.EChannelUnion, 0)
  ret.asyncGetChannelChatRecord(E.ChatChannelType.ESystem, 0)
  chatMainData:SortChannelChatQueue(E.ChatChannelType.EComprehensive)
  ret.checkChatQueueTimeTips(E.ChatChannelType.EComprehensive)
end

function ret.asyncInitBlackList()
  local blackReply = chitChatProxy.PrivateChatBlockList({}, chatMainData.CancelSource:CreateToken())
  if blackReply.errCode == 0 then
    chatMainData:InitBlackList(blackReply.blockIdList)
    local friendVM = Z.VMMgr.GetVM("friends_main")
    friendVM.AsyncRefreshBlacks(blackReply.blockIdList)
  else
    Z.TipsVM.ShowTips(blackReply.errCode)
  end
end

function ret.asyncInitBanData()
  local banReply = chitChatProxy.QueryChatMute({}, chatMainData.CancelSource:CreateToken())
  if banReply.errCode == 0 then
    ret.UpdatePersonalBanInfo(banReply)
  else
    Z.TipsVM.ShowTips(banReply.errCode)
  end
end

function ret.UpdatePersonalBanInfo(banData)
  if banData.isBan then
    chatMainData:SetBanTime(banData.endTimestamp)
  else
    chatMainData:SetBanTime(0)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
end

function ret.checkChatMsgDataDayTips(newTime, oldTime)
  if not newTime or not oldTime then
    return false
  end
  if newTime // oneDayTime ~= oldTime // oneDayTime then
    return true
  end
  return false
end

function ret.addTimeTips(channelId, targetId, time, index, queue)
  local chatData = {
    ChannelId = channelId,
    TargetCharId = targetId,
    MsgText = os.date("%Y-%m-%d", time),
    TimeStamp = time,
    ChatHyperLinkShowType = E.ChatHyperLinkShowType.SystemTips
  }
  table.insert(queue, index, chatData)
end

function ret.checkChatQueueTimeTips(channelId, targetId)
  local chatQueue = chatMainData:GetChannelQueueByChannelId(channelId, targetId, true)
  if #chatQueue == 0 then
    return
  end
  local curTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local firstTime = Z.ChatMsgHelper.GetSendTime(chatQueue[1])
  if Z.ChatMsgHelper.GetMsgType(chatQueue[1]) ~= E.ChitChatMsgType.EChatMsgClientTips and ret.checkChatMsgDataDayTips(curTime, firstTime) then
    ret.addTimeTips(channelId, targetId, firstTime, 1, chatQueue)
  end
  for i = #chatQueue, 2, -1 do
    local newChatMsgData = chatQueue[i]
    local oldChatMsgData = chatQueue[i - 1]
    if Z.ChatMsgHelper.GetMsgType(newChatMsgData) ~= E.ChitChatMsgType.EChatMsgClientTips and Z.ChatMsgHelper.GetMsgType(oldChatMsgData) ~= E.ChitChatMsgType.EChatMsgClientTips and ret.checkChatMsgDataDayTips(Z.ChatMsgHelper.GetSendTime(newChatMsgData), Z.ChatMsgHelper.GetSendTime(oldChatMsgData)) then
      ret.addTimeTips(channelId, targetId, Z.ChatMsgHelper.GetSendTime(newChatMsgData), i, chatQueue)
    end
  end
end

function ret.checkChannelIdOnGetChannelRecord(channelId)
  if channelId == E.ChatChannelType.EChannelWorld then
    return true
  elseif channelId == E.ChatChannelType.EChannelScene then
    return true
  elseif channelId == E.ChatChannelType.ESystem then
    return true
  elseif channelId == E.ChatChannelType.EChannelTeam then
    return Z.VMMgr.GetVM("team").CheckIsInTeam()
  elseif channelId == E.ChatChannelType.EChannelUnion then
    local unionVM = Z.VMMgr.GetVM("union")
    if unionVM:GetPlayerUnionId() == 0 then
      return false
    else
      return true
    end
  end
  return false
end

function ret.AsyncCreatePrivateChat(charId, cancelToken)
  local request = {}
  request.targetId = charId
  chitChatProxy.CreatePrivateChatSession(request, cancelToken)
  chatMainData:AddPrivateChatByCharId(charId)
end

function ret.AsyncDeletePrivateChat(charId, cancelToken)
  local request = {}
  request.targetId = charId
  local reply = chitChatProxy.DeletePrivateChatSession(request, cancelToken)
  if reply.errCode == 0 then
    chatMainData:DelPrivateChatByCharId(charId)
    if friendMainData:GetChatSelectCharId() == charId then
      friendMainData:SetChatSelectCharId(0)
      friendMainData:ClearChatRightSubViewList()
    end
    return true
  else
    Z.TipsVM.ShowTips(reply.errCode)
    return false
  end
end

function ret.CheckPrivateChatCharId(charId)
  if charId <= 0 then
    return
  end
  local isHave = chatMainData:GetIsHavePrivateChatItemByCharId(charId)
  if isHave then
    return
  end
  local countMax = Z.Global.Chat_MaxChatList
  if countMax == nil then
    logError("GlobalConfig Chat_MaxChatList not exit")
    return
  end
  local chatList = chatMainData:GetPrivateChatList()
  if countMax <= #chatList then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.DeletePrivateChat, chatList[#chatList - 1].charId)
  end
  if not chatMainData:IsHavePrivateChat(charId) then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.CreatePrivateChat, charId)
  end
end

function ret.GetSearchDataList(searchContext)
  local list = {}
  local privateChatList = chatMainData:GetPrivateChatList()
  if privateChatList == nil or #privateChatList == 0 then
    return
  end
  for _, privateChatItem in pairs(privateChatList) do
    if privateChatItem and privateChatItem.socialData and privateChatItem.socialData.basicData and privateChatItem.socialData.basicData.name then
      local charName = privateChatItem.socialData.basicData.name
      if string.match(charName, searchContext) then
        table.insert(list, privateChatItem)
      else
        local friendData = friendMainData:GetFriendDataByCharId(privateChatItem.charId)
        if friendData and friendData:GetRemark() and string.match(friendData:GetRemark(), searchContext) then
          table.insert(list, privateChatItem)
        end
      end
    end
  end
  return list
end

function ret.asyncGetChannelRecord(channelID, startIndex, count, targetId)
  local request = {}
  request.channelType = channelID
  request.descMsgId = startIndex
  request.recordNum = count
  request.targetId = targetId
  local recordReply = chitChatProxy.GetChipChatRecords(request, chatMainData.CancelSource:CreateToken())
  return recordReply
end

function ret.getRecordStartIndex(queue)
  if 0 < #queue then
    for i = 1, #queue do
      if Z.ChatMsgHelper.GetMsgType(queue[i]) ~= E.ChitChatMsgType.EChatMsgClientTips then
        return Z.ChatMsgHelper.GetMsgId(queue[i])
      end
    end
  end
  return 0
end

function ret.AsyncGetRecord(channelID, charId)
  if not channelID then
    return
  end
  if channelID == E.ChatChannelType.EComprehensive then
    ret.asyncGetComprehensiveRecord()
    return
  end
  local queue = chatMainData:GetChannelQueueByChannelId(channelID, charId, true)
  if queue then
    local lastMsgId = ret.getRecordStartIndex(queue)
    charId = charId and charId or chatMainData:GetPrivateSelectId()
    if 0 <= lastMsgId then
      if channelID == E.ChatChannelType.EChannelPrivate then
        ret.AsyncGetPrivateChatRecord(charId, lastMsgId)
      else
        ret.asyncGetChannelChatRecord(channelID, lastMsgId)
      end
    end
  end
end

function ret.asyncGetComprehensiveRecord()
  if settingData:GetSynthesis(E.ChatChannelType.EChannelWorld) then
    ret.AsyncGetRecord(E.ChatChannelType.EChannelWorld)
  end
  if settingData:GetSynthesis(E.ChatChannelType.EChannelScene) then
    ret.AsyncGetRecord(E.ChatChannelType.EChannelScene)
  end
  if settingData:GetSynthesis(E.ChatChannelType.EChannelTeam) then
    ret.AsyncGetRecord(E.ChatChannelType.EChannelTeam)
  end
  if settingData:GetSynthesis(E.ChatChannelType.EChannelUnion) then
    ret.AsyncGetRecord(E.ChatChannelType.EChannelUnion)
  end
  if settingData:GetSynthesis(E.ChatChannelType.ESystem) then
    ret.AsyncGetRecord(E.ChatChannelType.ESystem)
  end
  ret.updateComprehensiveTips()
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.GetRecord)
end

function ret.updateComprehensiveTips()
  chatMainData:ClearChannelChatTips(E.ChatChannelType.EComprehensive)
  chatMainData:SortChannelChatQueue(E.ChatChannelType.EComprehensive)
  ret.checkChatQueueTimeTips(E.ChatChannelType.EComprehensive)
end

function ret.UpdateComprehensiveRecord()
  chatMainData:ClearChannelQueueByChannelId(E.ChatChannelType.EComprehensive)
  ret.saveAllMsgToComprehensive(E.ChatChannelType.EChannelWorld)
  ret.saveAllMsgToComprehensive(E.ChatChannelType.EChannelScene)
  ret.saveAllMsgToComprehensive(E.ChatChannelType.EChannelTeam)
  ret.saveAllMsgToComprehensive(E.ChatChannelType.EChannelUnion)
  ret.saveAllMsgToComprehensive(E.ChatChannelType.ESystem)
  chatMainData:SortChannelChatQueue(E.ChatChannelType.EComprehensive)
  chatMainData:ClearChannelChatTips(E.ChatChannelType.EComprehensive)
  ret.checkChatQueueTimeTips(E.ChatChannelType.EComprehensive)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.GetRecord)
end

function ret.saveAllMsgToComprehensive(channelId)
  if settingData:GetSynthesis(channelId) then
    local chatQueue = chatMainData:GetChannelQueueByChannelId(channelId, 0, true)
    for i = #chatQueue, 1, -1 do
      if Z.ChatMsgHelper.GetMsgType(chatQueue[i]) ~= E.ChitChatMsgType.EChatMsgClientTips then
        ret.saveChatData(E.ChatChannelType.EComprehensive, chatQueue[i], true)
      end
    end
  end
end

function ret.saveChatData(channelId, chatMsgData, isRecord, targetId, maxCount, autoSort)
  chatMainData:SaveChatMsgDataToChannelQueue(channelId, chatMsgData, targetId, isRecord, maxCount, autoSort)
  chatMainData:SetChatDataFlg(channelId, E.ChatWindow.Main, true, isRecord)
  chatMainData:SetChatDataFlg(channelId, E.ChatWindow.Mini, true, isRecord)
end

function ret.checkPrivateChatNewMsgTips(channelId, charId)
  if channelId ~= E.ChatChannelType.EChannelPrivate then
    return
  end
  if chatMainData:GetPrivateSelectId() == charId and chatMainData:GetNewPrivateChatMessageTipsCharId() == 0 then
    chatMainData:SetNewPrivateChatMessageTipsCharId(charId)
    local chatDataNewMessageTips = {
      ChannelId = channelId,
      TargetCharId = charId,
      MsgText = Lang("privateChatNewMessageTips"),
      TimeStamp = Z.ServerTime:GetServerTime() * 0.001,
      IsNewMessage = true,
      ChatHyperLinkShowType = E.ChatHyperLinkShowType.SystemTips
    }
    ret.saveChatData(channelId, chatDataNewMessageTips, false, charId)
  end
end

function ret.saveChannelMsg(channelId, chatMsgList, isRecord, targetId, autoSort)
  if chatMsgList and 0 < #chatMsgList then
    for i = 1, #chatMsgList do
      local chatMsgData = {
        ChannelId = channelId,
        ChitChatMsg = chatMsgList[i]
      }
      ret.saveChatData(channelId, chatMsgData, isRecord, targetId)
      ret.saveMainMsg(chatMsgData, isRecord)
      ret.checkMessageLinkInfo(chatMsgData, isRecord, targetId)
      ret.checkComprehensive(channelId, chatMsgData, isRecord, autoSort)
      if not isRecord then
        ret.addBullet(chatMsgData)
      end
    end
  end
  if isRecord then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.GetRecord, channelId)
  end
  if channelId == E.ChatChannelType.EChannelPrivate then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.PrivateChatRefresh)
  end
end

function ret.checkMessageLinkInfo(chatMsgData, isRecord, targetId)
  if isRecord then
    return
  end
  local chatHyperLink = Z.ChatMsgHelper.GetChatHyperlink(chatMsgData)
  if not chatHyperLink then
    return
  end
  if chatHyperLink.MessageTableId and chatHyperLink.MessageTableId > 0 then
    local message = ret.GetShowMsg(chatMsgData)
    Z.TipsVM.OpenMessageViewByContextAndConfig(message, chatHyperLink.MessageTableId)
  end
  if chatHyperLink.IsShowInsystem then
    ret.saveChatData(E.ChatChannelType.ESystem, chatMsgData, isRecord, targetId)
  end
end

function ret.checkComprehensive(channelId, chatMsgData, isRecord, autoSort)
  if settingData:GetSynthesis(channelId) then
    ret.saveChatData(E.ChatChannelType.EComprehensive, chatMsgData, isRecord, nil, nil, autoSort)
  end
end

function ret.addBullet(chatMsgData)
  for _, data in pairs(chatMainData.BulletList) do
    if data.isShow == false then
      data.chatMsgData = chatMsgData
      return
    end
  end
  table.insert(chatMainData.BulletList, {chatMsgData = chatMsgData, isShow = false})
end

function ret.saveChatMsgData(channelId, chatMsgData, isRecord, targetId)
  ret.saveChatData(channelId, chatMsgData, isRecord, targetId)
  ret.saveMainMsg(chatMsgData, isRecord)
  if isRecord then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.GetRecord, channelId)
  end
  if channelId == E.ChatChannelType.EChannelPrivate then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.PrivateChatRefresh)
  end
end

function ret.saveComprehensiveMsg(chatMsgData, isRecord)
  if chatMsgData.IsComprehensive then
    ret.saveChatData(E.ChatChannelType.EComprehensive, chatMsgData, isRecord)
  end
end

function ret.saveMainMsg(chatMsgData, isRecord)
  local channel = settingData:GetChatList(Z.ChatMsgHelper.GetChannelId(chatMsgData))
  if channel then
    ret.saveChatData(E.ChatChannelType.EMain, chatMsgData, isRecord, nil, mainChannelQueueCount)
  end
end

function ret.SetReceiveSystemMsg(info)
  local msg = ""
  local darkMsg = ""
  if info.Type == E.ESystemTipInfoType.ItemInfo then
    if info.Id then
      local contentStr = Z.VMMgr.GetVM("items").ApplyItemNameWithQualityTag(info.Id)
      if info.Content ~= "" and contentStr ~= "" then
        local param = {
          item = {
            name = contentStr,
            num = info.Content
          }
        }
        msg = Lang("systemItemNoticeDark", param)
      end
      local contentDarkStr = Z.VMMgr.GetVM("items").ApplyItemNameWithQualityTag(info.Id)
      if info.Content ~= "" and contentDarkStr ~= "" then
        local param = {
          item = {
            name = contentDarkStr,
            num = info.Content
          }
        }
        darkMsg = Lang("systemItemNoticeDark", param)
      end
    end
  elseif info.Type == E.ESystemTipInfoType.MessageInfo and info.Content ~= "" then
    msg = info.Content
    darkMsg = info.Content
  end
  local chatMsgData = {
    ChannelId = E.ChatChannelType.ESystem,
    MsgText = msg,
    SystemType = info.Type,
    SystemId = info.Id,
    HeadStr = info.HeadStr
  }
  ret.saveChatData(E.ChatChannelType.ESystem, chatMsgData, false)
  if settingData:GetSynthesis(E.ChatChannelType.ESystem) then
    ret.saveChatData(E.ChatChannelType.EComprehensive, chatMsgData, false)
  end
  local mainChatMsgData = {
    ChannelId = E.ChatChannelType.ESystem,
    MsgText = darkMsg,
    SystemType = info.Type,
    SystemId = info.Id
  }
  ret.saveMainMsg(mainChatMsgData)
  ret.addBullet(chatMsgData)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.BubbleMsg, chatMsgData)
end

function ret.asyncUpdateWorldChannelRecord(channelId, channelMemberCount)
  chatMainData:ClearChannelQueueByChannelId(channelId)
  local worldGroupId = chatMainData:GetShowWorldGroupChannel()
  local chatData = {
    ChannelId = channelId,
    MsgText = string.format(Lang("joinChannelTips"), worldGroupId, channelMemberCount),
    TimeStamp = Z.ServerTime:GetServerTime() * 0.001,
    IsShowInFirst = true,
    ChatHyperLinkShowType = E.ChatHyperLinkShowType.SystemTips
  }
  ret.saveChatMsgData(channelId, chatData, false)
  ret.asyncGetChannelChatRecord(channelId, 0, true)
end

function ret.AsyncGetPrivateChatRecord(targetId, startIndex)
  local recordReply = ret.asyncGetChannelRecord(E.ChatChannelType.EChannelPrivate, startIndex, recordCount, targetId)
  if recordReply.errCode == 0 then
    chatMainData:UpdatePrivateChatByCharId(targetId, nil, recordReply.maxReadMsgId, recordReply.isEnd)
    ret.saveChannelMsg(E.ChatChannelType.EChannelPrivate, recordReply.multiMsgList, true, targetId)
    ret.checkChatQueueTimeTips(E.ChatChannelType.EChannelPrivate, targetId)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
  else
    Z.TipsVM.ShowTips(recordReply.errCode)
  end
end

function ret.asyncGetChannelChatRecord(channelId, lastMsgId, autoSort)
  if ret.checkChannelIdOnGetChannelRecord(channelId) and E.ChatChannelType.EChannelPrivate ~= channelId then
    local recordReply = ret.asyncGetChannelRecord(channelId, lastMsgId, recordCount)
    if recordReply.errCode == 0 then
      ret.saveChannelMsg(channelId, recordReply.multiMsgList, true, nil, autoSort)
      chatMainData:ClearChannelChatTips(channelId)
      ret.checkChatQueueTimeTips(channelId)
    end
  end
end

function ret.ReceiveMsg(vRequest)
  local targetId
  if vRequest.channelType == E.ChatChannelType.EChannelPrivate then
    local sender
    if vRequest.chatMsg.sendCharInfo then
      targetId = vRequest.chatMsg.sendCharInfo.charID
      sender = targetId
    end
    if targetId == Z.ContainerMgr.CharSerialize.charBase.charId and vRequest.chatMsg.msgInfo then
      targetId = vRequest.chatMsg.msgInfo.targetId
      sender = nil
    end
    ret.CheckPrivateChatCharId(targetId)
    ret.checkPrivateChatNewMsgTips(vRequest.channelType, sender)
  end
  if vRequest.channelType == nil or vRequest.channelType == E.ChatChannelType.EChannelTopNotice then
    local chatMsgData = {
      ChannelId = vRequest.channelType,
      ChitChatMsg = vRequest.chatMsg
    }
    local chatHyperLink = Z.ChatMsgHelper.GetChatHyperlink(chatMsgData)
    if not chatHyperLink then
      return
    end
    local message = ret.GetShowMsg(chatMsgData)
    Z.TipsVM.OpenMessageViewByContextAndConfig(message, chatHyperLink.MessageTableId)
    Z.TipsVM.OpenGameBroadcast(message)
  else
    ret.saveChannelMsg(vRequest.channelType, {
      vRequest.chatMsg
    }, false, targetId)
  end
  if vRequest.chatMsg.msgInfo and vRequest.chatMsg.msgInfo.chatHypertext and (vRequest.chatMsg.msgInfo.chatHypertext.configId == 5010001 or vRequest.chatMsg.msgInfo.chatHypertext.configId == 5010002) then
    local unionVm = Z.VMMgr.GetVM("union")
    unionVm:NotifyUnionActivity(vRequest.chatMsg.msgInfo.chatHypertext.configId)
  end
end

function ret.checkCanSendMessage(channelId)
  if channelId == E.ChatChannelType.EChannelTeam then
    if Z.VMMgr.GetVM("team").CheckIsInTeam() == false then
      Z.TipsVM.ShowTipsLang(1000100)
      return false
    end
  elseif channelId == E.ChatChannelType.EChannelNull or channelId == E.ChatChannelType.EChannelGroup or channelId == E.ChatChannelType.EChannelTopNotice or channelId == E.ChatChannelType.ESystem or channelId == E.ChatChannelType.EMain then
    return false
  end
  return true
end

function ret.AsyncSendMessage(channelId, msgText, msgType, configId, cancelToken, voiceFileId, voiceTime, voiceText)
  local cd = chatMainData:GetChatCD(channelId)
  if cd and 0 < cd then
    return
  end
  if ret.checkCanSendMessage(channelId) == false then
    return
  end
  if msgType == E.ChitChatMsgType.EChatMsgTextMessage and (msgText == "" or msgText == nil) then
    return
  end
  local targetId = channelId == E.ChatChannelType.EChannelPrivate and chatMainData:GetPrivateSelectId() or 0
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  local msgInfo = {}
  msgInfo.msgType = msgType
  msgInfo.targetId = targetId
  msgInfo.msgText = msgText
  if configId then
    local pictureEmoji = {}
    pictureEmoji.configId = configId
    msgInfo.pictureEmoji = pictureEmoji
  end
  if voiceFileId then
    local voice = {}
    voice.fileId = voiceFileId
    voice.text = voiceText
    voice.seconds = voiceTime
    msgInfo.voice = voice
  end
  request.msgInfo = msgInfo
  local sendReplay = chitChatProxy.SendChitChatMsg(request, cancelToken)
  if sendReplay.errCode == 0 then
    local cdTime = sendReplay.cdEndTime - sendReplay.showMsg.timestamp
    if cdTime and 0 < cdTime then
      chatMainData:SetChatCD(channelId, cdTime)
      local tmpTime = cdTime
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
      local func = function()
        tmpTime = tmpTime - 1
        chatMainData:SetChatCD(channelId, tmpTime)
        Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
      end
      local delta = 1
      local funcFinish = function()
        Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
      end
      Z.GlobalTimerMgr:StartTimer(channelId, func, delta, cdTime, nil, funcFinish)
    end
    if voiceFileId == nil then
      chatMainData:SetMsgHistory(msgType, sendReplay.showMsg.msgInfo.msgText)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatHistoryRefresh)
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
  else
    Z.TipsVM.ShowTips(sendReplay.errCode)
  end
end

function ret.AsyncSendItemShare(channelId, cancelToken)
  local item = chatMainData:GetShareProtoData()
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = 1
  request.objectUuId = item.itemUuid
  local itemShareData = chatMainData:GetShareData()
  if itemShareData.string1 then
    request.beforeDesc = itemShareData.string1
  end
  if itemShareData.string2 then
    request.afterDesc = itemShareData.string2
  end
  local targetId = channelId == E.ChatChannelType.EChannelPrivate and chatMainData:GetPrivateSelectId() or 0
  request.targetCharId = targetId
  local sendReplay = worldProxy.ShareObjectInChat(request, cancelToken)
  if sendReplay.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(sendReplay.errCode)
    return false
  end
end

function ret.AsyncSendFishingArchivesShare(channelId, cancelToken)
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = 2
  local itemShareData = chatMainData:GetShareData()
  if itemShareData.string1 then
    request.beforeDesc = itemShareData.string1
  end
  if itemShareData.string2 then
    request.afterDesc = itemShareData.string2
  end
  local targetId = channelId == E.ChatChannelType.EChannelPrivate and chatMainData:GetPrivateSelectId() or 0
  request.targetCharId = targetId
  local sendReplay = worldProxy.ShareObjectInChat(request, cancelToken)
  if sendReplay.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(sendReplay.errCode)
    return false
  end
end

function ret.AsyncSendFishingIllurateShare(channelId, cancelToken)
  local item = chatMainData:GetShareProtoData()
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = 3
  request.objectUuId = item.FishId
  local itemShareData = chatMainData:GetShareData()
  if itemShareData.string1 then
    request.beforeDesc = itemShareData.string1
  end
  if itemShareData.string2 then
    request.afterDesc = itemShareData.string2
  end
  local targetId = channelId == E.ChatChannelType.EChannelPrivate and chatMainData:GetPrivateSelectId() or 0
  request.targetCharId = targetId
  local sendReplay = worldProxy.ShareObjectInChat(request, cancelToken)
  if sendReplay.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(sendReplay.errCode)
    return false
  end
end

function ret.AsyncSendFishingRankShare(channelId, cancelToken)
  local item = chatMainData:GetShareProtoData()
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = 4
  request.objectUuId = item.FishId
  local itemShareData = chatMainData:GetShareData()
  if itemShareData.string1 then
    request.beforeDesc = itemShareData.string1
  end
  if itemShareData.string2 then
    request.afterDesc = itemShareData.string2
  end
  local targetId = channelId == E.ChatChannelType.EChannelPrivate and chatMainData:GetPrivateSelectId() or 0
  request.targetCharId = targetId
  local sendReplay = worldProxy.ShareObjectInChat(request, cancelToken)
  if sendReplay.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(sendReplay.errCode)
    return false
  end
end

function ret.AsyncSendPersonalZone(channelId, cancelToken)
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = 5
  local itemShareData = chatMainData:GetShareData()
  if itemShareData.string1 then
    request.beforeDesc = itemShareData.string1
  end
  if itemShareData.string2 then
    request.afterDesc = itemShareData.string2
  end
  local sendReplay = worldProxy.ShareObjectInChat(request, cancelToken)
  if sendReplay.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(sendReplay.errCode)
    return false
  end
end

function ret.AsyncSendShare(channelId, type, cancelToken)
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = type
  local sendReplay = worldProxy.ShareObjectInChat(request, cancelToken)
  if sendReplay.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(sendReplay.errCode)
    return false
  end
end

function ret.AsyncSetPrivateChatHasRead(targetId, maxReadMsgId, cancelToken)
  local request = {}
  request.targetId = targetId
  request.maxReadMsgId = maxReadMsgId
  local readReply = chitChatProxy.SetPrivateChatHasRead(request, cancelToken)
  if readReply.errCode ~= 0 then
    Z.TipsVM.ShowTips(readReply.errCode)
  end
  return readReply.errCode
end

function ret.AsyncSetPrivateChatTop(targetId, isTop, cancelToken)
  local request = {}
  request.targetId = targetId
  request.setTop = isTop
  local setTopReply = chitChatProxy.PrivateChatTargetTop(request, cancelToken)
  if setTopReply.errCode == 0 then
    chatMainData:SetPrivateChatTopByCharId(setTopReply.targetId, setTopReply.setTop)
    return true
  else
    Z.TipsVM.ShowTips(setTopReply.errCode)
    return false
  end
end

function ret.AsyncSetBlack(targetId, isBlack, cancelSource)
  local request = {}
  request.targetId = targetId
  request.setBlock = isBlack
  local setBlackReply = chitChatProxy.PrivateChatTargetBlock(request, cancelSource:CreateToken())
  if setBlackReply.errCode == 0 then
    if isBlack then
      chatMainData:AddBlack(targetId)
      chatMainData:DelPrivateChatByCharId(targetId)
      if friendMainData:GetChatSelectCharId() == targetId then
        friendMainData:SetChatSelectCharId(0)
        friendMainData:ClearChatRightSubViewList()
      end
      friendMainData:RemoveDataByCharId(targetId, true)
      local friendVM = Z.VMMgr.GetVM("friends_main")
      friendVM.AsyncRefreshBlacks(chatMainData:GetBlackList())
    else
      chatMainData:RemoveBlack(targetId)
      friendMainData:RemoveDataByCharId(targetId)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendRefresh)
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendSuggestionRefresh)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
    return true
  else
    Z.TipsVM.ShowTips(setBlackReply.errCode)
    return false
  end
end

function ret.OpenMiniChat(channelId)
  chatMainData:AddMiniChat(channelId)
  chatMainData:UpdateMiniChatType(channelId, E.MiniChatType.EChatView)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.OpenMiniChat, channelId)
end

function ret.getLastChatDataInQueue(channelId, targetId)
  local queue = chatMainData:GetChannelQueueByChannelId(channelId, targetId)
  if not queue then
    if targetId then
      logGreen("getLastChatDataInQueue Private TargetId Error" .. targetId)
    else
      logGreen("getLastChatDataInQueue ChannelId Error" .. channelId)
    end
    return
  end
  local count = table.zcount(queue)
  if 0 < count then
    for i = count, 1, -1 do
      local chatData = queue[i]
      if chatData and Z.ChatMsgHelper.GetMsgType(chatData) ~= E.ChitChatMsgType.EChatMsgClientTips then
        return chatData
      end
    end
  end
end

function ret.SetComprehensiveId(channelId)
  chatMainData:SetComprehensiveId(channelId)
end

function ret.GetEmojiName(configId)
  if not configId or configId == 0 then
    return ""
  end
  local config = Z.TableMgr.GetTable("ChatStickersTableMgr").GetRow(configId, true)
  if config then
    return config.Res
  end
end

function ret.OnVoiceDownLoad(isSuccess, curFilePath)
  if table.zcount(chatMainData.DownVoiceList) > 0 then
    local channelId = chatMainData.DownVoiceList[1].channelId
    if chatMainData.DownVoiceList[1].isComprehensive then
      channelId = E.ChatChannelType.EComprehensive
    end
    local chatMsgData = chatMainData:GetChatMsgDataByMsgId(channelId, chatMainData.DownVoiceList[1].targetId, chatMainData.DownVoiceList[1].msgId)
    Z.ChatMsgHelper.SetVoiceFilePath(chatMsgData, curFilePath)
    ret.VoicePlaybackRecording(curFilePath, function()
      Z.ChatMsgHelper.SetVoiceIsPlay(chatMsgData, true)
    end, function()
      Z.ChatMsgHelper.SetVoiceIsPlay(chatMsgData, false)
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
    end)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
  end
  table.remove(chatMainData.DownVoiceList, 1)
end

function ret.VoicePlaybackRecording(filePath, startFunc, endFunc)
  local isOk = Z.Voice.PlaybackRecording(filePath)
  if isOk then
    if startFunc then
      startFunc()
    end
    chatMainData.VoicePlayEndFuncList[#chatMainData.VoicePlayEndFuncList + 1] = endFunc
  end
end

function ret.GetShowMsg(chatMsgData, tmp, parent)
  local showMsg = Z.ChatMsgHelper.GetMsg(chatMsgData)
  local param = {}
  if Z.ChatMsgHelper.GetMsgType(chatMsgData) == E.ChitChatMsgType.EChatMsgHypertext then
    local chatHyperLink = Z.ChatMsgHelper.GetChatHyperlink(chatMsgData)
    if chatHyperLink and chatHyperLink.Content then
      showMsg = chatHyperLink.Content
      local paramList = Z.ChatMsgHelper.GetNoticeParamList(chatMsgData)
      if paramList then
        local linkData = {}
        if chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionHunt or chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionGrow or chatHyperLink.FuncType == E.ClientPlaceHolderType.GoToWorldBoss or chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionWarDance then
          linkData[1] = {
            isClient = true,
            type = chatHyperLink.FuncType
          }
        end
        local hyperLinkData = {}
        ret.calcNoticeParam(paramList, linkData, param, chatMsgData, chatHyperLink, hyperLinkData)
        if hyperLinkData and next(hyperLinkData) then
          showMsg = hyperLinkData[1]:GetShareContent()
        else
          showMsg = Z.Placeholder.Placeholder(showMsg, param)
        end
        ret.addLinkClick(tmp, parent, linkData)
      end
    end
  end
  return showMsg, param
end

function ret.calcHyperLink(paramList, linkData, param, chatMsgData, chatHyperLink, hyperLinkDataArray)
  local isShowHyperlink = false
  local string1 = ""
  local string2 = ""
  local playerName, protoData, hyperLinkData
  for i = 1, #paramList do
    local placeHolder = paramList[i]
    if placeHolder.type == E.PlaceHolderType.PlaceHolderTypeItem then
      protoData = pb.decode("zproto.PlaceHolderItem", placeHolder.bytesContent)
      if protoData then
        linkData[1] = {
          type = chatHyperLink.FuncType,
          value = protoData
        }
        hyperLinkData = chatMainData:CreateHyperLinkData(E.ChatHyperLinkType.ItemShare)
      end
      isShowHyperlink = true
    elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeFishPersonalTotal then
      protoData = pb.decode("zproto.PlaceHolderFishPersonalTotal", placeHolder.bytesContent)
      if protoData then
        local charId = Z.ChatMsgHelper.GetCharId(chatMsgData)
        playerName = Z.ChatMsgHelper.GetPlayerName(chatMsgData)
        linkData[1] = {
          type = E.PlaceHolderType.PlaceHolderTypeFishPersonalTotal,
          value = protoData,
          charId = charId
        }
        hyperLinkData = chatMainData:CreateHyperLinkData(E.ChatHyperLinkType.FishingArchives)
      end
      isShowHyperlink = true
    elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeFishItem then
      protoData = pb.decode("zproto.PlaceHolderFishItem", placeHolder.bytesContent)
      if protoData then
        playerName = Z.ChatMsgHelper.GetPlayerName(chatMsgData)
        linkData[1] = {
          type = E.PlaceHolderType.PlaceHolderTypeFishItem,
          value = protoData,
          playerName = playerName
        }
        hyperLinkData = chatMainData:CreateHyperLinkData(E.ChatHyperLinkType.FishingIllrate)
      end
      isShowHyperlink = true
    elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeFishRank then
      protoData = pb.decode("zproto.PlaceHolderFishRank", placeHolder.bytesContent)
      if protoData then
        playerName = Z.ChatMsgHelper.GetPlayerName(chatMsgData)
        linkData[1] = {
          type = E.PlaceHolderType.PlaceHolderTypeFishRank,
          value = protoData,
          playerName = playerName
        }
        hyperLinkData = chatMainData:CreateHyperLinkData(E.ChatHyperLinkType.FishingRank)
      end
      isShowHyperlink = true
    elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeString then
      local content = pb.decode("zproto.PlaceHolderStr", placeHolder.bytesContent)
      if not isShowHyperlink then
        string1 = content.text
      else
        string2 = content.text
      end
    elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypePlayer then
      protoData = pb.decode("zproto.PlaceHolderPlayer", placeHolder.bytesContent)
      if protoData then
        playerName = protoData.name
        linkData[1] = {
          type = chatHyperLink.FuncType,
          value = protoData
        }
        hyperLinkData = chatMainData:CreateHyperLinkData(E.ChatHyperLinkType.PersonalZone)
      end
      isShowHyperlink = true
    end
  end
  if hyperLinkData and protoData then
    hyperLinkData:RefreshShareData(string1, protoData, string2, playerName)
    table.insert(hyperLinkDataArray, hyperLinkData)
  end
end

function ret.calcNoticeParam(paramList, linkData, param, chatMsgData, chatHyperLink, hyperLinkData)
  local placeHolderTypeList = {}
  local placeHolderPlayerList = {}
  local placeHolderItemList = {}
  local placeHolderUnion
  local placeHolderBuff = {}
  local placeHolderTimestamp
  if chatHyperLink.Id == E.ChatHyperLinkType.ItemShare or chatHyperLink.Id == E.ChatHyperLinkType.FishingArchives or chatHyperLink.Id == E.ChatHyperLinkType.FishingIllrate or chatHyperLink.Id == E.ChatHyperLinkType.FishingRank or chatHyperLink.Id == E.ChatHyperLinkType.PersonalZone then
    ret.calcHyperLink(paramList, linkData, param, chatMsgData, chatHyperLink, hyperLinkData)
    if chatHyperLink.FuncType == E.ClientPlaceHolderType.PersonalZone or chatHyperLink.FuncType == E.ClientPlaceHolderType.ItemShare then
      linkData[1].isClient = true
    end
  else
    for i = 1, #paramList do
      local placeHolder = paramList[i]
      if placeHolder.type == E.PlaceHolderType.PlaceHolderTypeVal then
        local value = pb.decode("zproto.PlaceHolderVal", placeHolder.bytesContent)
        if value then
          table.insert(placeHolderTypeList, value)
        end
      elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypePlayer then
        local value = pb.decode("zproto.PlaceHolderPlayer", placeHolder.bytesContent)
        if value then
          table.insert(placeHolderPlayerList, value)
        end
      elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeItem then
        local value = pb.decode("zproto.PlaceHolderItem", placeHolder.bytesContent)
        if value then
          table.insert(placeHolderItemList, value)
        end
      elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeUnion then
        placeHolderUnion = pb.decode("zproto.PlaceHolderUnion", placeHolder.bytesContent)
      elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeBuff then
        local value = pb.decode("zproto.PlaceHolderBuff", placeHolder.bytesContent)
        if value then
          table.insert(placeHolderBuff, value)
        end
      elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeTimestamp then
        placeHolderTimestamp = pb.decode("zproto.PlaceHolderTimestamp", placeHolder.bytesContent)
      end
    end
  end
  if 0 < #placeHolderTypeList then
    if #placeHolderTypeList == 1 then
      param.val = placeHolderTypeList[1].value
    else
      param.arrVal = {}
      for i = 1, #placeHolderTypeList do
        param.arrVal[i] = placeHolderTypeList[i].value
      end
    end
  end
  if 0 < #placeHolderPlayerList then
    if #placeHolderPlayerList == 1 then
      linkData[#linkData + 1] = {
        type = E.PlaceHolderType.PlaceHolderTypePlayer,
        value = placeHolderPlayerList[1]
      }
      param.player = {
        name = Z.RichTextHelper.ApplyUnderLineTag(Z.RichTextHelper.ApplyLinkTag(#linkData, placeHolderPlayerList[1].name))
      }
    else
      param.player = {
        names = {}
      }
      for i = 1, #placeHolderPlayerList do
        linkData[#linkData + 1] = {
          type = E.PlaceHolderType.PlaceHolderTypePlayer,
          value = placeHolderPlayerList[i]
        }
        param.player.names[i] = Z.RichTextHelper.ApplyUnderLineTag(Z.RichTextHelper.ApplyLinkTag(#linkData, placeHolderPlayerList[i].name))
      end
    end
  end
  if 0 < #placeHolderItemList then
    local itemVm = Z.VMMgr.GetVM("items")
    if #placeHolderItemList == 1 then
      linkData[#linkData + 1] = {
        type = E.PlaceHolderType.PlaceHolderTypeItem,
        value = placeHolderItemList[1]
      }
      param.item = {
        name = Z.RichTextHelper.ApplyLinkTag(#linkData, itemVm.ApplyItemNameWithQualityTag(placeHolderItemList[1].configId, true))
      }
    else
      param.item = {
        names = {}
      }
      for i = 1, #placeHolderTypeList do
        linkData[#linkData + 1] = {
          type = E.PlaceHolderType.PlaceHolderTypeItem,
          value = placeHolderItemList[i]
        }
        param.item.names[i] = Z.RichTextHelper.ApplyLinkTag(#linkData, itemVm.ApplyItemNameWithQualityTag(placeHolderItemList[1].configId, true))
      end
    end
  end
  if placeHolderUnion then
    local unionBuild = Z.TableMgr.GetTable("UnionBuildingTableMgr").GetRow(placeHolderUnion.build)
    param.union = {}
    param.union.build = unionBuild.BuildingName
    Z.ChatMsgHelper.SetUnionBuild(chatMsgData, unionBuild)
  end
  if 0 < #placeHolderBuff then
    local buffTableMgr = Z.TableMgr.GetTable("BuffTableMgr")
    if #placeHolderBuff == 1 then
      param.buff = {}
      local buffConfig = buffTableMgr.GetRow(placeHolderBuff[1].buffId)
      param.buff.name = buffConfig and buffConfig.Name or ""
    else
      param.buff = {
        names = {}
      }
      for i = 1, #placeHolderTypeList do
        local buffConfig = buffTableMgr.GetRow(placeHolderBuff[i].buffId)
        param.buff.names[i] = buffConfig and buffConfig.Name or ""
      end
    end
  end
  if placeHolderTimestamp then
    local time = Z.TimeTools.FormatTimeToYMDHMS(placeHolderTimestamp.timestamp * 1000)
    param.timestamp = time
  end
end

function ret.addLinkClick(tmp, parent, linkData)
  if tmp then
    tmp:AddListener(function(key)
      local index = tonumber(key)
      local linkValue = linkData[index]
      if linkValue then
        if linkValue.isClient then
          if linkValue.type == E.ClientPlaceHolderType.UnionHunt then
            ret.onClickEnterUnionHunt()
          elseif linkValue.type == E.ClientPlaceHolderType.GoToWorldBoss then
            local gotoFuncVM = Z.VMMgr.GetVM("gotoFunc")
            gotoFuncVM.GoToFunc(800902)
          elseif linkValue.type == E.ClientPlaceHolderType.UnionWarDance then
            Z.CoroUtil.create_coro_xpcall(function()
              local unionWarDanceVM_ = Z.VMMgr.GetVM("union_wardance")
              unionWarDanceVM_:AsyncEnterUnionWardance(chatMainData.CancelSource:CreateToken())
            end)()
          elseif linkValue.type == E.ClientPlaceHolderType.UnionGrow then
            ret.onClickEnterUnionUnlock()
          elseif linkValue.type == E.ClientPlaceHolderType.ItemShare then
            ret.onClickItemShare(parent, linkValue.value)
          elseif linkValue.type == E.ClientPlaceHolderType.PersonalZone then
            ret.onClickOpenPersonalZone(linkValue.value)
          end
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypePlayer then
          ret.asyncClickPlayer(linkValue.value)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeItem then
          ret.onClickItemTips(parent, linkValue.value)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeFishPersonalTotal then
          ret.onClickFishingArchives(parent, linkValue.value, linkValue.charId)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeFishItem then
          ret.onClickFishingIllurate(parent, linkValue.value, linkValue.playerName)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeFishRank then
          ret.onClickFishingRank(parent, linkValue.value, linkValue.playerName)
        end
      end
    end, true)
  end
end

function ret.asyncClickPlayer(data)
  Z.CoroUtil.create_coro_xpcall(function()
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(data.charId, chatMainData.CancelSource:CreateToken())
  end)()
end

function ret.onClickItemTips(parent, data)
  local tipsId = Z.TipsVM.ShowItemTipsView(parent, data.configId)
  table.insert(chatMainData.ChatLinkTips, tipsId)
end

function ret.onClickItemShare(parent, data)
  local itemTipsViewData = {
    parentTrans = parent,
    configId = data.configId,
    itemUuid = data.ItemDetail.uuid,
    showType = E.EItemTipsShowType.Default,
    posType = E.EItemTipsPopType.Bounds,
    itemInfo = data.ItemDetail,
    isResident = false,
    isShowBg = true,
    closeTipsOnOpenMode = true
  }
  local tipsId = Z.TipsVM.OpenItemTipsView(itemTipsViewData)
  table.insert(chatMainData.ChatLinkTips, tipsId)
end

function ret.onClickEnterUnionHunt()
  local unionVM = Z.VMMgr.GetVM("union")
  if not unionVM:CheckUnionHuntUnlock() then
    Z.TipsVM.ShowTips(5200)
    return
  end
  unionVM:EnterUnionSceneHunt()
end

function ret.onClickEnterUnionUnlock()
  local unionVM_ = Z.VMMgr.GetVM("union")
  unionVM_:OpenUnionUnlockSceneView()
end

function ret.onClickOpenPersonalZone(data)
  local vm = Z.VMMgr.GetVM("personal_zone")
  vm.OpenPersonalZoneMainByCharId(data.charId, chatMainData.CancelSource:CreateToken())
end

function ret.onClickFishingArchives(parent, data, charId)
  local viewData = {}
  viewData.ShowInChat = true
  viewData.CharId = charId
  viewData.DataList = {}
  table.insert(viewData.DataList, {
    Name = Lang("FishingTotal"),
    Value = data.Total
  })
  table.insert(viewData.DataList, {
    Name = Lang("FishingMythFishTotal"),
    Value = data.MythTotal
  })
  table.insert(viewData.DataList, {
    Name = Lang("FishingFishTotal"),
    Value = data.SumFishType
  })
  table.insert(viewData.DataList, {
    Name = Lang("FishingHalobiosTotal"),
    Value = data.SumSeaLifeType
  })
  local unionName = data.unionName
  if unionName == nil or unionName == "" then
    unionName = Lang("noYet")
  end
  viewData.titleData = {
    Name = data.userName,
    UnionName = unionName
  }
  if data.MostFishId > 0 then
    local fishCfg = Z.TableMgr.GetTable("FishingTableMgr").GetRow(data.MostFishId)
    if fishCfg then
      table.insert(viewData.DataList, {
        Name = Lang("FishingMostFish"),
        Value = fishCfg.Name
      })
    end
  end
  if 0 < data.FavourZero then
    local fishingAreaCfg = Z.TableMgr.GetTable("FishingAreaTableMgr").GetRow(data.FavourZero)
    if fishingAreaCfg then
      table.insert(viewData.DataList, {
        Name = Lang("FishingLovestArea"),
        Value = fishingAreaCfg.AreaName
      })
    end
  end
  Z.UIMgr:OpenView("fishing_archives_window", viewData)
end

function ret.onClickFishingIllurate(parent, data, playerName)
  local viewData = {}
  viewData.FishId = data.FishId
  viewData.Size = data.Size / 100
  viewData.OwnerName = playerName
  viewData.parent = parent
  Z.UIMgr:OpenView("fishing_share_illustrate_window", viewData)
end

function ret.onClickFishingRank(parent, data, playerName)
  local viewData = {}
  viewData.FishId = data.FishId
  viewData.OwnerName = playerName
  viewData.parent = parent
  viewData.Rank = data.Rank
  viewData.Size = data.Size / 100
  Z.UIMgr:OpenView("fishing_share_ranking_window", viewData)
end

function ret.addTipsByConfigId(configId, isClearChannelQueue)
  local chatHyperLink = Z.TableMgr.GetTable("ChatHyperlinkMgr").GetRow(configId)
  if not chatHyperLink then
    return
  end
  for k, v in ipairs(chatHyperLink.ChannelId) do
    local channel = v
    if channel ~= E.ChatChannelType.EChannelTopNotice then
      if isClearChannelQueue and channel then
        chatMainData:ClearChannelQueueByChannelId(channel)
      end
      local chatData = {
        ChannelId = channel,
        NoticeConfigId = configId,
        MsgType = E.ChitChatMsgType.EChatMsgHypertext,
        NoticeParamList = {}
      }
      ret.saveChatData(channel, chatData, false)
    else
      Z.TipsVM.OpenGameBroadcast(chatHyperLink.Content)
    end
  end
end

function ret.GetUnionIsUnlock()
  local channelTableRow = Z.TableMgr.GetTable("ChannelTableMgr").GetRow(E.ChatChannelType.EChannelUnion)
  if not channelTableRow then
    return false
  end
  local switchVm = Z.VMMgr.GetVM("switch")
  local isOpen = true
  if switchVm.CheckFuncSwitch(channelTableRow.FunctionId) then
    if channelTableRow.SubFunctionId and channelTableRow.SubFunctionId and #channelTableRow.SubFunctionId > 0 then
      for i = 1, #channelTableRow.SubFunctionId do
        if not switchVm.CheckFuncSwitch(channelTableRow.SubFunctionId[i]) then
          isOpen = false
        end
      end
    end
  else
    isOpen = false
  end
  return isOpen
end

function ret.CheckChatChannelUnionTips()
  chatMainData:ClearChannelChatByConfigId(E.ChatChannelType.EChannelUnion, 5010006)
  chatMainData:ClearChannelChatByConfigId(E.ChatChannelType.EChannelUnion, 5010007)
  if ret.GetUnionIsUnlock() then
    local unionVM = Z.VMMgr.GetVM("union")
    if unionVM:GetPlayerUnionId() == 0 then
      ret.addTipsByConfigId(5010006, true)
    end
  else
    ret.addTipsByConfigId(5010007, true)
  end
end

local getPrivateChatOfflineTime = function(privateChatItem)
  local offlineTime = 0
  if privateChatItem.socialData and privateChatItem.socialData.basicData then
    offlineTime = privateChatItem.socialData.basicData.offlineTime or 0
  end
  return offlineTime
end
local getPrivateChatUnreadCount = function(privateChatItem)
  if privateChatItem.maxReadMsgId and privateChatItem.latestMsg and privateChatItem.maxReadMsgId < privateChatItem.latestMsg.msgId then
    return privateChatItem.latestMsg.msgId - privateChatItem.maxReadMsgId
  else
    return 0
  end
end
local getPrivateChatLastMsgTime = function(privateChatItem)
  if privateChatItem.latestMsg then
    return privateChatItem.latestMsg.timestamp
  else
    return 0
  end
end
local privateChatSortFunc = function(left, right)
  local leftSortValue = 0
  local rightSortValue = 0
  local leftOfflineTime = getPrivateChatOfflineTime(left)
  local rightOfflineTime = getPrivateChatOfflineTime(right)
  local leftUnReadCount = getPrivateChatUnreadCount(left)
  local rightUnReadCount = getPrivateChatUnreadCount(right)
  if left.isTop then
    leftSortValue = leftSortValue + 1000
  end
  if right.isTop then
    rightSortValue = rightSortValue + 1000
  end
  if leftOfflineTime == 0 then
    leftSortValue = leftSortValue + 100
  end
  if rightOfflineTime == 0 then
    rightSortValue = rightSortValue + 100
  end
  if 0 < leftUnReadCount then
    leftSortValue = leftSortValue + 10
  end
  if 0 < rightUnReadCount then
    rightSortValue = rightSortValue + 10
  end
  if leftSortValue == rightSortValue then
    local leftMsgTime = getPrivateChatLastMsgTime(left)
    local rightMsgTime = getPrivateChatLastMsgTime(right)
    if leftMsgTime == 0 and rightMsgTime == 0 then
      if leftOfflineTime == 0 and rightOfflineTime == 0 then
        return left.charId < right.charId
      else
        return leftOfflineTime > rightOfflineTime
      end
    else
      return leftMsgTime > rightMsgTime
    end
  else
    return leftSortValue > rightSortValue
  end
end

function ret.PrivateChatListSort(list)
  table.sort(list, privateChatSortFunc)
end

return ret
