local super = require("ui.service.service_base")
local VehicleService = class("VehicleService", super)

function VehicleService:OnInit()
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
  
  function self.vehicleUnlockItemChange_(item)
    local vehicleData = Z.DataMgr.Get("vehicle_data")
    local configs = vehicleData.VehicleRedWatcher[item.configId]
    if configs then
      local itemsVM = Z.VMMgr.GetVM("items")
      for _, config in ipairs(configs) do
        if config.ParentId and config.ParentId == 0 then
          if itemsVM.GetItemTotalCount(item.configId) >= config.UnlockCostItem[2] and itemsVM.GetItemTotalCount(config.Id) == 0 then
            Z.RedPointMgr.UpdateNodeCount(self.vehicleVM_.GetRedNodeId(config.Id), 1)
          else
            Z.RedPointMgr.UpdateNodeCount(self.vehicleVM_.GetRedNodeId(config.Id), 0)
          end
        elseif config.ParentId and config.ParentId ~= 0 then
          if itemsVM.GetItemTotalCount(item.configId) >= config.UnlockCostItem[2] and 0 < itemsVM.GetItemTotalCount(config.ParentId) and itemsVM.GetItemTotalCount(config.Id) == 0 then
            Z.RedPointMgr.UpdateNodeCount(self.vehicleVM_.GetRedNodeId(config.Id), 1)
          else
            Z.RedPointMgr.UpdateNodeCount(self.vehicleVM_.GetRedNodeId(config.Id), 0)
          end
        end
      end
    end
  end
end

function VehicleService:OnUnInit()
end

function VehicleService:OnLogin()
  local vehicleData = Z.DataMgr.Get("vehicle_data")
  vehicleData:InitData(true)
  for itemId, _ in pairs(vehicleData.VehicleRedWatcher) do
    Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, itemId, self.vehicleUnlockItemChange_)
  end
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function VehicleService:OnLogout()
  local vehicleData = Z.DataMgr.Get("vehicle_data")
  for itemId, _ in pairs(vehicleData.VehicleRedWatcher) do
    Z.ItemEventMgr.RemoveObjAllByEvent(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemId, itemId, self.vehicleUnlockItemChange_)
  end
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.onItemChange, self)
end

function VehicleService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self:checkAllVehicleRed()
  end
end

function VehicleService:checkAllVehicleRed()
  local vehicleData = Z.DataMgr.Get("vehicle_data")
  local configs = vehicleData:GetVehicleConfigs()
  for _, config in ipairs(configs) do
    self:checVehicleRedDot(config.Id)
  end
end

function VehicleService:checVehicleRedDot(configId)
  local vehicleConfig = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(configId)
  if vehicleConfig and vehicleConfig.IsHide and vehicleConfig.IsHide == 0 then
    if vehicleConfig.ParentId and vehicleConfig.ParentId ~= 0 then
      Z.RedPointMgr.UpdateNodeCount(self.vehicleVM_.GetRedNodeId(vehicleConfig.Id), 0)
    else
      local itemsVM = Z.VMMgr.GetVM("items")
      local skins = Z.DataMgr.Get("vehicle_data"):GetVehicleSkins(vehicleConfig.Id)
      for _, config in ipairs(skins) do
        if config.ParentId and config.ParentId ~= 0 and config.UnlockCostItem and #config.UnlockCostItem == 2 then
          if itemsVM.GetItemTotalCount(config.UnlockCostItem[1]) >= config.UnlockCostItem[2] and itemsVM.GetItemTotalCount(config.Id) == 0 and 0 < itemsVM.GetItemTotalCount(config.ParentId) then
            Z.RedPointMgr.UpdateNodeCount(self.vehicleVM_.GetRedNodeId(config.Id), 1)
          else
            Z.RedPointMgr.UpdateNodeCount(self.vehicleVM_.GetRedNodeId(config.Id), 0)
          end
        end
      end
    end
  end
end

function VehicleService:onItemChange(item)
  if item == nil or item.configId == nil then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByConfigId(item.configId, E.BackPackItemPackageType.Ride) then
    self:checVehicleRedDot(item.configId)
  end
end

return VehicleService
