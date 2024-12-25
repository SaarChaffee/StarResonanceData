local UI = Z.UI
local super = require("ui.ui_view_base")
local Fade_windowView = class("Fade_windowView", super)

function Fade_windowView:ctor()
  self.panel = nil
  super.ctor(self, "fade_window")
end

function Fade_windowView:onFadeIn(data)
  if self.timeOutTimer then
    self.timerMgr:StopTimer(self.timeOutTimer)
    self.timeOutTimer = nil
  end
  self.panel.anim.TweenContainer:Pause()
  Z.LuaBridge.SetBackgroundLoadingPriority(true)
  self.panel.anim.Ref.CanvasGroup.alpha = 0
  if data and data.IsInstant then
    self.panel.anim.TweenContainer:Rewind(Z.DOTweenAnimType.Open)
    self.panel.anim.TweenContainer:Complete(Z.DOTweenAnimType.Open)
    self:onFadeInEnd(data)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(self.panel.anim.TweenContainer.CoroPlay)
      coro(self.panel.anim.TweenContainer, Z.DOTweenAnimType.Open)
      self:onFadeInEnd(data)
    end, function(err)
      if err == ZUtil.ZCancelSource.CancelException then
        return
      end
      Z.LuaBridge.SetBackgroundLoadingPriority(false)
    end)()
  end
end

function Fade_windowView:onFadeInEnd(data)
  if not data then
    return
  end
  if data.TimeOut ~= nil and data.TimeOut > 0 then
    self.timeOutTimer = self.timerMgr:StartTimer(function()
      self.timeOutTimer = nil
      self:onFadeOut()
    end, data.TimeOut)
  end
  if data.EndCallback ~= nil then
    data.EndCallback()
  end
  if data.MaskType and data.WaitId then
    Z.WaitFadeManager:SetFadeOutCondition(data.MaskType, data.WaitId)
  end
end

function Fade_windowView:onFadeOut(data)
  if self.timeOutTimer then
    self.timerMgr:StopTimer(self.timeOutTimer)
    self.timeOutTimer = nil
  end
  self.panel.anim.TweenContainer:Pause()
  Z.LuaBridge.SetBackgroundLoadingPriority(false)
  if data and data.IsInstant then
    self.panel.anim.TweenContainer:Rewind(Z.DOTweenAnimType.Close)
    self.panel.anim.TweenContainer:Complete(Z.DOTweenAnimType.Close)
    self:onFadeOutEnd(data)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(self.panel.anim.TweenContainer.CoroPlay)
      coro(self.panel.anim.TweenContainer, Z.DOTweenAnimType.Close)
      self:onFadeOutEnd(data)
    end)()
  end
end

function Fade_windowView:onFadeOutEnd(data)
  self.panel.anim.Ref.CanvasGroup.alpha = 0
  if data ~= nil and data.EndCallback ~= nil then
    data.EndCallback()
  end
  Z.UIMgr:CloseView("fade_window")
end

function Fade_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:bindEvents()
end

function Fade_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.LuaBridge.SetBackgroundLoadingPriority(false)
end

function Fade_windowView:OnRefresh()
  local fadeArgs = self.viewData
  local color
  if fadeArgs and fadeArgs.IsWhite then
    color = Color.New(1, 1, 1, 1)
  else
    color = Color.New(0, 0, 0, 1)
  end
  self.panel.img.Img:SetColor(color)
  if fadeArgs and fadeArgs.IsOpen then
    self:onFadeIn(fadeArgs)
  else
    self:onFadeOut(fadeArgs)
  end
end

function Fade_windowView:bindEvents()
end

return Fade_windowView
