local UI = Z.UI
local super = require("ui.ui_view_base")
local House_buy_title_deed_subView = class("House_buy_title_deed_subView", super)
local loopListView = require("ui.component.loop_list_view")
local conditionItem = require("ui.component.house.house_condition_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function House_buy_title_deed_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_buy_title_deed_sub")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.commonVm_ = Z.VMMgr.GetVM("common")
  self.helpSysVM_ = Z.VMMgr.GetVM("helpsys")
  self.gotofuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function House_buy_title_deed_subView:initBinders()
  self.closeBtn_ = self.uiBinder.btn
  self.buyBtn_ = self.uiBinder.btn_buy
  self.requestBtn_ = self.uiBinder.btn_request
  self.labBtn_ = self.uiBinder.lab_btn
  self.goldIcon_ = self.uiBinder.rimg_gold
  self.houseIcon_ = self.uiBinder.rimg_icon
  self.goldCount_ = self.uiBinder.lab_digit
  self.unlockLoopList_ = self.uiBinder.scrollview
  self.titleLab_ = self.uiBinder.lab_title
  self.haveLab_ = self.uiBinder.lab_have
  self.goldNode_ = self.uiBinder.node_gold
  self.goldImg_ = self.uiBinder.img_gold
  self.askBtn_ = self.uiBinder.btn_ask
end

function House_buy_title_deed_subView:initData()
  self.allConditionMet_ = false
end

function House_buy_title_deed_subView:initUI()
  local isInviteUnlock = self.gotofuncVM_.CheckFuncCanUse(E.FunctionID.HomeLiveTogether, true)
  self.uiBinder.Ref:SetVisible(self.requestBtn_, isInviteUnlock)
  self.commonVm_.SetLabText(self.titleLab_, E.FunctionID.House)
  self.unlockLoopListView_ = loopListView.new(self, self.unlockLoopList_, conditionItem, "house_buy_conditions_item_tpl")
  self.unlockLoopListView_:Init({})
end

function House_buy_title_deed_subView:initBtns()
  self:AddAsyncClick(self.buyBtn_, function()
    if self:needBuyHouseCertificate() then
    else
      self.itemVm_.AsyncUseItemByConfigId(Z.GlobalHome.HouseCertificateID, self.cancelSource:CreateToken(), 1)
      self.houseVm_.CloseHouseBuyView()
    end
  end)
  self:AddClick(self.askBtn_, function()
    self.helpSysVM_.OpenFullScreenTipsView(40005)
  end)
  self:AddClick(self.requestBtn_, function()
    self.houseVm_.OpenHouseApplyView()
  end)
  self:AddClick(self.closeBtn_, function()
    self.houseVm_.CloseHouseBuyView()
  end)
end

function House_buy_title_deed_subView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:initBinders()
  self:initBtns()
  self:initData()
  self:initUI()
  Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, Z.GlobalHome.HouseCertificateID, self.OnRefresh, self)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, Z.SystemItem.HomeShopCurrencyDisplay)
end

function House_buy_title_deed_subView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.unlockLoopListView_ then
    self.unlockLoopListView_:UnInit()
    self.unlockLoopListView_ = nil
  end
  Z.ItemEventMgr.Remove(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemId, Z.GlobalHome.HouseCertificateID, self.OnRefresh, self)
  self.currencyItemList_:UnInit()
end

function House_buy_title_deed_subView:OnRefresh()
  self.labBtn_.text = Lang("HouseUseCertificate")
  self.houseIcon_:SetImage(self.itemVm_.GetItemIcon(Z.GlobalHome.HouseCertificateID))
  local needBuy = self:needBuyHouseCertificate()
  self.uiBinder.Ref:SetVisible(self.goldImg_, not needBuy)
  self.uiBinder.Ref:SetVisible(self.haveLab_, not needBuy)
  self.buyBtn_.IsDisabled = needBuy
end

function House_buy_title_deed_subView:needBuyHouseCertificate()
  return self.itemVm_.GetItemTotalCount(Z.GlobalHome.HouseCertificateID) == 0
end

function House_buy_title_deed_subView:refreshConditions()
  local conditionList = Z.ConditionHelper.GetConditionDescList(Z.GlobalHome.HouseCertificateCondition)
  self.unlockLoopListView_:RefreshListView(conditionList)
  self.allConditionMet_ = self:checkAllConditionMet(conditionList)
  self.buyBtn_.IsDisabled = not self.allConditionMet_
end

function House_buy_title_deed_subView:checkAllConditionMet(conditionList)
  for _, conditionDesc in pairs(conditionList) do
    if not conditionDesc.IsUnlock then
      return false
    end
  end
  return true
end

return House_buy_title_deed_subView
