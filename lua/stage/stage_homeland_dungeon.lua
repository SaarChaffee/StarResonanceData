local super = require("stage.stage_base")
local StageHomelandDungeon = class("StageHomelandDungeon", super)

function StageHomelandDungeon:ctor()
  super.ctor(self, Z.EStageType.HomelandDungeon)
end

return StageHomelandDungeon
