local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_bottom_ui_subView = class("Main_bottom_ui_subView", super)
local EQualityGrade = Panda.Utility.Quality.EQualityGrade
local QualityGradeSetting = Panda.Utility.Quality.QualityGradeSetting
local QualityString = {
  "SetFluency",
  "SetDistinct",
  "SetHighDefinition",
  "SetPerfection",
  "SetUserDefined"
}

function Main_bottom_ui_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "main_bottom_ui_sub", "main/main_bottom_ui_sub", UI.ECacheLv.None, true)
  self.mainUIVM_ = Z.VMMgr.GetVM("mainui")
  self.rolelevelData_ = Z.DataMgr.Get("role_level_data")
end

function Main_bottom_ui_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:bindWatcher()
  self:bindEvents()
  self:updateQualityUI()
end

function Main_bottom_ui_subView:OnDeActive()
  self:unbindWatcher()
  self:unBindEvents()
end

function Main_bottom_ui_subView:OnRefresh()
  self:updateExpUI()
end

function Main_bottom_ui_subView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.UserSetting.ImageQualityChanged, self.updateQualityUI, self)
end

function Main_bottom_ui_subView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.UserSetting.ImageQualityChanged, self.updateQualityUI, self)
end

function Main_bottom_ui_subView:bindWatcher()
  function self.onContainerChanged_()
    self:updateExpUI()
  end
  
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.onContainerChanged_)
end

function Main_bottom_ui_subView:unbindWatcher()
  if self.onContainerChanged_ ~= nil then
    Z.ContainerMgr.CharSerialize.roleLevel.Watcher:UnregWatcher(self.onContainerChanged_)
    self.onContainerChanged_ = nil
  end
end

function Main_bottom_ui_subView:updateExpUI()
  if Z.IsPCUI then
    return
  end
  local levelExp = self.mainUIVM_.GetPlayerExp()
  local curExp = Z.ContainerMgr.CharSerialize.roleLevel.curLevelExp or 0
  local curLevel = Z.ContainerMgr.CharSerialize.roleLevel.level or 0
  local ratio = 0
  if levelExp ~= 0 then
    ratio = curExp / levelExp
  end
  self.uiBinder.img_exp.fillAmount = ratio
  self.uiBinder.lab_lv.text = Lang("Level", {val = curLevel})
  self.uiBinder.lab_experience_num.text = Lang("season_achievement_progress", {val1 = curExp, val2 = levelExp})
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_max, curLevel == self.rolelevelData_.MaxPlayerLevel)
end

function Main_bottom_ui_subView:updateQualityUI()
  if Z.IsPCUI then
    return
  end
  local grade = QualityGradeSetting.QualityGrade
  grade = (grade:ToInt() < EQualityGrade.ELow:ToInt() or grade:ToInt() > EQualityGrade.ECustom:ToInt()) and EQualityGrade.EVeryHigh or grade
  local stringKey = QualityString[grade:ToInt() + 1]
  self.uiBinder.lab_image_quality.text = Lang(stringKey)
end

return Main_bottom_ui_subView
