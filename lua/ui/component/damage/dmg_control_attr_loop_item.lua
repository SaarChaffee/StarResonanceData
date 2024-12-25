local super = require("ui.component.loopscrollrectitem")
local DmgControlAttrLoop = class("DmgControlAttrLoop", super)

function DmgControlAttrLoop:OnInit()
end

function DmgControlAttrLoop:OnReset()
end

function DmgControlAttrLoop:OnPointerClick()
  self.parent.uiView:AttrSelected(self.data_)
end

function DmgControlAttrLoop:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.unit.lab_content.TMPLab.text = self.data_
  self.unit.node_on:SetVisible(false)
  self.unit.node_off:SetVisible(true)
end

function DmgControlAttrLoop:Selected(isSelect)
  self.unit.node_on:SetVisible(isSelect)
  self.unit.node_off:SetVisible(not isSelect)
end

function DmgControlAttrLoop:OnUnInit()
end

return DmgControlAttrLoop
