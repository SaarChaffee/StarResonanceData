local super = require("ui.model.data_base")
E.TrialRoadType = {
  Power = 1,
  Auxiliary = 2,
  Guard = 3
}
E.TrialRoadTargetState = {
  UnFinished = Z.PbEnum("ETrialRoadAwardState", "TrialRoadAwardStateNone"),
  UnGetReward = Z.PbEnum("ETrialRoadAwardState", "TrialRoadAwardStateFinish"),
  GetReward = Z.PbEnum("ETrialRoadAwardState", "TrialRoadAwardStateGet")
}
local TrialRoadData = class("TrialRoadData", super)

function TrialRoadData:ctor()
  super.ctor(self)
  self.dictRoomData_ = nil
  self.DictUnrealSceneStyle = {
    [E.TrialRoadType.Power] = E.UnrealSceneStyle.Red,
    [E.TrialRoadType.Guard] = E.UnrealSceneStyle.Green,
    [E.TrialRoadType.Auxiliary] = E.UnrealSceneStyle.Blue
  }
  self.DictTypeIconPath = {
    [E.TrialRoadType.Power] = "ui/atlas/trialroad/trialroad_icon_attack",
    [E.TrialRoadType.Guard] = "ui/atlas/trialroad/trialroad_icon_survival",
    [E.TrialRoadType.Auxiliary] = "ui/atlas/trialroad/trialroad_icon_assist"
  }
  self.planetCopyStateData_ = {}
  self.finishTargetColor = "#cce992"
  self.unfinishTargetColor = "#FFFFFF"
end

function TrialRoadData:InitTrialRoadRoomDict()
  if self.dictRoomData_ then
    self:refreshTrialRoadRoomData()
    return
  end
  self.dictRoomData_ = {
    [E.TrialRoadType.Power] = {},
    [E.TrialRoadType.Guard] = {},
    [E.TrialRoadType.Auxiliary] = {}
  }
  local rowDatas_ = Z.TableMgr.GetTable("TrialRoadTableMgr").GetDatas()
  for k, v in pairs(rowDatas_) do
    local roomData_ = self:createTrialRoadData(v)
    self.dictRoomData_[v.RoomType][v.RoomId] = roomData_
  end
  self:refreshTrialRoadRoomData()
end

function TrialRoadData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function TrialRoadData:UnInit()
  self.CancelSource:Recycle()
  self.dictRoomData_ = nil
end

function TrialRoadData:Clear()
  self.dictRoomData_ = nil
end

function TrialRoadData:ClearPlanetCopyState()
  self.planetCopyStateData_ = {}
end

function TrialRoadData:createTrialRoadData(trialRoadInfo)
  local data_ = {}
  data_.TrialRoadInfo = trialRoadInfo
  data_.IsFinished = false
  data_.ListRoomTarget = {}
  data_.IsLastFinish = trialRoadInfo.UnlockRoomId == 0
  if trialRoadInfo.ExtraTarget and next(trialRoadInfo.ExtraTarget) then
    for k, v in ipairs(trialRoadInfo.ExtraTarget) do
      local targetdata_ = {}
      targetdata_.Index = v[1]
      targetdata_.TargetId = v[2]
      targetdata_.AwardId = v[3]
      targetdata_.RoomId = trialRoadInfo.RoomId
      table.insert(data_.ListRoomTarget, targetdata_)
    end
  end
  self:RefreshTrialRoadRoomDataUnlockTime(data_)
  return data_
end

function TrialRoadData:GetTrialRoadRoomDataListByType(type)
  return self.dictRoomData_[type]
end

function TrialRoadData:RefreshRoomTargetState(roomId)
  local roomData = self:GetTrialRoadRoomDataById(roomId)
  if not roomData then
    return
  end
  local targetProgressDict_ = Z.ContainerMgr.CharSerialize.trialRoad.roomTargetAward[roomId]
  for _, v in ipairs(roomData.ListRoomTarget) do
    if targetProgressDict_ and targetProgressDict_.targetProgress and targetProgressDict_.targetProgress[v.TargetId] then
      v.TargetState = targetProgressDict_.targetProgress[v.TargetId].awardState
    else
      v.TargetState = E.TrialRoadTargetState.UnFinished
    end
  end
end

function TrialRoadData:GetTrialRoadRoomDataById(roomId)
  local roomData_ = self.dictRoomData_[E.TrialRoadType.Power][roomId]
  if roomData_ == nil then
    roomData_ = self.dictRoomData_[E.TrialRoadType.Auxiliary][roomId]
  end
  if roomData_ == nil then
    roomData_ = self.dictRoomData_[E.TrialRoadType.Guard][roomId]
  end
  if roomData_ == nil then
    logError("\230\156\170\230\137\190\229\136\176roomdata\239\188\140roomid\239\188\154" .. roomId)
  end
  return roomData_
end

function TrialRoadData:RefreshTrialRoadRoomDataUnlockTime(roomData)
  if roomData ~= nil then
    local dungeonTableRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(roomData.TrialRoadInfo.DungeonId)
    if not dungeonTableRow then
      return nil
    end
    local bResult = true
    local progress
    for _, v in ipairs(dungeonTableRow.Condition) do
      if v[1] == E.DungeonCondition.TimeIntervalConditionalLimitations then
        bResult, _, progress = Z.ConditionHelper.GetSingleConditionDesc(v[1], v[2], v[3])
      end
    end
    if bResult then
      roomData.IsUnLockTime = true
    else
      roomData.IsUnLockTime = bResult
      if not bResult and progress then
        local timeData = Z.TimeFormatTools.FormatToDHMS(math.floor(progress), false, false)
        return timeData
      end
    end
  end
  return nil
end

function TrialRoadData:refreshTrialRoadRoomData()
  for k, v in pairs(Z.ContainerMgr.CharSerialize.trialRoad.passRoom) do
    local roomData = self:GetTrialRoadRoomDataById(v)
    roomData.IsFinished = true
  end
  for _, dict in pairs(self.dictRoomData_) do
    for _, v in pairs(dict) do
      if v.TrialRoadInfo.UnlockRoomId ~= 0 then
        local data_ = dict[v.TrialRoadInfo.UnlockRoomId]
        if data_ then
          v.IsLastFinish = data_.IsFinished
        end
      else
        v.IsLastFinish = true
      end
      self:RefreshRoomTargetState(v.TrialRoadInfo.RoomId)
    end
  end
end

function TrialRoadData:GetNextRoomData(roomId)
  local rowDatas_ = Z.TableMgr.GetTable("TrialRoadTableMgr").GetDatas()
  for k, v in pairs(rowDatas_) do
    if v.UnlockRoomId ~= 0 and v.UnlockRoomId == roomId then
      return v
    end
  end
  return nil
end

return TrialRoadData
