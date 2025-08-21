local UI = Z.UI
local super = require("ui.ui_view_base")
local Explore_monster_level_popupView = class("Explore_monster_level_popupView", super)

function Explore_monster_level_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "explore_monster_level_popup")
  self.vm_ = Z.VMMgr.GetVM("explore_monster")
end

function Explore_monster_level_popupView:OnActive()
  self:initUIBinders()
  self:onStartAnimShow()
  self:rereshLevelInfo()
end

function Explore_monster_level_popupView:OnDeActive()
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_silver_eff)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_yellow_eff)
end

function Explore_monster_level_popupView:onStartAnimShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_silver_eff)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_yellow_eff)
  self.uiBinder.anim:PlayOnce("anim_explore_monster_level_popup_open")
  self.uiBinder.anim_dotween:Restart(Z.DOTweenAnimType.Open)
end

function Explore_monster_level_popupView:OnRefresh()
end

function Explore_monster_level_popupView:initUIBinders()
  self:AddClick(self.uiBinder.btn_reward, function()
    self.vm_:OpenExploreMonsterGradeWindow()
    self.vm_:CloseExploreMonsterLevelUpWindow()
  end)
  self:AddClick(self.uiBinder.btn, function()
    self.vm_:CloseExploreMonsterLevelUpWindow()
  end)
  self.uiBinder.scenemask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
end

function Explore_monster_level_popupView:rereshLevelInfo()
  local level_ = self.vm_.GetMonsterHuntLevel()
  local frontLevel = level_ - 1
  self.uiBinder.lab_level_front.text = Lang("Level", {val = frontLevel})
  self.uiBinder.lab_grade_front.text = frontLevel
  self.uiBinder.lab_lv.text = Lang("Level", {val = level_})
  self.uiBinder.lab_grade.text = level_
end

return Explore_monster_level_popupView
