local super = require("ui.model.data_base")
local EquipRefineData = class("EquipRefineData", super)

function EquipRefineData:ctor()
  super.ctor(self)
end

function EquipRefineData:Init()
  self.BaseSuccessRate = 0
  self.CurrentSuccessRate = 0
  self.CurSelBlessingData = {}
end

function EquipRefineData:SetBaseSuccessRate(value)
  self.BaseSuccessRate = value
end

function EquipRefineData:SetCurrentSuccessRate(value)
  self.CurrentSuccessRate = value
end

function EquipRefineData:Clear()
end

function EquipRefineData:UnInit()
end

return EquipRefineData
