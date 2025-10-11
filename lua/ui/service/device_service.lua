local super = require("ui.service.service_base")
local DeviceService = class("DeviceService", super)

function DeviceService:OnInit()
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeviceTypeChange, self)
end

function DeviceService:OnUnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function DeviceService:onDeviceTypeChange()
end

return DeviceService
