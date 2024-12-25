local rankInfoChanged = function(vRankId)
  if vRankId == nil then
    vRankId = -1
  end
  Z.EventMgr:Dispatch(Z.ConstValue.ParkourActionEvt.SyncRankInfo, vRankId)
end
local recordInfoChanged = function(result, vRecord)
  Z.EventMgr:Dispatch(Z.ConstValue.ParkourActionEvt.NotifyResultRecord, result, vRecord)
end
local closeTooltipView = function()
  Z.UIMgr:CloseView("parkour_tooltip_window")
end
local openTooltipView = function()
  local parkourData = Z.DataMgr.Get("parkour_tooltip_data")
  if parkourData.DungeonHideTag and parkourData.MainViewHideTag then
    Z.UIMgr:OpenView("parkour_tooltip_window")
  elseif Z.UIMgr:IsActive("parkour_tooltip_window") then
    Z.UIMgr:GetView("parkour_tooltip_window"):Hide()
  end
end
local setMainViewHideTag = function(isVisible)
  local parkourData = Z.DataMgr.Get("parkour_tooltip_data")
  parkourData:SetMainViewHideTag(isVisible)
  openTooltipView()
end
local setDungeonHideTag = function(isVisible)
  local parkourData = Z.DataMgr.Get("parkour_tooltip_data")
  parkourData:SetDungeonViewHideTag(isVisible)
  openTooltipView()
end
local getParkourRecord = function(dungeonId)
  local parkourData = Z.DataMgr.Get("parkour_tooltip_data")
  return parkourData:GetParkourRecord(dungeonId)
end
local setParkourRecordPlaceholder = function(placeholderParam)
  if placeholderParam == nil then
    placeholderParam = {}
  end
  if placeholderParam.record == nil then
    placeholderParam.record = {}
  end
  placeholderParam.record.recordData1 = getParkourRecord
  placeholderParam.record.recordData2 = getParkourRecord
  return placeholderParam
end
local getParkourRankingByContainer = function()
  local rankMap = Z.ContainerMgr.DungeonSyncData.dungeonRank.dungeonRankMap
  local charId = Z.ContainerMgr.CharSerialize.charId
  if not rankMap or not next(rankMap) then
    return
  end
  for k, v in pairs(rankMap) do
    if k == charId and v and v.rank then
      return v
    end
  end
  return nil
end
local setStartMark = function(isShow)
  local parkourData = Z.DataMgr.Get("parkour_tooltip_data")
  parkourData:SetStartMark(isShow)
end
local setUserOptionSelect = function(cancelSource)
  local interactionVm = Z.VMMgr.GetVM("interaction")
  if not Z.StageMgr.GetIsInDungeon() then
    return
  end
  interactionVm.AsyncUserOptionSelect("WorldEvent_Multiparkour_GoBack", cancelSource:CreateToken())
end
local getDungeonTimerData = function(timerType)
  local timerData = {}
  local parkourData = Z.DataMgr.Get("parkour_tooltip_data")
  if timerType == E.DungeonTimerType.DungeonTimerTypeMiddlerCommon then
    local rankFunction = function()
      local parkourtipsVm = Z.VMMgr.GetVM("parkourtips")
      parkourtipsVm.SetStartMark(false)
    end
    local limitTime = Z.Global.TimeLimitQuestAlert
    if not string.zisEmpty(limitTime) then
      limitTime = tonumber(limitTime)
    end
    timerData.rankCallBack = rankFunction
    timerData.timeLimitNumber = limitTime
    timerData.rankData = getParkourRankingByContainer()
    timerData.isShowRank = true
    timerData.rankStartMark = parkourData:GetStartMark()
    timerData.isShowStartNode = true
  elseif timerType == E.DungeonTimerType.DungeonTimerTypeWait then
    timerData.isShowZeroSecond = true
  end
  return timerData
end
local ret = {
  OpenTooltipView = openTooltipView,
  CloseTooltipView = closeTooltipView,
  RecordInfoChanged = recordInfoChanged,
  RankInfoChanged = rankInfoChanged,
  SetMainViewHideTag = setMainViewHideTag,
  SetDungeonHideTag = setDungeonHideTag,
  SetParkourRecordPlaceholder = setParkourRecordPlaceholder,
  GetParkourRankingByContainer = getParkourRankingByContainer,
  SetStartMark = setStartMark,
  SetUserOptionSelect = setUserOptionSelect,
  GetDungeonTimerData = getDungeonTimerData
}
return ret
