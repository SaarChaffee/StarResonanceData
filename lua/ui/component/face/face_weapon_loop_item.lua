local super = require("ui.component.loop_list_view_item")
local FaceWeaponLoopItem = class("FaceWeaponLoopItem", super)

function FaceWeaponLoopItem:OnInit()
end

function FaceWeaponLoopItem:OnRefresh(data)
  self.data_ = data
  self:initWeaponData()
end

function FaceWeaponLoopItem:initWeaponData()
  self.weaponId_ = self.data_.Id
  self.uiBinder.img_weap:SetImage(self.data_.Icon)
  self.uiBinder.lab_name.text = self.data_.Name
  local isSelect = self.parent.UIView.curWeaponTable_.Id == self.weaponId_
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelect)
end

function FaceWeaponLoopItem:OnSelected(isSelected)
  if isSelected then
    self.parent.UIView:OnSelectWeapon(self.weaponId_)
  end
end

function FaceWeaponLoopItem:OnUnInit()
end

return FaceWeaponLoopItem
