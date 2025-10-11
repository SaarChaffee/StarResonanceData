local super = require("ui.model.data_base")
local DungeonTimerData = class("DungeonTimerData", super)

function DungeonTimerData:ctor()
  super.ctor(self)
  self.MainViewHideTag = false
  self.DungeonHideTag = false
  self.DungeonTimerViewData = {}
  self.IsPausing = false
end

function DungeonTimerData:SetMainViewHideTag(isShow)
  if self.MainViewHideTag ~= isShow then
    self.MainViewHideTag = isShow
  end
end

function DungeonTimerData:SetDungeonViewHideTag(isShow)
  if self.DungeonHideTag ~= isShow then
    self.DungeonHideTag = isShow
  end
end

function DungeonTimerData:GetStartMark()
  return self.isShowStartMark
end

function DungeonTimerData:setDungeonTimerViewData(data)
  self.DungeonTimerViewData = data
end

function DungeonTimerData:Clear()
  self.MainViewHideTag = false
  self.DungeonHideTag = false
  self.DungeonTimerViewData = {}
  self.IsPausing = false
end

return DungeonTimerData
