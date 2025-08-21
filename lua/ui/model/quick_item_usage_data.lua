local super = require("ui.model.data_base")
local QuickItemUsageData = class("QuickItemUsageData", super)

function QuickItemUsageData:ctor()
  super.ctor(self)
end

function QuickItemUsageData:Init()
  self:Clear()
end

function QuickItemUsageData:Uninit()
  self:Clear()
end

function QuickItemUsageData:Clear()
  self.quickItemUsageQueue_ = {}
  self.quickItemUseageMap_ = {}
end

function QuickItemUsageData:EnItemQuickQueue(configId, uuid)
  if self.quickItemUseageMap_[uuid] ~= nil then
    return
  end
  self.quickItemUseageMap_[uuid] = true
  local queueData = {configId = configId, uuid = uuid}
  table.insert(self.quickItemUsageQueue_, queueData)
end

function QuickItemUsageData:DeItemQuickQueue(configId, uuid)
  if self.quickItemUseageMap_[uuid] == nil then
    return
  end
  self.quickItemUseageMap_[uuid] = nil
  for i, v in ipairs(self.quickItemUsageQueue_) do
    if v.configId == configId and v.uuid == uuid then
      table.remove(self.quickItemUsageQueue_, i)
      break
    end
  end
end

function QuickItemUsageData:PeekItemQuickQueue()
  if self.quickItemUsageQueue_ == nil then
    return nil
  end
  local count = #self.quickItemUsageQueue_
  if count == 0 then
    return nil
  end
  return self.quickItemUsageQueue_[count]
end

function QuickItemUsageData:CheckItemVail(configId, uuid)
  return self.quickItemUseageMap_[uuid] ~= nil
end

function QuickItemUsageData:HasQuickUseItem()
  return self.quickItemUsageQueue_ and #self.quickItemUsageQueue_ > 0
end

function QuickItemUsageData:OnReconnect()
end

return QuickItemUsageData
