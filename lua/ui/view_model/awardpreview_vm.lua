local ret = {}
local DEPTH = 10

function ret.OpenRewardDetailViewByListData(awardList, title, dlgType)
  local showList = {}
  for _, item in pairs(awardList) do
    local itemData = {
      ItemId = item.awardId,
      ItemNum = item.awardNum,
      LabType = E.ItemLabType.Num
    }
    table.insert(showList, itemData)
  end
  local dialogTitle = title or "RewardPreview"
  local showDlgType = dlgType and dlgType or E.DlgType.OK
  Z.UIMgr:OpenView("dialog", {
    itemList = showList,
    labTitle = Lang(dialogTitle),
    dlgType = showDlgType
  })
end

function ret.OpenRewardDetailViewByItemList(itemList, title)
  local showList = {}
  for _, item in pairs(itemList) do
    local itemData = {
      ItemId = item.configId,
      ItemNum = item.count,
      LabType = E.ItemLabType.Num
    }
    table.insert(showList, itemData)
  end
  local dialogTitle = title or "RewardPreview"
  Z.UIMgr:OpenView("dialog", {
    itemList = showList,
    labTitle = Lang(dialogTitle),
    dlgType = E.DlgType.OK
  })
end

function ret.checkSexLimit(param)
  local charInfo = Z.ContainerMgr.CharSerialize.charBase
  if charInfo == nil then
    return false
  end
  if param == nil or param == nil or #param < 1 then
    logError("\230\178\161\230\156\137\233\133\141\231\189\174\230\128\167\229\136\171\233\153\144\229\136\182\231\154\132\229\143\130\230\149\176")
    return false
  end
  local sex = tonumber(param[1])
  return charInfo.gender == sex
end

ret.checkLimitFuncs = {
  [E.AwardPrevLimitType.Sex] = ret.checkSexLimit
}

function ret.checkValid(awardTableRow)
  if not awardTableRow or awardTableRow.PreviewUseLimite == 0 then
    return true
  end
  local limitParams = awardTableRow.Limit
  if not limitParams or #limitParams < 1 then
    return true
  end
  local r = Z.ConditionHelper.CheckCondition(limitParams)
  return r
end

function ret.parsePreviewItem(previewItems, awardTotalList, awardPreviewId, previewItemSortDic, isShowCount, awardPackageTableRow)
  local bConfigError = false
  local prevDropType = E.AwardPrevDropType.Definitely
  local packageGroupContent = awardPackageTableRow.PackContent
  for contentIndex, value in ipairs(packageGroupContent) do
    local awardTableID = value[1]
    local awardTableRow = Z.TableMgr.GetTable("AwardTableMgr").GetRow(awardTableID)
    if awardTableRow then
      if awardPackageTableRow.PackType == 1 then
        if awardPackageTableRow.RandomRule == 1 then
          if awardTableRow.RandomRule == 1 then
            prevDropType = E.AwardPrevDropType.Definitely
          else
            prevDropType = E.AwardPrevDropType.Probability
          end
        elseif awardPackageTableRow.RandomRule == 4 then
          local groupWeight = awardPackageTableRow.GroupWeight
          if groupWeight ~= nil and 1 < #groupWeight then
            prevDropType = E.AwardPrevDropType.Probability
          else
            prevDropType = E.AwardPrevDropType.Definitely
          end
        else
          local rateList = awardPackageTableRow.GroupRates
          if rateList and rateList[contentIndex] and 10000 <= rateList[contentIndex] and awardTableRow.RandomRule == 1 then
            prevDropType = E.AwardPrevDropType.Definitely
          else
            prevDropType = E.AwardPrevDropType.Probability
          end
        end
      elseif awardPackageTableRow.PackType == 2 then
        prevDropType = E.AwardPrevDropType.Multipe
      end
    end
    if prevDropType ~= E.AwardPrevDropType.Definitely then
      break
    end
  end
  for index, value in ipairs(previewItems) do
    local num = value[2] or 0
    local numExtend = value[3] or 0
    if not isShowCount then
      num = 0
      numExtend = 0
    end
    local awardData = {
      awardId = value[1],
      awardNum = num,
      awardNumExtend = numExtend,
      PrevDropType = prevDropType
    }
    if 0 > awardData.awardNum or 0 > awardData.awardNumExtend then
      bConfigError = true
    else
      table.insert(awardTotalList, awardData)
      if not previewItemSortDic[awardData.awardId] or index < previewItemSortDic[awardData.awardId] then
        previewItemSortDic[awardData.awardId] = index
      end
    end
  end
  if bConfigError and awardPreviewId ~= 0 then
    logError("[awardpreview_vm] \229\165\150\229\138\177\233\162\132\232\167\136\233\133\141\231\189\174\233\148\153\232\175\175, \232\175\183\230\163\128\230\159\165AwardPackageTable\231\154\132PreviewItem\229\173\151\230\174\181, Id = " .. awardPreviewId)
  end
end

function ret.parseGroupContentNew(awardTotalList, awardPackageTableRow, isShowCount)
  local packageGroupContent = awardPackageTableRow.PackContent
  for contentIndex, value in ipairs(packageGroupContent) do
    local awardTableID = value[1]
    local awardTableRow = Z.TableMgr.GetTable("AwardTableMgr").GetRow(awardTableID)
    if awardTableRow then
      local groupContentItems = awardTableRow.GroupContent
      local bindInfo_ = awardTableRow.BindInfo
      if groupContentItems == nil or #groupContentItems < 1 then
        break
      end
      if ret.checkValid(awardTableRow) then
        local num1 = value[2]
        local num2 = value[3]
        for index, value1 in ipairs(groupContentItems) do
          local id = value1[1]
          local itemNum1 = value1[2]
          local itemNum2 = value1[3]
          local num1_ = 0
          local num2_ = 0
          if isShowCount then
            if awardPackageTableRow.RandomRule == 1 then
              if awardTableRow.RandomRule == 1 then
                num1_ = num1 * itemNum1
                num2_ = num2 * itemNum2
              end
            elseif awardPackageTableRow.RandomRule == 3 then
              local groupWeight = awardTableRow.GroupWeight
              if groupWeight ~= nil and 1 < #groupWeight then
                num1_ = num1 * itemNum1
                num2_ = num2 * itemNum2
              end
            end
          end
          local prevDropType
          if awardPackageTableRow.PackType == 1 then
            if awardPackageTableRow.RandomRule == 1 then
              if awardTableRow.RandomRule == 1 then
                prevDropType = E.AwardPrevDropType.Definitely
              else
                prevDropType = E.AwardPrevDropType.Probability
              end
            elseif awardPackageTableRow.RandomRule == 4 then
              local groupWeight = awardPackageTableRow.GroupWeight
              if groupWeight ~= nil and 1 < #groupWeight then
                prevDropType = E.AwardPrevDropType.Probability
              else
                prevDropType = E.AwardPrevDropType.Definitely
              end
            else
              local rateList = awardPackageTableRow.GroupRates
              if rateList and rateList[contentIndex] and 10000 <= rateList[contentIndex] and awardTableRow.RandomRule == 1 then
                prevDropType = E.AwardPrevDropType.Definitely
              else
                prevDropType = E.AwardPrevDropType.Probability
              end
            end
          elseif awardPackageTableRow.PackType == 2 then
            prevDropType = E.AwardPrevDropType.Multipe
          end
          table.insert(awardTotalList, {
            awardId = id,
            awardNum = num1_,
            awardNumExtend = num2_,
            BindInfo = bindInfo_,
            Index = index,
            PrevDropType = prevDropType
          })
        end
      end
    end
  end
end

function ret.getAwardList(awardTotalList, list)
  local isShowPreviewItem = false
  local isShowCount = true
  for _, awardId in ipairs(awardTotalList) do
    local awardPackageTableRow = Z.TableMgr.GetTable("AwardPackageTableMgr").GetRow(awardId)
    if awardPackageTableRow then
      if awardPackageTableRow.PreviewItem and #awardPackageTableRow.PreviewItem > 0 then
        isShowPreviewItem = true
      end
      if awardPackageTableRow.PreNumDetail == 1 then
        isShowCount = false
      end
      list[#list + 1] = awardPackageTableRow
    end
  end
  if not isShowPreviewItem then
    return isShowCount, isShowPreviewItem
  end
  for i = #list, 1, -1 do
    if #list[i].PreviewItem == 0 then
      table.remove(list, i)
    end
  end
  return isShowCount, isShowPreviewItem
end

function ret.getPreItems(awardTotalList, awardPackageTableRow, previewItemSortDic, isShowCount)
  local previewItems = awardPackageTableRow.PreviewItem
  local levelUpAwardId = 0
  if not previewItems or not (0 < #previewItems) then
    levelUpAwardId = ret.checkAwardLevelUp(awardPackageTableRow.PackID)
    if levelUpAwardId ~= awardPackageTableRow.PackID then
      logGreen("\229\165\150\229\138\177\229\140\133\229\141\135\231\186\167: {0} => {0}", awardPackageTableRow.PackID, levelUpAwardId)
      local awardTableRow = Z.TableMgr.GetTable("AwardTableMgr").GetRow(levelUpAwardId)
      if not awardTableRow then
        return
      end
    end
  end
  if previewItems and 0 < #previewItems then
    ret.parsePreviewItem(previewItems, awardTotalList, levelUpAwardId, previewItemSortDic, isShowCount, awardPackageTableRow)
  else
    ret.parseGroupContentNew(awardTotalList, awardPackageTableRow, isShowCount)
  end
end

function ret.mergeAwardItems(awardItemList)
  local temp = {}
  if awardItemList ~= nil or 0 < #awardItemList then
    for index, value in ipairs(awardItemList) do
      local tempItem = temp[value.awardId]
      if tempItem == nil then
        temp[value.awardId] = value
      elseif value.PrevDropType == E.AwardPrevDropType.Definitely and tempItem.PrevDropType == E.AwardPrevDropType.Probability or value.PrevDropType == E.AwardPrevDropType.Probability and tempItem.PrevDropType == E.AwardPrevDropType.Definitely then
        tempItem.awardNum = 0
        tempItem.awardNumExtend = 0
        tempItem.PrevDropType = E.AwardPrevDropType.Definitely
      else
        tempItem.awardNum = tempItem.awardNum + value.awardNum
        tempItem.awardNumExtend = tempItem.awardNumExtend + value.awardNumExtend
      end
    end
  end
  local list = {}
  for _, value in pairs(temp) do
    table.insert(list, value)
  end
  return list
end

function ret.splitAwardItemsByProbability(list)
  if list == nil or #list < 1 then
    return {}, {}
  end
  local definitely = {}
  local probability = {}
  for _, value in ipairs(list) do
    if value.PrevDropType == E.AwardPrevDropType.Definitely then
      table.insert(definitely, value)
    else
      table.insert(probability, value)
    end
  end
  return definitely, probability
end

function ret.getAwardIds(awardIdOrIds)
  if awardIdOrIds == nil then
    return {}
  end
  local awardIds = {}
  if type(awardIdOrIds) == "number" then
    table.insert(awardIds, awardIdOrIds)
    return awardIds
  elseif type(awardIdOrIds) == "table" then
    return awardIdOrIds
  else
    return {}
  end
end

function ret.GetAllAwardPreListByIds(awardIdOrIds)
  local awardIds = ret.getAwardIds(awardIdOrIds)
  local previewItemSortDic = {}
  local list = {}
  local isShowCount, isShowPreviewItem = ret.getAwardList(awardIds, list)
  local itemList = {}
  for _, awardPackageTableRow in ipairs(list) do
    ret.getPreItems(itemList, awardPackageTableRow, previewItemSortDic, isShowCount)
  end
  if not isShowPreviewItem then
    itemList = ret.mergeAwardItems(itemList)
  end
  if next(previewItemSortDic) ~= nil then
    table.sort(itemList, function(a, b)
      return previewItemSortDic[a.awardId] < previewItemSortDic[b.awardId]
    end)
  else
    local itemSortFactoryVm = Z.VMMgr.GetVM("item_sort_factory")
    table.sort(itemList, itemSortFactoryVm.DefaultPreviewAwardSort)
  end
  return itemList
end

function ret.GetGroupAwardPrevByProbability(awardIdOrIds)
  local list = ret.GetAllAwardPreListByIds(awardIdOrIds)
  local definitelyTemp = {}
  local probabilityTemp = {}
  definitelyTemp, probabilityTemp = ret.splitAwardItemsByProbability(list)
  return definitelyTemp, probabilityTemp
end

function ret.GetPreviewShowNum(awardData)
  local labType, lab
  if awardData.awardNum == awardData.awardNumExtend then
    labType = E.ItemLabType.Num
    lab = awardData.awardNum
  else
    labType = E.ItemLabType.Str
    lab = awardData.awardNum .. "~" .. awardData.awardNumExtend
  end
  return labType, lab
end

function ret.checkAwardLevelUp(awardPackageId)
  local checkedMap = {}
  return ret.doCheckAwardLevelUp(awardPackageId, checkedMap)
end

function ret.doCheckAwardLevelUp(awardId, checkedMap)
  checkedMap[awardId] = true
  local level = 0
  local awardTableRow = Z.TableMgr.GetTable("AwardPackageTableMgr").GetRow(awardId)
  local cond = awardTableRow.LevelUpConditions
  if cond == 0 then
    return awardId
  elseif math.floor(cond / 100) == Z.ConstValue.AwardLevelUpCondition.Count then
    local count = 1
    local time = 0
    local data = ret.getAwardData(awardId)
    if data then
      count = data.dropTimes + 1
      time = data.lastDropTime
    end
    if ret.islevelUpAwardCountReSet(cond, time) then
      count = 1
      return awardId
    end
    level = ret.getAwardLevelByCount(count, awardTableRow)
  elseif cond == Z.ConstValue.AwardLevelUpCondition.SeasonDay then
    local seasonVM = Z.VMMgr.GetVM("season")
    local serverTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
    local seasonId, day = seasonVM.GetSeasonByTime(serverTime)
    if seasonId and day then
      level = ret.getAwardLevelByCount(day, awardTableRow)
    end
  end
  if level == 0 then
    return awardId
  end
  local levelUpAwards = awardTableRow.LevelUpPackage
  if levelUpAwards and level <= #levelUpAwards then
    local levelUpAwardId = levelUpAwards[level]
    if table.zcontains(checkedMap, levelUpAwardId) then
      logError("\233\133\141\231\189\174\233\148\153\232\175\175, \229\165\150\229\138\177\229\190\170\231\142\175\229\141\135\231\186\167, awardId = {0}", awardId)
      return awardId
    end
    return ret.doCheckAwardLevelUp(levelUpAwardId, checkedMap)
  end
  return awardId
end

function ret.getAwardLevelByCount(count, awardTableRow)
  local levelUpGroupCfgs = awardTableRow.LevelUpConfig
  if levelUpGroupCfgs and 0 < #levelUpGroupCfgs then
    local level = 0
    for index, groupCfg in ipairs(levelUpGroupCfgs) do
      local levelUpCfgs = groupCfg
      if levelUpCfgs and #levelUpCfgs == 2 and count >= levelUpCfgs[1] and (count <= levelUpCfgs[2] or levelUpCfgs[2] == 0) then
        level = index
        return level
      end
    end
  end
  return 0
end

function ret.islevelUpAwardCountReSet(condition, lastTime)
  if lastTime == 0 then
    return false
  end
  local serverTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  if condition == Z.ConstValue.AwardLevelUpCondition.CountSeason then
    local seasonVM = Z.VMMgr.GetVM("season")
    local lastSeason, _ = seasonVM.GetSeasonByTime(lastTime)
    local curSeason, _ = seasonVM.GetSeasonByTime(serverTime)
    return lastSeason < curSeason
  elseif condition == Z.ConstValue.AwardLevelUpCondition.CountDay then
    local lastTimeDate = Z.TimeTools.GetDailyCycleTimeDataByTime(lastTime)
    local curTimeDate = Z.TimeTools.GetDailyCycleTimeDataByTime(serverTime)
    if lastTimeDate ~= nil and curTimeDate ~= nil and lastTimeDate.year == curTimeDate.year and lastTimeDate.yday == curTimeDate.yday then
      return false
    end
    return true
  else
    return false
  end
end

function ret.getAwardData(awardId)
  local dataDic = Z.ContainerMgr.CharSerialize.syncAwardData.levelUpAwardInfos
  if dataDic and dataDic[awardId] ~= nil then
    local data = dataDic[awardId]
    return data
  end
  return nil
end

function ret.CheckAwardTypeIsSelect(awardPackageID)
  local result_ = false
  local packageRow = Z.TableMgr.GetTable("AwardPackageTableMgr").GetRow(awardPackageID)
  if packageRow ~= nil then
    result_ = packageRow.PackType == Z.PbEnum("EAwardType", "EAwardTypeSelect")
  end
  return result_
end

function ret.GetAwardType(awardPackageID)
  local packageRow = Z.TableMgr.GetTable("AwardPackageTableMgr").GetRow(awardPackageID)
  if packageRow then
    return packageRow.PackType
  end
end

return ret
