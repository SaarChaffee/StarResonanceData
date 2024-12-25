local super = require("ui.model.data_base")
local BackpackData = class("BackpackData", super)

function BackpackData:ctor()
  super.ctor(self)
  self.ItemBackIdxToFuncId = {
    [1] = E.BackpackFuncId.ItemBp,
    [2] = E.BackpackFuncId.EquipBp,
    [5] = E.BackpackFuncId.CardBp,
    [6] = E.BackpackFuncId.ResonanceSkill
  }
  self.SortState = false
end

function BackpackData:Init()
  self.NewItems = {}
  self.NewPackageItems = {}
end

function BackpackData:Clear()
  self.NewItems = {}
  self.NewPackageItems = {}
end

return BackpackData
