local super = require("ui.model.data_base")
local TipsBroadcastData = class("TipsBroadcastData", super)

function TipsBroadcastData:ctor()
  super.ctor(self)
  self.broadcastQueue_ = {}
end

function TipsBroadcastData:AddBroadcast(vInfo)
  table.insert(self.broadcastQueue_, vInfo)
end

function TipsBroadcastData:GetBroadcast()
  if next(self.broadcastQueue_) == nil then
    return nil
  end
  return table.remove(self.broadcastQueue_, 1)
end

return TipsBroadcastData
