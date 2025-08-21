local getPointByType = function(type)
  local data = Z.DataMgr.Get("recommend_fightvalue_data")
  local serverType = data.FunctionIdToServerFightPointType[type]
  local totalFightPoint = 0
  if Z.ContainerMgr.CharSerialize.fightPoint.fightPointData[serverType] then
    totalFightPoint = Z.ContainerMgr.CharSerialize.fightPoint.fightPointData[serverType].totalPoint
  end
  return totalFightPoint
end
local getTotalPoint = function()
  return Z.ContainerMgr.CharSerialize.fightPoint.totalFightPoint
end
local checkERValueLevel = function(type, level)
  local levelCfg = Z.TableMgr.GetTable("PlayerLevelTableMgr").GetRow(level)
  if levelCfg then
    for _, v in pairs(levelCfg.NacsStandard) do
      if v[1] == type then
        local curPoint = getPointByType(type)
        return curPoint >= v[2]
      end
    end
  end
end
local checkERValueSeason = function(type)
  local seasonVm = Z.VMMgr.GetVM("season")
  local seasonId, day = seasonVm.GetSeasonByTime()
  if seasonId == 0 or day == 0 then
    return true
  end
  local seasonData = Z.DataMgr.Get("season_data")
  for id, seasonCfgData in pairs(seasonData.SeasonDailyTableDatas) do
    if seasonCfgData.Season == seasonId and seasonCfgData.Day == day then
      for _, v in pairs(seasonCfgData.NacsStandard) do
        if v[1] == type then
          local curPoint = getPointByType(type)
          return curPoint >= v[2]
        end
      end
    end
  end
  return true
end
local checkExceedingRecommendedValue = function(type)
  if type == nil then
    return false
  end
  local roleLevelData = Z.DataMgr.Get("role_level_data")
  local maxLevel = roleLevelData:GetMaxLevel()
  local curLevel = roleLevelData:GetRoleLevel()
  if maxLevel <= curLevel then
    return checkERValueSeason(type)
  else
    return checkERValueLevel(type, curLevel)
  end
end
local openMainView = function()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.RecommendFightValue)
  if not isOn then
    return
  end
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.RecommendFightValue, "competency_rating_main", function()
    Z.UIMgr:OpenView("competency_rating_main")
  end, Z.ConstValue.UnrealSceneConfigPaths.Role)
end
local closeMainView = function()
  Z.UIMgr:CloseView("competency_rating_main")
end
local uploadFightValueTLog = function()
  local WorldProxy = require("zproxy.world_proxy")
  local contentList = {
    getTotalPoint(),
    getPointByType(E.RecommendFightValueType.Level),
    getPointByType(E.RecommendFightValueType.Talent),
    getPointByType(E.RecommendFightValueType.Equip),
    getPointByType(E.RecommendFightValueType.Skill),
    getPointByType(E.RecommendFightValueType.Mod),
    getPointByType(E.RecommendFightValueType.Season)
  }
  local content = table.concat(contentList, "|")
  WorldProxy.UploadTLogBody("FightValueSyncFromClient", content)
end
local ret = {
  GetPointByType = getPointByType,
  GetTotalPoint = getTotalPoint,
  OpenMainView = openMainView,
  CloseMainView = closeMainView,
  CheckExceedingRecommendedValue = checkExceedingRecommendedValue,
  UploadFightValueTLog = uploadFightValueTLog
}
return ret
