local super = require("ui.model.data_base")
local CutsceneData = class("CutsceneData", super)

function CutsceneData:ctor()
  super.ctor(self)
  self:Clear()
end

function CutsceneData:Clear()
end

return CutsceneData
