local UI = Z.UI
local super = require("ui.ui_subview_base")
local Achievement_badge_subView = class("Achievement_badge_subView", super)
local AchievementDefine = require("ui.model.achievement_define")
local LoopGridView = require("ui.component.loop_grid_view")
local AchievementItem = require("ui.component.achievement.achievement_badge_item")

function Achievement_badge_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "achievement_badge_sub", "season_achievement/achievement_badge_sub", UI.ECacheLv.None, true)
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function Achievement_badge_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  local datas = self.achievementVM_.GetAndSortAchievementClass(AchievementDefine.PermanentAchievementType)
  self.classifyLoopListView_ = LoopGridView.new(self, self.uiBinder.loop_item, AchievementItem, "achievement_badge_item_tpl", true)
  self.classifyLoopListView_:Init(datas)
  Z.EventMgr:Add(Z.ConstValue.Achievement.OnAchievementDataChange, self.refreshList, self)
end

function Achievement_badge_subView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Achievement.OnAchievementDataChange, self.refreshList, self)
  self.classifyLoopListView_:UnInit()
  self.classifyLoopListView_ = nil
end

function Achievement_badge_subView:OnRefresh()
end

function Achievement_badge_subView:refreshList()
  self.classifyLoopListView_:RefreshAllShownItem()
end

return Achievement_badge_subView
