local UI = Z.UI
local super = require("ui.ui_view_base")
local Power_saving_windowView = class("Power_saving_windowView", super)
local logoImg = "ui/textures/login/login_logo"

function Power_saving_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "power_saving_window")
  self.powerSaveVM_ = Z.VMMgr.GetVM("power_save")
end

function Power_saving_windowView:OnActive()
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_bg, false)
  self.uiBinder.rimg_logo:SetImage(logoImg)
  self.uiBinder.input_detector:AddDetectedListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_bg, false)
    self.ViewConfig.IsFullScreen = false
    Z.UIMgr:UpdateCameraState()
    self.powerSaveVM_.ExitPowerSaveMode()
  end, true)
  self.uiBinder.input_detector:AddInactivityDetectedListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_bg, true)
    self.ViewConfig.IsFullScreen = true
    Z.UIMgr:UpdateCameraState()
    self.powerSaveVM_.EnterPowerSaveMode()
  end, true)
  self.uiBinder.input_detector:StartDetection(true)
end

function Power_saving_windowView:OnDeActive()
  self.uiBinder.input_detector:UnInit()
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_bg, false)
  self.powerSaveVM_.ExitPowerSaveMode()
  self.ViewConfig.IsFullScreen = false
end

function Power_saving_windowView:OnRefresh()
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_bg, false)
end

return Power_saving_windowView
