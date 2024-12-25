local super = require("ui.component.loopscrollrectitem")
local DmgControlBuffLoop = class("DmgControlBuffLoop", super)

function DmgControlBuffLoop:OnInit()
end

function DmgControlBuffLoop:OnReset()
end

function DmgControlBuffLoop:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.unit.lab_content.TMPLab.text = self.data_
  self.unit.node_on:SetVisible(false)
  self.unit.node_off:SetVisible(true)
end

function DmgControlBuffLoop:OnPointerClick()
  self.parent.uiView:BuffSelected(self.data_)
end

function DmgControlBuffLoop:Selected(isSelect)
  self.unit.node_on:SetVisible(isSelect)
  self.unit.node_off:SetVisible(not isSelect)
end

function DmgControlBuffLoop:OnUnInit()
end

return DmgControlBuffLoop
