local UI = Z.UI
local super = require("ui.ui_view_base")
local Fade_windowView = class("Fade_windowView", super)

function Fade_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fade_window")
end

function Fade_windowView:onFadeIn(data)
  if self.timeOutTimer then
    self.timerMgr:StopTimer(self.timeOutTimer)
    self.timeOutTimer = nil
  end
  self.uiBinder.comp_tween_main:Pause()
  Z.LuaBridge.SetBackgroundLoadingPriority(true)
  self.uiBinder.canvas_group_main.alpha = 0
  local openAnimType = Z.DOTweenAnimType.Open
  if data and data.OpenAnimType then
    openAnimType = data.OpenAnimType
  end
  if data and data.IsInstant then
    self.uiBinder.comp_tween_main:Rewind(openAnimType)
    self.uiBinder.comp_tween_main:Complete(openAnimType)
    self:onFadeInEnd(data)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(self.uiBinder.comp_tween_main.CoroPlay)
      coro(self.uiBinder.comp_tween_main, openAnimType)
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
  self.uiBinder.comp_tween_main:Pause()
  Z.LuaBridge.SetBackgroundLoadingPriority(false)
  local closeAnimType = Z.DOTweenAnimType.Close
  if data and data.CloseAnimType then
    closeAnimType = data.CloseAnimType
  end
  if data and data.IsInstant then
    self.uiBinder.comp_tween_main:Rewind(closeAnimType)
    self.uiBinder.comp_tween_main:Complete(closeAnimType)
    self:onFadeOutEnd(data)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(self.uiBinder.comp_tween_main.CoroPlay)
      coro(self.uiBinder.comp_tween_main, closeAnimType)
      self:onFadeOutEnd(data)
    end)()
  end
end

function Fade_windowView:onFadeOutEnd(data)
  self.uiBinder.canvas_group_main.alpha = 0
  if data ~= nil and data.EndCallback ~= nil then
    data.EndCallback()
  end
  Z.UIMgr:CloseView("fade_window")
end

function Fade_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.InputMgr:EnableInput(false, Panda.ZGame.EInputMgrEableSource.FadeWindow)
  self:bindEvents()
end

function Fade_windowView:OnDeActive()
  Z.InputMgr:EnableInput(true, Panda.ZGame.EInputMgrEableSource.FadeWindow)
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
  self.uiBinder.img_main:SetColor(color)
  if fadeArgs and fadeArgs.IsOpen then
    self:onFadeIn(fadeArgs)
  else
    self:onFadeOut(fadeArgs)
  end
end

function Fade_windowView:bindEvents()
end

return Fade_windowView
