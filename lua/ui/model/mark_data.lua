local super = require("ui.model.data_base")
local MarkData = class("MarkData", super)

function MarkData:Init()
  self.markShowState_ = true
end

function MarkData:UnInit()
  self.markShowState_ = true
end

function MarkData:SetMarkState(state)
  self.markShowState_ = state
end

function MarkData:GetMarkState()
  return self.markShowState_
end

return MarkData
