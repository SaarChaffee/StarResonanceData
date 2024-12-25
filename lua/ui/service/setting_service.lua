local super = require("ui.service.service_base")
local SettingService = class("SettingService", super)

function SettingService:OnInit()
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
    opens_[#opens_ + 1] = switchNum_
    ids_[#ids_ + 1] = value
  end
  Z.CameraMgr:SwitchCameraTemplate(opens_, ids_, 0)
  
  function self.onChangeLanguagee()
    local scenelineData = Z.DataMgr.Get("sceneline_data")
    scenelineData:ClearCache()
  end
  
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onChangeLanguagee)
end

function SettingService:OnLeaveScene()
end

function SettingService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.onChangeLanguagee)
end

function SettingService:OnEnterScene(sceneId)
end

return SettingService
