local super = require("ui.component.loopscrollrectitem")
local DmgControlTargetLoop = class("DmgControlTargetLoop", super)

function DmgControlTargetLoop:OnInit()
end

function DmgControlTargetLoop:OnReset()
end

function DmgControlTargetLoop:OnPointerClick()
  self.parent.uiView:TargetSelected(self.data_)
end

function DmgControlTargetLoop:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.unit.lab_content.TMPLab.text = self.data_
  self.unit.node_on:SetVisible(false)
  self.unit.node_off:SetVisible(true)
end

function DmgControlTargetLoop:Selected(isSelect)
  self.unit.node_on:SetVisible(isSelect)
  self.unit.node_off:SetVisible(not isSelect)
end

function DmgControlTargetLoop:OnUnInit()
end

return DmgControlTargetLoop
