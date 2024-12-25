local super = require("ui.component.loopscrollrectitem")
local BattlePassActiveLoopItem = class("BattlePassActiveLoopItem", super)

function BattlePassActiveLoopItem:ctor()
  super:ctor()
end

function BattlePassActiveLoopItem:OnInit()
  self:initWidgets()
end

function BattlePassActiveLoopItem:initWidgets()
  self.num_lab = self.uiBinder.lab_num
  self.content_lab = self.uiBinder.lab_event_info
end

function BattlePassActiveLoopItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self:setInfo()
end

function BattlePassActiveLoopItem:setInfo()
  self.num_lab.text = self.data_.Activation
  self.content_lab.text = self.data_.TargetDes
end

function BattlePassActiveLoopItem:OnUnInit()
end

return BattlePassActiveLoopItem
