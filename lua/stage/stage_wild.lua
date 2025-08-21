local super = require("stage.stage_base")
local StageWild = class("StageWild", super)

function StageWild:ctor()
  super.ctor(self, Z.EStageType.Wild)
end

function StageWild:OnEnterScene(sceneId)
  super.OnEnterScene(self, sceneId)
end

return StageWild
