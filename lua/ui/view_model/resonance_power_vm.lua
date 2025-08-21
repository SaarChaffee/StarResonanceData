local openResonancePowerCreate = function(itemUuid, configId)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.ResonanceFuncId.Create)
  if not isOn then
    return
  end
  local viewData = {
    FuncId = E.ResonanceFuncId.Create,
    MakeParam = {
      configId = configId or -1,
      count = 1
    }
  }
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_03, "weapon_develop_intensify_window", function()
    Z.UIMgr:OpenView("weapon_develop_intensify_window", viewData)
  end, Z.ConstValue.UnrealSceneConfigPaths.Backdrop_Explore)
end
local openResonancePowerDecompose = function(itemUuid, configId)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.ResonanceFuncId.Decompose)
  if not isOn then
    return
  end
  local viewData = {
    FuncId = E.ResonanceFuncId.Decompose
  }
  if itemUuid ~= nil and configId ~= nil then
    viewData.DecomposeParam = {
      itemUuid = itemUuid,
      configId = configId,
      count = 1
    }
  end
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_03, "weapon_develop_intensify_window", function()
    Z.UIMgr:OpenView("weapon_develop_intensify_window", viewData)
  end, Z.ConstValue.UnrealSceneConfigPaths.Backdrop_Explore)
end
local reqCreateResonancePower = function(itemId, count, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.itemId = itemId
  request.count = count
  local reply = worldProxy.AoYiItemFusion(request, cancelToken)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    local items = {
      {configId = itemId, count = count}
    }
    Z.VMMgr.GetVM("item_show").OpenItemShowView(items)
    return true
  end
end
local reqDecomposeResonancePower = function(decomposeDict, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.aoYiItems = decomposeDict
  local reply = worldProxy.AoYiItemDecompose(request, cancelToken)
  if reply.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(reply.items)
  end
  if reply.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(reply.errCode)
    return false
  end
end
local closeResonancePowerView = function()
  Z.UIMgr:CloseView("weapon_develop_intensify_window")
end
local getDecomposeGetAward = function(consumeDict)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local itemsVM = Z.VMMgr.GetVM("items")
  local awardIds = {}
  for _, consume in pairs(consumeDict) do
    local dataRow = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(consume.configId)
    if dataRow ~= nil then
      for i = 1, consume.count do
        for _, awardPackageId in ipairs(dataRow.DecomposeAwardPackID) do
          table.insert(awardIds, awardPackageId[1])
        end
      end
    end
  end
  return awardPreviewVm.GetAllAwardPreListByIds(awardIds)
end
local getCreateConsumeAward = function(configId, count)
  local costList = {}
  local dataRow_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(configId)
  for i, v in ipairs(dataRow_.MakeConsume) do
    costList[i] = {
      ItemId = v[1],
      Num = v[2] * count
    }
  end
  return costList
end
local openDecomposeAcquireView = function(viewData)
  Z.UIMgr:OpenView("resonacne_power_decompose_acquire", viewData)
end
local closeDecomposeAcquireView = function()
  Z.UIMgr:CloseView("resonacne_power_decompose_acquire")
end
local getMaxCreateCount = function(configId)
  local maxCount_ = 999999999
  local canCreate = true
  local notEnoughItems_ = {}
  local aoyiItemCfg_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(configId)
  local itemVM = Z.VMMgr.GetVM("items")
  for _, v in ipairs(aoyiItemCfg_.MakeConsume) do
    local configId_ = v[1]
    local needCount = v[2]
    local haveCount = itemVM.GetItemTotalCount(configId_)
    local count_ = math.floor(haveCount / needCount)
    if maxCount_ > count_ then
      maxCount_ = count_
    end
    if count_ < 1 then
      table.insert(notEnoughItems_, configId_)
    end
  end
  if maxCount_ < 1 then
    maxCount_ = 1
    canCreate = false
  else
    canCreate = true
  end
  local notEnoughItem_
  if 0 < #notEnoughItems_ then
    table.sort(notEnoughItems_)
    notEnoughItem_ = notEnoughItems_[1]
  end
  return maxCount_, canCreate, notEnoughItem_
end
local getNotEnoughItemByCount = function(configId, count)
  local notEnoughItems_ = {}
  local aoyiItemCfg_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(configId)
  local itemVM = Z.VMMgr.GetVM("items")
  for _, v in ipairs(aoyiItemCfg_.MakeConsume) do
    local configId_ = v[1]
    local needCount = v[2] * count
    local haveCount = itemVM.GetItemTotalCount(configId_)
    if needCount > haveCount then
      table.insert(notEnoughItems_, configId_)
    end
  end
  local notEnoughItem_
  if 0 < #notEnoughItems_ then
    table.sort(notEnoughItems_)
    notEnoughItem_ = notEnoughItems_[1]
  end
  return notEnoughItem_
end
local checkCanMake = function(configId)
  local config = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(configId)
  local itemVM = Z.VMMgr.GetVM("items")
  for _, v in ipairs(config.MakeConsume) do
    local configId = v[1]
    local needCount = v[2]
    local haveCount = itemVM.GetItemTotalCount(configId)
    if needCount > haveCount then
      return false
    end
  end
  return true
end
local checkHaveCoreMaterial = function(configId)
  local config = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(configId)
  if config == nil then
    return false
  end
  local itemVM = Z.VMMgr.GetVM("items")
  for _, v in ipairs(config.MakeConsume) do
    local configId = v[1]
    local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", configId)
    if itemConfig and itemConfig.Type == E.ResonanceSkillItemType.Material then
      local needCount = v[2]
      local haveCount = itemVM.GetItemTotalCount(configId)
      return needCount <= haveCount
    end
  end
  return true
end
local getResonanceMakeList = function(filterData, sortType, isAscending, selectConfigId)
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local configList = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetDatas()
  local resultList = {}
  for k, v in pairs(configList) do
    local isCanInsert = true
    if v.SkillId ~= 0 then
      local aoyiConfig = Z.TableMgr.GetRow("SkillAoyiTableMgr", v.SkillId)
      if aoyiConfig then
        if filterData then
          local filterHave = filterData[E.CommonFilterType.ResonanceHave]
          if filterHave and next(filterHave) and next(filterHave.value) then
            local haveCoreItem = checkHaveCoreMaterial(k)
            if filterHave.value[0] and filterHave.value[1] then
              isCanInsert = true
            elseif filterHave.value[0] and haveCoreItem or filterHave.value[1] and not haveCoreItem then
              isCanInsert = false
            end
          end
          local filterRarity = filterData[E.CommonFilterType.ResonanceSkillRarity]
          if filterRarity and next(filterRarity) and next(filterRarity.value) and not filterRarity.value[aoyiConfig.RarityType] then
            isCanInsert = false
          end
          local filterType = filterData[E.CommonFilterType.ResonanceSkillType]
          if filterType and next(filterType) and next(filterType.value) then
            local isInclude = false
            for i, type in ipairs(aoyiConfig.ShowSkillType) do
              if filterType.value[type] then
                isInclude = true
                break
              end
            end
            if not isInclude then
              isCanInsert = false
            end
          end
        end
      else
        isCanInsert = false
      end
    else
      isCanInsert = false
    end
    if isCanInsert then
      table.insert(resultList, v.Id)
    end
  end
  local isInGuide = Z.GuideMgr:IsGuideShow(3633)
  if sortType == E.ResonanceItemSortType.Quality then
    table.sort(resultList, function(a, b)
      local configA = itemTableMgr.GetRow(a)
      local configB = itemTableMgr.GetRow(b)
      local canMakeA = isInGuide and checkCanMake(a) and 1 or 0
      local canMakeB = isInGuide and checkCanMake(b) and 1 or 0
      if canMakeA == canMakeB then
        if configA and configB then
          if configA.Quality == configB.Quality then
            return a < b
          elseif isAscending then
            return configA.Quality > configB.Quality
          else
            return configA.Quality < configB.Quality
          end
        else
          return false
        end
      else
        return canMakeA > canMakeB
      end
    end)
  end
  return resultList
end
local getResonanceDecomposeList = function(filterData, sortType, isAscending, decomposeDict)
  local itemSortFactoryVM = Z.VMMgr.GetVM("item_sort_factory")
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local sortFunc = itemSortFactoryVM.GetItemSortFunc(E.BackPackItemPackageType.ResonanceSkill, {equipSortType = sortType, isAscending = isAscending})
  local itemIdList = itemsVM.GetItemIds(E.BackPackItemPackageType.ResonanceSkill, nil, sortFunc, false)
  local resultList = {}
  for k, v in ipairs(itemIdList) do
    local isCanInsert = true
    local aoyiItemConfig = Z.TableMgr.GetRow("SkillAoyiItemTableMgr", v.configId)
    if aoyiItemConfig then
      if aoyiItemConfig.SkillId ~= 0 then
        local aoyiConfig = Z.TableMgr.GetRow("SkillAoyiTableMgr", aoyiItemConfig.SkillId)
        if aoyiConfig then
          if filterData then
            local filterRarity = filterData[E.CommonFilterType.ResonanceSkillRarity]
            if filterRarity and next(filterRarity) and next(filterRarity.value) and not filterRarity.value[aoyiConfig.RarityType] then
              isCanInsert = false
            end
            local filterType = filterData[E.CommonFilterType.ResonanceSkillType]
            if filterType and next(filterType) and next(filterType.value) then
              local isInclude = false
              for i, type in ipairs(aoyiConfig.ShowSkillType) do
                if filterType.value[type] then
                  isInclude = true
                  break
                end
              end
              if not isInclude then
                isCanInsert = false
              end
            end
          end
        else
          isCanInsert = false
        end
      else
      end
    else
      isCanInsert = false
    end
    if isCanInsert then
      local data = {
        itemUuid = v.itemUuid,
        configId = v.configId,
        count = decomposeDict and decomposeDict[v.itemUuid] and decomposeDict[v.itemUuid].count or 0
      }
      table.insert(resultList, data)
    end
  end
  if sortType == E.ResonanceItemSortType.Quality then
    table.sort(resultList, function(a, b)
      local selectWightA = decomposeDict and decomposeDict[a.itemUuid] and 1 or 0
      local selectWightB = decomposeDict and decomposeDict[b.itemUuid] and 1 or 0
      if selectWightA == selectWightB then
        local configA = itemTableMgr.GetRow(a.configId)
        local configB = itemTableMgr.GetRow(b.configId)
        if configA and configB then
          if configA.Quality == configB.Quality then
            return a.configId < b.configId
          elseif isAscending then
            return configA.Quality > configB.Quality
          else
            return configA.Quality < configB.Quality
          end
        else
          return false
        end
      else
        return selectWightA > selectWightB
      end
    end)
  end
  return resultList
end
local ret = {
  OpenResonancePowerCreate = openResonancePowerCreate,
  OpenResonancePowerDecompose = openResonancePowerDecompose,
  CloseResonancePowerView = closeResonancePowerView,
  GetDecomposeGetAward = getDecomposeGetAward,
  ReqCreateResonancePower = reqCreateResonancePower,
  ReqDecomposeResonancePower = reqDecomposeResonancePower,
  OpenDecomposeAcquireView = openDecomposeAcquireView,
  CloseDecomposeAcquireView = closeDecomposeAcquireView,
  GetMaxCreateCount = getMaxCreateCount,
  GetCreateConsumeAward = getCreateConsumeAward,
  GetNotEnoughItemByCount = getNotEnoughItemByCount,
  CheckCanMake = checkCanMake,
  CheckHaveCoreMaterial = checkHaveCoreMaterial,
  GetResonanceMakeList = getResonanceMakeList,
  GetResonanceDecomposeList = getResonanceDecomposeList
}
return ret
