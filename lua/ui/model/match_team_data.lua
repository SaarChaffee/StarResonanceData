local super = require("ui.model.data_base")
local MatchTeamData = class("MatchTeamData", super)

function MatchTeamData:ctor()
  super.ctor(self)
  self.matchData_ = Z.DataMgr.Get("match_data")
end

function MatchTeamData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function MatchTeamData:GetCurMatchingTargetId()
  if self.matchData_:GetMatchType() ~= E.MatchType.Team then
    return
  end
  local curMatchInfo = self.matchData_:GetMatchData()
  if curMatchInfo ~= nil then
    return curMatchInfo.matchKeyInfo.matchTypeUuid
  end
end

function MatchTeamData:GetCurMatchingDungeonId()
  local targetID = self:GetCurMatchingTargetId()
  if targetID == nil then
    return
  end
  local targetInfo = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetID)
  if targetInfo then
    return targetInfo.RelativeDungeonId
  end
end

function MatchTeamData:UnInit()
  self.CancelSource:Recycle()
end

return MatchTeamData
