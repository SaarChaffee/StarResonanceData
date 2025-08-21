local super = require("ui.model.data_base")
E.SceneLineState = {
  SceneLineStatusNone = Z.PbEnum("ESceneLineStatus", "SceneLineStatusNone"),
  SceneLineStatusLow = Z.PbEnum("ESceneLineStatus", "SceneLineStatusLow"),
  SceneLineStatusMedium = Z.PbEnum("ESceneLineStatus", "SceneLineStatusMedium"),
  SceneLineStatusHigh = Z.PbEnum("ESceneLineStatus", "SceneLineStatusHigh"),
  SceneLineStatusFull = Z.PbEnum("ESceneLineStatus", "SceneLineStatusFull"),
  SceneLineStatusRecycle = Z.PbEnum("ESceneLineStatus", "SceneLineStatusRecycle")
}
local SceneLineData = class("SceneLineData", super)

function SceneLineData:ctor()
  super.ctor(self)
  self.PlayerLineId = nil
  self.PlayerSceneGuid = nil
  self.RecycleEndTime = nil
  self.LastRequestTime = nil
  self.LineDataList = nil
  self.SocialDataBySceneGuidDict = nil
end

function SceneLineData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function SceneLineData:Clear()
  self.PlayerLineId = nil
  self.PlayerSceneGuid = nil
  self.RecycleEndTime = nil
  self.LastRequestTime = nil
  self.LineDataList = nil
  self.SocialDataBySceneGuidDict = nil
end

function SceneLineData:UnInit()
  self.CancelSource:Recycle()
end

function SceneLineData:IsValidData()
  return self.LineDataList ~= nil and self.LastRequestTime ~= nil
end

function SceneLineData:SetLineDataList(dataList)
  for _, lineData in ipairs(dataList) do
    lineData.sort = self:GetLineDataSort(lineData)
  end
  self.LineDataList = dataList
end

function SceneLineData:SetPlayerSceneLineData(lineId, sceneGuid)
  self.PlayerLineId = lineId
  self.PlayerSceneGuid = sceneGuid
end

function SceneLineData:GetPlayerSceneLineDataFromList()
  if self.LineDataList then
    for _, lineData in ipairs(self.LineDataList) do
      if lineData.sceneGuid == self.PlayerSceneGuid then
        return lineData
      end
    end
  end
  return nil
end

function SceneLineData:SetRecycleEndTime(endTime, isInit)
  self.RecycleEndTime = endTime
  if not isInit then
    Z.EventMgr:Dispatch(Z.ConstValue.SceneLine.RefreshSceneLineUI, endTime)
  end
end

function SceneLineData:GetLineDataSort(lineData)
  if lineData.status == E.SceneLineState.SceneLineStatusHigh then
    return 5
  elseif lineData.status == E.SceneLineState.SceneLineStatusMedium then
    return 4
  elseif lineData.status == E.SceneLineState.SceneLineStatusLow then
    return 3
  elseif lineData.status == E.SceneLineState.SceneLineStatusFull then
    return 2
  elseif lineData.status == E.SceneLineState.SceneLineStatusRecycle then
    return 1
  else
    return 0
  end
end

function SceneLineData:GetLineInfoDataList(searchLineId)
  local resList = {}
  if self.LineDataList == nil then
    return resList
  end
  if searchLineId == nil then
    for _, lineData in ipairs(self.LineDataList) do
      if lineData.status ~= E.SceneLineState.SceneLineStatusNone then
        resList[#resList + 1] = lineData
      end
    end
  else
    for _, lineData in ipairs(self.LineDataList) do
      if lineData.status ~= E.SceneLineState.SceneLineStatusNone and lineData.status ~= E.SceneLineState.SceneLineStatusRecycle and lineData.lineId == searchLineId then
        resList[#resList + 1] = lineData
        break
      end
    end
  end
  if 1 < #resList then
    table.sort(resList, function(a, b)
      if a.sort == b.sort then
        return a.lineId < b.lineId
      else
        return a.sort > b.sort
      end
    end)
  end
  return resList
end

return SceneLineData
