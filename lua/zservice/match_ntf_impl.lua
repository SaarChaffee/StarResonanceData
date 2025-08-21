local pb = require("pb2")
local MatchNtfImpl = {}
local matchVm_ = Z.VMMgr.GetVM("match")

function MatchNtfImpl:EnterMatchResultNtf(call, vData)
  local errCode = vData.errCode
  if errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
    return
  end
  local matchdata = Z.DataMgr.Get("match_data")
  if vData.isReEnter then
    Z.TipsVM.ShowTips(16002044)
    local matchVm_ = Z.VMMgr.GetVM("match")
    matchVm_.CloseMatchView()
  end
  matchdata:SetMatchData(vData.matchInfo)
end

function MatchNtfImpl:CancelMatchResultNtf(call, vData)
  matchVm_.CloseMatchView()
  local matchdata = Z.DataMgr.Get("match_data")
  matchdata:SetMatchData(vData.matchInfo, true)
  local isChangeMatching, changFunc = matchdata:GetIsChangeMatching()
  if isChangeMatching then
    if changFunc then
      changFunc()
    end
    matchdata:SetIsChangeMatching(false, nil)
  end
  if vData.cancelType == E.MatchCancelType.UnReady then
    Z.TipsVM.ShowTips(16002041)
  end
  if vData.cancelType == E.MatchCancelType.Request then
    Z.TipsVM.ShowTips(16002045)
  end
  if vData.cancelType == E.MatchCancelType.TimeOut then
    Z.TipsVM.ShowTips(16002046)
  end
  local matchTeamVm_ = Z.VMMgr.GetVM("match_team")
  matchTeamVm_.CancelMatchingTimer()
end

function MatchNtfImpl:MatchReadyStatusNtf(call, vData)
  local errCode = vData.errCode
  if errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
    return
  end
  local matchdata = Z.DataMgr.Get("match_data")
  matchdata:SetMatchPlayerInfo(vData.matchPlayerInfo, vData.matchToken)
  for _, value in pairs(vData.matchPlayerInfo) do
    local vRequest = value
  end
  local playerDatas = vData.matchPlayerInfo
  if vData.matchType == E.MatchType.Team then
    local teamData = Z.DataMgr.Get("team_data")
    local mems = teamData.TeamInfo.members
    for _, value in pairs(playerDatas) do
      local vRequest = value
      local memInfo = mems[vRequest.charId]
      if not memInfo then
        return
      end
      if vRequest.readyStatus == E.RedayType.UnReady then
        local param = {
          player = {
            name = memInfo.socialData and memInfo.socialData.basicData.name or ""
          }
        }
        Z.TipsVM.ShowTipsLang(1000637, param)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchPlayerInfoChange)
end

return MatchNtfImpl
