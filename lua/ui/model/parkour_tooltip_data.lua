local super = require("ui.model.data_base")
local ParkourTooltipData = class("ParkourTooltipData", super)

function ParkourTooltipData:ctor()
  super.ctor(self)
  self.MainViewHideTag = false
  self.DungeonHideTag = false
  self.WorldEventDungeonData = {}
  self.WorldEventDungeonData.DungeonInfo = nil
  self.WorldEventDungeonData.ViewType = nil
  self.isShowStartMark = true
end

function ParkourTooltipData:GetParkourRecord(dungeonId)
  local recordData, recordInfo
  if table.zcount(Z.ContainerMgr.CharSerialize.records.recordList) > 0 then
    for k, v in pairs(Z.ContainerMgr.CharSerialize.records.recordList) do
      if k == dungeonId then
        recordInfo = v
        break
      end
    end
  end
  if recordInfo ~= nil and recordInfo.perfectTime then
    local perfectTime = Z.TimeFormatTools.FormatToDHMS(recordInfo.perfectTime, true)
    perfectTime = perfectTime or 0
    recordData = perfectTime
  end
  if recordData == nil then
    recordData = Lang("NullParkourScore")
  end
  return recordData
end

function ParkourTooltipData:SetMainViewHideTag(isShow)
  if self.MainViewHideTag ~= isShow then
    self.MainViewHideTag = isShow
  end
end

function ParkourTooltipData:SetDungeonViewHideTag(isShow)
  if self.DungeonHideTag ~= isShow then
    self.DungeonHideTag = isShow
  end
end

function ParkourTooltipData:SetWorldEventDungeonData(worldEventData)
  if not worldEventData then
    return
  end
  self.WorldEventDungeonData.DungeonInfo = worldEventData.dungeonInfo
  self.WorldEventDungeonData.ViewType = worldEventData.viewType
end

function ParkourTooltipData:Clear()
  self.MainViewHideTag = false
  self.DungeonHideTag = false
  self.WorldEventDungeonData = {}
  self.isShowStartMark = true
  self.WorldEventDungeonData.DungeonInfo = nil
  self.WorldEventDungeonData.ViewType = nil
end

function ParkourTooltipData:SetStartMark(isShow)
  if self.isShowStartMark ~= isShow then
    self.isShowStartMark = isShow
  end
end

function ParkourTooltipData:GetStartMark()
  return self.isShowStartMark
end

return ParkourTooltipData
