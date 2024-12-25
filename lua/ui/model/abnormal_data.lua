local super = require("ui.model.data_base")
local AbnormalData = class("AbnormalData", super)

function AbnormalData:ctor()
  super.ctor(self)
  self.timerMgr_ = Z.TimerMgr.new()
  self:Init()
end

function AbnormalData:Init()
  self.ReduceTime = {}
end

function AbnormalData:GetReduceTime(uuid)
  return self.ReduceTime[uuid]
end

function AbnormalData:SetReduceTime(uuid, createTime, duration)
  if not self.ReduceTime[uuid] then
    self.ReduceTime[uuid] = {}
  end
  local buffCreateTime = Z.NumTools.GetPreciseDecimal(createTime / 1000, 1)
  self.ReduceTime[uuid].createTime = buffCreateTime
  local buffDurationTime = Z.NumTools.GetPreciseDecimal(duration / 1000, 1)
  local buffEndTime = buffCreateTime + buffDurationTime
  self.ReduceTime[uuid].endTime = buffEndTime
end

function AbnormalData:Clear()
  self:Init()
  self.timerMgr_:Clear()
end

return AbnormalData
