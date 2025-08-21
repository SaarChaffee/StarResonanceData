local super = require("ui.model.data_base")
local UnionData = class("UnionData", super)

function UnionData:ctor()
  super.ctor(self)
  self.UnionInfo = nil
  self.RecruitInfo = nil
  self.MemberDict = nil
  self.BuildInfo = {}
  self.BuildBuffInfo = {}
  self.ResourceDict = {}
  self.CacheUnionList = {}
  self.SpeedUpTimes = 0
  self.ApplyNum = 0
  self.collectionUnionList_ = {}
  self.collectionUnionDict_ = {}
  self.lastServerQueryTimeDict_ = {}
  self.unionHuntProgressDict_ = nil
  self.unitHuntRankInfo_ = {}
  self.unionActiveRewardStateDict_ = {}
  self.huntRankInfoListMaxCount_ = Z.UnionActivityConfig.HuntListLimitNum
  self.unionCrowFund_ = nil
  self.unionCrowMemberList_ = nil
  self:ResetUnionSDKGroupData()
end

function UnionData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self:InitUnionUpgradeConfig()
end

function UnionData:ClearUnionCacheData()
  self.UnionInfo = nil
  self.RecruitInfo = nil
  self.MemberDict = nil
  self.BuildInfo = {}
  self.BuildBuffInfo = {}
  self.ResourceDict = {}
  self.unionActiveRewardStateDict_ = {}
  self.unionHuntProgressDict_ = nil
  self.unitHuntRankInfo_ = {}
  self.ApplyNum = 0
  self:ClearUnionItemCount()
  self:ResetUnionSDKGroupData()
end

function UnionData:Clear()
  self:ClearUnionCacheData()
  self.CacheUnionList = {}
  self.collectionUnionList_ = {}
  self.collectionUnionDict_ = {}
  self.lastServerQueryTimeDict_ = {}
end

function UnionData:UnInit()
  self.CancelSource:Recycle()
end

function UnionData:getCompareFunction(sortMode, orderMode)
  if sortMode == nil or orderMode == nil then
    return nil
  end
  local func
  if sortMode == E.UnionMemberSortMode.None and orderMode == E.UnionMemberOrderMode.None then
    function func(l, r)
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.Name and orderMode == E.UnionMemberOrderMode.Ascending then
    function func(l, r)
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.Name and orderMode == E.UnionMemberOrderMode.Descending then
    function func(l, r)
      return l.socialData.basicData.showId > r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.Position and orderMode == E.UnionMemberOrderMode.Ascending then
    function func(l, r)
      if l.baseData.officialId ~= r.baseData.officialId then
        return l.baseData.officialId < r.baseData.officialId
      end
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.Position and orderMode == E.UnionMemberOrderMode.Descending then
    function func(l, r)
      if l.baseData.officialId ~= r.baseData.officialId then
        return l.baseData.officialId > r.baseData.officialId
      end
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.RoleLevel and orderMode == E.UnionMemberOrderMode.Ascending then
    function func(l, r)
      if l.socialData.basicData.level ~= r.socialData.basicData.level then
        return l.socialData.basicData.level < r.socialData.basicData.level
      end
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.RoleLevel and orderMode == E.UnionMemberOrderMode.Descending then
    function func(l, r)
      if l.socialData.basicData.level ~= r.socialData.basicData.level then
        return l.socialData.basicData.level > r.socialData.basicData.level
      end
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.Contribution and orderMode == E.UnionMemberOrderMode.Ascending then
    function func(l, r)
      if l.baseData.historyActivePoints ~= r.baseData.historyActivePoints then
        return l.baseData.historyActivePoints < r.baseData.historyActivePoints
      end
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.Contribution and orderMode == E.UnionMemberOrderMode.Descending then
    function func(l, r)
      if l.baseData.historyActivePoints ~= r.baseData.historyActivePoints then
        return l.baseData.historyActivePoints > r.baseData.historyActivePoints
      end
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.OfflineTime and orderMode == E.UnionMemberOrderMode.Ascending then
    function func(l, r)
      if l.socialData.basicData.offlineTime ~= r.socialData.basicData.offlineTime then
        if l.socialData.basicData.offlineTime ~= 0 and r.socialData.basicData.offlineTime == 0 then
          return false
        elseif l.socialData.basicData.offlineTime == 0 and r.socialData.basicData.offlineTime ~= 0 then
          return true
        end
        return l.socialData.basicData.offlineTime > r.socialData.basicData.offlineTime
      end
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  elseif sortMode == E.UnionMemberSortMode.OfflineTime and orderMode == E.UnionMemberOrderMode.Descending then
    function func(l, r)
      if l.socialData.basicData.offlineTime ~= r.socialData.basicData.offlineTime then
        if l.socialData.basicData.offlineTime ~= 0 and r.socialData.basicData.offlineTime == 0 then
          return true
        elseif l.socialData.basicData.offlineTime == 0 and r.socialData.basicData.offlineTime ~= 0 then
          return false
        end
        return l.socialData.basicData.offlineTime < r.socialData.basicData.offlineTime
      end
      return l.socialData.basicData.showId < r.socialData.basicData.showId
    end
  end
  return func
end

function UnionData:GetDefaultSortMemberListData()
  if self.MemberDict == nil then
    return {}
  end
  local myCharId = Z.ContainerMgr.CharSerialize.charBase.charId
  local onlineList = {}
  local offlineList = {}
  for charId, memberData in pairs(self.MemberDict) do
    if charId ~= myCharId then
      if memberData.socialData.basicData.offlineTime == 0 then
        onlineList[#onlineList + 1] = memberData
      else
        offlineList[#offlineList + 1] = memberData
      end
    end
  end
  local compFunc = self:getCompareFunction(E.UnionMemberSortMode.OfflineTime, E.UnionMemberOrderMode.Ascending)
  table.sort(onlineList, compFunc)
  table.sort(offlineList, compFunc)
  local memberList = {}
  memberList[#memberList + 1] = self.MemberDict[myCharId]
  for _, v in pairs(onlineList) do
    memberList[#memberList + 1] = v
  end
  for _, v in pairs(offlineList) do
    memberList[#memberList + 1] = v
  end
  return memberList
end

function UnionData:GetMemberListData(sortMode, orderMode)
  if self.MemberDict == nil then
    return {}
  end
  if sortMode == nil then
    sortMode = E.UnionMemberSortMode.None
  end
  if orderMode == nil then
    orderMode = E.UnionMemberOrderMode.None
  end
  if sortMode == E.UnionMemberSortMode.None or orderMode == E.UnionMemberOrderMode.None then
    return self:GetDefaultSortMemberListData()
  end
  local memberList = {}
  for _, v in pairs(self.MemberDict) do
    memberList[#memberList + 1] = v
  end
  local compFunc = self:getCompareFunction(sortMode, orderMode)
  table.sort(memberList, compFunc)
  return memberList
end

function UnionData:GetSearchMemberListData(searchStr, sortMode, orderMode)
  local showId = tonumber(searchStr)
  local exactMatchList = {}
  local partsMatchList = {}
  for _, v in pairs(self.MemberDict) do
    if v.socialData.basicData.showId == showId then
      exactMatchList[#exactMatchList + 1] = v
    elseif v.socialData.basicData.name == searchStr then
      exactMatchList[#exactMatchList + 1] = v
    elseif string.find(v.socialData.basicData.name, searchStr, 1, true) then
      partsMatchList[#partsMatchList + 1] = v
    end
  end
  local searchList = table.zmerge(exactMatchList, partsMatchList)
  local compFunc = self:getCompareFunction(sortMode, orderMode)
  table.sort(searchList, compFunc)
  return searchList
end

function UnionData:GetCollectUnionList()
  return self.collectionUnionList_
end

function UnionData:ClearCollectUnionList()
  self.collectionUnionList_ = {}
end

function UnionData:AddCollectUnion(unionListData)
  if self.collectionUnionDict_[unionListData.baseInfo.Id] then
    self:RemoveCollectUnion(unionListData.baseInfo.Id)
  end
  table.insert(self.collectionUnionList_, unionListData)
  self.collectionUnionDict_[unionListData.baseInfo.Id] = unionListData
end

function UnionData:RemoveCollectUnion(unionId)
  if self.collectionUnionDict_[unionId] then
    for i, data in ipairs(self.collectionUnionList_) do
      if data.baseInfo.Id == unionId then
        table.remove(self.collectionUnionList_, i)
        break
      end
    end
    self.collectionUnionDict_[unionId] = nil
  end
end

function UnionData:IsCanCollectUnion()
  local maxNum = Z.Global.UnionCollectMax
  if maxNum <= #self.collectionUnionList_ then
    Z.TipsVM.ShowTips(1000546)
    return false
  else
    return true
  end
end

function UnionData:IsUnionCollection(unionId)
  return self.collectionUnionDict_ and self.collectionUnionDict_[unionId] ~= nil
end

function UnionData:SetUnionHuntProgressInfo(data)
  self.unionHuntProgressDict_ = data
end

function UnionData:SetUnionHuntProgressInfoByID(activityId, progressNum)
  local data = self.unionHuntProgressDict_
  if data then
    local awardList = data.award
    awardList[#awardList + 1] = progressNum
  end
end

function UnionData:GetUnionHuntProgressInfo(activityId)
  local d_ = self.unionHuntProgressDict_
  if d_ and d_.activityId == activityId then
    return d_
  end
  return nil
end

function UnionData:SetUnionHuntRankInfo(data)
  self.unitHuntRankInfo_ = data
end

function UnionData:GetUnionHuntRankInfo()
  local result = {}
  local count = #self.unitHuntRankInfo_
  if count > self.huntRankInfoListMaxCount_ then
    for i = 1, self.huntRankInfoListMaxCount_ do
      local value = self.unitHuntRankInfo_[i]
      result[#result + 1] = value
    end
  else
    result = self.unitHuntRankInfo_
  end
  table.sort(result, function(a, b)
    return a.rankIdx < b.rankIdx
  end)
  return result
end

function UnionData:InitUnionUpgradeConfig()
  self.buildUpgradeConfigDict_ = {}
  self.buildUpgradePurviewDict_ = {}
  self.buildPurviewInfoDict_ = {}
  local unionUpradingTableMgr = Z.TableMgr.GetTable("UnionUpradingTableMgr")
  local configList = unionUpradingTableMgr:GetDatas()
  for k, v in pairs(configList) do
    if self.buildUpgradeConfigDict_[v.BuildingId] == nil then
      self.buildUpgradeConfigDict_[v.BuildingId] = {}
    end
    self.buildUpgradeConfigDict_[v.BuildingId][v.Level] = v
    if self.buildUpgradePurviewDict_[v.BuildingId] == nil then
      self.buildUpgradePurviewDict_[v.BuildingId] = {}
    end
    for index, purviewInfo in ipairs(v.Purview) do
      local purviewId = purviewInfo[1]
      local purviewValue = 0
      local purviewValueCount = #purviewInfo
      if purviewValueCount == 2 then
        purviewValue = purviewInfo[2]
      elseif 2 < purviewValueCount then
        purviewValue = purviewInfo
      end
      if self.buildUpgradePurviewDict_[v.BuildingId][purviewId] == nil then
        self.buildUpgradePurviewDict_[v.BuildingId][purviewId] = {}
      end
      if self.buildPurviewInfoDict_[purviewId] == nil then
        self.buildPurviewInfoDict_[purviewId] = {}
      end
      table.insert(self.buildUpgradePurviewDict_[v.BuildingId][purviewId], {
        level = v.Level,
        value = purviewValue
      })
      if purviewId == E.UnionBuildEffectDef.GridSumNum or purviewId == E.UnionBuildEffectDef.UnlockEffectId then
        self.buildPurviewInfoDict_[purviewId][purviewValue] = v
      end
    end
  end
end

function UnionData:GetUnionUpgradeConfigList(buildId)
  return self.buildUpgradeConfigDict_[buildId]
end

function UnionData:GetUnionUpgradeConfigByLv(buildId, buildLv)
  local levelConfig = self:GetUnionUpgradeConfigList(buildId)
  if levelConfig and levelConfig[buildLv] then
    return levelConfig[buildLv]
  end
end

function UnionData:GetUnionUpgradeScreenConfigByLv(levelConfig)
end

function UnionData:GetUnionUpgradeDiffPurview(buildId, buildLv)
  local resultList = {}
  local buffList = {}
  local buildConfig = self:GetUnionUpgradeConfigByLv(buildId, buildLv)
  if buildConfig then
    for index, purviewInfo in ipairs(buildConfig.Purview) do
      local purviewId = purviewInfo[1]
      local purviewValue = 0
      local purviewValueCount = #purviewInfo
      if purviewValueCount == 2 then
        purviewValue = purviewInfo[2]
      elseif 2 < purviewValueCount then
        purviewValue = purviewInfo
      end
      if purviewId == E.UnionBuildEffectDef.AddMenSumNum or purviewId == E.UnionBuildEffectDef.GridSumNum then
        local purviewList = self.buildUpgradePurviewDict_[buildId][purviewId]
        if purviewList then
          for i = #purviewList, 1, -1 do
            local info = purviewList[i]
            if info.level == buildLv then
              local resultInfo = {
                id = purviewId,
                curValue = info.value,
                lastValue = 0
              }
              if purviewList[i - 1] then
                resultInfo.lastValue = purviewList[i - 1].value
              end
              table.insert(resultList, resultInfo)
              break
            end
          end
        end
      elseif purviewId == E.UnionBuildEffectDef.UnlockEffectId then
        table.insert(buffList, purviewValue)
      else
        table.insert(resultList, {id = purviewId, curValue = purviewValue})
      end
    end
    if 0 < #buffList then
      table.insert(resultList, {
        id = E.UnionBuildEffectDef.UnlockEffectId,
        curValue = buffList
      })
    end
  end
  return resultList
end

function UnionData:GetBuildPurviewInfoDict(purviewId)
  return self.buildPurviewInfoDict_[purviewId]
end

function UnionData:SetUnionBuffInfo()
end

function UnionData:GetLastServerQueryTime(key)
  return self.lastServerQueryTimeDict_[key] or 0
end

function UnionData:SetLastServerQueryTime(key)
  self.lastServerQueryTimeDict_[key] = Z.ServerTime:GetServerTime()
end

function UnionData:SetUnionActiveRewardState(id, isHadGet)
  self.unionActiveRewardStateDict_[id] = isHadGet
end

function UnionData:IsUnionActiveHadGet(id)
  return self.unionActiveRewardStateDict_[id] or false
end

function UnionData:SetUnionGrowData(data)
  self.unionCrowFund_ = data
end

function UnionData:GetUnionGrowData()
  return self.unionCrowFund_
end

function UnionData:SetUnionGrowMemberData(data)
  self.unionCrowMemberList_ = data
end

function UnionData:GetUnionGrowMemberData()
  return self.unionCrowMemberList_
end

function UnionData:SetHuntRecommendRedChecked(checked)
  self.recommendRedChecked_ = checked
  if checked then
    Z.LocalUserDataMgr.SetLongByLua(E.LocalUserDataType.Character, "UnionHuntActivityChecked", math.floor(Z.TimeTools.Now() / 1000))
  end
end

function UnionData:SetSignRecommendRedChecked(checked)
  self.recommendSignRedChecked_ = checked
  if checked then
    Z.LocalUserDataMgr.SetLongByLua(E.LocalUserDataType.Character, "UnionSignActivityChecked", math.floor(Z.TimeTools.Now() / 1000))
  end
end

function UnionData:SignRecommendRedChecked()
  local lastCheckedTime = Z.LocalUserDataMgr.GetLongByLua(E.LocalUserDataType.Character, "UnionSignActivityChecked", 0)
  if Z.TimeTools.CheckIsSameDay(math.floor(Z.TimeTools.Now() / 1000), lastCheckedTime) then
    return true
  end
  return self.recommendSignRedChecked_
end

function UnionData:HuntRecommendRedChecked()
  local lastCheckedTime = Z.LocalUserDataMgr.GetLongByLua(E.LocalUserDataType.Character, "UnionHuntActivityChecked", 0)
  if Z.TimeTools.CheckIsSameDay(math.floor(Z.TimeTools.Now() / 1000), lastCheckedTime) then
    return true
  end
  return self.recommendRedChecked_
end

function UnionData:ClearUnionItemCount()
  local itemsData = Z.DataMgr.Get("items_data")
  for k, v in pairs(E.UnionResourceId) do
    itemsData:SetItemTotalCount(v, 0)
  end
end

function UnionData:SetUnionAllRiadBossData(unionBossData)
  self.unionBossData_ = unionBossData
end

function UnionData:GetUnionAllRiadBossData(bossId)
  if not self.unionBossData_ then
    return
  end
  if not self.unionBossData_[bossId] then
    return 0
  end
  return self.unionBossData_[bossId].killCnt
end

function UnionData:ResetUnionSDKGroupData()
  self.SDKGroupInfo = {
    BindState = 0,
    GroupId = "",
    GroupName = "",
    GroupRelation = 0
  }
end

return UnionData
