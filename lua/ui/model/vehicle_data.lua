local super = require("ui.model.data_base")
local VehicleData = class("VehicleData", super)

function VehicleData:ctor()
  self.IsSendMessage = false
end

function VehicleData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.allVehicleConfigs_ = {}
  self.vehicleSkinConfigs_ = {}
  self.VehicleRedWatcher = {}
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
end

function VehicleData:UnInit()
  self.CancelSource:Recycle()
end

function VehicleData:Clear()
  self.IsSendMessage = false
end

function VehicleData:OnLanguageChange()
  self:InitData(false)
end

function VehicleData:InitData(needLoadRed)
  self.allVehicleConfigs_ = {}
  self.vehicleSkinConfigs_ = {}
  self.VehicleRedWatcher = {}
  local index = 0
  local vehicleBaseTableRows = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetDatas()
  for _, config in pairs(vehicleBaseTableRows) do
    if config.IsHide and config.IsHide == 0 then
      if config.ParentId and config.ParentId ~= 0 then
        if self.vehicleSkinConfigs_[config.ParentId] == nil then
          self.vehicleSkinConfigs_[config.ParentId] = {}
        end
        table.insert(self.vehicleSkinConfigs_[config.ParentId], config)
        if needLoadRed then
          Z.RedPointMgr.AddChildNodeData(self.vehicleVM_.GetRedNodeId(config.ParentId), E.RedType.VehicleItem, self.vehicleVM_.GetRedNodeId(config.Id))
        end
        if config.UnlockCostItem ~= nil and #config.UnlockCostItem == 2 then
          if self.VehicleRedWatcher[config.UnlockCostItem[1]] == nil then
            self.VehicleRedWatcher[config.UnlockCostItem[1]] = {}
          end
          table.insert(self.VehicleRedWatcher[config.UnlockCostItem[1]], config)
        end
      else
        index = index + 1
        self.allVehicleConfigs_[index] = config
        if self.vehicleSkinConfigs_[config.Id] == nil then
          self.vehicleSkinConfigs_[config.Id] = {}
        end
        table.insert(self.vehicleSkinConfigs_[config.Id], config)
        if needLoadRed then
          Z.RedPointMgr.AddChildNodeData(E.RedType.Vehicle, E.RedType.VehicleItem, self.vehicleVM_.GetRedNodeId(config.Id))
        end
      end
    end
  end
end

function VehicleData:GetVehicleConfigs(type)
  if type == nil then
    local res = {}
    local resCount = 0
    local itemsVM = Z.VMMgr.GetVM("items")
    for _, config in ipairs(self.allVehicleConfigs_) do
      if config.HideWhenNotHave then
        if 0 < itemsVM.GetItemTotalCount(config.Id) then
          resCount = resCount + 1
          res[resCount] = config
        end
      else
        resCount = resCount + 1
        res[resCount] = config
      end
    end
    return res
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

function VehicleData:GetVehicleSkins(configId)
  if self.vehicleSkinConfigs_[configId] == nil then
    return {}
  else
    local res = {}
    local resCount = 0
    local itemsVM = Z.VMMgr.GetVM("items")
    for _, config in ipairs(self.vehicleSkinConfigs_[configId]) do
      if config.HideWhenNotHave then
        if 0 < itemsVM.GetItemTotalCount(config.Id) then
          resCount = resCount + 1
          res[resCount] = config
        elseif config.UnlockCostItem ~= nil and #config.UnlockCostItem == 2 and 0 < itemsVM.GetItemTotalCount(config.UnlockCostItem[1]) then
          resCount = resCount + 1
          res[resCount] = config
        end
      else
        resCount = resCount + 1
        res[resCount] = config
      end
    end
    return res
  end
end

return VehicleData
