local super = require("ui.model.data_base")
local ChatMainData = class("ChatMainData", super)
E.ChatHyperLinkType = {
  ItemShare = 3000001,
  FishingIllrate = 8009003,
  FishingRank = 8009004,
  FishingArchives = 8009005,
  PersonalZone = 3001001
}

function ChatMainData:ctor()
  super.ctor(self)
  self:resetProp()
end

function ChatMainData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function ChatMainData:Clear()
  self:ResetData()
end

function ChatMainData:OnReconnect()
end

function ChatMainData:UnInit()
  self.CancelSource:Recycle()
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function ChatMainData:onLanguageChange()
  self:initChannelCfg()
end

function ChatMainData:resetProp()
  self:ResetData()
  self:initChannelCfg()
  self.channelList_ = {}
  self.channelFunctionIdList_ = {}
  self.comprehensiveConfig_ = {}
  self.charLimit_ = 0
  self.ComprehensiveConfigSettingId_ = 101
end

function ChatMainData:ResetData()
  self.isInitChatRecord_ = false
  self.comprehensiveId_ = -1
  self.curChannelId_ = nil
  self.sendChannelId_ = nil
  self.curWorldGroupId_ = 0
  self.curWorldNum_ = 0
  self.curWorldMaxNum_ = 0
  self.banTime_ = 0
  self.emojiHistoryList_ = {}
  self.msgHistoryList_ = {}
  self.privateSelectId_ = 0
  self.privateChatList_ = {}
  self.blackList_ = {}
  self.miniChatList_ = {}
  self.selectMiniChatChannelId_ = 0
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
  self.ChatLinkTips = {}
  self.hyperLink_ = nil
  self.playerLevelTableData_ = nil
end

function ChatMainData:ClearChatMsgQueue()
  self.chatMsgQueue_ = {
    [E.ChatChannelType.EChannelWorld] = {},
    [E.ChatChannelType.EChannelScene] = {},
    [E.ChatChannelType.EChannelTeam] = {},
    [E.ChatChannelType.EChannelUnion] = {},
    [E.ChatChannelType.EChannelPrivate] = {},
    [E.ChatChannelType.EComprehensive] = {},
    [E.ChatChannelType.ESystem] = {},
    [E.ChatChannelType.EMain] = {}
  }
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
    },
    [E.ChatChannelType.EMain] = {
      [E.ChatWindow.Main] = {flg = false, isRecord = false},
      [E.ChatWindow.Mini] = {flg = false, isRecord = false}
    }
  }
end

function ChatMainData:SetChatDataFlg(channelType, windowType, dataFlg, record)
  if channelType == E.ChatChannelType.EChannelPrivate then
    if not self.chatFlg_[channelType][self.privateSelectId_] then
      self.chatFlg_[channelType][self.privateSelectId_] = {flg = dataFlg, isRecord = record}
    else
      self.chatFlg_[channelType][self.privateSelectId_].flg = dataFlg
      self.chatFlg_[channelType][self.privateSelectId_].isRecord = record
    end
  elseif not self.chatFlg_[channelType][windowType] then
    self.chatFlg_[channelType][windowType] = {flg = dataFlg, isRecord = record}
  else
    self.chatFlg_[channelType][windowType].flg = dataFlg
    self.chatFlg_[channelType][windowType].isRecord = record
  end
end

function ChatMainData:GetChatDataFlg(channelType, windowType)
  if channelType == E.ChatChannelType.EChannelPrivate then
    return self.chatFlg_[channelType][self.privateSelectId_]
  else
    return self.chatFlg_[channelType][windowType]
  end
end

function ChatMainData:ClearChannelQueueByChannelId(channel)
  if self.chatMsgQueue_[channel] then
    self.chatMsgQueue_[channel] = {}
  end
end

function ChatMainData:ClearClientChannelData(dataChannelId, clearChannelId)
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

function ChatMainData:AddPrivateChatByCharId(charId)
  if #self.privateChatList_ > 0 then
    for i = 1, #self.privateChatList_ do
      if self.privateChatList_[i].charId == charId then
        return
      end
    end
  end
  local privateChatItem = {
    charId = charId,
    multiMsgList = {}
  }
  self.privateChatList_[#self.privateChatList_ + 1] = privateChatItem
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

function ChatMainData:AddPrivateChatListAddByTargetInfo(targetInfo)
  if #self.privateChatList_ > 0 then
    for i = 1, #self.privateChatList_ do
      if self.privateChatList_[i].charId == targetInfo.charId then
        return
      end
    end
  end
  local privateChatItem = {
    charId = targetInfo.charId,
    maxReadMsgId = targetInfo.maxReadMsgId,
    isTop = targetInfo.isTop,
    latestMsg = targetInfo.latestMsg,
    multiMsgList = {}
  }
  self.privateChatList_[#self.privateChatList_ + 1] = privateChatItem
end

function ChatMainData:AddPrivateChat(privateChatItem)
  self.privateChatList_[#self.privateChatList_ + 1] = privateChatItem
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

function ChatMainData:GetPrivateChatUnReadCount()
  local unReadCount = 0
  for i = 1, #self.privateChatList_ do
    if self.privateChatList_[i].maxReadMsgId and self.privateChatList_[i].latestMsg and self.privateChatList_[i].latestMsg.msgId and self.privateChatList_[i].latestMsg.msgId > self.privateChatList_[i].maxReadMsgId then
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

function ChatMainData:GetPrivateChatItemByCharId(charId)
  if #self.privateChatList_ > 0 then
    for i = 1, #self.privateChatList_ do
      if self.privateChatList_[i].charId == charId then
        return self.privateChatList_[i]
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

function ChatMainData:SetWorldGroupId(data, num, maxNum)
  self.curWorldGroupId_ = data
  self.curWorldNum_ = num
  self.curWorldMaxNum_ = maxNum
end

function ChatMainData:GetWorldGroupId()
  return self.curWorldGroupId_
end

function ChatMainData:GetShowWorldGroupChannel()
  return self.curWorldGroupId_
end

function ChatMainData:GetWorldNum()
  return self.curWorldNum_
end

function ChatMainData:GetWorldMaxNum()
  return self.curWorldMaxNum_
end

function ChatMainData:checkMessageLevelLimit(channelId, level, msgType)
  if channelId == E.ChatChannelType.ESystem then
    return true
  end
  if msgType == E.ChitChatMsgType.EChatMsgTextNotice or msgType == E.ChitChatMsgType.EChatMsgMultiLangNotice or msgType == E.ChitChatMsgType.EChatMsgHypertext then
    return true
  end
  local settingData = Z.DataMgr.Get("chat_setting_data")
  local limit = settingData:GetMessageLevel(channelId)
  if not limit then
    return true
  end
  local messageLevelLimit = math.modf(limit)
  if messageLevelLimit and level and level < messageLevelLimit then
    return false
  else
    return true
  end
end

function ChatMainData:getShowChannelList(chatMsgList)
  local showChatMsgDataList = {}
  if 0 < #chatMsgList then
    for i = 1, #chatMsgList do
      local chatMsgData = chatMsgList[i]
      if Z.ChatMsgHelper.GetMsgType(chatMsgData) ~= E.ChitChatMsgType.EChatMsgClientTips and self:checkMessageLevelLimit(Z.ChatMsgHelper.GetChannelId(chatMsgData), Z.ChatMsgHelper.GetSenderLevel(chatMsgData), Z.ChatMsgHelper.GetMsgType(chatMsgData) and not self:IsInBlack(Z.ChatMsgHelper.GetCharId(chatMsgData))) then
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
    targetId = targetId or self.privateSelectId_
    if self.privateChatList_ then
      for i = 1, #self.privateChatList_ do
        if self.privateChatList_[i].charId == targetId then
          if not self.privateChatList_[i].multiMsgList then
            self.privateChatList_[i].multiMsgList = {}
          end
          self:addChatMsgData(self.privateChatList_[i].multiMsgList, chatMsgData, isRecord, maxCount)
          if not isRecord and Z.ChatMsgHelper.GetMsgType(chatMsgData) ~= E.ChitChatMsgType.EChatMsgClientTips then
            self.privateChatList_[i].latestMsg = chatMsgData.ChitChatMsg
            if Z.ChatMsgHelper.GetCharId(chatMsgData) ~= Z.ContainerMgr.CharSerialize.charId and Z.ChatMsgHelper.GetCharId(chatMsgData) ~= self:GetPrivateSelectId() then
              Z.RedPointMgr.RefreshServerNodeCount(E.RedType.FriendChatTab, self:GetPrivateChatUnReadCount())
            end
          end
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

function ChatMainData:GetChannelQueueByChannelId(channelId, targetId, isAllMsg)
  if channelId == nil then
    return nil
  end
  if channelId == E.ChatChannelType.EChannelPrivate then
    targetId = targetId or self.privateSelectId_
    if self.privateChatList_ then
      for i = 1, #self.privateChatList_ do
        if self.privateChatList_[i].charId == targetId then
          if not self.privateChatList_[i].multiMsgList then
            self.privateChatList_[i].multiMsgList = {}
          end
          return self.privateChatList_[i].multiMsgList
        end
      end
    end
  elseif self.chatMsgQueue_[channelId] then
    if not self.chatMsgQueue_[channelId].multiMsgList then
      self.chatMsgQueue_[channelId].multiMsgList = {}
    end
    if isAllMsg then
      return self.chatMsgQueue_[channelId].multiMsgList
    else
      return self:getShowChannelList(self.chatMsgQueue_[channelId].multiMsgList)
    end
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

function ChatMainData:UpdatePrivateChatByCharId(charId, latestMsgId, maxReadMsgId, isEnd)
  for i = 1, #self.privateChatList_ do
    if self.privateChatList_[i].charId == charId then
      if latestMsgId then
        self.privateChatList_[i].latestMsgId = latestMsgId
      end
      if maxReadMsgId then
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
  for i = #self.blackList_, 1, -1 do
    if self.blackList_[i] == targetId then
      return true
    end
  end
  return false
end

function ChatMainData:InitBlackList(blockIdList)
  self.blackList_ = blockIdList
end

function ChatMainData:GetBlackList()
  return self.blackList_
end

function ChatMainData:AddBlack(targetId)
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

function ChatMainData:GetChatDraft(channelId, chatWindow)
  if channelId == E.ChatChannelType.EChannelPrivate then
    if self.privateSelectId_ > 0 then
      return self.channelChatDraft_[E.ChatWindow.Main][self.privateSelectId_]
    end
  elseif chatWindow == E.ChatWindow.Main then
    return self.channelChatDraft_[E.ChatWindow.Main]
  elseif channelId then
    return self.channelChatDraft_[E.ChatWindow.Mini][channelId]
  end
end

function ChatMainData:SetChatDraft(draftData, channelId, chatWindow)
  if channelId == E.ChatChannelType.EChannelPrivate then
    if self.privateSelectId_ > 0 then
      self.channelChatDraft_[E.ChatWindow.Main][self.privateSelectId_] = draftData
    end
  elseif chatWindow == E.ChatWindow.Main then
    self.channelChatDraft_[E.ChatWindow.Main] = draftData
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
      if config.Id == E.ChatChannelType.EChannelUnion then
        self.channelList_[#self.channelList_ + 1] = config
      elseif switchVm.CheckFuncSwitch(config.FunctionId) then
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
      if chatSettingData:GetSynthesis(v.Id) ~= nil and v.Id ~= E.ChatChannelType.ESystem and v.Id ~= E.ChatChannelType.EComprehensive and v.Id ~= E.ChatChannelType.EMain then
        table.insert(self.comprehensiveConfig_, 1, v)
      end
    end
  end
  return self.comprehensiveConfig_
end

function ChatMainData:GetExceptCurChannel()
  local config = {}
  local comprehensiveId = self:GetComprehensiveId()
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

function ChatMainData:AddMiniChat(channelId)
  if not self.miniChatList_ then
    self.miniChatList_ = {}
  end
  if self.miniChatList_[channelId] then
    return
  end
  local config = self:GetConfigData(channelId)
  local data = {}
  data.channelId = channelId
  data.type = E.MiniChatType.EChatView
  data.x = 0
  data.y = 183
  data.channelName = config == nil and "" or config.ChannelName
  data.colorTag = config == nil and "" or config.ChannelStyle
  self.miniChatList_[channelId] = data
end

function ChatMainData:RemoveMiniChat(channelId)
  if not self.miniChatList_ or not self.miniChatList_[channelId] then
    return
  end
  self.miniChatList_[channelId] = nil
end

function ChatMainData:UpdateMiniChatPosition(channelId, x, y)
  if not self.miniChatList_ or not self.miniChatList_[channelId] then
    return
  end
  self.miniChatList_[channelId].x = x
  self.miniChatList_[channelId].y = y
end

function ChatMainData:UpdateMiniChatType(channelId, type)
  if not self.miniChatList_ or not self.miniChatList_[channelId] then
    return
  end
  self.miniChatList_[channelId].type = type
end

function ChatMainData:GetMiniChatList()
  return self.miniChatList_
end

function ChatMainData:GetMiniChatData(channelId)
  if not self.miniChatList_ then
    return
  end
  return self.miniChatList_[channelId]
end

function ChatMainData:GetSelectMiniChatChannelId()
  return self.selectMiniChatChannelId_
end

function ChatMainData:SetSelectMiniChatChannelId(channelId)
  self.selectMiniChatChannelId_ = channelId
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
  end
  return data
end

return ChatMainData
