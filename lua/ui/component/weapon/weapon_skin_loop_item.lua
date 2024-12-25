local super = require("ui.component.loopscrollrectitem")
local WeaponSkinLoopItem = class("WeaponSkinLoopItem", super)

function WeaponSkinLoopItem:ctor()
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
end

function WeaponSkinLoopItem:OnInit()
end

function WeaponSkinLoopItem:Refresh()
  self.index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(self.index)
  self.SkinId_ = data.skinCfg.Id
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self.uiBinder.img_icon:SetImage(data.skinCfg.Icon)
  local unLock = self.weaponVm_.CheckWeaponSkinUnlock(data.skinCfg.Id)
  if unLock then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, false)
    local equip = self.weaponVm_.CheckWeaponSkinEquip(data.weaponId, data.skinCfg.Id)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_present, equip)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_present, false)
  end
  self.uiBinder.Trans:SetScale(0.8, 0.8)
end

function WeaponSkinLoopItem:OnReset()
end

function WeaponSkinLoopItem:Selected(isSelected)
  if isSelected then
    self.parent.uiView:onWeaponSkillItemSelect(self.SkinId_, self.index)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function WeaponSkinLoopItem:OnUnInit()
end

return WeaponSkinLoopItem
