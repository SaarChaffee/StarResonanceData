local super = require("ui.model.data_base")
local PowerSaveData = class("PowerSaveData", super)

function PowerSaveData:ctor()
  super.ctor(self)
end

function PowerSaveData:Init()
  self.isPowerSaveMode_ = false
end

function PowerSaveData:Clear()
end

function PowerSaveData:UnInit()
end

function PowerSaveData:SetLastData(inputEnabled)
  self.inputEnabled_ = inputEnabled
end

function PowerSaveData:GetLastData()
  return self.inputEnabled_
end

function PowerSaveData:SetOpen(isOpen)
  self.isPowerSaveMode_ = isOpen
end

function PowerSaveData:GetOpen()
  return self.isPowerSaveMode_
end

return PowerSaveData
