local UI = Z.UI
local super = require("ui.ui_view_base")
local Story_fade_message_windowView = class("Story_fade_message_windowView", super)

function Story_fade_message_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "story_fade_message_window")
  self.storyMessageVm_ = Z.VMMgr.GetVM("story_message")
  self.storyMessageTableMgr_ = Z.TableMgr.GetTable("StoryMessageTableMgr")
end

function Story_fade_message_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.InputMgr:EnableInput(false, Panda.ZGame.EInputMgrEableSource.StoryMessageWindow)
end

function Story_fade_message_windowView:OnDeActive()
  self.uiBinder.canvas_group_main.alpha = 0
  Z.InputMgr:EnableInput(true, Panda.ZGame.EInputMgrEableSource.StoryMessageWindow)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.LuaBridge.SetBackgroundLoadingPriority(false)
  Z.EPFlowBridge.OnLuaFunctionCallback(Z.ConstValue.Eplow.StoryMeesageViewClose)
end

function Story_fade_message_windowView:OnRefresh()
  self.curConfigId_ = self.viewData
  if self.curConfigId_ == nil then
    logError("Story_fade_message_windowView:OnRefresh curConfigId_ is nil")
    return
  end
  local tableRow = Z.TableMgr.GetTable("StoryMessageTableMgr").GetRow(self.curConfigId_)
  if tableRow == nil then
    self:onFadeOutEnd()
    return
  end
  self:refreshUI(tableRow)
end

function Story_fade_message_windowView:refreshUI(messageRow)
  local placeholderParam = Z.Placeholder.SetNpcPlaceholder()
  Z.Placeholder.SetPlayerSelfPronoun(placeholderParam)
  local content = Z.Placeholder.Placeholder(messageRow.Content, placeholderParam)
  self.contentText_ = content
  self.fadeInTime_ = messageRow.FadeInTime
  self.durationTime_ = messageRow.DurationTime
  self.uiBinder.lab_content:SetText("")
  if self.timeOutTimer then
    self.timerMgr:StopTimer(self.timeOutTimer)
    self.timeOutTimer = nil
  end
  self:startFadeIn()
end

function Story_fade_message_windowView:startFadeIn()
  self.uiBinder.comp_tween_main:Pause()
  Z.LuaBridge.SetBackgroundLoadingPriority(true)
  self.uiBinder.canvas_group_main.alpha = 0
  local openAnimType = Z.DOTweenAnimType.Open
  if self.fadeInTime_ == 0 then
    self.uiBinder.comp_tween_main:Rewind(openAnimType)
    self.uiBinder.comp_tween_main:Complete(openAnimType)
    self:onFadeInEnd()
  else
    Z.CoroUtil.create_coro_xpcall(function()
      local coro = Z.CoroUtil.async_to_sync(self.uiBinder.comp_tween_main.CoroPlay)
      coro(self.uiBinder.comp_tween_main, openAnimType)
      self:onFadeInEnd()
    end, function(err)
      if err == ZUtil.ZCancelSource.CancelException then
        return
      end
      Z.LuaBridge.SetBackgroundLoadingPriority(false)
    end)()
  end
end

function Story_fade_message_windowView:onFadeInEnd()
  self.uiBinder.lab_content:SetText(self.contentText_)
  if self.durationTime_ > 0 then
    self.timeOutTimer = self.timerMgr:StartTimer(function()
      self.timeOutTimer = nil
      self:onFadeOut()
    end, self.durationTime_)
  end
end

function Story_fade_message_windowView:onFadeOut()
  if self.timeOutTimer then
    self.timerMgr:StopTimer(self.timeOutTimer)
    self.timeOutTimer = nil
  end
  self.uiBinder.comp_tween_main:Pause()
  self.uiBinder.lab_content:SetText("")
  Z.CoroUtil.create_coro_xpcall(function()
    local closeAnimType = Z.DOTweenAnimType.Close
    local coro = Z.CoroUtil.async_to_sync(self.uiBinder.comp_tween_main.CoroPlay)
    coro(self.uiBinder.comp_tween_main, closeAnimType)
    self:onFadeOutEnd()
  end)()
end

function Story_fade_message_windowView:onFadeOutEnd()
  Z.UIMgr:CloseView("story_fade_message_window")
end

return Story_fade_message_windowView
