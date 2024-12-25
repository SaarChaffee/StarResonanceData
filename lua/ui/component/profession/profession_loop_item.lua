local super = require("ui.component.loop_list_view_item")
local ProfessionLoopItem = class("ProfessionLoopItem", super)

function ProfessionLoopItem:OnInit()
  self.weaponVm_ = Z.VMMgr.GetVM("weapon")
end

function ProfessionLoopItem:OnRefresh(data)
  self.data_ = data
  self:initWeaponData()
end

function ProfessionLoopItem:initWeaponData()
  self.profession_ = self.data_.Id
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_support, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_level, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
  if self.parent.UIView.viewData.isFaceView then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_fitting, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_not, false)
    self.uiBinder.img_weap:SetImage(self.data_.Icon)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_not, not self.data_.unlock)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_fitting, self.data_.equip)
  end
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(self.profession_)
  if professionRow == nil then
    return
  end
  self.uiBinder.img_weap:SetImage(professionRow.Icon)
  self.uiBinder.lab_name.text = professionRow.Name
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
end

function ProfessionLoopItem:OnSelected(isSelected, isClick)
  if isClick and not self.parent.UIView:CheckCanChangeSelectWeapon() then
    Z.TipsVM.ShowTipsLang(100000)
    return
  end
  if isSelected then
    self.parent.UIView:OnSelectWeapon(self.profession_)
    self.uiBinder.group_info.alpha = 1
  else
    self.uiBinder.group_info.alpha = 0.7
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
end

function ProfessionLoopItem:OnUnInit()
end

return ProfessionLoopItem
