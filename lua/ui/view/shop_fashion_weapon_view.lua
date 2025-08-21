local UI = Z.UI
local super = require("ui.view.shop_fashion_base_view")
local Shop_fashion_weapon_subView = class("Shop_fashion_weapon_subView", super)

function Shop_fashion_weapon_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.subCtor(self, "shop_fashion_part_sub", "shop/shop_fashion_part_sub", UI.ECacheLv.None, true)
end

function Shop_fashion_weapon_subView:OnActive()
  super.OnActive(self)
  self:InitShopList()
  self:InitThreeList()
  self:refreshBtnState()
end

function Shop_fashion_weapon_subView:OnDeActive()
  super.OnDeActive(self)
  self:ClearShopList()
  self:ClearThreeList()
end

function Shop_fashion_weapon_subView:OnAddMallItem()
  self:RefreshThreeList()
end

function Shop_fashion_weapon_subView:refreshBtnState()
  self.uiBinder.lab_goto.text = Lang("Fashion")
  self.uiBinder.img_goto:SetImage("ui/atlas/item/c_tab_icon/com_icon_tab_10")
end

function Shop_fashion_weapon_subView:RemoveWear(removeData)
  super.RemoveWear(self, removeData)
  self.viewData.parentView:ShowPlayerWeaponModel()
end

function Shop_fashion_weapon_subView:onClickReset()
  super.onClickReset(self)
  self.viewData.parentView:ShowPlayerWeaponModel()
end

function Shop_fashion_weapon_subView:onClickFashion()
  if self.curMallItemRow_ then
    local weaponId = self.curMallItemRow_.ItemId
    if self.curMallItemRow_.FashionList[1] and self.curMallItemRow_.FashionList[1] > 0 then
      weaponId = self.curMallItemRow_.FashionList[1]
    end
    self.fashionVM_.OpenFashionSystemView({FashionId = weaponId})
  else
    local fashionId = self.shopData_:GetShopBuyItemWeaponFashionId()
    if fashionId then
      self.fashionVM_.OpenFashionSystemView({FashionId = fashionId})
    else
      self.fashionVM_.OpenFashionSystemView({
        Region = E.FashionRegion.WeapoonSkin
      })
    end
  end
end

return Shop_fashion_weapon_subView
