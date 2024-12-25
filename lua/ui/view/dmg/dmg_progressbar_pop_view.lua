local UI = Z.UI
local super = require("ui.ui_subview_base")
local Dmg_progressbar_popView = class("Dmg_progressbar_popView", super)

function Dmg_progressbar_popView:ctor(parent)
  self.panel = nil
  super.ctor(self, "dmg_progressbar_popup", "dmg/dmg_progressbar_popup", UI.ECacheLv.None)
end

function Dmg_progressbar_popView:OnActive()
  local sliderValue = -1
  self:AddClick(self.panel.common_slider.sli_sens.Slider, function(value)
    sliderValue = value
    self.panel.common_slider.lab_value.TMPLab.text = value
  end)
  self:AddClick(self.panel.btn_cancel.btn.Btn, function()
    self:DeActive()
  end)
  self:AddClick(self.panel.btn_confirm.btn.Btn, function()
    if sliderValue ~= -1 then
      Z.EventMgr:Dispatch(Z.ConstValue.Damage.ControlRefreshColor, sliderValue)
    end
    self:DeActive()
  end)
  self:AddClick(self.panel.btn_popup_close.Btn, function()
    self:DeActive()
  end)
end

function Dmg_progressbar_popView:OnDeActive()
end

function Dmg_progressbar_popView:OnRefresh()
end

return Dmg_progressbar_popView
