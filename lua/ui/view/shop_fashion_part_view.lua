local UI = Z.UI
local super = require("ui.view.shop_fashion_base_view")
local Shop_fashion_part_subView = class("Shop_fashion_part_subView", super)

function Shop_fashion_part_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.subCtor(self, "shop_fashion_part_sub", "shop/shop_fashion_part_sub", UI.ECacheLv.None, true)
end

function Shop_fashion_part_subView:OnActive()
  super.OnActive(self)
  self:InitShopList()
  self:InitThreeList()
  self:refreshBtnState()
end

function Shop_fashion_part_subView:OnDeActive()
  super.OnDeActive(self)
  self:ClearShopList()
  self:ClearThreeList()
end

function Shop_fashion_part_subView:OnAddMallItem()
  self:RefreshPlayerWear()
  self:RefreshThreeList()
  self.viewData.parentView:RefreshWearSetting()
end

function Shop_fashion_part_subView:refreshBtnState()
  self.uiBinder.lab_goto.text = Lang("Fashion")
  self.uiBinder.img_goto:SetImage("ui/atlas/item/c_tab_icon/com_icon_tab_10")
end

function Shop_fashion_part_subView:onClickFashion()
  if self.curSelectData_ and self.curSelectData_.fashoinId then
    self.fashionVM_.OpenFashionSystemView({
      FashionId = self.curSelectData_.fashoinId
    })
  else
    self.fashionVM_.OpenFashionSystemView()
  end
end

return Shop_fashion_part_subView
