local super = require("ui.model.data_base")
local ChatMainData = class("ChatMainData", super)
E.ChatHyperLinkType = {
  ItemShare = 3000001,
  FishingIllrate = 8009003,
  FishingRank = 8009004,
  FishingArchives = 8009005,
  PersonalZone = 3001001,
  UnionGroup = 1004020,
  MasterDungeonScore = 1050001,
  LocalPosition = 3000002
}

function ChatMainData:ctor()
  super.ctor(self)
  self:resetProp()
end

function ChatMainData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.blockChatMap_ = {}
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function ChatMainData:Clear()
  self.blockChatMap_ = {}
  self:ResetData()
end

function ChatMainData:SetBlockChat(blockType, blockState)
  if blockState then
    self.blockChatMap_[blockType] = true
  else
    self.blockChatMap_[blockType] = nil
  end
end

function ChatMainData:IsBlocked()
  return next(self.blockChatMap_) ~= nil
end

function ChatMainData:OnReconnect()
end

function ChatMainData:UnInit()
  self.CancelSource:Recycle()
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function ChatMainData:onLanguageChange()
  self:initChannelCfg()
  self:clearClientTips()
end

function ChatMainData:resetProp()
  self:ResetData()
  self:initChannelCfg()
  self.channelList_ = {}
  self.channelFunctionIdList_ = {}
  self.comprehensiveConfig_ = {}
  self.charLimit_ = 0
  self.ComprehensiveConfigSettingId_ = 101
  self.chatBubblePressBgOtherScale_ = nil
  self.chatBubblePressBgSelfScale_ = nil
  self.mainChatInputChannel_ = E.ChatChannelType.EChannelWorld
  self.MainViewAutoHideTime = 60
end

function ChatMainData:ResetData()
  self.isInitChatRecord_ = false
  self.comprehensiveId_ = -1
  self.curChannelId_ = nil
  self.sendChannelId_ = nil
  self.curWorldGroupId_ = 1
  self.curWorldChannelState_ = 1
  self.banTime_ = 0
  self.emojiHistoryList_ = {}
  self.msgHistoryList_ = {}
  self.privateSelectId_ = 0
  self.privateChatList_ = {}
  self.blackList_ = {}
  self.miniChatList_ = {}
  self.miniIndex_ = 0
  self.selectMiniChatIndex_ = 0
  self.newPrivateChatMessageTipsCharId_ = 0
  self:ClearChatMsgQueue()
  self:ClearChatDraft()
  self:ClearChatCD()
  self:ClearChatDataFlg()
  self.BulletList = {}
  self.VoiceChannelId = -1
  self.VoiceIsInit = false
  self.DownVoiceList = {}
  self.VoiceFilePathList = {}
  self.VoicePlayEndFuncList = {}
  self.isInitList_ = false
  self.channelList_ = {}
  self.channelFunctionIdList_ = {}
  self.ChatLinkTipsId = nil
  self.hyperLink_ = nil
  self.playerLevelTableData_ = nil
  self.chatVoiceChannelId_ = nil
end

function ChatMainData:ClearChatMsgQueue(ignoreSystemChannel)
  if not self.chatMsgQueue_ then
    self.chatMsgQueue_ = {
      [E.ChatChannelType.EChannelWorld] = {},
      [E.ChatChannelType.EChannelScene] = {},
      [E.ChatChannelType.EChannelTeam] = {},
      [E.ChatChannelType.EChannelUnion] = {},
      [E.ChatChannelType.EChannelPrivate] = {},
      [E.ChatChannelType.EComprehensive] = {},
      [E.ChatChannelType.ESystem] = {}
    }
  else
    self.chatMsgQueue_[E.ChatChannelType.EChannelWorld] = {}
    self.chatMsgQueue_[E.ChatChannelType.EChannelScene] = {}
    self.chatMsgQueue_[E.ChatChannelType.EChannelTeam] = {}
    self.chatMsgQueue_[E.ChatChannelType.EChannelUnion] = {}
    self.chatMsgQueue_[E.ChatChannelType.EChannelPrivate] = {}
    self.chatMsgQueue_[E.ChatChannelType.EComprehensive] = {}
    if not ignoreSystemChannel then
      self.chatMsgQueue_[E.ChatChannelType.ESystem] = {}
    end
  end
  self.chatMsgQueueMaxMsgId_ = {
    [E.ChatChannelType.EChannelWorld] = 0,
    [E.ChatChannelType.EChannelScene] = 0,
    [E.ChatChannelType.EChannelTeam] = 0,
    [E.ChatChannelType.EChannelUnion] = 0,
    [E.ChatChannelType.EChannelPrivate] = {},
    [E.ChatChannelType.ESystem] = 0
  }
end

function ChatMainData:SetChatMsgQueueMaxMsgId(channelId, msgId, targetId)
  if targetId then
    self.chatMsgQueueMaxMsgId_[channelId][targetId] = msgId
  else
    self.chatMsgQueueMaxMsgId_[channelId] = msgId
  end
end

function ChatMainData:GetChatMsgQueueMaxMsgId(channelId, targetId)
  if targetId then
    return self.chatMsgQueueMaxMsgId_[channelId][targetId]
  else
    return self.chatMsgQueueMaxMsgId_[channelId]
  end
end

function ChatMainData:ClearChatDraft()
  self.channelChatDraft_ = {
    [E.ChatWindow.Main] = {},
    [E.ChatWindow.Mini] = {
      [E.ChatChannelType.EChannelWorld] = {},
      [E.ChatChannelType.EChannelScene] = {},
      [E.ChatChannelType.EChannelTeam] = {},
      [E.ChatChannelType.EChannelUnion] = {},
      [E.ChatChannelType.EChannelPrivate] = {}
    }
  }
end

function ChatMainData:ClearChatCD()
  self.chatCD_ = {
    [E.ChatChannelType.EChannelWorld] = 0,
    [E.ChatChannelType.EChannelScene] = 0,
    [E.ChatChannelType.EChannelTeam] = 0,
    [E.ChatChannelType.EChannelUnion] = 0,
    [E.ChatChannelType.EComprehensive] = 0
  }
end

function ChatMainData:ClearChatDataFlg()
  self.chatFlg_ = {
    [E.ChatChannelType.EChannelWorld] = {
      [E.ChatWindow.Main] = {flg = false, isRecord = false},
      [E.ChatWindow.Mini] = {flg = false, isRecord = false}
    },
    [E.ChatChannelType.EChannelScene] = {
      [E.ChatWindow.Main] = {flg = false, isRecord = false},
      [E.ChatWindow.Mini] = {flg = false, isRecord = false}
    },
    [E.ChatChannelType.EChannelTeam] = {
      [E.ChatWindow.Main] = {flg = false, isRecord = false},
      [E.ChatWindow.Mini] = {flg = false, isRecord = false}
    },
    [E.ChatChannelType.EChannelUnion] = {
      [E.ChatWindow.Main] = {flg = false, isRecord = false},
      [E.ChatWindow.Mini] = {flg = false, isRecord = false}
    },
    [E.ChatChannelType.EChannelPrivate] = {},
    [E.ChatChannelType.ESystem] = {
      [E.ChatWindow.Main] = {flg = false, isRecord = false},
      [E.ChatWindow.Mini] = {flg = false, isRecord = false}
    },
    [E.ChatChannelType.EComprehensive] = {
      [E.ChatWindow.Main] = {flg = false, isRecord = false},
      [E.ChatWindow.Mini] = {flg = false, isRecord = false}
    }
  }
end

function ChatMainData:SetChatDataFlg(channelType, windowType, dataFlg, record, charId)
  if channelType == E.ChatChannelType.EChannelPrivate then
    if not self.chatFlg_[channelType][charId] then
      self.chatFlg_[channelType][charId] = {flg = dataFlg, isRecord = record}
    else
      self.chatFlg_[channelType][charId].flg = dataFlg
      self.chatFlg_[channelType][charId].isRecord = record
    end
  elseif not self.chatFlg_[channelType][windowType] then
    self.chatFlg_[channelType][windowType] = {flg = dataFlg, isRecord = record}
  else
    self.chatFlg_[channelType][windowType].flg = dataFlg
    self.chatFlg_[channelType][windowType].isRecord = record
  end
end

function ChatMainData:GetChatDataFlg(channelType, windowType, charId)
  if channelType == E.ChatChannelType.EChannelPrivate then
    return self.chatFlg_[channelType][charId]
  else
    return self.chatFlg_[channelType][windowType]
  end
end

function ChatMainData:ClearChannelQueueByChannelId(channel)
  if self.chatMsgQueue_[channel] then
    self.chatMsgQueue_[channel] = {}
  end
  if channel == E.ChatChannelType.EChannelPrivate then
    self.chatMsgQueueMaxMsgId_[channel] = {}
  else
    self.chatMsgQueueMaxMsgId_[channel] = 0
  end
end

function ChatMainData:ClearClientChannelData(dataChannelId, clearChannelId)
  if not self.chatMsgQueue_[dataChannelId] or not self.chatMsgQueue_[dataChannelId].multiMsgList then
    return
  end
  for i = #self.chatMsgQueue_[dataChannelId].multiMsgList, 1, -1 do
    local msgData = self.chatMsgQueue_[dataChannelId].multiMsgList[i]
    if Z.ChatMsgHelper.GetChannelId(msgData) == clearChannelId then
      table.remove(self.chatMsgQueue_[dataChannelId].multiMsgList, i)
    end
  end
end

function ChatMainData:SetNewPrivateChatMessageTipsCharId(charId)
  self.newPrivateChatMessageTipsCharId_ = charId
end

function ChatMainData:GetNewPrivateChatMessageTipsCharId()
  return self.newPrivateChatMessageTipsCharId_
end

function ChatMainData:ClearNewPrivateChatMessageTipsCharId()
  if self.newPrivateChatMessageTipsCharId_ == 0 then
    return
  end
  local queue = self:GetChannelQueueByChannelId(E.ChatChannelType.EChannelPrivate, self.newPrivateChatMessageTipsCharId_, true)
  if not queue then
    return
  end
  for i = #queue, 1, -1 do
    if queue[i].IsNewMessage then
      table.remove(queue, i)
      break
    end
  end
end

function ChatMainData:SetPrivateSelectId(charId)
  self.privateSelectId_ = charId
end

function ChatMainData:GetPrivateSelectId()
  return self.privateSelectId_
end

function ChatMainData:SetIsInitChatRecord(isInit)
  self.isInitChatRecord_ = isInit
end

function ChatMainData:GetIsInitChatRecord()
  return self.isInitChatRecord_
end

function ChatMainData:IsHavePrivateChat(charId)
  if #self.privateChatList_ > 0 then
    for i = 1, #self.privateChatList_ do
      if self.privateChatList_[i].charId == charId then
        return true
      end
    end
  end
  return false
end

function ChatMainData:AddPrivateChatListAddByTargetInfo(targetInfo, isNew)
  if #self.privateChatList_ > 0 then
    for i = 1, #self.privateChatList_ do
      if self.privateChatList_[i].charId == targetInfo.charId then
        return
      end
    end
  end
  local privateChatItem = {
    charId = targetInfo.charId,
    maxReadMsgId = targetInfo.maxReadMsgId or 0,
    isTop = targetInfo.isTop or false,
    latestMsg = targetInfo.latestMsg,
    loopItemType = E.FriendLoopItemType.EPrivateChat,
    multiMsgList = {}
  }
  if isNew then
    local index = 1
    for i = 1, #self.privateChatList_ do
      if not self.privateChatList_[i].isTop then
        index = 1
        break
      end
    end
    table.insert(self.privateChatList_, index, privateChatItem)
  else
    self.privateChatList_[#self.privateChatList_ + 1] = privateChatItem
  end
end

function ChatMainData:DelPrivateChatByCharId(charId)
  if #self.privateChatList_ == 0 then
    return
  else
    for i = #self.privateChatList_, 1, -1 do
      if self.privateChatList_[i].charId == charId then
        table.remove(self.privateChatList_, i)
        break
      end
    end
  end
end

function ChatMainData:GetPrivateChatUnReadCount(isFriendMessageCount)
  local unReadCount = 0
  local friendMainData = Z.DataMgr.Get("friend_main_data")
  for i = 1, #self.privateChatList_ do
    if self.privateChatList_[i].maxReadMsgId and self.privateChatList_[i].latestMsg and self.privateChatList_[i].latestMsg.msgId and self.privateChatList_[i].latestMsg.msgId > self.privateChatList_[i].maxReadMsgId and (not isFriendMessageCount or isFriendMessageCount and friendMainData:IsFriendByCharId(self.privateChatList_[i].charId)) then
      unReadCount = unReadCount + self.privateChatList_[i].latestMsg.msgId - self.privateChatList_[i].maxReadMsgId
    end
  end
  return unReadCount
end

function ChatMainData:ClearPrivateChatList()
  self.privateChatList_ = {}
end

function ChatMainData:GetPrivateChatList()
  return self.privateChatList_
end

local getMsgTime = function(data)
  if data and data.latestMsg then
    return data.latestMsg.timestamp
  end
  return 0
end
local getFriendlinessValue = function(data)
  local friendMainData = Z.DataMgr.Get("friend_main_data")
  local friendLinessData = friendMainData:GetFriendLinessData(data.charId)
  if friendLinessData then
    return friendLinessData.friendLinessLevel, friendLinessData.friendLinessCurExp
  else
    return 0, 0
  end
end
local sortFunc = function(left, right)
  if left.isTop ~= right.isTop then
    if left.isTop then
      return true
    else
      return false
    end
  end
  local leftMsgTime = getMsgTime(left)
  local rightMsgTime = getMsgTime(right)
  if leftMsgTime == rightMsgTime then
    local leftFriendLinessLevel, leftFriendLinessExp = getFriendlinessValue(left)
    local rightFriendLinessLevel, rightFriendLinessExp = getFriendlinessValue(right)
    if leftFriendLinessLevel == rightFriendLinessLevel then
      if leftFriendLinessExp == rightFriendLinessExp then
        return left.charId < right.charId
      else
        return leftFriendLinessExp > rightFriendLinessExp
      end
    else
      return leftFriendLinessLevel > rightFriendLinessLevel
    end
  else
    return leftMsgTime > rightMsgTime
  end
end

function ChatMainData:SortPrivateChatList()
  table.sort(self.privateChatList_, sortFunc)
end

function ChatMainData:GetPrivateChatItemByCharId(charId)
  if #self.privateChatList_ > 0 then
    for i = 1, #self.privateChatList_ do
      if self.privateChatList_[i].charId == charId then
        return self.privateChatList_[i]
      end
    end
  end
end

function ChatMainData:SetPrivateChatMsgIdByCharId(charId, msgId)
  if #self.privateChatList_ > 0 then
    for i = 1, #self.privateChatList_ do
      if self.privateChatList_[i].charId == charId and msgId > self.privateChatList_[i].maxReadMsgId then
        self.privateChatList_[i].maxReadMsgId = msgId
        break
      end
    end
  end
end

function ChatMainData:GetIsHavePrivateChatItemByCharId(charId)
  if #self.privateChatList_ > 0 then
    for i = 1, #self.privateChatList_ do
      if self.privateChatList_[i].charId == charId then
        return true
      end
    end
  end
  return false
end

function ChatMainData:initChannelCfg()
  local channelTables = Z.TableMgr.GetTable("ChannelTableMgr").GetDatas()
  self.chatTickersConfig_ = Z.TableMgr.GetTable("ChatStickersTableMgr").GetDatas()
  self.channelCfg_ = {}
  for _, value in pairs(channelTables) do
    table.insert(self.channelCfg_, value)
  end
  table.sort(self.channelCfg_, function(left, right)
    return left.Sort < right.Sort
  end)
  self.isInitList_ = false
  self.channelList_ = {}
end

function ChatMainData:clearClientTips()
  if self.chatMsgQueue_ then
    for channelId, chatMsgQueue in pairs(self.chatMsgQueue_) do
      self:clearChatMsgQueueClientTips(channelId, chatMsgQueue.multiMsgList)
    end
  end
  if self.privateChatList_ then
    for i = 1, #self.privateChatList_ do
      self:clearChatMsgQueueClientTips(E.ChatChannelType.EChannelPrivate, self.privateChatList_[i].multiMsgList, self.privateChatList_[i].charId)
    end
  end
end

function ChatMainData:clearChatMsgQueueClientTips(channelId, chatMsgQueue, charId)
  if not chatMsgQueue or #chatMsgQueue == 0 then
    return
  end
  local isClear = false
  for i = #chatMsgQueue, 1, -1 do
    local chatMsgData = chatMsgQueue[i]
    local msgType = Z.ChatMsgHelper.GetMsgType(chatMsgData)
    if msgType == E.ChitChatMsgType.EChatMsgClientTips and chatMsgData.SystemType ~= E.ESystemTipInfoType.ItemInfo then
      table.remove(chatMsgQueue, i)
      isClear = true
    end
  end
  if isClear then
    self:SetChatDataFlg(channelId, E.ChatWindow.Main, true, false, charId)
    self:SetChatDataFlg(channelId, E.ChatWindow.Mini, true, false, charId)
  end
end

function ChatMainData:GetPlayerLevelTableData()
  if not self.playerLevelTableData_ then
    self.playerLevelTableData_ = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetDatas()
  end
  return self.playerLevelTableData_
end

function ChatMainData:GetChannelName(channelId)
  if not self.channelCfg_ then
    return
  end
  for i = 1, #self.channelCfg_ do
    if self.channelCfg_[i].Id == channelId then
      return self.channelCfg_[i].ChannelName
    end
  end
end

function ChatMainData:SetChatVoiceChannelId(channelId)
  self.chatVoiceChannelId_ = channelId
end

function ChatMainData:GetChatVoiceChannelId()
  return self.chatVoiceChannelId_
end

function ChatMainData:SetEmojiHistory(emoji)
  for k, v in pairs(self.emojiHistoryList_) do
    if v == emoji then
      return
    end
  end
  table.insert(self.emojiHistoryList_, 1, emoji)
end

function ChatMainData:GetEmojiHistory()
  return self.emojiHistoryList_
end

function ChatMainData:SetMsgHistory(type, text)
  if type == E.ChitChatMsgType.EChatMsgTextMessage and text then
    if self.msgHistoryList_ == nil then
      self.msgHistoryList_ = {}
    end
    table.insert(self.msgHistoryList_, 1, text)
    local msgCount = table.zcount(self.msgHistoryList_)
    if 20 < msgCount then
      table.remove(self.msgHistoryList_, msgCount)
    end
  end
end

function ChatMainData:GetMsgHistory()
  return self.msgHistoryList_
end

function ChatMainData:SetBanTime(time)
  self.banTime_ = time
end

function ChatMainData:GetBanTime()
  return self.banTime_ - math.modf(Z.ServerTime:GetServerTime() * 0.001)
end

function ChatMainData:GetBanEndTime()
  return self.banTime_
end

function ChatMainData:GetChatCDList()
  return self.chatCD_
end

function ChatMainData:GetChatCD(channelId)
  return self.chatCD_[channelId]
end

function ChatMainData:SetChatCD(channelId, cdTime)
  if self.chatCD_[channelId] then
    self.chatCD_[channelId] = cdTime
  end
end

function ChatMainData:SetScaleStatus(scale)
  self.scale_ = scale
end

function ChatMainData:GetScaleStatus()
  return self.scale_
end

function ChatMainData:SetWorldGroupId(data, state)
  self.curWorldGroupId_ = data
  self.curWorldChannelState_ = state
end

function ChatMainData:GetWorldGroupId()
  return self.curWorldGroupId_
end

function ChatMainData:GetWorldChannelState()
  return self.curWorldChannelState_
end

function ChatMainData:SetMainChatInputChannel(channelId)
  self.mainChatInputChannel_ = channelId
end

function ChatMainData:GetMainChatInputChannel()
  return self.mainChatInputChannel_
end

function ChatMainData:getShowChannelList(chatMsgList, isShowClientTips)
  local showChatMsgDataList = {}
  if 0 < #chatMsgList then
    for i = 1, #chatMsgList do
      local chatMsgData = chatMsgList[i]
      if (isShowClientTips or Z.ChatMsgHelper.GetMsgType(chatMsgData) ~= E.ChitChatMsgType.EChatMsgClientTips) and Z.ChatMsgHelper.CheckChatMsgCanShow(chatMsgData) then
        showChatMsgDataList[#showChatMsgDataList + 1] = chatMsgList[i]
      end
    end
  end
  return showChatMsgDataList
end

function ChatMainData:addChatMsgData(queue, chatMsgData, isRecord, maxCount, autoSort)
  if not queue then
    return
  end
  if maxCount and maxCount <= #queue then
    table.remove(queue, 1)
  end
  if isRecord then
    if autoSort and 1 < #queue then
      local curMsgSendTime = Z.ChatMsgHelper.GetSendTime(chatMsgData)
      if curMsgSendTime < Z.ChatMsgHelper.GetSendTime(queue[1]) then
        table.insert(queue, 1, chatMsgData)
      else
        for i = #queue, 1, -1 do
          if curMsgSendTime > Z.ChatMsgHelper.GetSendTime(queue[i]) then
            table.insert(queue, i + 1, chatMsgData)
            break
          end
        end
      end
    elseif 0 < #queue and queue[1].IsShowInFirst then
      table.insert(queue, 2, chatMsgData)
    else
      table.insert(queue, 1, chatMsgData)
    end
  else
    table.insert(queue, chatMsgData)
    if #queue == 1 then
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.RefreshChatViewEmptyState)
    end
  end
end

function ChatMainData:SaveChatMsgDataToChannelQueue(channelId, chatMsgData, targetId, isRecord, maxCount, autoSort)
  if channelId == nil then
    return nil
  end
  if channelId == E.ChatChannelType.EChannelPrivate then
    if self.privateChatList_ then
      for i = 1, #self.privateChatList_ do
        if self.privateChatList_[i].charId == targetId then
          if not self.privateChatList_[i].multiMsgList then
            self.privateChatList_[i].multiMsgList = {}
          end
          self:addChatMsgData(self.privateChatList_[i].multiMsgList, chatMsgData, isRecord, maxCount)
          if isRecord or Z.ChatMsgHelper.GetMsgType(chatMsgData) == E.ChitChatMsgType.EChatMsgClientTips then
            return
          end
          self.privateChatList_[i].latestMsg = chatMsgData.ChitChatMsg
        end
      end
    end
  elseif self.chatMsgQueue_[channelId] then
    if not self.chatMsgQueue_[channelId].multiMsgList then
      self.chatMsgQueue_[channelId].multiMsgList = {}
    end
    self:addChatMsgData(self.chatMsgQueue_[channelId].multiMsgList, chatMsgData, isRecord, maxCount, autoSort)
  end
end

function ChatMainData:GetChannelQueueByChannelId(channelId, targetId, isShowClientTips)
  if channelId == nil then
    return nil
  end
  if channelId == E.ChatChannelType.EChannelPrivate then
    if self.privateChatList_ then
      for i = 1, #self.privateChatList_ do
        if self.privateChatList_[i].charId == targetId then
          if not self.privateChatList_[i].multiMsgList then
            self.privateChatList_[i].multiMsgList = {}
          end
          return self:getShowChannelList(self.privateChatList_[i].multiMsgList, isShowClientTips)
        end
      end
    end
  elseif self.chatMsgQueue_[channelId] then
    if not self.chatMsgQueue_[channelId].multiMsgList then
      self.chatMsgQueue_[channelId].multiMsgList = {}
    end
    return self:getShowChannelList(self.chatMsgQueue_[channelId].multiMsgList, isShowClientTips)
  end
end

function ChatMainData:GetChatMsgDataByMsgId(channelId, targetId, msgId)
  if not channelId or not msgId then
    return
  end
  if channelId == E.ChatChannelType.EChannelPrivate then
    if not targetId then
      return
    end
    if self.privateChatList_ then
      for i = 1, #self.privateChatList_ do
        if self.privateChatList_[i].charId == targetId then
          if not self.privateChatList_[i].multiMsgList then
            return
          end
          for j = 1, #self.privateChatList_[i].multiMsgList do
            if Z.ChatMsgHelper.GetMsgId(self.privateChatList_[i].multiMsgList[j]) == msgId then
              return self.privateChatList_[i].multiMsgList[j]
            end
          end
          return
        end
      end
    end
  else
    for i = 1, #self.chatMsgQueue_[channelId].multiMsgList do
      if Z.ChatMsgHelper.GetMsgId(self.chatMsgQueue_[channelId].multiMsgList[i]) == msgId then
        return self.chatMsgQueue_[channelId].multiMsgList[i]
      end
    end
  end
end

function ChatMainData:ClearChannelChatTips(channelId)
  if not self.chatMsgQueue_[channelId].multiMsgList then
    self.chatMsgQueue_[channelId].multiMsgList = {}
    return
  end
  if #self.chatMsgQueue_[channelId].multiMsgList == 0 then
    return
  end
  for i = #self.chatMsgQueue_[channelId].multiMsgList, 1, -1 do
    if Z.ChatMsgHelper.GetMsgType(self.chatMsgQueue_[channelId].multiMsgList[i]) == E.ChitChatMsgType.EChatMsgClientTips then
      table.remove(self.chatMsgQueue_[channelId].multiMsgList, i)
    end
  end
end

function ChatMainData:ClearChannelChatByConfigId(channelId, configId)
  if not self.chatMsgQueue_[channelId].multiMsgList then
    self.chatMsgQueue_[channelId].multiMsgList = {}
    return
  end
  if #self.chatMsgQueue_[channelId].multiMsgList == 0 then
    return
  end
  for i = #self.chatMsgQueue_[channelId].multiMsgList, 1, -1 do
    if Z.ChatMsgHelper.GetNoticeConfigId(self.chatMsgQueue_[channelId].multiMsgList[i]) == configId then
      table.remove(self.chatMsgQueue_[channelId].multiMsgList, i)
    end
  end
end

function ChatMainData:ClearComprehensiveChannelChatTipsAndChannelMsg(channelId)
  if not self.chatMsgQueue_[E.ChatChannelType.EComprehensive].multiMsgList then
    self.chatMsgQueue_[E.ChatChannelType.EComprehensive].multiMsgList = {}
  end
  for i = #self.chatMsgQueue_[E.ChatChannelType.EComprehensive].multiMsgList, 1, -1 do
    if Z.ChatMsgHelper.GetMsgType(self.chatMsgQueue_[E.ChatChannelType.EComprehensive].multiMsgList[i]) == E.ChitChatMsgType.EChatMsgClientTips or Z.ChatMsgHelper.GetChannelId(self.chatMsgQueue_[E.ChatChannelType.EComprehensive].multiMsgList[i]) == channelId then
      table.remove(self.chatMsgQueue_[E.ChatChannelType.EComprehensive].multiMsgList, i)
    end
  end
end

function ChatMainData:SortChannelChatQueue(channelId)
  if not self.chatMsgQueue_[channelId].multiMsgList then
    return
  end
  if #self.chatMsgQueue_[channelId].multiMsgList <= 1 then
    return
  end
  table.sort(self.chatMsgQueue_[channelId].multiMsgList, function(left, right)
    return Z.ChatMsgHelper.GetSendTime(left) < Z.ChatMsgHelper.GetSendTime(right)
  end)
end

function ChatMainData:UpdatePrivateChatByCharId(charId, latestMsgId, maxReadMsgId, isEnd, ignoreSetMaxRed)
  for i = 1, #self.privateChatList_ do
    if self.privateChatList_[i].charId == charId then
      if latestMsgId then
        self.privateChatList_[i].latestMsgId = latestMsgId
      end
      if maxReadMsgId and not ignoreSetMaxRed and maxReadMsgId > self.privateChatList_[i].maxReadMsgId then
        self.privateChatList_[i].maxReadMsgId = maxReadMsgId
      end
      if isEnd then
        self.privateChatList_[i].isEnd = isEnd
      end
      break
    end
  end
end

function ChatMainData:SetPrivateChatTopByCharId(charId, isTop)
  for i = 1, #self.privateChatList_ do
    if self.privateChatList_[i].charId == charId then
      self.privateChatList_[i].isTop = isTop
      break
    end
  end
end

function ChatMainData:UpdateChannelChatByChannelType(channelId, latestMsgId)
  if self.chatMsgQueue_[channelId] then
    self.chatMsgQueue_[channelId].latestMsgId = latestMsgId
  end
end

function ChatMainData:IsInBlack(targetId)
  if not self.blackList_ or #self.blackList_ < 1 then
    return false
  end
  return table.zcontains(self.blackList_, targetId)
end

function ChatMainData:InitBlackList(blockIdList)
  self.blackList_ = blockIdList
end

function ChatMainData:GetBlackList()
  return self.blackList_
end

function ChatMainData:AddBlack(targetId)
  if table.zcontains(self.blackList_, targetId) then
    return
  end
  self.blackList_[#self.blackList_ + 1] = targetId
end

function ChatMainData:RemoveBlack(targetId)
  if #self.blackList_ < 1 then
    return
  end
  for i = #self.blackList_, 1, -1 do
    if self.blackList_[i] == targetId then
      table.remove(self.blackList_, i)
    end
  end
end

function ChatMainData:GetCharLimit()
  local localLanguageIdx = Z.LocalizationMgr:GetCurrentLanguage()
  if localLanguageIdx == E.Language.SimplifiedChinese or localLanguageIdx == E.Language.Korean or localLanguageIdx == E.Language.Japanese then
    self.charLimit_ = 140
  else
    self.charLimit_ = 280
  end
  return self.charLimit_
end

function ChatMainData:GetChatDraft(channelId, chatWindow, charId)
  if channelId == E.ChatChannelType.EChannelPrivate then
    return self.channelChatDraft_[E.ChatWindow.Main][charId]
  elseif chatWindow == E.ChatWindow.Main then
    return self.channelChatDraft_[chatWindow]
  elseif channelId then
    return self.channelChatDraft_[E.ChatWindow.Mini][channelId]
  end
end

function ChatMainData:SetChatDraft(draftData, channelId, chatWindow, charId)
  if channelId == E.ChatChannelType.EChannelPrivate then
    self.channelChatDraft_[E.ChatWindow.Main][charId] = draftData
  elseif chatWindow == E.ChatWindow.Main then
    self.channelChatDraft_[chatWindow] = draftData
  elseif channelId then
    self.channelChatDraft_[E.ChatWindow.Mini][channelId] = draftData
  end
end

function ChatMainData:GetChannelCfg()
  if self.channelCfg_ and next(self.channelCfg_) then
    return self.channelCfg_
  end
end

function ChatMainData:GetChannelList()
  if not self.isInitList_ then
    self.isInitList_ = true
    self:initChannelList()
  end
  return self.channelList_
end

function ChatMainData:CheckChannelList(functionId, open)
  if self.channelFunctionIdList_ and table.zcontains(self.channelFunctionIdList_, functionId) and open then
    self:initChannelList()
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.RefreshChatChannel)
  end
end

function ChatMainData:initChannelList()
  if self.channelCfg_ and next(self.channelCfg_) then
    self.channelList_ = {}
    self.channelFunctionIdList_ = {}
    local switchVm = Z.VMMgr.GetVM("switch")
    for _, config in pairs(self.channelCfg_) do
      if switchVm.CheckFuncSwitch(config.FunctionId) then
        table.insert(self.channelFunctionIdList_, config.FunctionId)
        if config.SubFunctionId and config.SubFunctionId and #config.SubFunctionId > 0 then
          local isOpen = true
          for i = 1, #config.SubFunctionId do
            if switchVm.CheckFuncSwitch(config.SubFunctionId[i]) == false then
              isOpen = false
              table.insert(self.channelFunctionIdList_, config.SubFunctionId[i])
            end
          end
          if isOpen then
            self.channelList_[#self.channelList_ + 1] = config
          end
        else
          self.channelList_[#self.channelList_ + 1] = config
        end
      end
    end
  end
end

function ChatMainData:SetChannelId(channelId)
  if self.curChannelId_ ~= channelId then
    self.curChannelId_ = channelId
  end
end

function ChatMainData:GetChannelId()
  if self.curChannelId_ then
    return self.curChannelId_
  else
    return self.channelCfg_[1].Id
  end
end

function ChatMainData:SetComprehensiveId(channelId)
  if self.comprehensiveId_ ~= channelId then
    self.comprehensiveId_ = channelId
  end
end

function ChatMainData:GetComprehensiveId()
  if self.comprehensiveId_ and self.comprehensiveId_ ~= -1 then
    return self.comprehensiveId_
  end
  local chatSettingData = Z.DataMgr.Get("chat_setting_data")
  local list = {}
  for _, config in pairs(self:GetComprehensiveConfig()) do
    list[config.Id] = chatSettingData:GetSynthesis(config.Id)
  end
  local count = 0
  for _, config in pairs(list) do
    if not config then
      count = count + 1
    end
  end
  if count == table.zcount(list) then
    self.comprehensiveId_ = -1
    return self.comprehensiveId_
  end
  if 0 < table.zcount(list) then
    for k, config in pairs(list) do
      if config then
        self.comprehensiveId_ = k
        return self.comprehensiveId_
      end
    end
  end
end

function ChatMainData:GetConfigData(channelId)
  if self.channelCfg_ and next(self.channelCfg_) then
    for _, config in pairs(self.channelCfg_) do
      if channelId and channelId == config.Id then
        return config
      end
    end
    return nil
  end
  return nil
end

function ChatMainData:GetChannelIdxWithId(channelId)
  if self.channelList_ and next(self.channelList_) then
    for k, v in pairs(self.channelList_) do
      if channelId and channelId == v.Id then
        return k - 1
      end
    end
  end
  return 0
end

function ChatMainData:GetComprehensiveConfig()
  local settingsTbl = Z.TableMgr.GetTable("SettingsTableMgr")
  local chatSettingData = Z.DataMgr.Get("chat_setting_data")
  self.comprehensiveConfig_ = {}
  local settingData = settingsTbl.GetRow(self.ComprehensiveConfigSettingId_)
  if settingData and self.channelCfg_ and next(self.channelCfg_) then
    for _, v in pairs(self.channelCfg_) do
      if chatSettingData:GetSynthesis(v.Id) ~= nil and v.Id ~= E.ChatChannelType.ESystem and v.Id ~= E.ChatChannelType.EComprehensive then
        table.insert(self.comprehensiveConfig_, 1, v)
      end
    end
  end
  return self.comprehensiveConfig_
end

function ChatMainData:GetExceptCurChannel(curChannel)
  local config = {}
  local comprehensiveId = curChannel or self:GetComprehensiveId()
  for _, v in pairs(self:GetComprehensiveConfig()) do
    if v.Id ~= comprehensiveId then
      if v.Id == E.ChatChannelType.EChannelTeam then
        local teamVM = Z.VMMgr.GetVM("team")
        if teamVM.CheckIsInTeam() then
          table.insert(config, v)
        end
      elseif v.Id == E.ChatChannelType.EChannelUnion then
        local unionVM = Z.VMMgr.GetVM("union")
        if unionVM:GetPlayerUnionId() > 0 then
          table.insert(config, v)
        end
      else
        table.insert(config, v)
      end
    end
  end
  return config
end

function ChatMainData:GetGroupSprite(type)
  local list = {}
  if self.chatTickersConfig_ and next(self.chatTickersConfig_) then
    for _, v in pairs(self.chatTickersConfig_) do
      if v.GroupId == type then
        table.insert(list, v)
      end
    end
  end
  return list
end

function ChatMainData:GetGroupSpriteByType(type)
  local list = {}
  if self.chatTickersConfig_ and next(self.chatTickersConfig_) then
    for _, v in pairs(self.chatTickersConfig_) do
      if v.Type == type then
        table.insert(list, v)
      end
    end
  end
  return list
end

function ChatMainData:AddMiniChat(channelId, charId, channelName, colorStyle)
  if not self.miniChatList_ then
    self.miniChatList_ = {}
  end
  local miniChatData = self:getMiniChatData(channelId, charId)
  if miniChatData then
    return
  end
  local config = self:GetConfigData(channelId)
  channelName = channelName or config == nil and "" or config.ChannelName
  colorStyle = colorStyle or config == nil and "" or config.ChannelStyle
  self.miniIndex_ = self.miniIndex_ + 1
  local data = {
    channelId = channelId,
    charId = charId,
    type = E.MiniChatType.EChatView,
    x = 0,
    y = 183,
    channelName = channelName,
    colorTag = colorStyle,
    index = self.miniIndex_
  }
  self.miniChatList_[#self.miniChatList_ + 1] = data
  return data
end

function ChatMainData:GetMiniChatData(index)
  return self.miniChatList_[index]
end

function ChatMainData:getMiniChatData(channelId, charId)
  for i = #self.miniChatList_, 1, -1 do
    if channelId and self.miniChatList_[i].channelId == channelId then
      if charId then
        if self.miniChatList_[i].charId == charId then
          return self.miniChatList_[i], i
        end
      else
        return self.miniChatList_[i], i
      end
    end
  end
end

function ChatMainData:RemoveMiniChat(index)
  for i = #self.miniChatList_, 1, -1 do
    if self.miniChatList_[i].index == index then
      table.remove(self.miniChatList_, i)
      break
    end
  end
end

function ChatMainData:UpdateMiniChatType(channelId, charId, type)
  local miniChatData = self:getMiniChatData(channelId, charId)
  if miniChatData then
    miniChatData.type = type
  end
end

function ChatMainData:GetMiniChatList()
  return self.miniChatList_
end

function ChatMainData:GetSelectMiniChatIndex()
  return self.selectMiniChatIndex_
end

function ChatMainData:SetSelectMiniChatIndex(index)
  self.selectMiniChatIndex_ = index
end

function ChatMainData:GetHyperLinkShareContent()
  return self.hyperLink_ and self.hyperLink_:GetShareContent() or nil
end

function ChatMainData:GetShareProtoData()
  return self.hyperLink_ and self.hyperLink_:GetShareProtoData() or nil
end

function ChatMainData:GetShareData()
  return self.hyperLink_ and self.hyperLink_:GetShareData() or nil
end

function ChatMainData:GetShareParamList()
  return self.hyperLink_ and self.hyperLink_:GetShareParamList() or nil
end

function ChatMainData:RefreshShareData(text, data, type)
  if type ~= self:GetShareHyperLinkType() then
    self.hyperLink_ = self:CreateHyperLinkData(type)
    text = ""
  end
  if self.hyperLink_ then
    self.hyperLink_:RefreshShareData(text, data)
  end
end

function ChatMainData:CheckShareData(text)
  if self.hyperLink_ then
    return self.hyperLink_:CheckShareData(text)
  end
  return false
end

function ChatMainData:ClearShareData()
  if self.hyperLink_ then
    self.hyperLink_:ClearShareData()
  end
  self.hyperLink_ = nil
end

function ChatMainData:GetShareHyperLinkType()
  if self.hyperLink_ then
    return self.hyperLink_.Type
  end
  return nil
end

function ChatMainData:CreateHyperLinkData(type)
  local data
  if not type then
    logError("\230\156\170\228\188\160\229\133\165type")
    return nil
  end
  if type == E.ChatHyperLinkType.ItemShare then
    data = require("chat_hyperlink.chat_hyperlink_item").new()
  elseif type == E.ChatHyperLinkType.FishingArchives then
    data = require("chat_hyperlink.chat_hyperlink_fishingarchives").new()
  elseif type == E.ChatHyperLinkType.FishingIllrate then
    data = require("chat_hyperlink.chat_hyperlink_fishingillrate").new()
  elseif type == E.ChatHyperLinkType.FishingRank then
    data = require("chat_hyperlink.chat_hyperlink_fishingrank").new()
  elseif type == E.ChatHyperLinkType.PersonalZone then
    data = require("chat_hyperlink.chat_hyperlink_personalzone").new()
  elseif type == E.ChatHyperLinkType.MasterDungeonScore then
    data = require("chat_hyperlink.chat_hyperlink_master_dungeon_score").new()
  elseif type == E.ChatHyperLinkType.LocalPosition then
    data = require("chat_hyperlink.chat_hyperlink_localposition").new()
  end
  return data
end

function ChatMainData:GetChatBubblePressBgOtherScale()
  if not self.chatBubblePressBgOtherScale_ then
    self.chatBubblePressBgOtherScale_ = Vector3.New(-1, 1, 1)
  end
  return self.chatBubblePressBgOtherScale_
end

function ChatMainData:GetChatBubblePressBgSelfScale()
  if not self.chatBubblePressBgSelfScale_ then
    self.chatBubblePressBgSelfScale_ = Vector3.New(1, 1, 1)
  end
  return self.chatBubblePressBgSelfScale_
end

return ChatMainData
