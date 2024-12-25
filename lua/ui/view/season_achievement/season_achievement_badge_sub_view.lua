local super = require("ui.ui_subview_base")
local SeasonAchievementBadge = class("SeasonAchievementBadge", super)
local LoopGridView = require("ui.component.loop_grid_view")
local AchievementItem = require("ui.view.season_achievement.season_achievement_item")

function SeasonAchievementBadge:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_achievement_badge", "season_achievement/season_achievement_badge_tpl", Z.UI.ECacheLv.None)
end

function SeasonAchievementBadge:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  Z.UnrealSceneMgr:AsyncSetBackGround(E.SeasonUnRealBgPath.Scene)
  self.classifyLoopListView_ = LoopGridView.new(self, self.uiBinder.loop_item, AchievementItem, "season_achievement_badge_item_tpl")
  self.classifyLoopListView_:Init({})
end

function SeasonAchievementBadge:OnRefresh()
  local seasonAchievementVm = Z.VMMgr.GetVM("season_achievement")
  self.classifyLoopListView_:RefreshListView(seasonAchievementVm.GetClassify(), false)
end

function SeasonAchievementBadge:OnDeActive()
  self.classifyLoopListView_:UnInit()
end

return SeasonAchievementBadge
