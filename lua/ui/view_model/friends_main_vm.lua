local worldProxy = require("zproxy.world_proxy")
local friend_data = require("ui.data.friend_data")
local friendMainData = Z.DataMgr.Get("friend_main_data")
E.FriendAddSource = {
  ESearch = 1,
  EIdcard = 2,
  ESuggestion = 3,
  EPrivateChat = 4,
  EDungeon = 5,
  EPersonalzone = 6,
  Team = 7
}
E.FriendFunctionBtnType = {
  AddFriend = 102301,
  CreateGroup = 102302,
  FriendManagement = 102303,
  GroupManagement = 102304,
  ChatSetTop = 102305,
  ChatCancelTop = 102306,
  CancelMessageTip = 102307,
  OpenMessageTip = 102308,
  DelChat = 102309,
  SetBlack = 102310,
  CancelBlack = 102311,
  DelFriend = 102312
}
E.FriendFunctionViewType = {
  None = 0,
  ApplyFriend = 1,
  SetFriend = 2,
  SendMessage = 3,
  AddFriend = 4,
  CreateGroup = 5,
  FriendManagement = 6,
  GroupManagement = 7
}
local logPbError = function(ret)
  if ret and ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end
local logErrCode = function(errCode)
  if errCode and errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
  end
end
local checkCharIdVaild = function(charId)
  if not charId or charId == 0 then
    Z.TipsVM.ShowTipsLang(130107)
    return false
  end
  return true
end
local initFriendData = function()
  local friendData = friend_data.new()
  return friendData
end
local getSearchDataList = function(searchContext)
  local list = {}
  for _, groupList in pairs(friendMainData:GetFriendDic()) do
    for _, friendData in pairs(groupList) do
      if friendData and friendData:GetPlayerName() then
        local isMatch = false
        if string.match(friendData:GetPlayerName(), searchContext) then
          isMatch = true
        elseif string.match(friendData:GetRemark(), searchContext) then
          isMatch = true
        end
        if isMatch then
          if Z.IsPCUI then
            table.insert(list, {
              loopItemType = E.FriendLoopItemType.EFriendItem,
              friendData = friendData
            })
          else
            table.insert(list, friendData)
          end
        end
      end
    end
  end
  return list
end
local getFriendAndGroupList = function(groupList, friendList)
  local allList = {}
  for i = 1, table.zcount(groupList) do
    table.insert(allList, groupList[i])
    for j = 1, table.zcount(friendList) do
      local groupId = groupList[i]:GetGroupId()
      local tempGroupId = friendList[j]:GetGroupId()
      if groupList[i]:GetIsGroup() and groupId == tempGroupId then
        table.insert(allList, friendList[j])
      end
    end
  end
  return allList
end
local openSetView = function(viewType, viewData, clearRightSubView)
  Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendOpenFuncSubView, viewType, viewData, clearRightSubView)
end
local closeSetView = function(viewType)
  Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendCloseFuncSubView, viewType)
end
local friendSortFunc = function(left, right)
  local leftSortValue = 0
  local rightSortValue = 0
  if left:GetIsTop() then
    leftSortValue = leftSortValue + 1000
  end
  if right:GetIsTop() then
    rightSortValue = rightSortValue + 1000
  end
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
local updateGroupShowList = function()
  local groupList = friendMainData:GetGroupList()
  friendMainData.AllList = {}
  local index = 1
  for i = 1, table.zcount(groupList) do
    table.insert(friendMainData.AllList, index, groupList[i])
    index = index + 1
    if 1 == groupList[i]:GetIsGroupShow() then
      local curFriendList = friendMainData:GetGroupAndFriendData(groupList[i]:GetGroupId())
      local showList = {}
      for _, friend in pairs(curFriendList) do
        showList[#showList + 1] = friend
      end
      table.sort(showList, friendSortFunc)
      for i = 1, #showList do
        table.insert(friendMainData.AllList, index, showList[i])
        index = index + 1
      end
    end
  end
end
local asyncSendAddFriend = function(charId, sourceId, cancelToken)
  if not checkCharIdVaild(charId) then
    return
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if not gotoFuncVM.CheckFuncCanUse(E.FunctionID.AddFriend) then
    return
  end
  local sendData = {}
  sendData.charId = charId
  sendData.source = sourceId
  local errCode = worldProxy.RequestAddFriend(sendData, cancelToken)
  if errCode ~= nil then
    if errCode == 0 then
      Z.TipsVM.ShowTipsLang(130101)
      friendMainData:AddSendedFriendList(charId)
      return true
    else
      logErrCode(errCode)
      return false
    end
  end
end
local searchFriend = function(searchContent, cancelToken)
  local sendData = {}
  sendData.searchContent = searchContent
  local ret = worldProxy.SearchFriend(sendData, cancelToken)
  logPbError(ret)
  return ret
end
local asyncProcessAddRequest = function(charId, isAgree, name, cancelToken)
  local sendData = {}
  sendData.charId = charId
  sendData.isAgree = isAgree
  local errCode = worldProxy.ProcessAddRequest(sendData, cancelToken)
  logErrCode(errCode)
  if errCode == 0 and isAgree then
    local param = {
      player = {name = name}
    }
    Z.TipsVM.ShowTipsLang(130103, param)
  end
  return errCode
end
local refreshBothWayFirneds = function(friendList, isAdd, isFull)
  if friendList then
    local friendCharIdUpdateList = {}
    for charId, socialInfo in pairs(friendList) do
      if true == isAdd then
        friendCharIdUpdateList[charId] = charId
        friendMainData:AddFriendCharList(charId)
        if Z.ContainerMgr.CharSerialize.charId ~= charId then
          local curGroup
          local friendInfo = friendMainData:GetFriendDataByCharId(charId)
          if not friendInfo then
            friendInfo = initFriendData()
          else
            curGroup = friendInfo:GetGroupId()
          end
          if socialInfo then
            if socialInfo.groupId == E.FriendGroupType.None then
              socialInfo.groupId = E.FriendGroupType.All
            end
            friendInfo:RefreshBothWayFirned(charId, socialInfo)
            friendInfo:RefreshPlayerSocialData(socialInfo.socialData)
            if curGroup and socialInfo.groupId ~= curGroup then
              friendMainData:RemoveDataByCharId(charId, true)
            end
            friendMainData:SetGroupAndFriendData(socialInfo.groupId, friendInfo)
          end
        end
      else
        friendCharIdUpdateList[charId] = charId
        friendMainData:RemoveFriendCharList(charId)
        friendMainData:RemoveDataByCharId(charId, true)
        friendMainData:DelFriendLiness(charId)
        if charId == friendMainData:GetAddressSelectCharId() then
          friendMainData:SetAddressSelectCharId(0)
          friendMainData:ClearFriendRightSubViewList()
          closeSetView()
        end
        if charId == friendMainData:GetChatSelectCharId() then
          friendMainData:SetChatSelectCharId(0)
          friendMainData:ClearChatRightSubViewList()
          closeSetView()
        end
        local chatMainData = Z.DataMgr.Get("chat_main_data")
        if chatMainData:IsHavePrivateChat(charId) then
          chatMainData:DelPrivateChatByCharId(charId)
          Z.EventMgr:Dispatch(Z.ConstValue.Chat.DeletePrivateChat, charId)
        end
      end
      friendMainData:RemoveSendedFriendList(charId)
    end
    local charZList = ZUtil.Pool.Collections.ZList_long.Rent()
    if isFull then
      local friendCharList = friendMainData:GetFriendCharList()
      if next(friendCharList) then
        for key, val in ipairs(friendCharList) do
          charZList:Add(val)
        end
        Z.LuaDataMgr:InitFriendIdCache(charZList)
      end
    else
      for key, val in pairs(friendCharIdUpdateList) do
        charZList:Add(val)
      end
      Z.LuaDataMgr:UpdateFriendIdCache(charZList, isAdd)
    end
    ZUtil.Pool.Collections.ZList_long.Return(charZList)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendSuggestionRefresh)
end
local asyncInitInfo = function(friendData, token)
  local socialVM = Z.VMMgr.GetVM("social")
  token = token or friendMainData.CancelSource:CreateToken()
  local socialData = socialVM.AsyncGetHeadAndHeadFrameInfoAndSDKPrivilege(friendData:GetCharId(), token)
  if socialData and socialData.basicData then
    local modelId = Z.ModelManager:GetModelIdByGenderAndSize(socialData.basicData.gender, socialData.basicData.bodySize)
    friendData:SetPlayerName(socialData.basicData.name)
    friendData:SetPlayerOffLineTime(socialData.basicData.offlineTime)
    friendData:SetPlayerSceneId(socialData.basicData.sceneId)
    friendData:SetPlayerAvatorInfo(socialData.avatarInfo)
    friendData:SetPlayerModelId(modelId)
    friendData:SetInitInfo(true)
    friendData:SetSocialData(socialData)
  end
end
local asyncUpdataPrivateChat = function(privateChat, token)
  local socialVM = Z.VMMgr.GetVM("social")
  local socialData = socialVM.AsyncGetHeadAndHeadFrameInfoAndSDKPrivilege(privateChat.charId, token)
  if socialData then
    privateChat.socialData = socialData
  end
end
local asyncRefreshBlacks = function(blackList)
  if blackList and 0 < #blackList then
    for i = 1, #blackList do
      local blackData = friendMainData:GetGroupFriendData(E.FriendGroupType.Shield, blackList[i])
      if not blackData then
        blackData = initFriendData()
        blackData:RefreshBlackFriend(blackList[i])
      end
      if not blackData:IsInitInfo() then
        asyncInitInfo(blackData)
      end
      friendMainData:SetGroupAndFriendData(E.FriendGroupType.Shield, blackData)
    end
  end
end
local refreshCustomGroups = function(groupList)
  if groupList then
    for groupId, groupName in pairs(groupList) do
      friendMainData:SetCustomGroupData(groupId, groupName)
    end
  end
end
local refreshApplications = function(applicationList, isInit)
  if applicationList then
    for i = #applicationList, 1, -1 do
      local friendData = initFriendData()
      friendData:RefreshApplication(applicationList[i])
      friendMainData:SetApplicationList(friendData)
    end
    if 0 < #applicationList and not isInit then
      Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendAddApply, applicationList)
    end
  end
end
local refreshGroupSort = function(groupSort)
  if table.zcount(groupSort) == 0 then
    return
  end
  friendMainData:SetGroupSort(groupSort)
end
local asyncSetGroupSort = function(groupSort, cancelToken)
  local sendData = {}
  sendData.groupSort = groupSort
  local errCode = worldProxy.SetGroupSort(sendData, cancelToken)
  logErrCode(errCode)
  return errCode
end
local refreshSuggestionList = function(suggestionList)
  local chatMainData = Z.DataMgr.Get("chat_main_data")
  local charList = {}
  if suggestionList then
    for _, personalData in pairs(suggestionList) do
      if not friendMainData:IsFriendByCharId(personalData.charId) and not chatMainData:IsInBlack(personalData.charId) then
        local data = {}
        data.charId = personalData.charId
        data.friendShowInfo = personalData.info
        data.socialData = personalData.socialData
        data.source = E.FriendAddSource.ESuggestion
        charList[#charList + 1] = data
      end
    end
  end
  friendMainData:SetSuggestionList(charList)
end
local refreshFriendLiness = function(friendLinessData)
  if not friendLinessData then
    return
  end
  for charId, friendLinessData in pairs(friendLinessData) do
    friendMainData:UpdateFriendLiness(charId, friendLinessData)
  end
end
local refreshTotalFriendLiness = function(totalfriendLines)
  if not totalfriendLines then
    return
  end
  friendMainData:SetFriendlinessLevel(totalfriendLines.level)
  friendMainData:SetFriendlinessExp(totalfriendLines.curExp)
  friendMainData:SetFriendlinessTodayAddExp(totalfriendLines.todayTotalAddExps)
  friendMainData:SetFriendlinessUpdateTimeStamp(totalfriendLines.updateTimeStamp)
  friendMainData:SetFriendlinessAwardList(totalfriendLines.gotLevelAwards)
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(E.GoalType.FriendTotal, totalfriendLines.level)
end
local checkFriendRemark = function(charUuid)
  local entityVM = Z.VMMgr.GetVM("entity")
  local charId = entityVM.UuidToEntId(charUuid)
  local friendData = friendMainData:GetFriendDataByCharId(charId)
  if friendData and friendData:GetRemark() and friendData:GetRemark() ~= "" then
    local entity = Z.EntityMgr:GetEntity(charUuid)
    if entity then
      entity:SetLuaAttr(Z.LocalAttr.EFriendRemark, friendData:GetRemark())
    end
  end
end
local asyncGetFriendBaseInfo = function(charId, cancelToken)
  local sendData = {}
  sendData.charId = charId
  local ret = worldProxy.GetFriendBaseInfo(sendData, cancelToken)
  if ret.baseInfo then
    local baseInfo = ret.baseInfo
    friendMainData:Clear()
    refreshBothWayFirneds(baseInfo.friendList, true, true)
    refreshCustomGroups(baseInfo.groupIdList)
    local chatSettingData = Z.DataMgr.Get("chat_setting_data")
    if chatSettingData:GetFriendApply() then
      refreshApplications(baseInfo.applicationList, true)
    end
    refreshGroupSort(baseInfo.groupSort)
  end
  refreshFriendLiness(ret.friendlinessList)
  refreshTotalFriendLiness(ret.totalFriendliness)
  Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendAddressTab, table.zcount(friendMainData:GetApplicationList()))
  return ret
end
local asyncGetFriendBaseData = function()
  if friendMainData.IsCache == false then
    local charId = Z.ContainerMgr.CharSerialize.charId
    local ret = asyncGetFriendBaseInfo(charId, friendMainData.CancelSource:CreateToken())
    if ret.errCode == 0 then
      friendMainData.IsCache = true
      Z.EventMgr:Dispatch(Z.ConstValue.Friend.RefreshFriendBaseDataCache)
    end
  end
end
local asyncFriend = function(operationMap, syncData)
  if #operationMap == 1 and operationMap[Z.PbEnum("EFriendSyncDataType", "DataTypeShowInfo")] then
    return
  end
  local groupSortRefresh = false
  local friendRefresh = false
  local applicationRefresh = false
  local selfPersionStateRefresh = false
  for k, isAdd in pairs(operationMap) do
    if k == Z.PbEnum("EFriendSyncDataType", "DataTypeFriendList") then
      if isAdd == 0 then
        refreshBothWayFirneds(syncData.baseInfo.friendList, true)
      else
        refreshBothWayFirneds(syncData.baseInfo.friendList, false)
      end
      friendRefresh = true
    elseif k == Z.PbEnum("EFriendSyncDataType", "DataTypeGroupList") then
      if isAdd == 0 then
        refreshCustomGroups(syncData.baseInfo.groupIdList)
      else
        for groupID, _ in pairs(syncData.baseInfo.groupIdList) do
          friendMainData:RemoveCustomGroup(groupID)
          selfPersionStateRefresh = true
        end
      end
      friendRefresh = true
      groupSortRefresh = true
    elseif k == Z.PbEnum("EFriendSyncDataType", "DataTypeApplicationList") then
      if isAdd == 0 then
        local chatSettingData = Z.DataMgr.Get("chat_setting_data")
        if chatSettingData:GetFriendApply() then
          refreshApplications(syncData.baseInfo.applicationList)
          Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendAddressTab, table.zcount(friendMainData:GetApplicationList()))
        end
      else
        for _, applicationInfo in pairs(syncData.baseInfo.applicationList) do
          friendMainData:RemoveApplicationFriendData(applicationInfo.charId)
          Z.EventMgr:Dispatch(Z.ConstValue.InvitationRemoveTipsUnit, E.InvitationTipsType.FriendApply, applicationInfo.charId)
        end
        Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendAddressTab, table.zcount(friendMainData:GetApplicationList()), true)
      end
      applicationRefresh = true
    elseif k == Z.PbEnum("EFriendSyncDataType", "DataTypeGroupSort") then
      refreshGroupSort(syncData.baseInfo.groupSort)
      friendRefresh = true
      groupSortRefresh = true
    end
  end
  if true == groupSortRefresh then
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendGroupRefresh)
  end
  if true == friendRefresh then
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendRefresh)
  end
  if true == applicationRefresh then
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendApplicationRefresh)
  end
  if true == selfPersionStateRefresh then
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendSelfPersonalStateRefresh)
  end
end
local updateSelfFriendLinessData = function(totalLevel, totalExp, todayAddExp, updateTimeStamp, friendChangeList)
  friendMainData:SetFriendlinessLevel(totalLevel)
  friendMainData:SetFriendlinessExp(totalExp)
  friendMainData:SetFriendlinessTodayAddExp(todayAddExp)
  friendMainData:SetFriendlinessUpdateTimeStamp(updateTimeStamp)
  friendMainData:UpdateFriendLinessExpChange(friendChangeList)
  Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendLinessChange)
end
local setFriendRemarks = function(charId, remark, cancelToken)
  if not checkCharIdVaild(charId) then
    return
  end
  local sendData = {}
  sendData.charId = charId
  sendData.remark = remark
  local ret = worldProxy.SetFriendRemarks(sendData, cancelToken)
  return ret
end
local deleteFriend = function(charList, cancelToken)
  for i = 1, #charList do
    if not checkCharIdVaild(charList[i]) then
      return
    end
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if not gotoFuncVM.CheckFuncCanUse(E.FunctionID.DeleteFriend) then
    return
  end
  local sendData = {}
  sendData.charList = {}
  sendData.charList.memberList = charList
  local errCode = worldProxy.DeleteFriend(sendData, cancelToken)
  logErrCode(errCode)
  return errCode
end
local asyncChangeGroup = function(charId, targetGroupId, cancelToken)
  if not checkCharIdVaild(charId) then
    return
  end
  local sendData = {}
  sendData.charId = charId
  sendData.targetGroupId = targetGroupId
  local errCode = worldProxy.ChangeGroup(sendData, cancelToken)
  logErrCode(errCode)
  return errCode
end
local asyncChangeGroupName = function(groupId, groupName, cancelToken)
  local sendData = {}
  sendData.groupId = groupId
  sendData.newName = groupName
  local errCode = worldProxy.ChangeGroupName(sendData, cancelToken)
  logErrCode(errCode)
  return errCode
end
local asyncCreateGroup = function(groupName, cancelToken)
  local sendData = {}
  sendData.groupName = groupName
  local errCode = worldProxy.CreateGroup(sendData, cancelToken)
  if errCode ~= Z.PbEnum("EErrorCode", "ErrIllegalCharacter") then
    logErrCode(errCode)
  end
  return errCode
end
local asyncDelectGroup = function(groupID, cancelToken)
  local sendData = {}
  sendData.groupId = groupID
  local errCode = worldProxy.DeleteGroup(sendData, cancelToken)
  logErrCode(errCode)
  return errCode
end
local asyncSetRemind = function(charId, isRemind, cancelToken)
  if not checkCharIdVaild(charId) then
    return
  end
  local sendData = {}
  sendData.charId = charId
  sendData.isRemind = isRemind
  local errCode = worldProxy.SetRemind(sendData, cancelToken)
  logErrCode(errCode)
  return errCode
end
local asyncSetTop = function(charId, isTop, cancelToken)
  if not checkCharIdVaild(charId) then
    return
  end
  local sendData = {}
  sendData.charId = charId
  sendData.isTop = isTop
  local errCode = worldProxy.SetTop(sendData, cancelToken)
  logErrCode(errCode)
  return errCode
end
local asyncSetPersonalState = function(state, isRemove)
  worldProxy.SetPersonalState(state, isRemove)
end
local getFriendsStatus = function(offlineTime, personalState)
  local statusCfgData = Z.TableMgr.GetTable("ChatStatusTableMgr")
  if offlineTime ~= 0 then
    return statusCfgData.GetRow(E.PersonalizationStatus.EStatusOutLine)
  end
  local cfgId = 1
  for key, value in pairs(personalState) do
    if value ~= 0 then
      local lastStatusCfg = statusCfgData.GetRow(cfgId)
      local nowStatusCfg = statusCfgData.GetRow(value)
      cfgId = lastStatusCfg and nowStatusCfg and lastStatusCfg.Priority < nowStatusCfg.Priority and value or cfgId
    end
  end
  return statusCfgData.GetRow(cfgId)
end
local openView = function(data)
  Z.UIMgr:OpenView("friends_set_window", data)
end
local closeView = function()
  Z.UIMgr:CloseView("friends_set_window")
end
local asyncSetSignature = function(signature, cancelSource)
  local data = {}
  data.signature = signature
  worldProxy.SetSignature(data, cancelSource:CreateToken())
end
local asyncSetHobbyMark = function(hobbyMark, cancelSource)
  local data = {}
  data.markList = hobbyMark
  worldProxy.SetHobbyMark(data, cancelSource:CreateToken())
end
local asyncSetTimeMark = function(timeMark, cancelSource)
  local data = {}
  data.markList = timeMark
  worldProxy.SetTimeMark(data, cancelSource:CreateToken())
end
local asyncSetshowPicture = function(url, cancelSource)
  local data = {}
  data.url = url
  worldProxy.SetshowPicture(data, cancelSource:CreateToken())
end
local asyncGetFriendShowInfo = function(charId, cancelSource)
  local data = {}
  data.charId = charId
  local ref = worldProxy.GetPersonalInfo(data, cancelSource:CreateToken())
  if ref.info then
    return ref.info
  end
end
local asyncGetSuggestionList = function(cancelSource)
  local data = {}
  data.charId = Z.ContainerMgr.CharSerialize.charId
  local ret = worldProxy.GetSuggestionList(data, cancelSource:CreateToken())
  if ret.errCode == 0 then
    refreshSuggestionList(ret.suggestionList)
  end
end
local openPrivateChat = function(charId)
  friendMainData:SetFriendViewType(E.FriendViewType.Chat)
  friendMainData:SetChatSelectCharId(charId)
  local chatMainVm = Z.VMMgr.GetVM("chat_main")
  chatMainVm.CheckPrivateChatCharId(charId)
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.OpenPrivateChat, charId)
  Z.VMMgr.GetVM("socialcontact_main").OpenFriendView()
end
local rewardPersonalFriendlinessLv = function(charId, level, cancelToken)
  local request = {}
  request.friendId = charId
  request.level = level
  local ret = worldProxy.RewardPersonalFriendlinessLv(request, cancelToken)
  return ret
end
local rewardTotalFriendlinessLv = function(level, cancelToken)
  local request = {}
  request.level = level
  local ret = worldProxy.RewardTotalFriendlinessLv(request, cancelToken)
  return ret
end
local updateFriendliness = function(charId, cancelToken)
  local request = {}
  request.friendIds = {charId}
  local ret = worldProxy.GetFriendliness(request, cancelToken)
  if ret.errCode == 0 then
    refreshTotalFriendLiness(ret.totalFriendliness)
    refreshFriendLiness(ret.friendlinessList)
  end
end
local getPlayerShowName = function(charId, playerName)
  local friendData = friendMainData:GetFriendDataByCharId(charId)
  if friendData and friendData:GetRemark() and friendData:GetRemark() ~= "" then
    return friendData:GetRemark()
  end
  return playerName
end
local ret = {
  UpdateGroupShowList = updateGroupShowList,
  GetFriendAndGroupList = getFriendAndGroupList,
  AsyncSendAddFriend = asyncSendAddFriend,
  SearchFriend = searchFriend,
  AsyncProcessAddRequest = asyncProcessAddRequest,
  AsyncGetFriendBaseData = asyncGetFriendBaseData,
  SetFriendRemarks = setFriendRemarks,
  DeleteFriend = deleteFriend,
  AsyncChangeGroup = asyncChangeGroup,
  AsyncChangeGroupName = asyncChangeGroupName,
  AsyncCreateGroup = asyncCreateGroup,
  AsyncDelectGroup = asyncDelectGroup,
  AsyncSetGroupSort = asyncSetGroupSort,
  AsyncSetRemind = asyncSetRemind,
  AsyncSetTop = asyncSetTop,
  AsyncSetPersonalState = asyncSetPersonalState,
  AsyncFriend = asyncFriend,
  UpdateSelfFriendLinessData = updateSelfFriendLinessData,
  GetSearchDataList = getSearchDataList,
  GetFriendsStatus = getFriendsStatus,
  OpenView = openView,
  CloseView = closeView,
  OpenSetView = openSetView,
  CloseSetView = closeSetView,
  AsyncSetSignature = asyncSetSignature,
  AsyncSetHobbyMark = asyncSetHobbyMark,
  AasyncSetTimeMark = asyncSetTimeMark,
  AsyncSetshowPicture = asyncSetshowPicture,
  AsyncGetFriendShowInfo = asyncGetFriendShowInfo,
  AsyncGetSuggestionList = asyncGetSuggestionList,
  OpenPrivateChat = openPrivateChat,
  AsyncInitInfo = asyncInitInfo,
  AsyncUpdataPrivateChat = asyncUpdataPrivateChat,
  AsyncRefreshBlacks = asyncRefreshBlacks,
  CheckFriendRemark = checkFriendRemark,
  RewardPersonalFriendlinessLv = rewardPersonalFriendlinessLv,
  RefreshTotalFriendLiness = refreshTotalFriendLiness,
  RewardTotalFriendlinessLv = rewardTotalFriendlinessLv,
  UpdateFriendliness = updateFriendliness,
  GetPlayerShowName = getPlayerShowName
}
return ret
