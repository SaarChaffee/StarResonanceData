local super = require("ui.component.loopscrollrectitem")
local WeaponHeroStripLoopItem = class("WeaponHeroStripLoopItem", super)

function WeaponHeroStripLoopItem:ctor()
end

function WeaponHeroStripLoopItem:OnInit()
end

function WeaponHeroStripLoopItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self:setUI()
end

function WeaponHeroStripLoopItem:setUI()
  self.unit.lab_content.TMPLab.text = self.data_.text
end

function WeaponHeroStripLoopItem:Selected(isSelected)
end

function WeaponHeroStripLoopItem:OnReset()
end

function WeaponHeroStripLoopItem:OnUnInit()
end

return WeaponHeroStripLoopItem
