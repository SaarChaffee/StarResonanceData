local super = require("ui.component.loop_grid_view_item")
local WeaponSkillSkinSkillItem = class("WeaponSkillSkinSkillItem", super)

function WeaponSkillSkinSkillItem:ctor()
end

function WeaponSkillSkinSkillItem:OnInit()
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponSkillSkinVm_ = Z.VMMgr.GetVM("weapon_skill_skin")
end

function WeaponSkillSkinSkillItem:OnRefresh(data)
  self.skillId_ = data.SkillId[1]
  local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(self.skillId_)
  if skillRow then
    self.uiBinder.lab_name.text = skillRow.Name
    self.uiBinder.img_icon:SetImage(skillRow.Icon)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, not self.weaponSkillVm_:CheckSkillUnlock(self.skillId_))
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  local skillSkinRedNodeName = self.weaponSkillSkinVm_:GetSkillSkinUnlockRedId(self.skillId_)
  Z.RedPointMgr.LoadRedDotItem(skillSkinRedNodeName, self.parent.UIView, self.uiBinder.reddot)
end

function WeaponSkillSkinSkillItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    self.parent.UIView:OnSelectSkill(self.skillId_)
  end
end

return WeaponSkillSkinSkillItem
