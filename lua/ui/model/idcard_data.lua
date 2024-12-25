local super = require("ui.model.data_base")
local IdCardData = class("IdCardData", super)

function IdCardData:ctor()
  super.ctor(self)
  self.PlayerIdCardData = {}
end

return IdCardData
