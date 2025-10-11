local super = require("ui.service.service_base")
local SettingService = class("SettingService", super)

function SettingService:OnInit()
  local settingVM_ = Z.VMMgr.GetVM("setting")
  
  function self.onSettingDataChanged(container, dirtyKeys)
    Z.EventMgr:Dispatch(Z.ConstValue.SettingDataChanged)
    if self.toysSetting == settingVM_.Get(E.SettingID.ToyVisible) then
      return
    end
    self.toysSetting = settingVM_.Get(E.SettingID.ToyVisible)
    Z.EntityHelper.RefreshAllToyVisible()
  end
end

function SettingService:OnUnInit()
end

function SettingService:OnLogin()
  local settingVM_ = Z.VMMgr.GetVM("setting")
  local switchVm = Z.VMMgr.GetVM("switch")
  if not switchVm.CheckFuncSwitch(E.SetFuncId.NpcVoice) then
    local settingData = Z.DataMgr.Get("setting_data")
    Z.AudioMgr:SetVcaVolume(0, settingData.VcaTags[E.SettingID.Voice], false)
    settingVM_.SetSwitchIsOn(E.SettingID.Voice, false)
  end
  if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
    settingVM_.SetHandleCameraRotateSpeed()
    settingVM_.SetHandleMouseSpeed()
  else
    settingVM_.SetCameraRotateSpeed()
  end
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeViceTypeChange, self)
  self.dialogPoped = false
end

function SettingService:OnLeaveScene()
end

function SettingService:onDeViceTypeChange()
  local settingVM_ = Z.VMMgr.GetVM("setting")
  self:RefreshCameraTemplate()
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local sceneTable = Z.TableMgr.GetRow("SceneTableMgr", curSceneId)
  local subType = sceneTable.SceneSubType
  local isShowDialog = subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select
  if not Z.UIMgr:IsActive("setting") and isShowDialog and Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick and not self.dialogPoped then
    self.dialogPoped = true
    local confirmFunc = function()
      settingVM_.OpenSettingView(nil, E.SetFuncId.SettingControl)
    end
    Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("SettingDeviceChangeConfirm"), confirmFunc, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.SettingDeviceChange, nil, true)
  end
  if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
    settingVM_.SetHandleCameraRotateSpeed()
    settingVM_.SetHandleMouseSpeed()
  else
    settingVM_.SetCameraRotateSpeed()
  end
end

function SettingService:RefreshCameraTemplate()
  local settingVM_ = Z.VMMgr.GetVM("setting")
  local opens_ = {}
  local ids_ = {}
  local settingIds = settingVM_.GetAllLensCompensateId()
  for key, value in pairs(settingIds) do
    local settingMap = settingVM_.Get(key)
    local isOpen
    if Z.GameContext.IsPC then
      if Z.InputMgr.InputDeviceType ~= Panda.ZInput.EInputDeviceType.Joystick then
        isOpen = settingMap[1] == 1
      else
        isOpen = settingMap[2] == 1
      end
    else
      isOpen = settingMap[3] == 1
    end
    local switchNum_ = isOpen == true and 1 or 0
    for k, v in pairs(value) do
      opens_[#opens_ + 1] = switchNum_
      ids_[#ids_ + 1] = v
    end
  end
  Z.CameraMgr:SwitchCameraTemplate(opens_, ids_, 0)
end

function SettingService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.Device.DeviceTypeChange, self.onDeViceTypeChange, self)
  Z.ContainerMgr.CharSerialize.settingData.Watcher:UnregWatcher(self.onSettingDataChanged)
  self.dialogPoped = false
end

function SettingService:OnEnterScene(sceneId)
end

function SettingService:OnSyncAllContainerData()
  local settingVM_ = Z.VMMgr.GetVM("setting")
  self.toysSetting = settingVM_.Get(E.SettingID.ToyVisible)
  Z.ContainerMgr.CharSerialize.settingData.Watcher:RegWatcher(self.onSettingDataChanged)
end

return SettingService
