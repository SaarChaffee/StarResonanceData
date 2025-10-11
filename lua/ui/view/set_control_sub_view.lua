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
  self:initSettingUIDict()
  self:initDeviceToggle()
  self:setBattle()
  self:setGliding()
  if Z.GameContext.IsPC then
    self:setCamera()
    self:setHandleCamera()
    self.uiBinder.cont_lens_compensate.device_content.gameObject:SetActive(true)
    self.isHandle = Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick
    if not self.isHandle then
      self.uiBinder.cont_lens_compensate.tog_option_pc.isOn = true
    else
      self.uiBinder.cont_lens_compensate.tog_option_handle.isOn = true
    end
    self:refreshLensCompensate(false)
  else
    self:setPhoneCamera()
    self.uiBinder.cont_lens_compensate.device_content.gameObject:SetActive(false)
  end
  self:setLensCompensate()
  self.uiBinder.cont_battle.cont_mouse_restrictions.Ref.UIComp:SetVisible(Z.GameContext.IsPC)
  self.uiBinder.cont_lens.Go:SetActive(Z.GameContext.IsPC)
  self.uiBinder.cont_lens_handle.Go:SetActive(Z.GameContext.IsPC)
  self.uiBinder.cont_lens_phone.Go:SetActive(not Z.GameContext.IsPC)
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeViceTypeChange, self)
end

function Set_control_subView:onDeViceTypeChange()
end

function Set_control_subView:initDeviceToggle()
  if Z.GameContext.IsPC then
    self:AddClick(self.uiBinder.cont_lens_compensate.tog_option_pc, function(isOn)
      self.isHandle = not isOn
      self:refreshLensCompensate(false)
    end)
    self:AddClick(self.uiBinder.cont_lens_compensate.tog_option_handle, function(isOn)
      self.isHandle = isOn
      self:refreshLensCompensate(false)
    end)
  end
  self:AddClick(self.uiBinder.cont_lens_compensate.btn_reset, function()
    self:OnResetBtnClick()
  end)
end

function Set_control_subView:OnResetBtnClick()
  self:refreshLensCompensate(true)
end

function Set_control_subView:initSettingUIDict()
  self.setting2UIDict_ = {}
  self.setting2UIDict_[E.SettingID.CameraLockFirst] = self.uiBinder.cont_battle.cont_lock_open
  self.setting2UIDict_[E.SettingID.ShowSkillTag] = self.uiBinder.cont_battle.cont_skill_tog
  self.setting2UIDict_[E.SettingID.AutoBattle] = self.uiBinder.cont_battle.cont_auto_battle_tog
  self.setting2UIDict_[E.SettingID.LockOpen] = self.uiBinder.cont_battle.cont_lock_camera_open
  self.setting2UIDict_[E.SettingID.CameraSeismicScreen] = self.uiBinder.cont_battle.cont_camera_seismic_screen
  self.setting2UIDict_[E.SettingID.PulseScreen] = self.uiBinder.cont_battle.cont_pulse_screen
  self.setting2UIDict_[E.SettingID.SkillController] = self.uiBinder.cont_battle.cont_skill_roulette
  self.setting2UIDict_[E.SettingID.SkillControllerPcUp] = self.uiBinder.cont_battle.cont_skill_press
  self.setting2UIDict_[E.SettingID.CameraMove] = self.uiBinder.cont_battle.cont_camera_move
  self.setting2UIDict_[E.SettingID.RemoveMouseRestrictions] = self.uiBinder.cont_battle.cont_mouse_restrictions
  self.setting2UIDict_[E.SettingID.GlideDirectionCtrl] = self.uiBinder.cont_gliding.cont_lock_direction
  self.setting2UIDict_[E.SettingID.GlideDiveCtrl] = self.uiBinder.cont_gliding.cont_lock_dive
  self.setting2UIDict_[E.SettingID.HorizontalSensitivity] = self.uiBinder.cont_lens.cont_set_lens_horizontal
  self.setting2UIDict_[E.SettingID.VerticalSensitivity] = self.uiBinder.cont_lens.cont_set_lens_vertical
  self.setting2UIDict_[E.SettingID.CameraTemplate] = self.uiBinder.cont_lens_compensate.cont_camera_zoom_template
  self.setting2UIDict_[E.SettingID.PitchAngleCorrection] = self.uiBinder.cont_lens_compensate.cont_camera_pitching_template
  self.setting2UIDict_[E.SettingID.BattleZoomCorrection] = self.uiBinder.cont_lens_compensate.cont_camera_zoom_detection
  self.setting2UIDict_[E.SettingID.BattlePitchAngkeCorrection] = self.uiBinder.cont_lens_compensate.cont_camera_pitching_detection
  self.setting2UIDict_[E.SettingID.CameraTranslationRotate] = self.uiBinder.cont_lens_compensate.cont_camera_translation_rotate
  self.setting2UIDict_[E.SettingID.CameraReleasingSkill] = self.uiBinder.cont_lens_compensate.cont_camera_releasing_skill
  self.setting2UIDict_[E.SettingID.CameraReleasingSkillAngle] = self.uiBinder.cont_lens_compensate.cont_camera_releasingskillangle
  self.setting2UIDict_[E.SettingID.CameraSeek] = self.uiBinder.cont_lens_compensate.cont_camera_seek
  self.setting2UIDict_[E.SettingID.CameraMelee] = self.uiBinder.cont_lens_compensate.cont_camera_melee
  self.setting2UIDict_[E.SettingID.HorizontalSensitivity] = self.uiBinder.cont_lens_phone.cont_set_lens_horizontal
  self.setting2UIDict_[E.SettingID.VerticalSensitivity] = self.uiBinder.cont_lens_phone.cont_set_lens_vertical
  self.setting2UIDict_[E.SettingID.HorizontalSensitivityHandle] = self.uiBinder.cont_lens_handle.cont_set_lens_horizontal
  self.setting2UIDict_[E.SettingID.VerticalSensitivityHandle] = self.uiBinder.cont_lens_handle.cont_set_lens_vertical
  self.setting2UIDict_[E.SettingID.MouseSpeedHandle] = self.uiBinder.cont_lens_handle.cont_mouse_speed
end

function Set_control_subView:refreshAllSettingVisible()
  local settingVisibleData = Z.DataMgr.Get("setting_visible_data")
  for k, v in pairs(self.setting2UIDict_) do
    local show = settingVisibleData:CheckVisible(k)
    if not show then
      v.Ref.UIComp:SetVisible(show)
    end
  end
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
  local equipWeapon = Z.VMMgr.GetVM("profession").CheckProfessionEquipWeapon()
  self.uiBinder.cont_battle.cont_auto_battle_tog.cont_switch.switch.IsOn = autoBattleOpen and equipWeapon
  self.uiBinder.cont_battle.cont_auto_battle_tog.cont_switch.switch:AddListener(function(isOn)
    if isOn and not equipWeapon then
      Z.TipsVM.ShowTips(150009)
      self.uiBinder.cont_battle.cont_auto_battle_tog.cont_switch.switch.IsOn = false
      return
    end
    self.settingVM_.Set(E.SettingID.AutoBattle, isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.AutoBattleChange, isOn)
    if Z.EntityMgr.PlayerEnt ~= nil then
      if Z.IsPCUI then
        Z.EntityMgr.PlayerEnt:SetLuaAttr(Z.LocalAttr.EAutoBattleSwitch, isOn)
      elseif isOn == false then
        Panda.ZGame.ZBattleUtils.StopPlayerAIBattle()
      end
    end
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_auto_battle_tog.btn_tips, function()
    local tipsId = Z.IsPCUI and 20008 or 20003
    self:OpenMinTips(tipsId, self.uiBinder.cont_battle.cont_auto_battle_tog.btn_tips_trans)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_auto_battle_set.btn_tips, function()
    self:OpenMinTips(20009, self.uiBinder.cont_battle.cont_auto_battle_tog.btn_tips_trans)
  end)
  self:AddAsyncClick(self.uiBinder.cont_battle.cont_auto_battle_set.btn_set, function()
    local fighterbtnVm = Z.VMMgr.GetVM("fighterbtns")
    Z.UIMgr:GotoMainView()
    fighterbtnVm:OpenSetAutoBattleSlotView()
  end)
  local skillFreeUseOpen = self.settingVM_.Get(E.SettingID.SkillController)
  self.uiBinder.cont_battle.cont_skill_roulette.cont_switch.switch.IsOn = skillFreeUseOpen
  self.uiBinder.cont_battle.cont_skill_roulette.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.SkillController, isOn)
    self.uiBinder.cont_battle.cont_skill_press.Ref.UIComp:SetVisible(isOn and Z.IsPCUI)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_skill_roulette.btn_tips, function()
    local tipsId = Z.IsPCUI and 20013 or 20012
    self:OpenMinTips(tipsId, self.uiBinder.cont_battle.cont_skill_roulette.btn_tips_trans)
  end)
  self.uiBinder.cont_battle.cont_skill_press.Ref.UIComp:SetVisible(skillFreeUseOpen and Z.IsPCUI)
  local skillPressCtrl = self.uiBinder.cont_battle.cont_skill_press
  local skillPressionTog1 = skillPressCtrl.cont_option1.tog_option
  local skillPressionTog2 = skillPressCtrl.cont_option2.tog_option
  skillPressionTog1.group = skillPressCtrl.togs_options
  skillPressionTog2.group = skillPressCtrl.togs_options
  local SkillControllerPcUp = self.settingVM_.Get(E.SettingID.SkillControllerPcUp)
  skillPressionTog1:SetIsOnWithoutCallBack(SkillControllerPcUp == E.FreeSkillUseMode.Click)
  skillPressionTog2:SetIsOnWithoutCallBack(SkillControllerPcUp == E.FreeSkillUseMode.Release)
  self:AddClick(self.uiBinder.cont_battle.cont_skill_press.btn_tips, function()
    local tipsId = 20022
    self:OpenMinTips(tipsId, self.uiBinder.cont_battle.cont_skill_press.btn_tips_trans)
  end)
  self:AddAsyncListener(skillPressionTog1, skillPressionTog1.AddListener, function(isOn)
    if isOn then
      self.settingVM_.Set(E.SettingID.SkillControllerPcUp, E.FreeSkillUseMode.Click)
    end
  end)
  self:AddAsyncListener(skillPressionTog2, skillPressionTog2.AddListener, function(isOn)
    if isOn then
      self.settingVM_.Set(E.SettingID.SkillControllerPcUp, E.FreeSkillUseMode.Release)
    end
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
  local cameraMove = self.settingVM_.Get(E.SettingID.CameraMove)
  self.uiBinder.cont_battle.cont_camera_move.cont_switch.switch.IsOn = cameraMove
  self.uiBinder.cont_battle.cont_camera_move.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.CameraMove, isOn)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_camera_move.btn_tips, function()
    self:OpenMinTips(20014, self.uiBinder.cont_battle.cont_camera_move.btn_tips_trans)
  end)
  local removeMouseRestrictions = self.settingVM_.Get(E.SettingID.RemoveMouseRestrictions)
  self.uiBinder.cont_battle.cont_mouse_restrictions.cont_switch.switch.IsOn = removeMouseRestrictions
  self.uiBinder.cont_battle.cont_mouse_restrictions.cont_switch.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.RemoveMouseRestrictions, isOn)
  end)
  self:AddClick(self.uiBinder.cont_battle.cont_mouse_restrictions.btn_tips, function()
    self:OpenMinTips(20020, self.uiBinder.cont_battle.cont_mouse_restrictions.btn_tips_trans)
  end)
  if Z.GameContext.IsPC then
    self.uiBinder.cont_battle.cont_camera_inertia.Ref.UIComp:SetVisible(false)
  else
    self.uiBinder.cont_battle.cont_camera_inertia.Ref.UIComp:SetVisible(true)
  end
  local isOpen = self.settingVM_.Get(E.SettingID.CameraInertia)
  local switch_ = self.uiBinder.cont_battle.cont_camera_inertia.cont_switch
  switch_.switch.IsOn = isOpen == true
  switch_.switch:AddListener(function(isOn)
    self.settingVM_.Set(E.SettingID.CameraInertia, isOn)
  end)
  local directionTip_Btn_ = self.uiBinder.cont_battle.cont_camera_inertia.btn_tips
  local directionTip_Trans_ = self.uiBinder.cont_battle.cont_camera_inertia.btn_tips_trans
  self:AddClick(directionTip_Btn_, function()
    self:OpenMinTips(20023, directionTip_Trans_)
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
  Z.EventMgr:Remove(Z.ConstValue.Device.DeviceTypeChange, self.onDeViceTypeChange, self)
end

function Set_control_subView:OnRefresh()
  self:refreshAllSettingVisible()
end

function Set_control_subView:setCamera()
  local hSlider = self.uiBinder.cont_lens.cont_set_lens_horizontal.slider_progress
  local hLab = self.uiBinder.cont_lens.cont_set_lens_horizontal.lab_value
  self.hSlider_ = SettingSliderItem.new()
  self.hSlider_:Init(hSlider, hLab, E.SettingID.HorizontalSensitivity, 1, table.zcount(Z.Global.CameraHorizontalRange), nil, true)
  self.hSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetCameraRotateSpeed()
  end)
  local zSlider = self.uiBinder.cont_lens.cont_set_lens_vertical.slider_progress
  local zLab = self.uiBinder.cont_lens.cont_set_lens_vertical.lab_value
  self.zSlider_ = SettingSliderItem.new()
  self.zSlider_:Init(zSlider, zLab, E.SettingID.VerticalSensitivity, 1, table.zcount(Z.Global.CameraVerticalRange), nil, true)
  self.zSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetCameraRotateSpeed()
  end)
end

function Set_control_subView:setHandleCamera()
  local hSlider = self.uiBinder.cont_lens_handle.cont_set_lens_horizontal.slider_progress
  local hLab = self.uiBinder.cont_lens_handle.cont_set_lens_horizontal.lab_value
  self.hHandleSlider_ = SettingSliderItem.new()
  self.hHandleSlider_:Init(hSlider, hLab, E.SettingID.HorizontalSensitivityHandle, 1, table.zcount(Z.Global.HandleCamHorizontalRange), nil, true)
  self.hHandleSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetHandleCameraRotateSpeed()
  end)
  local zSlider = self.uiBinder.cont_lens_handle.cont_set_lens_vertical.slider_progress
  local zLab = self.uiBinder.cont_lens_handle.cont_set_lens_vertical.lab_value
  self.zHandleSlider_ = SettingSliderItem.new()
  self.zHandleSlider_:Init(zSlider, zLab, E.SettingID.VerticalSensitivityHandle, 1, table.zcount(Z.Global.HandleCamVerticalRange), nil, true)
  self.zHandleSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetHandleCameraRotateSpeed()
  end)
  local mouseSlider = self.uiBinder.cont_lens_handle.cont_mouse_speed.slider_progress
  local mouseLab = self.uiBinder.cont_lens_handle.cont_mouse_speed.lab_value
  self.handleSpeedSlider_ = SettingSliderItem.new()
  self.handleSpeedSlider_:Init(mouseSlider, mouseLab, E.SettingID.MouseSpeedHandle, 1, table.zcount(Z.Global.HandleMouseSpeedRange), nil, true)
  self.handleSpeedSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetHandleMouseSpeed()
  end)
end

function Set_control_subView:setPhoneCamera()
  local hSlider = self.uiBinder.cont_lens_phone.cont_set_lens_horizontal.slider_progress
  local hLab = self.uiBinder.cont_lens_phone.cont_set_lens_horizontal.lab_value
  self.hSlider_ = SettingSliderItem.new()
  self.hSlider_:Init(hSlider, hLab, E.SettingID.HorizontalSensitivity, 1, table.zcount(Z.Global.CameraHorizontalRange), nil, true)
  self.hSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetCameraRotateSpeed()
  end)
  local zSlider = self.uiBinder.cont_lens_phone.cont_set_lens_vertical.slider_progress
  local zLab = self.uiBinder.cont_lens_phone.cont_set_lens_vertical.lab_value
  self.zSlider_ = SettingSliderItem.new()
  self.zSlider_:Init(zSlider, zLab, E.SettingID.VerticalSensitivity, 1, table.zcount(Z.Global.CameraVerticalRange), nil, true)
  self.zSlider_:SetExOnEndDrag(function()
    self.settingVM_.SetCameraRotateSpeed()
  end)
end

function Set_control_subView:refreshLensCompensate(useDefalut)
  local trans_ = self.uiBinder.cont_lens_compensate.cont_camera_zoom_template
  self:refreshLensCompensateItem(E.SettingID.CameraTemplate, trans_, useDefalut)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_pitching_template
  self:refreshLensCompensateItem(E.SettingID.PitchAngleCorrection, trans_, useDefalut)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_zoom_detection
  self:refreshLensCompensateItem(E.SettingID.BattleZoomCorrection, trans_, useDefalut)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_pitching_detection
  self:refreshLensCompensateItem(E.SettingID.BattlePitchAngkeCorrection, trans_, useDefalut)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_translation_rotate
  self:refreshLensCompensateItem(E.SettingID.CameraTranslationRotate, trans_, useDefalut)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_releasing_skill
  self:refreshLensCompensateItem(E.SettingID.CameraReleasingSkill, trans_, useDefalut)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_releasingskillangle
  self:refreshLensCompensateItem(E.SettingID.CameraReleasingSkillAngle, trans_, useDefalut)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_seek
  self:refreshLensCompensateItem(E.SettingID.CameraSeek, trans_, useDefalut)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_melee
  self:refreshLensCompensateItem(E.SettingID.CameraMelee, trans_, useDefalut)
end

function Set_control_subView:refreshLensCompensateItem(settingId_, trans_, useDefalut)
  local settingMap = self.settingVM_.Get(settingId_)
  if useDefalut then
    settingMap = self.settingVM_.GetDefaultCompensateTable(settingId_)
  end
  local switch_ = trans_.cont_switch
  local isOpen
  if Z.GameContext.IsPC then
    if not self.isHandle then
      isOpen = settingMap[1] == 1
    else
      isOpen = settingMap[2] == 1
    end
  else
    isOpen = settingMap[3] == 1
  end
  switch_.switch:SetIsOnWithoutNotify(isOpen)
  local cameraConfigIds_ = self.settingVM_.GetLensCompensateId(settingId_)
  if cameraConfigIds_ then
    local settingMap = self.settingVM_.Get(settingId_)
    if Z.GameContext.IsPC then
      if not self.isHandle then
        settingMap[1] = isOpen and 1 or 0
      else
        settingMap[2] = isOpen and 1 or 0
      end
    else
      settingMap[3] = isOpen and 1 or 0
    end
    self.settingVM_.Set(settingId_, settingMap)
    local switchNum_ = isOpen == true and 1 or 0
    local opens_ = {}
    local ids_ = cameraConfigIds_
    for k, v in pairs(ids_) do
      table.insert(opens_, switchNum_)
    end
    Z.CameraMgr:SwitchCameraTemplate(opens_, ids_, 0)
  end
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
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_translation_rotate
  self:initLensCompensateItem(E.SettingID.CameraTranslationRotate, trans_, 20015)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_releasing_skill
  self:initLensCompensateItem(E.SettingID.CameraReleasingSkill, trans_, 20016)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_releasingskillangle
  self:initLensCompensateItem(E.SettingID.CameraReleasingSkillAngle, trans_, 20017)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_seek
  self:initLensCompensateItem(E.SettingID.CameraSeek, trans_, 20018)
  trans_ = self.uiBinder.cont_lens_compensate.cont_camera_melee
  self:initLensCompensateItem(E.SettingID.CameraMelee, trans_, 20019)
end

function Set_control_subView:initLensCompensateItem(settingId_, trans_, langStr_)
  local settingMap = self.settingVM_.Get(settingId_)
  local switch_ = trans_.cont_switch
  local isOpen
  if Z.GameContext.IsPC then
    if not self.isHandle then
      isOpen = settingMap[1] == 1
    else
      isOpen = settingMap[2] == 1
    end
  else
    isOpen = settingMap[3] == 1
  end
  switch_.switch.IsOn = isOpen == true
  switch_.switch:AddListener(function(isOn)
    local cameraConfigIds_ = self.settingVM_.GetLensCompensateId(settingId_)
    if cameraConfigIds_ then
      local settingMap = self.settingVM_.Get(settingId_)
      if Z.GameContext.IsPC then
        if not self.isHandle then
          settingMap[1] = isOn and 1 or 0
        else
          settingMap[2] = isOn and 1 or 0
        end
      else
        settingMap[3] = isOn and 1 or 0
      end
      self.settingVM_.Set(settingId_, settingMap)
      local switchNum_ = isOn == true and 1 or 0
      local opens_ = {}
      local ids_ = cameraConfigIds_
      for k, v in pairs(ids_) do
        table.insert(opens_, switchNum_)
      end
      Z.CameraMgr:SwitchCameraTemplate(opens_, ids_, 0)
    end
  end)
  local directionTip_Btn_ = trans_.btn_tips
  local directionTip_Trans_ = trans_.btn_tips_trans
  self:AddClick(directionTip_Btn_, function()
    if type(langStr_) == "string" then
      self:showTip(directionTip_Trans_, Lang(langStr_))
    else
      self:OpenMinTips(langStr_, directionTip_Trans_)
    end
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

return Set_control_subView
