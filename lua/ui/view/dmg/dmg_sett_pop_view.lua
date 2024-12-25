local UI = Z.UI
local super = require("ui.ui_subview_base")
local Dmg_sett_popView = class("Dmg_sett_popView", super)
local dmgVm = Z.VMMgr.GetVM("damage")
local dmgData = Z.DataMgr.Get("damage_data")

function Dmg_sett_popView:ctor(parent)
  self.panel = nil
  super.ctor(self, "dmg_sett_popup", "dmg/dmg_sett_popup", UI.ECacheLv.None)
end

function Dmg_sett_popView:OnActive()
  local sliderValue = -1
  self:AddClick(self.panel.btn_popup_close.Btn, function()
    self:DeActive()
  end)
  self:AddClick(self.panel.n_common_btn_01.btn.Btn, function()
    self:DeActive()
  end)
  self:AddClick(self.panel.n_common_btn_02.btn.Btn, function()
    if sliderValue ~= -1 then
      Z.EventMgr:Dispatch(Z.ConstValue.Damage.ControlRefreshPanelColor, sliderValue)
    end
    self:DeActive()
  end)
  self:AddClick(self.panel.common_slider.sli_sens.Slider, function(value)
    sliderValue = value
    self.panel.common_slider.lab_value.TMPLab.text = value
  end)
end

function Dmg_sett_popView:OnDeActive()
end

function Dmg_sett_popView:BindEvents()
end

function Dmg_sett_popView:OnRefresh()
end

return Dmg_sett_popView
