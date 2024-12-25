local super = require("ui.component.loopscrollrectitem")
local DmgControlDummyLoop = class("DmgControlDummyLoop", super)

function DmgControlDummyLoop:OnInit()
end

function DmgControlDummyLoop:OnReset()
end

function DmgControlDummyLoop:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.unit.lab_content.TMPLab.text = self.data_
  self.unit.node_on:SetVisible(false)
  self.unit.node_off:SetVisible(true)
end

function DmgControlDummyLoop:OnPointerClick()
  self.parent.uiView:DummySelected(self.data_)
end

function DmgControlDummyLoop:Selected(isSelect)
  self.unit.node_on:SetVisible(isSelect)
  self.unit.node_off:SetVisible(not isSelect)
end

function DmgControlDummyLoop:OnUnInit()
end

return DmgControlDummyLoop
