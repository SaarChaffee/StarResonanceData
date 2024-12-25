local super = require("ui.model.data_base")
local EquipSystemData = class("BackpackData", super)

function EquipSystemData:ctor()
  super.ctor(self)
  self.GsTransferDesItem = nil
  self.GsTransferSourceItem = nil
  self.IsShowRepairState = true
  self.EquipModelName = "equipModel"
end

return EquipSystemData
