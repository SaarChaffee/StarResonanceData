local super = require("stage.stage_base")
local StageUnionDungeon = class("StageUnionDungeon", super)

function StageUnionDungeon:ctor()
  super.ctor(self, Z.EStageType.UnionDungeon)
end

return StageUnionDungeon
