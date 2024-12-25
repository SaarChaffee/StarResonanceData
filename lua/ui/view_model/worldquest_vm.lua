local getRewardByQuestId = function(eventId)
  local dailyEventRow = Z.TableMgr.GetTable("DailyWorldEventTableMgr").GetRow(eventId)
  if dailyEventRow then
    return Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(dailyEventRow.Award)
  else
    logError("DailyWorldEventTableMgr\230\156\170\230\137\190\229\136\176id\228\184\186" .. eventId .. "\231\154\132\230\149\176\230\141\174")
  end
end
local checkIsWorldDungeonAndFinish = function(dungeonId)
  local dailyWorldEventMgr = Z.TableMgr.GetTable("DailyWorldEventTableMgr")
  for k, v in pairs(Z.ContainerMgr.CharSerialize.worldEventMap.eventMap) do
    local eventInfo_ = dailyWorldEventMgr.GetRow(v.id)
    if eventInfo_ and eventInfo_.DungeonId == dungeonId and v.award == 1 then
      return true
    end
  end
  return false
end
local getWorldEventIdByEntityId = function(id)
  for _, v in pairs(Z.ContainerMgr.CharSerialize.worldEventMap.eventMap) do
    local eventInfo = Z.TableMgr.GetTable("DailyWorldEventTableMgr").GetRow(v.id)
    if eventInfo then
      local entityUId_ = eventInfo.Entity[2]
      if entityUId_ == id then
        return v.id
      end
    end
  end
  logError("EntityUId\229\146\140dailyworldeventId\230\178\161\229\175\185\228\184\138,EntityUId:" .. id)
  return nil
end
local getWorldEventViewDataInMap = function(flagData_)
  local viewData = {}
  viewData.showInMap_ = true
  viewData.flagData_ = flagData_
  viewData.dailyEventId_ = getWorldEventIdByEntityId(flagData_.Uid)
  return viewData
end
local showWorldEventView = function(uuid)
  local entityVM = Z.VMMgr.GetVM("entity")
  local subViewData = {}
  subViewData.showInMap_ = false
  subViewData.flagData_ = nil
  subViewData.dailyEventId_ = getWorldEventIdByEntityId(entityVM.UuidToEntId(uuid))
  if subViewData.dailyEventId_ then
    local viewData = {}
    viewData.subViewData = subViewData
    Z.UIMgr:OpenView("worldquest_main_window", viewData)
  else
    logError("\229\174\158\228\189\147id\232\189\172dailyeventid\229\164\177\232\180\165,\228\184\173\230\150\173")
  end
end
local checkWorldEventComplete = function(eventId)
  for _, v in pairs(Z.ContainerMgr.CharSerialize.worldEventMap.eventMap) do
    if v.id == eventId then
      return v.award == 1
    end
  end
  return false
end
local worldQuestEventFinish = function()
  local worldQuestData_ = Z.DataMgr.Get("worldquest_data")
  worldQuestData_.AcceptWorldQuest = false
  Z.LevelMgr:OnLevelEventTrigger(E.LevelEventType.OnWorldQuestRefresh)
  Z.TipsVM.ShowTipsLang(Z.Global.WorldEventSuccessMsgId)
end
local worldQuestEventRemove = function()
  local worldQuestData_ = Z.DataMgr.Get("worldquest_data")
  worldQuestData_.AcceptWorldQuest = false
  Z.LevelMgr:OnLevelEventTrigger(E.LevelEventType.OnWorldQuestRefresh)
end
local worldQuestInteractive = function()
  Z.UIMgr:OpenView("worldquest_interactive_window")
end
local openWorldQuestMapJump = function()
  local quickJumpVM_ = Z.VMMgr.GetVM("quick_jump")
  local funcSearchRow_ = Z.TableMgr.GetTable("FunctionSearchTableMgr").GetRow(E.FunctionID.WorldEvent)
  if funcSearchRow_ then
    quickJumpVM_.DoJumpByConfigParam(funcSearchRow_.QuickJumpType, funcSearchRow_.QuickJumpParam)
  end
end
local worldQuestTransfer = function(eventId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.eventId = eventId
  local ret = worldProxy.WorldEventTransfer(request, cancelToken)
  if ret == 0 then
    return true
  else
    Z.TipsVM.ShowTips(ret)
    return false
  end
end
local ret = {
  GetRewardByQuestId = getRewardByQuestId,
  CheckIsWorldDungeonAndFinish = checkIsWorldDungeonAndFinish,
  GetWorldEventIdByEntityId = getWorldEventIdByEntityId,
  GetWorldEventViewDataInMap = getWorldEventViewDataInMap,
  ShowWorldEventView = showWorldEventView,
  CheckWorldEventComplete = checkWorldEventComplete,
  WorldQuestEventFinish = worldQuestEventFinish,
  WorldQuestInteractive = worldQuestInteractive,
  OpenWorldQuestMapJump = openWorldQuestMapJump,
  WorldQuestEventRemove = worldQuestEventRemove,
  WorldQuestTransfer = worldQuestTransfer
}
return ret
