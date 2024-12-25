local super = require("stage.stage_base")
local StageWild = class("StageWild", super)

function StageWild:ctor()
  super.ctor(self, Z.EStageType.Wild)
end

function StageWild:OnEnterScene(sceneId)
  local mapData = Z.DataMgr.Get("map_data")
  mapData.IsShownNameAfterChangeScene = false
  super.OnEnterScene(self, sceneId)
end

return StageWild
