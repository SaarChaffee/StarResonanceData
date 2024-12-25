local HomeVm = {}
E.EHomeUserDataKey = {
  BKR_HOME_ALIGN = "BKR_HOME_ALIGN",
  BKR_HOME_ALIGN_MOVE = "BKR_HOME_ALIGN_MOVE",
  BKR_HOME_ALIGN_HIGHT = "BKR_HOME_ALIGN_HIGHT",
  BKR_HOME_ALIGN_ROTATE = "BKR_HOME_ALIGN_ROTATE"
}
local EAreaParamenter = {
  [1] = E.EHomeUserDataKey.BKR_HOME_ALIGN_MOVE,
  [2] = E.EHomeUserDataKey.BKR_HOME_ALIGN_HIGHT,
  [3] = E.EHomeUserDataKey.BKR_HOME_ALIGN_ROTATE
}

function HomeVm.IsSelfResident()
  local homeData = Z.DataMgr.Get("home_data")
  local homeId = homeData:GetomeLoadId()
  if homeId ~= 0 then
    local data = Z.ContainerMgr.DungeonSyncData.community.communityInfo
    local charId = Z.ContainerMgr.CharSerialize.charBase.charId
    if charId == data.residents[homeId] then
      return true
    end
  else
    return true
  end
  return false
end

function HomeVm.OpenHomeMain()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if stateId == Z.PbEnum("EActorState", "ActorStateDefault") then
    Z.UIMgr:OpenView("home_editor_main")
  else
    Z.TipsVM.ShowTips(1044002)
  end
end

function HomeVm.CloseHomeMain()
  Z.UIMgr:CloseView("home_editor_main")
end

function HomeVm.ItemsNameMatched(str, data)
  local tab = {}
  if str == "" or not str then
    return data
  end
  local index = 0
  for _, value in ipairs(data) do
    local itemCfgRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(value.configId)
    if itemCfgRow and string.find(itemCfgRow.Name, str) then
      tab[index] = value
      index = index + 1
    end
  end
  return tab
end

function HomeVm.GetWareHouseDataByTypeId(typeId)
  local tab = {}
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[11]
  local data = Z.TableMgr.GetTable("HousingItemsMgr").GetDatas()
  for _, housingItemsRow in pairs(data) do
    if housingItemsRow and (housingItemsRow.Type == typeId or typeId == -1) then
      tab[housingItemsRow.Id] = {
        configId = housingItemsRow.Id,
        count = 0
      }
    end
  end
  if package then
    for _, item in pairs(package.items) do
      if tab[item.configId] then
        tab[item.configId] = item
      end
    end
  end
  return table.zvalues(tab)
end

function HomeVm.LoadHomeData()
  local homeData = Z.DataMgr.Get("home_data")
  local homeCfgDatas = {}
  for index, value in pairs(homeData.HousingItemsTypeGroupDatas) do
    homeCfgDatas[value.Id] = {}
    homeCfgDatas[value.Id].groupId = value.Id
    homeCfgDatas[value.Id].iconPath = value.GroupIcon
    homeCfgDatas[value.Id].homeTypes = {}
  end
  for index, homeItemType in pairs(homeData.HousingItemsTypeDatas) do
    if homeCfgDatas[homeItemType.GroupId] then
      local groupIndex = #homeCfgDatas[homeItemType.GroupId].homeTypes + 1
      homeCfgDatas[homeItemType.GroupId].homeTypes[groupIndex] = {}
      homeCfgDatas[homeItemType.GroupId].homeTypes[groupIndex].typeId = homeItemType.Id
      homeCfgDatas[homeItemType.GroupId].homeTypes[groupIndex].iconPath = homeItemType.TypeIcon
    end
  end
  local tab = table.zvalues(homeCfgDatas)
  table.sort(tab, function(a, b)
    return a.groupId < b.groupId
  end)
  local homeData = Z.DataMgr.Get("home_data")
  homeData:SetHomeCfgDatas(tab)
end

function HomeVm.SetAlignUserData(key, value)
  Z.LocalUserDataMgr.SetInt(key, value)
end

function HomeVm.GetAlignUserData(id)
  return Z.LocalUserDataMgr.GetInt(EAreaParamenter[id])
end

function HomeVm.SetAlignState(state)
  local homeData = Z.DataMgr.Get("home_data")
  homeData:SetAlignState(state)
  Z.LocalUserDataMgr.SetBool("BKR_HOME_ALIGN", state)
end

function HomeVm.GetAlignState()
  return Z.LocalUserDataMgr.GetBool("BKR_HOME_ALIGN")
end

function HomeVm.InitAlignNum()
  local homeData = Z.DataMgr.Get("home_data")
  homeData.AlignMoveValue = HomeVm.GetAlignUserData(1)
  homeData.AlignHightValue = HomeVm.GetAlignUserData(2)
  homeData.AlignRotateValue = HomeVm.GetAlignUserData(3)
end

function HomeVm.OpenOptionView(entityIds, configIds)
  local tab = {}
  for i = 0, entityIds.count - 1 do
    tab[i + 1] = {
      entityId = entityIds[i],
      configId = configIds[i]
    }
  end
  Z.UIMgr:OpenView("home_edit_option_window", tab)
end

function HomeVm.CloseOptionView()
  Z.UIMgr:CloseView("home_edit_option_window")
end

function HomeVm.SetAllAlignUserData()
  local isSave = Z.LocalUserDataMgr.GetBool("BKR_HOME_SAVE_ALIGN")
  if not isSave then
    Z.LocalUserDataMgr.SetBool("BKR_HOME_SAVE_ALIGN", true)
    for index, value in ipairs(EAreaParamenter) do
      local residentialAreaParameterRow = Z.TableMgr.GetTable("ResidentialAreaParameterMgr").GetRow(index)
      if residentialAreaParameterRow then
        HomeVm.SetAlignUserData(value, residentialAreaParameterRow.Value[3])
      end
    end
  end
end

function HomeVm.getLands(data)
  local tab = {}
  if not data then
    return tab
  end
  local index = 1
  for uuid, structure in pairs(data.structures) do
    local HousingItemsBases = Z.TableMgr.GetTable("HousingItemsMgr").GetRow(structure.itemId)
    if HousingItemsBases then
      local homeData = Z.DataMgr.Get("home_data")
      homeData:SetLangData(structure.clientUuid, structure.itemId)
      if tab[HousingItemsBases.Type] == nil then
        tab[HousingItemsBases.Type] = {}
        tab[HousingItemsBases.Type].homelandData = {}
      end
      tab[HousingItemsBases.Type].typeId = HousingItemsBases.Type
      tab[HousingItemsBases.Type].homelandData[index] = {
        clientUuid = structure.clientUuid,
        itemId = structure.itemId
      }
      index = index + 1
    end
  end
  return tab
end

function HomeVm.SetnCommunityInfo()
  local homeData = Z.DataMgr.Get("home_data")
  local data = Z.ContainerMgr.DungeonSyncData.community.communityInfo
  local charId = Z.ContainerMgr.CharSerialize.charBase.charId
  homeData.CommunityDatas = {}
  local homeId = homeData:GetomeLoadId()
  local tab = {}
  if charId == data.residents[homeId] then
    local homelands = data.homelands[charId]
    tab = HomeVm.getLands(homelands)
  else
    return
  end
  homeData:SetCommunityDatas(table.zvalues(tab))
  Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshHome)
end

function HomeVm.SetHomelandInfo()
  local homeData = Z.DataMgr.Get("home_data")
  local data = Z.ContainerMgr.DungeonSyncData.homeland.homelandInfo
  homeData.LangData = {}
  local tab = HomeVm.getLands(data)
  homeData:SetHomelandDatas(table.zvalues(tab))
  Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshHome)
end

function HomeVm.GetHomelandDatas()
  local homeData = Z.DataMgr.Get("home_data")
  local type = Z.StageMgr.GetCurrentStageType()
  if type == Z.EStageType.CommunityDungeon then
    return homeData:GetCommunityDatas()
  elseif type == Z.EStageType.HomelandDungeon then
    return homeData:GetHomelandDatas()
  end
end

function HomeVm.HomeDatasStrMatched(str, HomeDatas)
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

function HomeVm.CheckPos(pos, homeId)
  local type = Z.StageMgr.GetCurrentStageType()
  if type == Z.EStageType.CommunityDungeon then
    local landPos, landSize, housePos, houseSize
    local residentialDistrictsRow = Z.TableMgr.GetTable("ResidentialDistrictsMgr").GetRow(homeId)
    if residentialDistrictsRow then
      landPos = residentialDistrictsRow.PlotPosition
      housePos = residentialDistrictsRow.HousingPosition
      local plotTypeRow = Z.TableMgr.GetTable("PlotTypeMgr").GetRow(residentialDistrictsRow.PlotType)
      if plotTypeRow then
        landSize = plotTypeRow.Size
        houseSize = plotTypeRow.HousingSize
      end
      if pos.x > landPos.X and pos.x < landPos.X + landSize.X and pos.y > landPos.Y and pos.y < landPos.Y + landSize.Z and pos.z > landPos.Z and pos.z < landPos.Z + landSize.Y and (pos.x > housePos.X and pos.x < housePos.X + houseSize.X and pos.z > housePos.Z and pos.z < housePos.Z + houseSize.Y) == false then
        return true
      end
    end
    return false
  elseif type == Z.EStageType.HomelandDungeon then
    local housingRow = Z.TableMgr.GetTable("housingTypeMgr").GetRow(1)
    if housingRow then
      local size = housingRow.HousingSize
      if pos.x > 0 and pos.x < size.X and pos.y > 0 and pos.y < size.Z and pos.z > 0 and pos.z < size.Y then
        return true
      end
    end
  end
  return false
end

return HomeVm
