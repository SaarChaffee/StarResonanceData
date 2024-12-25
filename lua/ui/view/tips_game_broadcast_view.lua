local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_game_broadcastView = class("Tips_game_broadcastView", super)
local POS_MOVE_Y = 100

function Tips_game_broadcastView:ctor()
  self.uiBinder = nil
  super.ctor(self, "tips_game_broadcast")
  self.configMoveTime_ = Z.Global.BroadcastTipsMoveTime
end

function Tips_game_broadcastView:OnActive()
  self:BindEvents()
  self.curShowId_ = nil
  if Z.UIMgr:IsActive("tips_broadcast") then
    self.uiBinder.rect_panel:SetAnchorPosition(0, -50)
  else
    self.uiBinder.rect_panel:SetAnchorPosition(0, 0)
  end
end

function Tips_game_broadcastView:OnDeActive()
end

function Tips_game_broadcastView:OnRefresh()
  self:showOneBroadcast()
end

function Tips_game_broadcastView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.UIOpen, self.onOpenViewEvent, self)
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.onCloseViewEvent, self)
end

function Tips_game_broadcastView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UIOpen, self.onOpenViewEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.UIClose, self.onCloseViewEvent, self)
end

function Tips_game_broadcastView:onCloseViewEvent(viewConfigKey)
  if viewConfigKey == "tips_broadcast" then
    self.uiBinder.rect_panel:SetAnchorPosition(0, 0)
  end
end

function Tips_game_broadcastView:onOpenViewEvent(viewConfigKey)
  if viewConfigKey == "tips_broadcast" then
    self.uiBinder.rect_panel:SetAnchorPosition(0, -50)
  end
end

function Tips_game_broadcastView:showOneBroadcast()
  local fitScreenWidth = self.uiBinder.imgrect_broadcast.sizeDelta.x
  local screenWidth = Z.UIRoot.CurCanvasSize.x
  local posOffset = math.min(-(fitScreenWidth - screenWidth) * 0.5, 0)
  self.uiBinder.imgrect_broadcast:SetAnchorPosition(0, POS_MOVE_Y)
  self.uiBinder.imgdw_broadcast:DoAnchorPosMove(Vector2.New(0, 0), 0.5)
  self.uiBinder.lab_broadcast.text = self.viewData
  self.uiBinder.labrect_broadcast:SetAnchorPosition(posOffset, 0)
  local moveWidth = screenWidth + self.uiBinder.lab_broadcast.preferredWidth
  self.uiBinder.labdw_broadcast:DoAnchorPosMove(Vector2.New(-moveWidth + posOffset, 0), self.configMoveTime_)
  self:createCloseTimer()
end

function Tips_game_broadcastView:closeById(noticeId)
  if self.curShowId_ and self.curShowId_ == noticeId then
    Z.UIMgr:CloseView("tips_game_broadcast")
  end
end

function Tips_game_broadcastView:createCloseTimer()
  self:clearCloseTimer()
  self.closeTimer_ = self.timerMgr:StartTimer(function()
    self.curShowId_ = nil
    self.uiBinder.imgdw_broadcast:DoAnchorPosMove(Vector2.New(0, POS_MOVE_Y), 0.5)
    self.animTimer_ = self.timerMgr:StartTimer(function()
      Z.UIMgr:CloseView("tips_game_broadcast")
    end, 1)
  end, self.configMoveTime_)
end

function Tips_game_broadcastView:clearCloseTimer()
  if self.closeTimer_ then
    self.closeTimer_:Stop()
    self.closeTimer_ = nil
  end
  if self.animTimer_ then
    self.animTimer_:Stop()
    self.animTimer_ = nil
  end
end

return Tips_game_broadcastView
