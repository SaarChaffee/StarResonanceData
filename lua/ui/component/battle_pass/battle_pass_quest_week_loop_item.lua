local super = require("ui.component.loopscrollrectitem")
local BattlePassQuestWeekLoopItem = class("BattlePassQuestWeekLoopItem", super)

function BattlePassQuestWeekLoopItem:ctor()
  super:ctor()
end

function BattlePassQuestWeekLoopItem:OnInit()
  self:initParam()
  self:initWidgets()
end

function BattlePassQuestWeekLoopItem:initWidgets()
  self.week_lab_1 = self.uiBinder.lab_week_1
  self.week_lab_2 = self.uiBinder.lab_week_2
  self.locked_off = self.uiBinder.group_off
  self.locked_on = self.uiBinder.group_on
  self.selected_img = self.uiBinder.img_select
end

function BattlePassQuestWeekLoopItem:initParam()
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.uiView = self.parent.uiView
end

function BattlePassQuestWeekLoopItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self:setItemInfo()
end

function BattlePassQuestWeekLoopItem:setItemInfo()
  local weekStr = Lang("PassWeek", {
    val = self.data_.index
  })
  self.week_lab_1.text = weekStr
  self.week_lab_2.text = weekStr
  local lockState = self.data_.index <= self.battlePassVM_.GetSeasonCurrentWeek()
  self.uiBinder.Ref:SetVisible(self.locked_on, lockState)
  self.uiBinder.Ref:SetVisible(self.locked_off, not lockState)
  self.uiBinder.Ref:SetVisible(self.selected_img, false)
end

function BattlePassQuestWeekLoopItem:Selected(isSelected)
  if self.uiView and isSelected then
    self.uiView:onWeekLoopItemSelected(self.component.Index + 1)
  end
  self.uiBinder.Ref:SetVisible(self.selected_img, isSelected)
end

function BattlePassQuestWeekLoopItem:OnUnInit()
end

return BattlePassQuestWeekLoopItem
