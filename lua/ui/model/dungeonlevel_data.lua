local super = require("ui.model.data_base")
local DungeonLevelData = class("DungeonLevelData", super)

function DungeonLevelData:ctor()
  super.ctor(self)
  self.PioneerInfos = nil
end

return DungeonLevelData
