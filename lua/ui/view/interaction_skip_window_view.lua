local UI = Z.UI
local super = require("ui.ui_view_base")
local Interaction_skip_windowView = class("Interaction_skip_windowView", super)
local ForceSkipTime = 1.5

function Interaction_skip_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "interaction_skip_window")
  
  function self.onPressF_()
    self.skipProgress_.fillAmount = 0
    self.startPressTime_ = Z.ServerTime:GetServerTime() / 1000
  end
  
  function self.whenPressF_()
    if not self.startPressTime_ or self.startPressTime_ <= 0 then
      return
    end
    local currentTime = Z.ServerTime:GetServerTime() / 1000
    local lastTime = currentTime - self.startPressTime_
    self.skipProgress_.fillAmount = lastTime / ForceSkipTime
    if lastTime >= ForceSkipTime then
      self:onClickSkip()
    end
  end
  
  function self.onReleseF_()
    self.startPressTime_ = 0
    self.skipProgress_.fillAmount = 0
  end
  
  function self.excKeyPress_()
    self:onClickSkip()
  end
end

function Interaction_skip_windowView:OnActive()
  self:initComp()
  self:bindEvent()
end

function Interaction_skip_windowView:OnDeActive()
end

function Interaction_skip_windowView:OnRefresh()
  self:refreshPromptText()
end

function Interaction_skip_windowView:initComp()
  self.btnBinder_ = self.uiBinder.btn_binder
  self.nodeautoPlay_ = self.btnBinder_.node_auto_play
  self.nodeSkip_ = self.btnBinder_.node_skip
  self.skipBtn_ = self.btnBinder_.skip_btn
  self.skipProgress_ = self.btnBinder_.skip_progress
  self.lab_prompt_ = self.btnBinder_.lab_prompt
  self.btnBinder_.Ref:SetVisible(self.nodeautoPlay_, false)
  self.btnBinder_.Ref:SetVisible(self.nodeSkip_, true)
  if Z.IsPCUI then
    self.btnBinder_.Ref:SetVisible(self.lab_prompt_, true)
  else
    self.btnBinder_.Ref:SetVisible(self.lab_prompt_, false)
  end
  local scale = Z.IsPCUI and 0.75 or 1
  self.nodeSkip_:SetScale(scale, scale)
  self.skipProgress_.fillAmount = 0
end

function Interaction_skip_windowView:bindEvent()
  self.skipBtn_:AddListener(function()
    self:onClickSkip()
  end)
end

function Interaction_skip_windowView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.Interact then
    if inputActionEventData.EventType == Z.InputActionEventType.ButtonJustPressed then
      self.onPressF_()
    end
    if inputActionEventData.EventType == Z.InputActionEventType.ButtonPressed then
      self.whenPressF_()
    end
    if inputActionEventData.EventType == Z.InputActionEventType.ButtonJustReleased then
      self.onReleseF_()
    end
  end
  if inputActionEventData.ActionId == Z.InputActionIds.ExitUI and inputActionEventData.EventType == Z.InputActionEventType.ButtonJustPressed then
    self.excKeyPress_()
  end
end

function Interaction_skip_windowView:refreshPromptText()
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(1)[1]
  if keyCodeDesc then
    self.lab_prompt_.text = Lang("Long_Press_Skip_Prompt", {val = keyCodeDesc})
    return
  end
  self.lab_prompt_.text = Lang("Long_Press_Skip_PromptDefault")
end

function Interaction_skip_windowView:onClickSkip()
  logGreen("onClickSkip")
  Z.UIMgr:CloseView("interaction_skip_window")
  Z.InteractionMgr:AbortInteractionByUI()
end

return Interaction_skip_windowView
