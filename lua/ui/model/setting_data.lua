local super = require("ui.model.data_base")
local SettingData = class("SettingData", super)
E.SettingVFXLevel = {
  Off = 1,
  Simple = 2,
  Normal = 3,
  Delicacy = 4
}

function SettingData:ctor()
  super.ctor(self)
  self.DataStorage = {
    ClientDeviceData = 0,
    ClientEnvData = 1,
    ClientAccountData = 2,
    ClientCharacterData = 3,
    ServerData = 99
  }
  self.VcaTags = {
    [E.SettingID.Master] = "Master_Volume",
    [E.SettingID.Bgm] = "BGM_Volume",
    [E.SettingID.Sfx] = "SFX_Volume",
    [E.SettingID.Voice] = "Voice_Volume",
    [E.SettingID.System] = "UI_Volume",
    [E.SettingID.P3] = "P3_Volume",
    [E.SettingID.PlayerVoiceReceptionVolume] = "PlayerVoiceReception_Volume",
    [E.SettingID.PlayerVoiceTransmissionVolume] = "PlayerVoiceTransmission_Volume"
  }
  self.CanOpen = {open = 1, close = 2}
  self.VFXIndexMapPC = {
    [E.SettingVFXLevel.Off] = -1,
    [E.SettingVFXLevel.Simple] = 0,
    [E.SettingVFXLevel.Normal] = 2,
    [E.SettingVFXLevel.Delicacy] = 4
  }
  self.VFXIndexMapMobile = {
    [E.SettingVFXLevel.Off] = -1,
    [E.SettingVFXLevel.Simple] = 0,
    [E.SettingVFXLevel.Normal] = 1,
    [E.SettingVFXLevel.Delicacy] = 3
  }
  self.SettingImageQuality2Effects = {
    E.SettingID.EffSelf,
    E.SettingID.EffEnemy,
    E.SettingID.EffTeammate,
    E.SettingID.EffOther,
    E.SettingID.EffectRest
  }
  self.displayGamepadActionCache_ = {}
end

function SettingData:Init()
  super.Init(self)
end

function SettingData:OnReconnect()
  super.OnReconnect(self)
end

function SettingData:Clear()
  super.Clear(self)
end

function SettingData:UnInit()
  super.UnInit(self)
end

return SettingData
