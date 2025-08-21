local UI = Z.UI
local super = require("ui.view.shop_fashion_base_view")
local Shop_fashion_face_subView = class("Shop_fashion_face_subView", super)

function Shop_fashion_face_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.subCtor(self, "shop_fashion_treasure_sub", "shop/shop_fashion_treasure_sub", UI.ECacheLv.None, true)
end

function Shop_fashion_face_subView:OnActive()
  super.OnActive(self)
  self:InitShopList()
  self:refreshBtnState()
  self:refreshShopList()
end

function Shop_fashion_face_subView:OnDeActive()
  super.OnDeActive(self)
  self:ClearShopList()
end

function Shop_fashion_face_subView:refreshBtnState()
  self.uiBinder.lab_goto.text = Lang("Face")
  self.uiBinder.img_goto:SetImage("ui/atlas/item/c_tab_icon/com_icon_tab_15")
end

function Shop_fashion_face_subView:refreshShopList()
  if not self.viewData.mallTableRow then
    return
  end
  local itemList = self:GetShopItemList(self.viewData.mallTableRow.Id)
  self.shopGridView_:RefreshListView(itemList, false)
  self:refreshItemSelect(itemList)
end

function Shop_fashion_face_subView:refreshItemSelect(items)
  self.shopGridView_:ClearAllSelect()
  if self.viewData.configId then
    local index = 1
    for i = 1, #items do
      if items[i].cfg and items[i].cfg.ItemId == self.viewData.configId then
        index = i
        break
      end
    end
    self.shopGridView_:MovePanelToItemIndex(index)
    self.shopGridView_:SetSelected(index)
    self.viewData.configId = nil
  elseif self.viewData.shopItemIndex then
    local index = self.viewData.shopItemIndex
    self:clearShopItemIndex()
    self.shopGridView_:MovePanelToItemIndex(index)
    self.shopGridView_:SetSelected(index)
  end
end

function Shop_fashion_face_subView:onClickFashion()
  local faceVM = Z.VMMgr.GetVM("face")
  faceVM.OpenEditView()
end

function Shop_fashion_face_subView:OnAddMallItem()
  self:RefreshPlayerWear()
  self:RefreshThreeList()
  self.viewData.parentView:RefreshWearSetting()
end

return Shop_fashion_face_subView
