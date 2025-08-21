local EQualityGrade = Panda.Utility.Quality.EQualityGrade
local QualityGradeSetting = Panda.Utility.Quality.QualityGradeSetting
local UI = Z.UI
local super = require("ui.ui_view_base")
local Set_item_popupView = class("Set_item_popupView", super)

function Set_item_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "setting_popup")
  self.settingVm_ = Z.VMMgr.GetVM("setting")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
end

function Set_item_popupView:OnActive()
  self:initBinder()
  self:bindBtnClick()
  self.recommenGrade_ = QualityGradeSetting.RecommendGrade:ToInt()
  self.recommenGrade_ = (self.recommenGrade_ < EQualityGrade.ELow:ToInt() or self.recommenGrade_ > EQualityGrade.EVeryHigh:ToInt()) and EQualityGrade.EVeryHigh:ToInt() or self.recommenGrade_
  self:refreshView()
  self:initConfig()
  self:initLangVoiceItem()
end

function Set_item_popupView:OnDeActive()
end

function Set_item_popupView:OnRefresh()
end

function Set_item_popupView:initConfig()
  self.audioLangNamesArray_ = Z.LocalizationMgr:GetAudioLanNames()
  local showAudioLangsTmp = Z.LocalizationMgr:GetShowAudioLans()
  self.showLangs_ = {}
  self.showAudioLangs_ = {}
  for i = 0, showAudioLangsTmp.Length - 1 do
    table.insert(self.showAudioLangs_, showAudioLangsTmp[i])
  end
end

function Set_item_popupView:initLangVoiceItem()
  if self.switchVm_.CheckFuncSwitch(E.SetFuncId.SettingLanguageVoice) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tog, #self.showAudioLangs_ > 1)
    self.curLanguageVoiceIdx_ = Z.LocalizationMgr:GetCurrentLanguageVoice()
    for i = 1, 4 do
      local showToggle = i <= #self.showAudioLangs_
      local toggleBinder = self.uiBinder["tog_language_" .. i]
      toggleBinder.Ref.UIComp:SetVisible(showToggle)
      if showToggle then
        toggleBinder.tog_language_1:RemoveAllListeners()
        toggleBinder.lab_language.text = self.audioLangNamesArray_[self.showAudioLangs_[i]]
        toggleBinder.tog_language_1:SetIsOnWithoutNotify(self.curLanguageVoiceIdx_ == self.showAudioLangs_[i])
        toggleBinder.tog_language_1:AddListener(function(isOn)
          if isOn then
            self:setLangVoiceItemSelect(self.showAudioLangs_[i], true)
          end
        end)
      end
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tog, false)
  end
end

function Set_item_popupView:setLangVoiceItemSelect(languageIdx, showTip)
  if self.curLanguageVoiceIdx_ ~= languageIdx then
    self.curLanguageVoiceIdx_ = languageIdx
    Z.LocalizationMgr:SetLanguageVoice(self.curLanguageVoiceIdx_)
    if showTip then
      Z.TipsVM.ShowTips(1000745, {
        val = self.audioLangNamesArray_[languageIdx]
      })
    end
  end
end

function Set_item_popupView:refreshView()
  for k, v in pairs(self.qualityBinders_) do
    v.Ref:SetVisible(v.img_recommend, k == self.recommenGrade_)
  end
  self:onSelectGrade(QualityGradeSetting.QualityGrade:ToInt())
end

function Set_item_popupView:onSelectGrade(grade)
  for k, v in pairs(self.qualityBinders_) do
    v.Ref:SetVisible(v.img_select, k == grade)
  end
  if grade == QualityGradeSetting.QualityGrade:ToInt() then
    return
  end
  QualityGradeSetting.QualityGrade = EQualityGrade.IntToEnum(grade)
  Z.EventMgr:Dispatch(Z.ConstValue.UserSetting.ImageQualityChanged)
  self.settingVm_.ImageQualityChanged()
end

function Set_item_popupView:initBinder()
  self.qualityBinders_ = {}
  for i = EQualityGrade.ELow:ToInt(), EQualityGrade.EVeryHigh:ToInt() do
    local binder = self.uiBinder[string.zconcat("node_img_0", i + 1)]
    self.qualityBinders_[i] = binder
  end
  if QualityGradeSetting.IsLowMemory then
    local tog = self.qualityBinders_[EQualityGrade.EVeryHigh:ToInt()]
    tog.Go:SetActive(false)
  end
end

function Set_item_popupView:bindBtnClick()
  self:AddClick(self.uiBinder.btn_close, function()
    self.settingVm_.CloseSettingPopupView()
  end)
  self:AddClick(self.uiBinder.btn_confime, function()
    self.settingVm_.CloseSettingPopupView()
  end)
  for k, v in pairs(self.qualityBinders_) do
    v.Ref:SetVisible(v.img_recommend, k == self.recommenGrade_)
    self:AddClick(v.btn, function()
      self:onSelectGrade(k)
    end)
  end
end

return Set_item_popupView
