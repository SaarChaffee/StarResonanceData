local super = require("ui.model.data_base")
local FluxRevoltTooltipData = class("FluxRevoltTooltipData", super)

function FluxRevoltTooltipData:ctor()
  super.ctor(self)
  self.MainViewHideTag = false
  self.DungeonHideTag = false
  self.WorldEventDungeonData = {}
  self.WorldEventDungeonData.DungeonInfo = nil
  self.WorldEventDungeonData.ViewType = nil
end

function FluxRevoltTooltipData:SetMainViewHideTag(isShow)
  if self.MainViewHideTag ~= isShow then
    self.MainViewHideTag = isShow
  end
end

function FluxRevoltTooltipData:SetDungeonViewHideTag(isShow)
  if self.DungeonHideTag ~= isShow then
    self.DungeonHideTag = isShow
  end
end

function FluxRevoltTooltipData:SetWorldEventDungeonData(worldEventData)
  if not worldEventData then
    return
  end
  self.WorldEventDungeonData.DungeonInfo = worldEventData.dungeonInfo
  self.WorldEventDungeonData.ViewType = worldEventData.viewType
end

return FluxRevoltTooltipData
