local super = require("ui.model.data_base")
local GuideData = class("GuideData", super)

function GuideData:ctor()
  super.ctor(self)
  self:Clear()
end

function GuideData:Clear()
end

function GuideData:Init()
end

function GuideData:UnInit(src)
end

return GuideData
