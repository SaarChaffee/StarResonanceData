local super = require("ui.model.data_base")
local UnionWarDanceData = class("UnionWarDanceData", super)

function UnionWarDanceData:ctor()
  super.ctor(self)
end

function UnionWarDanceData:Init()
  self.isDancing = false
  self.isInArea_ = false
  self.CancelSource = Z.CancelSource.Rent()
end

function UnionWarDanceData:Clear()
end

function UnionWarDanceData:UnInit()
  self.isInArea_ = false
  self.CancelSource:Recycle()
end

function UnionWarDanceData:GetMemberCount()
  local danceBall = Z.ContainerMgr.DungeonSyncData.dungeonUnionInfo.danceBall
  if not danceBall then
    return 0
  end
  return table.zcount(danceBall.dancers)
end

function UnionWarDanceData:SetIsInDanceArea(isInArea)
  self.isInArea_ = isInArea
  if not isInArea then
    self.isDancing = false
  end
end

function UnionWarDanceData:IsInDanceArea()
  return self.isInArea_
end

function UnionWarDanceData:GetDancedInfo()
  local danceBall = Z.ContainerMgr.DungeonSyncData.dungeonUnionInfo.danceBall
  if not danceBall then
    return nil
  end
  local selfCharID = Z.ContainerMgr.CharSerialize.charId
  if danceBall.dancers == nil then
    return nil
  end
  return danceBall.dancers[selfCharID]
end

function UnionWarDanceData:GetDancedScore()
  local danceBall = Z.ContainerMgr.DungeonSyncData.dungeonUnionInfo.danceBall
  if not danceBall then
    return 0
  end
  return danceBall.sumDanceScore
end

function UnionWarDanceData:GetDancedBuff()
  local danceBall = Z.ContainerMgr.DungeonSyncData.dungeonUnionInfo.danceBall
  if not danceBall then
    return 0
  end
  return danceBall.buffId
end

function UnionWarDanceData:InitContainerWatcher()
  self.selfDanceInfo = self:GetDancedInfo()
  
  function self.watcherFun_(container, dirtys)
    if dirtys.dancers then
      local curCount = table.zcount(container.dancers)
      if curCount ~= self.lastCnt then
        self.lastCnt = curCount
        if self.vibeLevel and self.vibeLevel ~= self:getCurSceneVibeLevel(curCount) then
          self.vibeLevel = self:getCurSceneVibeLevel(curCount)
          self:changeVibe(self.vibeLevel)
        end
        Z.EventMgr:Dispatch(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceMemberCnt, curCount)
      end
      if not self.selfDanceInfo then
        self.selfDanceInfo = self:GetDancedInfo()
        if not self.selfDanceInfo then
          return
        end
        self.selfDanceInfo.Watcher:RegWatcher(self.selfInfoWatcherFunc_)
        if self.selfDanceInfo.isDancing then
          Z.EventMgr:Dispatch(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfIsDancing, self.selfDanceInfo.isDancing)
          local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
          unionWarDanceVM:BeginDance()
        end
        self.isDancing = self.selfDanceInfo.isDancing
      end
    end
    if dirtys.sumDanceScore then
      Z.EventMgr:Dispatch(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceTotalTime, self:GetDancedScore())
    end
    if dirtys.buffId then
      local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
      unionWarDanceVM:ShowBuffTips(self:GetDancedBuff())
    end
  end
  
  function self.selfInfoWatcherFunc_(container, dirtys)
    local selfDanceInfo = self:GetDancedInfo()
    if not selfDanceInfo then
      return
    end
    if dirtys.isDancing then
      local isDancing = selfDanceInfo.isDancing
      Z.EventMgr:Dispatch(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfIsDancing, isDancing)
      if isDancing == true then
        local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
        unionWarDanceVM:BeginDance()
      end
      self.isDancing = isDancing
    end
    if dirtys.hasSend then
      Z.EventMgr:Dispatch(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfRewardSended, selfDanceInfo.hasSend)
    end
    if dirtys.danceSecs then
      Z.EventMgr:Dispatch(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfTotalTime, selfDanceInfo.danceSecs)
    end
  end
  
  self.danceBall = Z.ContainerMgr.DungeonSyncData.dungeonUnionInfo.danceBall
  if self.danceBall then
    self.danceBall.Watcher:RegWatcher(self.watcherFun_)
  end
  if self.selfDanceInfo then
    self.selfDanceInfo.Watcher:RegWatcher(self.selfInfoWatcherFunc_)
  end
end

function UnionWarDanceData:UnInitContainerWatcher()
  if self.danceBall then
    self.danceBall.Watcher:UnregWatcher(self.watcherFun_)
  end
  if self.selfDanceInfo then
    self.selfDanceInfo.Watcher:UnregWatcher(self.selfInfoWatcherFunc_)
  end
end

function UnionWarDanceData:getCurSceneVibeLevel(memberCount)
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  local seasonID = self.seasonVM_.GetCurrentSeasonId()
  local danceActivityTableRow = self:GetConfigDataBySeasonID(seasonID)
  if not danceActivityTableRow then
    return 0
  end
  for k, v in pairs(danceActivityTableRow.Vibenumber) do
    if memberCount < v then
      return k
    end
  end
  return #danceActivityTableRow.Vibenumber + 1
end

function UnionWarDanceData:GetWillOpenTimeStamp()
  local seasonVM_ = Z.VMMgr.GetVM("season")
  local seasonID = seasonVM_.GetCurrentSeasonId()
  local danceActivityTableRow = self:GetConfigDataBySeasonID(seasonID)
  if not danceActivityTableRow then
    return 0
  end
  local timerID = danceActivityTableRow.PreTimerId
  local hasEnd, _, endTime = Z.TimeTools.GetCycleEndTimeByTimeId(timerID)
  if not hasEnd then
    return 0
  end
  return endTime
end

function UnionWarDanceData:GetConfigDataBySeasonID(seasonID)
  local danceActivityMgr_ = Z.TableMgr.GetTable("DanceActivityMgr")
  local danceActivityTableRows = danceActivityMgr_:GetDatas()
  for k, v in pairs(danceActivityTableRows) do
    if v.SeasonId == seasonID then
      return v
    end
  end
  return nil
end

function UnionWarDanceData:changeVibe(vibeLevel)
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  unionWarDanceVM:ChangeVibe(vibeLevel)
end

function UnionWarDanceData:GetCurDanceID()
  local danceBall = Z.ContainerMgr.DungeonSyncData.dungeonUnionInfo.danceBall
  if not danceBall then
    return 0
  end
  return danceBall.randIndex + 1
end

function UnionWarDanceData:GetCurDanceSerizes()
  local danceId = self:GetCurDanceID()
  if danceId == -1 then
    return
  end
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  local seasonID = self.seasonVM_.GetCurrentSeasonId()
  local danceActivityTableRow = self:GetConfigDataBySeasonID(seasonID)
  if not danceActivityTableRow then
    return
  end
  if not danceActivityTableRow.DanceRandom or not danceActivityTableRow.DanceRandom[danceId] then
    return
  end
  local danceList = danceActivityTableRow.DanceRandom[danceId]
  local actions = {}
  local actionData = Z.DataMgr.Get("action_data")
  for i = 1, #danceList do
    local actionTime = actionData:GetDurationLoopTime(danceList[i], E.ExpressionType.Action)
    actions[danceList[i]] = actionTime
  end
  return actions
end

function UnionWarDanceData:GetCurDanceInfo()
  local actions = self:GetCurDanceSerizes()
  if not actions then
    return
  end
  local sumTime = 0
  for k, v in pairs(actions) do
    sumTime = sumTime + v
  end
  if sumTime == 0 then
    return
  end
  local serverTime = Z.ServerTime:GetServerTime()
  local danceBall = Z.ContainerMgr.DungeonSyncData.dungeonUnionInfo.danceBall
  if not danceBall then
    return
  end
  local activityStartTime = danceBall.beginTime
  local dancedSec = (serverTime - activityStartTime) / 1000
  if dancedSec < 0 then
    return
  end
  local roundTime = dancedSec % sumTime
  for k, v in pairs(actions) do
    if v > roundTime then
      return roundTime, k
    else
      roundTime = roundTime - v
    end
  end
end

function UnionWarDanceData:GetCurBGMSerizes()
  local danceId = self:GetCurDanceID()
  if danceId == -1 then
    return
  end
  self.seasonVM_ = Z.VMMgr.GetVM("season")
  local seasonID = self.seasonVM_.GetCurrentSeasonId()
  local danceActivityTableRow = self:GetConfigDataBySeasonID(seasonID)
  if not danceActivityTableRow then
    return
  end
  if not danceActivityTableRow.MusicRandom or not danceActivityTableRow.MusicRandom[danceId] then
    return
  end
  local musicList = danceActivityTableRow.MusicRandom[danceId]
  local musics = {}
  local misicList = {}
  for i = 1, #musicList do
    local musicTime = danceActivityTableRow.MusicTime[danceId][i]
    musics[musicList[i]] = musicTime
    table.insert(misicList, musicList[i])
  end
  return musics, musicList
end

function UnionWarDanceData:GetCurBGMInfo()
  local musics = self:GetCurBGMSerizes()
  if not musics then
    return
  end
  local sumTime = 0
  for k, v in pairs(musics) do
    sumTime = sumTime + v
  end
  if sumTime == 0 then
    return
  end
  local normalizedTime = Z.ServerTime:GetDanceNormalizedTime(sumTime)
  local dancedSec = sumTime * normalizedTime
  if dancedSec < 0 then
    return
  end
  local roundTime = dancedSec % sumTime
  for k, v in pairs(musics) do
    if v > roundTime then
      return roundTime, k
    else
      roundTime = roundTime - v
    end
  end
end

function UnionWarDanceData:IsDancing()
  return self.isDancing
end

function UnionWarDanceData:SetRecommendRedChecked(checked)
  self.recommendRedChecked_ = checked
  if checked then
    Z.LocalUserDataMgr.SetLong("UnionDanceActivityChecked", math.floor(Z.TimeTools.Now() / 1000))
  end
end

function UnionWarDanceData:RecommendRedChecked()
  local lastCheckedTime = Z.LocalUserDataMgr.GetLong("UnionDanceActivityChecked", 0)
  if Z.TimeTools.CheckIsSameDay(math.floor(Z.TimeTools.Now() / 1000), lastCheckedTime) then
    return true
  end
  return self.recommendRedChecked_
end

return UnionWarDanceData
