local friend_data = require("ui.data.friend_data")
local super = require("ui.model.data_base")
local FriendMainData = class("FriendMainData", super)
E.FriendViewType = {Chat = 1, Friend = 2}
E.PersonalizationStatus = {
  EStatusDefault = 0,
  EStatusOnline = 1,
  EStatusCopyScene = 2,
  EStatusCutScene = 3,
  EStatusPhoto = 4,
  EStatusRecruit = 5,
  EStatusOutLine = 6
}

function FriendMainData:ctor()
  super.ctor(self)
  self:ResetProp()
end

function FriendMainData:ResetProp()
  self.lastSearchTime_ = 0
  self.lastGetSuggestionTime_ = 0
  self.chatContactsGroupCfg_ = {}
  self.groupAndFriendList_ = {}
  self.IsCache = false
  self.applicationList_ = {}
  self.friendBaseDataList_ = {}
  self.AllList = {}
  self.customGroup_ = {}
  self.groupSort_ = {}
  self.groupList_ = {}
  self.SelectData = nil
  self.suggestionList_ = {}
  self.customGroupMinId_ = 100
  self.friendMainViewLeftSelectId_ = 0
  self.friendMainViewRightSelectId_ = 0
  self.playerPersonalState_ = {
    E.PersonalizationStatus.EStatusOnline
  }
  self.chatSelectCharId_ = 0
  self.addressSelectCharId_ = 0
  self.rightShowCharId_ = 0
  self.friendViewType_ = E.FriendViewType.Chat
  self.friendViewOpen_ = false
  self.isShowFriendChat_ = false
  self.chatRightSubViewList_ = {}
  self.friendsRightSubViewList_ = {}
  self.FriendlinessLevel_ = 1
  self.FriendlinessExp_ = 0
  self.FriendlinessUpdateTimeStamp_ = 0
  self.FriendlinessTodayAddExp_ = 0
  self.FriendlinessAwardList_ = {}
  self.FriendLinessData_ = {}
  self.FriendCharIdList_ = {}
  self.chatContactsGroupTableData_ = nil
  self.FriendshipLevelTableData_ = nil
  self.FriendshipTotalTableData_ = nil
end

function FriendMainData:Init()
  self:ResetProp()
  self.isSendedFriendList_ = {}
  self.CancelSource = Z.CancelSource.Rent()
end

function FriendMainData:Clear()
  self:ResetProp()
end

function FriendMainData:UnInit()
  self.CancelSource:Recycle()
end

function FriendMainData:OnLanguageChange()
  self.chatContactsGroupTableData_ = nil
  self.FriendshipLevelTableData_ = nil
end

function FriendMainData:GetChatSelectCharId()
  return self.chatSelectCharId_
end

function FriendMainData:SetChatSelectCharId(charId)
  if self.chatSelectCharId_ ~= charId then
    self:ClearChatRightSubViewList()
  end
  self.chatSelectCharId_ = charId
end

function FriendMainData:GetAddressSelectCharId()
  return self.addressSelectCharId_
end

function FriendMainData:SetAddressSelectCharId(charId)
  self.addressSelectCharId_ = charId
end

function FriendMainData:GetFriendViewType()
  return self.friendViewType_
end

function FriendMainData:SetFriendViewType(viewType)
  self.friendViewType_ = viewType
end

function FriendMainData:GetFriendViewOpen()
  return self.friendViewOpen_
end

function FriendMainData:SetFriendViewOpen(isOpen)
  self.friendViewOpen_ = isOpen
end

function FriendMainData:GetIsShowFriendChat()
  return self.isShowFriendChat_
end

function FriendMainData:SetIsShowFriendChat(isShow)
  self.isShowFriendChat_ = isShow
end

function FriendMainData:GetRightSubViewList()
  if self.friendViewType_ == E.FriendViewType.Chat then
    return self.chatRightSubViewList_
  else
    return self.friendsRightSubViewList_
  end
end

function FriendMainData:ClearRightSubViewList()
  if self.friendViewType_ == E.FriendViewType.Chat then
    self.chatRightSubViewList_ = {}
  else
    self.friendsRightSubViewList_ = {}
  end
end

function FriendMainData:ClearChatRightSubViewList()
  self.chatRightSubViewList_ = {}
end

function FriendMainData:ClearFriendRightSubViewList()
  self.friendsRightSubViewList_ = {}
end

function FriendMainData:ClearAllRightSubViewList()
  self.chatRightSubViewList_ = {}
  self.friendsRightSubViewList_ = {}
end

function FriendMainData:GetTotalFriendliness()
  return self.totalFriendliness_
end

function FriendMainData:SetFriendlinessLevel(level)
  if level == 0 then
    level = 1
  end
  self.FriendlinessLevel_ = level
end

function FriendMainData:GetFriendlinessLevel()
  return self.FriendlinessLevel_
end

function FriendMainData:SetFriendlinessExp(exp)
  self.FriendlinessExp_ = exp
end

function FriendMainData:GetFriendlinessExp()
  return self.FriendlinessExp_
end

function FriendMainData:SetFriendlinessUpdateTimeStamp(time)
  self.FriendlinessUpdateTimeStamp_ = time
end

function FriendMainData:GetFriendlinessUpdateTimeStamp()
  return self.FriendlinessUpdateTimeStamp_
end

function FriendMainData:SetFriendlinessTodayAddExp(exp)
  self.FriendlinessTodayAddExp_ = exp
end

function FriendMainData:GetFriendlinessTodayAddExp()
  return self.FriendlinessTodayAddExp_
end

function FriendMainData:SetFriendlinessAwardList(list)
  self.FriendlinessAwardList_ = list
end

function FriendMainData:GetFriendlinessAwardList()
  return self.FriendlinessAwardList_
end

function FriendMainData:AddFriendlinessAwardList(awardId)
  table.insert(self.FriendlinessAwardList_, awardId)
end

function FriendMainData:SetIsInitPrivateChatList(isInit)
  self.isInitPrivateChatList_ = isInit
end

function FriendMainData:GetIsInitPrivateChatList()
  return self.isInitPrivateChatList_
end

function FriendMainData:GetPlayerPersonalState()
  return self.playerPersonalState_
end

function FriendMainData:SetPlayerPersonalState(state)
  self.playerPersonalState_ = state
end

function FriendMainData:IsFriendByCharId(charId)
  if self.groupAndFriendList_ then
    for groupId, friendDataList in pairs(self.groupAndFriendList_) do
      if self:IsSystemGroup(groupId) then
        if groupId == E.FriendGroupType.All then
          for curCharId, _ in pairs(friendDataList) do
            if curCharId == charId then
              return true
            end
          end
        end
      else
        for curCharId, _ in pairs(friendDataList) do
          if curCharId == charId then
            return true
          end
        end
      end
    end
  end
  return false
end

function FriendMainData:checkValid(tab, charId)
  if tab == nil or #tab < 1 then
    return
  end
  for _, friendData in pairs(tab) do
    if friendData ~= nil and friendData:GetCharId() == charId then
      return false
    end
  end
  return true
end

function FriendMainData:SetApplicationList(friendData)
  if friendData == nil then
    return
  end
  if self.applicationList_ == nil then
    self.applicationList_ = {}
  end
  table.insert(self.applicationList_, 1, friendData)
end

function FriendMainData:RemoveApplicationFriendData(charId)
  if charId == nil or self.applicationList_ == nil then
    return
  end
  for i = 1, table.zcount(self.applicationList_) do
    if self.applicationList_[i]:GetCharId() == charId then
      table.remove(self.applicationList_, i)
      break
    end
  end
end

function FriendMainData:GetApplicationList()
  return self.applicationList_
end

function FriendMainData:GetApplicationCharList()
  local list = {}
  for i = 1, #self.applicationList_ do
    list[#list + 1] = self.applicationList_[i]:GetCharId()
  end
  return list
end

function FriendMainData:AddSendedFriendList(charId)
  if self.isSendedFriendList_ == nil then
    self.isSendedFriendList_ = {}
  end
  if #self.isSendedFriendList_ == 0 then
    self.isSendedFriendList_[1] = charId
  else
    for i = 1, #self.isSendedFriendList_ do
      if self.isSendedFriendList_[i] == charId then
        return
      end
    end
    self.isSendedFriendList_[#self.isSendedFriendList_ + 1] = charId
  end
end

function FriendMainData:RemoveSendedFriendList(charId)
  if self.isSendedFriendList_ and #self.isSendedFriendList_ > 0 then
    for i = 1, table.zcount(self.isSendedFriendList_) do
      if self.isSendedFriendList_[i] == charId then
        table.remove(self.isSendedFriendList_, i)
        break
      end
    end
  end
end

function FriendMainData:GetIsSendedFriend(charId)
  if self.isSendedFriendList_ and #self.isSendedFriendList_ > 0 then
    for i = 1, table.zcount(self.isSendedFriendList_) do
      if self.isSendedFriendList_[i] == charId then
        return true
      end
    end
  end
  return false
end

function FriendMainData:ClearSendedFriendList()
  self.isSendedFriendList_ = {}
end

function FriendMainData:GetFriendDataByCharId(charId)
  if self.groupAndFriendList_ then
    for _, friendDataList in pairs(self.groupAndFriendList_) do
      for curCharId, friendData in pairs(friendDataList) do
        if curCharId == charId then
          return friendData
        end
      end
    end
  end
  return nil
end

function FriendMainData:GetOnlineFriendList()
  local onlineFriendList = {}
  if self.groupAndFriendList_ then
    for groupId, friendDataList in pairs(self.groupAndFriendList_) do
      if groupId ~= E.FriendGroupType.Shield then
        for charId, friendData in pairs(friendDataList) do
          if friendData:GetPlayerOffLineTime() == 0 then
            onlineFriendList[#onlineFriendList + 1] = charId
          end
        end
      end
    end
  end
  return onlineFriendList
end

function FriendMainData:GetGroupTableData()
  if not self.chatContactsGroupTableData_ then
    self.chatContactsGroupTableData_ = Z.TableMgr.GetTable("ChatContactsGroupTableMgr").GetDatas()
  end
  return self.chatContactsGroupTableData_
end

function FriendMainData:GetFriendshipLevelTableData()
  if not self.FriendshipLevelTableData_ then
    self.FriendshipLevelTableData_ = Z.TableMgr.GetTable("FriendshipLevelMgr").GetDatas()
  end
  return self.FriendshipLevelTableData_
end

function FriendMainData:GetFriendshipTotalData()
  if not self.FriendshipTotalTableData_ then
    self.FriendshipTotalTableData_ = Z.TableMgr.GetTable("FriendshipTotalValueMgr").GetDatas()
  end
  return self.FriendshipTotalTableData_
end

function FriendMainData:SetLastSearchTime(value)
  self.lastSearchTime_ = value
end

function FriendMainData:GetLastSearchTime()
  return self.lastSearchTime_
end

function FriendMainData:SetLastGetSuggestionTime(value)
  self.lastGetSuggestionTime_ = value
end

function FriendMainData:GetLastGetSuggestionTime()
  return self.lastGetSuggestionTime_
end

function FriendMainData:SetGroupAndFriendData(groupID, friendData)
  if self.groupAndFriendList_ == nil then
    self.groupAndFriendList_ = {}
  end
  if self.groupAndFriendList_[groupID] == nil then
    self.groupAndFriendList_[groupID] = {}
  end
  local charId = friendData:GetCharId()
  self.groupAndFriendList_[groupID][charId] = friendData
end

function FriendMainData:GetGroupFriendData(groupID, charId)
  if self.groupAndFriendList_ and self.groupAndFriendList_[groupID] then
    return self.groupAndFriendList_[groupID][charId]
  end
end

function FriendMainData:RemoveFriendData(groupID, charId)
  if groupID == nil or self.groupAndFriendList_ == nil then
    return
  end
  local group = self.groupAndFriendList_[groupID]
  if group == nil or charId == nil then
    return
  end
  group[charId] = nil
end

function FriendMainData:RemoveGroupAndFriendDatas(groupID, groupIDs)
  if groupID == nil then
    return
  end
  if groupIDs == nil then
    return
  end
  for _, value in pairs(groupIDs) do
    self:RemoveFriendData(groupID, value)
  end
end

function FriendMainData:RemoveDataByCharId(charId, isIgnoreShield)
  if self.groupAndFriendList_ then
    for groupId, friendDataList in pairs(self.groupAndFriendList_) do
      if true == isIgnoreShield then
        if groupId ~= E.FriendGroupType.Shield then
          friendDataList[charId] = nil
        end
      else
        friendDataList[charId] = nil
      end
    end
  end
end

function FriendMainData:GetGroupAndFriendData(groupID)
  if self.groupAndFriendList_ == nil then
    self.groupAndFriendList_ = {}
  end
  if self.groupAndFriendList_[groupID] == nil then
    self.groupAndFriendList_[groupID] = {}
  end
  return self.groupAndFriendList_[groupID]
end

function FriendMainData:GetFriendDic()
  return self.groupAndFriendList_
end

function FriendMainData:ClearCustomGroup()
  self.customGroup_ = {}
end

function FriendMainData:SetCustomGroupData(groupID, groupName)
  if self.customGroup_ == nil then
    self.customGroup_ = {}
  end
  if groupID == nil or groupName == nil or groupName == "" then
    return
  end
  self.customGroup_[groupID] = groupName
end

function FriendMainData:RemoveCustomGroup(groupID)
  if self.customGroup_ == nil then
    return
  end
  self.customGroup_[groupID] = nil
end

function FriendMainData:GetGroupName(groupID)
  if self:IsSystemGroup(groupID) then
    local config = Z.TableMgr.GetTable("ChatContactsGroupTableMgr").GetRow(groupID)
    if config then
      return config.GroupName
    else
      return ""
    end
  else
    if self.customGroup_ == nil then
      self.customGroup_ = {}
      return ""
    end
    return self.customGroup_[groupID]
  end
end

function FriendMainData:GetCustomGroup()
  return self.customGroup_
end

function FriendMainData:SetGroupSort(groupSort)
  if groupSort == nil then
    return
  end
  self.groupSort_ = groupSort
  self:InitGroupSort()
end

function FriendMainData:CheckGroupSort()
  if #self.groupSort_ == 0 then
    return false
  end
  local groupCount = table.zcount(self.groupSort_)
  local customCount = table.zcount(self.customGroup_)
  local systemcount = table.zcount(self:GetGroupTableData())
  if customCount + systemcount ~= groupCount then
    return false
  end
  local chatGroupCfgs = self:GetGroupTableData()
  for _, friendsGroup in pairs(chatGroupCfgs) do
    local find = false
    for i = 1, #self.groupSort_ do
      if self.groupSort_[i] == friendsGroup.Id then
        find = true
        break
      end
    end
    if false == find then
      return false
    end
  end
  for groupId, _ in pairs(self.customGroup_) do
    local find = false
    for i = 1, #self.groupSort_ do
      if self.groupSort_[i] == groupId then
        find = true
        break
      end
    end
    if false == find then
      return false
    end
  end
  return true
end

local friendSortFunc = function(left, right)
  local leftSortValue = 0
  local rightSortValue = 0
  if left:GetPlayerOffLineTime() == 0 then
    leftSortValue = leftSortValue + 100
  end
  if right:GetPlayerOffLineTime() == 0 then
    rightSortValue = rightSortValue + 100
  end
  if leftSortValue == rightSortValue then
    if left:GetPlayerOffLineTime() == 0 and right:GetPlayerOffLineTime() == 0 then
      return left:GetCharId() < right:GetCharId()
    else
      return left:GetPlayerOffLineTime() > right:GetPlayerOffLineTime()
    end
  else
    return leftSortValue > rightSortValue
  end
end

function FriendMainData:GetFriendPCListData()
  local chatGroupCfgs = self:GetGroupTableData()
  local groupFriendList = {}
  local systemGroup = {}
  groupFriendList[1] = {
    loopItemType = E.FriendLoopItemType.EFriendGroupName,
    IsDefault = true
  }
  for _, friendsGroup in pairs(chatGroupCfgs) do
    groupFriendList[#groupFriendList + 1] = {
      loopItemType = E.FriendLoopItemType.EFriendGroup,
      GroupId = friendsGroup.Id,
      GroupName = friendsGroup.GroupName,
      IsDefault = true
    }
    systemGroup[#systemGroup + 1] = friendsGroup.Id
    local list = {}
    local count = 0
    if self.groupAndFriendList_[friendsGroup.Id] then
      for _, friendData in pairs(self.groupAndFriendList_[friendsGroup.Id]) do
        list[#list + 1] = friendData
        count = count + 1
      end
      table.sort(list, friendSortFunc)
      for i = 1, count do
        groupFriendList[#groupFriendList + 1] = {
          loopItemType = E.FriendLoopItemType.EFriendItem,
          friendData = list[i]
        }
      end
    end
  end
  groupFriendList[#groupFriendList + 1] = {
    loopItemType = E.FriendLoopItemType.EFriendGroupName
  }
  if self.groupSort_ then
    for _, groupId in ipairs(self.groupSort_) do
      if self.customGroup_[groupId] and not table.zcontains(systemGroup, groupId) then
        groupFriendList[#groupFriendList + 1] = {
          loopItemType = E.FriendLoopItemType.EFriendGroup,
          GroupId = groupId,
          GroupName = self.customGroup_[groupId]
        }
        if self.groupAndFriendList_[groupId] then
          local list = {}
          local count = 0
          for _, friendData in pairs(self.groupAndFriendList_[groupId]) do
            list[#list + 1] = friendData
            count = count + 1
          end
          table.sort(list, friendSortFunc)
          for i = 1, count do
            groupFriendList[#groupFriendList + 1] = {
              loopItemType = E.FriendLoopItemType.EFriendItem,
              friendData = list[i]
            }
          end
        end
      end
    end
  end
  return groupFriendList
end

function FriendMainData:InitGroupSort()
  local chatGroupCfgs = self:GetGroupTableData()
  local systemGroup = {}
  for _, friendsGroup in pairs(chatGroupCfgs) do
    if not table.zcontains(self.groupSort_, friendsGroup.Id) then
      self.groupSort_[#self.groupSort_ + 1] = friendsGroup.Id
    end
    table.insert(systemGroup, friendsGroup.Id)
  end
  self.groupList_ = {}
  for _, groupId in ipairs(self.groupSort_) do
    if self.customGroup_[groupId] or table.zcontains(systemGroup, groupId) then
      local data = friend_data.new()
      data:SetIsGroup(true)
      data:SetGroupId(groupId)
      table.insert(self.groupList_, data)
    end
  end
end

function FriendMainData:GetGroupSort()
  return self.groupSort_
end

function FriendMainData:GetGroupList()
  return self.groupList_
end

function FriendMainData:GetSuggestionList()
  return self.suggestionList_
end

function FriendMainData:SetSuggestionList(suggestionList)
  self.suggestionList_ = suggestionList
end

function FriendMainData:IsSystemGroup(groupId)
  if groupId then
    return groupId < self.customGroupMinId_
  end
  return false
end

function FriendMainData:UpdateFriendLiness(charId, friendLiness)
  local friendLinessData = {}
  friendLinessData.friendLinessLevel = friendLiness.level
  friendLinessData.friendLinessCurExp = friendLiness.curExp
  friendLinessData.friendLinessUpdateTimeStamp = friendLiness.updateTimeStamp
  friendLinessData.friendLinessTodayAddExp = friendLiness.todayTotalAddExps
  friendLinessData.friendLinessTodayPartAddExps = friendLiness.todayPartAddExps
  friendLinessData.friendLinessGetAwardList = friendLiness.gotLevelAwards
  self.FriendLinessData_[charId] = friendLinessData
end

function FriendMainData:GetFriendLinessData(charId)
  return self.FriendLinessData_[charId]
end

function FriendMainData:AddFriendLinessAwardId(charId, awardId)
  table.insert(self.FriendLinessData_[charId].friendLinessGetAwardList, awardId)
end

function FriendMainData:UpdateFriendLinessExpChange(friendChangeList)
  if friendChangeList then
    for i = 1, #friendChangeList do
      local levelInfo = friendChangeList[i]
      if self.FriendLinessData_[levelInfo.friendId] then
        self.FriendLinessData_[levelInfo.friendId].friendLinessLevel = levelInfo.level
        self.FriendLinessData_[levelInfo.friendId].friendLinessCurExp = levelInfo.curExp
        self.FriendLinessData_[levelInfo.friendId].friendLinessTodayAddExp = levelInfo.todayAddExps
      end
    end
  end
end

function FriendMainData:DelFriendLiness(charId)
  if self.FriendLinessData_[charId] then
    self.FriendLinessData_[charId] = nil
  end
end

function FriendMainData:AddFriendCharList(charId)
  if table.zcontains(self.FriendCharIdList_, charId) then
    return
  end
  self.FriendCharIdList_[#self.FriendCharIdList_ + 1] = charId
end

function FriendMainData:RemoveFriendCharList(charId)
  for i = #self.FriendCharIdList_, 1, -1 do
    if self.FriendCharIdList_[i] == charId then
      table.remove(self.FriendCharIdList_, i)
      return
    end
  end
end

function FriendMainData:GetFriendCharList()
  return self.FriendCharIdList_
end

return FriendMainData
