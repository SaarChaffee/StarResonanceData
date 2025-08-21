local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_pay_subView = class("Shop_pay_subView", super)
local LoopGridView = require("ui.component.loop_grid_view")
local chargeItem = require("ui.component.shop.charge_loop_item")

function Shop_pay_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "shop_pay_sub", "shop/shop_pay_sub", UI.ECacheLv.None, true)
end

function Shop_pay_subView:OnActive()
  self:onStartAnimShow()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.paymentVm = Z.VMMgr.GetVM("payment")
  self.paymentData = Z.DataMgr.Get("payment_data")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.paymentItemCount_ = self.itemsVm_.GetItemTotalCount(Z.SystemItem.ItemDiamond)
  self.loopGridView_ = LoopGridView.new(self, self.uiBinder.loop_all, chargeItem, "shop_pay", true)
  self.loopGridView_:Init({})
  self.productions = {}
  self:BindEvents()
  self:GetPaymentInfo()
end

function Shop_pay_subView:BindEvents()
  self.paymentData:SetPaymentResponseEvent(true)
  Z.EventMgr:Add(Z.ConstValue.Shop.PaymentResponse, self.GetPaymentInfo, self)
end

function Shop_pay_subView:GetPaymentInfo()
  Z.CoroUtil.create_coro_xpcall(function()
    self.shopVm_.AsyncGetFirstPayInfo(self.cancelSource:CreateToken())
    local currentPlatform = Z.SDKLogin.GetPlatform()
    if currentPlatform == E.LoginPlatformType.InnerPlatform then
      self:RefreshData()
    else
      local payFunctionData = Z.TableMgr.GetTable("PayFunctionTableMgr").GetDatas()
      local productIds = {}
      for _, value in pairs(payFunctionData) do
        local paymentRow = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(value.PaymentId[1])
        if paymentRow and paymentRow.IsSale == 1 and table.zcontains(paymentRow.Platform, currentPlatform) then
          table.insert(productIds, self.paymentData:GetProdctsName(paymentRow.Id))
        end
      end
      self.paymentVm:GetProductionInfos(productIds, function(productions)
        if productions then
          for _, value in pairs(productions) do
            self.productions[value.ID] = value
          end
        end
        self:RefreshData()
      end)
    end
  end)()
end

function Shop_pay_subView:RefreshData()
  local payFunctionData = Z.TableMgr.GetTable("PayFunctionTableMgr").GetDatas()
  local currentPlatform = Z.SDKLogin.GetPlatform()
  local showItemList = {}
  for _, value in pairs(payFunctionData) do
    local paymentRow = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(value.PaymentId[1])
    if paymentRow and paymentRow.IsSale == 1 and table.zcontains(paymentRow.Platform, currentPlatform) then
      local tmp = {}
      tmp.paymentRow = paymentRow
      tmp.payFunctionRow = value
      tmp.prodction = self.productions[self.paymentData:GetProdctsName(paymentRow.Id)] or {}
      table.insert(showItemList, tmp)
    end
  end
  table.sort(showItemList, function(a, b)
    return a.payFunctionRow.Sort < b.payFunctionRow.Sort
  end)
  self.loopGridView_:RefreshListView(showItemList)
end

function Shop_pay_subView:OnDeActive()
  self.loopGridView_:UnInit()
  self.loopGridView_ = nil
  self.paymentData:SetPaymentResponseEvent(false)
end

function Shop_pay_subView:OpenBuyPopup(data)
  self.selectPaymentData_ = data
  if Z.Global.PayConfirm then
    local award = self.shopVm_.GetShopItemAwardInfo(data.paymentRow.Id)
    local awardTable = {}
    for _, value in ipairs(award) do
      local data = {
        awardId = value.configId,
        awardNum = value.count
      }
      table.insert(awardTable, data)
    end
    local currencySymbol = self.shopVm_.GetShopItemCurrencySymbol()
    local data = {
      title = data.payFunctionRow.Name,
      rimgData = {
        rimgPath = data.payFunctionRow.Icon
      },
      type = E.CommonRechargePopViewType.Item,
      awardTable = awardTable,
      price = data.prodction.DisplayPrice or currencySymbol .. data.paymentRow.Price,
      content = data.payFunctionRow.Name,
      isShowSurpluseText = false,
      isShowRefundText = Z.Global.PayConfirmDes,
      productId = data.paymentRow.Id,
      lab_content = Lang("shop_pay_confirm_des")
    }
    Z.UIMgr:OpenView("common_recharge_pop", data)
  else
    self.paymentVm:AsyncPayment(self.paymentVm:GetPayType(), data.paymentRow.Id)
  end
end

function Shop_pay_subView:OnRefresh()
end

function Shop_pay_subView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Shop_pay_subView
