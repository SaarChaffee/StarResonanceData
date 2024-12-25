local UI = Z.UI
local super = require("ui.ui_subview_base")
local Set_control_subView = class("Set_control_subView", super)
local SettingSliderItem = require("ui.component.setting.setting_slider_item")

function Set_control_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "set_control_sub", "set/set_control_sub", UI.ECacheLv.None)
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.settingHintPopup_ = require("ui.view.set_hint_popup_view").new()
  self.tipsOffset_ = Vector2.New(300, 200)
end

function Set_control_subView:OnActive()
  self.uiBinder.set_control_sub:SetSizeDelta(0, 0)
  self.lab_value_tab_ = {}
  self.lab_value_tab_[E.SettingID.HorizontalSensitivity] = self.uiBinder.cont_lens.cont_set_lens_horizontal.lab_value
  self.lab_value_tab_[E.SettingID.VerticalSensitivity] = self.uiBinder.cont_lens.cont_set_lens_vertical.lab_value
  self.global_config_tab_ = {}
  self.global_config_tab_[E.SettingID.HorizontalSensitivity] = Z.Global.CameraHorizontalRange
  self.global_config_tab_[E.SettingID.VerticalSensitivity] = Z.Global.CameraVerticalRange
  self:setBattle()
  self:setGliding()
  self:setVfx()
  self:setCamera()
  self:setLensCompensate()
end

function Set_control_subView:setBattle()
  local isOpen = self.settingVM_.Get(E.SettingID.LockOpen)
  self.uiBinder.cont_battle.cont_lock_open.cont_switch.switch.IsOn = isOpen
  local isCameraOpen = self.settingVM_.Get(E.SettingID.CameraLockFirst)
  self.settingVM_.Set(E.SettingID.CameraLockFirst, isCameraOpen)
  self.uiBinder.cont_battle.cont_lock_camera_open.cont_switch.switch.IsOn = isCameraOpen
  self.uiBinder.cont_battle.cont_lock_open.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.LockOpen, isOn)
    if not isOn then
      Z.LuaBridge.CancelLockTarget()
    end
    Z.EventMgr:Dispatch(Z.ConstValue.LockTargetOpenSettingChange, isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.IgnoreFlagChanged)
  end)
  self.uiBinder.cont_battle.cont_lock_camera_open.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.CameraLockFirst, isOn)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_lock_open.btn_tips, function()
    self:OpenMinTips(20001, self.uiBinder.cont_battle.cont_lock_open.btn_tips_trans)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_lock_camera_open.btn_tips, function()
    self:OpenMinTips(20005, self.uiBinder.cont_battle.cont_lock_camera_open.btn_tips_trans)
  end)
  local skillTagOpen = self.settingVM_.Get(E.SettingID.ShowSkillTag)
  self.uiBinder.cont_battle.cont_skill_tog.cont_switch.switch.IsOn = skillTagOpen
  self.uiBinder.cont_battle.cont_skill_tog.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.ShowSkillTag, isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.ShowSkillLableChange, isOn)
  end)
  local autoBattleOpen = self.settingVM_.Get(E.SettingID.AutoBattle)
  self.uiBinder.cont_battle.cont_auto_battle_tog.cont_switch.switch.IsOn = autoBattleOpen
  self.uiBinder.cont_battle.cont_auto_battle_tog.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.AutoBattle, isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.AutoBattleChange, isOn)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_auto_battle_tog.btn_tips, function()
    self:OpenMinTips(20003, self.uiBinder.cont_battle.cont_auto_battle_tog.btn_tips_trans)
  end)
  local cameraSeismicScreen = self.settingVM_.Get(E.SettingID.CameraSeismicScreen)
  self.uiBinder.cont_battle.cont_camera_seismic_screen.cont_switch.switch.IsOn = cameraSeismicScreen
  self.uiBinder.cont_battle.cont_camera_seismic_screen.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.CameraSeismicScreen, isOn)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_camera_seismic_screen.btn_tips, function()
    self:OpenMinTips(20006, self.uiBinder.cont_battle.cont_camera_seismic_screen.btn_tips_trans)
  end)
  local pulseScreen = self.settingVM_.Get(E.SettingID.PulseScreen)
  self.uiBinder.cont_battle.cont_pulse_screen.cont_switch.switch.IsOn = pulseScreen
  self.uiBinder.cont_battle.cont_pulse_screen.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.PulseScreen, isOn)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_pulse_screen.btn_tips, function()
    self:OpenMinTips(20007, self.uiBinder.cont_battle.cont_pulse_screen.btn_tips_trans)
  end)
end

function Set_control_subView:OpenMinTips(id, parent)
  local helpsysData = Z.DataMgr.Get("helpsys_data")
  if helpsysData == nil then
    return
  end
  local helpLibraryData = helpsysData:GetOtherDataById(id)
  if helpLibraryData == nil then
    return
  end
  local descContent = Z.TableMgr.DecodeLineBreak(table.concat(helpLibraryData.Content, "="))
  self:showTip(parent, descContent)
end

function Set_control_subView:getGlobalTable(type)
  local config = self.global_config_tab_[type]
  local tab = {}
  local max = 0
  if not config or #config == 0 then
    return tab, 1
  end
  for _, v in pairs(config) do
    max = max + 1
    tab[v[1]] = v[2]
  end
  return tab, max
end

function Set_control_subView:OnDeActive()
  Z.CommonTipsVM.CloseTipsTitleContent()
end

function Set_control_subView:OnRefresh()
end

function Set_control_subView:setCamera()
  local hSlider = self.uiBinder.cont_lens.cont_set_lens_horizontal.slider_progress
  local hLab = self.uiBinder.cont_lens.cont_set_lens_horizontal.lab_value
  self.hSlider_ = SettingSliderItem.new()
  self.hSlider_:Init(hSlider, hLab, E.SettingID.HorizontalSensitivity, 1, 6, nil, true)
  self.hSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetCameraRotateSpeed()
  end)
  local zSlider = self.uiBinder.cont_lens.cont_set_lens_vertical.slider_progress
  local zLab = self.uiBinder.cont_lens.cont_set_lens_vertical.lab_value
  self.zSlider_ = SettingSliderItem.new()
  self.zSlider_:Init(zSlider, zLab, E.SettingID.VerticalSensitivity, 1, 6, nil, true)
  self.zSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetCameraRotateSpeed()
  end)
end

function Set_control_subView:setLensCompensate()
  local trans_ = self.uiBinder.cont_lens_compensate.cont_camera_zoom_template
  self:initLensCompensateItem(E.SettingID.CameraTemplate, trans_, "CamZoomCorrection")
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_pitching_template
  self:initLensCompensateItem(E.SettingID.PitchAngleCorrection, trans_, "CamPitchAngleCorrection")
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_zoom_detection
  self:initLensCompensateItem(E.SettingID.BattleZoomCorrection, trans_, "CamBattleZoomCorrection")
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_pitching_detection
  self:initLensCompensateItem(E.SettingID.BattlePitchAngkeCorrection, trans_, "CamBattlePitchAngleCorrection")
end

function Set_control_subView:initLensCompensateItem(settingId_, trans_, langStr_)
  local isOpen = self.settingVM_.Get(settingId_)
  local switch_ = trans_.cont_switch
  switch_.switch.IsOn = isOpen == true
  switch_.switch:AddListener(function(isOn)
    local cameraConfigId_ = self.settingVM_.GetLensCompensateId(settingId_)
    if cameraConfigId_ then
      self.settingVM_.Set(settingId_, isOn)
      local switchNum_ = isOn == true and 1 or 0
      local opens_ = {switchNum_}
      local ids_ = {cameraConfigId_}
      Z.CameraMgr:SwitchCameraTemplate(opens_, ids_, 0)
    end
  end)
  local directionTip_Btn_ = trans_.btn_tips
  local directionTip_Trans_ = trans_.btn_tips_trans
  self:AddClick(directionTip_Btn_, function()
    self:showTip(directionTip_Trans_, Lang(langStr_))
  end)
end

function Set_control_subView:showTip(trans, content)
  Z.CommonTipsVM.ShowTipsTitleContent(trans, Lang("DialogDefaultTitle"), content, true)
end

function Set_control_subView:setGliding()
  local directionCtrl = self.uiBinder.cont_gliding.cont_lock_direction
  local directTogGroup = directionCtrl.togs_options
  local directionTog1 = directionCtrl.cont_option1.tog_option
  local directionTog2 = directionCtrl.cont_option2.tog_option
  local directionTip_Btn_ = directionCtrl.btn_tips
  local directionTip_Trans_ = directionCtrl.btn_tips_trans
  directionTog1.group = directTogGroup
  directionTog2.group = directTogGroup
  local diveCtrl = self.uiBinder.cont_gliding.cont_lock_dive
  local diveTogGroup = diveCtrl.togs_options
  local diveTog1 = diveCtrl.cont_option1.tog_option
  local diveTog2 = diveCtrl.cont_option2.tog_option
  local diveTip_Btn_ = diveCtrl.btn_tips
  local diveTip_Trans_ = diveCtrl.btn_tips_trans
  diveTog1.group = diveTogGroup
  diveTog2.group = diveTogGroup
  self:AddClick(directionTip_Btn_, function()
    self:showTip(directionTip_Trans_, Lang("GlideSetControlTips"))
  end)
  self:AddClick(diveTip_Btn_, function()
    self:showTip(diveTip_Trans_, Lang("GlideSetDiveTips"))
  end)
  local directionMode = self.settingVM_.Get(E.SettingID.GlideDirectionCtrl)
  local diveMode = self.settingVM_.Get(E.SettingID.GlideDiveCtrl)
  directionTog1:SetIsOnWithoutCallBack(directionMode == E.GlideDirectionCtrlMode.Axis)
  directionTog2:SetIsOnWithoutCallBack(directionMode == E.GlideDirectionCtrlMode.Camera)
  diveTog1:SetIsOnWithoutCallBack(directionMode == E.GlideDirectionCtrlMode.Axis and diveMode == E.GlideDiveCtrlMode.Up)
  diveTog2:SetIsOnWithoutCallBack(directionMode == E.GlideDirectionCtrlMode.Axis and diveMode == E.GlideDiveCtrlMode.Down)
  diveTog1.interactable = directionMode == E.GlideDirectionCtrlMode.Axis
  diveTog2.interactable = directionMode == E.GlideDirectionCtrlMode.Axis
  self.uiBinder.cont_gliding.Ref:SetVisible(diveCtrl.Ref, directionMode == E.GlideDirectionCtrlMode.Axis)
  self:AddAsyncListener(directionTog1, directionTog1.AddListener, function(isOn)
    if isOn then
      self.settingVM_.Set(E.SettingID.GlideDirectionCtrl, E.GlideDirectionCtrlMode.Axis)
      self.settingVM_.SetPlayerGlideAttr(E.GlideDirectionCtrlMode.Axis)
      diveTog1.interactable = true
      diveTog2.interactable = true
      self.uiBinder.cont_gliding.Ref:SetVisible(diveCtrl.Ref, true)
      local mode = self.settingVM_.Get(E.SettingID.GlideDiveCtrl)
      diveTog1:SetIsOnWithoutCallBack(mode == E.GlideDiveCtrlMode.Up)
      diveTog2:SetIsOnWithoutCallBack(mode == E.GlideDiveCtrlMode.Down)
    end
  end)
  self:AddAsyncListener(directionTog2, directionTog2.AddListener, function(isOn)
    if isOn then
      self.settingVM_.Set(E.SettingID.GlideDirectionCtrl, E.GlideDirectionCtrlMode.Camera)
      self.settingVM_.Set(E.SettingID.GlideDiveCtrl, E.GlideDiveCtrlMode.Up)
      self.settingVM_.SetPlayerGlideAttr(E.GlideDirectionCtrlMode.Camera, E.GlideDiveCtrlMode.Up)
      diveTog1.interactable = false
      diveTog2.interactable = false
      self.uiBinder.cont_gliding.Ref:SetVisible(diveCtrl.Ref, false)
      diveTog1:SetIsOnWithoutCallBack(false)
      diveTog2:SetIsOnWithoutCallBack(false)
    end
  end)
  self:AddAsyncListener(diveTog1, diveTog1.AddListener, function(isOn)
    if isOn then
      self.settingVM_.Set(E.SettingID.GlideDiveCtrl, E.GlideDiveCtrlMode.Up)
      self.settingVM_.SetPlayerGlideAttr(nil, E.GlideDiveCtrlMode.Up)
    end
  end)
  self:AddAsyncListener(diveTog2, diveTog2.AddListener, function(isOn)
    if isOn then
      self.settingVM_.Set(E.SettingID.GlideDiveCtrl, E.GlideDiveCtrlMode.Down)
      self.settingVM_.SetPlayerGlideAttr(nil, E.GlideDiveCtrlMode.Down)
    end
  end)
end

function Set_control_subView:setVfx()
  self:setVfxInternal(self.uiBinder.cont_vfx_level.cont_self, E.SettingID.EffSelf)
  self:setVfxInternal(self.uiBinder.cont_vfx_level.cont_enemy, E.SettingID.EffEnemy)
  self:setVfxInternal(self.uiBinder.cont_vfx_level.cont_team, E.SettingID.EffTeammate)
  self:setVfxInternal(self.uiBinder.cont_vfx_level.cont_other, E.SettingID.EffOther)
end

function Set_control_subView:setVfxInternal(container, settingId)
  local group = container.node_list
  local toggles = {
    [E.SettingVFXLevel.Off] = container.tog_option1,
    [E.SettingVFXLevel.Simple] = container.tog_option2,
    [E.SettingVFXLevel.Delicacy] = container.tog_option3,
    [E.SettingVFXLevel.Normal] = container.tog_option4
  }
  local level = self.settingVM_.GetVFXLevelEnum(settingId)
  self:setVfxLevelByIdx(settingId, level)
  for idx, tog in pairs(toggles) do
    tog:SetIsOnWithoutCallBack(false)
  end
  for idx, tog in pairs(toggles) do
    tog.group = group
    tog:AddListener(function(isOn)
      if isOn then
        if idx == 1 then
          Z.DialogViewDataMgr:OpenNormalDialog(Lang("CloseVfxConfirm"), function()
            self:setVfxLevelByIdx(settingId, idx)
            Z.DialogViewDataMgr:CloseDialogView()
          end, function()
            tog:SetIsOnWithoutCallBack(false)
            toggles[level]:SetIsOnWithoutCallBack(true)
            Z.DialogViewDataMgr:CloseDialogView()
          end)
        else
          self:setVfxLevelByIdx(settingId, idx)
        end
      end
    end)
  end
  for idx, tog in pairs(toggles) do
    tog:SetIsOnWithoutCallBack(idx == level)
  end
end

function Set_control_subView:setVfxLevelByIdx(settingId, idx)
  local level = self.settingVM_.ConvertEnumToVFXLevel(idx)
  self.settingVM_.Set(settingId, level)
  Z.LuaBridge.ImportEffectLimitGradeConf()
end

return Set_control_subView
