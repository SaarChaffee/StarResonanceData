local UI = Z.UI
local super = require("ui.ui_subview_base")
local BasemoduleView = class("BasemoduleView", super)

function BasemoduleView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "set_basic_sub", "set/set_basic_sub", UI.ECacheLv.None)
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.settingData_ = Z.DataMgr.Get("setting_data")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
end

function BasemoduleView:OnActive()
  self.uiBinder.set_basic_sub:SetSizeDelta(0, 0)
  self.curLanguageIdx_ = 0
  self.curLanguageVoiceIdx_ = 0
  self.langTogItems_ = {}
  self.langVoiceTogItems_ = {}
  self.playerUid_ = tostring(Z.EntityMgr.PlayerUuid)
  self.settingsTbl_ = Z.TableMgr.GetTable("SettingsTableMgr")
  self.settingsTypeTbl_ = Z.TableMgr.GetTable("SettingsTypeTableMgr")
  self:initConfig()
  self:initCompQuote()
  self:initVoice()
  self:initLangVoiceItem()
  self:initLangItem()
  self:initClearCache()
  self:refreshAllSettingVisible()
end

function BasemoduleView:initConfig()
  self.langNamesArray_ = Z.LocalizationMgr:GetLanNames()
  local showLangsTmp = Z.LocalizationMgr:GetShowLans()
  local showAudioLangsTmp = Z.LocalizationMgr:GetShowAudioLans()
  self.showLangs_ = {}
  self.showAudioLangs_ = {}
  for i = 0, showLangsTmp.Length - 1 do
    table.insert(self.showLangs_, showLangsTmp[i])
  end
  for i = 0, showAudioLangsTmp.Length - 1 do
    table.insert(self.showAudioLangs_, showAudioLangsTmp[i])
  end
end

function BasemoduleView:refreshAllSettingVisible()
  local settingVisibleData = Z.DataMgr.Get("setting_visible_data")
  for k, v in pairs(self.containerList) do
    local show = settingVisibleData:CheckVisible(k)
    if not show then
      v.Ref.UIComp:SetVisible(show)
    end
  end
end

function BasemoduleView:initCompQuote()
  self.switchList = {
    [E.SettingID.Master] = self.uiBinder.cont_volume.cont_master.cont_switch.switch,
    [E.SettingID.Bgm] = self.uiBinder.cont_volume.cont_music.cont_switch.switch,
    [E.SettingID.Sfx] = self.uiBinder.cont_volume.cont_sound.cont_switch.switch,
    [E.SettingID.Voice] = self.uiBinder.cont_volume.cont_npcdialog.cont_switch.switch,
    [E.SettingID.System] = self.uiBinder.cont_volume.cont_uiaudio.cont_switch.switch,
    [E.SettingID.P3] = self.uiBinder.cont_volume.cont_otherplayer.cont_switch.switch,
    [E.SettingID.PlayerVoiceReceptionVolume] = self.uiBinder.cont_volume.cont_player_voice_reception.cont_switch.switch,
    [E.SettingID.PlayerVoiceTransmissionVolume] = self.uiBinder.cont_volume.cont_player_voice_sending.cont_switch.switch
  }
  self.sliderList = {
    [E.SettingID.Master] = self.uiBinder.cont_volume.cont_master.slider_progress,
    [E.SettingID.Bgm] = self.uiBinder.cont_volume.cont_music.slider_progress,
    [E.SettingID.Sfx] = self.uiBinder.cont_volume.cont_sound.slider_progress,
    [E.SettingID.Voice] = self.uiBinder.cont_volume.cont_npcdialog.slider_progress,
    [E.SettingID.System] = self.uiBinder.cont_volume.cont_uiaudio.slider_progress,
    [E.SettingID.P3] = self.uiBinder.cont_volume.cont_otherplayer.slider_progress,
    [E.SettingID.PlayerVoiceReceptionVolume] = self.uiBinder.cont_volume.cont_player_voice_reception.slider_progress,
    [E.SettingID.PlayerVoiceTransmissionVolume] = self.uiBinder.cont_volume.cont_player_voice_sending.slider_progress
  }
  self.sliderCanvasGroupList = {
    [E.SettingID.Master] = self.uiBinder.cont_volume.cont_master.slider_progress_canvasGroup,
    [E.SettingID.Bgm] = self.uiBinder.cont_volume.cont_music.slider_progress_canvasGroup,
    [E.SettingID.Sfx] = self.uiBinder.cont_volume.cont_sound.slider_progress_canvasGroup,
    [E.SettingID.Voice] = self.uiBinder.cont_volume.cont_npcdialog.slider_progress_canvasGroup,
    [E.SettingID.System] = self.uiBinder.cont_volume.cont_uiaudio.slider_progress_canvasGroup,
    [E.SettingID.P3] = self.uiBinder.cont_volume.cont_otherplayer.slider_progress_canvasGroup,
    [E.SettingID.PlayerVoiceReceptionVolume] = self.uiBinder.cont_volume.cont_player_voice_reception.slider_progress_canvasGroup,
    [E.SettingID.PlayerVoiceTransmissionVolume] = self.uiBinder.cont_volume.cont_player_voice_sending.slider_progress_canvasGroup
  }
  self.containerList = {
    [E.SettingID.Master] = self.uiBinder.cont_volume.cont_master,
    [E.SettingID.Bgm] = self.uiBinder.cont_volume.cont_music,
    [E.SettingID.Sfx] = self.uiBinder.cont_volume.cont_sound,
    [E.SettingID.Voice] = self.uiBinder.cont_volume.cont_npcdialog,
    [E.SettingID.System] = self.uiBinder.cont_volume.cont_uiaudio,
    [E.SettingID.P3] = self.uiBinder.cont_volume.cont_otherplayer,
    [E.SettingID.PlayerVoiceReceptionVolume] = self.uiBinder.cont_volume.cont_player_voice_reception,
    [E.SettingID.PlayerVoiceTransmissionVolume] = self.uiBinder.cont_volume.cont_player_voice_sending
  }
  self.languageList = {
    [E.SettingID.Master] = self.uiBinder.cont_volume.cont_master.lab_function,
    [E.SettingID.Bgm] = self.uiBinder.cont_volume.cont_music.lab_function,
    [E.SettingID.Sfx] = self.uiBinder.cont_volume.cont_sound.lab_function,
    [E.SettingID.Voice] = self.uiBinder.cont_volume.cont_npcdialog.lab_function,
    [E.SettingID.System] = self.uiBinder.cont_volume.cont_uiaudio.lab_function,
    [E.SettingID.P3] = self.uiBinder.cont_volume.cont_otherplayer.lab_function,
    [E.SettingID.PlayerVoiceReceptionVolume] = self.uiBinder.cont_volume.cont_player_voice_reception.lab_function,
    [E.SettingID.PlayerVoiceTransmissionVolume] = self.uiBinder.cont_volume.cont_player_voice_sending.lab_function
  }
end

function BasemoduleView:OnDeActive()
  for k, v in pairs(self.langVoiceTogItems_) do
    v.tog.group = nil
  end
  self.langTogItems_ = nil
  self.langVoiceTogItems_ = nil
  self.langNamesArray_ = nil
  self.audioLangNamesArray_ = nil
end

function BasemoduleView:setVoiceSwitch()
  for k, v in pairs(self.switchList) do
    local volTag = self.settingData_.VcaTags[k]
    local isOn = self.settingVM_.GetSwitchIsOn(k)
    local alphaValue = isOn and 1 or 0.3
    v.IsOn = isOn
    self.sliderList[k].interactable = isOn
    self.sliderCanvasGroupList[k].alpha = alphaValue
    self:AddClick(v, function(isOpen)
      self.sliderList[k].interactable = isOpen
      alphaValue = isOpen and 1 or 0.3
      self.sliderCanvasGroupList[k].alpha = alphaValue
      local volume = isOpen and self.sliderList[k].value or 0
      self.settingVM_.SetSwitchIsOn(k, isOpen)
      Z.AudioMgr:SetVcaVolume(volume, volTag, false)
      if k == E.SettingID.PlayerVoiceReceptionVolume then
        Z.VoiceBridge.SetSpeakerVolume(volume / 100)
      elseif k == E.SettingID.PlayerVoiceTransmissionVolume then
        Z.VoiceBridge.SetMicVolume(volume / 100)
      end
    end)
  end
end

function BasemoduleView:initVoice()
  for k, v in pairs(self.sliderList) do
    local volValue = Mathf.Floor(self.settingVM_.Get(k))
    local volTag = self.settingData_.VcaTags[k]
    local sliderLab = self.containerList[k].lab_value
    v.value = volValue
    sliderLab.text = volValue ~= 0 and volValue .. "%" or 0
    local funcSwitch = self.switchList[k]
    v.interactable = funcSwitch.IsOn
    self:AddClick(v, function(value)
      local value = math.floor(value + 0.5)
      sliderLab.text = value ~= 0 and value .. "%" or 0
      value = funcSwitch.IsOn and value or 0
      Z.AudioMgr:SetVcaVolume(value, volTag, false)
      if k == E.SettingID.PlayerVoiceReceptionVolume then
        Z.VoiceBridge.SetSpeakerVolume(value / 100)
      elseif k == E.SettingID.PlayerVoiceTransmissionVolume then
        Z.VoiceBridge.SetMicVolume(value / 100)
      end
    end)
    v:AddDragEndListener(function()
      local value = math.floor(v.value + 0.5)
      self.settingVM_.Set(k, value)
    end)
  end
  self:setVoiceSwitch()
end

function BasemoduleView:initLangVoiceItem()
  if self.switchVm_.CheckFuncSwitch(E.SetFuncId.SettingLanguageVoice) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_languagevoice.Ref, true)
    self.curLanguageVoiceIdx_ = Z.LocalizationMgr:GetCurrentLanguageVoice()
    self.audioLangNamesArray_ = Z.LocalizationMgr:GetAudioLanNames()
    self.uiBinder.cont_languagevoice.Ref.UIComp:SetVisible(#self.showAudioLangs_ > 1)
    if #self.showAudioLangs_ > 1 then
      Z.CoroUtil.create_coro_xpcall(function()
        for index, langId in ipairs(self.showAudioLangs_) do
          local item = self:AsyncLoadUiUnit("ui/prefabs/set/set_language_item_tpl", "langIVoicetem" .. langId, self.uiBinder.cont_languagevoice.node_list_trans)
          if item then
            self.langVoiceTogItems_[langId] = item
            item.tog.group = self.uiBinder.cont_languagevoice.node_list
            item.tog:RemoveAllListeners()
            local name = self.audioLangNamesArray_[langId]
            item.lab_language_off.text = name
            item.lab_language_on.text = name
            item.Ref:SetVisible(item.img_off, index ~= #self.showAudioLangs_)
            item.tog:AddListener(function(isOn)
              if isOn then
                self:setLangVoiceItemSelect(langId, true)
              end
            end)
          end
        end
        self:setLangVoiceItemSelect(self.curLanguageVoiceIdx_, false)
      end)()
    else
      self:setLangVoiceItemSelect(self.curLanguageVoiceIdx_, false)
    end
  else
    self.uiBinder.cont_languagevoice.Ref.UIComp:SetVisible(false)
  end
end

function BasemoduleView:setLangVoiceItemSelect(languageIdx, showTip)
  local itemIndex = languageIdx
  local item = self.langVoiceTogItems_[itemIndex]
  if item and not item.tog.isOn then
    item.tog.isOn = true
  end
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

function BasemoduleView:initLangItem()
  if self.switchVm_.CheckFuncSwitch(E.SetFuncId.SettingLanguage) and not Z.GameContext.IsPreviewEnvironment() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_language.Ref, true)
    self.curLanguageIdx_ = Z.LocalizationMgr:GetCurrentLanguage()
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_language.Ref, #self.showLangs_ > 1)
    if #self.showLangs_ > 1 then
      Z.CoroUtil.create_coro_xpcall(function()
        for itemIdx = 1, #self.showLangs_ do
          local item = self:AsyncLoadUiUnit("ui/prefabs/set/set_language_item_tpl", "langItem" .. self.showLangs_[itemIdx], self.uiBinder.cont_language.layout_content_Trans)
          if item then
            self.langTogItems_[self.showLangs_[itemIdx]] = item
            item.tog.group = self.uiBinder.cont_language.layout_content
            item.tog:RemoveAllListeners()
            item.tog.isOn = false
            local name = self.langNamesArray_[self.showLangs_[itemIdx]]
            item.lab_language_off.text = name
            item.lab_language_on.text = name
            item.Ref:SetVisible(item.img_off, itemIdx ~= #self.showLangs_)
            item.tog:AddListener(function(isOn)
              if isOn then
                self:setLangItemSelect(self.showLangs_[itemIdx], true)
              end
            end)
          end
        end
        self:setLangItemSelect(self.curLanguageIdx_, false)
      end)()
    else
      self:setLangItemSelect(self.curLanguageIdx_, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_language.Ref, false)
  end
end

function BasemoduleView:setLangItemSelect(languageIdx, showTip)
  local itemIndex = languageIdx
  local item = self.langTogItems_[itemIndex]
  if item and not item.tog.isOn then
    item.tog.isOn = true
  end
  if self.curLanguageIdx_ ~= languageIdx then
    self.curLanguageIdx_ = languageIdx
    Z.LocalizationMgr:SetLanguage(self.curLanguageIdx_)
    if showTip then
      Z.TipsVM.ShowTips(1000746, {
        val = self.langNamesArray_[languageIdx]
      })
    end
    Z.DataMgr.OnLanguageChange()
    if not self.viewData or not self.viewData.isLogin then
      Z.UIMgr:DeActiveAll(false, "setting")
      Z.UIMgr:OpenView(Z.ConstValue.MainViewName)
    end
    self:initLangVoiceItem()
    Z.EventMgr:Dispatch(Z.ConstValue.LanguageChange)
  end
end

function BasemoduleView:initClearCache()
  self:AddClick(self.uiBinder.cont_cache.btn_clear, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("CustomIdcardResourceCleaning"), function()
      Z.LuaBridge.DeleteDirectoryByPath({"snapshot"})
      Z.TipsVM.ShowTips(1044023)
    end)
  end)
end

return BasemoduleView
