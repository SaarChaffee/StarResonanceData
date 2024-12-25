local super = require("stage.stage_base")
local StageSelectChar = class("StageSelectChar", super)

function StageSelectChar:ctor()
  super.ctor(self, Z.EStageType.SelectChar)
end

return StageSelectChar
