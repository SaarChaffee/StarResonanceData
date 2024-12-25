local super = require("ui.component.loopscrollrectitem")
local DmgControlSkillLoop = class("DmgControlSkillLoop", super)

function DmgControlSkillLoop:OnInit()
end

function DmgControlSkillLoop:OnReset()
end

function DmgControlSkillLoop:OnPointerClick()
  self.parent.uiView:SkillSelected(self.data_)
end

function DmgControlSkillLoop:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.unit.lab_content.TMPLab.text = self.data_
  self.unit.node_on:SetVisible(false)
  self.unit.node_off:SetVisible(true)
end

function DmgControlSkillLoop:Selected(isSelect)
  self.unit.node_on:SetVisible(isSelect)
  self.unit.node_off:SetVisible(not isSelect)
end

function DmgControlSkillLoop:OnUnInit()
end

return DmgControlSkillLoop
