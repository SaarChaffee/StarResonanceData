local super = require("ui.component.loopscrollrectitem")
local DmgControlMonsterLoop = class("DmgControlMonsterLoop", super)

function DmgControlMonsterLoop:OnInit()
end

function DmgControlMonsterLoop:OnReset()
end

function DmgControlMonsterLoop:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.unit.lab_content.TMPLab.text = self.data_
  self.unit.node_on:SetVisible(false)
  self.unit.node_off:SetVisible(true)
end

function DmgControlMonsterLoop:OnPointerClick()
  self.parent.uiView:MonsterSelected(self.data_)
end

function DmgControlMonsterLoop:Selected(isSelect)
  self.unit.node_on:SetVisible(isSelect)
  self.unit.node_off:SetVisible(not isSelect)
end

function DmgControlMonsterLoop:OnUnInit()
end

return DmgControlMonsterLoop
