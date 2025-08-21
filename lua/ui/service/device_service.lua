local super = require("ui.service.service_base")
local DeviceService = class("DeviceService", super)

function DeviceService:OnInit()
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceTypeChange, self)
end

function DeviceService:OnUnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function DeviceService:onDeviceTypeChange()
  if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
    Z.GuideMgr:SetBlockSteer(E.BlockSteerType.Gamepad, true)
  else
    Z.GuideMgr:SetBlockSteer(E.BlockSteerType.Gamepad, false)
  end
end

return DeviceService
