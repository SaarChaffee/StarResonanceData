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

function QuickItemUsageData:EnItemQuickQueue(configId)
  if self.quickItemUseageMap_[configId] ~= nil then
    return
  end
  self.quickItemUseageMap_[configId] = true
  table.insert(self.quickItemUsageQueue_, configId)
end

function QuickItemUsageData:DeItemQuickQueue(configId)
  if self.quickItemUseageMap_[configId] == nil then
    return
  end
  self.quickItemUseageMap_[configId] = nil
  table.zremoveOneByValue(self.quickItemUsageQueue_, configId)
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

function QuickItemUsageData:CheckItemVail(configId)
  return self.quickItemUseageMap_[configId] ~= nil
end

function QuickItemUsageData:HasQuickUseItem()
  return self.quickItemUsageQueue_ and #self.quickItemUsageQueue_ > 0
end

function QuickItemUsageData:OnReconnect()
end

return QuickItemUsageData
