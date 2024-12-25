local super = require("ui.model.data_base")
local EquipCfgData = class("EquipCfgData", super)

function EquipCfgData:ctor()
  super.ctor(self)
end

function EquipCfgData:Init()
  self.RefineTableData = {}
  self.RefineBlessingTableData = {}
  self.RecastMaxLevleTab = {}
  self.RecastPerfectTab = {}
end

function EquipCfgData:Clear()
end

function EquipCfgData:UnInit()
end

return EquipCfgData
