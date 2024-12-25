local super = require("ui.service.service_base")
local DungeonService = class("DungeonService", super)

function DungeonService:OnInit()
  self.dungeonData_ = Z.DataMgr.Get("dungeon_data")
end

function DungeonService:OnUnInit()
end

function DungeonService:OnLogin()
end

function DungeonService:OnLogout()
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
    end)()
  end
end

return DungeonService
