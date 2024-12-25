local super = require("ui.component.loopscrollrectitem")
local WeaponHeroSkillLoopItem = class("WeaponHeroSkillLoopItem", super)

function WeaponHeroSkillLoopItem:ctor()
end

function WeaponHeroSkillLoopItem:OnInit()
  self:AddClick(self.unit.img_bg.Btn, function()
    Z.EventMgr:Dispatch(Z.ConstValue.Hero.SkillSelect, self.index_, self.data_)
  end)
  self:Selected(false)
end

function WeaponHeroSkillLoopItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self:setUI()
end

function WeaponHeroSkillLoopItem:setUI()
  local config = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.data_)
  self.unit.lab_name:SetVisible(false)
  self.unit.lab_grade:SetVisible(false)
  if config then
    self.unit.img_icon.Img:SetImage(config.Icon)
  end
end

function WeaponHeroSkillLoopItem:Selected(isSelected)
  self.unit.img_on:SetVisible(isSelected)
end

function WeaponHeroSkillLoopItem:OnReset()
end

function WeaponHeroSkillLoopItem:OnUnInit()
end

return WeaponHeroSkillLoopItem
