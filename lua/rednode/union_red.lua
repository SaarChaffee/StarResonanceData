local UnionRed = {}
local unionSubRedIdTab = {}
local unionWardanceRewardCountID = 24

function UnionRed.InitUnionActiveItemRed()
  local redDataList_ = UnionRed.GetUnionActiveRedDataList()
  for index, redData in pairs(redDataList_) do
    local childRedId = UnionRed.GetUnionActiveId(redData.awardId)
    local count_ = 0
    if redData.isCanGet then
      count_ = 1
    end
    Z.RedPointMgr.AddChildNodeData(E.RedType.UnionActiveTab, E.RedType.UnionActiveItem, childRedId)
    Z.RedPointMgr.UpdateNodeCount(childRedId, count_)
  end
end

function UnionRed.RemoveUnionActiveRedItem(awardId, view)
  local childRedId = UnionRed.GetUnionActiveId(awardId)
  Z.RedPointMgr.RemoveNodeItem(childRedId, view)
  unionSubRedIdTab[awardId] = nil
end

function UnionRed.GetUnionActiveRedDataList()
  local redDataList_ = {}
  local unionVM_ = Z.VMMgr.GetVM("union")
  local unionData_ = Z.DataMgr.Get("union_data")
  local curActiveValue_ = unionVM_:GetUnionResourceCount(E.UnionResourceId.Active)
  local isEnoughGetTime_ = unionVM_:IsEnoughActiveGetTime()
  local allAwardItemList_ = Z.TableMgr.GetTable("UnionActiveValueTableMgr"):GetDatas()
  for index, config in ipairs(allAwardItemList_) do
    local isReached = curActiveValue_ >= config.ActiveValue
    local isHadGet = unionData_:IsUnionActiveHadGet(config.Id)
    local isCanGet = isEnoughGetTime_ and isReached and not isHadGet
    redDataList_[index] = {
      awardId = config.AwardId,
      isCanGet = isCanGet
    }
  end
  return redDataList_
end

function UnionRed.GetUnionActiveId(awardId)
  local childRedId
  if unionSubRedIdTab[awardId] then
    childRedId = unionSubRedIdTab[awardId]
  else
    childRedId = string.zconcat("RedType.UnionActiveItem", awardId)
    unionSubRedIdTab[awardId] = childRedId
  end
  return childRedId
end

function UnionRed.RefreshUnionActiveItemRed()
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  local isShowRed = false
  if unionId == 0 then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionActiveTab, 0)
  else
    local redDataList = UnionRed.GetUnionActiveRedDataList()
    for id, redData in pairs(redDataList) do
      local childRedId = UnionRed.GetUnionActiveId(redData.awardId)
      local count = 0
      if redData.isCanGet then
        count = 1
        isShowRed = true
      end
      Z.RedPointMgr.UpdateNodeCount(childRedId, count)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.UnionFuncId.Active, isShowRed)
end

function UnionRed.LoadUnionActiveItem(awardId, view, parentTrans)
  local childRedId = UnionRed.GetUnionActiveId(awardId)
  Z.RedPointMgr.LoadRedDotItem(childRedId, view, parentTrans)
end

function UnionRed.InitUnionBuildingItemRed()
  local redDataList_ = UnionRed.GetUnionBuildingRedDataList()
  for index, redData in pairs(redDataList_) do
    local childRedId = UnionRed.GetUnionBuildingId(redData.Id)
    local childRedBtnId = "UnionBuildUpgradeBtn_" .. childRedId
    local count_ = 0
    if redData.showRed then
      count_ = 1
    end
    Z.RedPointMgr.AddChildNodeData(E.RedType.UnionBuildTab, E.RedType.UnionBuildItem, childRedId)
    Z.RedPointMgr.AddChildNodeData(childRedId, E.RedType.UnionBuildUpgradeBtn, childRedBtnId)
    Z.RedPointMgr.UpdateNodeCount(childRedBtnId, count_)
  end
end

function UnionRed.RemoveUnionBuildingRedItem(Id, view)
  local childRedId = UnionRed.GetUnionBuildingId(Id)
  Z.RedPointMgr.RemoveNodeItem(childRedId, view)
  unionSubRedIdTab[Id] = nil
end

function UnionRed.GetUnionBuildingRedDataList(isUnlock)
  local unionVM_ = Z.VMMgr.GetVM("union")
  local redDataList_ = {}
  local unionBuildingTableMgr_ = Z.TableMgr.GetTable("UnionBuildingTableMgr")
  local dataList_ = unionBuildingTableMgr_.GetDatas()
  for key, value in pairs(dataList_) do
    local curLv_ = unionVM_:GetUnionBuildLv(value.Id)
    local canUpgrade_ = unionVM_:CheckBuildUpgrade(value.Id, curLv_)
    local canPowerModify_ = unionVM_:CheckPlayerPower(E.UnionPowerDef.UpgradeBuilding)
    local unlock = isUnlock and isUnlock or unionVM_:GetUnionSceneIsUnlock()
    redDataList_[value.Id] = {
      Id = value.Id,
      showRed = canUpgrade_ and canPowerModify_ and unlock
    }
  end
  return redDataList_
end

function UnionRed.GetUnionBuildingId(Id)
  local childRedId
  if unionSubRedIdTab[Id] then
    childRedId = unionSubRedIdTab[Id]
  else
    childRedId = string.zconcat("RedType.UnionBuildingItem", Id)
    unionSubRedIdTab[Id] = childRedId
  end
  return childRedId
end

function UnionRed.RefreshUnionBuildingItemRed(sceneUnlock)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionBuildTab, 0)
  else
    local redDataList = UnionRed.GetUnionBuildingRedDataList(sceneUnlock)
    for id, redData in pairs(redDataList) do
      local childRedId = UnionRed.GetUnionBuildingId(redData.Id)
      local childRedBtnId = "UnionBuildUpgradeBtn_" .. childRedId
      local count = 0
      if redData.showRed then
        count = 1
      end
      Z.RedPointMgr.UpdateNodeCount(childRedBtnId, count)
    end
  end
end

function UnionRed.RefreshHuntRecommendRed(isInTime)
  local isRed = UnionRed.RefreshUnionHuntRed() or UnionRed.RefreshUnionHuntRecommendRed(isInTime)
  isRed = isRed and not UnionRed.UnionHuntRedChecked()
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.FunctionID.UnionHunt, isRed)
end

function UnionRed.RefreshDanceRecommendRed(isInTime)
  local isRed = UnionRed.RefreshUnionWarDanceRed(isInTime)
  isRed = isRed and not UnionRed.UnionWarDanceRedChecked()
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.FunctionID.UnionWarDance, isRed)
end

function UnionRed.RefreshUnionHuntRed()
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  local isRed = false
  if unionId == 0 or not unionVM:CheckUnionHuntUnlock() then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionBuildTab, 0)
    Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionHuntCount, 0)
  else
    local huntActDunDonIds = {}
    for _, value in ipairs(Z.UnionActivityConfig.HuntActivityId) do
      if value[2] == E.UnionActivityType.UnionHunt then
        table.insert(huntActDunDonIds, value[1])
      end
    end
    for _, value in ipairs(huntActDunDonIds) do
      local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(value)
      if dungeonData == nil then
        return
      end
      local countLimit = dungeonData.CountLimit
      local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(countLimit)
      local normalAwardCount = 0
      if counterCfgData then
        if Z.ContainerMgr.CharSerialize.counterList.counterMap[countLimit] then
          normalAwardCount = counterCfgData.Limit - Z.ContainerMgr.CharSerialize.counterList.counterMap[countLimit].counter
        else
          normalAwardCount = counterCfgData.Limit - 0
        end
      end
      local isInTime = UnionRed.RefreshUnionHuntRecommendRed()
      local childHuntRedId = "union_hunt_red_" .. value
      Z.RedPointMgr.AddChildNodeData(E.RedType.UnionHuntCount, E.RedType.UnionHuntCount, childHuntRedId)
      local activityChecked = UnionRed.UnionHuntRedChecked()
      Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionHuntCount, not activityChecked and isInTime and normalAwardCount or 0)
      if isInTime and 0 < normalAwardCount then
        isRed = true
      end
    end
  end
  return isRed
end

function UnionRed.RefreshUnionHuntRecommendRed(isInTime)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  local isUnionSceneUnlock = unionVM:GetUnionSceneIsUnlock()
  if unionId == 0 or not isUnionSceneUnlock then
    return false
  end
  local switchVm = Z.VMMgr.GetVM("switch")
  if not switchVm.CheckFuncSwitch(E.UnionFuncId.Hunt) then
    return false
  end
  local unionActRow = Z.TableMgr.GetTable("UnionActivityTableMgr").GetRow(E.UnionActivityType.UnionHunt)
  if unionActRow == nil or unionActRow.TimerId == nil then
    return false
  end
  if isInTime == nil then
    isInTime = Z.TimeTools.CheckIsInTimeByTimeId(unionActRow.TimerId)
  end
  local isRed = false
  local countID = unionActRow.CounterId
  local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
  local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
  isRed = 0 < normalAwardCount and isInTime
  return isRed
end

function UnionRed.RefreshUnionWarDanceRed(isInTime)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  local unionId = unionVM:GetPlayerUnionId()
  local isUnionSceneUnlock = unionVM:GetUnionSceneIsUnlock()
  if unionId == 0 or not isUnionSceneUnlock then
    return false
  end
  if isInTime == nil then
    isInTime = unionWarDanceVM:isInWarDanceActivity()
  end
  local isRed = false
  local countID = unionWardanceRewardCountID
  local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
  local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
  local activityChecked = UnionRed.UnionWarDanceRedChecked()
  isRed = 0 < normalAwardCount and not activityChecked and isInTime
  Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionDanceCount, isRed and normalAwardCount or 0)
  return isRed
end

function UnionRed.UnionWarDanceRedChecked()
  local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
  return unionWarDanceData_:RecommendRedChecked()
end

function UnionRed.UnionHuntRedChecked()
  local unionData_ = Z.DataMgr.Get("union_data")
  return unionData_:HuntRecommendRedChecked()
end

function UnionRed.LoadUnionBuildItem(Id, view, parentTrans)
  local childRedId = UnionRed.GetUnionBuildingId(Id)
  Z.RedPointMgr.LoadRedDotItem(childRedId, view, parentTrans)
end

function UnionRed.LoadUnionBuildUpBtnItem(Id, view, parentTrans)
  local childRedId = UnionRed.GetUnionBuildingId(Id)
  local childRedBtnId = "UnionBuildUpgradeBtn_" .. childRedId
  Z.RedPointMgr.LoadRedDotItem(childRedBtnId, view, parentTrans)
end

function UnionRed.RemoveUnionBuildingUpBtnRedItem(Id, view)
  local childRedId = UnionRed.GetUnionBuildingId(Id)
  local childRedBtnId = "UnionBuildUpgradeBtn_" .. childRedId
  Z.RedPointMgr.RemoveNodeItem(childRedBtnId, view)
end

function UnionRed.CheckUnionSceneUnlockRed()
  local unionVM = Z.VMMgr.GetVM("union")
  local isHaveUnion = unionVM:GetPlayerUnionId() ~= 0
  local isUnlock, curState = unionVM:GetUnionSceneIsUnlock()
  local isShowRed = isHaveUnion and not isUnlock and curState == E.UnionUnlockState.IsCrowding and not unionVM:GetHasJoinUnionSceneUnlock()
  Z.RedPointMgr.UpdateNodeCount(E.RedType.UnionSceneUnlockBtnRed, isShowRed and 1 or 0)
end

function UnionRed.Init()
  Z.EventMgr:Add(Z.ConstValue.Union.UnionHuntRedRefresh, UnionRed.RefreshHuntRecommendRed)
  Z.EventMgr:Add(Z.ConstValue.Union.UnionWarDanceRedRefresh, UnionRed.RefreshDanceRecommendRed)
end

function UnionRed.UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Union.UnionHuntRedRefresh, UnionRed.RefreshHuntRecommendRed)
  Z.EventMgr:Remove(Z.ConstValue.Union.UnionWarDanceRedRefresh, UnionRed.RefreshDanceRecommendRed)
end

return UnionRed
