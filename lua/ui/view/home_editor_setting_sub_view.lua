local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_setting_subView = class("Home_editor_setting_subView", super)

function Home_editor_setting_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "home_editor_setting_sub", "home_editor/home_editor_setting_sub", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("home_editor")
  self.data_ = Z.DataMgr.Get("home_editor_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.dpbOptions_ = {
    Lang("Small"),
    Lang("Middle"),
    Lang("Big")
  }
end

function Home_editor_setting_subView:initBinders()
  self.operationNode_ = self.uiBinder.node_unfold
  self.lightSlider_ = self.uiBinder.slider_light
  self.moveSlider_ = self.uiBinder.slider_move
  self.heightSlider_ = self.uiBinder.silder_hight
  self.rotateSlider_ = self.uiBinder.silder_rotate
  self.aligningBtn_ = self.uiBinder.btn_ask_aligning
  self.settingBtn_ = self.uiBinder.btn_ask_setting
  self.viewRect_ = self.uiBinder.view_rect
  self.switch_ = self.uiBinder.switch
  self.adsorbSwitch_ = self.uiBinder.switch_adsorb
  self.adsorbBtn_ = self.uiBinder.btn_adsorb
  self.moveLab_ = self.uiBinder.lab_move
  self.hightLab_ = self.uiBinder.lab_hight
  self.rotateLab_ = self.uiBinder.lab_rotate
  self.lightLab_ = self.uiBinder.lab_light
  self.viewRect_:SetSizeDelta(0, 0)
end

function Home_editor_setting_subView:initBtn()
  self:AddClick(self.adsorbBtn_, function(value)
    self.helpsysVM_.OpenMinTips(500113, self.adsorbBtn_.transform)
  end)
  self:setSlider(self.moveSlider_, Z.GlobalHome.AlignMoveValue, self.moveLab_, E.EHomeAlignType.AlignMoveValue)
  self:AddClick(self.moveSlider_, function(value)
    self:setLab(self.moveLab_, value)
    self.data_.AlignMoveValue = value
    self.vm_.SetAlignUserData(Z.ConstValue.Home.BKR_HOME_ALIGN_MOVE, value)
  end)
  self:setSlider(self.heightSlider_, Z.GlobalHome.AlignHeightValue, self.hightLab_, E.EHomeAlignType.AlignHeightValue)
  self:AddClick(self.heightSlider_, function(value)
    self:setLab(self.hightLab_, value)
    self.data_.AlignHightValue = value
    self.vm_.SetAlignUserData(Z.ConstValue.Home.BKR_HOME_ALIGN_HIGHT, value)
  end)
  self:setSlider(self.rotateSlider_, Z.GlobalHome.AlignAnglesValue, self.rotateLab_, E.EHomeAlignType.AlignAnglesValue)
  self:AddClick(self.rotateSlider_, function(value)
    self:setLab(self.rotateLab_, value)
    self.data_.AlignRotateValue = value
    self.vm_.SetAlignUserData(Z.ConstValue.Home.BKR_HOME_ALIGN_ROTATE, value)
  end)
  self.lightSlider_.maxValue = 10
  self:AddClick(self.lightSlider_, function(value)
    self:setLab(self.lightLab_, value)
  end)
  self:refreshAlignSwitchState(self.vm_.GetAlignState())
  self:AddClick(self.switch_, function(isOpen)
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshAlignSwitchState, isOpen)
  end)
  self:refreshAbsorbSwitchState(self.vm_.GetAbsorbState())
  self:AddClick(self.adsorbSwitch_, function(isOpen)
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshAbsorbSwitchState, isOpen)
  end)
  self:AddClick(self.aligningBtn_, function()
    self.helpsysVM_.OpenMinTips(500112, self.aligningBtn_.transform)
  end)
  self:AddClick(self.settingBtn_, function()
    self.helpsysVM_.OpenMinTips(30033, self.settingBtn_.transform)
  end)
end

function Home_editor_setting_subView:setLab(lab, text)
  if lab then
    lab.text = math.floor(text)
  end
end

function Home_editor_setting_subView:setSlider(slider, array, lab, type)
  slider.minValue = array[1]
  slider.maxValue = array[3]
  slider.value = self.vm_.GetAlignUserData(type)
  self:setLab(lab, slider.value)
end

function Home_editor_setting_subView:OnActive()
  self:bindEvent()
  self:initBinders()
  self:initBtn()
end

function Home_editor_setting_subView:OnDeActive()
  self.helpsysVM_.CloseTitleContentBtn()
end

function Home_editor_setting_subView:OnRefresh()
end

function Home_editor_setting_subView:refreshAlignSwitchState(state)
  self.vm_.SetAlignState(state)
  self.uiBinder.Ref:SetVisible(self.operationNode_, state)
  self.switch_.IsOn = state
end

function Home_editor_setting_subView:refreshAbsorbSwitchState(state)
  self.vm_.SetAbsorbState(state)
  self.adsorbSwitch_.IsOn = state
end

function Home_editor_setting_subView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshAlignSwitchState, self.refreshAlignSwitchState, self)
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshAbsorbSwitchState, self.refreshAbsorbSwitchState, self)
end

return Home_editor_setting_subView
