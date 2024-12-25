local super = require("ui.model.data_base")
local PivotData = class("PivotData", super)

function PivotData:ctor()
  super.ctor(self)
  self.portGuideData = {}
  self.guidePortUid = -1
  self.curUnlockPivotId_ = nil
end

function PivotData:AddPortGuideData(id, distance)
  self.portGuideData[id] = distance
end

function PivotData:ClearGuideData()
  self.portGuideData = {}
end

function PivotData:GetPortGuideData()
  local dis = 99999
  local tempUid = -1
  for uid, distance in pairs(self.portGuideData) do
    if distance < dis then
      dis = distance
      tempUid = uid
    end
  end
  self.portGuideData = {}
  if tempUid == -1 then
    self.guidePortUid = -1
    return false, tempUid
  end
  if tempUid == self.guidePortUid then
    return true, -1
  else
    self.guidePortUid = tempUid
    return true, self.guidePortUid
  end
end

function PivotData:SetUnlockPivotId(pivotId)
  self.curUnlockPivotId_ = pivotId
end

function PivotData:GetUnlockPivotId()
  return self.curUnlockPivotId_
end

return PivotData
