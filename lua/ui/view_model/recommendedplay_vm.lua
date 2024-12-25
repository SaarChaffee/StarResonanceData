local RecommendedPlayVM = {}
local worldProxy = require("zproxy.world_proxy")

function RecommendedPlayVM.OpenView(id)
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  Z.CoroUtil.create_coro_xpcall(function()
    local reply = RecommendedPlayVM.AsyncGetRecommendPlayData(recommendedPlayData.CancelSource:CreateToken())
    Z.UIMgr:OpenView("recommendedplay_main", id)
  end)()
end

function RecommendedPlayVM.CheckTypeIsRed(typeID)
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local seconds = recommendedPlayData.AllRedDots[typeID]
  local redDots = false
  if seconds then
    for _, thirds in pairs(seconds) do
      if type(thirds) == "boolean" then
        if thirds then
          redDots = true
          break
        end
      else
        for _, isRed in pairs(thirds) do
          if isRed then
            redDots = true
            break
          end
        end
      end
    end
  end
  return redDots
end

function RecommendedPlayVM.CheckSecondTagIsRed(id)
  local recommendedplayConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
  if recommendedplayConfig then
    local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
    local thirds = {}
    if recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]] and recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][id] then
      thirds = recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][id]
    end
    if thirds then
      if type(thirds) == "boolean" then
        if thirds then
          return true
        end
      else
        for _, third in pairs(thirds) do
          if third then
            return true
          end
        end
      end
    end
  end
  return false
end

function RecommendedPlayVM.CheckThirdTagIsRed(id)
  local recommendedplayConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
  if recommendedplayConfig then
    local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
    if recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]] and recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][recommendedplayConfig.ParentId] and recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][recommendedplayConfig.ParentId][id] then
      return true
    end
  end
  return false
end

function RecommendedPlayVM.CheckRedById(id)
  local recommendedplayConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
  if recommendedplayConfig then
    local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
    if recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]] and recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][id] then
      return true
    end
    if recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]] and recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][recommendedplayConfig.ParentId] and recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][recommendedplayConfig.ParentId][id] then
      return true
    end
  end
  return false
end

function RecommendedPlayVM.GetRecommendSurpluseCount(config)
  local count = -1
  if config.FunctionId == E.FunctionID.HeroDungeon then
    count = 0
    local thirdConfigs = Z.DataMgr.Get("recommendedplay_data"):GetThirdTagsById(config.Id)
    if thirdConfigs then
      for _, value in pairs(thirdConfigs) do
        count = count + RecommendedPlayVM.GetRecommendSurpluseCount(value)
      end
    end
  elseif config.FunctionId == E.FunctionID.HeroDungeonDiNa or config.FunctionId == E.FunctionID.HeroDungeonJuTaYiJi or config.FunctionId == E.FunctionID.HeroDungeonJuLongZhuaHen or config.FunctionId == E.FunctionID.HeroDungeonKaNiMan then
    local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(config.RelatedDungeonId)
    if dungeonData then
      local dungeonNormalCounterId = dungeonData.CountLimit
      local limtCount = Z.CounterHelper.GetCounterLimitCount(dungeonNormalCounterId)
      count = Z.CounterHelper.GetCounterResidueLimitCount(dungeonNormalCounterId, limtCount)
    end
  elseif config.FunctionId == E.FunctionID.WorldEvent then
    count = Z.ContainerMgr.CharSerialize.worldEventMap.acceptCount
  elseif config.FunctionId == E.FunctionID.UnionTask then
    local unionTaskVM = Z.VMMgr.GetVM("union_task")
    if Z.TimeTools.Now() / 1000 >= unionTaskVM:GetCanGetRewardTime() then
      count = 1
    else
      count = unionTaskVM:GetHasSend() and 0 or 1
    end
  elseif config.FunctionId == E.FunctionID.ExploreMonsterElite then
    count = Z.VMMgr.GetVM("items").GetItemTotalCount(Z.MonsterHunt.MonsterHuntEliteBootyKeyId)
  elseif config.FunctionId == E.FunctionID.ExploreMonsterBoss then
    count = Z.VMMgr.GetVM("items").GetItemTotalCount(Z.MonsterHunt.MonsterHuntBossBootyKeyId)
  elseif config.FunctionId == E.FunctionID.WorldBoss then
    local countID = Z.WorldBoss.WorldBossAwardCountId
    local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
    count = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
  elseif config.FunctionId == E.FunctionID.SeasonBattlePass then
    count = 0
    local seasonActivationVm = Z.VMMgr.GetVM("season_activation")
    local awardData = seasonActivationVm.GetActivationAwards()
    local maxProgress = 0
    if next(awardData) then
      maxProgress = awardData[#awardData - 1].Activation
    end
    if maxProgress > Z.ContainerMgr.CharSerialize.seasonActivation.activationPoint then
      count = 1
    end
  elseif config.FunctionId == E.FunctionID.UnionWarDance then
    count = RecommendedPlayVM.GetUnionActivityCount(E.FunctionID.UnionWarDance)
  elseif config.FunctionId == E.FunctionID.UnionHunt then
    count = RecommendedPlayVM.GetUnionActivityCount(E.FunctionID.UnionHunt)
  end
  return count
end

function RecommendedPlayVM.CheckServerDataShow(functionID)
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local config = recommendedPlayData:GetRecommendedPlayConfigByFunctionId(functionID)
  local serverTimeData = recommendedPlayData:GetSreverData(config.Id)
  if serverTimeData and Z.TimeTools.Now() / 1000 >= serverTimeData.startTimestamp and Z.TimeTools.Now() / 1000 <= serverTimeData.endTimestamp then
    return true
  end
  return false
end

function RecommendedPlayVM.CheckShowMainIconEffect()
  if RecommendedPlayVM.CheckServerDataShow(E.FunctionID.WorldBoss) then
    local bossRed_ = require("rednode.world_boss_red")
    if (bossRed_.CheckScoreAwardRed() or bossRed_.CheckProgress() or bossRed_.CheckHasAwardInOpenTime()) and not bossRed_.RedChecked() then
      return true
    end
  end
  local unionRed_ = require("rednode.union_red")
  if unionRed_.RefreshUnionWarDanceRed() and not unionRed_.UnionWarDanceRedChecked() then
    return true
  end
  if (unionRed_.RefreshUnionHuntRed() or unionRed_.RefreshUnionHuntRecommendRed()) and not unionRed_.UnionHuntRedChecked() then
    return true
  end
  return false
end

function RecommendedPlayVM.GetUnionActivityCount(functionID)
  local unionActivityData = Z.DataMgr.Get("union_activity_data")
  local countid = unionActivityData:GetCounterByFuncID(functionID)
  if countid == 0 then
    return 0
  end
  local maxLimitNum = 0
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(countid)
  local normalAwardCount = 0
  local nowAwardCount = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[countid] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[countid].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  return normalAwardCount
end

function RecommendedPlayVM.CheckReply(reply)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end

function RecommendedPlayVM.AsyncGetRecommendPlayData(cancelSource)
  local request = {}
  local reply = worldProxy.GetRecommendPlayData(request, cancelSource)
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  if RecommendedPlayVM.CheckReply(reply.errCode) then
    recommendedPlayData:SetServerData(reply.recommendPlayData)
    return true
  end
  recommendedPlayData:SetServerData({})
  return false
end

return RecommendedPlayVM
