local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local DmgAttrLoop = class("DmgAttrLoop", super)

function DmgAttrLoop:OnInit()
end

function DmgAttrLoop:OnReset()
end

function DmgAttrLoop:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self.unit.lab_01.TMPLab.text = self.data_.id
  self.unit.lab_02.TMPLab.text = self.data_.name
  self.unit.lab_03.TMPLab.text = self.data_.content
end

function DmgAttrLoop:OnUnInit()
end

return DmgAttrLoop
