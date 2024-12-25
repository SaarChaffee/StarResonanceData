local super = require("ui.model.data_base")
local WarehouseData = class("WarehouseData", super)

function WarehouseData:ctor()
  super.ctor(self)
end

function WarehouseData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.WarehouseCfgDatas = {}
  self.WarehouseTypeList = {}
  self.WarehouseInfo = nil
  self:InitCfgData()
end

function WarehouseData:InitCfgData()
  self.WarehouseTableDatas = Z.TableMgr.GetTable("WarehouseTableMgr").GetDatas()
end

function WarehouseData:OnLanguageChange()
  self:InitCfgData()
end

function WarehouseData:SetWarehouseType(list)
  self.WarehouseTypeList = list
end

function WarehouseData:GetWarehouseTypeList()
  return self.WarehouseTypeList
end

function WarehouseData:GetWarehouseTypeByIndex(index)
  return self.WarehouseTypeList[index]
end

function WarehouseData:SetWarehouseCfgData(data)
  self.WarehouseCfgDatas = data
end

function WarehouseData:GetWarehouseCfgDataByType(type)
  return self.WarehouseCfgDatas[type]
end

function WarehouseData:GetWarehouseInfo()
  return self.WarehouseInfo
end

function WarehouseData:SetWarehouseInfo(warehouseInfo)
  self.WarehouseInfo = warehouseInfo
end

function WarehouseData:UnInit()
  self.CancelSource:Recycle()
end

return WarehouseData
