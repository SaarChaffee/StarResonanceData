local UI = Z.UI
local super = require("ui.ui_view_base")
local ConnectingView = class("ConnectingView", super)

function ConnectingView:ctor()
  self.panel = nil
  super.ctor(self, "connecting")
end

function ConnectingView:OnActive()
  self.panel.lab_connecting:SetVisible(false)
  self.timerMgr:StartTimer(function()
    self.panel.lab_connecting:SetVisible(true)
  end, 0.5)
end

function ConnectingView:OnDeActive()
  self.panel.lab_connecting:SetVisible(false)
end

return ConnectingView
