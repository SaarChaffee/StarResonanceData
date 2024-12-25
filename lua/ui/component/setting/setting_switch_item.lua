local SettingSwitchItem = class("SettingSwitchItem")

function SettingSwitchItem:ctor()
  self.switch_ = nil
  self.settingId_ = nil
  self.onSwitch_ = nil
  self.settingVm_ = Z.VMMgr.GetVM("setting")
end

function SettingSwitchItem:Init(switch, settingId, onSwitch, isOn)
  self.switch_ = switch
  self.settingId_ = settingId
  self.onSwitch_ = onSwitch
  if switch then
    local default = settingId and self.settingVm_.Get(self.settingId_) or isOn
    switch.IsOn = default
    switch:AddListener(function(v)
      if settingId then
        self.settingVm_.Set(settingId, v)
      end
      if self.onSwitch_ then
        self.onSwitch_(v)
      end
    end)
  end
end

return SettingSwitchItem
