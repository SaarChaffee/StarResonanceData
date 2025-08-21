local super = require("ui.component.loop_list_view_item")
local WeaponSkillSkinItem = class("WeaponSkillSkinItem", super)

function WeaponSkillSkinItem:ctor()
end

function WeaponSkillSkinItem:OnInit()
  self.weaponSkillVm_ = Z.VMMgr.GetVM("weapon_skill")
  self.weaponSkillSkinVm_ = Z.VMMgr.GetVM("weapon_skill_skin")
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function WeaponSkillSkinItem:OnRefresh(data)
  self.skillSkinId_ = data.Id
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  local unlock = self.weaponSkillSkinVm_:CheckSkillSkinUnlock(data.SkillId[1], data.Id, data.ProfessionId)
  if data.Id == data.SkillId[1] then
    self.uiBinder.lab_name.text = Lang("Default")
    self.uiBinder.Ref:SetVisible(self.uiBinder.reddot, false)
    unlock = true
  end
  if unlock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_not, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_not, true)
  end
  self.uiBinder.lab_name.text = data.Name
  self.uiBinder.rimg_skill:SetImage(data.Icon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_support, self.weaponSkillSkinVm_:CheckSkillSkinEquip(data.SkillId[1], data.Id, data.ProfessionId))
  local showRedot = true
  if not unlock and Z.ConditionHelper.CheckCondition(data.UnlockCondition) then
    for _, cost in ipairs(data.UnlockConsume) do
      if self.itemVm_.GetItemTotalCount(cost[1]) < cost[2] then
        showRedot = false
      end
    end
  else
    showRedot = false
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.reddot, showRedot)
end

function WeaponSkillSkinItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    self.parent.UIView:OnSelectSkillSkin(self.skillSkinId_)
  end
end

return WeaponSkillSkinItem
