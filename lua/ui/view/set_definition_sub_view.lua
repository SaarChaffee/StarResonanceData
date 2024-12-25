local QualityGradeSetting = Panda.Utility.Quality.QualityGradeSetting
local EQualityPlatform = Panda.Utility.Quality.EQualityPlatform
local EQualityGrade = Panda.Utility.Quality.EQualityGrade
local EFrameRate = Panda.Utility.Quality.EFrameRate
local EShadowGrade = Panda.Utility.Quality.EShadowGrade
local EPostEffectGrade = Panda.Utility.Quality.EPostEffectGrade
local ESceneDetailGrade = Panda.Utility.Quality.ESceneDetailGrade
local ECharDetailGrade = Panda.Utility.Quality.ECharDetailGrade
local EEffectDetailGrade = Panda.Utility.Quality.EEffectDetailGrade
local EUpScaleGrade = Panda.Utility.Quality.EUpScaleGrade
local EOutlineQuality = Panda.Utility.Quality.EOutlineQuality
local EResolution = Panda.Utility.Quality.EResolution
local ERenderScale = Panda.Utility.Quality.ERenderScale
local UI = Z.UI
local super = require("ui.ui_subview_base")
local Set_definition_subView = class("Set_definition_subView", super)
local SettingSwitchItem = require("ui.component.setting.setting_switch_item")

function Set_definition_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "set_definition_sub", "set/set_definition_sub", UI.ECacheLv.None)
  self.settingVM_ = Z.VMMgr.GetVM("setting")
end

function Set_definition_subView:OnActive()
  self.parentView_ = self.viewData.parentView
  self.resolutionManager_ = Panda.Launch.ResolutionManager
  self.displayUtil_ = Z.GameDisplayInfoUtil
  self.uiBinder.set_definition_sub:SetSizeDelta(0, 0)
  self:initBinder()
  self.recommenGrade_ = QualityGradeSetting.RecommendGrade:ToInt()
  self.recommenGrade_ = (self.recommenGrade_ < EQualityGrade.ELow:ToInt() or self.recommenGrade_ > EQualityGrade.EVeryHigh:ToInt()) and EQualityGrade.EVeryHigh:ToInt() or self.recommenGrade_
  self:initComp()
  self:initLayout()
  self:setOther()
  self:initOutDisplayOptions()
  self:initResolutionOptions()
end

function Set_definition_subView:initResolutionOptions()
  self.uiBinder.cont_definition_setting.cont_resolution.Ref.UIComp:SetVisible(Z.IsPCUI)
  if not Z.IsPCUI then
    return
  end
  local optionList = {}
  local resolutionList = self.displayUtil_.GetAllScreenResolutions()
  for i = 0, resolutionList.Count - 1 do
    if resolutionList[i].Width > resolutionList[i].Height then
      table.insert(optionList, {
        Width = resolutionList[i].Width,
        Height = resolutionList[i].Height,
        IsFullScreen = false
      })
    end
  end
  table.sort(optionList, function(a, b)
    if a.Width == b.Width then
      return b.Height < a.Height
    else
      return a.Width > b.Width
    end
  end)
  local optionMaxFull = {
    Width = optionList[1].Width,
    Height = optionList[1].Height,
    IsFullScreen = true
  }
  table.insert(optionList, 1, optionMaxFull)
  local strList = {}
  for _, option in ipairs(optionList) do
    local fullScreenStr = option.IsFullScreen and Lang("FullScreen") or Lang("Window")
    table.insert(strList, string.format("%dx%d %s", option.Width, option.Height, fullScreenStr))
  end
  local dpdNode = self.uiBinder.cont_definition_setting.cont_resolution.cont_dropdown.dpd.dpd
  dpdNode:ClearOptions()
  dpdNode:AddOptions(strList)
  dpdNode:AddListener(function(index)
    local option = optionList[index + 1]
    self.resolutionManager_.SetResolution(option.Width, option.Height, option.IsFullScreen)
  end)
  dpdNode:AddOnClickListener(function(index)
    self.uiBinder.cont_definition_setting.cont_resolution.cont_dropdown.dpd.img_arrow_up:SetRot(-180, 0, 0)
  end)
  dpdNode:AddHideListener(function(index)
    self.uiBinder.cont_definition_setting.cont_resolution.cont_dropdown.dpd.img_arrow_up:SetRot(0, 0, 0)
  end)
  dpdNode.value = self:getCurResolutionOptionIdx(optionList)
end

function Set_definition_subView:getCurResolutionOptionIdx(optionList)
  local width = self.resolutionManager_.CurResolutionWidth
  local height = self.resolutionManager_.CurResolutionHeight
  local isFullScrenn = self.resolutionManager_.IsFullScreen
  for idx, option in ipairs(optionList) do
    if option.Width == width and option.Height == height and option.IsFullScreen == isFullScrenn then
      return idx - 1
    end
  end
  return 0
end

function Set_definition_subView:initOutDisplayOptions()
  self.uiBinder.cont_definition_setting.cont_outdisplay.Ref.UIComp:SetVisible(Z.IsPCUI)
  if not Z.IsPCUI then
    return
  end
  local strList = self.displayUtil_.GetAllDisplayInfoName()
  local dpdNode = self.uiBinder.cont_definition_setting.cont_outdisplay.cont_dropdown.dpd.dpd
  dpdNode:ClearAll()
  dpdNode:ClearOptions()
  dpdNode:AddOptions(strList)
  local newIndex = self.displayUtil_.GetCurWindowOnScreenIndex()
  if newIndex ~= dpdNode.value then
    dpdNode.value = newIndex
  end
  dpdNode:AddListener(function(index)
    if self.isShowDisplayDialog_ then
      return
    end
    local oldIndex = self.displayUtil_.GetCurWindowOnScreenIndex()
    if oldIndex == index then
      return
    end
    self.isShowDisplayDialog_ = true
    local displayResolution = self.displayUtil_.GetCurrentScreenResolution()
    local width = displayResolution.Width
    local height = displayResolution.Height
    local des = Lang("SetShowOutDisplaySureDes", {
      val1 = strList[index],
      val2 = width .. "x" .. height
    })
    Z.DialogViewDataMgr:OpenCountdownOKDialog(des, function()
      self.displayUtil_.ChangeGameMainWindow(index)
      self.uiBinder.cont_definition_setting.cont_resolution.cont_dropdown.dpd.dpd.value = self.resolutionManager_.IsFullScreen and 0 or 1
      Z.DialogViewDataMgr:CloseDialogView()
      self.isShowDisplayDialog_ = false
    end, function()
      dpdNode.value = self.displayUtil_.GetCurWindowOnScreenIndex()
      Z.DialogViewDataMgr:CloseDialogView()
      self.isShowDisplayDialog_ = false
    end, Z.Global.SetTipsCountdown, true)
    dpdNode:ZHide()
  end)
  dpdNode:AddOnClickListener(function(index)
    self.uiBinder.cont_definition_setting.cont_outdisplay.cont_dropdown.dpd.img_arrow_up:SetRot(-180, 0, 0)
  end)
  dpdNode:AddHideListener(function(index)
    self.uiBinder.cont_definition_setting.cont_outdisplay.cont_dropdown.dpd.img_arrow_up:SetRot(0, 0, 0)
  end)
end

function Set_definition_subView:initBinder()
  self.qualityTogGroup_ = self.uiBinder.cont_definition_setting.cont_img_quality.node_list
  self.qualityTogs_ = {}
  self.recommondImgs_ = {}
  self.raycastBtn_ = {}
  for i = EQualityGrade.ELow:ToInt(), EQualityGrade.ECustom:ToInt() do
    local tog = self.uiBinder.cont_definition_setting.cont_img_quality[string.zconcat("tog_option", i + 1)]
    self.qualityTogs_[i] = tog
    tog.group = self.qualityTogGroup_
    self.recommondImgs_[i] = self.uiBinder.cont_definition_setting.cont_img_quality[string.zconcat("img_recommend", i + 1)]
  end
  self.customSetPanel_ = self.uiBinder.cont_definition_setting.cont_custom
  self.shadowTogGroup_ = self.uiBinder.cont_definition_setting.cont_custom.cont_shadow_quality.node_list
  self.shadowTogs_ = {}
  for i = EShadowGrade.ENone:ToInt(), EShadowGrade.EHigh:ToInt() do
    local tog = self.uiBinder.cont_definition_setting.cont_custom.cont_shadow_quality[string.zconcat("tog_option", i + 1)]
    self.shadowTogs_[i] = tog
    tog.group = self.shadowTogGroup_
  end
  self.postEffctTogGroup_ = self.uiBinder.cont_definition_setting.cont_custom.cont_post_effects.node_list
  self.postEffctTogs_ = {}
  for i = EPostEffectGrade.ELow:ToInt(), EPostEffectGrade.EVeryHigh:ToInt() do
    local tog = self.uiBinder.cont_definition_setting.cont_custom.cont_post_effects[string.zconcat("tog_option", i + 1)]
    self.postEffctTogs_[i] = tog
    tog.group = self.postEffctTogGroup_
  end
  self.sceneDetailTogGroup_ = self.uiBinder.cont_definition_setting.cont_custom.cont_scene_detail.node_list
  self.sceneDetailTogs_ = {}
  for i = ESceneDetailGrade.ELow:ToInt(), ESceneDetailGrade.EVeryHigh:ToInt() do
    local tog = self.uiBinder.cont_definition_setting.cont_custom.cont_scene_detail[string.zconcat("tog_option", i + 1)]
    self.sceneDetailTogs_[i] = tog
    tog.group = self.sceneDetailTogGroup_
  end
  self.charDetailTogGroup_ = self.uiBinder.cont_definition_setting.cont_custom.cont_character_detail.node_list
  self.charDetailTogs_ = {}
  for i = ECharDetailGrade.ELow:ToInt(), ECharDetailGrade.EVeryHigh:ToInt() do
    local tog = self.uiBinder.cont_definition_setting.cont_custom.cont_character_detail[string.zconcat("tog_option", i + 1)]
    self.charDetailTogs_[i] = tog
    tog.group = self.charDetailTogGroup_
  end
  self.effectDetailTogGroup_ = self.uiBinder.cont_definition_setting.cont_custom.cont_effect_quality.node_list
  self.effectDetailTogs_ = {}
  for i = EEffectDetailGrade.ELow:ToInt(), EEffectDetailGrade.EVeryHigh:ToInt() do
    local tog = self.uiBinder.cont_definition_setting.cont_custom.cont_effect_quality[string.zconcat("tog_option", i + 1)]
    self.effectDetailTogs_[i] = tog
    tog.group = self.effectDetailTogGroup_
  end
  self:refreshSyncVertical()
  self:refreshFrame()
  self:refreshRenderPrecision()
  self.manNum_Slider_ = self.uiBinder.cont_definition_setting.cont_set_basic_volume.slider_progress
  self.manNum_Lab_ = self.uiBinder.cont_definition_setting.cont_set_basic_volume.lab_value
  self.aliasSwitchMobile_ = self.uiBinder.cont_set_show.cont_anti_aliasing.cont_switch.switch
  self.aliasSwitchPC_ = self.uiBinder.cont_definition_setting.cont_sroff_pc.cont_switch.switch
  self.bloomSwitch_ = self.uiBinder.cont_set_show.cont_bloom.cont_switch.switch
  self.hbloomWight_ = self.uiBinder.cont_set_show.cont_halo
  self.hBloomSwitch_ = self.uiBinder.cont_set_show.cont_halo.cont_switch.switch
  self.reflectSwitch_ = self.uiBinder.cont_set_show.cont_reflect.cont_switch.switch
  self.fogCont_ = self.uiBinder.cont_set_show.cont_volume_fog
  self.fogSwitch_ = self.uiBinder.cont_set_show.cont_volume_fog.cont_switch.switch
  self.lightscatteringCont_ = self.uiBinder.cont_set_show.cont_volume_fog
  self.charOutLine_ = self.uiBinder.cont_set_show.cont_character_outline.cont_switch
  self.charOutLineTogGroup_ = self.uiBinder.cont_set_show.cont_character_outline.node_list
  self:refreshSRSampling()
end

function Set_definition_subView:refreshRenderPrecision()
  self.reMobile_ = self.uiBinder.cont_definition_setting.cont_renderer_precision
  self.resolutionTogGroup_ = self.uiBinder.cont_definition_setting.cont_renderer_precision.node_list
  self.resolutionTogs_ = {}
  local resolutionBeginIndex = EResolution.E540:ToInt()
  local resolutionEndIndex = EResolution.E780:ToInt()
  if QualityGradeSetting.CurrentPlatform == EQualityPlatform.Emulator then
    resolutionBeginIndex = EResolution.E660:ToInt()
    resolutionEndIndex = EResolution.E960:ToInt()
  end
  local count = 1
  for i = resolutionBeginIndex, resolutionEndIndex do
    local tog = self.uiBinder.cont_definition_setting.cont_renderer_precision[string.zconcat("tog_option", count)]
    count = count + 1
    self.resolutionTogs_[i] = tog
    tog.group = self.resolutionTogGroup_
  end
  if QualityGradeSetting.CurrentPlatform == EQualityPlatform.Emulator then
    self:initTogsComp(self.resolutionTogGroup_, self.resolutionTogs_, "ResolutionHeight", EResolution.E660, EResolution.E960, EResolution)
  else
    self:initTogsComp(self.resolutionTogGroup_, self.resolutionTogs_, "ResolutionHeight", EResolution.E540, EResolution.E780, EResolution)
  end
end

function Set_definition_subView:refreshSRSampling()
  self.uiBinder.cont_definition_setting.cont_sr_sampling_pc.Ref.UIComp:SetVisible(Z.IsPCUI)
  self.uiBinder.cont_definition_setting.cont_srset_pc.Ref.UIComp:SetVisible(Z.IsPCUI)
  self.uiBinder.cont_definition_setting.cont_sroff_pc.Ref.UIComp:SetVisible(Z.IsPCUI)
  if not Z.IsPCUI then
    return
  end
  local togGroup = self.uiBinder.cont_definition_setting.cont_sr_sampling_pc.node_list
  local srSamplingTogs = {}
  for i = 1, 3 do
    local tog = self.uiBinder.cont_definition_setting.cont_sr_sampling_pc[string.zconcat("tog_option", i)]
    srSamplingTogs[i] = tog
    tog.group = togGroup
  end
  local useDLSS = QualityGradeSetting.UpScaleGrade == EUpScaleGrade.EDLSS
  local useFSR = QualityGradeSetting.UpScaleGrade == EUpScaleGrade.EFSR3
  srSamplingTogs[1].isOn = useDLSS
  srSamplingTogs[2].isOn = useFSR
  srSamplingTogs[3].isOn = not useDLSS and not useFSR
  local surpportDLSS = QualityGradeSetting.IsSupportDLSS
  self.uiBinder.cont_definition_setting.cont_sr_sampling_pc.Ref:SetVisible(srSamplingTogs[1], surpportDLSS)
  self.uiBinder.cont_definition_setting.cont_sr_sampling_pc.Ref:SetVisible(self.uiBinder.cont_definition_setting.cont_sr_sampling_pc.img_line1, surpportDLSS)
  srSamplingTogs[1]:AddListener(function(isOn)
    if isOn then
      if QualityGradeSetting.UpScaleGrade == EUpScaleGrade.EDLSS then
        return
      end
      QualityGradeSetting.UpScaleGrade = EUpScaleGrade.EDLSS
      self:setSRSubUIVisable()
    end
  end)
  srSamplingTogs[2]:AddListener(function(isOn)
    if isOn then
      if QualityGradeSetting.UpScaleGrade == EUpScaleGrade.EFSR3 then
        return
      end
      QualityGradeSetting.UpScaleGrade = EUpScaleGrade.EFSR3
      self:setSRSubUIVisable()
    end
  end)
  srSamplingTogs[3]:AddListener(function(isOn)
    if isOn then
      if QualityGradeSetting.UpScaleGrade == EUpScaleGrade.ENone then
        return
      end
      QualityGradeSetting.UpScaleGrade = EUpScaleGrade.ENone
      self:setSRSubUIVisable()
    end
  end)
  self:setSRSubUIVisable()
  self:refreshSRSubUI()
end

function Set_definition_subView:setSRSubUIVisable()
  local useSR = QualityGradeSetting.UpScaleGrade == EUpScaleGrade.EDLSS or QualityGradeSetting.UpScaleGrade == EUpScaleGrade.EFSR3
  self.uiBinder.cont_definition_setting.cont_srset_pc.Ref.UIComp:SetVisible(useSR)
  self.uiBinder.cont_definition_setting.cont_sroff_pc.Ref.UIComp:SetVisible(not useSR)
end

function Set_definition_subView:refreshSRSubUI()
  self.aliasSwitchPC_.IsOn = QualityGradeSetting.EnableAA
  self.aliasSwitchPC_:AddListener(function(isOn)
    QualityGradeSetting.EnableAA = isOn
  end)
  if not Z.IsPCUI then
    return
  end
  local togGroup = self.uiBinder.cont_definition_setting.cont_srset_pc.cont_effect_set.node_list
  local togs = {}
  for i = 1, 3 do
    local tog = self.uiBinder.cont_definition_setting.cont_srset_pc.cont_effect_set[string.zconcat("tog_option", i)]
    togs[i] = tog
    tog.group = togGroup
  end
  togs[1].isOn = QualityGradeSetting.RenderScale == ERenderScale.E50Percent
  togs[2].isOn = QualityGradeSetting.RenderScale == ERenderScale.E75Percent
  togs[3].isOn = QualityGradeSetting.RenderScale == ERenderScale.E100Percent
  togs[1]:AddListener(function(isOn)
    if isOn then
      if QualityGradeSetting.RenderScale == ERenderScale.E50Percent then
        return
      end
      QualityGradeSetting.RenderScale = ERenderScale.E50Percent
    end
  end)
  togs[2]:AddListener(function(isOn)
    if isOn then
      if QualityGradeSetting.RenderScale == ERenderScale.E75Percent then
        return
      end
      QualityGradeSetting.RenderScale = ERenderScale.E75Percent
    end
  end)
  togs[3]:AddListener(function(isOn)
    if isOn then
      if QualityGradeSetting.RenderScale == ERenderScale.E100Percent then
        return
      end
      QualityGradeSetting.RenderScale = ERenderScale.E100Percent
    end
  end)
end

function Set_definition_subView:refreshFrame()
  self.framePC_ = self.uiBinder.cont_definition_setting.cont_fps_pc
  self.framePCTogGroup_ = self.uiBinder.cont_definition_setting.cont_fps_pc.node_list
  self.framePCTogs_ = {}
  for i = EFrameRate.E30:ToInt(), EFrameRate.E120:ToInt() do
    local tog = self.uiBinder.cont_definition_setting.cont_fps_pc[string.zconcat("tog_option", i + 1)]
    self.framePCTogs_[i] = tog
    tog.group = self.framePCTogGroup_
  end
  self.frameMobile_ = self.uiBinder.cont_definition_setting.cont_fps
  self.frameTogGroup_ = self.uiBinder.cont_definition_setting.cont_fps.node_list
  self.frameTogs_ = {}
  for i = EFrameRate.E30:ToInt(), EFrameRate.E60:ToInt() do
    local tog = self.uiBinder.cont_definition_setting.cont_fps[string.zconcat("tog_option", i + 1)]
    self.frameTogs_[i] = tog
    tog.group = self.frameTogGroup_
  end
  if Z.IsPCUI then
    self:initFrameTogsComp(self.framePCTogGroup_, self.framePCTogs_, "FrameRate", EFrameRate.E30, EFrameRate.E120, EFrameRate)
  else
    self:initTogsComp(self.frameTogGroup_, self.frameTogs_, "FrameRate", EFrameRate.E30, EFrameRate.E60, EFrameRate)
  end
end

function Set_definition_subView:refreshSyncVertical()
  self.uiBinder.cont_definition_setting.cont_synchronization.Ref.UIComp:SetVisible(Z.IsPCUI)
  if not Z.IsPCUI and QualityGradeSetting.EnableVSync then
    QualityGradeSetting.EnableVSync = false
  end
  if Z.IsPCUI then
    local sync = self.uiBinder.cont_definition_setting.cont_synchronization.switch
    self.sync_ = SettingSwitchItem.new()
    self.sync_:Init(sync, nil, function(isOn)
      QualityGradeSetting.EnableVSync = isOn
      if Z.IsPCUI then
        self.framePC_.cont_fps_pc.alpha = isOn and 0.5 or 1
        self.framePC_.Ref:SetVisible(self.framePC_.img_empty, isOn)
      else
        self.frameMobile_.cont_fps.alpha = isOn and 0.5 or 1
        self.frameMobile_.Ref:SetVisible(self.frameMobile_.img_empty, isOn)
      end
      if isOn then
        Z.TipsVM.ShowTips(1000206)
      end
    end, QualityGradeSetting.EnableVSync)
  end
end

function Set_definition_subView:initLayout()
  self.uiBinder.cont_definition_setting.Ref:SetVisible(self.frameMobile_.Ref, not Z.IsPCUI)
  self.uiBinder.cont_definition_setting.Ref:SetVisible(self.framePC_.Ref, Z.IsPCUI)
  local openSync = QualityGradeSetting.EnableVSync
  if Z.IsPCUI then
    self.framePC_.cont_fps_pc.alpha = openSync and 0.5 or 1
    self.framePC_.Ref:SetVisible(self.framePC_.img_empty, openSync)
  else
    self.frameMobile_.cont_fps.alpha = openSync and 0.5 or 1
    self.frameMobile_.Ref:SetVisible(self.frameMobile_.img_empty, openSync)
  end
  self.uiBinder.cont_definition_setting.Ref:SetVisible(self.reMobile_.Ref, not Z.IsPCUI)
  self.uiBinder.cont_set_show.cont_character_outline.Ref:SetVisible(self.charOutLine_.Ref, true)
  self.uiBinder.cont_set_show.cont_character_outline.Ref:SetVisible(self.charOutLineTogGroup_, false)
  self.uiBinder.cont_set_show.Ref:SetVisible(self.fogCont_.Ref, Z.IsPCUI)
  self.uiBinder.cont_set_show.Ref:SetVisible(self.lightscatteringCont_.Ref, Z.IsPCUI)
  self.uiBinder.cont_definition_setting.Ref:SetVisible(self.customSetPanel_.Ref, EQualityGrade.ECustom == QualityGradeSetting.QualityGrade)
  self:rebuildLayout()
end

function Set_definition_subView:rebuildLayout()
  self.uiBinder.node_subview:ForceRebuildLayoutImmediate()
end

function Set_definition_subView:setCurTog()
  local grade = QualityGradeSetting.QualityGrade
  grade = (grade:ToInt() < EQualityGrade.ELow:ToInt() or grade:ToInt() > EQualityGrade.ECustom:ToInt()) and EQualityGrade.EVeryHigh or grade
  local tog = self.qualityTogs_[grade:ToInt()]
  tog.isOn = true
end

function Set_definition_subView:saveQualityCustom()
  if QualityGradeSetting.QualityGrade == EQualityGrade.ECustom then
    local data = {
      ShadowGrade = QualityGradeSetting.ShadowGrade:ToInt(),
      PostEffectGrade = QualityGradeSetting.PostEffectGrade:ToInt(),
      SceneDetailGrade = QualityGradeSetting.SceneDetailGrade:ToInt(),
      CharDetailGrade = QualityGradeSetting.CharDetailGrade:ToInt(),
      EffectEffectGrade = QualityGradeSetting.EffectDetailGrade:ToInt()
    }
    self.settingVM_.Set(E.ClientSettingID.Grade, data)
  end
end

function Set_definition_subView:initComp()
  self:setCurTog()
  for i = EQualityGrade.ELow:ToInt(), EQualityGrade.ECustom:ToInt() do
    local tog = self.qualityTogs_[i]
    local temp = i
    tog:AddListener(function(isOn)
      if isOn then
        if self.lastQualityGrade_ == EQualityGrade.ECustom:ToInt() then
          self:saveQualityCustom()
        end
        self.lastQualityGrade_ = temp
        self:gradeTogCallFunc(tog, temp)
      end
    end)
    local img = self.recommondImgs_[i]
    if img ~= nil then
      self.uiBinder.cont_definition_setting.cont_img_quality.Ref:SetVisible(img, self.recommenGrade_ == i)
    end
  end
  self:initTogsComp(self.shadowTogGroup_, self.shadowTogs_, "ShadowGrade", EShadowGrade.ENone, EShadowGrade.EHigh, EShadowGrade)
  self:initTogsComp(self.postEffctTogGroup_, self.postEffctTogs_, "PostEffectGrade", EPostEffectGrade.ELow, EPostEffectGrade.EVeryHigh, EPostEffectGrade)
  self:initTogsComp(self.sceneDetailTogGroup_, self.sceneDetailTogs_, "SceneDetailGrade", ESceneDetailGrade.ELow, ESceneDetailGrade.EVeryHigh, ESceneDetailGrade)
  self:initTogsComp(self.charDetailTogGroup_, self.charDetailTogs_, "CharDetailGrade", ECharDetailGrade.ELow, ECharDetailGrade.EVeryHigh, ECharDetailGrade)
  self:initTogsComp(self.effectDetailTogGroup_, self.effectDetailTogs_, "EffectDetailGrade", EEffectDetailGrade.ELow, EEffectDetailGrade.EVeryHigh, EEffectDetailGrade)
  self.uiBinder.cont_set_show.cont_anti_aliasing.Ref.UIComp:SetVisible(not Z.IsPCUI)
  if not Z.IsPCUI then
    self.aliasSwitchMobile_.IsOn = QualityGradeSetting.EnableAA
    self.aliasSwitchMobile_:AddListener(function(isOn)
      QualityGradeSetting.EnableAA = isOn
    end)
  end
  self.bloomSwitch_.IsOn = QualityGradeSetting.EnableBloom
  self.bloomSwitch_:AddListener(function(isOn)
    QualityGradeSetting.EnableBloom = isOn
    self.uiBinder.cont_set_show.Ref:SetVisible(self.hbloomWight_.Ref, isOn and Z.IsPCUI)
    if not isOn then
      QualityGradeSetting.EnableBloomLensflare = isOn
    end
    self.hBloomSwitch_.IsOn = QualityGradeSetting.EnableBloomLensflare
  end)
  self.uiBinder.cont_set_show.Ref:SetVisible(self.hbloomWight_.Ref, QualityGradeSetting.EnableBloom and Z.IsPCUI)
  self.hBloomSwitch_.IsOn = QualityGradeSetting.EnableBloomLensflare
  self.hBloomSwitch_:AddListener(function(isOn)
    QualityGradeSetting.EnableBloomLensflare = isOn
  end)
  self.reflectSwitch_.IsOn = QualityGradeSetting.EnableSsr
  self.reflectSwitch_:AddListener(function(isOn)
    QualityGradeSetting.EnableSsr = isOn
  end)
  self.fogSwitch_.IsOn = QualityGradeSetting.EnableVolumeFog
  self.fogSwitch_:AddListener(function(isOn)
    QualityGradeSetting.EnableVolumeFog = isOn
  end)
  self.charOutLine_.switch.IsOn = QualityGradeSetting.EnableOutline
  self.charOutLine_.switch:AddListener(function(isOn)
    QualityGradeSetting.EnableOutline = isOn
  end)
  local max = Z.IsPCUI and Z.Global.SameScreenNumMaxPC or Z.Global.SameScreenNumMax
  local min = Z.IsPCUI and Z.Global.SameScreenNumMinPC or Z.Global.SameScreenNumMin
  self.manNum_Slider_.maxValue = max
  self.manNum_Slider_.minValue = min
  self.manNum_Slider_.value = QualityGradeSetting.CharLimit
  self.manNum_Slider_:AddListener(function()
    local val = math.floor(self.manNum_Slider_.value + 0.5)
    self.manNum_Lab_.text = tostring(val)
  end)
  self.manNum_Slider_:AddDragEndListener(function()
    QualityGradeSetting.CharLimit = math.floor(self.manNum_Slider_.value + 0.5)
  end)
  self.manNum_Lab_.text = tostring(QualityGradeSetting.CharLimit)
end

function Set_definition_subView:gradeTogCallFunc(tog, i)
  if QualityGradeSetting.QualityGrade:ToInt() == i then
    return
  end
  local func = function()
    QualityGradeSetting.QualityGrade = EQualityGrade.IntToEnum(i)
    if i == EQualityGrade.ECustom:ToInt() then
      self.uiBinder.cont_definition_setting.Ref:SetVisible(self.customSetPanel_.Ref, true)
      self:refreshQualityView()
    else
      self.uiBinder.cont_definition_setting.Ref:SetVisible(self.customSetPanel_.Ref, false)
    end
    self:rebuildLayout()
    self.parentView_:RefreshSubView(E.SetFuncId.SettingFrame)
    Z.EventMgr:Dispatch(Z.ConstValue.UserSetting.ImageQualityChanged)
  end
  if i > self.recommenGrade_ and i ~= EQualityGrade.ECustom:ToInt() then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("SetHighQualityGrade"), function()
      tog.isOn = true
      Z.DialogViewDataMgr:CloseDialogView()
      func()
    end, function()
      Z.DialogViewDataMgr:CloseDialogView()
      self:setCurTog()
    end)
  else
    tog.isOn = true
    func()
  end
end

function Set_definition_subView:initTogsComp(group, togs, setEnumStr, beginIdx, endIdx, enumType)
  for i = beginIdx:ToInt(), endIdx:ToInt() do
    local tog = togs[i]
    tog:RemoveAllListeners()
  end
  for i = beginIdx:ToInt(), endIdx:ToInt() do
    local tog = togs[i]
    if i == QualityGradeSetting[setEnumStr]:ToInt() then
      tog.isOn = true
    end
    local temp = i
    tog:AddListener(function()
      if tog.isOn then
        QualityGradeSetting[setEnumStr] = enumType.IntToEnum(temp)
      end
    end)
  end
end

function Set_definition_subView:initFrameTogsComp(group, togs, setEnumStr, beginIdx, endIdx, enumType)
  for i = beginIdx:ToInt(), endIdx:ToInt() do
    local tog = togs[i]
    if i == QualityGradeSetting[setEnumStr]:ToInt() then
      tog.isOn = true
    end
    local temp = i
    tog:AddListener(function()
      if tog.isOn then
        if QualityGradeSetting[setEnumStr]:ToInt() == temp then
          return
        end
        local confirm = function()
          QualityGradeSetting[setEnumStr] = enumType.IntToEnum(temp)
          self.uiBinder.cont_definition_setting.cont_synchronization.switch.IsOn = false
        end
        local onCancel = function()
          for k, v in pairs(togs) do
            v:SetIsOnWithoutCallBack(k == QualityGradeSetting[setEnumStr]:ToInt())
          end
        end
        if QualityGradeSetting.EnableVSync then
          Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("SettingDefintionFrameConfirm"), confirm, onCancel, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.SettingDefinitionFrameConfirm)
        else
          confirm()
        end
      end
    end)
  end
end

function Set_definition_subView:setOther()
  local motionSwitch = self.uiBinder.cont_set_show.cont_motionblur.cont_switch.switch
  self.uiBinder.cont_set_show.Ref:SetVisible(self.uiBinder.cont_set_show.cont_motionblur.Ref, Z.IsPCUI)
  if Z.IsPCUI then
    self.motionSwitch_ = SettingSwitchItem.new()
    self.motionSwitch_:Init(motionSwitch, nil, function(isOn)
      QualityGradeSetting.EnableMotionBlur = isOn
    end, QualityGradeSetting.EnableMotionBlur)
  end
end

function Set_definition_subView:OnDeActive()
  self:saveQualityCustom()
  self.resolutionManager_ = nil
  self.displayUtil_ = nil
  self.uiBinder.cont_definition_setting.cont_outdisplay.cont_dropdown.dpd.dpd:ClearAll()
end

function Set_definition_subView:OnRefresh()
end

function Set_definition_subView:refreshQualityView()
  local eData = self.settingVM_.Get(E.ClientSettingID.Grade)
  eData = eData == nil and {
    ShadowGrade = QualityGradeSetting.ShadowGrade:ToInt(),
    PostEffectGrade = QualityGradeSetting.PostEffectGrade:ToInt(),
    SceneDetailGrade = QualityGradeSetting.SceneDetailGrade:ToInt(),
    CharDetailGrade = QualityGradeSetting.CharDetailGrade:ToInt(),
    EffectEffectGrade = QualityGradeSetting.EffectDetailGrade:ToInt()
  } or eData
  self:refreshComp(self.shadowTogGroup_, self.shadowTogs_, "ShadowGrade", EShadowGrade.ENone, EShadowGrade.EHigh, eData.ShadowGrade, EShadowGrade)
  self:refreshComp(self.postEffctTogGroup_, self.postEffctTogs_, "PostEffectGrade", EPostEffectGrade.ELow, EPostEffectGrade.EVeryHigh, eData.PostEffectGrade, EPostEffectGrade)
  self:refreshComp(self.sceneDetailTogGroup_, self.sceneDetailTogs_, "SceneDetailGrade", ESceneDetailGrade.ELow, ESceneDetailGrade.EVeryHigh, eData.SceneDetailGrade, ESceneDetailGrade)
  self:refreshComp(self.charDetailTogGroup_, self.charDetailTogs_, "CharDetailGrade", ECharDetailGrade.ELow, ECharDetailGrade.EVeryHigh, eData.CharDetailGrade, ECharDetailGrade)
  self:refreshComp(self.effectDetailTogGroup_, self.effectDetailTogs_, "EffectDetailGrade", EEffectDetailGrade.ELow, EEffectDetailGrade.EVeryHigh, eData.EffectEffectGrade, EEffectDetailGrade)
end

function Set_definition_subView:refreshComp(group, togs, setEnumStr, beginIdx, endIdx, showEnum, enumType)
  for i = beginIdx:ToInt(), endIdx:ToInt() do
    local tog = togs[i]
    if i == showEnum then
      tog.isOn = true
      QualityGradeSetting[setEnumStr] = enumType.IntToEnum(i)
    end
  end
end

return Set_definition_subView
