local CountDownComp = class("CountDownComp")
local UIUnitPrefabPath = "ui/prefabs/controller/controller_count_down_progress_tpl"

function CountDownComp:ctor(parent, key)
  self.uiObj_ = nil
  self.parent_ = parent
  self.key_ = key
  self.curTime = 0
  self.timeOffset = 0
  self.data = nil
  self.timerMgr = Z.TimerMgr.new()
  self.panelRef_ = nil
  self.isRemove_ = false
  self.isVisible_ = true
  self.isFirstUpdate_ = true
end

function CountDownComp:createCountDownData()
  local template = {
    beginTime = 0,
    maxTime = 0,
    hasEffect = false,
    effectType = 0,
    endVisible = false,
    lightPointOffset = Vector2.zero,
    progressRot = Vector3.zero,
    autoRemove = false,
    size = nil,
    lightPointSize = nil,
    useTimer = true,
    initFillAmount = 1,
    bgImg = "",
    progressImg = "",
    lightPointImg = "",
    timeScale = 1,
    spendTime = 0
  }
  local t = setmetatable({}, {__index = template, __newindex = template})
  return t
end

function CountDownComp:Init(panel, countDownData)
  if countDownData then
    self.data = countDownData
  else
    logError("countDownData is nil")
    return
  end
  self.panelRef_ = panel
  Z.CoroUtil.create_coro_xpcall(function()
    self.cancelSource = Z.CancelSource.Rent()
    local cancelSource = self.cancelSource:CreateToken()
    if not self.uiObj_ then
      self.uiObj_ = panel:AsyncLoadUiUnit(UIUnitPrefabPath, self.key_, self.parent_.Trans)
      if Z.CancelSource.IsCanceled(cancelSource) or not self.uiObj_ then
        return
      end
    end
    if self.uiObj_ ~= nil then
      self.uiObj_.Ref:SetVisible(false)
      self:Active(countDownData)
      if countDownData.useTimer and self.data.maxTime > 0 then
        self:Start()
      end
    end
  end)()
end

function CountDownComp:Active(countDownData)
  if countDownData.bgImg == "" then
    self.uiObj_.bg:SetVisible(false)
  else
    self.uiObj_.bg.Img:SetImage(countDownData.bgImg)
    if countDownData.size then
      self.uiObj_.progress.Ref:SetWidth(countDownData.size.x)
      self.uiObj_.progress.Ref:SetHeight(countDownData.size.y)
    end
    self.uiObj_.bg:SetVisible(true)
  end
  if countDownData.progress == "" then
    self.uiObj_.progress:SetVisible(false)
  else
    self.uiObj_.progress.Img:SetImage(countDownData.progressImg)
    if countDownData.size then
      self.uiObj_.progress.Ref:SetWidth(countDownData.size.x)
      self.uiObj_.progress.Ref:SetHeight(countDownData.size.y)
    end
    self.uiObj_.progress.Img.fillAmount = countDownData.initFillAmount
    self.uiObj_.progress:SetVisible(true)
  end
  self.uiObj_.light_point:SetVisible(false)
  self.uiObj_.translation_light_point:SetVisible(false)
  local lightPoint
  if countDownData.effectType == E.CountDownEffectType.Ring then
    lightPoint = self.uiObj_.light_point
    self.uiObj_.progress.Img:SetImageFillMethod(4)
    lightPoint.ZEff:SetEffectGoVisible(true)
    self.uiObj_.ring.Ref:SetRotate(0, 0, 0)
  elseif countDownData.effectType == E.CountDownEffectType.Horizontal then
    lightPoint = self.uiObj_.translation_light_point
    self.uiObj_.progress.Img:SetImageFillMethod(0)
  elseif countDownData.effectType == E.CountDownEffectType.Vertical then
    lightPoint = self.uiObj_.translation_light_point
    self.uiObj_.progress.Img:SetImageFillMethod(1)
  else
    logGreen("not set effectType")
  end
  if countDownData.hasEffect then
    if lightPoint then
      lightPoint:SetVisible(true)
      if countDownData.lightPointImg ~= nil and 0 < #countDownData.lightPointImg then
        lightPoint.Img:SetImage(countDownData.lightPointImg)
        lightPoint:SetImageSize()
      end
    else
      logError("lightPoint is nil or countDownData.lightPointImg is nil")
    end
  else
    self.uiObj_.translation_light_point:SetVisible(false)
    self.uiObj_.light_point:SetVisible(false)
  end
end

function CountDownComp:SetVisible(flag)
  if self.isVisible_ ~= flag then
    self.isVisible_ = flag
    if self.uiObj_ ~= nil then
      self.uiObj_.Ref:SetVisible(flag)
    end
  end
end

function CountDownComp:Start()
  self.timerMgr:Clear()
  local fillDetal = (self.curTime + self.timeOffset) / self.data.maxTime
  self.uiObj_.progress.Img.fillAmount = 1 - fillDetal
  self.cdTimer = self.timerMgr:StartTimer(function()
    if self.uiObj_ == nil or self.uiObj_.progress == nil then
      self.timerMgr:StopTimer(self.cdTimer)
      self.cdTimer = nil
    end
    if self.isFirstUpdate_ then
      self.isFirstUpdate_ = false
      self.uiObj_.Ref:SetVisible(self.isVisible_)
    end
    self.curTime = self.curTime + 0.1
    local fillDetal = (self.curTime + self.timeOffset) / self.data.maxTime
    self.uiObj_.progress.Img.fillAmount = 1 - fillDetal
    if self.data.hasEffect then
      self:SetLightPoint(fillDetal)
    end
    if 1 < fillDetal then
      self.timerMgr:StopTimer(self.cdTimer)
      self.cdTimer = nil
    end
  end, 0.1, math.maxinteger)
  if self.data.autoRemove then
    self.autoRemoveTimer = self.timerMgr:StartTimer(function()
      self:Uninit()
      self.panelRef_:RemoveUiUnit(self.key_)
    end, self.data.maxTime + 0.1)
  end
end

function CountDownComp:UpdateProgress(fillAmountValue)
  if self.uiObj_ then
    self.uiObj_.Ref:SetVisible(self.isVisible_)
    self.uiObj_.progress.Img.fillAmount = fillAmountValue
    if self.data.hasEffect then
      self:SetLightPoint(fillAmountValue)
    end
  end
end

function CountDownComp:SetLightPoint(delta)
  local lightPoint
  if self.data.effectType == E.CountDownEffectType.Ring then
    lightPoint = self.uiObj_.light_point
    local rotz = 360 * delta
    self.uiObj_.ring.Ref:SetEulerAngls(0, 0, rotz)
  elseif self.data.effectType == E.CountDownEffectType.Horizontal or self.data.effectType == E.CountDownEffectType.Vertical then
    lightPoint = self.uiObj_.translation_light_point
    local w = lightPoint.Trans.sizeDelta.x
    lightPoint.Ref:SetPosition(w * 0.5, 0)
  elseif self.data.effectType == E.CountDownEffectType.Vertical then
    lightPoint = self.uiObj_.translation_light_point
    local h = lightPoint.Trans.sizeDelta.y
    lightPoint.Ref:SetPosition(h * 0.5, 0)
  end
end

function CountDownComp:Stop()
  self.timerMgr:Clear()
end

function CountDownComp:Uninit()
  if not self.isRemove_ then
    self.isRemove_ = true
    if self.cdTimer ~= nil then
      self.timerMgr:StopTimer(self.cdTimer)
      self.cdTimer = nil
    end
    if self.autoRemoveTimer ~= nil then
      self.timerMgr:StopTimer(self.cdTimer)
      self.autoRemoveTimer = nil
    end
    self:Stop()
    self.uiObj_ = nil
    self.parent_ = nil
    self.curTime = nil
    self.data = nil
    self.timerMgr = nil
  end
end

return CountDownComp
