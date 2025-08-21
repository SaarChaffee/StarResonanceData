local super = require("ui.model.data_base")
local HouseData = class("HouseData", super)

function HouseData:ctor()
  super.ctor(self)
  self:Clear()
end

E.HouseItemUnlockType = {
  normal = 0,
  item = 1,
  condition = 2
}

function HouseData:Init()
  self.IsEntering = false
  self.HousingItems = {}
  self.HousingItemGroupTypes = {}
  self.HousingItemGroupItems = {}
  self.homelandBaseInfo_ = {}
  self.houseOwnerCharId_ = 0
  self.name_ = nil
  self.introduction_ = nil
  self.checkInContent_ = nil
  self.transferCommunity_ = nil
  self.authorityInfo_ = nil
  self.furnitureState_ = nil
  self.HosingTypeItems = {}
  self.CancelSource = Z.CancelSource.Rent()
  self.cohabitantInfo_ = {}
  self.invitationList_ = {}
  self.invitationTimeDict = {}
  self.buildInfos_ = {}
  self.innerDecorationInfo_ = {}
  self.outerDecorationInfo_ = {}
  self.taskList = nil
  self.taskInfo = nil
  self.CurFarmInteractionConfigId = 0
  self.CuyFarmInteractionUuid = 0
  self.outerEmptyLand_ = 0
  self.innerEmptyLand_ = 0
end

function HouseData:Clear()
  self:Init()
end

function HouseData:InitCfgData()
  self.HosingTypeItems = {}
  self.HousingItems = Z.TableMgr.GetTable("HousingItemsMgr").GetDatas()
  for _, value in pairs(self.HousingItems) do
    if value.Exist then
      local HousingItemsType = Z.TableMgr.GetRow("HousingItemsTypeMgr", value.Type)
      if HousingItemsType then
        local housingItemsTypeGroupRow = Z.TableMgr.GetRow("HousingItemsTypeGroupMgr", HousingItemsType.GroupId)
        if housingItemsTypeGroupRow then
          if self.HousingItemGroupItems[HousingItemsType.GroupId] == nil then
            self.HousingItemGroupItems[HousingItemsType.GroupId] = {}
            table.insert(self.HousingItemGroupTypes, HousingItemsType.GroupId)
          end
          local groupData = self.HousingItemGroupItems[HousingItemsType.GroupId]
          groupData[#groupData + 1] = value
          if self.HosingTypeItems[housingItemsTypeGroupRow.BuildGroup] == nil then
            self.HosingTypeItems[housingItemsTypeGroupRow.BuildGroup] = {}
          end
          local data = self.HosingTypeItems[housingItemsTypeGroupRow.BuildGroup]
          data[#data + 1] = value
        end
      end
    end
  end
  table.sort(self.HousingItemGroupTypes, function(leftId, rightId)
    local leftGroupRow = Z.TableMgr.GetRow("HousingItemsTypeGroupMgr", leftId)
    local rightGroupRow = Z.TableMgr.GetRow("HousingItemsTypeGroupMgr", rightId)
    if leftGroupRow and rightGroupRow then
      return leftGroupRow.Sort < rightGroupRow.Sort
    end
    return false
  end)
  for index, value in pairs(self.HosingTypeItems) do
    table.sort(value, function(a, b)
      return a.SortId < b.SortId
    end)
  end
end

function HouseData:GetHomelandBaseInfo()
  return self.homelandBaseInfo_
end

function HouseData:SetHomelandBaseInfo(info)
  self.taskList = nil
  self.taskInfo = nil
  self.homelandBaseInfo_ = info
  self.name_ = info.name ~= "" and info.name or nil
  self.introduction_ = info.introduction ~= "" and info.introduction or nil
  self.checkInContent_ = info.checkInContent ~= "" and info.checkInContent or nil
  self.transferCommunity_ = info.transferCommunity
  self.houseOwnerCharId_ = info.houseOwnerCharId
  self.authorityInfo_ = info.authorityInfo
  self.furnitureState_ = info.furnitureState
  self.innerDecorationInfo_ = info.innerDecorationInfo
  self.outerDecorationInfo_ = info.outerDecorationInfo
  self.outerEmptyLand_ = info.outerEmptyLand
  self.innerEmptyLand_ = info.innerEmptyLand
  self.flowersNum_ = info.flowersNum
  if info.cohabitant then
    self:SetHomeCohabitantInfo(info.cohabitant)
  end
  self.homeLevel_ = info.level
  self.homeExp_ = info.exp
  self:SetHouseCleanValue(info.cleanliness)
  self.homeLandSellShopInfo = info.homeLandSellShopInfo
end

function HouseData:GetFlowerNum()
  return self.flowersNum_ or 0
end

function HouseData:GetHouseName()
  return self.name_
end

function HouseData:SetHouseName(name)
  self.name_ = name
end

function HouseData:GetHouseIntroduc()
  return self.introduction_
end

function HouseData:SetHouseIntroduc(introduc)
  self.introduction_ = introduc
end

function HouseData:GetFieldId()
  return self.homelandBaseInfo_.fieldId
end

function HouseData:GetHouseLevel()
  if self.homeLevel_ == nil then
    return 0
  end
  return self.homeLevel_
end

function HouseData:GetHouseMaxLevel()
  local maxLevel = 0
  local levelDatas = self:GetAllLevelData()
  for k, v in pairs(levelDatas) do
    if maxLevel < v.Id then
      maxLevel = v.Id
    end
  end
  return maxLevel
end

function HouseData:GetHouseExp()
  if self.homeExp_ == nil then
    return 0
  end
  return self.homeExp_
end

function HouseData:SetHouseLevel(level)
  if self.homeLevel_ and self.homeLevel_ == level then
    return
  end
  self.homeLevel_ = level
  Z.EventMgr:Dispatch(Z.ConstValue.House.HouseLevelChange, level)
end

function HouseData:SetHouseExp(exp)
  self.homeExp_ = exp
end

function HouseData:GetHouseCheckInContent()
  return self.checkInContent_
end

function HouseData:SetHouseCheckInContent(content)
  self.checkInContent_ = content
end

function HouseData:GetHomeCohabitantInfo()
  return self.cohabitantInfo_
end

function HouseData:GetHomeCohabitantCharIdByIndex(index)
  local count = 1
  for charId, _ in pairs(self.cohabitantInfo_) do
    if count == index then
      return charId
    end
    count = count + 1
  end
  return nil
end

function HouseData:GetHomeCohabitantCount()
  if not self.cohabitantInfo_ then
    return 0
  end
  local count = 0
  for _, _ in pairs(self.cohabitantInfo_) do
    count = count + 1
  end
  return count
end

function HouseData:SetHomeCohabitantInfo(info)
  self.cohabitantInfo_ = {}
  for charId, value in pairs(info) do
    self.cohabitantInfo_[charId] = value
  end
end

function HouseData:UpdateHomeCohabitantInfo(info)
  for charId, value in pairs(info) do
    if not self.cohabitantInfo_[charId] then
      self.cohabitantInfo_[charId] = {}
    end
    self.cohabitantInfo_[charId].playerAuthorityInfo = value.playerAuthorityInfo
    self.cohabitantInfo_[charId].quitCohabitant = value.quitCohabitant
  end
end

function HouseData:RemoveHomeCohabitantInfo(charId)
  if charId and self.cohabitantInfo_[charId] then
    self.cohabitantInfo_[charId] = nil
  end
end

function HouseData:GetHomeCohabitantInfoByCharId(charId)
  return self.cohabitantInfo_[charId]
end

function HouseData:GetHomeCharLimit(limitType, charId)
  if self:IsCharHomeOwner(charId) then
    return true
  end
  local cohabitantInfo = self.cohabitantInfo_[charId]
  if not (cohabitantInfo and cohabitantInfo.playerAuthorityInfo) or not cohabitantInfo.playerAuthorityInfo.authority then
    return false
  end
  return cohabitantInfo.playerAuthorityInfo.authority[limitType]
end

function HouseData:GetPlayerHomeLimit(limitType)
  local charId = Z.ContainerMgr.CharSerialize.charId
  return self:GetHomeCharLimit(limitType, charId)
end

function HouseData:CheckPlayerFurnitureEditLimit(showTips)
  if not self:GetPlayerHomeLimit(E.HousePlayerLimitType.FurnitureEdit) then
    if showTips then
      Z.TipsVM.ShowTips(1044016)
    end
    return false
  end
  return true
end

function HouseData:GetHomeLimit(limitType)
  if not self.authorityInfo_ then
    return false
  end
  return self.authorityInfo_.authority[limitType]
end

function HouseData:SetAuthorityInfo(info)
  self.authorityInfo_ = info
end

function HouseData:GetEmptyLand()
  return self.outerEmptyLand_ + self.innerEmptyLand_
end

function HouseData:GetHomeBuildFurnitureCount(state)
  if not self.furnitureState_ or not self.furnitureState_[state] then
    return 0
  end
  return self.furnitureState_[state]
end

function HouseData:GetHomeFurnitureState()
  return self.furnitureState_
end

function HouseData:GetHomeTransferData()
  return self.transferCommunity_
end

function HouseData:SetHomeTransferData(data)
  self.transferCommunity_ = data
end

function HouseData:GetHomeOwnerCharId()
  return self.houseOwnerCharId_
end

function HouseData:SetHomeOwnerCharId(charId)
  self.houseOwnerCharId_ = charId
end

function HouseData:IsHomeOwner()
  return self:GetHomeOwnerCharId() == Z.ContainerMgr.CharSerialize.charBase.charId
end

function HouseData:IsCharHomeOwner(charId)
  return self:GetHomeOwnerCharId() == charId
end

function HouseData:GetHomeId()
  return Z.ContainerMgr.CharSerialize.communityHomeInfo.homelandId
end

function HouseData:GetCommunityId()
  return Z.ContainerMgr.CharSerialize.communityHomeInfo.communityId
end

function HouseData:GetHomeBuyCount()
  return Z.ContainerMgr.CharSerialize.communityHomeInfo.buyCount
end

function HouseData:GetInvitationList()
  return self.invitationList_
end

function HouseData:SetInvitationList(list)
  self.invitationList_ = list
  self.invitationTimeDict = {}
  for _, value in pairs(self.invitationList_) do
    self.invitationTimeDict[value.inviteeCharId] = value.time
  end
end

function HouseData:GetInvitationTimeByCharId(charId)
  return self.invitationTimeDict[charId] or 0
end

function HouseData:SetBuildInfos(buildType, infos)
  self.buildInfos_[buildType] = infos
end

function HouseData:GetBuildInfosByIndexAndType(buildType, index)
  local infos = self.buildInfos_[buildType]
  if infos then
    return infos[index]
  end
end

function HouseData:UnInit()
  self.CancelSource:Recycle()
  self:Clear()
end

function HouseData:OnLanguageChange()
  self.HouseLevelDatas = nil
end

function HouseData:GetAllLevelData()
  if self.HouseLevelDatas then
    return self.HouseLevelDatas
  end
  self.HouseLevelDatas = Z.TableMgr.GetTable("HomeLevelTableMgr").GetDatas()
  table.sort(self.HouseLevelDatas, function(a, b)
    return a.Id < b.Id
  end)
  return self.HouseLevelDatas
end

function HouseData:GetHouseCleanValue()
  if self.cleanliness_ == nil then
    return 0
  end
  return self.cleanliness_
end

function HouseData:GetHouseCleanLevel()
  local cleanliness_ = self:GetHouseCleanValue()
  for k, v in pairs(Z.GlobalHome.HomeCleanLevel) do
    if v <= cleanliness_ then
      return k
    end
  end
  return #Z.GlobalHome.HomeCleanLevel + 1
end

function HouseData:SetHouseCleanValue(cleanliness)
  Z.EventMgr:Dispatch(Z.ConstValue.House.HouseCleaninessChange)
  self.cleanliness_ = cleanliness
end

function HouseData:GetHouseLightLevel(serverValue)
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  if currentStageType == Z.EStageType.CommunityDungeon then
    if self.outerDecorationInfo_ and self.outerDecorationInfo_.lamplightInfo and self.outerDecorationInfo_.lamplightInfo.lamplightLevel then
      if serverValue then
        return self.outerDecorationInfo_.lamplightInfo.lamplightLevel
      else
        return self.outerDecorationInfo_.lamplightInfo.lamplightLevel / 1000
      end
    end
  elseif currentStageType == Z.EStageType.HomelandDungeon and self.innerDecorationInfo_ and self.innerDecorationInfo_.lamplightInfo and self.innerDecorationInfo_.lamplightInfo.lamplightLevel then
    if serverValue then
      return self.innerDecorationInfo_.lamplightInfo.lamplightLevel
    else
      return self.innerDecorationInfo_.lamplightInfo.lamplightLevel / 1000
    end
  end
  return 0
end

function HouseData:GetHouseLightColor()
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  if currentStageType == Z.EStageType.CommunityDungeon then
    if self.outerDecorationInfo_ and self.outerDecorationInfo_.lamplightInfo then
      return self.outerDecorationInfo_.lamplightInfo.lamplightColor
    end
  elseif currentStageType == Z.EStageType.HomelandDungeon and self.innerDecorationInfo_ and self.innerDecorationInfo_.lamplightInfo then
    return self.innerDecorationInfo_.lamplightInfo.lamplightColor
  end
  return nil
end

function HouseData:GetHouseEnvId()
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  if currentStageType == Z.EStageType.CommunityDungeon then
    if self.outerDecorationInfo_ and self.outerDecorationInfo_.lamplightInfo then
      return self.outerDecorationInfo_.lamplightInfo.dayNightId
    else
      return Z.GlobalHome.HomeDayNightLightDefault
    end
  elseif currentStageType == Z.EStageType.HomelandDungeon then
    if self.innerDecorationInfo_ and self.innerDecorationInfo_.lamplightInfo then
      return self.innerDecorationInfo_.lamplightInfo.dayNightId
    else
      return Z.GlobalHome.HomeEnvironmentLightDefault
    end
  end
  return 0
end

function HouseData:GetHouseLightMode()
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  if currentStageType == Z.EStageType.CommunityDungeon then
    if self.outerDecorationInfo_ and self.outerDecorationInfo_.lamplightInfo then
      return self.outerDecorationInfo_.lamplightInfo.mode
    end
  elseif currentStageType == Z.EStageType.HomelandDungeon and self.innerDecorationInfo_ and self.innerDecorationInfo_.lamplightInfo then
    return self.innerDecorationInfo_.lamplightInfo.mode
  end
  return 0
end

function HouseData:GetHouseEnvColor()
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  if currentStageType == Z.EStageType.CommunityDungeon then
    if self.outerDecorationInfo_ and self.outerDecorationInfo_.lamplightInfo then
      local vec3 = self.outerDecorationInfo_.lamplightInfo.lamplightColor
      if vec3 then
        return {
          h = vec3.x,
          s = vec3.y,
          v = vec3.z
        }
      end
    end
  elseif currentStageType == Z.EStageType.HomelandDungeon and self.innerDecorationInfo_ and self.innerDecorationInfo_.lamplightInfo then
    local vec3 = self.innerDecorationInfo_.lamplightInfo.lamplightColor
    if vec3 then
      return {
        h = vec3.x,
        s = vec3.y,
        v = vec3.z
      }
    end
  end
  return nil
end

function HouseData:UpdateDecorationInfo(decorationInfo, isOuter)
  if isOuter then
    if not self.outerDecorationInfo_ then
      self.outerDecorationInfo_ = {}
    end
    self:doUpdateDecorationInfo(self.outerDecorationInfo_, decorationInfo)
  else
    if not self.innerDecorationInfo_ then
      self.innerDecorationInfo_ = {}
    end
    self:doUpdateDecorationInfo(self.innerDecorationInfo_, decorationInfo)
  end
end

function HouseData:doUpdateDecorationInfo(curDecorationInfo, newDecorationInfo)
  if newDecorationInfo.lamplightInfo then
    if not curDecorationInfo.lamplightInfo then
      curDecorationInfo.lamplightInfo = {}
    end
    curDecorationInfo.lamplightInfo.lamplightLevel = newDecorationInfo.lamplightInfo.lamplightLevel
    curDecorationInfo.lamplightInfo.lamplightColor = newDecorationInfo.lamplightInfo.lamplightColor
    curDecorationInfo.lamplightInfo.dayNightId = newDecorationInfo.lamplightInfo.dayNightId
    curDecorationInfo.lamplightInfo.mode = newDecorationInfo.lamplightInfo.mode
  end
end

function HouseData:GetInnterDecorationInfo()
  return self.innerDecorationInfo_
end

function HouseData:GetOuterDecorationInfo()
  return self.outerDecorationInfo_
end

function HouseData:SetHouseQuestInfo(newInfo)
  local newTaskList = {}
  local hasFinish = false
  self.taskInfo = newInfo
  for k, v in pairs(newInfo.curTaskMap) do
    local taskData = {}
    taskData.id = k
    taskData.isFinished = v.finished
    if self.taskList then
      for _, oldTask in pairs(self.taskList) do
        if oldTask.id == taskData.id and not oldTask.isFinished and taskData.isFinished then
          Z.EventMgr:Dispatch(Z.ConstValue.House.HouseQuestFinished, taskData.id)
        end
      end
    end
    table.insert(newTaskList, taskData)
  end
  self.taskList = newTaskList
  Z.EventMgr:Dispatch(Z.ConstValue.House.HouseQuestChanged)
end

function HouseData:GetAllTaskDatas()
  if self.taskList then
    self:SortQuest()
    return self.taskList
  end
  self.taskList = {}
  local taskInfo = self:GetTaskInfo()
  if not taskInfo then
    return self.taskList
  end
  for k, v in pairs(taskInfo.curTaskMap) do
    local taskData = {}
    taskData.id = k
    taskData.isFinished = v.finished
    table.insert(self.taskList, taskData)
  end
  self:SortQuest()
  return self.taskList
end

function HouseData:SortQuest()
  table.sort(self.taskList, function(atask, btask)
    if atask.isFinished ~= btask.isFinished then
      if atask.isFinished then
        return false
      else
        return true
      end
    end
    local aHomeTaskTableRow = Z.TableMgr.GetRow("HomeTaskTableMgr", atask.id)
    local bHomeTaskTableRow = Z.TableMgr.GetRow("HomeTaskTableMgr", btask.id)
    if aHomeTaskTableRow.Rank ~= bHomeTaskTableRow.Rank then
      return aHomeTaskTableRow.Rank < bHomeTaskTableRow.Rank
    end
    return atask.id < btask.id
  end)
end

function HouseData:GetTaskInfo()
  local cohabitantInfo = self:GetHomeCohabitantInfoByCharId(Z.ContainerMgr.CharSerialize.charId)
  if not self.taskInfo and cohabitantInfo then
    self.taskInfo = cohabitantInfo.homeLandPlayerTaskInfo
  end
  return self.taskInfo
end

function HouseData:GetHouseSellDataMap()
  self.sellDataMap = {}
  self.sellDataMap.highList = {}
  self.sellDataMap.normalList = {}
  self.sellDataMap.lowList = {}
  if not self.homeLandSellShopInfo then
    return self.sellDataMap
  end
  for k, v in pairs(self.homeLandSellShopInfo.collectingItems) do
    local data = {}
    data.key = k
    data.itemId = v.itemId
    data.collectedNum = v.collectedNum
    data.collectPrice = v.collectPrice
    data.IsHigh = v.IsHigh
    if data.IsHigh then
      table.insert(self.sellDataMap.highList, data)
    else
      table.insert(self.sellDataMap.normalList, data)
    end
  end
  return self.sellDataMap
end

function HouseData:SetHouseSellShopInfo(homeLandSellShopInfo)
  self.homeLandSellShopInfo = homeLandSellShopInfo
  Z.EventMgr:Dispatch(Z.ConstValue.House.HouseSellInfoChanged)
end

return HouseData
