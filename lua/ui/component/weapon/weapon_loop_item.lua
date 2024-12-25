local super = require("ui.component.loopscrollrectitem")
local WeaponLoopItem = class("WeaponLoopItem", super)
local item = require("common.item")

function WeaponLoopItem:ctor()
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
end

function WeaponLoopItem:OnInit()
end

function WeaponLoopItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  self.weaponId_ = data.Id
  local weaponSysCfg = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.weaponId_)
  if weaponSysCfg == nil then
    return
  end
  self.uiBinder.img_weap:SetImage(weaponSysCfg.Icon)
  if data.unlock then
    local weapon = self.weaponVm_.GetWeaponInfo(self.weaponId_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_not, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_level, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_fitting, data.equip)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_equip, data.equip)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_support, not data.equip and data.support)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_support, not data.equip and data.support)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
    self.uiBinder.lab_level.text = Lang("WeaponProficiency") .. ":" .. weapon.level
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_not, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_level, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_fitting, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_equip, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_support, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_support, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
end

function WeaponLoopItem:OnReset()
end

function WeaponLoopItem:Selected(isSelected)
  if isSelected then
    self.parent.uiView:OnWeaponItemSelect(self.weaponId_)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
end

function WeaponLoopItem:OnUnInit()
end

return WeaponLoopItem
