local UI = Z.UI
local super = require("ui.ui_view_base")
local Zrp_settingView = class("Zrp_settingView", super)
local QualityGradeSetting = Panda.Utility.Quality.QualityGradeSetting
local EQualityPlatform = Panda.Utility.Quality.EQualityPlatform
local EQualityGrade = Panda.Utility.Quality.EQualityGrade
local EResolution = Panda.Utility.Quality.EResolution
local EFrameRate = Panda.Utility.Quality.EFrameRate
local ERenderScale = Panda.Utility.Quality.ERenderScale
local EShadowGrade = Panda.Utility.Quality.EShadowGrade
local EPostEffectGrade = Panda.Utility.Quality.EPostEffectGrade
local ESceneDetailGrade = Panda.Utility.Quality.ESceneDetailGrade
local ECharDetailGrade = Panda.Utility.Quality.ECharDetailGrade
local EEffectDetailGrade = Panda.Utility.Quality.EEffectDetailGrade
local EOutlineQuality = Panda.Utility.Quality.EOutlineQuality
local EUpScaleGrade = Panda.Utility.Quality.EUpScaleGrade
local EEffectLod = Panda.ZEffect.EEffectLod

function Zrp_settingView:ctor()
  self.uiBinder = nil
  super.ctor(self, "zrp_setting")
  self.passObjs = {}
  self.vm = Z.VMMgr.GetVM("zrp_setting")
  self.gmData_ = Z.DataMgr.Get("gm_data")
end

function Zrp_settingView:OnActive()
  self:BindEvents()
end

function Zrp_settingView:OnDeActive()
  self:ClearPassObjs()
end

function Zrp_settingView:ClearPassObjs()
  for _, value in ipairs(self.passObjs) do
    UnityEngine.GameObject.Destroy(value)
  end
  self.passObjs = {}
end

function Zrp_settingView:BindEvents()
  self:AddClick(self.uiBinder.btn_close, function()
    self.vm.CloseZrpSetting()
  end)
  self:AddClick(self.uiBinder.btn_gradeveryhigh, function()
    QualityGradeSetting.QualityGrade = EQualityGrade.EVeryHigh
    self:OnRefresh()
  end)
  self:AddClick(self.uiBinder.btn_gradehigh, function()
    QualityGradeSetting.QualityGrade = EQualityGrade.EHigh
    self:OnRefresh()
  end)
  self:AddClick(self.uiBinder.btn_grademiddle, function()
    QualityGradeSetting.QualityGrade = EQualityGrade.EMiddle
    self:OnRefresh()
  end)
  self:AddClick(self.uiBinder.btn_gradelow, function()
    QualityGradeSetting.QualityGrade = EQualityGrade.ELow
    self:OnRefresh()
  end)
  self.uiBinder.dp_platform:AddListener(function(index)
    QualityGradeSetting.CurrentPlatform = EQualityPlatform.IntToEnum(index)
  end, true)
  self.uiBinder.slider_resolution:AddListener(function(value)
    local index = math.floor(value * tonumber(EResolution.ECount:ToInt() - 1) + 0.5)
    QualityGradeSetting.ResolutionHeight = EResolution.IntToEnum(index)
    self.uiBinder.lab_resolution.text = tostring(QualityGradeSetting.ResolutionHeight)
  end)
  self.uiBinder.slider_renderscale:AddListener(function(value)
    local index = math.floor(value * tonumber(ERenderScale.ECount:ToInt() - 1) + 0.5)
    QualityGradeSetting.RenderScale = ERenderScale.IntToEnum(index)
    self.uiBinder.lab_renderscale.text = tostring(index * 0.25 + 0.5)
  end)
  self.uiBinder.dp_framerate:AddListener(function(index)
    QualityGradeSetting.FrameRate = EFrameRate.IntToEnum(index)
  end, true)
  self.uiBinder.dp_shadowgrade:AddListener(function(index)
    QualityGradeSetting.ShadowGrade = EShadowGrade.IntToEnum(index)
  end, true)
  self.uiBinder.dp_posteffectgrade:AddListener(function(index)
    QualityGradeSetting.PostEffectGrade = EPostEffectGrade.IntToEnum(index)
  end, true)
  self.uiBinder.dp_scenegrade:AddListener(function(index)
    QualityGradeSetting.SceneDetailGrade = ESceneDetailGrade.IntToEnum(index)
  end, true)
  self.uiBinder.dp_chargrade:AddListener(function(index)
    QualityGradeSetting.CharDetailGrade = ECharDetailGrade.IntToEnum(index)
  end, true)
  self.uiBinder.dp_effectgrade:AddListener(function(index)
    QualityGradeSetting.EffectDetailGrade = EEffectDetailGrade.IntToEnum(index)
  end, true)
  self.uiBinder.dp_upscalegrade:AddListener(function(index)
    QualityGradeSetting.UpScaleGrade = EUpScaleGrade.IntToEnum(index)
  end, true)
  self.uiBinder.slider_sharpnessgrade:AddListener(function(value)
    QualityGradeSetting.ApplySharpness = value
    self.uiBinder.lab_sharpnessgrade.text = tostring(value)
  end)
  self.uiBinder.input_budgetsize:AddListener(function(text)
    QualityGradeSetting.MipmapStreamingBudgetSize = tonumber(text)
  end)
  self.uiBinder.input_maxreducion:AddListener(function(text)
    QualityGradeSetting.MipmapStreamingMaxReduction = tonumber(text)
  end)
  self.uiBinder.input_lodbias:AddListener(function(text)
    QualityGradeSetting.LodBias = tonumber(text)
  end)
  self.uiBinder.input_csmdis:AddListener(function(text)
    QualityGradeSetting.CSMShadowDistance = tonumber(text)
  end)
  self.uiBinder.input_effect_vh:AddListener(function(text)
    QualityGradeSetting.SetEffectLimit(EEffectLod.EVeryHigh, tonumber(text))
  end)
  self.uiBinder.input_effect_h:AddListener(function(text)
    QualityGradeSetting.SetEffectLimit(EEffectLod.EHigh, tonumber(text))
  end)
  self.uiBinder.input_effect_m:AddListener(function(text)
    QualityGradeSetting.SetEffectLimit(EEffectLod.EMedium, tonumber(text))
  end)
  self.uiBinder.input_effect_l:AddListener(function(text)
    QualityGradeSetting.SetEffectLimit(EEffectLod.ELow, tonumber(text))
  end)
  self.uiBinder.input_effect_vl:AddListener(function(text)
    QualityGradeSetting.SetEffectLimit(EEffectLod.EVeryLow, tonumber(text))
  end)
  self.uiBinder.tog_srpbatch:AddListener(function(r)
    QualityGradeSetting.SrpBatchSwitch = r
  end)
  self.uiBinder.tog_cutscene:AddListener(function(r)
    QualityGradeSetting.CutSceneSwitch = r
  end)
  self.uiBinder.tog_ssr:AddListener(function(r)
    QualityGradeSetting.EnableSsr = r
  end)
  self.uiBinder.tog_fog:AddListener(function(r)
    QualityGradeSetting.EnableVolumeFog = r
  end)
  self.uiBinder.tog_lightscattering:AddListener(function(r)
    QualityGradeSetting.EnableLightScattering = r
  end)
  self.uiBinder.tog_motionblur:AddListener(function(r)
    QualityGradeSetting.EnableMotionBlur = r
  end)
  self.uiBinder.tog_taa:AddListener(function(r)
    QualityGradeSetting.EnableAA = r
  end)
  self.uiBinder.tog_bloom:AddListener(function(r)
    QualityGradeSetting.EnableBloom = r
  end)
  self.uiBinder.tog_bloomlensflare:AddListener(function(r)
    QualityGradeSetting.EnableBloomLensflare = r
  end)
  self.uiBinder.tog_outline:AddListener(function(r)
    QualityGradeSetting.EnableOutline = r
  end)
  self.uiBinder.tog_ecsmodel:AddListener(function(isOn)
    Z.GameContext.UseECSModel = isOn
  end)
  self.uiBinder.tog_scene:AddListener(function(isOn)
    QualityGradeSetting.IsSceneVisible = isOn
    self:RefreshPasses()
  end)
  self.uiBinder.tog_char:AddListener(function(isOn)
    QualityGradeSetting.IsCharVisible = isOn
    self:RefreshPasses()
  end)
  self.uiBinder.tog_op_worker:AddListener(function(isOn)
    QualityGradeSetting.IsLimitWorkerCount = isOn
    self:RefreshPasses()
  end)
  self.uiBinder.tog_bug:AddListener(function(isOn)
    self.gmData_.IsOpenBug = isOn
    Z.EventMgr:Dispatch(Z.ConstValue.GM.IsOpenBug, isOn)
  end)
  self.uiBinder.tog_subpass:AddListener(function(r)
    QualityGradeSetting.EnableSubpass = r
  end)
  self.uiBinder.tog_vsync:AddListener(function(r)
    QualityGradeSetting.EnableVSync = r
  end)
  self.uiBinder.tog_gm:AddListener(function(isOn)
    self.gmData_.IsOpenGm = isOn
    Z.EventMgr:Dispatch(Z.ConstValue.GM.IsOpenGm, isOn)
  end)
  self.uiBinder.tog_watermark:AddListener(function(isOn)
    local markData = Z.DataMgr.Get("mark_data")
    markData:SetMarkState(isOn)
    Z.EventMgr:Dispatch(Z.ConstValue.GM.IsOpenMake, isOn)
  end)
end

function Zrp_settingView:OnRefresh()
  self.uiBinder.dp_platform:SetValueWithoutNotify(QualityGradeSetting.CurrentPlatform:ToInt())
  self.uiBinder.dp_platform:RefreshShownValue()
  self.uiBinder.slider_resolution.value = QualityGradeSetting.ResolutionHeight:ToInt() / (EResolution.ECount:ToInt() - 1)
  self.uiBinder.lab_resolution.text = tostring(QualityGradeSetting.ResolutionHeight)
  self.uiBinder.slider_renderscale.value = QualityGradeSetting.RenderScale:ToInt() / (ERenderScale.ECount:ToInt() - 1)
  self.uiBinder.lab_renderscale.text = tostring(QualityGradeSetting.RenderScale:ToInt() * 0.25 + 0.5)
  self.uiBinder.dp_framerate:SetValueWithoutNotify(QualityGradeSetting.FrameRate:ToInt())
  self.uiBinder.dp_framerate:RefreshShownValue()
  self.uiBinder.dp_shadowgrade:SetValueWithoutNotify(QualityGradeSetting.ShadowGrade:ToInt())
  self.uiBinder.dp_shadowgrade:RefreshShownValue()
  self.uiBinder.dp_posteffectgrade:SetValueWithoutNotify(QualityGradeSetting.PostEffectGrade:ToInt())
  self.uiBinder.dp_posteffectgrade:RefreshShownValue()
  self.uiBinder.dp_scenegrade:SetValueWithoutNotify(QualityGradeSetting.SceneDetailGrade:ToInt())
  self.uiBinder.dp_scenegrade:RefreshShownValue()
  self.uiBinder.dp_chargrade:SetValueWithoutNotify(QualityGradeSetting.CharDetailGrade:ToInt())
  self.uiBinder.dp_chargrade:RefreshShownValue()
  self.uiBinder.dp_effectgrade:SetValueWithoutNotify(QualityGradeSetting.EffectDetailGrade:ToInt())
  self.uiBinder.dp_effectgrade:RefreshShownValue()
  self.uiBinder.dp_upscalegrade:SetValueWithoutNotify(QualityGradeSetting.UpScaleGrade:ToInt())
  self.uiBinder.dp_upscalegrade:RefreshShownValue()
  self.uiBinder.slider_sharpnessgrade.value = QualityGradeSetting.ApplySharpness
  self.uiBinder.lab_sharpnessgrade.text = tostring(QualityGradeSetting.ApplySharpness)
  self.uiBinder.input_budgetsize.text = tostring(QualityGradeSetting.MipmapStreamingBudgetSize)
  self.uiBinder.input_maxreducion.text = tostring(QualityGradeSetting.MipmapStreamingMaxReduction)
  self.uiBinder.input_lodbias.text = tostring(QualityGradeSetting.LodBias)
  self.uiBinder.input_csmdis.text = tostring(QualityGradeSetting.CSMShadowDistance)
  self.uiBinder.input_effect_vh.text = tostring(QualityGradeSetting.GetEffectLimit(EEffectLod.EVeryHigh))
  self.uiBinder.input_effect_h.text = tostring(QualityGradeSetting.GetEffectLimit(EEffectLod.EHigh))
  self.uiBinder.input_effect_m.text = tostring(QualityGradeSetting.GetEffectLimit(EEffectLod.EMedium))
  self.uiBinder.input_effect_l.text = tostring(QualityGradeSetting.GetEffectLimit(EEffectLod.ELow))
  self.uiBinder.input_effect_vl.text = tostring(QualityGradeSetting.GetEffectLimit(EEffectLod.EVeryLow))
  self.uiBinder.tog_srpbatch.isOn = QualityGradeSetting.SrpBatchSwitch
  self.uiBinder.tog_cutscene.isOn = QualityGradeSetting.CutSceneSwitch
  self.uiBinder.tog_fog.isOn = QualityGradeSetting.EnableVolumeFog
  self.uiBinder.tog_lightscattering.isOn = QualityGradeSetting.EnableLightScattering
  self.uiBinder.tog_taa.isOn = QualityGradeSetting.EnableAA
  self.uiBinder.tog_bloom.isOn = QualityGradeSetting.EnableBloom
  self.uiBinder.tog_bloomlensflare.isOn = QualityGradeSetting.EnableBloomLensflare
  self.uiBinder.tog_ssr.isOn = QualityGradeSetting.EnableSsr
  self.uiBinder.tog_motionblur.isOn = QualityGradeSetting.EnableMotionBlur
  self.uiBinder.tog_subpass.isOn = QualityGradeSetting.EnableSubpass
  self.uiBinder.tog_vsync.isOn = QualityGradeSetting.EnableVSync
  self.uiBinder.tog_ecsmodel.isOn = Z.GameContext.UseECSModel
  self.uiBinder.tog_scene.isOn = QualityGradeSetting.IsSceneVisible
  self.uiBinder.tog_char.isOn = QualityGradeSetting.IsCharVisible
  self.uiBinder.tog_op_worker.isOn = QualityGradeSetting.IsLimitWorkerCount
  self.uiBinder.tog_bug.isOn = self.gmData_.IsOpenBug
  self.uiBinder.tog_gm.isOn = self.gmData_.IsOpenGm
  self.uiBinder.tog_watermark.isOn = self.gmData_.IsOpenWaterMark
  self.uiBinder.tog_outline.isOn = QualityGradeSetting.EnableOutline
  self:RefreshPasses()
  local lastScore = Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Device, "Devices_Quality_Score", 0)
  if lastScore ~= 0 then
    self.uiBinder.last_score.text = "Quality Score:" .. lastScore
  else
    self.uiBinder.last_score.text = ""
  end
  self.uiBinder.performancescore.text = tostring(Z.LocalUserDataMgr.GetIntByLua(E.LocalUserDataType.Device, "PERFORMANCE_TEST_SCORE", 0))
end

function Zrp_settingView:RefreshPasses()
  self:ClearPassObjs()
  if QualityGradeSetting.RenderPassList then
    for i = 0, QualityGradeSetting.RenderPassList.Count - 1 do
      local pass = QualityGradeSetting.RenderPassList:get_Item(i)
      if pass.isGroup then
        for j = 0, pass.SubPasses.Count - 1 do
          local subPass = pass.SubPasses:get_Item(j)
          for k = 0, subPass.RendererPassList.Count - 1 do
            local p = subPass.RendererPassList:get_Item(k)
            self:AddRenderPass(p)
          end
        end
      else
        self:AddRenderPass(pass)
      end
    end
  end
end

function Zrp_settingView:AddRenderPass(pass)
  local go = UnityEngine.GameObject.Instantiate(self.uiBinder.zrp_renderpass.Go)
  go.transform:SetParent(self.uiBinder.sv_renderpass.Content)
  go.transform.localScale = Vector3.one
  go.transform.localPosition = Vector3.zero
  go.transform.localRotation = Quaternion.identity
  go:SetActive(true)
  table.insert(self.passObjs, go)
  local temp = UIBinderToLua(go)
  temp.lab_passname.text = pass.name
  temp.tog_pass.isOn = pass.runtimeActive
  temp.tog_pass.enabled = pass.isActive
  temp.tog_pass:AddListener(function(r)
    pass.runtimeActive = r
  end)
end

return Zrp_settingView
