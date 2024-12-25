local equipData = Z.DataMgr.Get("equip_system_data")
local funcVm = Z.VMMgr.GetVM("gotofunc")
local equipAttrParseVM = Z.VMMgr.GetVM("equip_attr_parse")
local fightAttrParseVm = Z.VMMgr.GetVM("fight_attr_parse")
local equipRed = require("rednode.equip_red")
local openEquipSystemView = function(data)
  if funcVm.CheckFuncCanUse(E.EquipFuncId.Equip) then
    local args = {}
    
    function args.EndCallback()
      Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_03, "equip_system", function()
        Z.UIMgr:OpenView("equip_system", data)
      end, Z.ConstValue.UnrealSceneConfigPaths.Backdrop_Explore)
    end
    
    Z.UIMgr:FadeIn(args)
  end
end
local closeEquipSystemView = function()
  Z.UIMgr:CloseView("equip_system")
end
local openChangeEquipView = function(data)
  if funcVm.CheckFuncCanUse(E.EquipFuncId.Equip) then
    Z.UIMgr:OpenView("equip_change_window", data)
  end
end
local closeChangeEquipView = function()
  Z.UIMgr:CloseView("equip_change_window")
end
local getEquipGsByConfigId = function(configId)
  local equipTableRow = Z.TableMgr.GetRow("EquipTableMgr", configId)
  if equipTableRow then
    return equipTableRow.EquipGs
  end
  return 0
end
local getRepairEquip = function()
  local equipDurabilityAlert = Z.Global.EquipDurabilityAlert
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  local packages = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if packages then
    for key, value in pairs(equipList) do
      local item = packages.items[value.itemUuid]
      if item then
        return false
      end
    end
  end
  return false
end
local equipRegWatcher = function(container, dirtys)
  local isShowRepair = getRepairEquip()
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.RefreshEquipRepairState, isShowRepair)
  if equipData.IsShowRepairState == false and isShowRepair == true then
    Z.TipsVM.ShowTipsLang(410009)
  end
  if equipData.IsShowRepairState == isShowRepair then
    return
  end
  equipData.IsShowRepairState = isShowRepair
end
local equipDurabilityWatcher = function()
  local equipAttr = Z.ContainerMgr.CharSerialize.equip.equipAttr
  equipAttr.Watcher:RegWatcher(equipRegWatcher)
  equipRed.InitEquipNode()
end
local getAllEquipItemInfos = function(filterFuncs)
  local items = Z.ContainerMgr.CharSerialize.itemPackage.packages[2].items
  local ret = {}
  for _, v in pairs(items) do
    if not filterFuncs then
      table.insert(ret, v)
    else
      local isOk = true
      for key, value in pairs(filterFuncs) do
        isOk = value(v.uuid, v.configId)
        if not isOk then
          break
        end
      end
      if isOk then
        table.insert(ret, v)
      end
    end
  end
  return ret
end
local hasEquipItemInfos = function(filterFuncs)
  local items = Z.ContainerMgr.CharSerialize.itemPackage.packages[2].items
  local ret = {}
  for _, v in pairs(items) do
    if not filterFuncs then
      return true
    else
      local isOk = true
      local itemUuid = v.uuid
      local configId = v.configId
      for key, value in pairs(filterFuncs) do
        isOk = value(itemUuid, configId)
        if not isOk then
          break
        end
      end
      if isOk then
        return true
      end
    end
  end
  return false
end
local getSamePartEquipAttr = function(configId)
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, false)
  if equipTable then
    local partId = equipTable.EquipPart
    local equipInfo = Z.ContainerMgr.CharSerialize.equip.equipList[partId]
    return equipInfo
  end
end
local getEquipAttr = function(configId, itemId)
  local itemsVm = Z.VMMgr.GetVM("items")
  local itemInfo = itemsVm.GetItemInfobyItemId(itemId, configId)
  return itemInfo.equipAttr
end
local checkCanRecast = function(itemUuid, configId)
  if funcVm.CheckFuncCanUse(E.EquipFuncId.EquipRecast, true) then
    local equipCfgRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId, true)
    if equipCfgRow then
      return #equipCfgRow.RecastingAttrLibId > 0
    end
  end
  return false
end
local updateEquipFashion = function()
  local dataList = {}
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  local playerGender = Z.ContainerMgr.CharSerialize.charBase.gender
  for _, equipInfo in pairs(Z.ContainerMgr.CharSerialize.equip.equipList) do
    if package.items[equipInfo.itemUuid] then
      local equipId = package.items[equipInfo.itemUuid].configId
      local row = Z.TableMgr.GetTable("EquipTableMgr").GetRow(equipId)
      if row then
        local fashionId = playerGender == Z.PbEnum("EGender", "GenderMale") and row.FashionMId or row.FashionFId
        local data = {}
        data.FashionId = fashionId
        table.insert(dataList, data)
        if checkCanRecast(nil, equipId) then
          Z.EventMgr:Dispatch(Z.ConstValue.SteerEventName.OnGuideEvnet, string.zconcat(E.SteerGuideEventType.RecastEquip, "=", 1))
        end
      end
    end
  end
  local fashionVM = Z.VMMgr.GetVM("fashion")
  local zList = fashionVM.WearDataListToZList(dataList)
  Z.EventMgr:Dispatch(Z.ConstValue.FashionAttrChange, Z.LocalAttr.EWearEquip, zList)
  zList:Recycle()
end
local openDayDialog = function(onConfirmFunc, labDesc, preferencesKey, onCancelFunc)
  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(labDesc, onConfirmFunc, onCancelFunc, E.DlgPreferencesType.Day, preferencesKey)
end
local asyncPutOnEquip = function(vSlot, itemUuid, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.PutOnEquip(vSlot, itemUuid, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.PutOnSuccess, vSlot)
  updateEquipFashion()
end
local checkIsFitProfessionAttrByAttrId = function(attrId)
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  if curProfessionId == 0 or not curProfessionId then
    return false
  end
  local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(curProfessionId)
  if not professionSystemTableRow then
    return false
  end
  local fightAttrData = fightAttrParseVm.GetFightAttrTableRow(attrId)
  if fightAttrData.Id == professionSystemTableRow.StrOrIntOrDexShow[1][2] then
    return true
  end
  if fightAttrData.Id == professionSystemTableRow.AttackShow[1][2] then
    return true
  end
  return false
end
local checkAttrFunc = function(attr)
  local attrDatas = equipAttrParseVM.GetEquipAttrEffectByAttrDic(attr)
  for index, value in ipairs(attrDatas) do
    if checkIsFitProfessionAttrByAttrId(value.attrId) then
      return true
    end
  end
  return false
end
local checkProfessionIsContainEquipAttr = function(item)
  if item == nil then
    return false
  end
  if checkAttrFunc(item.equipAttr.basicAttr) or checkAttrFunc(item.equipAttr.advanceAttr) then
    return true
  end
  return false
end
local addAttrIdsByCfgData = function(attrIds, data)
  for index, value in ipairs(data) do
    attrIds[value[2]] = true
  end
end
local checkPutOnEquip = function(vSlot, itemUuid, cancelToken)
  local itemsVM = Z.VMMgr.GetVM("items")
  local item = itemsVM.GetItemInfo(itemUuid, E.BackPackItemPackageType.Equip)
  local dialogStr = ""
  if item then
    local bindFlag = item.bindFlag == 1
    if not checkProfessionIsContainEquipAttr(item) then
      local professionSystemTable = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(Z.ContainerMgr.CharSerialize.professionList.curProfessionId)
      if professionSystemTable then
        local attrIds = {}
        addAttrIdsByCfgData(attrIds, professionSystemTable.AttackShow)
        addAttrIdsByCfgData(attrIds, professionSystemTable.StrOrIntOrDexShow)
        local strs = {}
        for attrId, value in pairs(attrIds) do
          local fightAttrTableRow = Z.TableMgr.GetRow("FightAttrTableMgr", attrId)
          if fightAttrTableRow then
            strs[#strs + 1] = fightAttrTableRow.Name
          end
        end
        local str = table.concat(strs, "\227\128\129")
        if bindFlag then
          dialogStr = Lang("EquipAttrTypeNotCompatibleMoreTips", {
            val1 = professionSystemTable.Name,
            val2 = str
          })
        else
          dialogStr = Lang("EquipAttrTypeNotCompatibleTips", {
            val1 = professionSystemTable.Name,
            val2 = str
          })
        end
      end
    elseif bindFlag then
      dialogStr = Lang("EquipPutOnNoFlagTips")
    end
    if dialogStr ~= "" then
      openDayDialog(function()
        asyncPutOnEquip(vSlot, itemUuid, cancelToken)
      end, dialogStr, E.DlgPreferencesKeyType.EquipPutOnNoBindFlag)
    else
      asyncPutOnEquip(vSlot, itemUuid, cancelToken)
    end
  end
end
local asyncTakeOffEquip = function(vSlot, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.TakeOffEquip(vSlot, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.PutOnSuccess, vSlot)
  updateEquipFashion()
end
local showError = function(ret)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end
local asyncEquipBreach = function(vItemUuid, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.EquipBreach(vItemUuid, cancelToken)
  return showError(ret)
end
local asyncEquipDecompose = function(vItemUuids, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.EquipDecompose(vItemUuids, cancelToken)
  return showError(ret)
end
local openEquipFuncView = function(data)
  local switchVm = Z.VMMgr.GetVM("switch")
  if switchVm.CheckFuncSwitch(E.FunctionID.EquipFunc) then
    local equipData = Z.DataMgr.Get("equip_system_data")
    Z.UnrealSceneMgr:ClearModelByName(equipData.EquipModelName)
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_03, "equip_function", function()
      local viewData
      if data then
        viewData = {
          subViewType = data.type,
          subViewData = {
            itemUuid = data.itemUuid,
            configId = data.configId
          }
        }
      end
      Z.UIMgr:OpenView("equip_function", viewData)
    end, Z.ConstValue.UnrealSceneConfigPaths.Backdrop_Explore)
  end
end
local getEquipData = function(type, itemUuid, configId)
  local data = {}
  data.type = type
  data.itemUuid = itemUuid
  data.configId = configId
  return data
end
local openEquipCopyView = function(itemUuid, configId)
  funcVm.GoToFunc(E.EquipFuncId.EquipFunc, getEquipData("transfer", itemUuid, configId))
end
local openEquipWashView = function(itemUuid, configId)
  funcVm.GoToFunc(E.EquipFuncId.EquipFunc, getEquipData("wash", itemUuid, configId))
end
local openEquipBreachView = function(itemUuid, configId)
  funcVm.GoToFunc(E.EquipFuncId.EquipFunc, getEquipData("breach", itemUuid, configId))
end
local openEquipRepairView = function(itemUuid, configId)
  funcVm.GoToFunc(E.EquipFuncId.EquipFunc, getEquipData("repair", itemUuid, configId))
end
local openEquipDecomposeView = function(itemUuid, configId)
  funcVm.GoToFunc(E.EquipFuncId.EquipFunc, getEquipData("decompose", itemUuid, configId))
end
local openEquipRecastView = function(itemUuid, configId)
  funcVm.GoToFunc(E.EquipFuncId.EquipFunc, getEquipData("recast", itemUuid, configId))
end
local openEquipRefineView = function(itemUuid, configId)
  funcVm.GoToFunc(E.EquipFuncId.EquipFunc, getEquipData("refine", itemUuid, configId))
end
local cloeseEquipFuncView = function()
  Z.UIMgr:CloseView("equip_function")
end
local getRepairCostItems = function(quality)
  local tab = Z.Global.EquipDurabilityFixCost
  local costPreCount, costConfigId
  for _, data in ipairs(tab) do
    if data[1] == quality then
      costConfigId = data[2]
      costPreCount = data[3]
      break
    end
  end
  if costPreCount == nil or costConfigId == nil then
    logError("not find equip durability fix cost ,quality is " .. quality)
    return nil
  end
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTypeTableMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local constData = itemTableMgr.GetRow(costConfigId)
  local itemType
  if constData then
    itemType = constData.Type
  end
  local itemTypeTableRow = itemTypeTableMgr.GetRow(itemType)
  if itemTypeTableRow == nil then
    return
  end
  local packages = Z.ContainerMgr.CharSerialize.itemPackage.packages[itemTypeTableRow.Package]
  local count = 0
  for key, value in pairs(packages.items) do
    if value.configId == costConfigId then
      count = count + value.count
    end
  end
  local ret = {
    configId = costConfigId,
    totalCount = count,
    preCount = costPreCount
  }
  return ret
end
local getGsTransferSourceItem = function()
  local equipData = Z.DataMgr.Get("equip_system_data")
  if equipData.GsTransferSourceItem then
    return equipData.GsTransferSourceItem.uuid, equipData.GsTransferSourceItem.configId
  end
  return nil
end
local getGsTransferDesItem = function()
  local equipData = Z.DataMgr.Get("equip_system_data")
  if equipData.GsTransferDesItem then
    return equipData.GsTransferDesItem.uuid, equipData.GsTransferDesItem.configId
  end
  return nil
end
local notifiGsTransferItemsChanged = function(desItem, sourceItem)
  local equipData = Z.DataMgr.Get("equip_system_data")
  equipData.GsTransferDesItem = desItem
  equipData.GsTransferSourceItem = sourceItem
  Z.EventMgr:Dispatch(Z.ConstValue.Equip.GSTransferItemsChanged)
end
local checkCanBreack = function(itemUuid, configId)
  local itemsVm = Z.VMMgr.GetVM("items")
  local itemData = itemsVm.GetItemInfobyItemId(itemUuid, configId)
  local maxEquipLevel = Z.DataMgr.Get("season_data").MaxEquipLevel
  local totalGs = getEquipGsByConfigId(itemData.configId)
  if not (itemData and itemData.equipAttr) or itemData.quality ~= 4 or maxEquipLevel > totalGs then
    return false
  end
  return true
end
local checkCanRepair = function(itemUuid, configId)
  return true
end
local checkCanGsTransfer = function(itemUuid, configId)
  return true
end
local getBreachCostMatreial = function(configId)
  local equipTableRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId)
  if equipTableRow == nil then
    return nil
  end
  local gsCostItems = Z.Global.EquipExtraGsCost
  local costConfigId, costCount
  for _, data in ipairs(gsCostItems) do
    if data[1] == equipTableRow.EquipPart then
      costConfigId = data[2]
      costCount = data[3]
      break
    end
  end
  local itemsVm = Z.VMMgr.GetVM("items")
  local totalCount = itemsVm.GetItemTotalCount(costConfigId)
  local ret = {
    totalCount = totalCount,
    costCount = costCount,
    costConfigId = costConfigId
  }
  return ret
end
local calculateBaseAttr = function(configId, gs)
  local equipTableRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId)
  if equipTableRow == nil then
    return
  end
  local typeAttrLibID = equipTableRow.TypeAttrLibID
  local equipAttrLibTableMgr = Z.TableMgr.GetTable("EquipAttrLibTableMgr")
  local lib
  local datas = equipAttrLibTableMgr.GetDatas()
  local maxGs = 0
  local maxValue
  for _, value in pairs(datas) do
    if value.AttrLibID == typeAttrLibID then
      local inculdePart = false
      for index, value in pairs(value.EquipPart) do
        if value == equipTableRow.EquipPart then
          inculdePart = true
          break
        end
      end
      if maxGs < value.EquipLevelRange[2] then
        maxGs = value.EquipLevelRange[2]
        maxValue = value
      end
      if inculdePart and gs > value.EquipLevelRange[1] and gs <= value.EquipLevelRange[2] then
        lib = value
        break
      end
    end
  end
  if lib == nil then
    lib = maxValue
  end
  local ret = {}
  if lib then
    for index, attrId in ipairs(lib.Attr) do
      local values = lib.ValueCal[index]
      local v = values[1] + values[2] * gs + values[3] * gs * gs
      v = math.floor(v)
      ret[attrId] = v
    end
  end
  return ret
end
local getBreachBaseAttr = function(itemUuid, configId)
  local itemsVm = Z.VMMgr.GetVM("items")
  local itemInfo = itemsVm.GetItemInfobyItemId(itemUuid, configId)
  local curTotalGs = getEquipGsByConfigId(itemInfo.configId)
  local addgs = Z.Global.EquipExtraGs
  local nextTotalGs = curTotalGs + tonumber(addgs)
  return calculateBaseAttr(configId, nextTotalGs)
end
local isRedQualityEquip = function(itemUuid, configId)
  local itemsVm = Z.VMMgr.GetVM("items")
  local itemData = itemsVm.GetItemInfobyItemId(itemUuid, configId)
  if not (itemData and itemData.equipAttr) or itemData.quality == 5 then
    return true
  end
  return false
end
local checkEquipDecompose = function(itemUuid, configId)
  local equipInfo = getSamePartEquipAttr(configId)
  if equipInfo and equipInfo.itemUuid == itemUuid then
    return false
  end
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  local equipTableRow = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId)
  if itemTableRow == nil or equipTableRow == nil then
    return false
  end
  local materials = Z.Global.EquipDecompose
  for _, data in ipairs(materials) do
    if data[1] == itemTableRow.Quality and data[2] == equipTableRow.EquipPart then
      return true
    end
  end
  return false
end
local notIsRedQualityEquip = function(itemUuid, configId)
  return not isRedQualityEquip(itemUuid, configId)
end
local openDamagedTips = function(posTrans)
  local viewData = {
    rect = posTrans,
    title = Lang("EquipDamaged"),
    content = Lang("EquipDamagedText"),
    isRightFirst = false
  }
  Z.UIMgr:OpenView("tips_icontitle_content", viewData)
end
local closeIconTitleContent = function()
  Z.UIMgr:CloseView("tips_icontitle_content")
end
local getEquipPartIdByConfigId = function(configId)
  local equipTabBase = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId, true)
  if equipTabBase then
    return equipTabBase.EquipPart
  end
  return 0
end
local getAllEquipByPartId = function(equipPart)
  local data = {}
  if equipPart == nil then
    return data
  end
  local allEquipInfos = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if allEquipInfos then
    for _, item in pairs(allEquipInfos.items) do
      local equipRow = Z.TableMgr.GetRow("EquipTableMgr", item.configId)
      if equipRow and getEquipPartIdByConfigId(item.configId) == equipPart then
        table.insert(data, {
          item = item,
          gs = equipRow.EquipGs
        })
      end
    end
  end
  return data
end
local getItemByPartId = function(equipPart)
  if equipPart == nil then
    return
  end
  local equipInfo = Z.ContainerMgr.CharSerialize.equip.equipList[equipPart]
  if equipInfo == nil then
    return
  end
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if package == nil then
    return
  end
  return package.items[equipInfo.itemUuid]
end
local getEquipMaxGsAndProfessionEquips = function(data, partId)
  local professionEquips = {}
  local maxGs = 0
  if data and 0 < #data then
    for i, item in ipairs(data) do
      local equipData = Z.TableMgr.GetTable("EquipTableMgr").GetRow(item.item.configId, true)
      if equipData then
        if partId == E.EquipPart.Weapon then
          local equipWeaponRow = Z.TableMgr.GetTable("EquipWeaponTableMgr").GetRow(item.item.configId, true)
          if equipWeaponRow then
            local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
            if curProfessionId == equipWeaponRow.ProfessionId then
              professionEquips[item.item.uuid] = true
              if maxGs < equipData.EquipGs then
                maxGs = equipData.EquipGs
              end
            end
          end
        elseif checkProfessionIsContainEquipAttr(item.item) then
          professionEquips[item.item.uuid] = true
          if maxGs < equipData.EquipGs then
            maxGs = equipData.EquipGs
          end
        end
      end
    end
  end
  return maxGs, professionEquips
end
local getEquipPartTabRed = function(partId)
  return E.RedType.RoleMain .. partId * 10
end
local isPutEquipByUuid = function(uuid)
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  for key, value in pairs(equipList) do
    if value.itemUuid == uuid then
      return true
    end
  end
  return false
end
local getEquipMinPerfectByLevel = function(configId, perfectLevle)
  local equipRecastVm = Z.VMMgr.GetVM("equip_recast")
  local equipPerfectLibTable = equipRecastVm.GetEquipPerfectRow(configId, perfectLevle)
  if equipPerfectLibTable then
    return equipPerfectLibTable.PerfectPart[1]
  end
  return 1
end
local openEquipSearchTips = function(transform)
  local searchVm = Z.VMMgr.GetVM("type_search")
  local functions = searchVm.GetObtainWayByType({
    201,
    202,
    203,
    204,
    205,
    206,
    207
  })
  if table.zcount(functions) == 0 then
    return
  end
  local viewData = {
    rect = transform,
    approachDatas = functions,
    isRightFirst = false
  }
  Z.UIMgr:OpenView("tips_approach", viewData)
end
local closeApproach = function()
  Z.UIMgr:CloseView("tips_approach")
end
local sortWeapon = function(weaponData, isAscending)
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  local sameData = {}
  local noData = {}
  for i, value in ipairs(weaponData) do
    local equipWeaponTableRow = Z.TableMgr.GetTable("EquipWeaponTableMgr").GetRow(value.configId)
    if equipWeaponTableRow and equipWeaponTableRow.ProfessionId == curProfessionId then
      sameData[#sameData + 1] = value
    else
      noData[#noData + 1] = value
    end
  end
  local itemSortVm = Z.VMMgr.GetVM("item_sort_factory")
  local sortData = {}
  sortData.equipSortType = E.EquipItemSortType.Quality
  sortData.isAscending = isAscending
  sortData.sortType = E.EquipItemSortType.Quality
  local sortFunc = itemSortVm.GetItemSortFunc(E.BackPackItemPackageType.Equip, sortData)
  table.sort(sameData, function(item1, item2)
    return sortFunc(item1, item2)
  end)
  table.sort(noData, function(item1, item2)
    return sortFunc(item1, item2)
  end)
  table.zmerge(sameData, noData)
  return sameData
end
local getEquipsByConfigId = function(configId, difUuid, isNoGetPutEquip)
  local tab = {}
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if package then
    for i, item in pairs(package.items) do
      if item.configId == configId and difUuid ~= item.uuid then
        if isNoGetPutEquip then
          if not isPutEquipByUuid(item.uuid) then
            tab[#tab + 1] = item
          end
        else
          tab[#tab + 1] = item
        end
      end
    end
  end
  return tab
end
local checkEquipIsCurProfession = function(configId)
  local equipWeaponRow = Z.TableMgr.GetTable("EquipWeaponTableMgr").GetRow(configId, true)
  if equipWeaponRow and Z.ContainerMgr.CharSerialize.professionList.curProfessionId ~= equipWeaponRow.ProfessionId then
    return false
  end
  return true
end
local checkPutOnEquipIsCurProfession = function(configId)
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, false)
  if equipTable then
    local professionSystemTable = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(Z.ContainerMgr.CharSerialize.professionList.curProfessionId)
    if equipTable.EquipPart == E.EquipPart.Weapon then
      local equipWeaponRow = Z.TableMgr.GetTable("EquipWeaponTableMgr").GetRow(configId)
      if equipWeaponRow and Z.ContainerMgr.CharSerialize.professionList.curProfessionId ~= equipWeaponRow.ProfessionId and professionSystemTable then
        Z.TipsVM.ShowTips(150007, {
          val = professionSystemTable.Name
        })
        return false
      end
    end
  end
  return true
end
local ret = {
  GetAllEquipItemInfos = getAllEquipItemInfos,
  HasEquipItemInfos = hasEquipItemInfos,
  GetSamePartEquipAttr = getSamePartEquipAttr,
  GetEquipAttr = getEquipAttr,
  AsyncPutOnEquip = asyncPutOnEquip,
  AsyncTakeOffEquip = asyncTakeOffEquip,
  AsyncEquipBreach = asyncEquipBreach,
  AsyncEquipDecompose = asyncEquipDecompose,
  OpenEquipSystemView = openEquipSystemView,
  OpenEquipGsTransferView = openEquipCopyView,
  OpenEquipWashView = openEquipWashView,
  OpenEquipBreachView = openEquipBreachView,
  OpenEquipRepairView = openEquipRepairView,
  OpenEquipDecomposeView = openEquipDecomposeView,
  OpenEquipRecastView = openEquipRecastView,
  OpenEquipRefineView = openEquipRefineView,
  CloeseEquipFuncView = cloeseEquipFuncView,
  GetRepairCostItems = getRepairCostItems,
  CheckCanBreack = checkCanBreack,
  CheckCanRepair = checkCanRepair,
  CheckCanGsTransfer = checkCanGsTransfer,
  CheckCanRecast = checkCanRecast,
  CalculateBaseAttr = calculateBaseAttr,
  GetBreachBaseAttr = getBreachBaseAttr,
  GetBreachCostMatreial = getBreachCostMatreial,
  NotifiGsTransferItemsChanged = notifiGsTransferItemsChanged,
  IsRedQualityEquip = isRedQualityEquip,
  NotIsRedQualityEquip = notIsRedQualityEquip,
  CheckEquipDecomonece = checkEquipDecompose,
  GetGsTransferSourceItem = getGsTransferSourceItem,
  GetGsTransferDesItem = getGsTransferDesItem,
  OpenEquipFuncView = openEquipFuncView,
  CloseEquipSystemView = closeEquipSystemView,
  OpenChangeEquipView = openChangeEquipView,
  CloseChangeEquipView = closeChangeEquipView,
  GetRepairEquip = getRepairEquip,
  EquipDurabilityWatcher = equipDurabilityWatcher,
  UpdateEquipFashion = updateEquipFashion,
  OpenDamagedTips = openDamagedTips,
  CloseIconTitleContent = closeIconTitleContent,
  GetAllEquipByPartId = getAllEquipByPartId,
  GetEquipMaxGsAndProfessionEquips = getEquipMaxGsAndProfessionEquips,
  GetEquipPartIdByConfigId = getEquipPartIdByConfigId,
  GetEquipPartTabRed = getEquipPartTabRed,
  IsPutEquipByUuid = isPutEquipByUuid,
  GetEquipMinPerfectByLevel = getEquipMinPerfectByLevel,
  OpenEquipSearchTips = openEquipSearchTips,
  CloseApproach = closeApproach,
  SortWeapon = sortWeapon,
  OpenDayDialog = openDayDialog,
  GetEquipsByConfigId = getEquipsByConfigId,
  CheckEquipIsCurProfession = checkEquipIsCurProfession,
  CheckProfessionIsContainEquipAttr = checkProfessionIsContainEquipAttr,
  GetEquipGsByConfigId = getEquipGsByConfigId,
  GetItemByPartId = getItemByPartId,
  CheckPutOnEquip = checkPutOnEquip,
  CheckIsFitProfessionAttrByAttrId = checkIsFitProfessionAttrByAttrId,
  CheckPutOnEquipIsCurProfession = checkPutOnEquipIsCurProfession
}
return ret
