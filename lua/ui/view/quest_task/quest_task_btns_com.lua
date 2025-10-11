local QuestTaskBtnsCom = class("QuestTaskBtnCom")
local StartPressTime = 0.2
local ForceSkipTime = 1.5
local ShowFirstDuration = 5
local ShowDuration = 3
local ignoreActionIds = {
  Z.InputActionIds.Interact,
  Z.InputActionIds.ExitUI,
  Z.InputActionIds.Zoom
}
local SkipBtnState = {
  Hide = 1,
  Show = 2,
  Pressing = 4
}
local AutoPlayState = {
  Hide = 1,
  Show = 2,
  Playing = 4
}

function QuestTaskBtnsCom:ctor()
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.talkOptionVM_ = Z.VMMgr.GetVM("talk_option")
  
  function self.onPressF_()
    if not self:getIsAllowSkip() then
      return
    end
    self.uiBinder_.skip_progress.fillAmount = 0
    self.startPressTime_ = Z.ServerTime:GetServerTime() / 1000
    self:refreshSkipBtnUIByState(SkipBtnState.Show, false)
    self:refreshAutoBtnUIByState(AutoPlayState.Show, false)
  end
  
  function self.whenPressF_()
    if not self:getIsAllowSkip() then
      if self.skipBtnState_ == SkipBtnState.Pressing or self.startPressTime_ > 0 then
        self.startPressTime_ = 0
        self.uiBinder_.skip_progress.fillAmount = 0
        self:refreshSkipBtnUIByState(SkipBtnState.Show, true)
      end
      return
    end
    if not self.startPressTime_ or self.startPressTime_ <= 0 then
      return
    end
    local currentTime = Z.ServerTime:GetServerTime() / 1000
    local lastTime = currentTime - self.startPressTime_
    if lastTime > StartPressTime then
      self:refreshSkipBtnUIByState(SkipBtnState.Pressing, true)
      local fillAmount = (currentTime - self.startPressTime_) / ForceSkipTime
      self.uiBinder_.skip_progress.fillAmount = fillAmount
    end
    if lastTime >= ForceSkipTime then
      self:doSkip()
    end
  end
  
  function self.onReleseF_()
    if not self:getIsAllowSkip() or not self.init_ then
      return
    end
    self.startPressTime_ = 0
    self:refreshSkipBtnUIByState(SkipBtnState.Show, true)
    self:refreshAutoBtnUIByState(AutoPlayState.Show, false)
  end
  
  function self.anyActionPress_(inputActionData)
    if self.source_ ~= E.QuestTaskBtnsSource.Cutscene then
      return
    end
    for _, value in ipairs(ignoreActionIds) do
      if value == inputActionData.ActionId then
        return
      end
    end
    self:refreshSkipBtnUIByState(SkipBtnState.Show, false)
    self:refreshAutoBtnUIByState(AutoPlayState.Show, false)
  end
  
  function self.excKeyPress_(inputActionData)
    if self:canResponeExitKey(inputActionData) then
      self:onClickSkip()
    end
  end
end

function QuestTaskBtnsCom:Init(source, uiBinder, viewConfigKey)
  self.init_ = true
  self.source_ = source
  self.viewConfigKey_ = viewConfigKey
  self.uiBinder_ = uiBinder
  self.timerMgr_ = Z.TimerMgr.new()
  self.startPressTime_ = 0
  self:setScale()
  self:bindEvent()
  self.skipBtnState_ = 1
  self.autoPlayState_ = 1
  self.isShowSkipDialog = false
end

function QuestTaskBtnsCom:UnInit()
  self:unRegisterInput()
  self:refreshSkipBtnUIByState(SkipBtnState.Hide, true)
  self:refreshAutoBtnUIByState(AutoPlayState.Hide, true)
  Z.EventMgr:RemoveObjAll(self)
  self.timerMgr_:Clear()
  self.timerMgr_ = nil
  self.init_ = false
end

function QuestTaskBtnsCom:Refresh(isInFlow, cutsId, skipType)
  self.isInFlow_ = isInFlow
  self.cutsId_ = cutsId
  self.skipType_ = skipType
  self:refreshSkipBtnUIByState(SkipBtnState.Show, true, ShowFirstDuration)
  self:refreshAutoBtnUIByState(AutoPlayState.Show, true)
  self:unRegisterInput()
  self:registerInput()
  self:refreshPromptText()
  self.autoPlay_ = self.settingVM_.Get(E.ClientSettingID.AutoPlay)
  self:autoPlay(self.autoPlay_)
end

function QuestTaskBtnsCom:refreshBtns()
  self:refreshSkipBtnUIByState(self.skipBtnState_, true)
  self:refreshAutoBtnUIByState(self.autoPlayState_, true)
end

function QuestTaskBtnsCom:setScale()
  local scale = Z.IsPCUI and 0.75 or 1
  self.uiBinder_.node_skip:SetScale(scale, scale)
  self.uiBinder_.node_auto_play:SetScale(scale, scale)
end

function QuestTaskBtnsCom:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.IsAllowSkipTalkChange, self.refreshBtns, self)
  self.uiBinder_.skip_btn:AddListener(function()
    self:onClickSkip()
  end)
  self.uiBinder_.auto_play_btn:AddListener(function()
    self:autoPlay(not self.autoPlay_)
  end)
end

function QuestTaskBtnsCom:registerInput()
  if not self.init_ then
    return
  end
  Z.InputLuaBridge:AddInputEventDelegateWithActionId(self.onPressF_, Z.InputActionEventType.ButtonJustPressed, Z.InputActionIds.Interact)
  Z.InputLuaBridge:AddInputEventDelegateWithActionId(self.whenPressF_, Z.InputActionEventType.ButtonPressed, Z.InputActionIds.Interact)
  Z.InputLuaBridge:AddInputEventDelegateWithActionId(self.onReleseF_, Z.InputActionEventType.ButtonJustReleased, Z.InputActionIds.Interact)
  Z.InputLuaBridge:AddInputEventDelegateWithoutActionId(self.anyActionPress_, Z.InputActionEventType.ButtonJustPressed)
  Z.InputLuaBridge:AddInputEventDelegateWithActionId(self.excKeyPress_, Z.InputActionEventType.ButtonJustPressed, Z.InputActionIds.ExitUI)
end

function QuestTaskBtnsCom:unRegisterInput()
  if not self.init_ then
    return
  end
  Z.InputLuaBridge:RemoveInputEventDelegateWithActionId(self.onPressF_, Z.InputActionEventType.ButtonJustPressed, Z.InputActionIds.Interact)
  Z.InputLuaBridge:RemoveInputEventDelegateWithActionId(self.whenPressF_, Z.InputActionEventType.ButtonPressed, Z.InputActionIds.Interact)
  Z.InputLuaBridge:RemoveInputEventDelegateWithActionId(self.onReleseF_, Z.InputActionEventType.ButtonJustReleased, Z.InputActionIds.Interact)
  Z.InputLuaBridge:RemoveInputEventDelegateWithoutActionId(self.anyActionPress_, Z.InputActionEventType.ButtonJustPressed)
  Z.InputLuaBridge:RemoveInputEventDelegateWithActionId(self.excKeyPress_, Z.InputActionEventType.ButtonJustPressed, Z.InputActionIds.ExitUI)
end

function QuestTaskBtnsCom:refreshPromptText()
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(1)[1]
  if keyCodeDesc then
    self.uiBinder_.lab_prompt.text = Lang("Long_Press_Skip_Prompt", {val = keyCodeDesc})
    return
  end
  self.uiBinder_.lab_prompt.text = Lang("Long_Press_Skip_PromptDefault")
end

function QuestTaskBtnsCom:onClickSkip()
  if self:getIsAllowSkip() then
    if self:isShowDialog() then
      if not self.isShowSkipDialog then
        self:unRegisterInput()
        local onConfirm = function()
          self:doSkip()
          self.isShowSkipDialog = false
        end
        local onCancel = function()
          self:registerInput()
          self.isShowSkipDialog = false
        end
        self.isShowSkipDialog = true
        Z.DialogViewDataMgr:OpenNormalDialog(Lang("TalkSkipConfirm"), onConfirm, onCancel)
      end
    else
      self:doSkip()
    end
  else
    Z.TipsVM.ShowTips(4950)
  end
end

function QuestTaskBtnsCom:isShowDialog()
  if self.source_ == E.QuestTaskBtnsSource.Cutscene then
    local cutRow = Z.TableMgr.GetTable("CutsceneTableMgr").GetRow(self.cutsId_)
    if cutRow and cutRow.ValidateSkip then
      return true
    end
    return false
  end
end

function QuestTaskBtnsCom:doSkip()
  if not self.init_ or not self:getIsAllowSkip() then
    return
  end
  if self.source_ == E.QuestTaskBtnsSource.Cutscene then
    if self.isInFlow_ then
      self.talkOptionVM_.CloseOptionView()
      Z.EPFlowBridge.SkipAllFlow()
    else
      Z.LuaBridge.SkipCutScene()
    end
  else
    self.talkOptionVM_.CloseOptionView()
    Z.UIMgr:FadeOut()
    Z.EventMgr:Dispatch(Z.ConstValue.Quest.OnSkipTalk)
    Z.EPFlowBridge.SkipAllFlow()
  end
end

function QuestTaskBtnsCom:autoPlay(autoPlay)
  if not self:getIsAllowAutoPlay() then
    return
  end
  local isChange = self.autoPlay_ ~= autoPlay
  self.autoPlay_ = autoPlay
  if self.autoPlay_ then
    self:refreshAutoBtnUIByState(AutoPlayState.Playing, true)
  elseif self.autoPlayState_ == AutoPlayState.Hide then
    self:refreshAutoBtnUIByState(AutoPlayState.Hide, true)
  else
    self:refreshAutoBtnUIByState(AutoPlayState.Show, true)
  end
  if isChange then
    self.settingVM_.Set(E.ClientSettingID.AutoPlay, self.autoPlay_)
    Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.OnAutoPlayChange)
  end
end

function QuestTaskBtnsCom:getIsAllowSkip()
  if self.source_ == E.QuestTaskBtnsSource.Cutscene and not self.isInFlow_ then
    if not self.skipType_ == nil then
      local cutRow = Z.TableMgr.GetTable("CutsceneTableMgr").GetRow(self.cutsId_)
      if cutRow and cutRow.CanSkip == 0 then
        self.skipType_ = cutRow.CanSkip
      end
    end
    return self.skipType_ == 0
  end
  local talkData = Z.DataMgr.Get("talk_data")
  return talkData:GetNodeIsAllowSkip()
end

function QuestTaskBtnsCom:getIsAllowAutoPlay()
  if self.source_ == E.QuestTaskBtnsSource.Cutscene then
    return false
  end
  return true
end

function QuestTaskBtnsCom:refreshSkipBtnUIByState(skipState, isForce, duration)
  if not self.init_ then
    return
  end
  if self.uiBinder_ == nil or self.uiBinder_.Ref == nil then
    return
  end
  if self.skipBtnState_ == SkipBtnState.Pressing and not isForce then
    return
  end
  self.skipBtnState_ = skipState
  Z.UIMgr:RemoveShowMouseView(self.viewConfigKey_)
  if self.skipBtnState_ ~= SkipBtnState.Hide then
    Z.UIMgr:AddShowMouseView(self.viewConfigKey_)
  end
  self:setVisibleComp(self.uiBinder_.skip_progress, false)
  self:setVisibleComp(self.uiBinder_.node_skip, false)
  self:setVisibleComp(self.uiBinder_.rect_prompt, false)
  if self.skipBtnState_ == SkipBtnState.Hide then
    return
  end
  if Z.IsPCUI then
    self:setVisibleComp(self.uiBinder_.rect_prompt, true)
  end
  self:setVisibleComp(self.uiBinder_.node_skip, true)
  if self.skipBtnState_ == SkipBtnState.Show then
    if self:getIsAllowSkip() then
      self.uiBinder_.Ref:GetUIComp(self.uiBinder_.node_skip).CanvasGroup.alpha = 1
    else
      self.uiBinder_.Ref:GetUIComp(self.uiBinder_.node_skip).CanvasGroup.alpha = 0.3
      self:setVisibleComp(self.uiBinder_.rect_prompt, false)
    end
  end
  if self.skipBtnState_ == SkipBtnState.Pressing then
    self:setVisibleComp(self.uiBinder_.skip_progress, true)
  end
  self:autoHideUI(duration)
end

function QuestTaskBtnsCom:refreshAutoBtnUIByState(autoPlayState, isForce)
  if self.uiBinder_ == nil or self.uiBinder_.Ref == nil then
    return
  end
  if self.autoPlayState_ == AutoPlayState.Playing and not isForce then
    return
  end
  self.autoPlayState_ = autoPlayState
  self:setVisibleComp(self.uiBinder_.node_auto_play, false)
  self:setVisibleComp(self.uiBinder_.auto_play_anim, false)
  self:setVisibleComp(self.uiBinder_.node_auto_play_on, false)
  self:setVisibleComp(self.uiBinder_.node_auto_play_off, false)
  self.uiBinder_.auto_play_anim:Stop()
  if self.autoPlayState_ == AutoPlayState.Hide then
    return
  end
  if not self:getIsAllowAutoPlay() then
    return
  end
  self:setVisibleComp(self.uiBinder_.node_auto_play, true)
  self.uiBinder_.auto_play_btn.interactable = true
  if self.autoPlayState_ == AutoPlayState.Show then
    self:setVisibleComp(self.uiBinder_.node_auto_play_off, true)
  end
  if self.autoPlayState_ == AutoPlayState.Playing then
    self:setVisibleComp(self.uiBinder_.node_auto_play_on, true)
    self:setVisibleComp(self.uiBinder_.auto_play_anim, true)
    self.uiBinder_.auto_play_anim:PlayLoop("amin_talk_btns_node_auto_play_img_bar")
  end
end

function QuestTaskBtnsCom:autoHideUI(duration)
  if self.source_ == E.QuestTaskBtnsSource.Cutscene and (self.skipBtnState_ == SkipBtnState.Pressing or self.skipBtnState_ == SkipBtnState.Show) then
    self.timerMgr_:Clear()
    duration = duration or ShowDuration
    self.timerMgr_:StartTimer(function()
      self:refreshAutoBtnUIByState(AutoPlayState.Hide, false)
      self:refreshSkipBtnUIByState(SkipBtnState.Hide, false)
    end, duration, 1)
  end
end

function QuestTaskBtnsCom:setVisibleComp(comp, visible)
  if comp == nil or self.uiBinder_ == nil or self.uiBinder_.Ref == nil then
    return
  end
  self.uiBinder_.Ref:SetVisible(comp, visible)
end

function QuestTaskBtnsCom:canResponeExitKey()
  local letterWindow = Z.UIMgr:GetView("quest_letter_window")
  if letterWindow ~= nil and letterWindow.IsActive then
    return false
  end
  if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
    return false
  end
  return true
end

return QuestTaskBtnsCom
