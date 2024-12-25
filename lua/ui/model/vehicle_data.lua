local super = require("ui.model.data_base")
local VehicleData = class("VehicleData", super)

function VehicleData:ctor()
  self.allVehicleConfigs_ = {}
  local index = 0
  local vehicleBaseTableRows = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetDatas()
  for _, config in pairs(vehicleBaseTableRows) do
    if config.IsHide and config.IsHide == 0 then
      index = index + 1
      self.allVehicleConfigs_[index] = config
    end
  end
  self.IsSendMessage = false
end

function VehicleData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function VehicleData:UnInit()
  self.CancelSource:Recycle()
end

function VehicleData:Clear()
  self.IsSendMessage = false
end

function VehicleData:GetVehicleConfigs(type)
  if type == nil then
    return self.allVehicleConfigs_
  else
    local res = {}
    local index = 0
    for _, config in ipairs(self.allVehicleConfigs_) do
      if config.Type == type then
        index = index + 1
        res[index] = config
      end
    end
    return res
  end
end

return VehicleData
