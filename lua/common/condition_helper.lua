local ConditionHelper = {}
E.ConditionType = {
  Level = 1,
  TaskOver = 2,
  UseTalentPoints = 3,
  GS = 4,
  Item = 5,
  DungeonId = 6,
  DungeonScroe = 7,
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
  OpenServerDay = 45,
  FishingLevel = 54
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
    local bResult, unlockDesc, progress, tipsId, tipsParam, showPurview = ConditionHelper.GetSingleConditionDesc(condType, table.unpack(params))
    if unlockDesc ~= "" then
      table.insert(descList, {
        Desc = unlockDesc,
        Progress = progress,
        IsUnlock = bResult,
        tipsId = tipsId,
        tipsParam = tipsParam,
        showPurview = showPurview
      })
    end
  end
  return descList
end

function ConditionHelper.GetSingleConditionDesc(condType, ...)
  local condFunc = ConditionHelper.getCondFunc(condType)
  if condFunc then
    local bResult, tipsId, tipsParam, progress, showPurview = condFunc(...)
    return bResult, Z.TipsVM.GetMessageContent(tipsId, tipsParam), progress, tipsId, tipsParam, showPurview
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
  return bResult, tipsId, tipsParam, progress
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
  local curSkillLv = weaponData:GetWeaponSkillData(skillId)
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
  local curBpLevel = Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.level
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
      tipsVal = Z.TimeTools.FormatToDHM(progress)
    elseif startTime > now then
      result = false
      progress = Z.TimeTools.DiffTime(startTime, now)
      tipsVal = Z.TimeTools.FormatToDHM(progress)
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
  local startTime = Z.TimeTools.Format2Tp(timeString)
  local serverTime = Z.ServerTime:GetServerTime()
  if startTime <= serverTime then
    return true, tipsId, tipsParam, "1/1"
  else
    return false, tipsId, {date = tipsParam}, "0/1"
  end
end

function ConditionHelper.checkConditionType_30(buildId, condLv, isShowPurview)
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
  if isShowPurview then
    local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.UnionBuildLv)
    if conditionRow then
      showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {
        val1 = config.BuildingName,
        val2 = condLv
      })
    end
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
  return bResult
end

function ConditionHelper.checkConditionType_45(condValue, isShowPurview)
  local daySec = 86400
  local bResult = false
  local timeTableId = Z.Global.ServiceOpenTime
  local isExceed, subTime = Z.TimeTools.GetCurTimeIsExceed(timeTableId)
  local day = 0
  if isExceed then
    bResult = 0 > subTime + condValue * 24 * 60 * 60
    if not bResult then
      day = math.ceil((subTime + condValue * daySec) / daySec)
    end
  else
    bResult = false
    day = math.ceil((subTime + condValue * daySec) / daySec)
  end
  local tipsId = 124024
  local tipsParam = {val = condValue}
  local progress = day
  local showPurview = ""
  if isShowPurview then
    local conditionRow = Z.TableMgr.GetTable("ConditionTableMgr").GetRow(E.ConditionType.OpenServerDay)
    if conditionRow then
      showPurview = Z.Placeholder.Placeholder(conditionRow.ShowPurview, {val = condValue})
    end
  end
  return bResult, tipsId, tipsParam, progress, showPurview
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

function ConditionHelper.checkConditionType_9(timeId)
  local tipsId = 1004101
  local tipsVal = ""
  local result = false
  local progress = 0
  local startTime, endTime, offsetTime
  local timeCfg = Z.TableMgr.GetTable("TimerTableMgr").GetRow(timeId)
  if timeCfg and timeCfg.basetimmerid then
    local baseTimeCfg = Z.TableMgr.GetTable("TimerTableMgr").GetRow(timeCfg.basetimmerid)
    if baseTimeCfg then
      startTime = Z.TimeTools.TimerTabaleTimeParse(baseTimeCfg.starttime)
      endTime = Z.TimeTools.TimerTabaleTimeParse(baseTimeCfg.endtime)
    end
  else
    startTime = Z.TimeTools.TimerTabaleTimeParse(timeCfg.starttime)
    endTime = Z.TimeTools.TimerTabaleTimeParse(timeCfg.endtime)
  end
  offsetTime = timeCfg.startTimeOffset
  if startTime then
    local _, totalSec = Z.TimeTools.TimerTabaleOffsetParse(offsetTime)
    local startTime = totalSec + startTime
    local now = Z.TimeTools.Now() / 1000
    if startTime <= now and (endTime == nil or endTime >= now) then
      result = true
      progress = endTime and endTime - now or 1
      tipsVal = Z.TimeTools.FormatToDHM(progress)
    elseif startTime > now then
      result = false
      progress = Z.TimeTools.DiffTime(startTime, now)
      tipsVal = Z.TimeTools.FormatToDHM(progress)
    end
  end
  return result, tipsId, {val = tipsVal}, progress
end

return ConditionHelper
