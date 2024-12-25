local super = require("ui.model.data_base")
local DungeonData = class("DungeonData", super)

function DungeonData:ctor()
  super.ctor(self)
  self.DungeonList = {}
  self.DungeonTargetData = {
    step = 1,
    trackId = 1,
    posCfg = {}
  }
  self.PioneerInfos = nil
  self.BeginEnterPioneerInfo = nil
  self.TrackViewShow = true
  self.DungeonTimeData = nil
  self.dungeonAffixDic = {}
end

function DungeonData:GetDungeonTimeData()
  return self.DungeonTimeData
end

function DungeonData:SetDungeonTimeData(data)
  self.DungeonTimeData = data
end

function DungeonData:SetDungeonList(dungeonList)
  self.DungeonList = dungeonList
  local dungeonListShow = {}
  local id1 = dungeonList[1] and dungeonList[1] or 0
  local id2 = dungeonList[2] and dungeonList[2] or 0
  local id3 = dungeonList[3] and dungeonList[3] or 0
  table.insert(dungeonListShow, id2)
  table.insert(dungeonListShow, id1)
  table.insert(dungeonListShow, id3)
  Z.HeroDungeonMgr:InitEntranceDict(dungeonListShow)
end

function DungeonData:GetDungeonList()
  return self.DungeonList
end

function DungeonData:SetDungeonAffixDic(dungeonAffixes)
  self.dungeonAffixDic = dungeonAffixes
end

function DungeonData:GetDungeonAffixDic(dungeonId)
  return self.dungeonAffixDic[dungeonId]
end

function DungeonData:SetDungeonTargetData(key, value)
  if self.DungeonTargetData[key] then
    self.DungeonTargetData[key] = value
  end
end

function DungeonData:GetDungeonTargetData(key)
  if key then
    return self.DungeonTargetData[key]
  end
  return self.DungeonTargetData
end

function DungeonData:GetDungeonIntroductionById(id)
  local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(id)
  if cfg then
    local tb = {
      name = cfg.Name,
      content = cfg.Content,
      playType = cfg.PlayType
    }
    return tb
  end
end

function DungeonData:GetChestIntroductionById(id)
  local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(id)
  local cfg
  local tb = {}
  if dungeonData then
    cfg = dungeonData.ExploreAward
    for key, value in pairs(cfg) do
      local tempTb = {}
      tempTb.preValue = value[1]
      tempTb.rewardId = value[2]
      table.insert(tb, tempTb)
    end
  end
  return tb
end

function DungeonData:GetSortedEventList()
  local eventList = {}
  local container = Z.ContainerMgr.DungeonSyncData.dungeonEvent
  for eventId, eventData in pairs(container) do
    table.insert(eventList, eventData)
  end
  table.sort(eventList, function(a, b)
    return a.startTime < b.startTime
  end)
  return eventList
end

function DungeonData:CreatCancelSource()
  if self.CancelSource == nil then
    self.CancelSource = Z.CancelSource.Rent()
  end
end

function DungeonData:RecycleCancelSource()
  if self.CancelSource then
    self.CancelSource:Recycle()
    self.CancelSource = nil
  end
end

function DungeonData:UnInit()
  if self.CancelSource then
    self.CancelSource:Recycle()
  end
end

function DungeonData:Clear()
  self.DungeonList = {}
  self.DungeonTargetData = {
    step = 1,
    trackId = 1,
    posCfg = {}
  }
  self.PioneerInfos = nil
  self.BeginEnterPioneerInfo = nil
  self.TrackViewShow = true
end

return DungeonData
