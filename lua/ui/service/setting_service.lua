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
  local opens_ = {}
  local ids_ = {}
  local settingIds = settingVM_.GetAllLensCompensateId()
  for key, value in pairs(settingIds) do
    local isOpen = settingVM_.Get(key)
    local switchNum_ = isOpen == true and 1 or 0
    for k, v in pairs(value) do
      opens_[#opens_ + 1] = switchNum_
      ids_[#ids_ + 1] = v
    end
  end
  Z.CameraMgr:SwitchCameraTemplate(opens_, ids_, 0)
  local switchVm = Z.VMMgr.GetVM("switch")
  if not switchVm.CheckFuncSwitch(E.SetFuncId.NpcVoice) then
    local settingData = Z.DataMgr.Get("setting_data")
    Z.AudioMgr:SetVcaVolume(0, settingData.VcaTags[E.SettingID.Voice], false)
    settingVM_.SetSwitchIsOn(E.SettingID.Voice, false)
  end
end

function SettingService:OnLeaveScene()
end

function SettingService:OnLogout()
  Z.ContainerMgr.CharSerialize.settingData.Watcher:UnregWatcher(self.onSettingDataChanged)
end

function SettingService:OnEnterScene(sceneId)
end

function SettingService:OnSyncAllContainerData()
  local settingVM_ = Z.VMMgr.GetVM("setting")
  self.toysSetting = settingVM_.Get(E.SettingID.ToyVisible)
  Z.ContainerMgr.CharSerialize.settingData.Watcher:RegWatcher(self.onSettingDataChanged)
end

return SettingService
