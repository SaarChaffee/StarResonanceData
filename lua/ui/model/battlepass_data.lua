local super = require("ui.model.data_base")
local BattlePassData = class("BattlePassData", super)

function BattlePassData:ctor()
  super.ctor(self)
end

function BattlePassData:Init()
  self.weekData_ = {}
  self.seasonTask_ = {}
  self.BattlePassLevel = 0
  self.BPCardPageIndex = 0
  self.CurBattlePassData = {}
end

function BattlePassData:Clear()
  self.weekData_ = {}
  self.seasonTask_ = {}
  self.BattlePassLevel = 0
  self.BPCardPageIndex = 0
  self.CurBattlePassData = {}
end

function BattlePassData:UnInit()
end

function BattlePassData:GetBattlePassData(battlePassId)
  local bpCardInfo = {}
  local bpCardTableInfo = Z.TableMgr.GetTable("BattlePassCardTableMgr").GetDatas()
  for k, v in pairs(bpCardTableInfo) do
    if v.BattlePassCardId == battlePassId then
      bpCardInfo[v.SeasonLevel] = {}
      bpCardInfo[v.SeasonLevel].configData = v
    end
  end
  table.sort(bpCardInfo, function(a, b)
    return a.configData.SeasonLevel < b.configData.SeasonLevel
  end)
  return bpCardInfo
end

function BattlePassData:GetSeasonTaskBySeasonId(seasonId)
  if not seasonId then
    return {}
  end
  if next(self.seasonTask_) and self.seasonTask_[1].Season == seasonId then
    return self.seasonTask_
  end
  self.seasonTask_ = {}
  local seasonBPTaskTableData = Z.TableMgr.GetTable("SeasonBPTaskTableMgr").GetDatas()
  for k, v in pairs(seasonBPTaskTableData) do
    if v.Season == seasonId then
      local tempTable = {}
      tempTable.configData = v
      table.insert(self.seasonTask_, tempTable)
    end
  end
  return self.seasonTask_
end

function BattlePassData:GetSeasonWeek()
  local questContainer = Z.ContainerMgr.CharSerialize.seasonCenter
  if not questContainer or table.zcount(questContainer) <= 0 then
    return {}
  end
  self.weekData_ = {}
  local index = 0
  local data = self:GetSeasonTaskBySeasonId(questContainer.seasonId)
  for _, v in pairs(data) do
    if v.configData.ShowWeek and not self.weekData_[v.configData.ShowWeek] and 0 < v.configData.ShowWeek then
      self.weekData_[v.configData.ShowWeek] = {}
      self.weekData_[v.configData.ShowWeek].index = v.configData.ShowWeek
      self.weekData_[v.configData.ShowWeek].condition = v.configData.Condition
      self.weekData_[v.configData.ShowWeek].seasonId = questContainer.seasonId
      if Z.ConditionHelper.CheckSingleCondition(tonumber(v.configData.Condition[1]), false, tonumber(v.configData.Condition[2]), v.configData.Condition[3], v.configData.Condition[4]) then
        index = index + 1
      end
    end
  end
  if index < #self.weekData_ then
    local count = #self.weekData_ - index
    for i = 1, count do
      table.remove(self.weekData_)
    end
  end
  return self.weekData_
end

return BattlePassData
