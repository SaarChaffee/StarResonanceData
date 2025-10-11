local UI = Z.UI
local super = require("ui.ui_view_base")
local Shop_exchange_popupView = class("Shop_exchange_popupView", super)
local keyPad = require("ui.view.cont_num_keyboard_view")

function Shop_exchange_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "shop_exchange_popup")
end

function Shop_exchange_popupView:OnActive()
  self:initFunction()
  self:refreshItemData()
  self:InputNum(0)
  Z.EventMgr:Add(Z.ConstValue.Shop.NotifyBuyShopResult, self.buyCallFunc, self)
end

function Shop_exchange_popupView:OnDeActive()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Shop.NotifyBuyShopResult, self.buyCallFunc, self)
end

function Shop_exchange_popupView:refreshItemData()
  self.mallItemRow_ = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(self.viewData.itemId, true)
  if not self.mallItemRow_ then
    return
  end
  for itemId, count in pairs(self.mallItemRow_.Cost) do
    self.originalItemId_ = itemId
    self.originalItemCount_ = count
    break
  end
  local originalItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.originalItemId_, true)
  if not originalItemRow then
    return
  end
  self.targetItemId_ = self.mallItemRow_.ItemId
  local targetCountItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.targetItemId_, true)
  if not targetCountItemRow then
    return
  end
  local targetCount = self.mallItemRow_.Quantity
  local itemVm = Z.VMMgr.GetVM("items")
  self.uiBinder.rimg_original:SetImage(itemVm.GetItemIcon(self.originalItemId_))
  self.uiBinder.lab_original.text = string.zconcat("x", self.originalItemCount_)
  self.uiBinder.rimg_target:SetImage(itemVm.GetItemIcon(self.targetItemId_))
  self.uiBinder.lab_target.text = string.zconcat("x", targetCount)
  self.uiBinder.rimg_original_have:SetImage(itemVm.GetItemIcon(self.originalItemId_))
  self.uiBinder.rimg_target_exchange:SetImage(itemVm.GetItemIcon(self.targetItemId_))
  self.exchangeMax_ = -1
  for i = 1, #Z.Global.ShopBuyDoodSingleNumMax do
    if Z.Global.ShopBuyDoodSingleNumMax[i][1] == self.targetItemId_ then
      self.exchangeMax_ = Z.Global.ShopBuyDoodSingleNumMax[i][2]
      break
    end
  end
  self.uiBinder.lab_title.text = Lang("ShopExchangeTitleItemName", {
    name = targetCountItemRow.Name
  })
  self.uiBinder.lab_exchange.text = "="
  local itemsVM = Z.VMMgr.GetVM("items")
  self.originalHave_ = itemsVM.GetItemTotalCount(self.originalItemId_)
  self.uiBinder.lab_original_have.text = self.originalHave_
  self.uiBinder.lab_target_exchange.text = 0
  self.exchangeMax_ = math.min(self.exchangeMax_, self.originalHave_)
end

function Shop_exchange_popupView:initFunction()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.keypad_ = keyPad.new(self)
  self:AddClick(self.uiBinder.btn_reduce, function()
    self:InputNum(self.exchangeNum_ - 1)
  end)
  self:AddClick(self.uiBinder.btn_add, function()
    self:InputNum(self.exchangeNum_ + 1)
  end)
  self:AddClick(self.uiBinder.btn_num, function()
    self.keypad_:Active({
      max = self.exchangeMax_
    }, self.uiBinder.node_num_key)
  end)
  self:AddClick(self.uiBinder.btn_exchange, function()
    local buyList = {
      [self.mallItemRow_.Id] = {
        buyNum = self.exchangeNum_
      }
    }
    local shopVM = Z.VMMgr.GetVM("shop")
    shopVM.AsyncShopBuyItemList(buyList, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_get_other, function()
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.node_btn_get_ref, self.targetItemId_)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("shop_exchange_popup")
  end)
end

function Shop_exchange_popupView:buyCallFunc()
  Z.UIMgr:CloseView("shop_exchange_popup")
end

function Shop_exchange_popupView:InputNum(num)
  if num < 0 then
    num = 0
  end
  if self.exchangeMax_ == 0 then
    num = 0
  end
  if 0 < self.exchangeMax_ and num > self.exchangeMax_ then
    return
  end
  self.exchangeNum_ = num
  self.uiBinder.lab_num.text = self.exchangeNum_
  self.uiBinder.lab_target_exchange.text = self.exchangeNum_ * self.mallItemRow_.Quantity
  self.uiBinder.lab_original_have.text = self.originalHave_ - self.exchangeNum_
end

return Shop_exchange_popupView
