local UI = Z.UI
local super = require("ui.ui_view_base")
local Common_recharge_popView = class("Common_recharge_popView", super)
local loopListView = require("ui.component.loop_list_view")
local common_reward_loop_list_item = require("ui.component.monthly_reward_card.monthly_reward_loop_list_reward_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Common_recharge_popView:ctor()
  self.uiBinder = nil
  super.ctor(self, "common_recharge_pop")
  self.viewData = nil
end

function Common_recharge_popView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, Z.SystemItem.DefaultCurrencyDisplay)
  self.uiBinder.lab_title.text = self.viewData.title
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_item, false)
  self.uiBinder.rimg_card.Ref.UIComp:SetVisible(false)
  if self.viewData.type == E.CommonRechargePopViewType.Monthly then
    self.uiBinder.rimg_card.Ref.UIComp:SetVisible(true)
    self.uiBinder.rimg_card.rimg_card:SetImage(self.viewData.rimgData.rimgPath)
    if self.viewData.rimgData.day then
      self.uiBinder.rimg_card.lab_day.text = self.viewData.rimgData.day
    end
  elseif self.viewData.type == E.CommonRechargePopViewType.Item then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_item, true)
    self.uiBinder.rimg_item:SetImage(self.viewData.rimgData.rimgPath)
  end
  self.uiBinder.lab_left_price.text = self.viewData.price
  self.uiBinder.lab_right_price.text = self.viewData.price
  local content = ""
  if self.viewData.content then
    content = Z.RichTextHelper.ApplyStyleTag(self.viewData.content, "recharge_pop_content")
  end
  if self.viewData.isShowSurpluseText then
    if self.viewData.content then
      content = content .. "\n" .. Z.RichTextHelper.ApplyStyleTag(Lang("RechargePopSurpluse"), "recharge_pop_surpluse")
    else
      content = Z.RichTextHelper.ApplyStyleTag(Lang("RechargePopSurpluse"), "recharge_pop_surpluse")
    end
  end
  self.uiBinder.lab_tips_01.text = content
  if self.viewData.isShowRefundText then
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview, true)
    local confirmDesc = ""
    confirmDesc = self.viewData.lab_content
    self.uiBinder.lab_content.text = confirmDesc
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview, false)
  end
  self:AddClick(self.uiBinder.btn_cancel, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    local paymentVm = Z.VMMgr.GetVM("payment")
    paymentVm:AsyncPayment(paymentVm:GetPayType(), self.viewData.productId)
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, common_reward_loop_list_item, "monthly_reward_card_item_award_tpl")
  if self.viewData.awardId then
    self.loopListView_:Init(Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(self.viewData.awardId))
  elseif self.viewData.awardTable then
    self.loopListView_:Init(self.viewData.awardTable)
  else
    self.loopListView_:Init({})
  end
end

function Common_recharge_popView:OnDeActive()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
end

function Common_recharge_popView:OnRefresh()
end

return Common_recharge_popView
