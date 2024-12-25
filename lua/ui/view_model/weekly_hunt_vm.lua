local WeeklyHuntVm = {}
local enterdungeonsceneVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
local wordProxy = require("zproxy.world_proxy")

function WeeklyHuntVm.OpenRankView()
  Z.UIMgr:OpenView("weekly_hunt_rankings_window")
end

function WeeklyHuntVm.CloseRankView()
  Z.UIMgr:CloseView("weekly_hunt_rankings_window")
end

function WeeklyHuntVm.OpenWeekHuntView()
  Z.UIMgr:OpenView("weekly_hunt_main")
end

function WeeklyHuntVm.CloseWeekHuntView()
  Z.UIMgr:CloseView("weekly_hunt_main")
end

function WeeklyHuntVm.OpenTargetView()
  Z.UIMgr:OpenView("weekly_hunt_target_reward_popup")
end

function WeeklyHuntVm.CloseTargetView()
  Z.UIMgr:CloseView("weekly_hunt_target_reward_popup")
end

function WeeklyHuntVm.AsyncGetWeeklyTowerProcessAward(climbUpId, isoneKey, token)
  local request = {climbUpId = climbUpId}
  if isoneKey then
    request.oneKey = isoneKey
  end
  local ret = wordProxy.GetWeeklyTowerProcessAward(request, token)
  Z.TipsVM.ShowTips(ret)
end

function WeeklyHuntVm.AsyncGetTeamTowerLayerInfo(token)
  local ret = wordProxy.GetTeamTowerLayerInfo(token)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  else
    return ret
  end
end

function WeeklyHuntVm.InitClimbUpLayerTable()
  local data = Z.DataMgr.Get("weekly_hunt_data")
  local climbUpLayerData = Z.TableMgr.GetTable("ClimbUpLayerTableMgr").GetDatas()
  local tabs = {}
  local dungeons = {}
  local maxLayer = 0
  local climbUpRuleTable = Z.TableMgr.GetTable("ClimbUpRuleTableMgr").GetDatas()
  local ruleTab = {}
  for index, value in pairs(climbUpRuleTable) do
    ruleTab[value.Season] = value
  end
  for index, value in pairs(climbUpLayerData) do
    if maxLayer < value.LayerNumber then
      maxLayer = value.LayerNumber
    end
    if tabs[value.Season] == nil then
      tabs[value.Season] = {}
    end
    dungeons[value.DungeonId] = value.LayerNumber
    local tab = tabs[value.Season][value.StageId]
    if tab == nil then
      tabs[value.Season][value.StageId] = {}
      tab = tabs[value.Season][value.StageId]
      tab.awards = {}
      tab.stageId = value.StageId
      tab.climbUpLayerRows = {}
      tab.affixIds = {}
      tab.layer = value.LayerNumber
      tab.isBossLayer = value.LayarType == E.WeeklyHuntMonsterType.Boss
      tab.jumpStage = 1
      local releRow = ruleTab[value.Season]
      if releRow then
        for index, stage in pairs(releRow.JumpStage) do
          if stage >= value.StageId then
            tab.jumpStage = index
            break
          end
        end
      end
    end
    if value.RewardId ~= 0 then
      tab.awards[value.LayarType] = value.RewardId
    end
    for index, value in ipairs(value.AffixId) do
      if not tab.affixIds[value] then
        tab.affixIds[value] = value
      end
    end
    tab.climbUpLayerRows[#tab.climbUpLayerRows + 1] = value
  end
  for seasonId, climbUpLayerDatas in pairs(tabs) do
    for _, v in pairs(climbUpLayerDatas) do
      table.sort(v.climbUpLayerRows, function(left, right)
        return left.LayerNumber < right.LayerNumber
      end)
    end
  end
  data:SetMaxLayer(maxLayer)
  data:SetClimbUpLayerDatas(table.zvalues(tabs))
  data:SetDungeons(dungeons)
  data:SetClimbRuleDatas(ruleTab)
end

function WeeklyHuntVm.GetAffixByDungeonId(dungeonId)
  local data = Z.DataMgr.Get("weekly_hunt_data")
  local layer = data.DungeonLayers[dungeonId]
  if layer then
    local climbUpLayerTableRow = Z.TableMgr.GetRow("ClimbUpLayerTableMgr", layer)
    return climbUpLayerTableRow.AffixId
  end
  return nil
end

function WeeklyHuntVm.Enterdungeon(dungeonId, token)
  return enterdungeonsceneVm.AsyncCreateLevel(E.FunctionID.WeeklyHunt, dungeonId, token)
end

function WeeklyHuntVm.enterTeamTowerLayer()
  local teamVm = Z.VMMgr.GetVM("team")
  if teamVm.CheckIsInTeam() and not teamVm.GetYouIsLeader() then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local dungeonData = Z.DataMgr.Get("dungeon_data")
    dungeonData:CreatCancelSource()
    local ret = WeeklyHuntVm.AsyncGetTeamTowerLayerInfo(dungeonData.CancelSource:CreateToken())
    if ret then
      local climbUpLayerTableRow = Z.TableMgr.GetRow("ClimbUpLayerTableMgr", ret.enterClimbUpId)
      if climbUpLayerTableRow then
        WeeklyHuntVm.Enterdungeon(climbUpLayerTableRow.DungeonId, dungeonData.CancelSource:CreateToken())
      end
    end
    dungeonData:RecycleCancelSource()
  end)()
end

function WeeklyHuntVm.Countdown(isShow)
  if isShow then
    local time = 5
    Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.WeeklyHuntNext, function()
      Z.TipsVM.ShowTips(1006001, {val = time})
      time = time - 1
      if time == 0 then
        WeeklyHuntVm.enterTeamTowerLayer()
      end
    end, 1, 5)
  else
    Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.WeeklyHuntNext)
  end
end

function WeeklyHuntVm.ResultFailed()
  local teamVm = Z.VMMgr.GetVM("team")
  if teamVm.CheckIsInTeam() and not teamVm.GetYouIsLeader() then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local dungeonData = Z.DataMgr.Get("dungeon_data")
    dungeonData:CreatCancelSource()
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    if dungeonId and dungeonId ~= 0 then
      WeeklyHuntVm.Enterdungeon(dungeonId, dungeonData.CancelSource:CreateToken())
    end
    dungeonData:RecycleCancelSource()
  end)()
end

function WeeklyHuntVm.GetTargetAwardRedName(layer)
  return "weekly_hunt_award_red" .. layer
end

return WeeklyHuntVm
