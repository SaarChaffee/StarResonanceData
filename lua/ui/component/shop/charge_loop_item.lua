local super = require("ui.component.loop_grid_view_item")
local ChargeLoopItem = class("ChargeLoopItem", super)

function ChargeLoopItem:ctor()
end

function ChargeLoopItem:OnInit()
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.parent.UIView:AddAsyncClick(self.uiBinder.btn, function()
    self.parent.UIView:OpenBuyPopup(self.data_)
  end)
end

function ChargeLoopItem:OnUnInit()
end

function ChargeLoopItem:OnRefresh(data)
  self.data_ = data
  local isFirstCharge = self.shopVm_.CheckShopItemFirstCharge(self.data_.paymentRow.Id)
  if isFirstCharge then
    local firstAwards = self.awardPreviewVm_.GetAllAwardPreListByIds(self.data_.paymentRow.FirstChargeAwardID)
    if firstAwards and firstAwards[1] then
      self.uiBinder.Ref:SetVisible(self.uiBinder.layout_ast_topup, true)
      self.uiBinder.lab_lock_first.text = Lang("firstChargeAwards") .. firstAwards[1].awardNum
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(firstAwards[1].awardId)
      if itemRow then
        self.uiBinder.rimg_icon_first:SetImage(itemRow.Icon)
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.layout_ast_topup, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_ast_topup, false)
  end
  local isBouns = self.shopVm_.CheckShopItemExtraAwardCharge(self.data_.paymentRow.Id)
  if isBouns then
    local award = self.shopVm_.GetShopItemExtraAwardCharge(self.data_.paymentRow.Id)
    if award then
      self.uiBinder.Ref:SetVisible(self.uiBinder.layout_presented, true)
      self.uiBinder.lab_lock_add.text = Lang("chargeAddAwards") .. award.awardNum
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(award.awardId)
      if itemRow then
        self.uiBinder.rimg_icon_add:SetImage(itemRow.Icon)
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.layout_presented, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_presented, false)
  end
  self.uiBinder.lab_item_name_count.text = data.payFunctionRow.Name
  local currencySymbol = self.shopVm_.GetShopItemCurrencySymbol()
  self.uiBinder.lab_price.text = data.prodction.DisplayPrice or currencySymbol .. data.paymentRow.Price
  self.uiBinder.rimg_icon:SetImage(data.payFunctionRow.Icon)
end

function ChargeLoopItem:OnSelected(isSelected, isClick)
end

return ChargeLoopItem
