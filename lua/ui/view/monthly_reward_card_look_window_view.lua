local super = require("ui.ui_view_base")
local Monthly_reward_card_look_windowView = class("Monthly_reward_card_look_windowView", super)

function Monthly_reward_card_look_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "monthly_reward_card_look_window")
  self.monthlyRewardCardData_ = Z.DataMgr.Get("monthly_reward_card_data")
end

function Monthly_reward_card_look_windowView:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self:initBtn()
  self.cardIndex_ = self.viewData
  self:refreshCardInfo()
end

function Monthly_reward_card_look_windowView:OnDeActive()
  self.cardId = nil
end

function Monthly_reward_card_look_windowView:OnRefresh()
  self.listDataCount_ = self.monthlyRewardCardData_:GetShowListDataCount()
end

function Monthly_reward_card_look_windowView:initBtn()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_share, function()
  end)
  self:AddClick(self.uiBinder.btn_left, function()
    self.cardIndex_ = self.cardIndex_ + 1 > self.listDataCount_ and self.cardIndex_ or self.cardIndex_ + 1
    self:refreshCardInfo()
  end)
  self:AddClick(self.uiBinder.btn_right, function()
    self.cardIndex_ = self.cardIndex_ - 1 <= 0 and 1 or self.cardIndex_ - 1
    self:refreshCardInfo()
  end)
  self:AddClick(self.uiBinder.btn_down, function()
  end)
end

function Monthly_reward_card_look_windowView:refreshCardInfo()
  local cardInfo = self.monthlyRewardCardData_:GetShowListDataByIndex(self.cardIndex_)
  if not cardInfo then
    return
  end
  self.uiBinder.lab_day.text = "31"
  self.uiBinder.lab_year.text = cardInfo.itemConfig.Name
  self.uiBinder.rimg_card:SetImage(Z.ConstValue.PersonalZone.PersonalCardBg .. cardInfo.NoteMonthCardConfig.Resources)
end

return Monthly_reward_card_look_windowView
