local super = require("ui.model.data_base")
local WorldQuestData = class("WorldQuestData", super)

function WorldQuestData:ctor()
  super.ctor(self)
  self.AcceptWorldQuest = false
  self.dailyWorldEventDict_ = {}
end

function WorldQuestData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function WorldQuestData:CheckIsWorldQuestEntity(entityId)
  if next(self.dailyWorldEventDict_) == nil then
    local dailyEventList = Z.TableMgr.GetTable("DailyWorldEventTableMgr"):GetDatas()
    for k, v in pairs(dailyEventList) do
      self.dailyWorldEventDict_[v.Entity[2]] = v.Entity[2]
    end
  end
  if self.dailyWorldEventDict_[entityId] ~= nil then
    return true
  end
  return false
end

function WorldQuestData:ClearDict()
  self.dailyWorldEventDict_ = {}
end

function WorldQuestData:UnInit()
  self.CancelSource:Recycle()
  self:ClearDict()
end

return WorldQuestData
