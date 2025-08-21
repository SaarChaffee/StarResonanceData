local DpsVm = {}

function DpsVm.CheckIsDpsTrackerOn()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local isDpsTrackerOn = false
  if dungeonId ~= 0 then
    local dungeonRow = Z.TableMgr.GetRow("DungeonsTableMgr", dungeonId)
    if dungeonRow and dungeonRow.IsDpsTrackerOn then
      isDpsTrackerOn = true
      if dungeonRow.PlayType == E.DungeonType.MasterChallengeDungeon then
        local heroDungeonVm = Z.VMMgr.GetVM("hero_dungeon_main")
        local masterChallengeDungeonId = heroDungeonVm.GetCurMasterChallengeDungeonId()
        local heroMaterDungeonRow = Z.TableMgr.GetRow("MasterChallengeDungeonTableMgr", masterChallengeDungeonId, true)
        if heroMaterDungeonRow then
          isDpsTrackerOn = heroMaterDungeonRow.IsDpsTrackerOn
        end
      end
    end
  end
  return isDpsTrackerOn
end

return DpsVm
