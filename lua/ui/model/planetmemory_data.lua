local super = require("ui.model.data_base")
local PlanetMemoryData = class("PlanetmemoryData", super)
E.PlanetMemorySeasonConfigEnum = {
  SeasonId = 1,
  SeasonName = 2,
  SeasonAward = 3,
  SeasonAffix = 4,
  SeasonAwardDesc = 5,
  LockedPointModel = 6,
  UnlockPointModel = 7,
  FinishedPointModel = 8,
  StartPointModel = 9,
  CurrentPointModel = 10,
  SpecialPointEffect = 11,
  SmokePosition = 12,
  LinkModelRadius = 13,
  SmokeModel = 14,
  RoomTypeIcon = 15,
  RoomTypeBallIcon = 16,
  SceneZoom = 17,
  FirstRoomCamOffset = 18
}
E.PlanetMemoryCameraAnimType = {Enter = "enter", Move = "move"}
E.PlanetMemoryCreateModelType = {Model = 1, Effect = 2}

function PlanetMemoryData:ctor()
  super.ctor(self)
  self.currentPointModel_ = -1
  self.curPlanetMemoryID_ = 1
  self.planetMemoryState_ = {}
  self.planetMemoryFogUnlockedState_ = {}
  self.isContinue_ = false
  self.planetCopyStateData_ = {}
  self.nowSeasonId_ = 0
  self.nowSeasonDay_ = 0
end

function PlanetMemoryData:Init()
end

function PlanetMemoryData:UnInit()
end

function PlanetMemoryData:SetSeasonData(seasonId, seasonDay)
  self.nowSeasonId_ = seasonId
  self.nowSeasonDay_ = seasonDay
end

function PlanetMemoryData:GetNowSeasonId()
  local seasonVm = Z.VMMgr.GetVM("season")
  local seasonId, _ = seasonVm.GetSeasonByTime()
  return seasonId
end

function PlanetMemoryData:GetSeasonDay()
  local seasonVm = Z.VMMgr.GetVM("season")
  local _, seasonDay = seasonVm.GetSeasonByTime()
  return seasonDay
end

function PlanetMemoryData:GetMonsterIconPath(configType, textureCfg)
  if not configType or not textureCfg then
    return
  end
  if #textureCfg < 1 then
    return
  end
  if configType == E.PlanetmemoryType.Common then
    return textureCfg[1]
  elseif configType == E.PlanetmemoryType.Boss then
    return textureCfg[3]
  elseif configType == E.PlanetmemoryType.Cream then
    return textureCfg[2]
  elseif configType == E.PlanetmemoryType.Special then
    return textureCfg[4]
  end
end

function PlanetMemoryData:GetLastFinishedPlanetMemoryID()
  local passList = Z.ContainerMgr.CharSerialize.planetMemory
  if passList and passList.passRoom and #passList.passRoom >= 1 then
    self.curPlanetMemoryID_ = passList.passRoom[#passList.passRoom]
  end
  return self.curPlanetMemoryID_
end

function PlanetMemoryData:ClearPlanetMemoryState()
  self.planetMemoryState_ = {}
end

function PlanetMemoryData:GetPlanetMemoryState()
  return self.planetMemoryState_
end

function PlanetMemoryData:AddPlanetMenoryState(roomId, state)
  self.planetMemoryState_[roomId] = state
end

function PlanetMemoryData:ClearPlanetMemoryFogUnlockedState()
  self.planetMemoryFogUnlockedState_ = {}
end

function PlanetMemoryData:GetPlanetMemoryFogUnlockedState()
  return self.planetMemoryFogUnlockedState_
end

function PlanetMemoryData:AddPlanetMemoryFogUnlockedState(roomId, state)
  self.planetMemoryFogUnlockedState_[roomId] = state
end

function PlanetMemoryData:GetCurPlanetMemoryPassNum()
  local passList = Z.ContainerMgr.CharSerialize.planetMemory
  if not (passList and next(passList)) or not next(passList.passRoom) then
    return 0
  end
  return table.zcount(passList.passRoom)
end

function PlanetMemoryData:SetPlanetMemoryIsContinue(state)
  self.isContinue_ = state
end

function PlanetMemoryData:GetPlanetMemoryIsContinue()
  return self.isContinue_
end

function PlanetMemoryData:SetPlanetCopyState(state)
  self.planetCopyStateData_ = state
end

function PlanetMemoryData:ClearPlanetCopyState()
  self.planetCopyStateData_ = {}
end

function PlanetMemoryData:GetPlanetCopyState()
  return self.planetCopyStateData_
end

function PlanetMemoryData:Clear()
  self.currentPointModel_ = -1
  self.specialPointEffect_ = {}
  self.curPlanetMemoryID_ = 1
  self:ClearPlanetMemoryState()
  self.isContinue_ = false
  self:ClearPlanetCopyState()
  self:ClearPlanetMemoryFogUnlockedState()
end

return PlanetMemoryData
