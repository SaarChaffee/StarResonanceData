local super = require("ui.ui_view_base")
local Monthly_reward_card_buy_windowView = class("Monthly_reward_card_buy_windowView", super)

function Monthly_reward_card_buy_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "monthly_reward_card_buy_window")
end

function Monthly_reward_card_buy_windowView:OnActive()
end

function Monthly_reward_card_buy_windowView:OnDeActive()
end

function Monthly_reward_card_buy_windowView:OnRefresh()
end

return Monthly_reward_card_buy_windowView
