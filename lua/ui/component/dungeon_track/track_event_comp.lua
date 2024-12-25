local TrackEventComp = class("TrackEventComp")
local TrackEventItem = require("ui.component.dungeon_track.track_event_item")
local TrackEventUnitPath = "ui/prefabs/main/track/hero_dungeon_task_event_tpl"
local TrackEventUnitPathPc = "ui/prefabs/main/track/hero_dungeon_task_event_tpl_pc"

function TrackEventComp:ctor()
  self.trackEventVM_ = Z.VMMgr.GetVM("track_event")
end

function TrackEventComp:Init(parentView, parentTrans, compData)
  self.parentView_ = parentView
  self.parentTrans_ = parentTrans
  self.compData_ = compData
  self.eventItemDic_ = {}
  self.eventItemNameDic_ = {}
  self:InitUnits()
  Z.EventMgr:Add(Z.ConstValue.Dungeon.RemoveEvent, self.OnRemoveEvent, self)
end

function TrackEventComp:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Dungeon.RemoveEvent, self.OnRemoveEvent, self)
  for eventId, eventItem in pairs(self.eventItemDic_) do
    eventItem:UnInit()
  end
  for eventId, unitName in pairs(self.eventItemNameDic_) do
    self.parentView_:RemoveUiUnit(unitName)
  end
  self.parentView_ = nil
  self.parentTrans_ = nil
  self.compData_ = nil
  self.eventItemNameDic_ = nil
  self.eventItemDic_ = nil
end

function TrackEventComp:InitUnits()
  local events = self.compData_.dungeonEvent.dungeonEventData
  if not events then
    return
  end
  for eventId, value in pairs(events) do
    local eventData = value
    if eventData.state == E.DungeonEventState.Running then
      self:AsyncInitUnit(eventId, eventData)
    end
  end
end

function TrackEventComp:RefreshUnits(container, dirtyKeys)
  if not dirtyKeys.dungeonEventData then
    return
  end
  for eventId, value in pairs(dirtyKeys.dungeonEventData) do
    local eventData = container.dungeonEventData[eventId]
    if value:IsNew() then
      if eventData.state == E.DungeonEventState.Running then
        self:AsyncInitUnit(eventId, eventData)
        Z.TipsVM.ShowTipsLang(15001103)
      end
    else
      local eventItem = self.eventItemDic_[eventId]
      if eventItem then
        eventItem:RefreshData(eventData)
      end
    end
  end
  self:SortItems()
end

function TrackEventComp:SortItems()
  local sortedEventIdList = table.zkeys(self.eventItemNameDic_)
  table.sort(sortedEventIdList, function(a, b)
    local itemA = self.eventItemDic_[a]
    local itemB = self.eventItemDic_[b]
    if itemA.refreshTime_ == itemB.refreshTime_ then
      if itemA.eventData_.startTime == itemB.eventData_.startTime then
        return itemA.eventData_.eventId < itemB.eventData_.eventId
      else
        return itemA.eventData_.startTime < itemB.eventData_.startTime
      end
    else
      return itemA.refreshTime_ > itemB.refreshTime_
    end
  end)
  for index, eventId in ipairs(sortedEventIdList) do
    local unitName = self.eventItemNameDic_[eventId]
    local unit = self.parentView_.units[unitName]
    unit.Trans:SetSiblingIndex(index - 1)
  end
end

function TrackEventComp:AsyncInitUnit(eventId, eventData)
  Z.CoroUtil.create_coro_xpcall(function()
    local unitName = string.format("event_%s", eventId)
    local path = Z.IsPCUI and TrackEventUnitPathPc or TrackEventUnitPath
    local unit = self.parentView_:AsyncLoadUiUnit(path, unitName, self.parentTrans_)
    local eventItem = TrackEventItem.new()
    eventItem:Init(unit, self.parentView_)
    eventItem:SetData(eventData)
    self.eventItemDic_[eventId] = eventItem
    self.eventItemNameDic_[eventId] = unitName
  end)()
end

function TrackEventComp:OnRemoveEvent(eventId)
  local item = self.eventItemDic_[eventId]
  local unitName = self.eventItemNameDic_[eventId]
  if item and unitName then
    item:UnInit()
    self.parentView_:RemoveUiUnit(unitName)
    self.eventItemDic_[eventId] = nil
    self.eventItemNameDic_[eventId] = nil
  end
end

return TrackEventComp
