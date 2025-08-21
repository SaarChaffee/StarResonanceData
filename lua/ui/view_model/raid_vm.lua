local RaidVM = {}

function RaidVM:OpenRaidMainView(diff)
  if not Z.VMMgr.GetVM("raid"):CheckAnyDiffRaidDungeonOpen(true) then
    return
  end
  local viewData = {
    diff = tonumber(diff or 1)
  }
  Z.UIMgr:OpenView("raid_main", viewData)
end

function RaidVM:CloseRaidMainView()
  Z.UIMgr:CloseView("raid_main")
end

function RaidVM:OpenRaidMonsterView(dungeonId, bossId)
  local viewData = {dungeonId = dungeonId, bossId = bossId}
  Z.UIMgr:OpenView("raid_monster_window", viewData)
end

function RaidVM:CloseRaidMonsterView()
  Z.UIMgr:CloseView("raid_monster_window")
end

function RaidVM:CheckAnyDiffRaidDungeonOpen(showTips)
  local gotoVM = Z.VMMgr.GetVM("gotofunc")
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local raidDungeonData = Z.TableMgr.GetTable("RaidDungeonTableMgr").GetDatas()
  for _, value in pairs(raidDungeonData) do
    if value.SeasonId == seasonId then
      local dungeonsConfig = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(value.DungeonId)
      if dungeonsConfig and gotoVM.CheckFuncCanUse(dungeonsConfig.FunctionID, true) then
        for index, bossId in ipairs(value.BossId) do
          local raidBossRow = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(bossId)
          if raidBossRow and Z.TimeTools.CheckIsInTimeByTimeId(raidBossRow.OpenTimerId) then
            return true
          end
        end
      end
    end
  end
  if showTips then
    Z.TipsVM.ShowTips(100102)
  end
  return false
end

function RaidVM:GetBossCountId(bossId)
  local raidBoosRow_ = Z.TableMgr.GetTable("RaidBossTableMgr").GetRow(bossId)
  if raidBoosRow_ == nil then
    return 0
  end
  if Z.TimeTools.CheckIsInTimeByTimeId(raidBoosRow_.TimerId) then
    return raidBoosRow_.UPAwardCount
  end
  return raidBoosRow_.AwardCount
end

function RaidVM:AsyncStartEnterDungeon(functionID, dungeonId, affix, cancelToken, selectType, heroKeyItemUuid)
  local enterdungeonsceneVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
  enterdungeonsceneVm.AsyncCreateLevel(functionID, dungeonId, cancelToken, affix, nil, selectType, heroKeyItemUuid)
end

return RaidVM
