local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_achievement_finish_popupView = class("Season_achievement_finish_popupView", super)
local normalBg = "ui/atlas/season_achievement/seasoncenter_achievement_tips_round"
local specialBg = "ui/atlas/season_achievement/seasoncenter_perpetual_achievement_tips_round"
local normalBg2 = "ui/textures/large_ui/season_achievement/seasoncenter_achievement_tips_bg"
local specialBg2 = "ui/textures/large_ui/season_achievement/seasoncenter_perpetual_achievement_tips_bg"
local normalColor = Color.New(0.7098039215686275, 0.42745098039215684, 0.8156862745098039, 1)
local specialColor = Color.New(0.43137254901960786, 1, 1, 1)

function Season_achievement_finish_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_achievement_finish_popup", "season_achievement/season_achievement_finish_popup")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function Season_achievement_finish_popupView:OnActive()
  Z.AudioMgr:Play("sys_general_tips")
  self.uiBinder.lab_name.text = self.viewData.name
  if self.viewData.isRecipeUnlock then
    if Z.IsPCUI then
      self.uiBinder.lab_title.text = Lang("RecipeUnlocked")
      self.uiBinder.img_line_1:SetColor(normalColor)
      self.uiBinder.img_line_2:SetColor(normalColor)
    else
      self.uiBinder.img_bg:SetImage(normalBg)
      self.uiBinder.img_bg_02:SetImage(normalBg2)
    end
  elseif Z.IsPCUI then
    self.uiBinder.lab_title.text = Lang("AchievementAchieved")
    if self.viewData.special then
      self.uiBinder.img_line_1:SetColor(specialColor)
      self.uiBinder.img_line_2:SetColor(specialColor)
    else
      self.uiBinder.img_line_1:SetColor(normalColor)
      self.uiBinder.img_line_2:SetColor(normalColor)
    end
  elseif self.viewData.special then
    self.uiBinder.img_bg:SetImage(specialBg)
    self.uiBinder.img_bg_02:SetImage(specialBg2)
  else
    self.uiBinder.img_bg:SetImage(normalBg)
    self.uiBinder.img_bg_02:SetImage(normalBg2)
  end
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_achievement)
  self.uiBinder.effect_achievement:SetEffectGoVisible(true)
  self.uiBinder.effect_achievement:Play()
  local token = self.cancelSource:CreateToken()
  local anim_name
  if Z.IsPCUI then
    anim_name = "anim_season_achievement_finish_popup_pc_open"
  else
    anim_name = "anim_season_achievement_finish_popup_open"
  end
  if self.viewData.achievementId and self.viewData.achievementId ~= 0 then
    local config = self.achievementVM_.GetAchievementInClassConfig(self.viewData.achievementId)
    if config then
      self.uiBinder.rimg_icon:SetImage(config.ClassIcon)
    end
  end
  self.commonVM_.CommonPlayAnim(self.uiBinder.anim, anim_name, token, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
end

function Season_achievement_finish_popupView:OnDeActive()
  self.timerMgr:Clear()
end

function Season_achievement_finish_popupView:OnRefresh()
end

return Season_achievement_finish_popupView
