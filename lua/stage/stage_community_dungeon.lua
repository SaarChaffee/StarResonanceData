local super = require("stage.stage_base")
local StageCommunityDungeon = class("StageCommunityDungeon", super)

function StageCommunityDungeon:ctor()
  super.ctor(self, Z.EStageType.CommunityDungeon)
end

return StageCommunityDungeon
