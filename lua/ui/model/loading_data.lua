local super = require("ui.model.data_base")
local LoadingData = class("LoadingData", super)

function LoadingData:ctor()
end

function LoadingData:Init()
  self.TargetProgress = 0
end

function LoadingData:Clear()
  self.TargetProgress = 0
end

function LoadingData:UnInit()
  self.TargetProgress = 0
end

function LoadingData:GetTargetProgress()
  return self.TargetProgress
end

function LoadingData:SetTargetProgress(progress)
  self.TargetProgress = progress
end

return LoadingData
