local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_action_sliderView = class("Camera_action_sliderView", super)
local actionData = Z.DataMgr.Get("action_data")
local data = Z.DataMgr.Get("camerasys_data")

function Camera_action_sliderView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_action_slider", "photograph/camera_action_slider", UI.ECacheLv.None)
  self.parent_ = parent
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
end

function Camera_action_sliderView:OnActive()
  self.isUpdateSlider_ = false
  self.cameraSysVm = Z.VMMgr.GetVM("camerasys")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self:addListenerActionSlider()
  self:BindLuaAttrWatchers()
end

function Camera_action_sliderView:OnDeActive()
  if self.updateTimer_ ~= nil then
    self.timerMgr:StopTimer(self.updateTimer_)
  end
  self:freezeFrameCtrl(-1)
  if self.playerPosWatcher ~= nil then
    self.playerPosWatcher:Dispose()
    self.playerPosWatcher = nil
  end
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Camera.ExpressionPlaySlider, self.refrehSliderPlay, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.ActionReset, self.resetExpression, self)
end

function Camera_action_sliderView:OnRefresh()
  self.memberData_ = self.cameraMemberData_:GetSelectMemberData()
end

function Camera_action_sliderView:updatePosEvent()
  self.expressionData_:SetCurPlayingId(-1)
  self:refrehSliderPlay(false, true)
end

function Camera_action_sliderView:updateStateEvent()
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if stateId ~= Z.PbEnum("EActorState", "ActorStateAction") then
    self:updatePosEvent()
  end
end

function Camera_action_sliderView:BindLuaAttrWatchers()
  Z.EventMgr:Add(Z.ConstValue.Camera.ExpressionPlaySlider, self.refrehSliderPlay, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.ActionReset, self.resetExpression, self)
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
      self:updateStateEvent()
    end)
  end
end

function Camera_action_sliderView:refrehSliderPlay(isShow, isSetPersitTime)
  if isShow then
    self:Show()
    self:openPlayExpression()
  else
    self:cancelPlayExpression(isSetPersitTime)
  end
end

function Camera_action_sliderView:updateSliderBtn()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_pause, self.isUpdateSlider_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, not self.isUpdateSlider_)
end

function Camera_action_sliderView:addListenerActionSlider()
  self.uiBinder.slider_action.value = 0
  self.uiBinder.slider_action:AddListener(function()
    if not self.isUpdateSlider_ and self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
      self:freezeFrameCtrl(self.uiBinder.slider_action.value)
    end
  end)
  self.uiBinder.action_event.onDown:AddListener(function()
    if self.isUpdateSlider_ then
      self.isUpdateSlider_ = false
      self:freezeFrameCtrl(0)
      if self.updateTimer_ ~= nil then
        self.timerMgr:StopTimer(self.updateTimer_)
      end
      if self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
        self:freezeFrameCtrl(self.uiBinder.slider_action.value)
      end
      self:updateSliderBtn()
    end
  end)
  self:updateSliderBtn()
  self.uiBinder.btn_play:AddListener(function()
    if self.memberData_ then
      self.memberData_.actionData.actionPauseTime = 0
    end
    if self.uiBinder.slider_action.value > 0.98 then
      self:freezeFrameCtrl(-1)
      self.expressionVm_.ExpressionSinglePlay(self.viewData)
      self:openPlayExpression()
    else
      self:restorePlayExpression()
    end
    self:updateSliderBtn()
  end)
  self.uiBinder.btn_pause:AddListener(function()
    self:stopPlayExpression()
    self:updateSliderBtn()
  end)
end

function Camera_action_sliderView:updateAnimSlider()
  self.isUpdateAnimSlider_ = true
  self.isUpdateSlider_ = true
  self.sumTime = actionData:GetDurationSumTime(self.expressionData_:GetCurPlayingId(), self.expressionData_:GetLogicExpressionType())
  local count = math.ceil(self.sumTime / 0.05)
  self.cumTime = self.uiBinder.slider_action.value * self.sumTime
  self:updateSliderBtn()
  local iterationsNum = count
  self.updateTimer_ = self.timerMgr:StartTimer(function()
    self.cumTime = self.cumTime + 0.05
    local pre = self.cumTime / self.sumTime
    self.uiBinder.slider_action.value = pre
    iterationsNum = iterationsNum - 1
    if self.uiBinder.slider_action.value > 0.98 and self.isUpdateAnimSlider_ then
      if self.isUpdateSlider_ then
        self.uiBinder.slider_action.value = 1
      end
      if iterationsNum <= 0 then
        self:openPlayExpression()
      end
    end
  end, 0.05, count)
end

function Camera_action_sliderView:cancelPlayExpression(isSetPersitTime)
  self.isUpdateAnimSlider_ = false
  self.isUpdateSlider_ = false
  if self.updateTimer_ ~= nil then
    self.timerMgr:StopTimer(self.updateTimer_)
  end
  if not self.memberData_ or self.memberData_.baseData.isSelf then
    self:Hide()
  end
  if isSetPersitTime then
    if self.viewData then
      Z.ZAnimActionPlayMgr:SetActionPersistTime(self.viewData.ZModel, -1)
      return
    end
    Z.ZAnimActionPlayMgr:SetActionPersistTime(-1)
  end
end

function Camera_action_sliderView:freezeFrameCtrl(timePer)
  local id = self.expressionData_:GetCurPlayingId()
  if self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action and id ~= nil and 0 < id then
    if self.memberData_ ~= nil and not self.memberData_.baseData.isSelf and 0 <= timePer then
      local pauseTime = self.expressionVm_.GetActionPerState(id, timePer)
      self.memberData_.actionData.actionPauseTime = pauseTime
    end
    self.expressionVm_.FreezeFrameCtrl(self.viewData, id, timePer)
  end
end

function Camera_action_sliderView:stopPlayExpression()
  self.isUpdateSlider_ = false
  if self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
    self:freezeFrameCtrl(self.uiBinder.slider_action.value)
  end
  if self.updateTimer_ ~= nil then
    self.timerMgr:StopTimer(self.updateTimer_)
  end
end

function Camera_action_sliderView:resetExpression(actionViewData)
  self.isUpdateSlider_ = false
  if self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
    self:freezeFrameCtrl(1)
  end
  if self.updateTimer_ ~= nil then
    self.timerMgr:StopTimer(self.updateTimer_)
  end
  if actionViewData and actionViewData.ZModel then
    Z.ZAnimActionPlayMgr:ResetAction(actionViewData.ZModel)
  else
    Z.ZAnimActionPlayMgr:ResetAction()
  end
  self:Hide()
end

function Camera_action_sliderView:restorePlayExpression()
  self:freezeFrameCtrl(-1)
  self:updateAnimSlider()
end

function Camera_action_sliderView:openPlayExpression()
  local logicExpressionType = self.expressionData_:GetLogicExpressionType()
  if logicExpressionType == E.ExpressionType.Action then
    if self.updateTimer_ ~= nil then
      self.timerMgr:StopTimer(self.updateTimer_)
    end
    self.isUpdateSlider_ = true
    local curPlayId = self.expressionData_:GetCurPlayingId()
    self.uiBinder.slider_action.value = 0
    if self.memberData_ and 0 < curPlayId and 0 < self.memberData_.actionData.actionPauseTime then
      local sumTime = actionData:GetDurationSumTime(curPlayId, logicExpressionType)
      self.uiBinder.slider_action.value = self.memberData_.actionData.actionPauseTime / sumTime
      self.isUpdateSlider_ = false
      return
    end
    self:updateAnimSlider()
  end
end

return Camera_action_sliderView
