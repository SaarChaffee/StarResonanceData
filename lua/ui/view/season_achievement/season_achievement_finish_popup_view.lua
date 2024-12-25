local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_achievement_finish_popupView = class("Season_achievement_finish_popupView", super)

function Season_achievement_finish_popupView:ctor()
  self.uiBinder = nil
  if Z.IsPCUI then
    Z.UIConfig.season_achievement_finish_popup.PrefabPath = "season_achievement/season_achievement_finish_popup_pc"
  else
    Z.UIConfig.season_achievement_finish_popup.PrefabPath = "season_achievement/season_achievement_finish_popup"
  end
  super.ctor(self, "season_achievement_finish_popup")
end

function Season_achievement_finish_popupView:OnActive()
  Z.AudioMgr:Play("sys_general_tips")
  self.uiBinder.lab_name.text = self.viewData
  local anim_name = Z.IsPCUI and "anim_season_achievement_finish_popup_pc_open" or "anim_season_achievement_finish_popup_open"
  self.uiBinder.anim:ResetAniState(anim_name)
  self.uiBinder.anim:PlayOnce(anim_name)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_achievement)
  self.uiBinder.effect_achievement:SetEffectGoVisible(true)
  self.uiBinder.effect_achievement:Play()
  self.timerMgr:StartTimer(function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end, 4)
end

function Season_achievement_finish_popupView:OnDeActive()
  self.timerMgr:Clear()
end

function Season_achievement_finish_popupView:OnRefresh()
end

return Season_achievement_finish_popupView
