local super = require("ui.model.data_base")
local ItemTraceData = class("ItemTraceData", super)

function ItemTraceData:ctor()
  super.ctor(self)
end

function ItemTraceData:Init(...)
  self.CurTraceItemId = 0
  self.CurTraceMaterialList = {}
end

function ItemTraceData:SetTraceItemData(configId, materialList)
  self.CurTraceItemId = configId
  self.CurTraceMaterialList = materialList
end

function ItemTraceData:CancelTraceCurTraceItem()
  self.CurTraceMaterialList = {}
  self.CurTraceItemId = 0
end

function ItemTraceData:Clear()
  self.CurTraceItemId = 0
  self.CurTraceMaterialList = {}
end

function ItemTraceData:UnInit()
end

return ItemTraceData
