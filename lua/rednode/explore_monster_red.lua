local ExploreMonsterRed = {}
ExploreMonsterRed.package = {}

function ExploreMonsterRed.AddNewRed()
  for i = 1, 4 do
    local childRedId = ExploreMonsterRed.GetTabRedDotID(i)
    Z.RedPointMgr.AddChildNodeData(E.RedType.MonsterHuntMapBtn, E.RedType.MonsterHuntLeftTab, childRedId)
    local count_ = ExploreMonsterRed.RefreshTabRedItem(i)
    Z.RedPointMgr.UpdateNodeCount(childRedId, count_)
  end
end

function ExploreMonsterRed.GetTabRedDotID(tabID)
  local childRedId = E.RedType.MonsterHuntMapBtn .. E.RedType.MonsterHuntLeftTab .. tabID
  return childRedId
end

function ExploreMonsterRed.RefreshTargetRedItem(monsterId)
  local exploreMonsterVM = Z.VMMgr.GetVM("explore_monster")
  local monsterData = exploreMonsterVM.GetExploreMonsterTargetInfoList(monsterId)
  if monsterData then
    for _, value in pairs(monsterData) do
      local info_ = value
      if info_.awardFlag == E.MonsterHuntTargetAwardState.Get then
        return 1
      end
    end
  end
  return 0
end

function ExploreMonsterRed.RefreshTabRedItem(rank)
  local exploreMonsterVM = Z.VMMgr.GetVM("explore_monster")
  local monsterList = exploreMonsterVM.GetExploreMonsterListByFilter({}, rank, "")
  for _, data in ipairs(monsterList) do
    local monsterData = exploreMonsterVM.GetExploreMonsterTargetInfoList(data.ExploreData.MonsterId)
    if monsterData then
      for _, value in pairs(monsterData) do
        local info_ = value
        if info_.awardFlag == E.MonsterHuntTargetAwardState.Get then
          return 1
        end
      end
    end
  end
  return 0
end

function ExploreMonsterRed.RefreshLevelRedItem()
  local exploreMonsterVM = Z.VMMgr.GetVM("explore_monster")
  local curLevel = exploreMonsterVM.GetMonsterHuntLevel()
  local receiveData = exploreMonsterVM.GetHuntLevelAwardReceiveState()
  local list = exploreMonsterVM.GetAllMonsterHuntLevelData()
  if receiveData then
    for _, value in pairs(list) do
      if curLevel >= value.Level then
        local curData_ = receiveData.levelAwardFlag[value.Level]
        if curData_ ~= nil then
          local canReceive = curData_ == E.MonsterHuntTargetAwardState.Receive
          if canReceive == false then
            return 1
          end
        end
      end
    end
  end
  return 0
end

return ExploreMonsterRed
