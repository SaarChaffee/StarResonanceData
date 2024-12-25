local getExploreTarget = function(exploreId)
  local exploreInfo = Z.TableMgr.GetTable("ExploreTableMgr").GetRow(exploreId)
  if exploreInfo == nil then
    return nil, nil
  end
  return exploreInfo, Z.TableMgr.GetTable("TargetTableMgr").GetRow(exploreInfo.TargetID)
end
local ret = {GetExploreTarget = getExploreTarget}
return ret
