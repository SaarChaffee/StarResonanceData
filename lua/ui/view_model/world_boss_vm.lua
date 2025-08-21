local worldProxy = require("zproxy.world_proxy")
local worldBossData = Z.DataMgr.Get("world_boss_data")
local WorldBossVM = {}

function WorldBossVM:GetProgressItemRedName(index)
  return "world_boss_progress_item" .. E.RedType.WorldBossProgressAwardItemRed .. index
end

function WorldBossVM:GetScoreItemRedName(score)
  return "world_boss_score_item" .. E.RedType.WorldBossScoreAwardItemRed .. score
end

function WorldBossVM.OpenWorldBoss()
  WorldBossVM.OpenWorldBossMainView()
end

function WorldBossVM:AsyncGetWorldBossInfo(cancelToken, callBack)
  local param = {}
  local ret = worldProxy.GetWorldBossInfo(param, cancelToken)
  if ret then
    worldBossData:SetWorldBossInfoData(ret)
    if callBack then
      callBack(ret)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.WorldBoss.GetWorldBossInfoCall)
  end
end

function WorldBossVM:AsyncReceiveScoreReward(stageID, cancelToken)
  local param = {scoreStage = stageID}
  local ret = worldProxy.ReceiveScoreReward(param, cancelToken)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end

function WorldBossVM:AsyncReceiveBossReward(stageID, cancelToken)
  local param = {stage = stageID}
  local ret = worldProxy.ReceiveBossReward(param, cancelToken)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end

function WorldBossVM:GetStageTableData()
  local tableList = {}
  local datas = worldBossData:GetWorldBossStageTableDatas()
  local index = 1
  for _, value in pairs(datas) do
    tableList[index] = value
    index = index + 1
  end
  table.sort(tableList, function(a, b)
    return a.Id < b.Id
  end)
  return tableList
end

function WorldBossVM:GetSelfRankAndScore()
  local worldBossSettlement = Z.ContainerMgr.DungeonSyncData.settlement.worldBossSettlement
  local charId = Z.ContainerMgr.CharSerialize.charId
  local rankDatas = worldBossSettlement.dungeonBossRank.bossRank
  local rankData
  for _, value in pairs(rankDatas) do
    if value.charId == charId then
      rankData = value
      break
    end
  end
  if rankData == nil then
    return 0, 0
  end
  local rankIndex = rankData.rank
  local score = rankData.score
  if score < Z.WorldBoss.WorldBossMinContribute then
    rankIndex = 0
  end
  return rankIndex, score
end

function WorldBossVM.AsyncExitDungeon(cancelToken)
  local proxy = require("zproxy.world_proxy")
  proxy.LeaveScene(cancelToken)
end

function WorldBossVM.OpenWorldBossMainView()
  Z.UIMgr:OpenView("world_boss_main")
end

function WorldBossVM.CloseWorldBossMainView()
  Z.UIMgr:CloseView("world_boss_main")
end

function WorldBossVM:OpenWorldBossScoreView()
  Z.UIMgr:OpenView("world_boss_bonus_points_popup")
end

function WorldBossVM:CloseWorldBossScoreView()
  Z.UIMgr:CloseView("world_boss_bonus_points_popup")
end

function WorldBossVM:OpenWorldBossScheduleView()
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  if not funcVM.FuncIsOn(E.FunctionID.WorldBoss) then
    return
  end
  Z.UIMgr:OpenView("world_boss_full_schedule_popup")
end

function WorldBossVM:CloseWorldBossScheduleView()
  Z.UIMgr:CloseView("world_boss_full_schedule_popup")
end

function WorldBossVM:OpenWorldBossSettlementView()
  Z.UIMgr:OpenView("world_boss_settlement")
end

function WorldBossVM:CloseWorldBossSettlementView()
  Z.UIMgr:CloseView("world_boss_settlement")
end

function WorldBossVM:NoticeWorldBossOpen()
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.FuncIsOn(E.FunctionID.WorldBoss, true) then
    return
  end
  local chatMainVm = Z.VMMgr.GetVM("chat_main")
  for k, v in ipairs(Z.WorldBoss.WorldBossOpenChat) do
    chatMainVm.addTipsByConfigId(v, false)
  end
end

return WorldBossVM
