local super = require("ui.model.data_base")
local EquipSystemData = class("BackpackData", super)

function EquipSystemData:ctor()
  super.ctor(self)
  self.GsTransferDesItem = nil
  self.GsTransferSourceItem = nil
  self.IsShowRepairState = true
  self.EquipModelName = "equipModel"
end

function EquipSystemData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function EquipSystemData:UnInit()
  self.CancelSource:Recycle()
end

function EquipSystemData:Clear()
end

return EquipSystemData
