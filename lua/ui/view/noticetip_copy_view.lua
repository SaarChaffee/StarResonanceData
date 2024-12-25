local UI = Z.UI
local dataMgr = require("ui.model.data_manager")
local super = require("ui.ui_view_base")
local Noticetip_copyView = class("Noticetip_copyView", super)

function Noticetip_copyView:ctor()
  self.uiBinder = nil
  super.ctor(self, "noticetip_copy")
  self.data_ = Z.DataMgr.Get("noticetip_data")
end

function Noticetip_copyView:OnActive()
  self.cancelToken_ = nil
end

function Noticetip_copyView:OnRefresh()
  self.timerMgr:StartTimer(function()
    if self.data_.CopyTextShowingState then
      self:showCopyTextTip()
      return
    end
    self:showCopyTip()
  end, 0)
end

function Noticetip_copyView:OnDeActive()
end

function Noticetip_copyView:showCopyTip()
  local msgItem = self.data_.Copy_tip
  local config = msgItem.config
  self.uiBinder.ZTxt_pop.text = msgItem.content
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_copy_tip, true)
  local repeatCount = config.RepeatPlay[1] or 1
  repeatCount = math.max(repeatCount, 1)
  local showInterval = (config.RepeatPlay[2] or 0) * 0.001
  local showOnceAction = function()
    self.uiBinder.anim:PlayOnce("node_copy_tip_start", 4)
    repeatCount = repeatCount - 1
    self.timerMgr:StartTimer(function()
      self.uiBinder.anim:PlayOnce("node_copy_tip_end", 4)
      if repeatCount <= 0 then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_copy_tip, false)
        Z.EventMgr:Dispatch(Z.ConstValue.TipsShowNextTopPop)
      end
    end, config.DurationTime)
  end
  self.timerMgr:StartTimer(function()
    showOnceAction()
    if 0 < repeatCount then
      self.timerMgr:StartTimer(showOnceAction, config.DurationTime + showInterval, repeatCount)
    end
  end, config.Delay)
end

function Noticetip_copyView:showCopyTextTip()
  local duration = tonumber(self.data_.copy_tip_text_delay)
  self.uiBinder.ZTxt_pop.text = self.data_.copy_tip_text
  self.uiBinder.Ref.UIComp:SetVisible(true)
  self.animator_:PlayOnce("node_copy_tip_start", 4)
  self.timerMgr:StartTimer(function()
    self.animator_:PlayOnce("node_copy_tip_end", 4)
    self.data_.CopyTextShowingState = false
  end, duration)
  self.timerMgr:StartTimer(function()
    self.uiBinder.Ref.UIComp:SetVisible(false)
  end, duration + 0.5)
end

return Noticetip_copyView
