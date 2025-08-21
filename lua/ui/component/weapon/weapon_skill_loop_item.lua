local super = require("ui.component.loop_grid_view_item")
local WeaponSkillItem = class("WeaponSkillItem", super)

function WeaponSkillItem:ctor()
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
end

function WeaponSkillItem:OnInit()
end

function WeaponSkillItem:OnRefresh(data)
  self.skillId_ = data.skillId
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mark, not self.weaponSkillVm_:CheckSkillUnlock(self.skillId_))
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, not self.weaponSkillVm_:CheckSkillUnlock(self.skillId_))
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_assemble, self.weaponSkillVm_:CheckSkillEquip(self.skillId_))
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.skillId_)
  self.uiBinder.img_icon:SetImage(skillRow.Icon)
  local level = self.weaponVm_.GetShowSkillLevel(nil, self.skillId_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_grade, true)
  self.uiBinder.lab_grade.text = Lang("Level", {val = level})
end

function WeaponSkillItem:OnUnInit()
end

function WeaponSkillItem:OnSelected()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
  if self.IsSelected then
    self.parent.UIView:onSkillItemSelect(self.skillId_)
  end
end

return WeaponSkillItem
