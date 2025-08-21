local FishingRed = {}

function FishingRed.InitFishIllustratedRed()
  local fishingAreaDatas_ = Z.TableMgr.GetTable("FishingAreaTableMgr").GetDatas()
  local fishTypeDatas = Z.TableMgr.GetTable("FishingTypeTableMgr").GetDatas()
  local countDict = {}
  for _, area in pairs(fishingAreaDatas_) do
    local areaKey_ = "FishingAreaTab_" .. area.SceneObjectId
    Z.RedPointMgr.AddChildNodeData(E.RedType.FishingIllustratedTab, E.RedType.FishingIllustratedAreaTab, areaKey_)
    countDict[area.SceneObjectId] = {}
    for _, fishType in pairs(fishTypeDatas) do
      local fishTypeKey_ = "FishingType_" .. area.SceneObjectId .. "_" .. fishType.Type
      Z.RedPointMgr.AddChildNodeData(areaKey_, E.RedType.FishingIllustratedFishTypeTab, fishTypeKey_)
      countDict[area.SceneObjectId][fishType.Type] = 0
    end
  end
  for _, area in pairs(fishingAreaDatas_) do
    for _, fish in pairs(area.FishGroup) do
      local fishCfg = Z.TableMgr.GetTable("FishingTableMgr").GetRow(fish)
      if fishCfg and Z.ContainerMgr.CharSerialize.fishSetting.fishRecords[fish] and not Z.ContainerMgr.CharSerialize.fishSetting.fishRecords[fish].firstFlag then
        local num_ = countDict[area.SceneObjectId][fishCfg.Type]
        countDict[area.SceneObjectId][fishCfg.Type] = num_ + 1
      end
    end
  end
  for area, typeList in pairs(countDict) do
    for type, count in pairs(typeList) do
      local key = "FishingType_" .. area .. "_" .. type
      Z.RedPointMgr.UpdateNodeCount(key, count)
    end
  end
end

function FishingRed.InitLevelRewardRed()
  local fishingData = Z.DataMgr.Get("fishing_data")
  local curLevel = fishingData:GetFishingLevelByExp()
  local levelCfgs = Z.TableMgr.GetTable("FishingLevelTableMgr").GetDatas()
  local count = 0
  for _, v in pairs(levelCfgs) do
    if 0 < v.ItemAward then
      local isGet = Z.ContainerMgr.CharSerialize.fishSetting.levelReward and Z.ContainerMgr.CharSerialize.fishSetting.levelReward[v.FishingLevel] or false
      local canGet = curLevel >= v.FishingLevel
      local rewardKey = "FishingLevelAward_" .. v.FishingLevel
      local countTmp = 0
      if canGet and not isGet then
        countTmp = 1
        count = count + 1
      end
      Z.RedPointMgr.AddChildNodeData(E.RedType.FishingShopLevel, E.RedType.FishingLevelAwardBtn, rewardKey)
      Z.RedPointMgr.UpdateNodeCount(rewardKey, countTmp)
    end
  end
  Z.RedPointMgr.UpdateNodeCount(E.RedType.FishingLevelAwardAllBtn, count)
end

function FishingRed.RefreshIllustratedItemRed()
  local fishingAreaDatas_ = Z.TableMgr.GetTable("FishingAreaTableMgr").GetDatas()
  local fishTypeDatas = Z.TableMgr.GetTable("FishingTypeTableMgr").GetDatas()
  local countDict = {}
  for _, area in pairs(fishingAreaDatas_) do
    countDict[area.SceneObjectId] = {}
    for _, fishType in pairs(fishTypeDatas) do
      countDict[area.SceneObjectId][fishType.Type] = 0
    end
  end
  for _, area in pairs(fishingAreaDatas_) do
    for _, fish in pairs(area.FishGroup) do
      local fishCfg = Z.TableMgr.GetTable("FishingTableMgr").GetRow(fish)
      if fishCfg and Z.ContainerMgr.CharSerialize.fishSetting.fishRecords[fish] and not Z.ContainerMgr.CharSerialize.fishSetting.fishRecords[fish].firstFlag then
        local num_ = countDict[area.SceneObjectId][fishCfg.Type]
        countDict[area.SceneObjectId][fishCfg.Type] = num_ + 1
      end
    end
  end
  for area, typeList in pairs(countDict) do
    for type, count in pairs(typeList) do
      local key = "FishingType_" .. area .. "_" .. type
      Z.RedPointMgr.UpdateNodeCount(key, count)
    end
  end
end

function FishingRed.RefreshLevelRewardRed()
  local fishingData = Z.DataMgr.Get("fishing_data")
  local curLevel = fishingData:GetFishingLevelByExp()
  local levelCfgs = Z.TableMgr.GetTable("FishingLevelTableMgr").GetDatas()
  local count = 0
  for _, v in pairs(levelCfgs) do
    if 0 < v.ItemAward then
      local isGet = Z.ContainerMgr.CharSerialize.fishSetting.levelReward[v.FishingLevel]
      local canGet = curLevel >= v.FishingLevel
      local rewardKey = "FishingLevelAward_" .. v.FishingLevel
      local countTmp = 0
      if canGet and not isGet then
        countTmp = 1
        count = count + 1
      end
      Z.RedPointMgr.UpdateNodeCount(rewardKey, countTmp)
    end
  end
  Z.RedPointMgr.UpdateNodeCount(E.RedType.FishingLevelAwardAllBtn, count)
end

function FishingRed.LoadIllustratedAreaTabRedItem(area, view, parentTrans)
  local areaKey_ = "FishingAreaTab_" .. area
  Z.RedPointMgr.LoadRedDotItem(areaKey_, view, parentTrans)
end

function FishingRed.RemoveIllustratedAreaTabRedItem(area)
  local areaKey_ = "FishingAreaTab_" .. area
  Z.RedPointMgr.RemoveNodeItem(areaKey_)
end

function FishingRed.LoadIllustratedTypeRedItem(area, fishType, view, parentTrans)
  local fishTypeKey_ = "FishingType_" .. area .. "_" .. fishType
  Z.RedPointMgr.LoadRedDotItem(fishTypeKey_, view, parentTrans)
end

function FishingRed.LoadShopLevelAwardRedItem(level, view, parentTrans)
  local rewardKey = "FishingLevelAward_" .. level
  Z.RedPointMgr.LoadRedDotItem(rewardKey, view, parentTrans)
end

return FishingRed
