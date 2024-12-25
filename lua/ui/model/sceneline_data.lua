local super = require("ui.model.data_base")
E.SceneLineState = {
  SceneLineStatusDefault = Z.PbEnum("ESceneLineStatus", "SceneLineStatusDefault"),
  SceneLineStatusGreen = Z.PbEnum("ESceneLineStatus", "SceneLineStatusGreen"),
  SceneLineStatusOrange = Z.PbEnum("ESceneLineStatus", "SceneLineStatusOrange"),
  SceneLineStatusRed = Z.PbEnum("ESceneLineStatus", "SceneLineStatusRed"),
  SceneLineStatusBlack = Z.PbEnum("ESceneLineStatus", "SceneLineStatusBlack")
}
local Color_State_Enum = {
  [E.SceneLineState.SceneLineStatusGreen] = "ui/atlas/mainui/else/line_green",
  [E.SceneLineState.SceneLineStatusOrange] = "ui/atlas/mainui/else/line_orange",
  [E.SceneLineState.SceneLineStatusRed] = "ui/atlas/mainui/else/line_red",
  [E.SceneLineState.SceneLineStatusBlack] = "ui/atlas/mainui/else/line_black"
}
local SceneLineData = class("SceneLineData", super)

function SceneLineData:ctor()
  super.ctor(self)
  self.sceneLineList = nil
  self.playerSceneLine = nil
  self.requestCD = Z.Global.LineChangeCD
  self.cdRest = 0
  self.cdTimerMgr = Z.TimerMgr.new()
  self.cdTimer = nil
  self.lineNameDict = {}
end

function SceneLineData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.requestCD = Z.Global.LineChangeCD
end

function SceneLineData:Clear()
  self.sceneLineList = {}
end

function SceneLineData:UnInit()
  self.CancelSource:Recycle()
  self:CloseCDTimer()
  self.cdTimerMgr = nil
  self.lineNameDict = {}
end

function SceneLineData:RefreshSceneLineList(dataList)
  self:ClearSceneLineList()
  for _, value in ipairs(dataList) do
    table.insert(self.sceneLineList, self:CreateSceneLineClass(value))
  end
  local teamData_ = Z.DataMgr.Get("team_data")
  if teamData_.TeamInfo then
    for key, value in pairs(teamData_.TeamInfo.members) do
      if self.playerSceneLine and value.socialData.basicData.sceneId == self.playerSceneLine.sceneId and value.socialData.basicData.charID ~= Z.ContainerMgr.CharSerialize.charBase.charId then
        local lineData = self:GetSceneLinDataById(value.socialData.sceneData.lineId)
        if lineData then
          table.insert(lineData.teamFriendSocialDatas, value.socialData)
        end
      end
    end
  end
  self:SortScenelIneList()
end

function SceneLineData:GetSceneLinDataById(id)
  for _, value in ipairs(self.sceneLineList) do
    if value.sceneLineInfo.lineId == id then
      return value
    end
  end
  return nil
end

function SceneLineData:SortScenelIneList()
  table.sort(self.sceneLineList, function(a, b)
    if self.playerSceneLine and a.sceneLineInfo.lineId == self.playerSceneLine.sceneLineInfo.lineId and b.sceneLineInfo.lineId ~= self.playerSceneLine.sceneLineInfo.lineId then
      return true
    elseif self.playerSceneLine and a.sceneLineInfo.lineId ~= self.playerSceneLine.sceneLineInfo.lineId and b.sceneLineInfo.lineId == self.playerSceneLine.sceneLineInfo.lineId then
      return false
    elseif next(a.teamFriendSocialDatas) ~= nil and next(b.teamFriendSocialDatas) == nil then
      return true
    elseif next(a.teamFriendSocialDatas) == nil and next(b.teamFriendSocialDatas) ~= nil then
      return false
    elseif a.stateSortId == b.stateSortId then
      return a.sceneLineInfo.lineId < b.sceneLineInfo.lineId
    else
      return a.stateSortId > b.stateSortId
    end
  end)
  Z.EventMgr:Dispatch(Z.ConstValue.SceneLine.RefreshSceneLineList)
end

function SceneLineData:CreateSceneLineClass(sceneLineInfo)
  if sceneLineInfo == nil then
    return nil
  end
  local tempLineClass_ = {}
  tempLineClass_.sceneLineInfo = sceneLineInfo
  tempLineClass_.lineColor = self:GetLineColor(sceneLineInfo)
  tempLineClass_.lineName = self:GetLineNameById(sceneLineInfo.lineId)
  tempLineClass_.teamFriendSocialDatas = {}
  tempLineClass_.sceneId = nil
  if sceneLineInfo.status == E.SceneLineState.SceneLineStatusRed then
    tempLineClass_.stateSortId = 4
  elseif sceneLineInfo.status == E.SceneLineState.SceneLineStatusOrange then
    tempLineClass_.stateSortId = 3
  elseif sceneLineInfo.status == E.SceneLineState.SceneLineStatusGreen then
    tempLineClass_.stateSortId = 2
  else
    tempLineClass_.stateSortId = 1
  end
  return tempLineClass_
end

function SceneLineData:ClearSceneLineList()
  self.sceneLineList = {}
end

function SceneLineData:GetSceneLineDataList(searchLineId)
  local resList_ = {}
  local index = 1
  if self.sceneLineList == nil then
    return resList_
  end
  for key, value in ipairs(self.sceneLineList) do
    if searchLineId == nil then
      if value.sceneLineInfo.status ~= E.SceneLineState.SceneLineStatusBlack and value.sceneLineInfo.status ~= E.SceneLineState.SceneLineStatusDefault then
        resList_[index] = value
        index = index + 1
      end
    elseif searchLineId == value.sceneLineInfo.lineId then
      resList_[1] = value
    end
  end
  return resList_
end

function SceneLineData:CheckCanRequst()
  if self.sceneLineList == nil or self.cdRest <= 0 then
    return true
  else
    return false
  end
end

function SceneLineData:RefreshPlayerSceneLine()
  self.socialVm_ = Z.VMMgr.GetVM("social")
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData_ = self.socialVm_.AsyncGetSocialData(0, Z.ContainerMgr.CharSerialize.charId, self.CancelSource:CreateToken())
    if socialData_ == nil then
      logError("\232\175\183\230\177\130\229\136\134\231\186\191\230\149\176\230\141\174\229\164\177\232\180\165, socialdata\228\184\186nil")
      self.playerSceneLine = nil
    else
      local sceneLineData_ = {}
      sceneLineData_.lineId = socialData_.sceneData.lineId
      sceneLineData_.status = E.SceneLineState.SceneLineStatusGreen
      self.playerSceneLine = self:CreateSceneLineClass(sceneLineData_)
      self.playerSceneLine.sceneId = socialData_.basicData.sceneId
    end
    Z.EventMgr:Dispatch(Z.ConstValue.SceneLine.RefreshPlayerSceneLine)
  end)()
end

function SceneLineData:EnterRequestCD()
  self.cdRest = self.requestCD
  self:CloseCDTimer()
  self.cdTimer = self.cdTimerMgr:StartTimer(function()
    if self.cdRest > 0 then
      self.cdRest = self.cdRest - 1
    end
  end, 1, self.requestCD)
end

function SceneLineData:LeaveRequestCD()
  self:CloseCDTimer()
  self.cdRest = 0
end

function SceneLineData:CloseCDTimer()
  if self.cdTimer then
    self.cdTimerMgr.StopTimer(self.cdTimer.StopTimer)
    self.cdTimer = nil
  end
end

function SceneLineData:GetLineNameById(lineId)
  if self.lineNameDict[lineId] == nil then
    local lineName_ = lineId .. Lang("Line")
    self.lineNameDict[lineId] = lineName_
  end
  return self.lineNameDict[lineId]
end

function SceneLineData:ClearCache()
  self.lineNameDict = {}
  self.cdRest = 0
end

function SceneLineData:GetLineColor(line)
  return Color_State_Enum[line.status]
end

return SceneLineData
