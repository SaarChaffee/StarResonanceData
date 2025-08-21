local ConditionHelper = {}
E.ConditionType = {
  Level = 1,
  TaskOver = 2,
  UseTalentPoints = 3,
  GS = 4,
  Item = 5,
  DungeonId = 6,
  DungeonScroe = 7,
  TimerRunning = 8,
  TimeInterval = 9,
  Function = 14,
  SkillLevel = 17,
  BpLevel = 24,
  SeasonTitleLevel = 25,
  SeasonTimeRange = 26,
  SeasonTimeOffset = 27,
  TaskStepOver = 28,
  AfterTime = 29,
  UnionBuildLv = 30,
  UnionLevel = 35,
  UnionMoney = 36,
  AllTalentPoints = 38,
  Sex = 42,
  ProfessionId = 43,
  OpenServerDay = 45,
  InRecommendData = 53,
  FishingLevel = 54,
  LifeProfessionLevel = 58,
  LifeProfessionSpecializationLevel = 59,
  RecipeIsUnlock = 60,
  LifeProVitality = 63,
  CollectionScoreLevel = 64,
  HasHome = 67,
  HomeLevel = 72,
  HomeCleanliness = 73,
  NotInShapeShift = 75,
  SDKPlatform = 76,
  UnlockLifeProduction = 89
}
local SexLimitName = {
  [1] = "GenderMale",
  [2] = "GenderFemale"
}
local condFuncDic

function ConditionHelper.getCondFunc(condType)
  if condFuncDic == nil then
    condFuncDic = {}
    for _, type in pairs(E.ConditionType) do
      local condFunc = ConditionHelper["checkConditionType_" .. type]
      if condFunc then
        condFuncDic[type] = condFunc
      end
    end
  end
  return condFuncDic[condType]
end

function ConditionHelper.CheckCondition(condTbl, bShowTip, extraParams)
  if condTbl == nil or condTbl == nil or #condTbl == 0 then
    return true
  end
  for i, v in ipairs(condTbl) do
    local params = {}
    local condType = v[1]
    if v[2] then
      table.insert(params, v[2])
    end
    if v[3] then
      table.insert(params, v[3])
    end
    if extraParams then
      table.insert(params, extraParams)
    end
    if not ConditionHelper.CheckSingleCondition(condType, bShowTip, table.unpack(params)) then
      return false
    end
  end
  return true
end

function ConditionHelper.CheckSingleCondition(condType, bShowTip, ...)
  local condFunc = ConditionHelper.getCondFunc(condType)
  if condFunc then
    local bResult, tipsId, tipsParam = condFunc(...)
    if not bResult then
      if bShowTip and tipsId then
        Z.TipsVM.ShowTipsLang(tipsId, tipsParam)
      end
      return false
    end
  end
  return true
end

function ConditionHelper.GetConditionDescList(condTbl, extraParams)
  local descList = {}
  if condTbl == nil or condTbl == nil or #condTbl == 0 then
    return descList
  end
  for i, v in ipairs(condTbl) do
    local params = {}
    local condType = v[1]
    if v[2] then
      table.insert(params, v[2])
    end
    if v[3] then
      table.insert(params, v[3])
    end
    if extraParams then
      table.insert(params, extraParams)
    end
    local bResult, unlockDesc, progress, tipsId, tipsParam, showPurview, showLock = ConditionHelper.GetSingleConditionDesc(condType, table.unpack(params))
    if unlockDesc ~= "" then
      table.insert(descList, {
        Desc = unlockDesc,
        Progress = progress,
        IsUnlock = bResult,
        tipsId = tipsId,
        tipsParam = tipsParam,
        showPurview = showPurview,
        showLock = showLock
      })
    end
  end
  return descList
end

function ConditionHelper.GetSingleConditionDesc(condType, ...)
  local condFunc = ConditionHelper.getCondFunc(condType)
  if condFunc then
    local bResult, tipsId, tipsParam, progress, showPurview, showLock = condFunc(...)
    return bResult, tipsId == 0 and "" or Z.TipsVM.GetMessageContent(tipsId, tipsParam), progress, tipsId, tipsParam, showPurview, showLock
  end
  return false, "", "", 0, "", ""
end

function ConditionHelper.checkConditionType_1(condValue, maxlevel)
  local curLevel = Z.ContainerMgr.CharSerialize.roleLevel.level or 0
  local bResult
  if maxlevel then
    bResult = condValue <= curLevel and maxlevel >= curLevel
  else
    bResult = condValue <= curLevel
  end
  local tipsId = 1500001
  local tipsParam = {val = condValue}
  local progress = curLevel .. "/" .. condValue
  return bResult, tipsId, tipsParam, progress
end

function ConditionHelper.checkConditionType_2(condValue)
  local questVm = Z.VMMgr.GetVM("quest")
  local questTableRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(condValue)
  local bResult = questVm.IsQuestFinish(condValue)
  local tipsId = 1500003
  local tipsParam = {
    val = questTableRow.QuestName
  }
  local progress = (bResult and 0 or 1) .. "/" .. 1
  return bResult, tipsId, tipsParam, progress
end

function ConditionHelper.checkConditionType_3(condValue, weaponId)
  local talentVM = Z.VMMgr.GetVM("talent_skill")
  local usedPoints = talentVM.GetCurWeaponUseTalentPoint(weaponId)
  local bResult = condValue <= usedPoints
  local tipsId = 1500002
  local tipsParam = {val = condValue}
  local progress = usedPoints .. "/" .. condValue
  return bResult, tipsId, tipsParam, progress
end

function ConditionHelper.checkConditionType_4(condValue)
  local totalGs = 0
  local bResult = condValue <= totalGs
  local tipsId = 130038
  local tipsParam = {
    dungeon = {gs = condValue}
  }
  return bResult, tipsId, tipsParam
end

function ConditionHelper.checkConditionType_5(itemId, itemCount)
  local itemsVm = Z.VMMgr.GetVM("items")
  local totalGs = itemsVm.GetItemTotalCount(itemId)
  local bResult = itemCount <= totalGs
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
  local tipsId = 100010
  local tipsParam = {
    item = {
      name = itemRow.Name
    },
    str = totalGs .. "/" .. itemCount
  }
  local progress = totalGs .. "/" .. itemCount
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.Item)
  local showPurview = ""
  if conditionRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      val = itemRow.Name
    })
  end
  return bResult, tipsId, tipsParam, progress, showPurview, true
end

function ConditionHelper.checkConditionType_9(timeId)
  local tipsId = 1004101
  local tipsParam = {val = 0}
  local result = false
  local progress = 0
  if timeId == nil then
    logError("[ConditionHelper.checkConditionType_9] timeId is nil")
    return false, tipsId, tipsParam, 0
  end
  local startTime, endTime, _ = Z.TimeTools.GetWholeStartEndTimeByTimerId(timeId)
  if startTime and 0 < startTime then
    local now = Z.TimeTools.Now() / 1000
    if startTime <= now and (endTime == nil or endTime == 0 or endTime >= now) then
      result = true
      progress = endTime and endTime - now or 1
      if 0 < progress then
        tipsParam = {
          val = Z.TimeFormatTools.FormatToDHMS(progress)
        }
      else
        tipsId = 1500013
      end
    elseif startTime > now then
      result = false
      progress = Z.TimeTools.DiffTime(startTime, now)
      if 0 < progress then
        tipsParam = {
          val = Z.TimeFormatTools.FormatToDHMS(progress)
        }
      else
        tipsId = 1500013
      end
    end
  end
  return result, tipsId, tipsParam, progress
end

function ConditionHelper.checkConditionType_14(functionId)
  local switchVm = Z.VMMgr.GetVM("switch")
  local bResult, reason = switchVm.CheckFuncSwitch(functionId)
  local tipsId = 0
  local tipsParam = ""
  if reason and reason[1] then
    tipsId = reason[1].error
    tipsParam = reason[1].params
  end
  local progress = ""
  return bResult, tipsId, tipsParam, progress
end

function ConditionHelper.checkConditionType_17(skillId, skillLevel)
  local weaponData = Z.DataMgr.Get("weapon_data")
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local curSkillLv = weaponData:GetWeaponSkillData(weaponSkillVm:GetOriginSkillId(skillId))
  local bResult = skillLevel <= curSkillLv
  local tipsId = 1500005
  local skillConfig = Z.TableMgr.GetTable("SkillTableMgr").GetRow(skillId)
  local tipsParam = {
    val = skillLevel,
    str = skillConfig.Name
  }
  local progress = curSkillLv .. "/" .. skillLevel
  return bResult, tipsId, tipsParam, progress
end

function ConditionHelper.checkConditionType_24(bpLevel)
  local battlePassVM = Z.VMMgr.GetVM("battlepass")
  local curBattleCardData = battlePassVM.GetCurrentBattlePassContainer()
  local curBpLevel = curBattleCardData == nil and 0 or curBattleCardData.level
  local bResult = bpLevel <= curBpLevel
  local tipsId = 124007
  local progress = curBpLevel .. "/" .. bpLevel
  return bResult, tipsId, {val = bpLevel}, progress
end

function ConditionHelper.checkConditionType_25(seasonTitleLevel)
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local seasonRankConfig = seasonRankTableMgr.GetRow(seasonTitleLevel)
  local tipVal_ = ""
  if seasonRankConfig ~= nil then
    tipVal_ = seasonRankConfig.Name
  end
  local seasonInfo = seasonTitleData:GetCurRankInfo()
  local curSeasonId_ = seasonInfo.curRanKStar
  local bResult = seasonTitleLevel <= curSeasonId_
  local tipsId = 124011
  local progress = 0 .. "/" .. 1
  if bResult then
    progress = 1 .. "/" .. 1
  end
  return bResult, tipsId, {val = tipVal_}, progress
end

function ConditionHelper.checkConditionType_26(seasonId, startOffset, endOffset)
  local seasonVm = Z.VMMgr.GetVM("season")
  local seasonStartTime, seasonEndTime = seasonVm.GetSeasonStartEndTime(seasonId)
  if seasonStartTime and seasonEndTime then
    local _, totalSec = Z.TimeTools.TimerTabaleOffsetParse(startOffset)
    local startTime = totalSec + seasonStartTime
    _, totalSec = Z.TimeTools.TimerTabaleOffsetParse(endOffset)
    local endTime = totalSec + seasonStartTime
    local now = Z.TimeTools.Now() / 1000
    if startTime <= now and endTime >= now then
      return true
    end
    return false
  end
  return false
end

function ConditionHelper.checkConditionType_27(seasonId, offsetTime)
  local tipsId = 1004101
  local tipsVal = ""
  local result = false
  local progress = 0
  local seasonVm = Z.VMMgr.GetVM("season")
  local seasonStartTime, seasonEndTime = seasonVm.GetSeasonStartEndTime(seasonId)
  if seasonStartTime and seasonEndTime then
    local _, totalSec = Z.TimeTools.TimerTabaleOffsetParse(offsetTime)
    local startTime = totalSec + seasonStartTime
    local now = Z.TimeTools.Now() / 1000
    if startTime <= now and seasonEndTime >= now then
      result = true
      progress = seasonEndTime - now
      tipsVal = Z.TimeFormatTools.FormatToDHMS(progress)
    elseif startTime > now then
      result = false
      progress = Z.TimeTools.DiffTime(startTime, now)
      tipsVal = Z.TimeFormatTools.FormatToDHMS(progress)
    end
  end
  return result, tipsId, {val = tipsVal}, progress
end

function ConditionHelper.checkConditionType_28(questId, questStepId)
  local tipsId = 124004
  local tipsParam = {}
  tipsParam.groupName = ""
  tipsParam.questName = ""
  if not questId or not questStepId then
    return true, tipsId, tipsParam, "1/1"
  end
  local questTable = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questTable then
    local questTypeTable = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(questTable.QuestType)
    if questTypeTable then
      local questTypeGroupTable = Z.TableMgr.GetTable("QuestTypeGroupTableMgr").GetRow(questTypeTable.QuestTypeGroupID)
      if questTypeGroupTable then
        tipsParam.groupName = questTypeGroupTable.GroupName
        tipsParam.questName = questTable.QuestName
      end
    end
  end
  local questVm = Z.VMMgr.GetVM("quest")
  if questVm.IsQuestStepFinish(questId, questStepId) then
    return true, tipsId, tipsParam, "1/1"
  else
    return false, tipsId, tipsParam, "0/1"
  end
end

function ConditionHelper.checkConditionType_29(timeString)
  local tipsId = 124001
  local tipsParam = {}
  tipsParam.longstring = timeString
  if not timeString or timeString == "" then
    return true, tipsId, tipsParam, "1/1"
  end
  local startTime = Z.TimeTools.TimeString2Stamp(timeString)
  local serverTime = Z.ServerTime:GetServerTime()
  if startTime <= serverTime then
    return true, tipsId, tipsParam, "1/1"
  else
    return false, tipsId, {date = tipsParam}, "0/1"
  end
end

function ConditionHelper.checkConditionType_30(buildId, condLv)
  local unionVM = Z.VMMgr.GetVM("union")
  local curBuildLv = unionVM:GetUnionBuildLv(buildId)
  local bResult = condLv <= curBuildLv
  local config = unionVM:GetUnionBuildConfig(buildId)
  local tipsId = 1500006
  local tipsParam = {
    name = config.BuildingName,
    level = condLv
  }
  local progress = curBuildLv .. "/" .. condLv
  local showPurview = ""
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.UnionBuildLv)
  if conditionRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      val1 = config.BuildingName,
      val2 = condLv
    })
  end
  return bResult, tipsId, tipsParam, progress, showPurview
end

function ConditionHelper.checkConditionType_35(level)
  local unionVM_ = Z.VMMgr.GetVM("union")
  local buildId_ = E.UnionBuildId.BaseBuild
  local unionLevel_ = unionVM_:GetUnionBuildLv(buildId_)
  local tipsId = 124021
  local tipsParam = {}
  tipsParam.val = level
  return level <= unionLevel_, tipsId, tipsParam
end

function ConditionHelper.checkConditionType_36(money)
  local unionVM_ = Z.VMMgr.GetVM("union")
  local resourceId_ = E.UnionResourceId.Gold
  local unionMoney_ = unionVM_:GetUnionResourceCount(resourceId_)
  local tipsId = 124022
  local tipsParam = {}
  tipsParam.val = money
  return money <= unionMoney_, tipsId, tipsParam
end

function ConditionHelper.checkConditionType_38(condValue)
  local talentVM = Z.VMMgr.GetVM("talent_skill")
  local curHaveTalentPoints = talentVM.GetAllTalentPointCount()
  local bResult = condValue <= curHaveTalentPoints
  local tipsId = 1500007
  local tipsParam = {val = condValue}
  local progress = curHaveTalentPoints .. "/" .. condValue
  return bResult, tipsId, tipsParam, progress
end

function ConditionHelper.checkConditionType_42(condValue)
  local charInfo = Z.ContainerMgr.CharSerialize.charBase
  if charInfo == nil then
    return false
  end
  local sex = condValue
  local bResult = charInfo.gender == sex
  local tipsId = 1500007
  local showPurview = ""
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.ProfessionId)
  if conditionRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      name = Lang(SexLimitName[sex])
    })
  end
  return bResult, tipsId, nil, nil, showPurview, true
end

function ConditionHelper.checkConditionType_43(profession)
  local professionVm = Z.VMMgr.GetVM("profession")
  local professionId = professionVm:GetContainerProfession()
  local bResult = professionId == profession
  local tipsId = 1600002
  local showPurview = ""
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(profession)
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.ProfessionId)
  if conditionRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      name = professionRow.Name
    })
  end
  return bResult, tipsId, {
    val = professionRow.Name
  }, nil, showPurview, true
end

function ConditionHelper.checkConditionType_45(condValue)
  local daySec = 86400
  local bResult = false
  local timeTableId = Z.Global.ServiceOpenTime
  local isExceed, subTime = Z.TimeTools.GetCurTimeIsExceed(timeTableId)
  local day = 0
  local timeStr = ""
  local formatTime = function(second)
    if 86400 <= second then
      local day = math.floor(second / 86400)
      local hour = math.floor((second - day * 86400) / 3600)
      timeStr = Lang("DayAndHour", {
        item = {day = day, hour = hour}
      })
    else
      local hour = math.ceil(second / 3600)
      timeStr = Lang("Hour", {val = hour})
    end
    return timeStr
  end
  if isExceed then
    bResult = 0 > subTime + condValue * 24 * 60 * 60
    if not bResult then
      day = math.ceil((subTime + condValue * daySec) / daySec)
      timeStr = formatTime(subTime + condValue * daySec)
    end
  else
    bResult = false
    day = math.ceil((subTime + condValue * daySec) / daySec)
    timeStr = formatTime(subTime + condValue * daySec)
  end
  local tipsId = 124024
  local tipsParam = {val = timeStr}
  local progress = day
  local showPurview = ""
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.OpenServerDay)
  if conditionRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      val = condValue + 1
    })
  end
  return bResult, tipsId, tipsParam, progress, showPurview
end

function ConditionHelper.checkConditionType_53(recommendId)
  local tipsId = 16010000
  local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(recommendId)
  if config == nil then
    return false, tipsId
  end
  if config.FunctionId ~= nil and config.FunctionId ~= 0 and not Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(config.FunctionId) then
    return false, tipsId
  end
  local serverTimeData = Z.DataMgr.Get("recommendedplay_data"):GetServerData(recommendId)
  if serverTimeData ~= nil and (Z.TimeTools.Now() / 1000 < serverTimeData.startTimestamp or Z.TimeTools.Now() / 1000 > serverTimeData.endTimestamp) then
    return false, tipsId
  end
  return true, tipsId
end

function ConditionHelper.checkConditionType_54(condValue)
  local fishingData = Z.DataMgr.Get("fishing_data")
  local curLevel = fishingData:GetFishingLevelByExp()
  local bResult = condValue <= curLevel
  local tipsId = 1500008
  local tipsParam = {val = condValue}
  local progress = curLevel .. "/" .. condValue
  local showPurview = ""
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.FishingLevel)
  if conditionRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {val = condValue})
  end
  return bResult, tipsId, tipsParam, progress, showPurview
end

function ConditionHelper.checkConditionType_58(proID, level)
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  local curLevel = lifeProfessionVM.GetLifeProfessionLv(proID)
  local bResult = level <= curLevel
  local progress = curLevel .. "/" .. level
  local showPurview = ""
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.LifeProfessionLevel)
  local lifeProfessionTableRow = Z.TableMgr.GetTable("LifeProfessionTableMgr").GetRow(proID)
  if not lifeProfessionTableRow then
    return false
  end
  local tipsParam = {
    name = lifeProfessionTableRow.Name,
    level = level
  }
  if conditionRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      val1 = lifeProfessionTableRow.Name,
      val2 = level
    })
  end
  return bResult, 1500010, tipsParam, progress, showPurview
end

function ConditionHelper.checkConditionType_59(specialGroupID, level)
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  local lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  local lifeFormulaTableRow = lifeProfessionData_:GetSpecializationRow(specialGroupID, level)
  if not lifeFormulaTableRow then
    return false, 0
  end
  local curLevel = lifeProfessionVM.GetSpecializationLv(lifeFormulaTableRow.ProId, lifeFormulaTableRow.Id)
  local bResult = level <= curLevel
  local tipsParam = {
    name = lifeFormulaTableRow.Name
  }
  local progress = (bResult and curLevel or Z.RichTextHelper.ApplyColorTag(curLevel, "#ff6300")) .. "/" .. level
  local showPurview = ""
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.LifeProfessionSpecializationLevel)
  local tipsID = 1500012
  if conditionRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      val = lifeFormulaTableRow.Name
    })
  end
  return bResult, tipsID, tipsParam, progress, showPurview
end

function ConditionHelper.checkConditionType_60(proID)
  local bResult = Z.ContainerMgr.CharSerialize.lifeProfession.lifeProfessionRecipe[proID] ~= nil
  local tipsParam = {}
  local progress = ""
  local showPurview = ""
  local tipsID = 1002009
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.RecipeIsUnlock)
  if conditionRow then
    showPurview = conditionRow.ShowPurview
    progress = conditionRow.ShowPurview
  end
  return bResult, tipsID, tipsParam, progress, showPurview
end

function ConditionHelper.checkConditionType_63(needCount)
  local itemsVm = Z.VMMgr.GetVM("items")
  local curHave = itemsVm.GetItemTotalCount(Z.SystemItem.VigourItemId)
  local bResult = needCount <= curHave
  local tipsParam = {val = needCount}
  local progress = (bResult and curHave or Z.RichTextHelper.ApplyColorTag(curHave, "#ff6300")) .. "/" .. needCount
  local showPurview = ""
  local tipsID = 1001907
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.LifeProVitality)
  if conditionRow then
    showPurview = conditionRow.ShowPurview
  end
  return bResult, tipsID, tipsParam, progress, showPurview
end

function ConditionHelper.checkConditionType_64(level)
  local bResult = level <= Z.ContainerMgr.CharSerialize.fashionBenefit.level
  local tipsParam = {}
  local progress = ""
  local showPurview = ""
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.CollectionScoreLevel)
  local tipsID = 120022
  local fashionLevelRow = Z.TableMgr.GetTable("FashionLevelTableMgr").GetRow(level, true)
  if conditionRow and fashionLevelRow then
    showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      val = fashionLevelRow.Name
    })
    progress = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
      val = fashionLevelRow.Name
    })
  end
  return bResult, tipsID, tipsParam, progress, showPurview, true
end

function ConditionHelper.checkConditionType_67()
  local bResult = Z.ContainerMgr.CharSerialize.communityHomeInfo.homelandId == 0
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.HasHome)
  local tipsID = conditionRow.FailureMessage
  local showPurview = conditionRow.ShowPurview
  return bResult, tipsID, {}, "", showPurview
end

function ConditionHelper.checkConditionType_72(homeLevel)
  local houseData = Z.DataMgr.Get("house_data")
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.HomeLevel)
  local tipsID = conditionRow.FailureMessage
  local showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {val = homeLevel})
  local tipsParam = {val = homeLevel}
  local bResult = homeLevel <= houseData:GetHouseLevel()
  return bResult, tipsID, tipsParam, "", showPurview, true
end

function ConditionHelper.checkConditionType_73(cleanliness)
  local houseData = Z.DataMgr.Get("house_data")
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.HomeCleanliness)
  local tipsID = conditionRow.FailureMessage
  local showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {val = cleanliness})
  local tipsParam = {val = cleanliness}
  local bResult = cleanliness <= houseData:GetHouseCleanValue()
  return bResult, tipsID, tipsParam, "", showPurview, true
end

function ConditionHelper.checkConditionType_75()
  local player = Z.EntityMgr.PlayerEnt
  if not player then
    return false
  end
  local tipsId = 0
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.NotInShapeShift)
  if conditionRow then
    tipsId = conditionRow.FailureMessage
  end
  local bResult = not player.LuaGetIsInShapeShift()
  return bResult, tipsId, nil, nil
end

function ConditionHelper.checkConditionType_76(launchPlatform)
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.SDKPlatform)
  local tipsID = conditionRow.FailureMessage
  local showPurview = conditionRow.ShowPurview
  local bResult = Z.VMMgr.GetVM("sdk").CheckLaunchPlatformCanShow(launchPlatform)
  return bResult, tipsID, "", "", showPurview
end

function ConditionHelper.checkConditionType_89(lifeProductionId)
  local lifeProductionListTableRow = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetRow(lifeProductionId)
  local bResult = false
  local tipsParam = {
    val = lifeProductionListTableRow.Name
  }
  local progress = ""
  if lifeProductionListTableRow then
    bResult = ConditionHelper.CheckCondition(lifeProductionListTableRow.UnlockCondition)
  end
  local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.UnlockLifeProduction)
  local showPurview = conditionRow.ShowPurview
  local tipsID = conditionRow.FailureMessage
  return bResult, tipsID, tipsParam, progress, showPurview
end

return ConditionHelper
