local UI = Z.UI
local super = require("ui.ui_view_base")
local TipsBroadcastView = class("tips_broadcast_view", super)
local POS_MOVE_Y = 100

function TipsBroadcastView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_broadcast")
  self.broadcastVM_ = Z.VMMgr.GetVM("tips_broadcast")
  self.broadcastData_ = Z.DataMgr.Get("tips_broadcast_data")
  self.configMoveTime_ = Z.Global.BroadcastTipsMoveTime
end

function TipsBroadcastView:OnActive()
  self:BindEvents()
  self.curShowId_ = nil
end

function TipsBroadcastView:OnRefresh()
  self:showOneBroadcast()
end

function TipsBroadcastView:OnDeActive()
end

function TipsBroadcastView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Broadcast.AddData, self.showOneBroadcast, self)
  Z.EventMgr:Add(Z.ConstValue.Broadcast.CloseById, self.closeById, self)
end

function TipsBroadcastView:showOneBroadcast()
  local info = self.broadcastData_:GetBroadcast()
  if info == nil then
    return
  end
  self.curShowId_ = info.noticeId
  local fitScreenWidth = self.uiBinder.img_broadcast.sizeDelta.x
  local screenWidth = Z.UIRoot.CurCanvasSize.x
  local posOffset = math.min(-(fitScreenWidth - screenWidth) * 0.5, 0)
  self.uiBinder.img_broadcast:SetAnchorPosition(0, POS_MOVE_Y)
  self.uiBinder.img_broadcast_dotween:DoAnchorPosMove(Vector2.New(0, 0), 0.5)
  self.uiBinder.lab_broadcast.text = info.contentText
  self.uiBinder.lab_broadcast_ref:SetAnchorPosition(posOffset, 0)
  local moveWidth = screenWidth + self.uiBinder.lab_broadcast.preferredWidth
  self.uiBinder.lab_broadcast_dotween:DoAnchorPosMove(Vector2.New(-moveWidth + posOffset, 0), self.configMoveTime_)
  self:createCloseTimer()
end

function TipsBroadcastView:closeById(noticeId)
  if self.curShowId_ and self.curShowId_ == noticeId then
    Z.UIMgr:CloseView("tips_broadcast")
  end
end

function TipsBroadcastView:createCloseTimer()
  self:clearCloseTimer()
  self.closeTimer_ = self.timerMgr:StartTimer(function()
    self.curShowId_ = nil
    self.uiBinder.img_broadcast_dotween:DoAnchorPosMove(Vector2.New(0, POS_MOVE_Y), 0.5)
    self.animTimer_ = self.timerMgr:StartTimer(function()
      Z.UIMgr:CloseView("tips_broadcast")
    end, 1)
  end, self.configMoveTime_)
end

function TipsBroadcastView:clearCloseTimer()
  if self.closeTimer_ then
    self.closeTimer_:Stop()
    self.closeTimer_ = nil
  end
  if self.animTimer_ then
    self.animTimer_:Stop()
    self.animTimer_ = nil
  end
end

return TipsBroadcastView
