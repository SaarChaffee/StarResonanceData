local UI = Z.UI
local super = require("ui.ui_subview_base")
local Home_editor_setting_subView = class("Home_editor_setting_subView", super)

function Home_editor_setting_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "home_editor_setting_sub", "home_editor/home_editor_setting_sub", UI.ECacheLv.None)
  self.vm_ = Z.VMMgr.GetVM("home")
  self.data_ = Z.DataMgr.Get("home_data")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
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
  self.moveLab_ = self.uiBinder.lab_move
  self.hightLab_ = self.uiBinder.lab_hight
  self.rotateLab_ = self.uiBinder.lab_rotate
  self.lightLab_ = self.uiBinder.lab_light
  self.viewRect_:SetSizeDelta(0, 0)
end

function Home_editor_setting_subView:initBtn()
  self:setSlider(self.moveSlider_, E.EHomeAlignType.AlignMoveValue, self.moveLab_)
  self:AddClick(self.moveSlider_, function(value)
    self:setLab(self.moveLab_, value)
    self.data_.AlignMoveValue = value
    self.vm_.SetAlignUserData(E.EHomeUserDataKey.BKR_HOME_ALIGN_MOVE, value)
  end)
  self:setSlider(self.heightSlider_, E.EHomeAlignType.AlignHeightValue, self.hightLab_)
  self:AddClick(self.heightSlider_, function(value)
    self:setLab(self.hightLab_, value)
    self.data_.AlignHightValue = value
    self.vm_.SetAlignUserData(E.EHomeUserDataKey.BKR_HOME_ALIGN_HIGHT, value)
  end)
  self:setSlider(self.rotateSlider_, E.EHomeAlignType.AlignAnglesValue, self.rotateLab_)
  self:AddClick(self.rotateSlider_, function(value)
    self:setLab(self.rotateLab_, value)
    self.data_.AlignRotateValue = value
    self.vm_.SetAlignUserData(E.EHomeUserDataKey.BKR_HOME_ALIGN_ROTATE, value)
  end)
  self.lightSlider_.maxValue = 10
  self:AddClick(self.lightSlider_, function(value)
    self:setLab(self.lightLab_, value)
  end)
  local state = self.vm_.GetAlignState()
  self:refreshGridSwitchState(state)
  self:AddClick(self.switch_, function(isOpen)
    Z.EventMgr:Dispatch(Z.ConstValue.Home.RefreshGridSwitchState, isOpen)
  end)
  self:AddClick(self.aligningBtn_, function()
    self.helpsysVM_.OpenMinTips(30032, self.aligningBtn_.transform)
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

function Home_editor_setting_subView:setSlider(slider, id, lab)
  local residentialAreaParameterRow = Z.TableMgr.GetTable("ResidentialAreaParameterMgr").GetRow(id)
  if residentialAreaParameterRow then
    slider.minValue = residentialAreaParameterRow.Value[1]
    slider.maxValue = residentialAreaParameterRow.Value[2]
    slider.value = self.vm_.GetAlignUserData(id)
    self:setLab(lab, slider.value)
  end
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

function Home_editor_setting_subView:refreshGridSwitchState(state)
  self.vm_.SetAlignState(state)
  self.uiBinder.Ref:SetVisible(self.operationNode_, state)
  self.switch_.IsOn = state
end

function Home_editor_setting_subView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshGridSwitchState, self.refreshGridSwitchState, self)
end

return Home_editor_setting_subView
