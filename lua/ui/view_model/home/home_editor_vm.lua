local HomeEditorVm = {}
local worldProxy = require("zproxy.world_proxy")
local EAreaParamenter = {
  [1] = Z.ConstValue.Home.BKR_HOME_ALIGN_MOVE,
  [2] = Z.ConstValue.Home.BKR_HOME_ALIGN_HIGHT,
  [3] = Z.ConstValue.Home.BKR_HOME_ALIGN_ROTATE
}
E.EHomeAlignType = {
  AlignMoveValue = 1,
  AlignHeightValue = 2,
  AlignAnglesValue = 3
}

function HomeEditorVm.IsSelfResident()
  local homeData = Z.DataMgr.Get("home_editor_data")
  local homeLandId = homeData:GetHomeLandId()
  if homeLandId ~= -1 then
    return true
  end
  return false
end

function HomeEditorVm.AsyncEnterEditState()
  local homeData = Z.DataMgr.Get("home_editor_data")
  local errorId = worldProxy.EnterEditState({}, homeData.CancelSource:CreateToken())
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
  return errorId
end

function HomeEditorVm.AsyncExitEditState()
  local homeData = Z.DataMgr.Get("home_editor_data")
  local errorId = worldProxy.ExitEditState({}, homeData.CancelSource:CreateToken())
  if errorId ~= 0 then
    Z.TipsVM.ShowTips(errorId)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Home.ExitEditState)
  return errorId
end

function HomeEditorVm.OpenHomeMain()
  Z.CoroUtil.create_coro_xpcall(function()
    if not HomeEditorVm.IsSelfResident() then
      return
    end
    if Z.EntityMgr.PlayerEnt == nil then
      return
    end
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
    if stateId == Z.PbEnum("EActorState", "ActorStateDefault") then
      local homeData = Z.DataMgr.Get("home_editor_data")
      local houseData = Z.DataMgr.Get("house_data")
      local homeId = houseData:GetHomeId()
      if homeId ~= 0 then
        if HomeEditorVm.AsyncEnterEditState() == 0 and Z.DIServiceMgr.HomeService:EnterEditState(homeId, homeData:GetHomeLandId()) then
          Z.UIMgr:OpenView("home_editor_main")
        end
      else
        logError("\230\154\130\230\156\170\230\139\165\230\156\137\229\174\182\229\155\173")
      end
    else
      Z.TipsVM.ShowTips(1044002)
    end
  end)()
end

function HomeEditorVm.CloseHomeMain()
  Z.UIMgr:CloseView("home_editor_main")
end

function HomeEditorVm.ItemsNameMatched(str, data)
  local tab = {}
  if str == "" or not str then
    return data
  end
  local index = 1
  for _, value in ipairs(data) do
    local itemCfgRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(value.configId)
    if itemCfgRow and string.find(itemCfgRow.Name, str) then
      tab[index] = value
      index = index + 1
    end
  end
  return tab
end

function HomeEditorVm.GetAllWareHouseData()
  local tab = {}
  local homeData = Z.DataMgr.Get("home_editor_data")
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  local limit = currentStageType == Z.EStageType.CommunityDungeon and 2 or 1
  local matType = E.HousingItemGroupType.HousingItemGroupTypePartitionWallMat
  for _, datas in pairs(homeData.HousingItemsTypeMap) do
    for _, id in ipairs(datas) do
      local housingItemsRow = Z.TableMgr.GetRow("HousingItemsMgr", id)
      if housingItemsRow then
        local typeRow = Z.TableMgr.GetRow("HousingItemsTypeMgr", housingItemsRow.Type)
        if typeRow and typeRow.GroupId ~= matType and (housingItemsRow.IndoorOutdoorLimit == 0 or housingItemsRow.IndoorOutdoorLimit == limit) then
          tab[#tab + 1] = {configId = id}
        end
      end
    end
  end
  return tab
end

function HomeEditorVm.GetWareHouseDataByTypeId(typeId)
  local tab = {}
  local homeData = Z.DataMgr.Get("home_editor_data")
  local data = homeData.HousingItemsTypeMap[typeId] or {}
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  local limit = currentStageType == Z.EStageType.CommunityDungeon and 2 or 1
  for _, id in ipairs(data) do
    local housingItemsRow = Z.TableMgr.GetRow("HousingItemsMgr", id)
    if housingItemsRow and (housingItemsRow.IndoorOutdoorLimit == 0 or housingItemsRow.IndoorOutdoorLimit == limit) then
      tab[#tab + 1] = {configId = id}
    end
  end
  return tab
end

function HomeEditorVm.GetItemGroupType(itemId)
  local itemCfg = Z.TableMgr.GetTable("HousingItemsMgr").GetRow(itemId)
  if itemCfg then
    local typeCfg = Z.TableMgr.GetRow("HousingItemsTypeMgr", itemCfg.Type)
    if typeCfg then
      return typeCfg.GroupId
    end
  end
  return 0
end

function HomeEditorVm.GetItemSubType(itemId)
  local itemCfg = Z.TableMgr.GetTable("HousingItemsMgr").GetRow(itemId)
  if itemCfg then
    return itemCfg.Type
  end
  return 0
end

function HomeEditorVm.LoadHomeData()
  local homeData = Z.DataMgr.Get("home_editor_data")
  local homeCfgDatas = {}
  for index, value in pairs(homeData.HousingItemsTypeGroupDatas) do
    homeCfgDatas[value.Id] = {
      groupId = value.Id,
      sortId = value.Sort,
      iconPath = value.GroupIcon,
      isType = false,
      groupName = value.GroupName
    }
  end
  local homeItemTypes = {}
  for index, homeItemType in pairs(homeData.HousingItemsTypeDatas) do
    if homeItemTypes[homeItemType.GroupId] == nil then
      homeItemTypes[homeItemType.GroupId] = {}
    end
    local groupList = homeItemTypes[homeItemType.GroupId]
    groupList[#groupList + 1] = {
      typeId = homeItemType.Id,
      iconPath = homeItemType.TypeIcon,
      isType = true,
      typeName = homeItemType.Name,
      sortId = homeItemType.Sort
    }
  end
  local tab = table.zvalues(homeCfgDatas)
  table.sort(tab, function(a, b)
    return a.sortId < b.sortId
  end)
  for groupId, value in pairs(homeItemTypes) do
    table.sort(value, function(a, b)
      return a.sortId < b.sortId
    end)
  end
  local homeData = Z.DataMgr.Get("home_editor_data")
  homeData:SetHomeCfgDatas(tab)
  homeData:SetHomeCfgItemDatas(homeItemTypes)
end

function HomeEditorVm.SetAlignUserData(key, value)
  Z.LocalUserDataMgr.SetIntByLua(E.LocalUserDataType.Character, key, value)
end

function HomeEditorVm.GetAlignUserData(id)
  local value = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Character, EAreaParamenter[id])
  if value == 0 then
    return 1
  end
  return value
end

function HomeEditorVm.SetAlignState(state)
  local homeData = Z.DataMgr.Get("home_editor_data")
  homeData:SetAlignState(state)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, Z.ConstValue.Home.BKR_HOME_ALIGN, state)
end

function HomeEditorVm.GetAlignState()
  return Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, Z.ConstValue.Home.BKR_HOME_ALIGN)
end

function HomeEditorVm.SetAbsorbState(state)
  local homeData = Z.DataMgr.Get("home_editor_data")
  homeData.IsAbsorb = state
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, Z.ConstValue.Home.BKR_HOME_ADSORB, state)
  if not state then
    Z.DIServiceMgr.HomeService:SetAdsorbSurfaceType(Z.EHomeAdsorbType.Disable)
  else
    Z.DIServiceMgr.HomeService:SetAdsorbSurfaceType(Z.EHomeAdsorbType.Enable)
  end
end

function HomeEditorVm.GetAbsorbState()
  local isAbsorb = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, Z.ConstValue.Home.BKR_HOME_ADSORB)
  local homeData = Z.DataMgr.Get("home_editor_data")
  homeData.IsAbsorb = isAbsorb
  return isAbsorb
end

function HomeEditorVm.InitAlignNum()
  local homeData = Z.DataMgr.Get("home_editor_data")
  homeData.AlignMoveValue = HomeEditorVm.GetAlignUserData(E.EHomeAlignType.AlignMoveValue)
  homeData.AlignHightValue = HomeEditorVm.GetAlignUserData(E.EHomeAlignType.AlignHeightValue)
  homeData.AlignRotateValue = HomeEditorVm.GetAlignUserData(E.EHomeAlignType.AlignAnglesValue)
end

function HomeEditorVm.OpenOptionView(entityIds, configIds)
  local tab = {}
  for i = 0, entityIds.count - 1 do
    tab[i + 1] = {
      entityId = entityIds[i],
      configId = configIds[i]
    }
  end
  Z.UIMgr:OpenView("home_edit_option_window", tab)
end

function HomeEditorVm.CloseOptionView()
  Z.UIMgr:CloseView("home_edit_option_window")
end

function HomeEditorVm.SetAllAlignUserData()
  local isSave = Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, "BKR_HOME_SAVE_ALIGN")
  if not isSave then
    Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, "BKR_HOME_SAVE_ALIGN", true)
    HomeEditorVm.SetAlignUserData(E.EHomeAlignType.AlignMoveValue, Z.GlobalHome.AlignMoveValue[4])
    HomeEditorVm.SetAlignUserData(E.EHomeAlignType.AlignHeightValue, Z.GlobalHome.AlignHeightValue[4])
    HomeEditorVm.SetAlignUserData(E.EHomeAlignType.AlignAnglesValue, Z.GlobalHome.AlignAnglesValue[4])
  end
end

function HomeEditorVm.useCommunityField(homeLandId)
  local gmVm = Z.VMMgr.GetVM("gm")
  gmVm.SendCmd("useCommunityField", homeLandId)
end

function HomeEditorVm.SetnCommunityInfo()
end

function HomeEditorVm.SetHomelandInfo()
end

function HomeEditorVm.getLands()
  local homeData = Z.DataMgr.Get("home_editor_data")
  local houseItemMap = homeData:GetHouseItemList()
  local tab = {}
  if not houseItemMap then
    return tab
  end
  local index = 1
  for itemId, uIds in pairs(houseItemMap) do
    local HousingItemsBases = Z.TableMgr.GetTable("HousingItemsMgr").GetRow(itemId)
    if HousingItemsBases then
      for _, uId in ipairs(uIds) do
        if tab[HousingItemsBases.Type] == nil then
          tab[HousingItemsBases.Type] = {}
          tab[HousingItemsBases.Type].homelandData = {}
        end
        tab[HousingItemsBases.Type].typeId = HousingItemsBases.Type
        tab[HousingItemsBases.Type].homelandData[index] = {clientUuid = uId, itemId = itemId}
        index = index + 1
      end
    end
  end
  return tab
end

function HomeEditorVm.GetHomelandDatas()
  return HomeEditorVm.getLands()
end

function HomeEditorVm.GetHomelandDataByType(type)
  local tab = HomeEditorVm.GetHomelandDatas()
  if tab[type] then
    return tab[type].homelandData
  end
  return nil
end

function HomeEditorVm.HomeDatasStrMatched(str, HomeDatas)
  local tab = {}
  if str == "" or not str then
    return HomeDatas
  end
  for _, homeData in ipairs(HomeDatas) do
    for __, value in ipairs(homeData.homelandData) do
      local itemCfgRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(value.itemId)
      if itemCfgRow and string.find(itemCfgRow.Name, str) then
        if tab[homeData.typeId] == nil then
          tab[homeData.typeId] = {}
          tab[homeData.typeId].typeId = homeData.typeId
          tab[homeData.typeId].homelandData = {}
        end
        table.insert(tab[homeData.typeId].homelandData, value)
      end
    end
  end
  return table.zvalues(tab)
end

function HomeEditorVm.GetOperationHight(homeId)
  local minHight = 0
  local maxHight = 0
  local type = Z.StageMgr.GetCurrentStageType()
  if type == Z.EStageType.CommunityDungeon then
    local residentialDistrictsRow = Z.TableMgr.GetTable("ResidentialDistrictsMgr").GetRow(homeId)
    if residentialDistrictsRow then
      local housePos = residentialDistrictsRow.PlotPosition
      local plotTypeRow = Z.TableMgr.GetTable("PlotTypeMgr").GetRow(residentialDistrictsRow.PlotType)
      if plotTypeRow then
        minHight = housePos.Y
        maxHight = housePos.Y + plotTypeRow.Size.Y
      end
    end
  elseif type == Z.EStageType.HomelandDungeon then
    local housingRow = Z.TableMgr.GetTable("HousingTypeMgr").GetRow(1)
    if housingRow then
      local landPos = housingRow.HousingPosition
      local landSize = housingRow.HousingSize
      minHight = landPos.Y
      maxHight = landPos.Y + landSize.Z
    end
  end
  return minHight, maxHight
end

function HomeEditorVm.checkLimitCount(itemId)
  local homeEditorData = Z.DataMgr.Get("home_editor_data")
  local houseData = Z.DataMgr.Get("house_data")
  local housingItemsRow = Z.TableMgr.GetRow("HousingItemsMgr", itemId)
  if housingItemsRow == nil then
    return
  end
  local housingItemsTypeRow = Z.TableMgr.GetRow("HousingItemsTypeMgr", housingItemsRow.Type)
  if housingItemsTypeRow == nil then
    return
  end
  local homeLevelTableRow = Z.TableMgr.GetRow("HomeLevelTableMgr", houseData:GetHouseLevel())
  if homeLevelTableRow == nil then
    return
  end
  local limit = 999
  for index, value in ipairs(homeLevelTableRow.PlantNumber) do
    if value[1] == housingItemsRow.Type then
      limit = value[2]
      break
    end
  end
  local arrangeLimit = math.min(limit, housingItemsTypeRow.ArrangeLimit)
  local curCount = homeEditorData:GetHouseItemTypeCount(housingItemsRow.Type)
  if arrangeLimit <= curCount then
    Z.TipsVM.ShowTips(1044017)
    return false
  end
  return true
end

function HomeEditorVm.OnClickWareHouseItem(itemId, count, isWareHouse, clientUuid)
  Z.CoroUtil.create_coro_xpcall(function()
    local houseData = Z.DataMgr.Get("house_data")
    local homeEditorData = Z.DataMgr.Get("home_editor_data")
    if not houseData:GetHomeCharLimit(E.HousePlayerLimitType.FurnitureEdit, Z.ContainerMgr.CharSerialize.charId) then
      Z.TipsVM.ShowTips(1044016)
      return
    end
    if isWareHouse then
      if 0 < count then
        local groupId = HomeEditorVm.GetItemGroupType(itemId)
        if groupId == E.HousingItemGroupType.HousingItemGroupTypeDecoration then
          local subType = HomeEditorVm.GetItemSubType(itemId)
          HomeEditorVm.AsyncSetMaterialInfo(subType, itemId)
        elseif groupId == E.HousingItemGroupType.HousingItemGroupTypePartitionWallMat then
          if homeEditorData.CurSelectedList and #homeEditorData.CurSelectedList == 1 then
            local selectEntityUuid = homeEditorData.CurSelectedList[1]
            HomeEditorVm.AsyncSetFurnitureMaterial(selectEntityUuid, itemId)
          end
        elseif homeEditorData.IsOperationState then
          if not HomeEditorVm.checkLimitCount(itemId) then
            return
          end
          Z.DialogViewDataMgr:OpenNormalDialog(Lang("HomeSwicthSelected"), function()
            Z.EventMgr:Dispatch(Z.ConstValue.Home.SaveSelectedEntity)
            Z.DIServiceMgr.HomeService:CreateEntity(itemId)
          end)
        else
          if not HomeEditorVm.checkLimitCount(itemId) then
            return
          end
          Z.DIServiceMgr.HomeService:CreateEntity(itemId)
        end
      end
    else
      Z.DIServiceMgr.HomeService:SelectEntities({clientUuid})
      Z.DIServiceMgr.HomeService:MoveCameraToEntity(clientUuid)
      Z.EventMgr:Dispatch(Z.ConstValue.Home.HomeEntitySelectingSingle, clientUuid, itemId)
    end
  end)()
end

function HomeEditorVm.AsyncCreateStructureGroup(groupName, structureIds, token, isNoRefresh)
  local request = {groupName = groupName, structureIds = structureIds}
  local ret = worldProxy.CreateStructureGroup(request, token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  else
    local homeData = Z.DataMgr.Get("home_editor_data")
    if homeData.FurnitureGroupInfo[ret.groupId] == nil then
      homeData.FurnitureGroupInfo[ret.groupId] = {}
      homeData.FurnitureGroupInfo[ret.groupId].structureIds = {}
      homeData.FurnitureGroupInfo[ret.groupId].groupName = groupName
    end
    for index, entityId in ipairs(structureIds) do
      local lastGroupId = homeData.FurnitureGroupInfoDic[entityId]
      if lastGroupId then
        table.zremoveOneByValue(homeData.FurnitureGroupInfo[lastGroupId].structureIds, entityId)
      end
      table.insert(homeData.FurnitureGroupInfo[ret.groupId].structureIds, entityId)
      homeData.FurnitureGroupInfoDic[entityId] = ret.groupId
    end
    homeData.CurMultiSelectedEntIds = {}
    if not isNoRefresh then
      Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshEditorOperation, ret.groupId)
    end
  end
end

function HomeEditorVm.AsyncDissolveStructureGroup(groupId, token, isNoDispatchEvent)
  local request = {groupId = groupId}
  local ret = worldProxy.DissolveStructureGroup(request, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    local homeData = Z.DataMgr.Get("home_editor_data")
    homeData.FurnitureGroupInfo[groupId] = nil
    for key, value in pairs(homeData.FurnitureGroupInfoDic) do
      if value == groupId then
        homeData.FurnitureGroupInfoDic[key] = nil
      end
    end
    if not isNoDispatchEvent then
      Z.EventMgr:Dispatch(Z.ConstValue.Home.DissolveStructureGroup)
    end
  end
end

function HomeEditorVm.AsyncRemoveStructureGroup(groupId, structureIds, token)
  local request = {groupId = groupId, structureIds = structureIds}
  local ret = worldProxy.RemoveStructureGroup(request, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    local homeData = Z.DataMgr.Get("home_editor_data")
    local groupInfo = homeData.FurnitureGroupInfo[groupId]
    if groupInfo then
      for key, value in ipairs(structureIds) do
        table.zremoveOneByValue(groupInfo.structureIds, value)
        homeData.FurnitureGroupInfoDic[value] = nil
      end
      if #groupInfo.structureIds <= 1 then
        for index, id in ipairs(groupInfo.structureIds) do
          homeData.FurnitureGroupInfoDic[id] = nil
        end
        homeData.FurnitureGroupInfo[groupId] = nil
        Z.EventMgr:Dispatch(Z.ConstValue.Home.DissolveStructureGroup)
      else
        homeData.CurEditorGroupEntityId = nil
        Z.EventMgr:Dispatch(Z.ConstValue.Home.RemoveStructureGroup)
      end
    end
  end
end

function HomeEditorVm.AsyncAddToStructureGroup(groupId, structureIds, token)
  local request = {groupId = groupId, structureIds = structureIds}
  local ret = worldProxy.AddToStructureGroup(request, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    local homeData = Z.DataMgr.Get("home_editor_data")
    local groupInfo = homeData.FurnitureGroupInfo[groupId]
    if groupInfo then
      for key, value in ipairs(structureIds) do
        groupInfo.structureIds[#groupInfo.structureIds + 1] = value
        homeData.FurnitureGroupInfoDic[value] = groupId
      end
    end
    homeData.CurMultiSelectedEntIds = {}
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshEditorOperation, groupId)
  end
end

function HomeEditorVm.AsyncRenameStructureGroup(groupId, groupName, token)
  local request = {groupId = groupId, groupName = groupName}
  local ret = worldProxy.RenameStructureGroup(request, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    local homeData = Z.DataMgr.Get("home_editor_data")
    local groupInfo = homeData.FurnitureGroupInfo[groupId]
    if groupInfo then
      groupInfo.groupName = groupName
    end
  end
end

function HomeEditorVm.AsyncGetStructureGroupInfo()
  local homeData = Z.DataMgr.Get("home_editor_data")
  local request = {isOuter = true}
  local ret = worldProxy.GetStructureGroupInfo(request, homeData.CancelSource:CreateToken())
  homeData.FurnitureGroupInfo = ret.groupInfos
  homeData.FurnitureGroupInfoDic = {}
  for groupId, data in pairs(ret.groupInfos) do
    for key, entityId in ipairs(data.structureIds) do
      homeData.FurnitureGroupInfoDic[entityId] = groupId
    end
  end
end

function HomeEditorVm.AsyncHomelandFurnitureWarehouseData()
  local homeData = Z.DataMgr.Get("home_editor_data")
  local request = {}
  local ret = worldProxy.GetHomelandFurnitureWarehouseInfo(request, homeData.CancelSource:CreateToken())
  homeData.HomelandFurnitureWarehouseGrid = {}
  if ret.errCode == 0 then
    for index, value in pairs(ret.items) do
      homeData.HomelandFurnitureWarehouseGrid[ret.itemToSlots[index]] = value
    end
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function HomeEditorVm.AsyncSetLamplightLevel(level)
  local homeData = Z.DataMgr.Get("home_editor_data")
  local houseData = Z.DataMgr.Get("house_data")
  local request = {
    lamplightLevel = level,
    lamplightColor = houseData:GetHouseLightColor(),
    dayNightId = houseData:GetHouseEnvId(),
    mode = houseData:GetHouseLightMode()
  }
  local ret = worldProxy.HomelandSetLamplight(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HomeEditorVm.AsyncSetLamplightColor(color)
  local homeData = Z.DataMgr.Get("home_editor_data")
  local houseData = Z.DataMgr.Get("house_data")
  local request = {
    lamplightLevel = houseData:GetHouseLightLevel(true),
    lamplightColor = color,
    dayNightId = houseData:GetHouseEnvId(),
    mode = houseData:GetHouseLightMode()
  }
  local ret = worldProxy.HomelandSetLamplight(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HomeEditorVm.AsyncSetLamplightModel(mode)
  local homeData = Z.DataMgr.Get("home_editor_data")
  local houseData = Z.DataMgr.Get("house_data")
  local request = {
    lamplightLevel = houseData:GetHouseLightLevel(true),
    lamplightColor = houseData:GetHouseLightColor(),
    dayNightId = houseData:GetHouseEnvId(),
    mode = mode
  }
  local ret = worldProxy.HomelandSetLamplight(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HomeEditorVm.AsyncSetEvnId(id)
  local homeData = Z.DataMgr.Get("home_editor_data")
  local houseData = Z.DataMgr.Get("house_data")
  local request = {
    lamplightLevel = houseData:GetHouseLightLevel(true),
    lamplightColor = houseData:GetHouseLightColor(),
    dayNightId = id,
    mode = houseData:GetHouseLightMode()
  }
  local ret = worldProxy.HomelandSetLamplight(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HomeEditorVm.InteractionSwitchLamplight(uuid)
  local houseData = Z.DataMgr.Get("house_data")
  if not houseData:CheckPlayerFurnitureEditLimit(true) then
    return
  end
  local structure = Z.DIServiceMgr.HomeService:GetHouseItemStructure(uuid)
  if not structure then
    return
  end
  local lightState
  if structure.lamplightInfo then
    lightState = structure.lamplightInfo.state
  end
  if not lightState or lightState:ToInt() == E.HomelandLamplightState.HomelandLamplightStateOff then
    HomeEditorVm.AsyncSwitchLamplight(uuid, E.HomelandLamplightState.HomelandLamplightStateOn)
  else
    HomeEditorVm.AsyncSwitchLamplight(uuid, E.HomelandLamplightState.HomelandLamplightStateOff)
  end
end

function HomeEditorVm.AsyncSwitchLamplight(structureUuid, lamplightState)
  local homeData = Z.DataMgr.Get("home_editor_data")
  local request = {structureUuid = structureUuid, lamplightState = lamplightState}
  local ret = worldProxy.HomelandSwitchLamplight(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end

function HomeEditorVm.AsyncSwitchAllLamplight(state)
  local homeData = Z.DataMgr.Get("home_editor_data")
  local request = {lamplightState = state}
  local ret = worldProxy.HomelandSwitchAllLamplight(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HomeEditorVm.AsyncSetFurnitureName(uuid, name)
  local homeData = Z.DataMgr.Get("home_editor_data")
  local request = {structureUuid = uuid, name = name}
  local ret = worldProxy.HomelandSetFurnitureName(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HomeEditorVm.AsyncSetFurnitureMaterial(uuid, itemId)
  if Z.DIServiceMgr.HomeService:GetHouseItemStructure(uuid) == nil then
    logError("\229\174\182\229\133\183\232\191\152\230\156\170\228\191\157\229\173\152\239\188\140\230\151\160\230\179\149\232\174\190\231\189\174\230\157\144\232\180\168, uuid={0}", uuid)
    return
  end
  local homeData = Z.DataMgr.Get("home_editor_data")
  local request = {structureUuid = uuid, materialId = itemId}
  local ret = worldProxy.HomelandSetFurnitureMaterial(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HomeEditorVm.AsyncSetMaterialInfo(type, itemId)
  local homeData = Z.DataMgr.Get("home_editor_data")
  local request = {structureType = type, materialId = itemId}
  local ret = worldProxy.HomelandSetMaterialInfo(request, homeData.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function HomeEditorVm.SetCopyInfo(clientUid, serverUuid, configId)
  local homeData = Z.DataMgr.Get("home_editor_data")
  if serverUuid ~= 0 then
    local uid = homeData.CopyClientUidList[clientUid]
    homeData.CopyUUidList[uid] = serverUuid
    homeData.CopyClientUidList[clientUid] = nil
    homeData:AddHouseItem(configId, serverUuid)
    if next(homeData.CopyClientUidList) == nil then
      local tab = {}
      local selectedUuidList = {}
      local selectedUuidIndex = 1
      for uid, serverUuid in pairs(homeData.CopyUUidList) do
        selectedUuidList[selectedUuidIndex] = serverUuid
        selectedUuidIndex = selectedUuidIndex + 1
        local groupId = homeData.FurnitureGroupInfoDic[uid]
        if groupId then
          local groupInfo = homeData.FurnitureGroupInfo[groupId]
          if groupInfo then
            if tab[groupId] == nil then
              tab[groupId] = {
                groupName = groupInfo.groupName,
                idList = {}
              }
            end
            local data = tab[groupId].idList
            data[#data + 1] = serverUuid
          end
        end
      end
      if next(tab) ~= nil then
        Z.CoroUtil.create_coro_xpcall(function()
          for key, value in pairs(tab) do
            HomeEditorVm.AsyncCreateStructureGroup(value.groupName, value.idList, homeData.CancelSource:CreateToken(), true)
          end
          Z.EventMgr:Dispatch(Z.ConstValue.Home.DissolveStructureGroup)
          Z.EventMgr:Dispatch(Z.ConstValue.Home.HomeEntitySelecting, selectedUuidList)
        end)()
      else
        Z.EventMgr:Dispatch(Z.ConstValue.Home.DissolveStructureGroup)
        Z.EventMgr:Dispatch(Z.ConstValue.Home.HomeEntitySelecting, selectedUuidList)
      end
      homeData:InitCopyTab()
    end
  else
    homeData:CreateHomeFurniture(configId)
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshWareHouseCount, configId)
    homeData.CopyItemCount = homeData.CopyItemCount + 1
    if homeData.CopyItemCount == table.zcount(homeData.CopyClientUidList) then
      local tab = table.zkeys(homeData.CopyClientUidList)
      Z.EventMgr:Dispatch(Z.ConstValue.Home.HomeEntitySelecting, tab)
    end
  end
end

return HomeEditorVm
