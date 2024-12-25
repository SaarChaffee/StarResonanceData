local ItemsVM = {}
local itemTypeTableMgr_ = Z.TableMgr.GetTable("ItemTypeTableMgr")
local itemFunctionTbl = Z.TableMgr.GetTable("ItemFunctionTableMgr")
local backPackData_ = Z.DataMgr.Get("backpack_data")
local itemsData = Z.DataMgr.Get("items_data")
local worldProxy = require("zproxy.world_proxy")
local unionVM = Z.VMMgr.GetVM("union")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
local AffixColor = {
  [1] = "#62b3ff",
  [2] = "#fd6c63",
  [3] = "#ffc26d"
}
local handleError = function(errCode)
  if errCode ~= 0 and Z.PbEnum("EErrorCode", "ErrAsynchronousReturn") ~= errCode then
    Z.TipsVM.ShowTips(errCode)
  end
end

function ItemsVM.showExpireItemTips(item)
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTableData = itemsTableMgr.GetRow(item.configId)
  if itemTableData and itemTableData.TimeType ~= 0 then
    local time = item.expireTime - Z.ServerTime:GetServerTime()
    if time < 0 then
      local param = {
        item = {
          name = itemTableData.Name
        }
      }
      Z.TipsVM.ShowTipsLang(100106, param)
    end
  end
end

function ItemsVM.GetSingleItemCreateTime(packageId, configId)
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[packageId]
  if not package then
    return "nil"
  end
  for _, item in pairs(package.items) do
    if item.configId == configId then
      return Z.TimeTools.FormatTimeToYMD(item.createTime)
    end
  end
  return ""
end

function ItemsVM.AsyncSetQuickBar(itemConfigId, token)
  local ret = worldProxy.SetQuickBar(itemConfigId, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    Z.EventMgr:Dispatch(Z.ConstValue.Backpack.ChangeQuickBar, itemConfigId)
  end
  return ret
end

function ItemsVM.checkItemAutoApply(item)
  local cfg = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(item.configId, true)
  if cfg and cfg.AutoApplyClient > 0 then
    ItemsVM.OpenSelectGiftPackageView(item.configId, item.uuid, item.count)
  end
end

function ItemsVM.traceNpc(functionSearchData, tipsId)
  local npcId = Z.EntityTabManager.GetNpcIdByFunctionId(functionSearchData.functionId)
  local sceneId, npcEntityData = Z.EntityTabManager.GetNpcEntityDataByNpcId(npcId)
  if npcEntityData then
    local mapVm = Z.VMMgr.GetVM("map")
    local uid = npcEntityData.UId % Z.ConstValue.GlobalLevelIdOffset
    mapVm.SetTraceEntity(E.GoalGuideSource.GetItem, sceneId, uid, Z.GoalPosType.Npc, false)
    Z.TipsVM.CloseItemTipsView(tipsId)
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Map, sceneId)
  else
    logError("not find NpcEntityDataByNpcId npcid ={0}, functionId = {1}", npcId, functionSearchData.functionId)
  end
end

function ItemsVM.traceZone(functionSearchData, tipsId)
  local sceneId, zoneEntityData = Z.EntityTabManager.GetZoneEntityDataBySceneTagId(functionSearchData.sceneTagId)
  if zoneEntityData then
    local mapVm = Z.VMMgr.GetVM("map")
    local uid = zoneEntityData.UId % Z.ConstValue.GlobalLevelIdOffset
    mapVm.SetTraceEntity(E.GoalGuideSource.GetItem, sceneId, uid, Z.GoalPosType.Zone, false)
    Z.TipsVM.CloseItemTipsView(tipsId)
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Map, sceneId)
  else
    logError("not find ZoneEntityDataBySceneTagId SceneTagId ={0}, functionId = {1}", functionSearchData.sceneTagId, functionSearchData.functionId)
  end
end

function ItemsVM.traceSceneObject(functionSearchData, tipsId)
  local sceneId, sceneEntityData = Z.EntityTabManager.GetSceneEntityDataBySceneTagId(functionSearchData.sceneTagId)
  if sceneEntityData then
    local mapVm = Z.VMMgr.GetVM("map")
    local uid = sceneEntityData.UId % Z.ConstValue.GlobalLevelIdOffset
    mapVm.SetTraceEntity(E.GoalGuideSource.GetItem, sceneId, uid, Z.GoalPosType.SceneObject, false)
    Z.TipsVM.CloseItemTipsView(tipsId)
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Map, sceneId)
  else
    logError("not find ZoneEntityDataBySceneTagId SceneTagId ={0}, functionId = {1}", functionSearchData.sceneTagId, functionSearchData.functionId)
  end
end

function ItemsVM.RemoveNewPackageItems(package)
  if backPackData_.NewPackageItems[package] then
    for index, value in pairs(backPackData_.NewPackageItems[package]) do
      backPackData_.NewItems[value] = nil
    end
    backPackData_.NewPackageItems[package] = {}
  end
end

function ItemsVM.setQuickBar(configId)
  local quickBarId = Z.ContainerMgr.CharSerialize.itemPackage.quickBar
  if quickBarId == 0 or quickBarId == nil then
    local cfg = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(configId, true)
    if cfg and cfg.CanQuick == 1 then
      Z.CoroUtil.create_coro_xpcall(function()
        itemsData:CreatCancelSource()
        ItemsVM.AsyncSetQuickBar(configId, itemsData.CancelSource:CreateToken())
        itemsData:RecycleCancelSource()
      end)()
    end
  end
end

function ItemsVM.GetItemCd(package, configId)
  local fun = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(configId, true)
  if fun == nil then
    return
  end
  local itemCd = package.itemCd[configId]
  local publicCd, publicUseCD
  if fun and #fun.PublicCD > 0 then
    publicCd = Z.ContainerMgr.CharSerialize.itemPackage.useGroupCd[fun.PublicCD[1]]
    publicUseCD = itemsData:GetGroupCd(fun.PublicCD[1]) or fun.PublicCD[2]
  end
  if itemCd == nil and publicCd == nil then
    return
  end
  if itemCd and publicCd and 0 < itemCd and 0 < publicCd then
    if itemCd > publicCd then
      return itemCd, fun.UseCD
    else
      return publicCd, publicUseCD
    end
  end
  if publicCd and publicUseCD then
    return publicCd, publicUseCD
  end
  if itemCd and 0 < itemCd then
    return itemCd, fun.UseCD
  end
end

function ItemsVM.CheckPackageTypeByItemUuid(itemUuid, packageType)
  if not itemUuid then
    logError("itemUuid is nil")
    return
  end
  local itemPackageType = itemsData:GetItemPackageType(itemUuid)
  return itemPackageType == packageType
end

function ItemsVM.CheckPackageTypeByConfigId(configId, packageType)
  if not configId then
    logError("configId is nil")
    return
  end
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local item = itemsTableMgr.GetRow(configId, true)
  if item == nil then
    return false
  end
  local itemType = itemTypeTableMgr_.GetRow(item.Type, true)
  if itemType then
    return itemType.Package == packageType
  end
end

function ItemsVM.GetItemConfigId(itemUuid, packageType)
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[packageType]
  local item = package.items[itemUuid]
  if item == nil then
    return nil
  end
  return item.configId
end

function ItemsVM.GetItemInfo(itemUuid, packageType)
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[packageType]
  return package.items[itemUuid]
end

function ItemsVM.GetItemTabDataByUuid(itemUuid)
  local packages = Z.ContainerMgr.CharSerialize.itemPackage.packages
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  for _, package in pairs(packages) do
    local item = package.items[itemUuid]
    if item then
      return itemsTableMgr.GetRow(item.configId, true)
    end
  end
  return nil
end

function ItemsVM.GetPackageTypebyItemId(itemConfigId)
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTableData = itemsTableMgr.GetRow(itemConfigId)
  if itemTableData == nil then
    logError("itemTableData is nil, configId is {0}", itemConfigId)
    return nil
  end
  local itemTypeData = itemTypeTableMgr_.GetRow(itemTableData.Type)
  if itemTypeData then
    return itemTypeData.Package
  end
end

function ItemsVM.GetPackageInfobyItemId(itemConfigId)
  local packageType = ItemsVM.GetPackageTypebyItemId(itemConfigId)
  if packageType == nil then
    return nil
  end
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[packageType]
  return package
end

function ItemsVM.GetItemInfobyItemId(itemUuid, itemConfigId)
  if itemUuid == nil or itemConfigId == nil then
    return
  end
  local package = ItemsVM.GetPackageInfobyItemId(itemConfigId)
  if package then
    return package.items[itemUuid]
  end
end

function ItemsVM.GetItemTotalCount(configId)
  if configId == nil or configId == 0 then
    return 0
  end
  local ret = 0
  local packageType = ItemsVM.GetPackageTypebyItemId(configId)
  if packageType == nil then
    return 0
  end
  if packageType == E.BackPackItemPackageType.UnionResource then
    return unionVM:GetUnionResourceCount(configId)
  else
    local package = ItemsVM.GetPackageInfobyItemId(configId)
    local itemUuids = itemsData:GetItemUuidsByConfigId(configId)
    if itemUuids == nil or #itemUuids < 1 then
      return 0
    end
    for _, itemUuid in ipairs(itemUuids) do
      local item = package.items[itemUuid]
      if item then
        ret = ret + item.count
      end
    end
  end
  return ret
end

function ItemsVM.GetItemIds(packageType, itemFilterFuncs, itemSortfunc, isShortcuts)
  local itemFunctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local ids = {}
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[packageType]
  for _, item in pairs(package.items) do
    local isOk = true
    if itemFilterFuncs then
      if type(itemFilterFuncs) == "table" and 0 < #itemFilterFuncs then
        for _, filterFunc in ipairs(itemFilterFuncs) do
          isOk = filterFunc(item.uuid, item.configId)
          if not isOk then
            break
          end
        end
      end
      if type(itemFilterFuncs) == "function" then
        isOk = itemFilterFuncs(item.uuid, item.configId)
      end
    end
    if packageType == E.BackPackItemPackageType.Item and isShortcuts then
      local itemConfigData = itemFunctionTableMgr.GetRow(item.configId, true)
      if itemConfigData and itemConfigData.CanQuick == 1 then
        isOk = true
      else
        isOk = false
      end
    end
    if isOk then
      table.insert(ids, {
        itemUuid = item.uuid,
        configId = item.configId
      })
    end
  end
  if itemSortfunc and type(itemSortfunc) == "function" then
    table.sort(ids, itemSortfunc)
  end
  return ids
end

function ItemsVM.checkItemUseCdByConfigId(configId)
  local serverTime = Z.ServerTime:GetServerTime()
  local package = ItemsVM.GetPackageInfobyItemId(configId)
  local cdTime = package.itemCd[configId] or 0
  local funRow = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(configId)
  local publicCd = 0
  if funRow and 0 < #funRow.PublicCD then
    publicCd = Z.ContainerMgr.CharSerialize.itemPackage.useGroupCd[funRow.PublicCD[1]] or 0
  end
  if cdTime == 0 and publicCd == 0 then
    return true
  end
  cdTime = cdTime > publicCd and cdTime or publicCd
  local state, diffTime = pcall(Z.TimeTools.DiffTime, cdTime, serverTime)
  if not state then
    logError(string.zconcat("checkItemUseCdByConfigId error:", diffTime, "cdTime:", cdTime, "serverTime:", serverTime))
    return false
  end
  if 0 < diffTime then
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
    if itemRow then
      local param = {
        item = {
          name = itemRow.Name
        }
      }
      Z.TipsVM.ShowTipsLang(100103, param)
    end
    return false
  end
  return true
end

function ItemsVM.setItemPublicCdByConfigId(itemConfigId)
  local itemFuncRow = itemFunctionTbl.GetRow(itemConfigId, true)
  if not itemFuncRow then
    return
  end
  if #itemFuncRow.PublicCD > 0 then
    itemsData:SetGroupCd(itemFuncRow.PublicCD[1], itemFuncRow.PublicCD[2])
  end
end

function ItemsVM.CheckItemIsPackageWithLimit(configId)
  local itemFunctionTable = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local itemFunctionTableRow = itemFunctionTable.GetRow(configId, true)
  if not itemFunctionTableRow or itemFunctionTableRow.Type ~= E.ItemFunctionType.Gift then
    return false
  end
  local awardId = tonumber(itemFunctionTableRow.Parameter[1])
  local awardTable = Z.TableMgr.GetTable("AwardPackageTableMgr")
  local awardTableRow = awardTable.GetRow(awardId)
  if awardTableRow == nil then
    return false
  end
  local awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  local awardList = awardPreviewVM_.GetAllAwardPreListByIds(awardId)
  if awardList == nil or next(awardList) == nil then
    return false
  end
  local isProbability = false
  for i, v in ipairs(awardList) do
    if v.PrevDropType == E.AwardPrevDropType.Probability then
      isProbability = true
      break
    end
  end
  if awardTableRow.PackType == Z.PbEnum("EAwardType", "EAwardTypeSelect") or isProbability then
    return false
  else
    for index, itemData in ipairs(awardList) do
      if ItemsVM.CheckItemIsLimited(itemData.awardId, itemData.awardNum) then
        return true
      end
    end
  end
  return false
end

function ItemsVM.CheckItemIsLimited(itemConfigId, itemNum)
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTypeMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local itemTableBae = itemTableMgr.GetRow(itemConfigId)
  if itemTableBae then
    local itemTypeTableRow = itemTypeMgr.GetRow(itemTableBae.Type)
    if itemTypeTableRow then
      local limitCount = itemTypeTableRow.UpperLlimit
      local curCount = ItemsVM.GetItemTotalCount(itemConfigId)
      if limitCount == 0 then
        return false
      end
      if limitCount < curCount + itemNum then
        return true
      end
    end
  end
  return false
end

function ItemsVM.AsyncUseItemByUuid(useItemParam, token)
  local configRow = ItemsVM.GetItemTabDataByUuid(useItemParam.itemUuid)
  if not configRow then
    return
  end
  local configId = configRow.Id
  local itemFuncRow = itemFunctionTbl.GetRow(configId, true)
  if not itemFuncRow then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.UseItem, configId)
  if itemFuncRow.Type > 100 and itemFuncRow.Type == Z.PbEnum("EItemUseType", "ItemUseOpenUI") then
    local funcId = tonumber(itemFuncRow.Parameter[1])
    if funcId then
      local gotoVM = Z.VMMgr.GetVM("gotofunc")
      if gotoVM.CheckFuncCanUse(funcId) then
        gotoVM.GoToFunc(funcId)
      end
    end
    return
  end
  if itemFuncRow.UseCD and itemFuncRow.UseCD > 0 and not ItemsVM.checkItemUseCdByConfigId(configId) then
    return
  end
  ItemsVM.setItemPublicCdByConfigId(configId)
  if ItemsVM.CheckItemIsPackageWithLimit(configId) then
    local onConfirmCB = function()
      Z.DialogViewDataMgr:CloseDialogView()
    end
    local dialogViewData = {
      dlgType = E.DlgType.OK,
      labDesc = Lang("ItemIsPackageWithLimit", {
        val = ItemsVM.ApplyItemNameWithQualityTag(configId)
      }),
      onConfirm = onConfirmCB,
      labYes = Lang("Confirm")
    }
    Z.DialogViewDataMgr:OpenDialogView(dialogViewData, E.EDialogViewDataType.System, true)
    return
  end
  local ret = worldProxy.UseItem(useItemParam, token)
  if ret == 0 then
    if itemFuncRow.SoundEffect and itemFuncRow.SoundEffect ~= "" then
      Z.AudioMgr:Play(itemFuncRow.SoundEffect)
    end
  else
    if 0 < #itemFuncRow.PublicCD then
      itemsData:SetGroupCd(itemFuncRow.PublicCD[1], nil)
    end
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end

function ItemsVM.AsyncUseItemByConfigId(configId, token, useNum)
  local uuidList = itemsData:GetItemUuidsByConfigId(configId)
  if uuidList and 0 < #uuidList then
    local useItemParam = {}
    useItemParam.itemUuid = uuidList[1]
    useItemParam.useNum = useNum or 1
    return ItemsVM.AsyncUseItemByUuid(useItemParam, token)
  end
end

function ItemsVM.OpenBatchUseView(configId, itemUuid, itemCount)
  if itemUuid == nil and itemCount < 2 then
    return false
  end
  local itemFuctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local funcData = itemFuctionTableMgr.GetRow(configId, true)
  if funcData == nil then
    return
  end
  if funcData.ItemBatch <= 1 then
    return false
  end
  local usePopVm_ = Z.VMMgr.GetVM("use_item_popup")
  local viewData = {
    title = "SelectUseNum",
    itemUuid = itemUuid,
    configId = configId,
    maxUseCount = funcData.ItemBatch,
    itemCount = itemCount,
    isUse = true
  }
  usePopVm_.OpenUsePopup(viewData)
  return true
end

function ItemsVM.OpenDeleteItemView(configId, itemUuid, itemCount)
  if itemUuid == nil then
    return
  end
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTableRow = itemTableMgr.GetRow(configId, true)
  if itemTableRow == nil then
    return
  end
  if itemTableRow.Discard ~= 1 then
    return
  end
  local usePopVm_ = Z.VMMgr.GetVM("use_item_popup")
  local viewData = {
    title = "SelectDeleteNum",
    secondTitle = 1 < itemCount and "SelectDeleteNumConfirm" or "SelectDeleteNumConfirmOneItem",
    itemUuid = itemUuid,
    configId = configId,
    maxUseCount = itemCount,
    itemCount = itemCount,
    isDiscard = true
  }
  usePopVm_.OpenDeletePopup(viewData)
  return true
end

function ItemsVM.OpenSelectGiftPackageView(configId, itemUuid, itemCount)
  local itemFuctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local funcData = itemFuctionTableMgr.GetRow(configId, true)
  if funcData == nil or funcData.Type ~= E.ItemFunctionType.Gift or funcData.Parameter == nil or #funcData.Parameter < 1 then
    return false
  end
  local awardId = tonumber(funcData.Parameter[1])
  local bagPackType = awardPreviewVm.GetAwardType(awardId)
  local viewData = {}
  viewData.itemUuid = itemUuid
  viewData.itemId = configId
  viewData.awardId = awardId
  viewData.ItemBatchCount = funcData.ItemBatch
  viewData.awardNum = itemCount
  if bagPackType == Z.PbEnum("EAwardType", "EAwardTypeSelect") then
    if funcData.Parameter[2] == "1" then
      Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.SelectPack, "bag_selectpack_popup_new", viewData, 2)
    else
      Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.SelectPack, "bag_selectpack_popup", viewData, 2)
    end
    return true
  end
  return false
end

function ItemsVM.ApplyItemNameWithQualityTag(configId, isUnderLine)
  local item = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if item == nil then
    return ""
  end
  local name = item.Name
  if isUnderLine then
    name = string.zconcat("<u>", item.Name, "</u>")
  end
  local colorTag = "ItemQuality_" .. item.Quality
  local name = Z.RichTextHelper.ApplyStyleTag(name, colorTag)
  return name
end

function ItemsVM.OpenKeyRecastView(configId, itemUuid)
  local viewData = {}
  viewData.itemUuid = itemUuid
  viewData.itemId = configId
  Z.UIMgr:OpenView("hero_dungeon_key_popup", viewData)
end

function ItemsVM.CloseKeyRecastView()
  Z.UIMgr:CloseView("hero_dungeon_key_popup")
end

function ItemsVM.OpenKeyRecastConfirmView(configId, itemUuid)
  local viewData = {}
  viewData.itemUuid = itemUuid
  viewData.itemId = configId
  Z.UIMgr:OpenView("hero_dungeon_key_expend_popup", viewData)
end

function ItemsVM.CloseKeyRecastConfirmView()
  Z.UIMgr:CloseView("hero_dungeon_key_expend_popup")
end

function ItemsVM.AsyncReforgeKey(itemUuid, token)
  local param = {itemUuid = itemUuid}
  local ret = worldProxy.ReforgeKey(param, token)
  if ret == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.KeyRecastSuccess)
  end
  return ret
end

function ItemsVM.GetRecastKeyCost()
  local limitID = Z.Global.HeroDungeonKeyRecastCounterId
  local costTime = 0
  local countData = Z.ContainerMgr.CharSerialize.counterList.counterMap[limitID]
  if countData then
    costTime = countData.counter
  end
  local nextTime = costTime + 1
  local costCfg = Z.Global.HeroDungeonKeyRecastCost
  for _, value in ipairs(costCfg) do
    if nextTime >= value[1] and nextTime <= value[2] then
      return value
    end
  end
  return nil
end

function ItemsVM.GetKeyAffixStr(itemUuid, type)
  local info = ItemsVM.GetItemInfo(itemUuid, type)
  local affixStr = ""
  if info then
    local affixCfgs = Z.TableMgr.GetTable("AffixTableMgr")
    local linkStr = "<u><link=%d>%s</link><u>"
    local affix = info.affixData.affixIds
    local count = table.zcount(affix)
    for key, value in ipairs(affix) do
      local cfg = affixCfgs.GetRow(value)
      if cfg then
        local affixName = cfg.Name
        local colorStr = AffixColor[cfg.EffectType]
        if colorStr then
          affixName = string.format("<color=%s>%s</color>", colorStr, affixName)
        end
        local s = string.format(linkStr, key, affixName)
        local endStr = key < count and "," or ""
        affixStr = affixStr .. s .. endStr
      end
    end
  end
  return affixStr
end

function ItemsVM.CheckItemIsKey(configId)
  return configId == Z.Global.HeroDungeonKeyId
end

function ItemsVM.GetIsNeedRecastKeyTips()
  return itemsData:GetKeyRecastTips()
end

function ItemsVM.SetIsNeedRecastKeyTips(needTips)
  itemsData:SetKeyRecastTips(needTips)
end

function ItemsVM.CheckItemPackageIsFull(configId)
  local package = ItemsVM.GetPackageInfobyItemId(configId)
  if package == nil then
    return false
  end
  local curCount = table.zcount(package.items)
  return curCount > package.maxCapacity
end

function ItemsVM.CheckIsFashionItem(configId)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if itemCfg then
    local itemTypeCfg = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemCfg.Type)
    if itemTypeCfg and itemTypeCfg.Package == E.BackPackItemPackageType.Fashion then
      return true
    end
  end
  return false
end

function ItemsVM.AsyncDeleteItem(itemUuid, count, token)
  local param = {itemUuid = itemUuid, count = count}
  local ret = worldProxy.DeleteItem(param, token)
  handleError(ret)
end

function ItemsVM.GetItemIcon(configID, gender)
  local itemConfig = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configID)
  if gender == nil then
    gender = Z.ContainerMgr.CharSerialize.charBase.gender
  end
  if itemConfig then
    if gender == 2 and itemConfig.Icon2 ~= nil and string.len(itemConfig.Icon2) > 0 then
      return itemConfig.Icon2
    end
    return itemConfig.Icon
  end
  return ""
end

return ItemsVM
