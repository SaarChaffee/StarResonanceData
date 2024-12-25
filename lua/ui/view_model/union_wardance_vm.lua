local UnionWarDanceVM = {}
local worldProxy_ = require("zproxy.world_proxy")
local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
local actionData = Z.DataMgr.Get("action_data")
local unionWardanceRewardCountID = 24
local VibeLevel2ParamMap = {
  [0] = "default",
  [1] = "default",
  [2] = "white",
  [3] = "cyan",
  [4] = "pink"
}
local CheckErrorCode = function(errorCode)
  if errorCode and errorCode ~= 0 then
    Z.TipsVM.ShowTips(errorCode)
    return false
  end
  return true
end

function UnionWarDanceVM:InitWatcher()
  unionWarDanceData_:InitContainerWatcher()
end

function UnionWarDanceVM:UnInitWatcher()
  unionWarDanceData_:UnInitContainerWatcher()
end

function UnionWarDanceVM:OpenDanceView()
  Z.UIMgr:OpenView("union_wardance_window")
end

function UnionWarDanceVM:CloseDanceView()
  Z.UIMgr:CloseView("union_wardance_window")
end

function UnionWarDanceVM:RequestBeginDance()
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  local vRequest = {}
  vRequest.unionId = unionId
  local reply = worldProxy_.BeginDance(vRequest, unionWarDanceData_.CancelSource:CreateToken())
  if CheckErrorCode(reply) == false then
    return
  end
end

function UnionWarDanceVM:ShowUnionWarDanceVibe(forceStart)
  local memberCount = unionWarDanceData_:GetMemberCount()
  local vibeLevel = unionWarDanceData_:getCurSceneVibeLevel(memberCount)
  unionWarDanceData_.vibeLevel = vibeLevel
  self:ChangeVibe(vibeLevel, forceStart)
end

function UnionWarDanceVM:isInWarDanceActivity()
  local seasonVM_ = Z.VMMgr.GetVM("season")
  local seasonID = seasonVM_.GetCurrentSeasonId()
  local danceActivityTableRow = unionWarDanceData_:GetConfigDataBySeasonID(seasonID)
  if not danceActivityTableRow then
    return false
  end
  local timerID = danceActivityTableRow.TimerId
  return Z.TimeTools.CheckIsInTimeByTimeId(timerID)
end

function UnionWarDanceVM:isinWillOpenWarDanceActivity()
  local seasonVM_ = Z.VMMgr.GetVM("season")
  local seasonID = seasonVM_.GetCurrentSeasonId()
  local danceActivityTableRow = unionWarDanceData_:GetConfigDataBySeasonID(seasonID)
  if not danceActivityTableRow then
    return false
  end
  local timerID = danceActivityTableRow.PreTimerId
  return Z.TimeTools.CheckIsInTimeByTimeId(timerID)
end

function UnionWarDanceVM:AddChatNotice(chatHyperID)
  local chatMainVm = Z.VMMgr.GetVM("chat_main")
  chatMainVm.addTipsByConfigId(chatHyperID, false)
end

function UnionWarDanceVM:NoticeActivityWillOpen()
  local unionVM = Z.VMMgr.GetVM("union")
  if unionVM:GetPlayerUnionId() ~= 0 and unionVM:GetUnionSceneIsUnlock() then
    self:AddChatNotice(1005001)
  end
end

function UnionWarDanceVM:NoticeActivityOpen()
  local unionVM = Z.VMMgr.GetVM("union")
  if unionVM:GetPlayerUnionId() ~= 0 and unionVM:GetUnionSceneIsUnlock() then
    self:AddChatNotice(1005002)
    self:OpenActivityInvite()
  end
end

function UnionWarDanceVM:OpenActivityInvite()
  local countID = unionWardanceRewardCountID
  local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
  local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
  if normalAwardCount <= 0 then
    return
  end
  local unionInviteFunc = function(callData, flag, cancelSource)
    if flag then
      Z.CoroUtil.create_coro_xpcall(function()
        self:AsyncEnterUnionWardance(cancelSource:CreateToken())
      end)()
    end
  end
  local teamTipData_ = Z.DataMgr.Get("team_tip_data")
  local content_ = Lang("UnionWarDanceNotice")
  local info = {
    charId = "",
    tipsType = E.InvitationTipsType.UnionWarDance,
    content = content_,
    cd = Z.Global.TeamInviteLastTime,
    func = unionInviteFunc,
    funcParam = {}
  }
  teamTipData_:SetCacheData(info)
end

function UnionWarDanceVM:NoticeActivityEnd()
  local unionVM = Z.VMMgr.GetVM("union")
  if unionVM:GetPlayerUnionId() ~= 0 and unionVM:GetUnionSceneIsUnlock() then
    self:AddChatNotice(1005004)
  end
end

function UnionWarDanceVM:StartUnionWarDanceMusic(forceStart)
  local scenceId = Z.StageMgr.GetCurrentSceneId()
  local scenceData = Z.TableMgr.GetTable("SceneTableMgr").GetRow(scenceId)
  if scenceData == nil then
    return
  end
  local subType = scenceData.SceneSubType
  if subType ~= E.SceneSubType.Union then
    return
  end
  if not self:isInWarDanceActivity() and not forceStart then
    return
  end
  local _, musicList = unionWarDanceData_:GetCurBGMSerizes()
  local curMusicDuration, curMusicID = unionWarDanceData_:GetCurBGMInfo()
  self.curMusicID = curMusicID
  self.StopDanceMusic = false
  self:StartUnionWarDanceMusicRound(musicList, curMusicDuration)
end

function UnionWarDanceVM:StartUnionWarDanceMusicRound(musicList, curMusicDuration)
  if self.StopDanceMusic then
    return
  end
  local callBackFunction = function()
    local nextMusicID = self.curMusicID
    if #musicList < 1 then
      return
    end
    for i = 1, #musicList do
      if musicList[i] == self.curMusicID then
        if i == #musicList then
          nextMusicID = musicList[1]
        else
          nextMusicID = musicList[i + 1]
        end
      end
    end
    self.curMusicID = nextMusicID
    self:StartUnionWarDanceMusicRound(musicList, 0)
  end
  local seekTo = math.floor(curMusicDuration * 1000)
  Z.AudioMgr:PlayBGMSeek(self.curMusicID, seekTo, callBackFunction)
end

function UnionWarDanceVM:EndUnionWarDanceMusic()
  self.StopDanceMusic = true
  Z.AudioMgr:Play("BGM_Assoc_Hall")
end

function UnionWarDanceVM:ShowBuffTips(buffID)
  local buffCfgData = Z.TableMgr.GetTable("BuffTableMgr").GetRow(buffID)
  if not buffCfgData then
    return
  end
  Z.TipsVM.ShowTipsLang(1005006, {
    buffname = buffCfgData.Name
  })
end

function UnionWarDanceVM:HideUnionWarDanceVibe()
  self:ChangeVibe(0)
end

function UnionWarDanceVM:ChangeVibe(vibeLevel, forceStart)
  local scenceId = Z.StageMgr.GetCurrentSceneId()
  if scenceId == 0 then
    return
  end
  local scenceData = Z.TableMgr.GetTable("SceneTableMgr").GetRow(scenceId)
  if scenceData == nil then
    return
  end
  local subType = scenceData.SceneSubType
  if subType ~= E.SceneSubType.Union then
    return
  end
  if not self:isInWarDanceActivity() and not forceStart then
    return
  end
  Z.LevelMgr.FireSceneEvent({
    eventType = 12,
    strParams = {
      VibeLevel2ParamMap[vibeLevel]
    }
  })
end

function UnionWarDanceVM:BeginDance()
  local curActionTable = unionWarDanceData_:GetCurDanceSerizes()
  local curActionDuration, curActionID = unionWarDanceData_:GetCurDanceInfo()
  if curActionDuration == nil or curActionID == nil then
    return
  end
  local actionDuration = actionData:GetDurationLoopTime(curActionID, E.ExpressionType.Action)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  Z.CoroUtil.create_coro_xpcall(function()
    local vRequest = {}
    vRequest.unionId = unionId
    vRequest.actionId = curActionID
    local reply = worldProxy_.BeginDanceActive(vRequest, unionWarDanceData_.CancelSource:CreateToken())
    if CheckErrorCode(reply) == false then
      return
    end
    Z.ZAnimActionPlayMgr:PlayAction(curActionID, false, Z.ServerTime:GetDanceNormalizedTime(actionDuration))
  end)()
end

function UnionWarDanceVM:StopDance()
  Z.ZAnimActionPlayMgr:ResetAction()
end

function UnionWarDanceVM:AsyncEnterUnionWardance(cancelToken)
  local unionVM_ = Z.VMMgr.GetVM("union")
  local unionId = unionVM_:GetPlayerUnionId()
  if unionId == 0 then
    Z.TipsVM.ShowTips(1000593)
    return
  end
  local isUnionSceneUnlock = unionVM_:GetUnionSceneIsUnlock()
  if not isUnionSceneUnlock then
    Z.TipsVM.ShowTips(1000594)
    return
  end
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local configData_ = Z.UnionActivityConfig.HuntDungeonCount
  for _, value in ipairs(configData_) do
    local sceneId = value[1]
    if sceneId == curSceneId then
      Z.TipsVM.ShowTips(100124)
      return
    end
  end
  local vRequest = {}
  vRequest.unionId = unionId
  vRequest.enterType = Z.PbEnum("UnionEnterScene", "UnionEnterSceneDance")
  local errrCode = worldProxy_.EnterUnionScene(vRequest, cancelToken)
  CheckErrorCode(errrCode)
end

function UnionWarDanceVM:AsyncGetPersonalReward(cancelToken)
  local request = {}
  local reply = worldProxy_.GetDanceBallAward(request, cancelToken)
  CheckErrorCode(reply)
end

return UnionWarDanceVM
