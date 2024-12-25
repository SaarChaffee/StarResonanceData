local WeeklyHuntRed = {}
local processId = {}

function WeeklyHuntRed.initAwardRed()
  local weeklyHuntData = Z.DataMgr.Get("weekly_hunt_data")
  local seasonData = Z.DataMgr.Get("season_data")
  local weeklyHuntVm = Z.VMMgr.GetVM("weekly_hunt")
  local climbRuleRow = weeklyHuntData.ClimbRuleDatas[seasonData.CurSeasonId]
  if climbRuleRow then
    for index, value in ipairs(climbRuleRow.ProcessId) do
      local redName = weeklyHuntVm.GetTargetAwardRedName(value)
      processId[value] = redName
      Z.RedPointMgr.AddChildNodeData(E.RedType.WeeklyHuntTarget, E.RedType.WeeklyHuntAward, redName)
    end
  end
  WeeklyHuntRed.weeklyTowerChange()
end

function WeeklyHuntRed.weeklyTowerChange()
  local weeklyTower = Z.ContainerMgr.CharSerialize.weeklyTower
  local redCountTab = {}
  for layer, red in pairs(processId) do
    if layer <= weeklyTower.maxClimbUpId then
      redCountTab[layer] = 1
    else
      redCountTab[layer] = 0
    end
  end
  for index, layer in ipairs(weeklyTower.awardClimbUpIds) do
    redCountTab[layer] = 0
  end
  for layer, value in pairs(processId) do
    Z.RedPointMgr.RefreshServerNodeCount(value, redCountTab[layer])
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.FunctionID.WeeklyHunt, Z.RedPointMgr.GetRedState(E.RedType.WeeklyHuntTarget))
end

function WeeklyHuntRed.Init()
  function WeeklyHuntRed.weeklyTowerChange_()
    WeeklyHuntRed:weeklyTowerChange()
  end
  
  Z.EventMgr:Add(Z.ConstValue.SyncSeason, WeeklyHuntRed.initAwardRed)
  Z.ContainerMgr.CharSerialize.weeklyTower.Watcher:RegWatcher(WeeklyHuntRed.weeklyTowerChange_)
end

function WeeklyHuntRed.UnInit()
  if WeeklyHuntRed.weeklyTowerChange_ then
    Z.ContainerMgr.CharSerialize.weeklyTower.Watcher:UnregWatcher(WeeklyHuntRed.weeklyTowerChange_)
    WeeklyHuntRed.weeklyTowerChange_ = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.SyncSeason, WeeklyHuntRed.initAwardRed)
end

return WeeklyHuntRed
