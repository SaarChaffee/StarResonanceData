local super = require("stage.stage_base")
local StageMirrorDungeon = class("StageMirrorDungeon", super)

function StageMirrorDungeon:ctor()
  super.ctor(self, Z.EStageType.Dungeon)
end

return StageMirrorDungeon
