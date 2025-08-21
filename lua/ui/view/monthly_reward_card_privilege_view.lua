local super = require("ui.ui_view_base")
local Monthly_reward_card_privilege_windowView = class("Monthly_reward_card_privilege_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local MonthlyRewardPrivilegesLabItem = require("ui.component.monthly_reward_card.monthly_reward_privileges_lab_item")

function Monthly_reward_card_privilege_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "monthly_reward_card_privilege_window")
  self.monthlyCardVM_ = Z.VMMgr.GetVM("monthly_reward_card")
  self.monthlyCardData_ = Z.DataMgr.Get("monthly_reward_card_data")
end

function Monthly_reward_card_privilege_windowView:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  self:initView()
  self:AddClick(self.uiBinder.btn_get, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self.uiBinder.anim:CoroPlayOnce("anim_monthly_reward_card_privilege_window_open", self.cancelSource:CreateToken(), function()
    self.uiBinder.animdotween:Restart(Z.DOTweenAnimType.Open)
  end, function(err)
    if err ~= ZUtil.ZCancelSource.CancelException then
      logError(err)
    end
  end)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
end

function Monthly_reward_card_privilege_windowView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Monthly_reward_card_privilege_windowView:OnRefresh()
end

function Monthly_reward_card_privilege_windowView:initView()
  self.loopListView_ = loopListView.new(self, self.uiBinder.loop_item, MonthlyRewardPrivilegesLabItem, "monthly_reward_card_privilege_tpl")
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  local labDataList = self.monthlyCardVM_:GetLoopLabShowText()
  if not labDataList or table.zcount(labDataList) == 0 then
    return
  end
  self.loopListView_:Init(labDataList)
end

return Monthly_reward_card_privilege_windowView
