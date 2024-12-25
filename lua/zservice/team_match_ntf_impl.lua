local pb = require("pb2")
local TeamMatchNtfImpl = {}
local matchVm_ = Z.VMMgr.GetVM("match")

function TeamMatchNtfImpl:NotifyMatchERROR(call, errType, vErrCode)
  local matchData = Z.DataMgr.Get("match_data")
  if errType == Z.PbEnum("ETeamErrorType", "ReqCharCancelMatch") then
    Z.TipsVM.ShowTipsLang(1000614)
    matchData:SetSelfMatchData(false, "matching")
    matchVm_.CancelMatchingTips()
    Z.EventMgr:Dispatch(Z.ConstValue.Team.RepeatCharCancelMatch)
  elseif errType == Z.PbEnum("ETeamErrorType", "ReqCharBeginMatch") then
    Z.TipsVM.ShowTipsLang(1000613)
    matchData:SetSelfMatchData(true, "matching")
    matchVm_.CreateMatchingTips()
  end
end

return TeamMatchNtfImpl
