local worldProxy = require("zproxy.world_proxy")
local enterdungeonsceneVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
local entChar = Z.PbEnum("EEntityType", "EntChar")
local SettlementNodeIndex = Panda.ZGame.SettlementNodeIndex
local UnionVM = {}
local Ignore_Error_Msg_Id = {
  [4408] = true,
  [4430] = true,
  [4433] = true
}
local TENCENT_DEFINE = require("ui.model.tencent_define")
local SDK_GROUP_CHANNEL = Bokura.Plugins.Tencent.Group.GroupChannel
local cjson = require("cjson")

function UnionVM:CachePlayerUnionInfo(unionInfo, recruitInfo)
  local unionData = Z.DataMgr.Get("union_data")
  if unionInfo == nil or unionInfo.baseInfo.Id == 0 then
    unionData:ClearUnionCacheData()
  else
    unionData.UnionInfo = unionInfo
    if recruitInfo ~= nil then
      unionData.RecruitInfo = recruitInfo
    end
    self:HandleUnionOfficials()
  end
end

function UnionVM:CacheUnionMember(memberList, memberSocialList)
  local unionData = Z.DataMgr.Get("union_data")
  unionData.MemberDict = {}
  local totalCount = #memberList
  local zCharIdList = ZUtil.Pool.Collections.ZList_long.Rent(totalCount)
  for index, memberData in ipairs(memberList) do
    local socialData = memberSocialList[index]
    unionData.MemberDict[memberData.memId] = {baseData = memberData, socialData = socialData}
    zCharIdList:Add(socialData.basicData.charID)
  end
  Z.LuaDataMgr:SyncAllUnionMemberCharId(zCharIdList)
  ZUtil.Pool.Collections.ZList_long.Return(zCharIdList)
  self:CheckApplyRedNum()
end

function UnionVM:CacheBuildInfo(unionBuildingInfos)
  local unionData = Z.DataMgr.Get("union_data")
  if unionBuildingInfos ~= nil then
    unionData.BuildInfo = {}
    for id, info in pairs(unionBuildingInfos) do
      unionData.BuildInfo[id] = info
    end
  end
end

function UnionVM:CacheBuildBuffInfo(unionBuffInfoList)
  local unionData = Z.DataMgr.Get("union_data")
  if unionBuffInfoList ~= nil then
    unionData.BuildBuffInfo = {}
    for id, info in ipairs(unionBuffInfoList) do
      if info.effectBuffId ~= 0 then
        unionData.BuildBuffInfo[info.buffPos + 1] = info
      end
    end
  end
end

function UnionVM:CacheResourceInfo(unionResourceLib, isShowTip)
  local unionData = Z.DataMgr.Get("union_data")
  local itemsData = Z.DataMgr.Get("items_data")
  if unionResourceLib ~= nil then
    for id, unionResource in pairs(unionResourceLib) do
      local lastCount = self:GetUnionResourceCount(id)
      local changeCount = unionResource.sumNum - lastCount
      unionData.ResourceDict[id] = unionResource
      itemsData:SetItemTotalCount(id, unionResource.sumNum)
      if isShowTip and 0 < changeCount then
        self:AddUnionResourceChangeTip(id, changeCount)
      end
    end
  end
end

function UnionVM:AddUnionResourceChangeTip(configId, changeCount)
  local itemData = {
    uuid = 0,
    configId = configId,
    count = changeCount
  }
  Z.ItemEventMgr.AddItemGetTipsData(itemData)
end

function UnionVM:HandleActiveRewardInfo(receivedAwardIdList, isResetData)
  local unionData = Z.DataMgr.Get("union_data")
  if isResetData then
    unionData.unionActiveRewardStateDict_ = {}
  end
  if receivedAwardIdList ~= nil then
    for i, id in ipairs(receivedAwardIdList) do
      unionData:SetUnionActiveRewardState(id, true)
    end
  end
end

function UnionVM:HandleUnionOfficials()
  local unionData = Z.DataMgr.Get("union_data")
  for id, officialData in pairs(unionData.UnionInfo.officials) do
    local config = Z.TableMgr.GetTable("UnionManageTableMgr").GetRow(id)
    if officialData.Name == "" then
      officialData.Name = config.Position
    end
    for i = 1, #config.UnionManage do
      local powerId = config.UnionManage[i].X
      local defaultValue = config.UnionManage[i].Z == 1
      local powers = officialData.power
      if powers[powerId] == nil then
        powers[powerId] = defaultValue
      end
    end
  end
  self:CheckApplyRedNum()
end

function UnionVM:UpdateUnionOfficials(officials)
  local unionData = Z.DataMgr.Get("union_data")
  for _, officialData in pairs(officials) do
    if officialData.Name == "" then
      local config = Z.TableMgr.GetRow("UnionManageTableMgr", officialData.officialId)
      officialData.Name = config and config.Position or ""
    end
    unionData.UnionInfo.officials[officialData.officialId] = officialData
  end
  self:CheckApplyRedNum()
end

function UnionVM:UpdateUnionOfficialsByNotify(officialData)
  local unionData = Z.DataMgr.Get("union_data")
  unionData.UnionInfo.officials[officialData.officialId] = officialData
  self:CheckApplyRedNum()
end

function UnionVM:CanPowerModify(officialId, powerId)
  local enableModify = false
  local config = Z.TableMgr.GetTable("UnionManageTableMgr").GetRow(officialId)
  for i = 1, #config.UnionManage do
    if powerId == config.UnionManage[i].X then
      enableModify = config.UnionManage[i].Y == 1
    end
  end
  return enableModify
end

function UnionVM:UpdateUnionBase(unionBaseData)
  if unionBaseData == nil or unionBaseData.Id == 0 then
    return
  end
  local unionData = Z.DataMgr.Get("union_data")
  unionData.UnionInfo.baseInfo = unionBaseData
  Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.RefreshUnionBaseData)
end

function UnionVM:GetPlayerUnionId()
  local unionData = Z.DataMgr.Get("union_data")
  local unionId = 0
  if unionData.UnionInfo ~= nil then
    unionId = unionData.UnionInfo.baseInfo.Id
  end
  return unionId
end

function UnionVM:GetPlayerUnionName()
  local unionData = Z.DataMgr.Get("union_data")
  if unionData.UnionInfo == nil then
    return ""
  else
    return unionData.UnionInfo.baseInfo.Name
  end
end

function UnionVM:GetPlayerUnionInfo()
  local unionData = Z.DataMgr.Get("union_data")
  return unionData.UnionInfo
end

function UnionVM:GetPlayerOfficialId()
  local unionData = Z.DataMgr.Get("union_data")
  if unionData.MemberDict == nil then
    return 0
  end
  local charId = Z.ContainerMgr.CharSerialize.charBase.charId
  if not unionData.MemberDict[charId] then
    return 0
  end
  local officialId = unionData.MemberDict[charId].baseData.officialId
  return officialId
end

function UnionVM:GetOnlineMemberList()
  local unionData = Z.DataMgr.Get("union_data")
  local onlineMemberList = {}
  if unionData.MemberDict ~= nil then
    for id, data in pairs(unionData.MemberDict) do
      if data.socialData.basicData.offlineTime == 0 then
        onlineMemberList[#onlineMemberList + 1] = data
      end
    end
  end
  return onlineMemberList
end

function UnionVM:UpdateOnlineMemberList(memberIdList, memberTimeList)
  local tempMemberDict = {}
  for i, charId in ipairs(memberIdList) do
    if memberTimeList[i] then
      tempMemberDict[charId] = memberTimeList[i]
    end
  end
  local unionData = Z.DataMgr.Get("union_data")
  if unionData.MemberDict ~= nil then
    for id, data in pairs(unionData.MemberDict) do
      local time = tempMemberDict[data.socialData.basicData.charID]
      if time ~= nil then
        unionData.MemberDict[id].socialData.basicData.offlineTime = time
      end
    end
  end
end

function UnionVM:GetOnlineMemberCount()
  local unionData = Z.DataMgr.Get("union_data")
  local onlineMemberCount = 0
  if unionData.MemberDict ~= nil then
    for id, data in pairs(unionData.MemberDict) do
      if data.socialData.basicData.offlineTime == 0 then
        onlineMemberCount = onlineMemberCount + 1
      end
    end
  end
  return onlineMemberCount
end

function UnionVM:GetLogoData(ids)
  if #ids < 5 then
    return nil
  end
  local iconTableInfo = Z.TableMgr.GetTable("UnionIconTableMgr")
  local frontColorGroupConfig = iconTableInfo.GetRow(ids[1])
  if frontColorGroupConfig == nil then
    logError("\232\161\168UnionIconTable\228\184\173\228\184\141\229\173\152\229\156\168\230\149\176\230\141\174" .. ids[1])
    return nil
  end
  local backColorGroupConfig = iconTableInfo.GetRow(ids[3])
  if backColorGroupConfig == nil then
    logError("\232\161\168UnionIconTable\228\184\173\228\184\141\229\173\152\229\156\168\230\149\176\230\141\174" .. ids[3])
    return nil
  end
  local frontColor = self:GetRGBColorById(frontColorGroupConfig.Colour, ids[2])
  local backColor = self:GetRGBColorById(backColorGroupConfig.Colour, ids[4])
  local logoData = {}
  logoData.frontIconId = ids[1]
  logoData.frontIconColor = frontColor
  logoData.backIconId = ids[3]
  logoData.backIconColor = backColor
  logoData.backIconTexId = ids[5]
  return logoData
end

function UnionVM:CheckPlayerPower(powerId)
  local unionData = Z.DataMgr.Get("union_data")
  if unionData.UnionInfo == nil or unionData.UnionInfo.baseInfo.Id == 0 then
    return false
  end
  local officialId = self:GetPlayerOfficialId()
  if officialId == 0 then
    return false
  end
  local officialsData = unionData.UnionInfo.officials
  if officialsData[officialId] == nil then
    return false
  end
  local powers = officialsData[officialId].power
  if powers[powerId] == nil then
    return false
  end
  return powers[powerId]
end

function UnionVM:GetUnionMemberData(charId)
  local unionData = Z.DataMgr.Get("union_data")
  if charId == nil or unionData.MemberDict == nil then
    return nil
  end
  return unionData.MemberDict[charId]
end

function UnionVM:GetUnionHuntData()
  local seasonVM_ = Z.VMMgr.GetVM("season")
  local seasonID_ = seasonVM_:GetCurrentSeasonId()
  local activityTableMgr = Z.TableMgr.GetTable("UnionActivityTableMgr")
  local configData_ = activityTableMgr:GetDatas()
  local datas_ = {}
  for _, value in ipairs(configData_) do
    if value.SeasonId == seasonID_ then
      table.insert(datas_, value)
    end
  end
  return datas_
end

function UnionVM:GetUnionHuntAwardData()
  local configData_ = Z.UnionActivityConfig.HuntTreasureChest
  local datas_ = {}
  for _, value in ipairs(configData_) do
    local scoreNum_ = value[1]
    local awardId_ = value[2]
    local td = {}
    td[1] = scoreNum_
    td[2] = awardId_
    table.insert(datas_, td)
  end
  return datas_
end

function UnionVM:GetAwardData(configData)
  local datas_ = {}
  for _, value in ipairs(configData) do
    local scoreNum_ = value[1]
    local awardId_ = value[2]
    local td = {}
    td[1] = scoreNum_
    td[2] = awardId_
    table.insert(datas_, td)
  end
  return datas_
end

function UnionVM:CheckUnionHuntUnlock()
  local switchVm = Z.VMMgr.GetVM("switch")
  if not switchVm.CheckFuncSwitch(E.UnionFuncId.Hunt) then
    return false
  end
  local unionActRow = Z.TableMgr.GetTable("UnionActivityTableMgr").GetRow(E.UnionActivityType.UnionHunt)
  if unionActRow == nil or unionActRow.TimerId == nil then
    return false
  end
  return Z.TimeTools.CheckIsInTimeByTimeId(unionActRow.TimerId)
end

function UnionVM:GetUnionResourceCount(configId)
  local unionData = Z.DataMgr.Get("union_data")
  local unionResource = unionData.ResourceDict[configId]
  if unionResource then
    return unionResource.sumNum
  else
    return 0
  end
end

function UnionVM:GetUnionBuildLv(buildId)
  local buildInfo = self:GetBuildInfo(buildId)
  if buildInfo == nil then
    return 0
  end
  return buildInfo.buildingLevel
end

function UnionVM:GetEquipBuffInfoDict()
  local unionData = Z.DataMgr.Get("union_data")
  local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local buffInfoDict = {}
  for slotIndex, info in pairs(unionData.BuildBuffInfo) do
    if info.endTime and curServerTime < info.endTime then
      buffInfoDict[info.effectBuffId] = info
    end
  end
  return buffInfoDict
end

function UnionVM:GetUnionBuildMaxLv(buildId)
  local unionData = Z.DataMgr.Get("union_data")
  local configList = unionData:GetUnionUpgradeConfigList(buildId)
  if configList then
    for level, config in pairs(configList) do
      if config.MaxLevel == 1 then
        return config.Level
      end
    end
  end
  return 0
end

function UnionVM:GetUnionBuildConfig(buildId)
  local unionBuildingTableMgr = Z.TableMgr.GetTable("UnionBuildingTableMgr")
  return unionBuildingTableMgr.GetRow(buildId)
end

function UnionVM:GetBuildInfo(buildId)
  local unionData = Z.DataMgr.Get("union_data")
  if unionData.BuildInfo then
    return unionData.BuildInfo[buildId]
  end
end

function UnionVM:IsUnionBuildUnlock(buildId, isShowTips)
  local config = self:GetUnionBuildConfig(buildId)
  if config == nil then
    return false
  end
  return Z.ConditionHelper.CheckCondition(config.Unlock, isShowTips)
end

function UnionVM:CheckBuildUpgrade(buildId, buildLv, isShowTips)
  if not self:IsUnionBuildUnlock(buildId, isShowTips) then
    return false
  end
  local unionData = Z.DataMgr.Get("union_data")
  local curUpgradeConfig = unionData:GetUnionUpgradeConfigByLv(buildId, buildLv)
  if curUpgradeConfig and curUpgradeConfig.MaxLevel == 1 then
    return false
  end
  local nextUpgradeConfig = unionData:GetUnionUpgradeConfigByLv(buildId, buildLv + 1)
  if nextUpgradeConfig == nil then
    return false
  end
  if self:CheckBuildIsUpgrading(buildId) then
    return false
  end
  if #nextUpgradeConfig.UnionExp > 0 then
    local itemId = nextUpgradeConfig.UnionExp[1]
    local curExp = self:GetUnionResourceCount(itemId)
    local needExp = nextUpgradeConfig.UnionExp[2]
    if curExp < needExp then
      if isShowTips then
        Z.TipsVM.ShowTips(1000550)
      end
      return false
    end
  end
  if 0 < #nextUpgradeConfig.UnionBankroll then
    local itemId = nextUpgradeConfig.UnionBankroll[1]
    local curGold = self:GetUnionResourceCount(itemId)
    local needGold = nextUpgradeConfig.UnionBankroll[2]
    if curGold < needGold then
      if isShowTips then
        Z.TipsVM.ShowTips(1000551)
      end
      return false
    end
  end
  if 0 < #nextUpgradeConfig.UpgradingLimits then
    for i, v in ipairs(nextUpgradeConfig.UpgradingLimits) do
      local buildId = v[1]
      local buildLv = v[2]
      local curBuildLv = self:GetUnionBuildLv(buildId)
      if buildLv > curBuildLv then
        if isShowTips then
          Z.TipsVM.ShowTips(1000552)
        end
        return false
      end
    end
  end
  return true
end

function UnionVM:CheckBuildIsUpgrading(buildId)
  local buildInfo = self:GetBuildInfo(buildId)
  if buildInfo == nil then
    return false
  end
  local currentTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  if buildInfo.upgradeFinishTime ~= 0 and buildInfo.upgradeFinishTime > currentTime + buildInfo.hasSpeedUpSec then
    return true
  else
    return false
  end
end

function UnionVM:ParseUnionBuildPurviewDesc(level, purviewConfig)
  local unionUpradingPurviewTableMgr = Z.TableMgr.GetTable("UnionUpradingPurviewTableMgr")
  local buffTableMgr = Z.TableMgr.GetTable("BuffTableMgr")
  local result = {}
  if purviewConfig then
    for i, info in ipairs(purviewConfig) do
      local id = info[1]
      local config = unionUpradingPurviewTableMgr.GetRow(id)
      if id == E.UnionBuildEffectDef.AddMenSumNum then
        local baseNum = Z.Global.UnionMemberInitialNum
        local desc = Z.Placeholder.Placeholder(config.ShowPurview, {
          val = baseNum + info[2]
        })
        result[i] = desc
      elseif id == E.UnionBuildEffectDef.UnlockEffectId then
        local unionBuffId = info[2]
        local unionBuffConfig = self.unionTimelinessBuffTableMgr.GetRow(unionBuffId)
        if unionBuffConfig then
          local buffConfig = buffTableMgr.GetRow(unionBuffConfig.Buff)
          local desc = Z.Placeholder.Placeholder(config.ShowPurview, {
            val = buffConfig.Name
          })
          result[i] = desc
        end
      elseif id == E.UnionBuildEffectDef.UnlockUnionScreen then
        local desc = Z.Placeholder.Placeholder(config.ShowPurview, {
          val1 = info[2],
          val2 = info[3]
        })
        result[i] = desc
      elseif id == E.UnionBuildEffectDef.UnlockUnionAlbum then
        local baseNum = Z.Global.UnionPhotoAlbumNumLimit
        local desc = Z.Placeholder.Placeholder(config.ShowPurview, {
          val = baseNum + info[2]
        })
        result[i] = desc
      elseif 1 < #info then
        local value = info[2]
        local desc = Z.Placeholder.Placeholder(config.ShowPurview, {val = value})
        result[i] = desc
      else
        result[i] = config.ShowPurview
      end
    end
  end
  if 0 < #result then
    return table.concat(result, "\n")
  elseif level == 0 then
    return Lang("NotUnlock")
  else
    return Lang("None")
  end
end

function UnionVM:ParseUnionBuildBuffPurview(nextBuildConfig)
  local result = {}
  local isBuffEffect = false
  if nextBuildConfig and nextBuildConfig.Purview then
    for i, info in ipairs(nextBuildConfig.Purview) do
      local id = info[1]
      if id == E.UnionBuildEffectDef.UnlockEffectId then
        local unionTimelinessBuffTableMgr = Z.TableMgr.GetTable("UnionTimelinessBuffTableMgr")
        local config = unionTimelinessBuffTableMgr.GetRow(info[2])
        if config then
          table.insert(result, config)
        end
        isBuffEffect = true
      end
    end
  end
  return result, isBuffEffect
end

function UnionVM:GetUnlockBuffSlotNum()
  local unlockSlotCount = 0
  local unionData = Z.DataMgr.Get("union_data")
  local purviewInfo = unionData:GetBuildPurviewInfoDict(E.UnionBuildEffectDef.GridSumNum)
  if purviewInfo then
    local maxSlotCount = Z.ConstValue.UnionConstValue.MAX_BUFF_COUNT
    for i = 1, maxSlotCount do
      local info = purviewInfo[i]
      if info then
        local curBuildLv = self:GetUnionBuildLv(info.BuildingId)
        if curBuildLv >= info.Level then
          unlockSlotCount = unlockSlotCount + 1
        end
      end
    end
  end
  return unlockSlotCount
end

function UnionVM:GetUnionScreenNum(screenId)
  if not screenId then
    return 0
  end
  local unionData = Z.DataMgr.Get("union_data")
  local buildId = E.UnionBuildId.Screen
  local purviewId = E.UnionBuildEffectDef.UnlockUnionScreen
  local curBuildLv = self:GetUnionBuildLv(buildId)
  local purviewInfoList = unionData.buildUpgradePurviewDict_[buildId][purviewId]
  local maxValue = 0
  for i, v in ipairs(purviewInfoList) do
    local id = v.value[2]
    local value = v.value[3]
    if id == tonumber(screenId) and curBuildLv >= v.level and maxValue < value then
      maxValue = value
    end
  end
  return maxValue
end

function UnionVM:GetUnionAlbumMaxNum()
  local unionData = Z.DataMgr.Get("union_data")
  local buildId = E.UnionBuildId.Screen
  local purviewId = E.UnionBuildEffectDef.UnlockUnionAlbum
  local curBuildLv = self:GetUnionBuildLv(buildId)
  local purviewInfoList = unionData.buildUpgradePurviewDict_[buildId][purviewId]
  local maxValue = 0
  for i, v in ipairs(purviewInfoList) do
    if curBuildLv >= v.level and maxValue < v.value then
      maxValue = v.value
    end
  end
  return maxValue + Z.Global.UnionPhotoAlbumNumLimit
end

function UnionVM:GetUnlockInfoBySlotIndex(slotIndex)
  local unionData = Z.DataMgr.Get("union_data")
  local purviewInfo = unionData:GetBuildPurviewInfoDict(E.UnionBuildEffectDef.GridSumNum)
  if purviewInfo then
    return purviewInfo[slotIndex]
  end
end

function UnionVM:CheckUnionBuffUnlock(buffId)
  local unionData = Z.DataMgr.Get("union_data")
  local purviewInfoDict = unionData:GetBuildPurviewInfoDict(E.UnionBuildEffectDef.UnlockEffectId)
  local unlockConfig = purviewInfoDict[buffId]
  if unlockConfig then
    local curBuildLv = self:GetUnionBuildLv(unlockConfig.BuildingId)
    return curBuildLv >= unlockConfig.Level, unlockConfig
  end
  return false, nil
end

function UnionVM:GetUnionSceneIsUnlock()
  local leftTime = 0
  local unlock = false
  local state = E.UnionUnlockState.WaitBegin
  local nowTime = math.floor(Z.TimeTools.Now() / 1000)
  local unionData = Z.DataMgr.Get("union_data")
  local data = unionData:GetUnionGrowData()
  if data then
    if data.buildingFinished then
      unlock = true
    else
      local time = data.fundBeginTime
      local buildEndTime = data.buildEndTime
      if 0 < time and nowTime < time then
        state = E.UnionUnlockState.WaitBegin
        leftTime = time
      elseif 0 < time and nowTime > time and buildEndTime == 0 then
        state = E.UnionUnlockState.IsCrowding
      elseif 0 < buildEndTime and nowTime < buildEndTime then
        state = E.UnionUnlockState.WaitBuildEnd
        leftTime = buildEndTime
      elseif 0 < buildEndTime and nowTime > buildEndTime then
        state = E.UnionUnlockState.BuildEnd
        unlock = true
      end
    end
  end
  return unlock, state, leftTime
end

function UnionVM:CheckCanEnterUnionScene()
  local unionId = self:GetPlayerUnionId()
  if unionId == 0 then
    return false
  end
  local isUnionSceneUnlock = self:GetUnionSceneIsUnlock()
  if not isUnionSceneUnlock then
    return false
  end
  return true
end

function UnionVM:GetUnionSceneUnlockMembers()
  local unionData = Z.DataMgr.Get("union_data")
  local list = unionData:GetUnionGrowMemberData()
  local memberList = {}
  for _, value in ipairs(list) do
    memberList[value.fundPos + 1] = value
  end
  return memberList
end

function UnionVM:GetUnionSceneUnlockProgress()
  local memberNum = 0
  local unionData = Z.DataMgr.Get("union_data")
  local data = unionData:GetUnionGrowData()
  local posList = data.fundPosCharId
  for _, _ in pairs(posList) do
    memberNum = memberNum + 1
  end
  return memberNum
end

function UnionVM:GetHasJoinUnionSceneUnlock()
  local result = false
  local unionData = Z.DataMgr.Get("union_data")
  local data = unionData:GetUnionGrowData()
  local posList = data.fundPosCharId
  for _, value in pairs(posList) do
    if value == Z.ContainerMgr.CharSerialize.charId then
      result = true
      break
    end
  end
  return result
end

local CheckErrorCode = function(errCode)
  if errCode and errCode ~= 0 then
    if not Ignore_Error_Msg_Id[errCode] then
      logError("[Union]ErrorCode=" .. errCode)
    end
    Z.TipsVM.ShowTips(errCode)
    return false
  end
  return true
end

function UnionVM:OnNotifyUnionInfo(vRequest)
  if vRequest.type == E.UnionMemberNotifyType.Join then
    self:CachePlayerUnionInfo(vRequest.info)
    Z.CoroUtil.create_coro_xpcall(function()
      local unionData = Z.DataMgr.Get("union_data")
      self:AsyncReqUnionMemsList(self:GetPlayerUnionId(), unionData.CancelSource:CreateToken())
    end)()
    Z.VMMgr.GetVM("chat_main").ClearChannelQueueByChannelId(E.ChatChannelType.EChannelUnion)
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.UnionJoin)
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.JoinUnion)
    Z.SDKReport.Report(Z.SDKReportEvent.JoinAliance)
  elseif vRequest.type == E.UnionMemberNotifyType.Leave then
    self:CloseAllUnionView()
    self:CachePlayerUnionInfo(nil)
    Z.VMMgr.GetVM("chat_main").ClearChannelQueueByChannelId(E.ChatChannelType.EChannelUnion)
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.LeaveUnion)
  elseif vRequest.type == E.UnionMemberNotifyType.PositionChange then
    self:CachePlayerUnionInfo(vRequest.info)
  else
    logError("\230\156\170\229\174\154\228\185\137\231\154\132\229\141\143\228\188\154\233\128\154\231\159\165\231\177\187\229\158\139:" .. vRequest.type)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UpdateUnionInfo)
end

function UnionVM:OnNotifyUpdateMember(vRequest)
  local unionData = Z.DataMgr.Get("union_data")
  if unionData.MemberDict == nil then
    unionData.MemberDict = {}
  end
  if vRequest.type == E.UnionMemberNotifyType.Join then
    local totalCount = #vRequest.memberInfoList
    local zCharIdList = ZUtil.Pool.Collections.ZList_long.Rent(totalCount)
    for index, memberData in ipairs(vRequest.memberInfoList) do
      local socialData = vRequest.memberSocialList[index]
      unionData.MemberDict[memberData.memId] = {baseData = memberData, socialData = socialData}
      zCharIdList:Add(socialData.basicData.charID)
    end
    Z.LuaDataMgr:SyncUnionMemberCharId(zCharIdList, true)
    ZUtil.Pool.Collections.ZList_long.Return(zCharIdList)
  elseif vRequest.type == E.UnionMemberNotifyType.Leave then
    local totalCount = #vRequest.memberInfoList
    local zCharIdList = ZUtil.Pool.Collections.ZList_long.Rent(totalCount)
    for index, memberData in ipairs(vRequest.memberInfoList) do
      local unionMemberData = unionData.MemberDict[memberData.memId]
      if not unionMemberData then
        logError("unionMemberData is Empty , memberId = {0}", memberData.memId)
        ZUtil.Pool.Collections.ZList_long.Return(zCharIdList)
        return
      end
      if not unionMemberData.socialData then
        logError("socialData is Empty , memberId = {0}", memberData.memId)
        ZUtil.Pool.Collections.ZList_long.Return(zCharIdList)
      else
        zCharIdList:Add(unionMemberData.socialData.basicData.charID)
      end
      unionData.MemberDict[memberData.memId] = nil
    end
    Z.LuaDataMgr:SyncUnionMemberCharId(zCharIdList, false)
    ZUtil.Pool.Collections.ZList_long.Return(zCharIdList)
  elseif vRequest.type == E.UnionMemberNotifyType.PositionChange then
    for index, memberData in ipairs(vRequest.memberInfoList) do
      local socialData = vRequest.memberSocialList[index]
      unionData.MemberDict[memberData.memId] = {baseData = memberData, socialData = socialData}
    end
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionMemberPositionChange)
  else
    logError("\230\156\170\229\174\154\228\185\137\231\154\132\229\141\143\228\188\154\233\128\154\231\159\165\231\177\187\229\158\139:" .. vRequest.type)
  end
  self:CheckApplyRedNum()
  Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UpdateMemberData)
end

function UnionVM:OnNotifyRequestListNum(vRequest)
  local unionData = Z.DataMgr.Get("union_data")
  unionData.ApplyNum = vRequest.num
  self:CheckApplyRedNum()
end

function UnionVM:CheckApplyRedNum()
  local unionData = Z.DataMgr.Get("union_data")
  local count = 0
  if self:CheckPlayerPower(E.UnionPowerDef.ProcessApplication) then
    count = unionData.ApplyNum
  end
  Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionApplyButton, count)
end

function UnionVM:AsyncReqUnionInfo(unionId, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = unionId
  local reply = worldProxy.ReqUnionInfo(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:CachePlayerUnionInfo(reply.info, reply.recruitInfo)
    if reply.info and reply.info.baseInfo.Id ~= 0 then
      self:CacheBuildInfo(reply.unionBuildings)
      self:CacheBuildBuffInfo(reply.effectBuffs)
      self:CacheResourceInfo(reply.unionResourceLib)
      if reply.selfActivity then
        self:HandleActiveRewardInfo(reply.selfActivity.receivedPointAwardIds, true)
      end
      unionData.SpeedUpTimes = reply.selfSpeedTimes
    end
  end
  return reply
end

function UnionVM:AsyncReqOtherUnionInfo(unionId, cancelToken)
  local request = {}
  request.unionId = unionId
  local reply = worldProxy.ReqUnionInfo(request, cancelToken)
  CheckErrorCode(reply.errCode)
  return reply
end

function UnionVM:AsyncBatchReqOtherUnionInfo(unionIdList, cancelToken)
  local request = {}
  request.unionIdList = unionIdList
  local reply = worldProxy.BatchSearchUnionList(request, cancelToken)
  CheckErrorCode(reply.errCode)
  return reply
end

function UnionVM:AsyncReqUnionList(cancelToken)
  local request = {}
  local reply = worldProxy.UnionList(request, cancelToken)
  CheckErrorCode(reply.errCode)
  return reply
end

function UnionVM:AsyncReqJoinUnions(unionIds, isOneKeyJoin, cancelToken)
  if self:GetPlayerUnionId() ~= 0 then
    Z.TipsVM.ShowTips(100511)
    return
  end
  local request = {}
  request.unionIds = unionIds
  request.isAll = isOneKeyJoin
  local reply = worldProxy.ReqJoinUnions(request, cancelToken)
  if reply and 0 < reply.nextJoinTime then
    local currentTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    local leftTime = reply.nextJoinTime - currentTime
    if 0 < leftTime then
      Z.TipsVM.ShowTips(1000571, {
        val = Z.TimeFormatTools.FormatToDHMS(leftTime)
      })
    end
  elseif #reply.unionsRet == 1 then
    local isSuccess = CheckErrorCode(reply.unionsRet[1].errCode)
    if isSuccess then
      Z.TipsVM.ShowTips(1000507)
    end
  else
    CheckErrorCode(reply.errCode)
  end
  return reply
end

function UnionVM:AsyncReqRefuseUnionInvite(inviteId, cancelToken)
  local request = {InviteId = inviteId}
  local errCode = worldProxy.ReJectUnionInvite(request, cancelToken)
  CheckErrorCode(errCode)
end

function UnionVM:AsyncSearchUnionList(inputStr, cancelToken)
  local request = {}
  request.searchContent = inputStr
  local reply = worldProxy.SearchUnionList(request, cancelToken)
  CheckErrorCode(reply.errCode)
  return reply
end

function UnionVM:AsyncCreateUnion(name, manifesto, isAutoJoin, logoData, tagList, cancelToken)
  local request = {}
  request.unionName = name
  request.declaration = manifesto
  request.autoApproval = isAutoJoin
  request.unionIcon = logoData
  request.tags = tagList
  local reply = worldProxy.CreateUnion(request, cancelToken)
  if reply and reply.nextJoinTime > 0 then
    local currentTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    local leftTime = reply.nextJoinTime - currentTime
    if 0 < leftTime then
      Z.TipsVM.ShowTips(1000571, {
        val = Z.TimeFormatTools.FormatToDHMS(leftTime)
      })
    end
    return
  end
  if CheckErrorCode(reply.errCode) == false then
    return
  end
  local unionInfo = reply.info
  self:CachePlayerUnionInfo(unionInfo)
  local param = {
    guild = {
      name = self:GetPlayerUnionName()
    }
  }
  Z.TipsVM.ShowTipsLang(1000520, param)
  Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.CreateUnion)
end

function UnionVM:AsyncSetUnionIcon(unionId, logoData, cancelToken)
  local request = {}
  request.unionId = unionId
  request.Icon = logoData
  local reply = worldProxy.SetUnionIcon(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:UpdateUnionBase(reply.data)
  end
  return reply
end

function UnionVM:AsyncSetUnionDeclaration(unionId, unionDeclaration, cancelToken)
  local request = {}
  request.unionId = unionId
  request.declaration = unionDeclaration
  local reply = worldProxy.SetUnionDeclaration(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:UpdateUnionBase(reply.data)
  end
  return reply
end

function UnionVM:AsyncSetUnionName(unionId, unionName, cancelToken)
  local request = {}
  request.unionId = unionId
  request.name = unionName
  local reply = worldProxy.SetUnionName(request, cancelToken)
  if reply.errCode == Z.PbEnum("EErrorCode", "ErrUnionChangeNameCD") then
    local param = {
      val = Z.TimeFormatTools.TicksFormatTime(reply.passTimeMs * 1000, E.TimeFormatType.YMDHMS)
    }
    Z.TipsVM.ShowTipsLang(1000521, param)
    return
  end
  if CheckErrorCode(reply.errCode) then
    self:UpdateUnionBase(reply.data)
    Z.TipsVM.ShowTips(1000549)
  end
end

function UnionVM:AsyncSetUnionTag(unionId, tagList, cancelToken)
  local request = {}
  request.unionId = unionId
  request.tags = tagList
  local reply = worldProxy.SetUnionTags(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:UpdateUnionBase(reply.data)
  end
  return reply
end

function UnionVM:AsyncSetUnionAutoPass(unionId, autoPass, cancelToken)
  local request = {}
  request.unionId = unionId
  request.autoPass = autoPass
  local reply = worldProxy.SetUnionAutoPass(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:GetPlayerUnionInfo().autoPass = reply.autoPass
  end
  return reply
end

function UnionVM:AsyncReqUnionMemsList(unionId, cancelToken)
  local request = {}
  request.unionId = unionId
  local reply = worldProxy.ReqUnionMemsList(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:CacheUnionMember(reply.memList, reply.memSocialList)
  end
  return reply
end

function UnionVM:AsyncReqLeaveUnion(unionId, cancelToken)
  local unionName = self:GetPlayerUnionName()
  local request = {}
  request.unionId = unionId
  local errCode = worldProxy.ReqLeaveUnion(request, cancelToken)
  if CheckErrorCode(errCode) then
    local param = {
      guild = {name = unionName}
    }
    Z.TipsVM.ShowTips(1000526, param)
  end
  return errCode
end

function UnionVM:AsyncReqKickOut(unionId, charIds, cancelToken)
  local request = {}
  request.unionId = unionId
  request.vKickIds = charIds
  local errCode = worldProxy.ReqKickOut(request, cancelToken)
  CheckErrorCode(errCode)
  return errCode
end

function UnionVM:AsyncInviteRequestInfo(myCharId, myCharName, unionId, unionName, inviteeCharId, cancelToken)
  local request = {}
  request.InviteId = myCharId
  request.inviteName = myCharName
  request.unionId = unionId
  request.unionName = unionName
  request.charid = inviteeCharId
  local errCode = worldProxy.InviteJoinUnion(request, cancelToken)
  CheckErrorCode(errCode)
end

function UnionVM:AsyncGetRequestList(unionId, cancelToken)
  local request = {}
  request.unionId = unionId
  local reply = worldProxy.GetRequestList(request, cancelToken)
  CheckErrorCode(reply.errCode)
  return reply
end

function UnionVM:AsyncApprovalRequest(unionId, operationList, cancelToken)
  local request = {}
  request.unionId = unionId
  request.vApprovalList = operationList
  local reply = worldProxy.ApprovalRequest(request, cancelToken)
  CheckErrorCode(reply.errCode)
  return reply
end

function UnionVM:AsyncReqChangeOfficials(unionId, changeType, officialDataList, cancelToken)
  local request = {}
  request.unionId = unionId
  request.changeType = changeType
  request.changeOfficials = officialDataList
  local reply = worldProxy.ReqChangeOfficials(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:UpdateUnionOfficials(reply.changeOfficials)
  end
  return reply
end

function UnionVM:AsyncReqChangeOfficialMembers(unionId, changedMemberDict, cancelToken)
  local request = {}
  request.unionId = unionId
  request.changeOfficials = changedMemberDict
  local errCode = worldProxy.ReqChangeOfficialMembers(request, cancelToken)
  CheckErrorCode(errCode)
  return errCode
end

function UnionVM:AsyncReqTransferPresident(unionId, charId, cancelToken)
  local request = {}
  request.unionId = unionId
  request.vNewPresidentId = charId
  local reply = worldProxy.ReqTransferPresident(request, cancelToken)
  if CheckErrorCode(reply.errCode) and reply.info ~= nil and reply.info.baseInfo.Id ~= 0 then
    self:CachePlayerUnionInfo(reply.info)
  end
  return reply
end

function UnionVM:AsyncSetUnionRecruit(level, slogan, instruction, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local recruitInfo = {joinLevel = level, instruction = instruction}
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  request.recruitInfo = recruitInfo
  request.slogan = slogan
  local errCode = worldProxy.SetRecruitInfo(request, cancelToken)
  if CheckErrorCode(errCode) then
    unionData.RecruitInfo = recruitInfo
    unionData.UnionInfo.baseInfo.slogan = slogan
  end
  return errCode
end

function UnionVM:AsyncCollectUnion(unionId, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = unionId
  local reply = worldProxy.AddCollectUnionId(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    Z.TipsVM.ShowTips(1000590)
    unionData:AddCollectUnion(reply.briefUnionIfo)
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.CollectionUnionChange)
  end
  return reply
end

function UnionVM:AsyncCancelCollectUnion(unionId, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = unionId
  local errCode = worldProxy.CancelCollectedUnionId(request, cancelToken)
  if CheckErrorCode(errCode) then
    Z.TipsVM.ShowTips(1000591)
    unionData:RemoveCollectUnion(unionId)
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.CollectionUnionChange)
  end
  return errCode
end

function UnionVM:AsyncGetCollectUnionList(cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  local reply = worldProxy.GetCollectedUnionList(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    unionData:ClearCollectUnionList()
    for i, data in ipairs(reply.unionList) do
      unionData:AddCollectUnion(data)
    end
  end
  return reply
end

function UnionVM:AsyncGetActiveInfo(cancelToken)
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  local reply = worldProxy.GetUnionActivityInfo(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:HandleActiveRewardInfo(reply.selfActivity.receivedPointAwardIds, true)
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionActiveRewardInfoChange)
  end
  return reply
end

function UnionVM:AsyncGetActiveAward(awardId, cancelToken)
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  request.awardId = awardId
  local reply = worldProxy.ReceiveUnionActivityAward(request, cancelToken)
  if reply.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(reply.items)
  end
  if CheckErrorCode(reply.errCode) then
    self:HandleActiveRewardInfo(reply.receivedPointAwardIds)
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionActiveRewardInfoChange)
  end
  return reply
end

function UnionVM:AsyncGetUnionHuntProgressInfo(activityId, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = unionData.UnionInfo.baseInfo.Id
  request.activityId = activityId
  local reply = worldProxy.ReqUnionActivityProgressInfo(request, cancelToken)
  if reply.errCode == 4463 then
    return reply
  end
  if CheckErrorCode(reply.errCode) then
    unionData:SetUnionHuntProgressInfo(reply.progressInfo)
  end
  return reply
end

function UnionVM:AsyncGetUnionHuntProgressAward(activityId, progress, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = unionData.UnionInfo.baseInfo.Id
  request.activityId = activityId
  request.progress = progress
  local errCode = worldProxy.ReqGetUnionActivityAward(request, cancelToken)
  if CheckErrorCode(errCode) then
    unionData:SetUnionHuntProgressInfoByID(activityId, progress)
  end
  return errCode
end

function UnionVM:OnNotifyHuntProgressAward(vRequest)
  local unionData = Z.DataMgr.Get("union_data")
  unionData:SetUnionHuntProgressInfo(vRequest.progressInfo)
end

function UnionVM:AsyncGetUnionHuntRankData(activityId, rankType, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = unionData.UnionInfo.baseInfo.Id
  request.activityId = activityId
  request.rankType = rankType
  local reply = worldProxy.ReqUnionActivityRank(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    local list = reply.rankList
    unionData:SetUnionHuntRankInfo(list)
  end
  return reply
end

function UnionVM:AsyncGetUnionResource(cancelToken)
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  local reply = worldProxy.GetUnionResourceLib(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    self:CacheResourceInfo(reply.unionResourceLib)
  end
  return reply
end

function UnionVM:AsyncUpgradeUnionBuild(buildId, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  request.buildingId = buildId
  local reply = worldProxy.UpgradeUnionBuilding(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    local buildInfo = reply.upgradeBuildInfo
    if buildInfo then
      unionData.BuildInfo[buildInfo.buildingId] = buildInfo
      Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange)
    end
  end
  return reply
end

function UnionVM:AsyncSpeedUpUnionBuild(buildId, buildLv, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  request.buildingId = buildId
  request.buildLevel = buildLv
  local reply = worldProxy.SpeedUpUpgradeUnionBuilding(request, cancelToken)
  if CheckErrorCode(reply.errCode) then
    if reply.selfSpeedTimes then
      unionData.SpeedUpTimes = reply.selfSpeedTimes
    end
    local buildInfo = reply.upgradeBuildInfo
    if buildInfo then
      unionData.BuildInfo[buildInfo.buildingId] = buildInfo
      Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange)
    end
  end
  return reply
end

function UnionVM:AsyncEnterUnionScene(cancelToken)
  local unionId = self:GetPlayerUnionId()
  if unionId == 0 then
    Z.TipsVM.ShowTips(1000593)
    return
  end
  local isUnionSceneUnlock = self:GetUnionSceneIsUnlock()
  if not isUnionSceneUnlock then
    Z.TipsVM.ShowTips(1000594)
    return
  end
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local configData_ = Z.UnionActivityConfig.HuntDungeonCount
  for _, value in ipairs(configData_) do
    local sceneId = value[1]
    if sceneId == curSceneId then
      Z.TipsVM.ShowTips(100124)
      return
    end
  end
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(curSceneId)
  if sceneTable.SceneSubType == E.SceneSubType.Union then
    Z.TipsVM.ShowTips(1000555)
    return
  end
  local vRequest = {}
  vRequest.unionId = unionId
  vRequest.enterType = Z.PbEnum("UnionEnterScene", "UnionEnterSceneNormal")
  local errCode = worldProxy.EnterUnionScene(vRequest, cancelToken)
  CheckErrorCode(errCode)
end

function UnionVM:EnterUnionSceneHunt()
  local unionId = self:GetPlayerUnionId()
  if unionId == 0 then
    Z.TipsVM.ShowTips(1000593)
    return
  end
  local isUnionSceneUnlock = self:GetUnionSceneIsUnlock()
  if not isUnionSceneUnlock then
    Z.TipsVM.ShowTips(1000594)
    return
  end
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local configData_ = Z.UnionActivityConfig.HuntDungeonCount
  for _, value in ipairs(configData_) do
    local sceneId = value[1]
    if sceneId == curSceneId then
      Z.TipsVM.ShowTips(100124)
      return
    end
  end
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(curSceneId)
  if sceneTable.SceneSubType == E.SceneSubType.Union then
    Z.TipsVM.ShowTips(1000555)
    return
  end
  local vRequest = {}
  vRequest.unionId = unionId
  vRequest.enterType = Z.PbEnum("UnionEnterScene", "UnionEnterSceneHunt")
  Z.CoroUtil.create_coro_xpcall(function()
    local unionData = Z.DataMgr.Get("union_data")
    local errCode = worldProxy.EnterUnionScene(vRequest, unionData.CancelSource:CreateToken())
    CheckErrorCode(errCode)
  end)()
end

function UnionVM.EnterUnionScene()
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  if not funcVM.FuncIsOn(E.UnionFuncId.Union) then
    return
  end
  local unionId = UnionVM.GetPlayerUnionId(UnionVM)
  if unionId == 0 then
    UnionVM.OpenUnionMainView(UnionVM)
    return
  end
  local isUnionSceneUnlock = UnionVM.GetUnionSceneIsUnlock(UnionVM)
  if not isUnionSceneUnlock then
    UnionVM.OpenUnionMainView(UnionVM)
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local unionData = Z.DataMgr.Get("union_data")
    UnionVM.AsyncEnterUnionScene(UnionVM, unionData.CancelSource:CreateToken())
  end)()
end

function UnionVM.LeaveUnionScene(uuid, cancelToken)
  Z.CoroUtil.create_coro_xpcall(function()
    worldProxy.LeaveScene(cancelToken)
  end)()
end

function UnionVM:AsyncSetEffectBuff(buffId, buffSlotIndex, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  request.effectBuffPos = buffSlotIndex - 1
  request.effectBuffId = buffId
  local reply = worldProxy.SetEffectBuff(request, cancelToken)
  if CheckErrorCode(reply.errCode) and reply.effectBuff then
    unionData.BuildBuffInfo[reply.effectBuff.buffPos + 1] = reply.effectBuff
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionBuildBuffInfoChange)
  end
  return reply
end

function UnionVM:AsyncUnlockUnionScene(pos, cancelToken)
  local unionId = self:GetPlayerUnionId()
  local request = {unionId = unionId, growFuncPos = pos}
  local ret = worldProxy.JoinUnionGrowFunc(request, cancelToken)
  if CheckErrorCode(ret.errCode) then
    local unionData = Z.DataMgr.Get("union_data")
    unionData:SetUnionGrowData(ret.crowdFund)
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionSceneUnlockRedRefresh)
  end
  return ret.errCode
end

function UnionVM:AsyncGetUnlockUnionSceneData(cancelToken)
  local unionId = self:GetPlayerUnionId()
  local request = {unionId = unionId}
  local ret = worldProxy.GetUnionGrowFundInfo(request, cancelToken)
  if CheckErrorCode(ret.errCode) then
    local unionData = Z.DataMgr.Get("union_data")
    unionData:SetUnionGrowData(ret.crowdFund)
    unionData:SetUnionGrowMemberData(ret.crowFuncMemList)
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionSceneUnlockRedRefresh)
  end
  return ret.errCode
end

function UnionVM:AsyncCancelEffectBuff(buffId, buffSlotIndex, cancelToken)
  local unionData = Z.DataMgr.Get("union_data")
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  request.effectBuffPos = buffSlotIndex - 1
  request.effectBuffId = buffId
  local errCode = worldProxy.CancelEffectBuff(request, cancelToken)
  if CheckErrorCode(errCode) then
    unionData.BuildBuffInfo[buffSlotIndex] = nil
    Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionBuildBuffInfoChange)
  end
  return errCode
end

function UnionVM:AsyncStartEnterDungeon(functionID, dungeonId, affix, cancelSource, selectType, heroKeyItemUuid)
  enterdungeonsceneVm.AsyncCreateLevel(functionID, dungeonId, cancelSource:CreateToken(), affix, nil, selectType, heroKeyItemUuid)
end

function UnionVM:AsyncBindGroupWithTencent(groupType, groupId, cancelToken)
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  request.groupType = groupType
  request.groupId = groupId
  local reply = worldProxy.BindGroupWithTencent(request, cancelToken)
  if reply then
    if CheckErrorCode(reply.errCode) and reply.unionInfo then
      self:CachePlayerUnionInfo(reply.unionInfo)
    end
    return reply.errCode
  end
end

function UnionVM:AsyncUnBindGroupWithTencent(cancelToken)
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  local reply = worldProxy.UnBindGroupWithTencent(request, cancelToken)
  if reply then
    if CheckErrorCode(reply.errCode) and reply.unionInfo then
      self:CachePlayerUnionInfo(reply.unionInfo)
    end
    return reply.errCode
  end
end

function UnionVM:AsyncInviteJoinGroupWithTencent(content, cancelToken)
  local request = {}
  request.unionId = self:GetPlayerUnionId()
  request.desc = content
  request.url = ""
  local errCode = worldProxy.InviteJoinGroupWithTencent(request, cancelToken)
  CheckErrorCode(errCode)
  return errCode
end

function UnionVM:GetRGBColorById(colorGroupId, hsvIndex)
  local row = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(colorGroupId)
  if row == nil then
    logError("\232\161\168ColorGroupTable\228\184\173\228\184\141\229\173\152\229\156\168ID={0}\231\154\132\230\149\176\230\141\174", colorGroupId)
    return Color.New(1, 1, 1, 1)
  end
  if hsvIndex > #row.UiColor then
    logError("\232\161\168ColorGroupTable\228\184\173ID={0}\231\154\132UiColor\230\149\176\233\135\143\228\184\141\232\182\179{1}\228\184\170", colorGroupId, hsvIndex)
    return Color.New(1, 1, 1, 1)
  end
  if hsvIndex == 0 then
    return Color.New(1, 1, 1, 1)
  end
  local h = row.UiColor[hsvIndex][2]
  local s = row.UiColor[hsvIndex][3]
  local v = row.UiColor[hsvIndex][4]
  return Color.HSVToRGB(h / 360, s / 100, v / 100, false)
end

function UnionVM:GetOfficialName(officialId)
  local unionData = Z.DataMgr.Get("union_data")
  if unionData.UnionInfo == nil or unionData.UnionInfo.baseInfo.Id == 0 then
    logError("\230\178\161\230\137\190\229\136\176\229\141\143\228\188\154\231\155\184\229\133\179\230\149\176\230\141\174")
    return ""
  end
  local officialDataDict = unionData.UnionInfo.officials
  if officialId == nil or officialDataDict[officialId] == nil then
    return ""
  end
  return officialDataDict[officialId].Name
end

function UnionVM:GetPowerName(powerId)
  local unionAuthorityTableRow = Z.TableMgr.GetRow("UnionAuthorityTableMgr", powerId)
  if unionAuthorityTableRow == nil then
    return ""
  end
  return unionAuthorityTableRow.Authority
end

function UnionVM:GetOfficialMemberList(officialId)
  local unionData = Z.DataMgr.Get("union_data")
  local memberList = {}
  if unionData.MemberDict == nil then
    return memberList
  end
  for id, data in pairs(unionData.MemberDict) do
    if data.baseData.officialId == officialId then
      memberList[#memberList + 1] = data
    end
  end
  return memberList
end

function UnionVM:GetLastTimeDesignText(lastTime)
  if lastTime == 0 then
    return Lang("Online")
  end
  local ONE_MINUTE = 60
  local ONE_HOUR = 3600
  local ONE_DAY = 86400
  local duration = (Z.ServerTime:GetServerTime() - lastTime) / 1000
  if ONE_MINUTE > duration then
    return Lang("JustNow")
  elseif ONE_HOUR > duration then
    return math.modf(duration // ONE_MINUTE) .. Lang("MinutesAgo")
  elseif ONE_DAY > duration then
    return math.modf(duration // ONE_HOUR) .. Lang("HoursAgo")
  elseif ONE_DAY < duration then
    return math.modf(duration // ONE_DAY) .. Lang("DaysAgo")
  else
    logError("\230\151\182\233\151\180\229\188\130\229\184\184 {0} ", duration)
    return ""
  end
end

function UnionVM:IsPlayerUnionPresident()
  local unionData = Z.DataMgr.Get("union_data")
  return unionData.UnionInfo.baseInfo.presidentId == Z.ContainerMgr.CharSerialize.charBase.charId
end

function UnionVM:IsDefaultPosition(positionId)
  return positionId == Z.Global.UnionDefaultPosition
end

function UnionVM:IsCustomPosition(positionId)
  return positionId >= E.UnionPositionDef.Custom1
end

function UnionVM:IsUnionMember(charId)
  local unionData = Z.DataMgr.Get("union_data")
  if unionData.MemberDict == nil then
    return false
  end
  return unionData.MemberDict[charId] ~= nil
end

function UnionVM:CanUnionDissolve()
  local unionInfo = self:GetPlayerUnionInfo()
  if unionInfo == nil then
    return false
  end
  return unionInfo.baseInfo.num == 1
end

function UnionVM:CheckIconUnlock(unionIconId)
  local unionIconTableMgr = Z.TableMgr.GetTable("UnionIconTableMgr")
  local row = unionIconTableMgr.GetRow(unionIconId)
  if row == nil then
    return false
  end
  return true
end

function UnionVM.GetDungeonTimerData(timeType)
  local timerData = {}
  timerData.startTime = 0
  timerData.endTime = 0
  local startTime = Z.ContainerMgr.DungeonSyncData.timerInfo.startTime
  local limitTime = Z.ContainerMgr.DungeonSyncData.timerInfo.dungeonTimes
  if startTime ~= nil and limitTime ~= nil then
    timerData.startTime = startTime
    timerData.endTime = startTime + limitTime
    timerData.timeType = E.DungeonTimerDirection.DungeonTimerDirectionDown
  end
  return timerData
end

function UnionVM:GetDungeonCounterID(dungeonID)
  local configData_ = Z.UnionActivityConfig.HuntDungeonCount
  for _, value in ipairs(configData_) do
    local id = value[1]
    if id == dungeonID then
      local countId_ = value[2]
      return countId_
    end
  end
  return 0
end

function UnionVM:NotifyUnionActivity(msgId)
  local unionInviteFunc = function(callData, flag)
    local unionVM = Z.VMMgr.GetVM("union")
    if flag then
      unionVM:EnterUnionSceneHunt()
    end
  end
  local teamTipData_ = Z.DataMgr.Get("team_tip_data")
  local content_ = ""
  if msgId == 5010001 then
    content_ = Lang("UnionHuntEnterNotice")
  elseif msgId == 5010002 then
    content_ = Lang("UnionHuntStartNotice")
  end
  local info = {
    charId = "",
    tipsType = E.InvitationTipsType.UnionHunt,
    content = content_,
    cd = Z.Global.TeamInviteLastTime,
    func = unionInviteFunc,
    funcParam = {}
  }
  local unionVM = Z.VMMgr.GetVM("union")
  if not unionVM:GetUnionSceneIsUnlock() then
    return
  end
  teamTipData_:SetCacheData(info)
end

function UnionVM:IsEnoughActiveGetTime()
  local myCharId = Z.ContainerMgr.CharSerialize.charId
  local memberData = self:GetUnionMemberData(myCharId)
  if memberData == nil then
    return false
  end
  local joinTime = memberData.baseData.joinTime
  local condTime = Z.Global.UnionDuration
  local curTime = Z.ServerTime:GetServerTime() / 1000
  return condTime <= curTime - joinTime
end

function UnionVM:ShowLeaveUnionTips()
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(curSceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Union then
    return
  end
  local unionData = Z.DataMgr.Get("union_data")
  Z.DialogViewDataMgr:OpenOKDialog(Lang("LeaveUnionTips"), function()
    worldProxy.LeaveScene(unionData.CancelSource:CreateToken())
  end)
end

function UnionVM:IsUnionPhotoWallOpen()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.UnionPhotoWall, true)
  return isOn
end

function UnionVM:OpenUnionMainView()
  Z.CoroUtil.create_coro_xpcall(function()
    local unionData = Z.DataMgr.Get("union_data")
    self:AsyncReqUnionInfo(0, unionData.CancelSource:CreateToken())
    if self:GetPlayerUnionId() ~= 0 then
      Z.UIMgr:OpenView("union_main")
    else
      Z.UIMgr:OpenView("union_join_window")
    end
  end)()
end

function UnionVM:OpenUnionMainSubView(subType, subViewData)
  local unionId = self:GetPlayerUnionId()
  if unionId ~= 0 then
    Z.UIMgr:OpenView("union_main", {Type = subType, SubViewData = subViewData})
  else
    Z.TipsVM.ShowTipsLang(1000595)
    Z.UIMgr:OpenView("union_join_window")
  end
end

function UnionVM:CloseUnionMainView()
  Z.UIMgr:CloseView("union_main")
end

function UnionVM:CloseAllUnionView()
  Z.UIMgr:CloseView("union_main")
  Z.UIMgr:CloseView("union_join_window")
  Z.UIMgr:CloseView("union_create_window")
  Z.UIMgr:CloseView("union_detail_popup")
  Z.UIMgr:CloseView("union_recruit_popup")
  Z.UIMgr:CloseView("union_application_popup")
end

function UnionVM:OpenUnionCreateView()
  Z.UIMgr:OpenView("union_create_window")
end

function UnionVM:OpenJoinWindow()
  Z.UIMgr:OpenView("union_join_window")
end

function UnionVM:CloseJoinWindow()
  Z.UIMgr:CloseView("union_join_window")
end

function UnionVM:OpenUnionPositionManagePopup(type, caencelToken)
  self:AsyncReqUnionInfo(self:GetPlayerUnionId(), caencelToken)
  Z.UIMgr:OpenView("union_position_manage_popup", type)
end

function UnionVM:OpenModifyIconPopup()
  Z.UIMgr:OpenView("union_logo_customizing_popup")
end

function UnionVM:CloseModifyIconPopup()
  Z.UIMgr:CloseView("union_logo_customizing_popup")
end

function UnionVM:OpenUnionApplicationPopup(cancelToken)
  self:AsyncReqUnionInfo(self:GetPlayerUnionId(), cancelToken)
  Z.UIMgr:OpenView("union_application_popup")
  local unionData = Z.DataMgr.Get("union_data")
  unionData.ApplyNum = 0
  Z.RedPointMgr.OnClickRedDot(E.RedType.UnionApplyButton)
end

function UnionVM:CloseUnionApplicationPopup()
  Z.UIMgr:CloseView("union_application_popup")
end

function UnionVM:OpenModifyNamePopup(info)
  Z.UIMgr:OpenView("union_name_popup", info)
end

function UnionVM:OpenModifyManifestoPopup(info)
  Z.UIMgr:OpenView("union_manifesto_popup", info)
end

function UnionVM:CloseAppointEditTips()
  Z.UIMgr:CloseView("union_appoint_edit_tips")
end

function UnionVM:OpenUnionSettingView()
  Z.UIMgr:OpenView("union_set_popup")
end

function UnionVM:OpenUnionRecruitSettingView()
  Z.UIMgr:OpenView("union_recruit_popup")
end

function UnionVM:OpenUnionRecruitDetailView(viewData)
  Z.UIMgr:OpenView("union_detail_popup", viewData)
end

function UnionVM:OpenAppointEditTipsView(viewData)
  Z.UIMgr:OpenView("union_appoint_edit_tips", viewData)
end

function UnionVM:OpenFilterTipsView(viewData)
  Z.UIMgr:OpenView("union_filter_tips", viewData)
end

function UnionVM:OpenLabelTipsView(viewData)
  Z.UIMgr:OpenView("union_label_tips", viewData)
end

function UnionVM:OpenHuntEnterView(difficulty)
  local viewData = {difficulty = difficulty}
  Z.UIMgr:OpenView("union_hunt_enter_into_main", viewData)
end

function UnionVM:CloseHuntEnterView()
  Z.UIMgr:CloseView("union_hunt_enter_into_main")
end

function UnionVM:OpenHuntRankView(viewData)
  Z.UIMgr:OpenView("union_active_hot_popup", viewData)
end

function UnionVM:CloseHuntRankView()
  Z.UIMgr:CloseView("union_active_hot_popup")
end

function UnionVM:OpenUnionHuntView(openFuncId)
  self:OpenUnionMainSubView(E.UnionMainTab.Hunt, {
    OpenFuncId = tonumber(openFuncId)
  })
end

function UnionVM:OpenUnionActivityView()
  self:OpenUnionMainSubView(E.UnionMainTab.Active)
end

function UnionVM:OpenUnionBuildViewById(buildId)
  Z.UIMgr:OpenView("union_upgrade_main", {BuildId = buildId})
end

function UnionVM:OpenUnionDeviceView()
  Z.UIMgr:OpenView("union_device_main")
end

function UnionVM:OpenUnionBuildFunctionViewById(buildId, uuid, ...)
  if not self:IsUnionBuildUnlock(buildId, true) then
    return
  end
  local params = {
    ...
  }
  if buildId == E.UnionBuildId.Buff then
    local functionId = E.UnionFuncId.Buff
    if functionId then
      local funcVM = Z.VMMgr.GetVM("gotofunc")
      funcVM.GoToFunc(functionId, uuid)
    end
  elseif buildId == E.UnionBuildId.Mall then
    local functionId = tonumber(params[1])
    if functionId then
      local funcVM = Z.VMMgr.GetVM("gotofunc")
      funcVM.GoToFunc(functionId, uuid)
    end
  elseif buildId == E.UnionBuildId.Screen then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.UnionPhotoWall)
    if not isOn then
      return
    end
    local albumData_ = Z.DataMgr.Get("album_main_data")
    albumData_.EScreenId = tonumber(params[2])
    Z.UIMgr:OpenView("album_main", E.AlbumOpenSource.UnionElectronicScreen)
  end
end

function UnionVM:OpenUnionBuildPopupView(type, buildId, extendParams)
  Z.UIMgr:OpenView("union_unit_popup", {
    Type = type,
    BuildId = buildId,
    ExtendParams = extendParams
  })
end

function UnionVM:OpenUnionUnlockSceneView()
  Z.UIMgr:OpenView("union_unlockscene_main")
end

function UnionVM:CloseUnionUnlockSceneView()
  Z.UIMgr:CloseView("union_unlockscene_main")
end

function UnionVM:OpenUnionUnlockSceneSuccessView()
  Z.UIMgr:OpenView("union_scene_unlock_popup")
end

function UnionVM:CloseUnionUnlockSceneSuccessView()
  Z.UIMgr:CloseView("union_scene_unlock_popup")
end

local playCallFunc = function(cutId, tab, teamMembers)
  local entityVM = Z.VMMgr.GetVM("entity")
  local teamEntData = {}
  Z.UITimelineDisplay:Play(cutId)
  Z.UITimelineDisplay:SetGoPosByCutsceneId(cutId, Vector3.New(tab.ResultCurscenePos.X, tab.ResultCurscenePos.Y, tab.ResultCurscenePos.Z))
  local isPlay = Z.SettlementCutMgr:GetSettlementIsPlayByCutId(cutId)
  if isPlay then
    local showCount = #teamMembers
    for index, value in ipairs(teamMembers) do
      if value.isAi then
        Z.LuaBridge.SetModelVisibleByEntId(value.charId)
        showCount = showCount - 1
      end
    end
    if 1 < showCount then
      local count = 0
      for index, value in ipairs(teamMembers) do
        if not value.isAi then
          count = count + 1
          local data = {}
          local nodeCountType = SettlementNodeIndex.IntToEnum(showCount - 2)
          data.posi = Z.SettlementCutMgr:GetSettlementMondelNodePosi(nodeCountType, count - 1)
          data.quaternion = Z.SettlementCutMgr:GetSettlementMondelNodeEulerAngle(nodeCountType, count - 1)
          teamEntData[value.charId] = data
          local uuid = entityVM.EntIdToUuid(Z.ContainerMgr.CharSerialize.charId, entChar)
          local entity = Z.EntityMgr:GetEntity(uuid)
          if entity then
            entity.Model:SetLuaAttr(Z.ModelAttr.EModelAnimIKClose, true)
          end
        end
      end
    else
      local data = {}
      local indexType = SettlementNodeIndex.IntToEnum(0)
      data.posi = Z.SettlementCutMgr:GetSettlementMondelNodePosi(indexType, 0)
      data.quaternion = Z.SettlementCutMgr:GetSettlementMondelNodeEulerAngle(indexType, 0)
      teamEntData[Z.EntityMgr.PlayerEnt.CharId] = data
      local uuid = entityVM.EntIdToUuid(Z.ContainerMgr.CharSerialize.charId, entChar)
      local entity = Z.EntityMgr:GetEntity(uuid)
      if entity then
        entity.Model:SetLuaAttr(Z.ModelAttr.EModelAnimIKClose, true)
      end
    end
  end
  local ret = {}
  ret.vUserPos = {}
  for charId, pos in pairs(teamEntData) do
    local tab = {}
    tab.pos = {
      x = pos.posi.x,
      y = pos.posi.y,
      z = pos.posi.z,
      dir = pos.quaternion.y
    }
    ret.vUserPos[charId] = tab
  end
  local teamData = Z.DataMgr.Get("team_data")
  Z.CoroUtil.create_coro_xpcall(function()
    local proxy = require("zproxy.world_proxy")
    proxy.ReportSettlementPosition(ret, teamData.CancelSource:CreateToken())
  end)()
  Z.UIMgr:OpenView("hero_dungeon_copy_window")
end
local playTimeLine = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local tab = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local teamVm = Z.VMMgr.GetVM("team")
  local teamMembers = teamVm.GetTeamMemData()
  local cutId = 50100601
  local teamData = Z.DataMgr.Get("team_data")
  if tab and (tab.ResultCurscenePos.X ~= 0 or tab.ResultCurscenePos.Y ~= 0 or tab.ResultCurscenePos.Z ~= 0) then
    Z.UITimelineDisplay:AsyncPreLoadTimeline(cutId, teamData.CancelSource:CreateToken(), function()
      playCallFunc(cutId, tab, teamMembers)
    end, function()
    end)
  else
    Z.UIMgr:OpenView("hero_dungeon_copy_window")
  end
end

function UnionVM:OpenSettlementSuccessWindow()
  if Z.UIMgr:IsActive("camerasys") then
    Z.UIMgr:CloseView("camerasys")
  end
  playTimeLine()
end

function UnionVM:OpenSettlementFailWindow()
  if Z.UIMgr:IsActive("trialroad_battle_failure_window") then
    return
  end
  Z.UIMgr:GotoMainView()
  Z.UIMgr:OpenView("trialroad_battle_failure_window")
end

function UnionVM:CheckSDKGroupValid()
  local accountData = Z.DataMgr.Get("account_data")
  return accountData.LoginType and (accountData.LoginType == E.LoginType.QQ or accountData.LoginType == E.LoginType.WeChat)
end

function UnionVM:MemberJoinGroup()
  if not self:IsBindGroup() then
    Z.TipsVM.ShowTips(1000575)
  elseif Z.GameContext.IsPlayInMobile and self:CheckSDKGroupValid() then
    if not self:IsJoinGroup() then
      self:CallJoinGroup()
    else
      Z.TipsVM.ShowTips(1000576)
    end
  else
    local curGroupType = self:GetBindGroupType()
    if curGroupType == TENCENT_DEFINE.GROUP_CHANNEL.QQ then
      local unionInfo = self:GetPlayerUnionInfo()
      if unionInfo.groupId ~= "" then
        Z.LuaBridge.SystemCopy(unionInfo.groupId)
        Z.TipsVM.ShowTips(1000577)
      elseif self.unionData_.SDKGroupInfo.GroupId ~= "" then
        Z.LuaBridge.SystemCopy(self.unionData_.SDKGroupInfo.GroupId)
        Z.TipsVM.ShowTips(1000577)
      else
        logError("[Union SDK Group] Unexpected error")
      end
    elseif curGroupType == TENCENT_DEFINE.GROUP_CHANNEL.WeChat then
      Z.TipsVM.ShowTips(1000578)
    end
  end
end

function UnionVM:IsBindGroup()
  local unionInfo = self:GetPlayerUnionInfo()
  local unionData = Z.DataMgr.Get("union_data")
  if unionInfo.groupType ~= TENCENT_DEFINE.GROUP_CHANNEL.None and unionInfo.groupId ~= "" then
    return true
  else
    return unionData.SDKGroupInfo.BindState == 1
  end
end

function UnionVM:IsJoinGroup()
  local unionData = Z.DataMgr.Get("union_data")
  return self:IsBindGroup() and unionData.SDKGroupInfo.GroupRelation >= 1 and unionData.SDKGroupInfo.GroupRelation <= 3
end

function UnionVM:GetBindGroupType()
  local unionInfo = self:GetPlayerUnionInfo()
  if unionInfo.groupType ~= TENCENT_DEFINE.GROUP_CHANNEL.None and unionInfo.groupId ~= "" then
    return unionInfo.groupType
  else
    local unionData = Z.DataMgr.Get("union_data")
    if not self:IsBindGroup() then
      return TENCENT_DEFINE.GROUP_CHANNEL.None
    elseif unionData.SDKGroupInfo.GroupId == "" then
      return TENCENT_DEFINE.GROUP_CHANNEL.WeChat
    else
      return TENCENT_DEFINE.GROUP_CHANNEL.QQ
    end
  end
end

function UnionVM:CallGetGroupState()
  local unionInfo = self:GetPlayerUnionInfo()
  local accountData = Z.DataMgr.Get("account_data")
  local serverData = Z.DataMgr.Get("server_data")
  local unionId = tostring(unionInfo.baseInfo.Id)
  if accountData.LoginType == E.LoginType.QQ then
    local zoneId = tostring(serverData:GetCurrentZoneId())
    local extraJson = cjson.encode({areaID = zoneId})
    Z.SDKTencent.GetGroupState(SDK_GROUP_CHANNEL.QQ, unionId, zoneId, extraJson)
  elseif accountData.LoginType == E.LoginType.WeChat then
    Z.SDKTencent.GetGroupState(SDK_GROUP_CHANNEL.WeChat, unionId)
  end
end

function UnionVM:CallGetGroupRelation()
  local unionInfo = self:GetPlayerUnionInfo()
  local accountData = Z.DataMgr.Get("account_data")
  local unionData = Z.DataMgr.Get("union_data")
  if accountData.LoginType == E.LoginType.QQ then
    local groupId = unionData.SDKGroupInfo.GroupId
    Z.SDKTencent.GetGroupRelation(SDK_GROUP_CHANNEL.QQ, groupId)
  elseif accountData.LoginType == E.LoginType.WeChat then
    local unionId = tostring(unionInfo.baseInfo.Id)
    Z.SDKTencent.GetGroupRelation(SDK_GROUP_CHANNEL.WeChat, unionId)
  end
end

function UnionVM:CallCreateGroup()
  local unionInfo = self:GetPlayerUnionInfo()
  local accountData = Z.DataMgr.Get("account_data")
  local serverData = Z.DataMgr.Get("server_data")
  local unionId = tostring(unionInfo.baseInfo.Id)
  local unionName = unionInfo.baseInfo.Name
  local playerName = Z.ContainerMgr.CharSerialize.charBase.name
  if accountData.LoginType == E.LoginType.QQ then
    local zoneId = tostring(serverData:GetCurrentZoneId())
    local charId = tostring(Z.ContainerMgr.CharSerialize.charBase.charId)
    local extraJson = cjson.encode({areaID = zoneId})
    Z.SDKTencent.CreateGroup(SDK_GROUP_CHANNEL.QQ, unionId, unionName, playerName, zoneId, charId, extraJson)
  elseif accountData.LoginType == E.LoginType.WeChat then
    Z.SDKTencent.CreateGroup(SDK_GROUP_CHANNEL.WeChat, unionId, unionName, playerName)
  end
end

function UnionVM:CallJoinGroup()
  local unionInfo = self:GetPlayerUnionInfo()
  local unionData = Z.DataMgr.Get("union_data")
  local accountData = Z.DataMgr.Get("account_data")
  local serverData = Z.DataMgr.Get("server_data")
  local unionId = tostring(unionInfo.baseInfo.Id)
  if accountData.LoginType == E.LoginType.QQ then
    local zoneId = tostring(serverData:GetCurrentZoneId())
    local charId = tostring(Z.ContainerMgr.CharSerialize.charBase.charId)
    local groupId = unionData.SDKGroupInfo.GroupId
    local extraJson = cjson.encode({areaID = zoneId})
    Z.SDKTencent.JoinGroup(SDK_GROUP_CHANNEL.QQ, unionId, zoneId, charId, groupId, extraJson)
  elseif accountData.LoginType == E.LoginType.WeChat then
    Z.SDKTencent.JoinGroup(SDK_GROUP_CHANNEL.WeChat, unionId)
  end
end

function UnionVM:CallBindGroup()
  local accountData = Z.DataMgr.Get("account_data")
  if accountData.LoginType ~= E.LoginType.QQ then
    return
  end
  local unionInfo = self:GetPlayerUnionInfo()
  local unionData = Z.DataMgr.Get("union_data")
  local serverData = Z.DataMgr.Get("server_data")
  local unionId = tostring(unionInfo.baseInfo.Id)
  local zoneId = tostring(serverData:GetCurrentZoneId())
  local charId = tostring(Z.ContainerMgr.CharSerialize.charBase.charId)
  local groupId = unionData.SDKGroupInfo.GroupId
  local groupName = unionData.SDKGroupInfo.GroupName
  local extraJson = cjson.encode({areaID = zoneId})
  Z.SDKTencent.BindGroup(SDK_GROUP_CHANNEL.QQ, unionId, zoneId, charId, groupId, groupName, extraJson)
end

function UnionVM:CallUnbindGroup()
  local accountData = Z.DataMgr.Get("account_data")
  local serverData = Z.DataMgr.Get("server_data")
  local unionInfo = self:GetPlayerUnionInfo()
  local unionId = tostring(unionInfo.baseInfo.Id)
  if accountData.LoginType == E.LoginType.QQ then
    local unionName = unionInfo.baseInfo.Name
    local zoneId = tostring(serverData:GetCurrentZoneId())
    local charId = tostring(Z.ContainerMgr.CharSerialize.charBase.charId)
    local extraJson = cjson.encode({areaID = zoneId})
    Z.SDKTencent.UnbindGroup(SDK_GROUP_CHANNEL.QQ, unionId, unionName, zoneId, charId, extraJson)
  elseif accountData.LoginType == E.LoginType.WeChat then
    Z.SDKTencent.UnbindGroup(SDK_GROUP_CHANNEL.WeChat, unionId)
  end
end

function UnionVM:AsyncUnionGetAllBossData(cancelToken)
  local unionId = self:GetPlayerUnionId()
  local unionGetAllBossDataRequest = {unionId = unionId}
  local reply = worldProxy.UnionGetAllBossData(unionGetAllBossDataRequest, cancelToken)
  if CheckErrorCode(reply.errCode) then
    local unionData = Z.DataMgr.Get("union_data")
    unionData:SetUnionAllRiadBossData(reply.bossDatas)
  end
  return nil
end

function UnionVM:AsyncGetRaidDungeonPassInfo(bossId, cancelToken)
  local unionId = self:GetPlayerUnionId()
  local unionGetKillBossDataRequest = {unionId = unionId, bossId = bossId}
  local reply = worldProxy.UnionGetKillBossData(unionGetKillBossDataRequest, cancelToken)
  if CheckErrorCode(reply.errCode) then
    return reply
  end
  return nil
end

return UnionVM
