local super = require("ui.ui_view_base")
local Monthly_reward_card_windowView = class("Monthly_reward_card_windowView", super)

function Monthly_reward_card_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "monthly_reward_card_window")
  self.monthlyCardVM_ = Z.VMMgr.GetVM("monthly_reward_card")
  self.monthlyCardData_ = Z.DataMgr.Get("monthly_reward_card_data")
end

function Monthly_reward_card_windowView:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  self:setViewInfo()
  self:AddAsyncClick(self.uiBinder.btn_get, function()
    local monthlyCardInfo = Z.ContainerMgr.CharSerialize.monthlyCard
    if monthlyCardInfo.items and table.zcount(monthlyCardInfo.items) > 0 then
      Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.ItemShow, "com_rewards_window", {
        itemList = monthlyCardInfo.items
      }, 1)
    end
    self.monthlyCardVM_:AsyncClickMonthlyCardTips(self.cancelSource:CreateToken())
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect)
end

function Monthly_reward_card_windowView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_effect)
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
end

function Monthly_reward_card_windowView:OnRefresh()
end

function Monthly_reward_card_windowView:setViewInfo()
  local lastMonthlyCardKey = self.monthlyCardVM_:GetActiveMonthlyCardKey()
  local data = self.monthlyCardData_:GetCardInfo(lastMonthlyCardKey)
  if not data then
    return
  end
  self.uiBinder.rimg_card:SetImage(data.NoteMonthCardConfig.Resources)
  self.uiBinder.lab_year.text = data.ItemConfig.Name
  local nowTime = math.floor(Z.TimeTools.Now() / 1000)
  local monthlyCardInfo = Z.ContainerMgr.CharSerialize.monthlyCard
  if not monthlyCardInfo then
    return
  end
  local difference = monthlyCardInfo.expireTime - nowTime
  self.uiBinder.lab_tips.text = Lang("MonthlyCardAwardTips", {
    val = monthlyCardInfo.tipsDay
  })
  if difference <= 0 then
    self.uiBinder.lab_time.text = Lang("Tips_TimeLimit_InValid")
  else
    local detailTime = difference
    self:setTime(monthlyCardInfo)
    self.timer_ = self.timerMgr:StartTimer(function()
      detailTime = detailTime - 1
      if detailTime <= 0 then
        self.uiBinder.lab_time.text = Lang("Tips_TimeLimit_InValid")
        self.timerMgr:StopTimer(self.timer)
        return
      end
      self:setTime(monthlyCardInfo)
    end, 1, difference)
  end
end

function Monthly_reward_card_windowView:setTime(monthlyCardInfo)
  if not monthlyCardInfo or not self.uiBinder then
    return
  end
  self.uiBinder.lab_time.text = Lang("MonthlyRemainingTime", {
    time = Z.TimeFormatTools.FormatToDHMS(monthlyCardInfo.expireTime - Z.TimeTools.Now() / 1000)
  })
end

function Monthly_reward_card_windowView:onStartAnimShow()
  self.uiBinder.anim:CoroPlayOnce("anim_monthly_reward_card_window_open", self.cancelSource:CreateToken(), function()
    self.uiBinder.anim_dotween:Restart(Z.DOTweenAnimType.Open)
  end, function(err)
    if err ~= ZUtil.ZCancelSource.CancelException then
      logError(err)
    end
  end)
end

return Monthly_reward_card_windowView
