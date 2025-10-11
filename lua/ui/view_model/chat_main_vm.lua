local ret = {}
local chatMainData = Z.DataMgr.Get("chat_main_data")
local settingData = Z.DataMgr.Get("chat_setting_data")
local friendMainData = Z.DataMgr.Get("friend_main_data")
local chitChatProxy = require("zproxy.chit_chat_proxy")
local worldProxy = require("zproxy.world_proxy")
local pb = require("pb2")
local recordCount = 30
local mainChannelQueueCount = 200
local oneDayTime = 86400
local EntChar = Z.PbEnum("EEntityType", "EntChar")
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
  PlaceHolderTypeFishRank = 10,
  PlaceHolderTypeUnionGroup = 11,
  PlaceHolderTypeMasterMode = 12,
  PlaceHolderTypeScenePosition = 13
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
  PersonalZone = 9,
  UnionGroup = 11
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
    ret.asyncInitBlackList()
    ret.asyncInitPrivateChatList()
    ret.asyncInitWorldChatChannelId()
    ret.asyncInitRecord()
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
        if not chatMainData:IsInBlack(privateReply.targetList[i].charId) then
          chatMainData:AddPrivateChatListAddByTargetInfo(privateReply.targetList[i])
        end
      end
      ret.AsyncUpdatePrivateChatCharInfo()
      Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, chatMainData:GetPrivateChatUnReadCount())
    end
  else
    Z.TipsVM.ShowTips(privateReply.errCode)
  end
end

function ret.AsyncUpdatePrivateChatCharInfo(isRefresh, cancelSource)
  local privateChatList = chatMainData:GetPrivateChatList()
  if 0 < #privateChatList then
    for i = 1, #privateChatList do
      if not privateChatList[i].socialData or isRefresh then
        local socialVM = Z.VMMgr.GetVM("social")
        local token
        if cancelSource then
          token = cancelSource:CreateToken()
        else
          token = chatMainData.CancelSource:CreateToken()
        end
        local socialData = socialVM.AsyncGetHeadAndHeadFrameInfoAndSDKPrivilege(privateChatList[i].charId, token)
        privateChatList[i].socialData = socialData
      end
    end
  end
end

function ret.AsyncUpdatePrivateChatLastMsg(charId, receiveMsg, token)
  local privateChatList = chatMainData:GetPrivateChatList()
  if 0 < #privateChatList then
    for i = 1, #privateChatList do
      if privateChatList[i].charId == charId then
        local chatQueue = chatMainData:GetChannelQueueByChannelId(E.ChatChannelType.EChannelPrivate, charId, false)
        if 0 < #chatQueue then
          privateChatList[i].latestMsg = chatQueue[#chatQueue].ChitChatMsg
          local maxReadMsgId = 0
          if receiveMsg then
            if 1 < #chatQueue then
              maxReadMsgId = chatQueue[#chatQueue - 1].ChitChatMsg.msgId
              privateChatList[i].maxReadMsgId = maxReadMsgId
            end
          else
            maxReadMsgId = chatQueue[#chatQueue].ChitChatMsg.msgId
          end
          ret.AsyncSetPrivateChatHasRead(charId, maxReadMsgId, token)
        end
      end
    end
  end
  Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, chatMainData:GetPrivateChatUnReadCount())
end

function ret.AsyncUpdatePrivateChatList(data)
  if not chatMainData:IsInBlack(data.addTargetInfo.charId) then
    chatMainData:AddPrivateChatListAddByTargetInfo(data.addTargetInfo, true)
    ret.AsyncUpdatePrivateChatCharInfo()
  end
  chatMainData:DelPrivateChatByCharId(data.delTargetId)
end

function ret.asyncInitWorldChatChannelId()
  local worldReply = chitChatProxy.GetWorldChatChannelId({}, chatMainData.CancelSource:CreateToken())
  if worldReply.errCode == 0 then
    chatMainData:SetWorldGroupId(worldReply.channelId, worldReply.state)
  else
    Z.TipsVM.ShowTips(worldReply.errCode)
  end
end

function ret.AsyncChannelGroupSwitch(groupId, cancelToken)
  local setWorldChannelReply = chitChatProxy.SetWorldChatChannelId({channelId = groupId}, cancelToken)
  if setWorldChannelReply.errCode == 0 then
    chatMainData:SetWorldGroupId(groupId, setWorldChannelReply.state)
    chatMainData:ClearClientChannelData(E.ChatChannelType.EComprehensive, E.ChatChannelType.EChannelWorld)
    ret.asyncUpdateWorldChannelRecord()
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.RefreshFromEnd, E.ChatChannelType.EChannelWorld)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.RefreshChatViewEmptyState)
  else
    Z.TipsVM.ShowTips(setWorldChannelReply.errCode)
  end
end

function ret.ClearChannelQueueByChannelId(chatChannelType)
  chatMainData:ClearClientChannelData(E.ChatChannelType.EComprehensive, chatChannelType)
  chatMainData:ClearChannelQueueByChannelId(chatChannelType)
  if settingData:GetSynthesis(chatChannelType) then
    chatMainData:ClearComprehensiveChannelChatTipsAndChannelMsg()
    ret.checkChatQueueTimeTips(E.ChatChannelType.EComprehensive)
  end
  chatMainData:SetChatDataFlg(E.ChatChannelType.EComprehensive, E.ChatWindow.Main, true, true)
end

function ret.asyncInitRecord()
  chatMainData:ClearChatMsgQueue(true)
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
  chatMainData:AddPrivateChatListAddByTargetInfo({charId = charId}, true)
end

function ret.AsyncDeletePrivateChat(charId, cancelToken)
  if not ret.checkCharIdVaild(charId) then
    return
  end
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

function ret.CheckPrivateChatCharId(charId, receiveMsg)
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
  local isInBlack = chatMainData:IsInBlack(charId)
  if isInBlack then
    return
  end
  local chatList = chatMainData:GetPrivateChatList()
  if countMax <= #chatList then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.DeletePrivateChat, chatList[#chatList - 1].charId)
  end
  if not chatMainData:IsHavePrivateChat(charId) then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.CreatePrivateChat, charId, receiveMsg)
  end
end

function ret.GetSearchDataList(searchContext)
  local list = {}
  local privateChatList = chatMainData:GetPrivateChatList()
  if privateChatList == nil or #privateChatList == 0 then
    return list
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
  if not channelID or channelID == E.ChatChannelType.EComprehensive then
    return
  end
  local queue = chatMainData:GetChannelQueueByChannelId(channelID, charId, true)
  if queue then
    local lastMsgId = chatMainData:GetChatMsgQueueMaxMsgId(channelID, charId)
    if not lastMsgId or lastMsgId == 0 then
      if 0 < #queue then
        lastMsgId = ret.getRecordStartIndex(queue)
      else
        lastMsgId = 0
      end
    end
    if 0 <= lastMsgId then
      if channelID == E.ChatChannelType.EChannelPrivate then
        charId = charId or chatMainData:GetPrivateSelectId()
        ret.AsyncGetPrivateChatRecord(charId, lastMsgId)
      else
        ret.asyncGetChannelChatRecord(channelID, lastMsgId)
      end
    end
  end
end

function ret.AsyncGetComprehensiveRecord()
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
  if not ret.checkCanSaveChannelMsg(chatMsgData) then
    return
  end
  chatMainData:SaveChatMsgDataToChannelQueue(channelId, chatMsgData, targetId, isRecord, maxCount, autoSort)
  chatMainData:SetChatDataFlg(channelId, E.ChatWindow.Main, true, isRecord, targetId)
  chatMainData:SetChatDataFlg(channelId, E.ChatWindow.Mini, true, isRecord, targetId)
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
      if ret.checkCanSaveChannelMsg(chatMsgData) then
        local saveToSystemChannel = ret.checkMessageLinkTipsAndSave(chatMsgData, isRecord)
        if channelId ~= E.ChatChannelType.ESystem or not saveToSystemChannel then
          ret.saveChatData(channelId, chatMsgData, isRecord, targetId)
        end
        ret.checkComprehensive(channelId, chatMsgData, isRecord, autoSort)
        if not isRecord then
          ret.addBullet(chatMsgData)
        end
      end
    end
  end
  if isRecord then
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.GetRecord, channelId)
  end
end

function ret.updateChannelMsgId(channelId, msgList, targetId)
  if not msgList or table.zcount(msgList) == 0 then
    return
  end
  chatMainData:SetChatMsgQueueMaxMsgId(channelId, msgList[#msgList].msgId, targetId)
end

function ret.checkCanSaveChannelMsg(chatMsgData)
  local sendCharId = Z.ChatMsgHelper.GetCharId(chatMsgData)
  if sendCharId == 0 then
    return true
  end
  return not chatMainData:IsInBlack(sendCharId)
end

function ret.checkMessageLinkTipsAndSave(chatMsgData, isRecord)
  if isRecord then
    return false
  end
  local chatHyperLink = Z.ChatMsgHelper.GetChatHyperlink(chatMsgData)
  if not chatHyperLink then
    return false
  end
  if chatHyperLink.MessageTableId and chatHyperLink.MessageTableId > 0 then
    local message = ret.GetShowMsg(chatMsgData)
    Z.TipsVM.OpenMessageViewByContextAndConfig(message, chatHyperLink.MessageTableId)
  end
  if chatHyperLink.IsShowInsystem then
    ret.saveChatData(E.ChatChannelType.ESystem, chatMsgData, false)
    return true
  end
  return false
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

function ret.saveComprehensiveMsg(chatMsgData, isRecord)
  if chatMsgData.IsComprehensive then
    ret.saveChatData(E.ChatChannelType.EComprehensive, chatMsgData, isRecord)
  end
end

function ret.SetReceiveSystemMsg(info)
  local chatMsgData = {
    ChannelId = E.ChatChannelType.ESystem,
    SystemType = info.Type,
    SystemId = info.Id,
    SystemContent = info.Content,
    HeadStr = info.HeadStr,
    MsgText = info.Content
  }
  ret.saveChatData(E.ChatChannelType.ESystem, chatMsgData, false)
  if settingData:GetSynthesis(E.ChatChannelType.ESystem) then
    ret.saveChatData(E.ChatChannelType.EComprehensive, chatMsgData, false)
  end
  ret.addBullet(chatMsgData)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.BubbleMsg, chatMsgData)
end

function ret.asyncUpdateWorldChannelRecord()
  chatMainData:ClearChannelQueueByChannelId(E.ChatChannelType.EChannelWorld)
  ret.asyncGetChannelChatRecord(E.ChatChannelType.EChannelWorld, 0, true)
end

function ret.AsyncGetPrivateChatRecord(targetId, startIndex, ignoreSetMaxRed)
  local recordReply = ret.asyncGetChannelRecord(E.ChatChannelType.EChannelPrivate, startIndex, recordCount, targetId)
  if recordReply.errCode == 0 then
    chatMainData:UpdatePrivateChatByCharId(targetId, nil, recordReply.maxReadMsgId, recordReply.isEnd, ignoreSetMaxRed)
    ret.saveChannelMsg(E.ChatChannelType.EChannelPrivate, recordReply.multiMsgList, true, targetId)
    ret.updateChannelMsgId(E.ChatChannelType.EChannelPrivate, recordReply.multiMsgList, targetId)
    ret.checkChatQueueTimeTips(E.ChatChannelType.EChannelPrivate, targetId)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
  elseif recordReply.errCode ~= Z.PbEnum("EErrorCode", "ErrChatRecordListIsEmpty") then
    Z.TipsVM.ShowTips(recordReply.errCode)
  end
end

function ret.asyncGetChannelChatRecord(channelId, lastMsgId, autoSort)
  if ret.checkChannelIdOnGetChannelRecord(channelId) and E.ChatChannelType.EChannelPrivate ~= channelId then
    local recordReply = ret.asyncGetChannelRecord(channelId, lastMsgId, recordCount)
    if recordReply.errCode == 0 then
      ret.saveChannelMsg(channelId, recordReply.multiMsgList, true, nil, autoSort)
      ret.updateChannelMsgId(channelId, recordReply.multiMsgList)
      if channelId == E.ChatChannelType.ESystem then
        return
      end
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
    ret.CheckPrivateChatCharId(targetId, true)
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
    ret.checkHudMessage({
      ChannelId = vRequest.channelType,
      ChitChatMsg = vRequest.chatMsg
    })
    ret.checkFriendMsgData(vRequest.channelType, vRequest.chatMsg)
  end
  if vRequest.chatMsg.msgInfo and vRequest.chatMsg.msgInfo.chatHypertext and (vRequest.chatMsg.msgInfo.chatHypertext.configId == 5010001 or vRequest.chatMsg.msgInfo.chatHypertext.configId == 5010002) then
    local unionVm = Z.VMMgr.GetVM("union")
    unionVm:NotifyUnionActivity(vRequest.chatMsg.msgInfo.chatHypertext.configId)
  end
end

function ret.checkHudMessage(chatMsgData)
  local channelTableRow = Z.TableMgr.GetTable("ChannelTableMgr").GetRow(chatMsgData.ChannelId, true)
  if not channelTableRow then
    return
  end
  if channelTableRow.IsShowHUD <= 0 then
    return
  end
  local msgType = Z.ChatMsgHelper.GetMsgType(chatMsgData)
  if msgType == E.ChitChatMsgType.EChatMsgPictureEmoji then
    ret.checkEmojiHudMessage(chatMsgData)
  elseif msgType == E.ChitChatMsgType.EChatMsgTextMessage then
    local content = ret.GetShowMsg(chatMsgData, nil, nil, false, true)
    Z.LuaBridge.SetHudCharTalk(ret.getCharUuid(chatMsgData), content)
  elseif msgType == E.ChitChatMsgType.EChatMsgHypertext then
    local content = ret.GetShowMsg(chatMsgData, nil, nil, false, true)
    Z.LuaBridge.SetHudCharTalk(ret.getCharUuid(chatMsgData), content)
  end
end

function ret.checkEmojiHudMessage(chatMsgData)
  local row = Z.ChatMsgHelper.GetEmojiRow(chatMsgData)
  if not row then
    return
  end
  if row.Type == E.EChatStickersType.EQuickMessage then
    Z.LuaBridge.SetHudCharTalk(ret.getCharUuid(chatMsgData), row.Text)
  elseif row.Type == E.EChatStickersType.EHeadPicture then
    Z.LuaBridge.SetHudCharEmotion(ret.getCharUuid(chatMsgData), row.Id)
  end
end

function ret.checkFriendMsgData(channelId, chatMsg)
  if channelId ~= E.ChatChannelType.EChannelPrivate then
    return
  end
  local sendCharId = 0
  if chatMsg.sendCharInfo then
    sendCharId = chatMsg.sendCharInfo.charID
  end
  if sendCharId == Z.ContainerMgr.CharSerialize.charBase.charId then
    local targetId = 0
    if chatMsg.msgInfo then
      targetId = chatMsg.msgInfo.targetId
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.ChatSelfSendNewMessage, targetId)
  else
    if chatMainData:GetPrivateChatItemByCharId(sendCharId) then
      Z.EventMgr:Dispatch(Z.ConstValue.Friend.ChatPrivateNewMessage, sendCharId)
    end
    local mainUIData = Z.DataMgr.Get("mainui_data")
    mainUIData.MainUIPCShowFriendMessage = true
    if friendMainData:IsFriendByCharId(sendCharId) then
      Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendNewMessage)
    end
  end
  Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, chatMainData:GetPrivateChatUnReadCount())
end

function ret.CheckMainUIFriendNewMessage()
  local isShowFriendNewMessage = false
  local privateChatList = chatMainData:GetPrivateChatList()
  for i = 1, #privateChatList do
    if friendMainData:IsFriendByCharId(privateChatList[i].charId) and privateChatList[i].maxReadMsgId and privateChatList[i].latestMsg and privateChatList[i].latestMsg.msgId and privateChatList[i].latestMsg.msgId > privateChatList[i].maxReadMsgId then
      isShowFriendNewMessage = true
      break
    end
  end
  local mainUIData = Z.DataMgr.Get("mainui_data")
  mainUIData.MainUIPCShowFriendMessage = isShowFriendNewMessage
  Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendNewMessage)
end

function ret.getCharUuid(chatMsgData)
  local entityVM = Z.VMMgr.GetVM("entity")
  local sendCharId = Z.ChatMsgHelper.GetCharId(chatMsgData)
  local uuid = entityVM.EntIdToUuid(sendCharId, EntChar)
  return uuid
end

function ret.checkCanSendMessage(channelId)
  if channelId == E.ChatChannelType.EChannelTeam then
    if Z.VMMgr.GetVM("team").CheckIsInTeam() == false then
      Z.TipsVM.ShowTipsLang(1000100)
      return false
    end
  elseif channelId == E.ChatChannelType.EChannelNull or channelId == E.ChatChannelType.EChannelGroup or channelId == E.ChatChannelType.EChannelTopNotice or channelId == E.ChatChannelType.ESystem then
    return false
  end
  return true
end

function ret.AsyncSendMessage(channelId, targetId, msgText, msgType, configId, cancelToken, voiceFileId, voiceTime, voiceText)
  if ret.CheckChannelLevelLimit(channelId) then
    return false
  end
  local cd = chatMainData:GetChatCD(channelId)
  if cd and 0 < cd then
    return false
  end
  if ret.checkCanSendMessage(channelId) == false then
    return false
  end
  if msgType == E.ChitChatMsgType.EChatMsgTextMessage and (msgText == "" or msgText == nil) then
    return false
  end
  if channelId == E.ChatChannelType.EChannelPrivate and (not targetId or targetId == 0) then
    targetId = chatMainData:GetPrivateSelectId()
  end
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  local msgInfo = {}
  msgInfo.msgType = msgType
  msgInfo.targetId = targetId
  msgInfo.msgText = Z.RichTextHelper.RemoveTagsOtherThanEmojis(msgText)
  if configId then
    local pictureEmoji = {}
    pictureEmoji.configId = configId
    msgInfo.pictureEmoji = pictureEmoji
  end
  if voiceFileId then
    local voice = {}
    voice.fileId = voiceFileId
    voice.seconds = voiceTime
    msgInfo.voice = voice
    if voiceText and string.zlenNormalize(voiceText) > Z.Global.ChatVoiceMsgMaxLength then
      voice.text = string.sub(voiceText, 1, Z.Global.ChatVoiceMsgMaxLength)
    else
      voice.text = voiceText
    end
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
    return true
  else
    if sendReplay.errCode == Z.PbEnum("EErrorCode", "ErrTextCheckIllegal") then
      local accountData = Z.DataMgr.Get("account_data")
      if accountData.PlatformType == E.LoginPlatformType.APJPlatform then
        Z.TipsVM.ShowTips(sendReplay.errCode)
        return false
      elseif sendReplay.showMsg then
        ret.saveChannelMsg(channelId, {
          sendReplay.showMsg
        }, false, targetId)
        return true
      else
        Z.TipsVM.ShowTips(sendReplay.errCode)
        return false
      end
    else
      Z.TipsVM.ShowTips(sendReplay.errCode)
    end
    return false
  end
end

function ret.AsyncSendItemShare(channelId, targetId, cancelToken)
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
  local sendTargetId = targetId
  sendTargetId = sendTargetId or channelId == E.ChatChannelType.EChannelPrivate and chatMainData:GetPrivateSelectId() or 0
  request.targetCharId = sendTargetId
  local errCode = worldProxy.ShareObjectInChat(request, cancelToken)
  if errCode == 0 then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
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
  local errCode = worldProxy.ShareObjectInChat(request, cancelToken)
  if errCode == 0 then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
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
  local errCode = worldProxy.ShareObjectInChat(request, cancelToken)
  if errCode == 0 then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
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
  local errCode = worldProxy.ShareObjectInChat(request, cancelToken)
  if errCode == 0 then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
    return false
  end
end

function ret.AsyncSendMasterDungeonScoreShare(channelId, cancelToken)
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = Z.PbEnum("ShareObjectType", "ShareObjectTypeMasterMode")
  local itemShareData = chatMainData:GetShareData()
  if itemShareData.string1 then
    request.beforeDesc = itemShareData.string1
  end
  if itemShareData.string2 then
    request.afterDesc = itemShareData.string2
  end
  local targetId = channelId == E.ChatChannelType.EChannelPrivate and chatMainData:GetPrivateSelectId() or 0
  request.targetCharId = targetId
  local errCode = worldProxy.ShareObjectInChat(request, cancelToken)
  if errCode == 0 then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
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
  local errCode = worldProxy.ShareObjectInChat(request, cancelToken)
  if errCode == 0 then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
    return false
  end
end

function ret.AsyncSendShare(channelId, type, cancelToken)
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = type
  local errCode = worldProxy.ShareObjectInChat(request, cancelToken)
  if errCode == 0 then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
    return false
  end
end

function ret.AsyncLocalPosition(channelId, cancelToken)
  channelId = channelId == E.ChatChannelType.EComprehensive and chatMainData:GetComprehensiveId() or channelId
  local request = {}
  request.channelType = channelId
  request.objectType = Z.PbEnum("ShareObjectType", "ShareObjectTypePosition")
  local itemShareData = chatMainData:GetShareData()
  if itemShareData.string1 then
    request.beforeDesc = itemShareData.string1
  end
  if itemShareData.string2 then
    request.afterDesc = itemShareData.string2
  end
  local targetId = channelId == E.ChatChannelType.EChannelPrivate and chatMainData:GetPrivateSelectId() or 0
  request.targetCharId = targetId
  request.paramList = chatMainData:GetShareParamList()
  local errCode = worldProxy.ShareObjectInChat(request, cancelToken)
  if errCode == 0 then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ChatChannel, channelId)
    return true
  else
    Z.TipsVM.ShowTips(errCode)
    return false
  end
end

function ret.AsyncSetPrivateChatHasRead(targetId, maxReadMsgId, cancelToken)
  local request = {}
  request.targetId = targetId
  request.maxReadMsgId = maxReadMsgId
  local readReply = chitChatProxy.SetPrivateChatHasRead(request, cancelToken)
  if readReply.errCode == 0 then
    local chatMainData = Z.DataMgr.Get("chat_main_data")
    chatMainData:SetPrivateChatMsgIdByCharId(targetId, maxReadMsgId)
    return true
  else
    return false
  end
end

function ret.AsyncSetPrivateChatTop(targetId, isTop, cancelToken)
  if not ret.checkCharIdVaild(targetId) then
    return false
  end
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
  if not ret.checkCharIdVaild(targetId) then
    return
  end
  local request = {}
  request.targetId = targetId
  request.setBlock = isBlack
  local setBlackReply = chitChatProxy.PrivateChatTargetBlock(request, cancelSource:CreateToken())
  if setBlackReply.errCode == 0 then
    if isBlack then
      chatMainData:AddBlack(targetId)
      if chatMainData:IsHavePrivateChat(targetId) then
        chatMainData:DelPrivateChatByCharId(targetId)
        Z.EventMgr:Dispatch(Z.ConstValue.Chat.DeletePrivateChat, targetId)
      end
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

function ret.OpenMiniChat(channelId, charId, channelName, colorStyle)
  local list = chatMainData:GetMiniChatList()
  if list and Z.Global.ChatFloatingWindowLimit and #list >= Z.Global.ChatFloatingWindowLimit then
    Z.TipsVM.ShowTips(1000106)
    return
  end
  chatMainData:AddMiniChat(channelId, charId, channelName, colorStyle)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.OpenMiniChat)
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
    return string.zconcat(Z.ConstValue.Emoji.EmojiPath, config.Res)
  else
    return ""
  end
end

function ret.getVoiceDataByFileId(fileId)
  for i = 1, #chatMainData.DownVoiceList do
    local voiceData = chatMainData.DownVoiceList[i]
    if voiceData.fileId == fileId then
      return voiceData, i
    end
  end
end

function ret.OnVoiceDownLoad(isSuccess, curFilePath, fileId)
  local voiceData, index = ret.getVoiceDataByFileId(fileId)
  if not isSuccess or not index then
    table.remove(chatMainData.DownVoiceList, index)
    return
  end
  local channelId = voiceData.channelId
  if voiceData.isComprehensive then
    channelId = E.ChatChannelType.EComprehensive
  end
  local chatMsgData = chatMainData:GetChatMsgDataByMsgId(channelId, voiceData.targetId, voiceData.msgId)
  if chatMsgData then
    Z.ChatMsgHelper.SetVoiceFilePath(chatMsgData, curFilePath)
    ret.VoicePlaybackRecording(curFilePath, function()
      Z.ChatMsgHelper.SetVoiceIsPlay(chatMsgData, true)
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
    end, function()
      Z.ChatMsgHelper.SetVoiceIsPlay(chatMsgData, false)
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
    end)
  end
  table.remove(chatMainData.DownVoiceList, index)
end

function ret.VoicePlaybackRecording(filePath, startFunc, endFunc)
  local isOk = Z.Voice.PlaybackRecording(filePath)
  if isOk then
    if startFunc then
      startFunc()
    end
    chatMainData.VoicePlayEndFuncList[#chatMainData.VoicePlayEndFuncList + 1] = endFunc
  elseif endFunc then
    endFunc()
  end
end

function ret.GetShowMsg(chatMsgData, tmp, parent, isMainChatContent, isHudChatContent)
  local showMsg = Z.ChatMsgHelper.GetMsg(chatMsgData)
  local param = {}
  if Z.ChatMsgHelper.GetMsgType(chatMsgData) == E.ChitChatMsgType.EChatMsgHypertext then
    local chatHyperLink = Z.ChatMsgHelper.GetChatHyperlink(chatMsgData)
    if chatHyperLink and chatHyperLink.Content then
      showMsg = chatHyperLink.Content
      local paramList = Z.ChatMsgHelper.GetNoticeParamList(chatMsgData)
      if paramList then
        local linkData = {}
        if chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionHunt or chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionGrow or chatHyperLink.FuncType == E.ClientPlaceHolderType.GoToWorldBoss or chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionWarDance or chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionGroup then
          linkData[1] = {
            isClient = true,
            type = chatHyperLink.FuncType
          }
        end
        local hyperLinkData = {}
        ret.calcNoticeParam(paramList, linkData, param, chatMsgData, chatHyperLink, hyperLinkData)
        if hyperLinkData and next(hyperLinkData) then
          showMsg = hyperLinkData[1]:GetShareContent(isMainChatContent, isHudChatContent)
        elseif isMainChatContent and chatHyperLink.FunctionButtonEscape ~= "" then
          showMsg = Z.Placeholder.Placeholder(chatHyperLink.FunctionButtonEscape, param)
        else
          showMsg = Z.Placeholder.Placeholder(showMsg, param)
        end
        ret.addLinkClick(tmp, parent, linkData, chatMsgData)
      end
    end
  elseif isHudChatContent and type(showMsg) == "string" then
    showMsg = string.gsub(showMsg, "<[^>]->", "")
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
    elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeMasterMode then
      protoData = pb.decode("zproto.PlaceHolderMasterMode", placeHolder.bytesContent)
      if protoData then
        linkData[1] = {
          type = E.PlaceHolderType.PlaceHolderTypeMasterMode,
          value = protoData,
          playerName = protoData.userName
        }
        hyperLinkData = chatMainData:CreateHyperLinkData(E.ChatHyperLinkType.MasterDungeonScore)
      end
      isShowHyperlink = true
    elseif placeHolder.type == E.PlaceHolderType.PlaceHolderTypeScenePosition then
      protoData = pb.decode("zproto.PlaceHolderScenePosition", placeHolder.bytesContent)
      if protoData then
        linkData[1] = {
          type = E.PlaceHolderType.PlaceHolderTypeScenePosition,
          value = protoData
        }
        hyperLinkData = chatMainData:CreateHyperLinkData(E.ChatHyperLinkType.LocalPosition)
      end
      isShowHyperlink = true
    end
  end
  if chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionGroup then
    param.string = Z.ChatMsgHelper.GetMsg(chatMsgData)
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
  if chatHyperLink.Id == E.ChatHyperLinkType.ItemShare or chatHyperLink.Id == E.ChatHyperLinkType.FishingArchives or chatHyperLink.Id == E.ChatHyperLinkType.FishingIllrate or chatHyperLink.Id == E.ChatHyperLinkType.FishingRank or chatHyperLink.Id == E.ChatHyperLinkType.PersonalZone or chatHyperLink.Id == E.ChatHyperLinkType.UnionGroup or chatHyperLink.Id == E.ChatHyperLinkType.MasterDungeonScore or chatHyperLink.Id == E.ChatHyperLinkType.LocalPosition then
    ret.calcHyperLink(paramList, linkData, param, chatMsgData, chatHyperLink, hyperLinkData)
    if chatHyperLink.FuncType == E.ClientPlaceHolderType.PersonalZone or chatHyperLink.FuncType == E.ClientPlaceHolderType.ItemShare or chatHyperLink.FuncType == E.ClientPlaceHolderType.UnionGroup then
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
    local time = Z.TimeFormatTools.TicksFormatTime(placeHolderTimestamp.timestamp * 1000, E.TimeFormatType.YMDHMS)
    param.timestamp = time
  end
end

function ret.addLinkClick(tmp, parent, linkData, chatMsgData)
  if tmp then
    tmp:AddListener(function(key)
      local index = tonumber(key)
      local linkValue = linkData[index]
      if linkValue then
        if linkValue.isClient then
          if linkValue.type == E.ClientPlaceHolderType.UnionHunt then
            ret.onClickEnterUnionHunt()
          elseif linkValue.type == E.ClientPlaceHolderType.GoToWorldBoss then
            local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
            gotoFuncVM.GoToFunc(800902)
          elseif linkValue.type == E.ClientPlaceHolderType.UnionWarDance then
            Z.CoroUtil.create_coro_xpcall(function()
              local unionWarDanceVM_ = Z.VMMgr.GetVM("union_wardance")
              unionWarDanceVM_:AsyncEnterUnionWardance(chatMainData.CancelSource:CreateToken())
            end)()
          elseif linkValue.type == E.ClientPlaceHolderType.UnionGrow then
            ret.onClickEnterUnionUnlock()
          elseif linkValue.type == E.ClientPlaceHolderType.ItemShare then
            ret.onClickItemShare(parent, linkValue.value, chatMsgData)
          elseif linkValue.type == E.ClientPlaceHolderType.PersonalZone then
            ret.onClickOpenPersonalZone(linkValue.value)
          elseif linkValue.type == E.ClientPlaceHolderType.UnionGroup then
            local unionVM = Z.VMMgr.GetVM("union")
            unionVM:MemberJoinGroup()
          end
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypePlayer then
          ret.asyncClickPlayer(linkValue.value)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeItem then
          ret.onClickItemTips(parent, linkValue.value, chatMsgData)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeFishPersonalTotal then
          ret.onClickFishingArchives(parent, linkValue.value, linkValue.charId)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeFishItem then
          ret.onClickFishingIllurate(parent, linkValue.value, linkValue.playerName)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeFishRank then
          ret.onClickFishingRank(parent, linkValue.value, linkValue.playerName)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeMasterMode then
          ret.onClickMasterDungeonScore(parent, linkValue.value, linkValue.playerName)
        elseif linkValue.type == E.PlaceHolderType.PlaceHolderTypeScenePosition then
          ret.onClickPositionShare(linkValue.value)
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

function ret.onClickItemTips(parent, data, chatMsgData)
  if chatMsgData.LinkTipsId then
    Z.TipsVM.CloseItemTipsView(chatMsgData.LinkTipsId)
  end
  chatMsgData.LinkTipsId = Z.TipsVM.ShowItemTipsView(parent, data.configId)
  chatMainData.ChatLinkTipsId = chatMsgData.LinkTipsId
end

function ret.onClickItemShare(parent, data, chatMsgData)
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
  if chatMsgData.LinkTipsId then
    Z.TipsVM.CloseItemTipsView(chatMsgData.LinkTipsId)
  end
  chatMsgData.LinkTipsId = Z.TipsVM.OpenItemTipsView(itemTipsViewData)
  chatMainData.ChatLinkTipsId = chatMsgData.LinkTipsId
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
  viewData.IsNewbie = data.isNewbie
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

function ret.onClickMasterDungeonScore(parent, data, playerName)
  local viewData = {}
  viewData.isPlayer = false
  viewData.score = data
  viewData.parent = parent
  viewData.playerName = playerName
  Z.UIMgr:OpenView("hero_dungeon_master_share_window", viewData)
end

function ret.onClickPositionShare(data)
  local sceneVM = Z.VMMgr.GetVM("scene")
  if not sceneVM.CheckSceneUnlock(data.SceneId, true) then
    return
  end
  local miniMapVM = Z.VMMgr.GetVM("minimap")
  if not miniMapVM.CheckSceneID(data.SceneId, true) then
    Z.TipsVM.ShowTips(102915)
    return
  end
  local quickJumpVM = Z.VMMgr.GetVM("quick_jump")
  quickJumpVM.DoJumpByConfigParam(E.QuickJumpType.TraceScenePosition, {
    data.SceneId,
    E.TrackType.Position,
    E.GoalGuideSource.PositionShare,
    Vector3.New(data.PositionX, data.PositionY, data.PositionZ)
  })
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

function ret.OpenMainChatView()
  if chatMainData:IsBlocked() then
    return
  end
  Z.UIMgr:OpenView("main_chat")
  if not Z.IsPCUI then
    return
  end
  Z.UIMgr:OpenView("main_chat_pc")
end

function ret.CloseMainChatView()
  Z.UIMgr:CloseView("main_chat")
  if not Z.IsPCUI then
    return
  end
  Z.UIMgr:CloseView("main_chat_pc")
end

function ret.OpenChatSettingPopupView(gotoTab)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isSettingOn = gotoFuncVM.CheckFuncCanUse(E.EChatRightChannelBtnFunctionId.ESetting)
  if not isSettingOn then
    return
  end
  local isOn1 = gotoFuncVM.CheckFuncCanUse(E.FunctionID.ChatSettingChannelShow, true)
  local isOn2 = gotoFuncVM.CheckFuncCanUse(E.FunctionID.ChatSettingBarrageShow, true)
  local isOn3 = gotoFuncVM.CheckFuncCanUse(E.FunctionID.ChatSettingFilter, true)
  if not isOn1 and not isOn2 and not isOn3 then
    Z.TipsVM.ShowTipsLang(100102)
    return
  end
  Z.UIMgr:OpenView("chat_setting_popup", {goToTab = gotoTab})
end

function ret.CheckIsChatCD(channelId)
  local cd = chatMainData:GetChatCD(channelId)
  return cd and 0 < cd
end

function ret.CheckChannelLevelLimit(channelId)
  local config = chatMainData:GetConfigData(channelId)
  if not config then
    return false
  end
  local curLevel = Z.ContainerMgr.CharSerialize.roleLevel.level or 0
  if curLevel < config.LevelLimit and 0 < config.LevelLimit then
    Z.TipsVM.ShowTips(5230, {
      val = config.LevelLimit
    })
    return true
  end
  return false
end

function ret.CheckChatNum(text)
  local charNum = string.zlenNormalize(text)
  local charMaxLimit = chatMainData:GetCharLimit()
  return charNum <= charMaxLimit
end

function ret.GetChatEmojiUnlock(emojiId)
  local row = Z.TableMgr.GetTable("ChatStickersTableMgr").GetRow(emojiId, true)
  if not row then
    return false
  end
  return ret.GetChatEmojiUnlockByTableRow(row)
end

function ret.GetChatEmojiUnlockByTableRow(row)
  if row.IsDefUnlock == 0 then
    return true
  end
  local emojinUnlockData = Z.ContainerMgr.CharSerialize.unlockEmojiData.unlockMap
  return emojinUnlockData[row.Id]
end

function ret.AsyncUnlockEmoji(emojiId, token)
  local ret = worldProxy.UnlockEmoji(emojiId, token)
  if ret == 0 then
    return true
  else
    Z.TipsVM.ShowTips(ret)
  end
end

function ret.OpenChatMainPCView()
  local mainUIData = Z.DataMgr.Get("mainui_data")
  local socialVM = Z.VMMgr.GetVM("socialcontact_main")
  if mainUIData.MainUIPCShowFriendMessage then
    socialVM.OpenFriendView()
  elseif mainUIData.MainUIPCShowMail then
    socialVM.OpenMailView()
  else
    socialVM.OpenChatView()
  end
end

function ret.AsyncArkShareWithTencent(targetCharId, cancelToken)
  local accountData = Z.DataMgr.Get("account_data")
  local request = {
    targetCharId = targetCharId,
    selefOpenId = accountData.OpenID,
    selefToken = accountData.Token
  }
  local reply = chitChatProxy.ArkShareWithTencent(request, cancelToken)
  if reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return
  end
  Z.TipsVM.ShowTips(170301)
end

function ret.AsyncGetArkJsonWithTencent(cancelToken)
  local accountData = Z.DataMgr.Get("account_data")
  local request = {
    selefOpenId = accountData.OpenID,
    selefToken = accountData.Token
  }
  local reply = chitChatProxy.GetArkJsonWithTencent(request, cancelToken)
  if reply and reply.errCode ~= 0 then
    Z.TipsVM.ShowTips(reply.errCode)
    return nil
  end
  return reply.arkJson
end

function ret.checkCharIdVaild(charId)
  if not charId or charId == 0 then
    Z.TipsVM.ShowTipsLang(130107)
    return false
  end
  return true
end

return ret
