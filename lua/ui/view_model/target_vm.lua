local getExploreTarget = function(exploreId)
  local exploreInfo = Z.TableMgr.GetTable("ExploreTableMgr").GetRow(exploreId)
  if exploreInfo == nil then
    return nil, nil
  end
  local stepId = exploreInfo.QuestStepID
  if stepId ~= nil and stepId ~= 0 then
    local stepInfo = Z.TableMgr.GetTable("ExploreStepTableMgr").GetRow(stepId, true)
    return exploreInfo, stepInfo
  end
  return exploreInfo, Z.TableMgr.GetTable("TargetTableMgr").GetRow(exploreInfo.TargetID)
end
local ret = {GetExploreTarget = getExploreTarget}
return ret
