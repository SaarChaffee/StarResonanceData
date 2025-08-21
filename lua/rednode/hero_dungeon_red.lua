local HeroDungeonRed = {}
local itemType = {
  underway = 0,
  get = 1,
  received = 2
}

function HeroDungeonRed.InitRed()
  local weekTarget = Z.ContainerMgr.CharSerialize.dungeonList.weekTarget.weekTarget
  for targetId, targetProgress in pairs(weekTarget) do
    Z.RedPointMgr.AddChildNodeData(E.RedType.HeroDungeonWeek, E.RedType.HeroDungeonWeekTraget, E.RedType.HeroDungeonWeekTraget .. targetProgress.targetId)
    if targetProgress.awardState == itemType.get then
      Z.RedPointMgr.UpdateNodeCount(E.RedType.HeroDungeonWeekTraget .. targetProgress.targetId, 1)
    else
      Z.RedPointMgr.UpdateNodeCount(E.RedType.HeroDungeonWeekTraget .. targetProgress.targetId, 0)
    end
  end
end

return HeroDungeonRed
