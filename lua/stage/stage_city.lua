local super = require("stage.stage_base")
local StageCity = class("StageHall", super)

function StageCity:ctor()
  super.ctor(self, Z.EStageType.City)
end

function StageCity:OnEnterScene(sceneId)
  super.OnEnterScene(self, sceneId)
end

return StageCity
