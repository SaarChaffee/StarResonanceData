local UI = Z.UI
local super = require("ui.ui_view_base")
local gradeItem_ = require("ui/component/explore_monster/explore_monster_grade_item")
local loop_list_view = require("ui/component/loop_list_view")
local Explore_monster_grade_popupView = class("Explore_monster_grade_popupView", super)

function Explore_monster_grade_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "explore_monster_grade_popup")
  self.vm_ = Z.VMMgr.GetVM("explore_monster")
end

function Explore_monster_grade_popupView:OnActive()
  self:initBinders()
  self:initBaseData()
end

function Explore_monster_grade_popupView:OnDeActive()
  self.rewardScrollRect_:UnInit()
  self.rewardScrollRect_ = nil
end

function Explore_monster_grade_popupView:OnRefresh()
end

function Explore_monster_grade_popupView:initBinders()
  self.btn_close = self.uiBinder.btn_close
  self:AddClick(self.uiBinder.btn_close, function()
    self.vm_.CloseExploreMonsterGradeWindow()
  end)
  local dataList_ = {}
  self.rewardScrollRect_ = loop_list_view.new(self, self.uiBinder.scrollview_award, gradeItem_, "explore_monster_grade_list_tpl")
  self.rewardScrollRect_:Init(dataList_)
  self.uiBinder.scenemask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
end

function Explore_monster_grade_popupView:initBaseData()
  local list_ = self.vm_.GetAllMonsterHuntLevelData()
  self.rewardScrollRect_:RefreshListView(list_)
end

function Explore_monster_grade_popupView:RefreshRewardList()
  self.rewardScrollRect_:RefreshAllShownItem()
end

return Explore_monster_grade_popupView
