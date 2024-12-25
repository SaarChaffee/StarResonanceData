local super = require("stage.stage_base")
local StageDungeon = class("StageDungeon", super)

function StageDungeon:ctor()
  super.ctor(self, Z.EStageType.Dungeon)
end

return StageDungeon
