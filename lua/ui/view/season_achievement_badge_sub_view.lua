local UI = Z.UI
local super = require("ui.ui_subview_base")
local Season_achievement_badge_subView = class("Season_achievement_badge_subView", super)
local LoopGridView = require("ui.component.loop_grid_view")
local AchievementItem = require("ui.component.achievement.achievement_badge_item")

function Season_achievement_badge_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "season_achievement_badge_sub", "season_achievement/season_achievement_badge_sub", UI.ECacheLv.None, true)
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function Season_achievement_badge_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  Z.UnrealSceneMgr:InitSceneCamera(true)
  Z.UnrealSceneMgr:AsyncSetBackGround(E.SeasonUnRealBgPath.Scene)
  local datas = self.achievementVM_.GetAndSortAchievementClass(Z.DataMgr.Get("season_data").CurSeasonId)
  self.classifyLoopListView_ = LoopGridView.new(self, self.uiBinder.loop_item, AchievementItem, "season_achievement_badge_item_tpl", true)
  self.classifyLoopListView_:Init(datas)
  Z.EventMgr:Add(Z.ConstValue.Achievement.OnAchievementDataChange, self.refreshList, self)
end

function Season_achievement_badge_subView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Achievement.OnAchievementDataChange, self.refreshList, self)
  self.classifyLoopListView_:UnInit()
  self.classifyLoopListView_ = nil
end

function Season_achievement_badge_subView:OnRefresh()
end

function Season_achievement_badge_subView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Season_achievement_badge_subView:refreshList()
  self.classifyLoopListView_:RefreshAllShownItem()
end

return Season_achievement_badge_subView
