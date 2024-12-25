local super = require("ui.model.data_base")
local MatchData = class("MatchData", super)

function MatchData:ctor()
  super.ctor(self)
  self.selfMatchData_ = {
    targetId = E.TeamTargetId.All,
    matching = false
  }
end

function MatchData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self:ClearMatchData()
end

function MatchData:SetMatchInfo(matchInfo)
  self.matchInfo_ = matchInfo
  if self.matchInfo_ ~= nil then
    self:SetMatchType(self.matchInfo_.matchType)
    self:SetMatchState(self.matchInfo_.matchType, self.matchInfo_.matchStatus, self.matchInfo_.matchReadyTime)
    self:SetMatchStartTime(self.matchInfo_.matchTime * 1000, self.matchInfo_.matchType)
    self:SetMatchPlayerInfo(self.matchInfo_.matchPlayerInfo, self.matchInfo_.matchType)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchInfoChange)
end

function MatchData:GetMatchInfo()
  return self.matchInfo_
end

function MatchData:SetSelfMatchData(data, key)
  if key then
    self.selfMatchData_[key] = data
    return
  end
  self.selfMatchData_ = data
end

function MatchData:GetSelfMatchData(key)
  if key then
    return self.selfMatchData_[key]
  end
  return self.selfMatchData_
end

function MatchData:SetMatchType(matchType)
  if self.matchType_ == matchType then
    return
  end
  self.matchType_ = matchType
  Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchTypeChange)
end

function MatchData:GetMatchType()
  return self.matchType_
end

function MatchData:SetMatchState(matchType, matchState, matchSuccessTime)
  if matchType == E.MatchType.WorldBoss and matchSuccessTime and matchState == E.MatchSatatusType.WaitReady then
    local worldBossData = Z.DataMgr.Get("world_boss_data")
    worldBossData:SetWorldBossMatchSuccessTime(matchSuccessTime)
    local worldBossVM = Z.VMMgr.GetVM("world_boss")
    worldBossVM:OpenWorldBossMatchView()
  end
  if self.matchState_ == matchState then
    return
  end
  self.matchState_ = matchState
  Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchStateChange)
end

function MatchData:GetMatchState()
  return self.matchState_
end

function MatchData:SetMatchStartTime(matchStartTime, matchType)
  if self.matchStartTime_ == matchStartTime then
    return
  end
  self.matchType_ = matchType
  self.matchStartTime_ = matchStartTime
  if matchType == E.MatchType.WorldBoss then
    local worldBossData = Z.DataMgr.Get("world_boss_data")
    worldBossData:SetWorldBossMatchTime(matchStartTime)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchStartTimeChange, matchType)
end

function MatchData:GetMatchStartTime()
  return self.matchStartTime_
end

function MatchData:SetMatchPlayerInfo(matchPlayerInfo, matchType)
  self.matchPlayerInfo_ = matchPlayerInfo
  self.matchType_ = matchType
  Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchPlayerInfoChange, matchType)
end

function MatchData:GetMatchPlayerInfo()
  return self.matchPlayerInfo_
end

function MatchData:GetReadyMemberCount()
  local num = 0
  if self.matchPlayerInfo_ then
    for _, value in pairs(self.matchPlayerInfo_) do
      if value.readyStatus == E.RedayType.Ready then
        num = num + 1
      end
    end
  end
  return num
end

function MatchData:ClearMatchData()
  self.matchType_ = E.MatchType.Null
  self.matchState_ = E.MatchSatatusType.Null
  self.matchStartTime_ = 0
  self.matchInfo_ = nil
  self.matchPlayerInfo_ = {}
  self.selfMatchData_ = {
    targetId = E.TeamTargetId.All,
    matching = false
  }
end

function MatchData:UnInit()
  self:ClearMatchData()
  self.CancelSource:Recycle()
end

return MatchData
