local super = require("ui.model.data_base")
local MatchActivityData = class("MatchActivityData", super)

function MatchActivityData:ctor()
  super.ctor(self)
end

function MatchActivityData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function MatchActivityData:UnInit()
  self.CancelSource:Recycle()
end

function MatchActivityData:GetActivityId()
  local matchData = Z.DataMgr.Get("match_data")
  if matchData:GetMatchType() ~= E.MatchType.Activity then
    return
  end
  local curMatchInfo = matchData:GetMatchData()
  if curMatchInfo ~= nil then
    return curMatchInfo.matchKeyInfo.matchTypeUuid
  end
end

function MatchActivityData:GetCurMatchActivityType()
  local matchData = Z.DataMgr.Get("match_data")
  local curMatchInfo = matchData:GetMatchData()
  if curMatchInfo ~= nil and curMatchInfo.matchKeyInfo ~= nil then
    local actId = curMatchInfo.matchKeyInfo.matchTypeUuid
    return self:GetMatchActivityTypeByActId(actId)
  end
end

function MatchActivityData:GetMatchActivityTypeByActId(actId)
  local seasonActTableRow = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(actId)
  if seasonActTableRow and seasonActTableRow.FunctionId == E.FunctionID.WorldBoss then
    return E.MatchActivityType.WorldBoseActivity
  else
    return E.MatchActivityType.CommonActivity
  end
end

return MatchActivityData
