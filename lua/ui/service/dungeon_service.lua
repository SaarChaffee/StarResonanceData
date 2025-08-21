local super = require("ui.service.service_base")
local DungeonService = class("DungeonService", super)

function DungeonService:OnInit()
  self.dungeonData_ = Z.DataMgr.Get("dungeon_data")
  
  function self.onflagChangeFunc(container, dirtyKeys)
    if dirtyKeys.dungeonInfoUpdateTime or dirtyKeys.seasonAwards then
      self:refreshMasterScoreReddot()
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.SyncSeason, self.registerWatcher, self)
  Z.EventMgr:Add(Z.ConstValue.Dungeon.UpdateMasterDungeonScore, self.refreshMasterScoreReddot, self)
end

function DungeonService:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Dungeon.UpdateMasterDungeonScore, self.refreshMasterScoreReddot, self)
  Z.EventMgr:Remove(Z.ConstValue.SyncSeason, self.registerWatcher, self)
end

function DungeonService:OnLogin()
end

function DungeonService:OnLogout()
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId]
  if seasonMasterDungeonInfo == nil then
    return
  end
  seasonMasterDungeonInfo.Watcher:UnregWatcher(self.onflagChangeFunc)
end

function DungeonService:OnEnterStage(stage, toSceneId, dungeonId)
  if dungeonId == 0 then
    self.dungeonData_:SetDungeonTimeData(nil)
  end
end

function DungeonService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    Z.CoroUtil.create_coro_xpcall(function()
      local matchVm = Z.VMMgr.GetVM("match")
      matchVm.AsyncGetMatchInfo()
      local dungeonVm = Z.VMMgr.GetVM("dungeon")
      dungeonVm.AsyncGetSeasonDungeonList()
      dungeonVm.InitDungeonRedpoint()
    end)()
  end
end

function DungeonService:OnSyncAllContainerData()
  self:registerWatcher()
end

function DungeonService:registerWatcher()
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId]
  if seasonMasterDungeonInfo == nil then
    return
  end
  seasonMasterDungeonInfo.Watcher:RegWatcher(self.onflagChangeFunc)
  self:refreshMasterScoreReddot()
end

function DungeonService:refreshMasterScoreReddot()
  local heroDungeonVm_ = Z.VMMgr.GetVM("hero_dungeon_main")
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local totalScore = heroDungeonVm_.GetPlayerSeasonMasterDungeonScore(seasonId)
  for index, value in ipairs(Z.GlobalDungeon.MasterScoreAward) do
    local isReceive = heroDungeonVm_.CheckGetSeasonScoreAwrard(index)
    local canReceive = totalScore >= value[1]
    if canReceive and not isReceive then
      Z.RedPointMgr.UpdateNodeCount(E.RedType.MasterScore, 1)
      Z.EventMgr:Dispatch(Z.ConstValue.Hero.MasterScoreAward)
      return
    end
  end
  Z.RedPointMgr.UpdateNodeCount(E.RedType.MasterScore, 0)
  Z.EventMgr:Dispatch(Z.ConstValue.Hero.MasterScoreAward)
end

return DungeonService
