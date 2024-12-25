local UI = Z.UI
local super = require("ui.ui_view_base")
local Interrogate_windowView = class("Interrogate_windowView", super)

function Interrogate_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "interrogate_window")
  self.vm_ = Z.VMMgr.GetVM("interrogate_window")
end

function Interrogate_windowView:OnActive()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_up_1, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_up_2, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_interrogate1, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_interrogate2, false)
end

function Interrogate_windowView:OnRefresh()
  if self.viewData == 1 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_up_1, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.effect_interrogate1, true)
    Z.TipsVM.ShowTipsLang(5206002)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_up_2, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.effect_interrogate2, true)
    Z.TipsVM.ShowTipsLang(5206002)
  end
  self.timerMgr:StartTimer(function()
    self.vm_:CloseView()
  end, 1, 1)
end

return Interrogate_windowView
