local super = require("ui.model.data_base")
local InsightData = class("InsightData", super)

function InsightData:ctor()
  super.ctor(self)
  self.lastOpenInsightTime_ = 0
end

function InsightData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function InsightData:UnInit()
  self.CancelSource:Recycle()
end

function InsightData:SetLastOpenInsightTime(newTime)
  self.lastOpenInsightTime_ = newTime
end

function InsightData:GetLastOpenInsightTime()
  return self.lastOpenInsightTime_
end

return InsightData
