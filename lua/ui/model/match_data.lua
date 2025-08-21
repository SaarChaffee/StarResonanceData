local super = require("ui.model.data_base")
local MatchData = class("MatchData", super)

function MatchData:ctor()
  super.ctor(self)
end

function MatchData:Init()
  self.isChangeMatching_ = false
  self.CancelSource = Z.CancelSource.Rent()
  self:ClearMatchData()
end

function MatchData:GetMatchType()
  return self.matchType_
end

function MatchData:SetMatchData(data, isCancel)
  if data == nil then
    local matchTeamVm_ = Z.VMMgr.GetVM("match_team")
    matchTeamVm_.CancelMatchingTimer()
    return
  end
  if data.matchKeyInfo == nil or isCancel then
    self:ClearMatchData()
    local matchTeamVm_ = Z.VMMgr.GetVM("match_team")
    matchTeamVm_.CancelMatchingTimer()
    Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchStateChange)
    return
  end
  local matchVm_ = Z.VMMgr.GetVM("match")
  local matchStatus = data.matchStatus
  self.matchInfo_ = data
  self.matchType_ = data.matchKeyInfo.matchType
  self.matchPlayerInfo_ = data.matchPlayerInfo
  self:SetMatchStartTime(data.matchTime * 1000)
  if self.matchState_ == matchStatus then
    return
  end
  self.matchState_ = matchStatus
  if matchStatus == E.MatchSatatusType.WaitReady then
    matchVm_.OpenMatchView(self.matchType_)
  else
    matchVm_.CloseMatchView()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchStateChange)
end

function MatchData:GetMatchData()
  return self.matchInfo_
end

function MatchData:SetMatchStartTime(matchStartTime)
  if self.matchStartTime_ == matchStartTime then
    return
  end
  self.matchStartTime_ = matchStartTime
  Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchStartTimeChange, self.matchType_)
  local matchTeamVm_ = Z.VMMgr.GetVM("match_team")
  matchTeamVm_.CreateMatchingTimer()
end

function MatchData:GetMatchStartTime()
  return self.matchStartTime_
end

function MatchData:GetMatchSuccessTime()
  if not self.matchInfo_ then
    return 0
  end
  return self.matchInfo_.matchReadyTime
end

function MatchData:SetMatchPlayerInfo(matchPlayerInfo, matchToken)
  if self.matchInfo_.matchToken ~= matchToken then
    return
  end
  self.matchPlayerInfo_ = matchPlayerInfo
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
  self:SetMatchStartTime(0)
  self.matchType_ = E.MatchType.Null
  self.matchState_ = E.MatchSatatusType.Null
  self.matchInfo_ = nil
  self.matchPlayerInfo_ = {}
end

function MatchData:UnInit()
  self:ClearMatchData()
  self.CancelSource:Recycle()
end

function MatchData:GetIsChangeMatching()
  return self.isChangeMatching_, self.beginMatchFunc_
end

function MatchData:SetIsChangeMatching(isChanging, beginMatchFunc)
  self.beginMatchFunc_ = beginMatchFunc
  self.isChangeMatching_ = isChanging
end

return MatchData
