local super = require("ui.model.data_base")
local EntityAndHudRecordData = class("EntityAndHudRecordData", super)

function EntityAndHudRecordData:ctor()
  super.ctor(self)
end

function EntityAndHudRecordData:Init()
  super.Init(self)
  self.CancelSource = Z.CancelSource.Rent()
  self.ShowEntityRecord = {}
  self.ShowUIAllRecord = {}
end

function EntityAndHudRecordData:UnInit()
  self.CancelSource:Recycle()
  self.ShowUIAllRecord = nil
end

function EntityAndHudRecordData:SetShowEntityRecord(type, state)
  self.ShowEntityRecord[type] = state
end

function EntityAndHudRecordData:SetShowUIRecord(type, state)
  self.ShowUIAllRecord[type] = state
end

function EntityAndHudRecordData:GetShowEntityRecord(type)
  local show = true
  if self.ShowEntityRecord[type] ~= nil then
    show = self.ShowEntityRecord[type]
  end
  return show
end

function EntityAndHudRecordData:GetShowUIRecord(type)
  local show = true
  if self.ShowUIAllRecord[type] ~= nil then
    show = self.ShowUIAllRecord[type]
  end
  return show
end

return EntityAndHudRecordData
