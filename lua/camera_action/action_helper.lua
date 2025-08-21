local ActionHelper = class("ActionHelper")

function ActionHelper:ctor(parent)
  self.parentView_ = parent
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraSysVM_ = Z.VMMgr.GetVM("camerasys")
  self.expressionVM_ = Z.VMMgr.GetVM("expression")
  self.actionData_ = Z.DataMgr.Get("action_data")
end

function ActionHelper:Init(memberData)
  if memberData.uiBinder == nil then
    self:UnInit()
    return
  end
  self.memberData_ = memberData.memberListData
  self.uiBinder_ = memberData.uiBinder
  self.isUpdateSlider_ = false
  self.timerMgr_ = Z.TimerMgr.new()
  self.isPause_ = false
  self:initBtn()
end

function ActionHelper:initBtn()
  if not self.parentView_ then
    return
  end
  self.parentView_:AddClick(self.uiBinder_.btn_medium_play, function()
    if self.memberData_ then
      self.memberData_.actionData.actionPauseTime = 0
    end
    if self.uiBinder_.slider_action.value > 0.98 then
      self:freezeFrameCtrl(-1)
      local modelData
      if not self.memberData_.baseData.isSelf then
        local model = self:getCurModel()
        modelData = {ZModel = model}
      end
      self.expressionVM_.ExpressionSinglePlay(modelData)
      self:openPlayExpression()
    else
      self:restorePlayExpression()
    end
    self:updateSliderBtn()
  end)
  self.parentView_:AddClick(self.uiBinder_.btn_medium_pause, function()
    self:stopPlayExpression()
    self:updateSliderBtn()
  end)
  self.uiBinder_.slider_action:RemoveAllListeners()
  self.uiBinder_.slider_action.value = 0
  self.uiBinder_.slider_action:AddListener(function(value)
    if not self.isUpdateSlider_ then
      self:freezeFrameCtrl(value)
    end
  end)
  self.uiBinder_.action_event.onDown:RemoveAllListeners()
  self.uiBinder_.action_event.onDown:AddListener(function()
    if self.isUpdateSlider_ then
      self.isUpdateSlider_ = false
      self:freezeFrameCtrl(0)
      if self.updateTimer_ ~= nil then
        self.timerMgr_:StopTimer(self.updateTimer_)
      end
      self:freezeFrameCtrl(self.uiBinder_.slider_action.value)
      self:updateSliderBtn()
    end
  end)
end

function ActionHelper:Refresh()
  self:openPlayExpression()
end

function ActionHelper:UnInit()
  self.uiBinder_ = nil
  if self.timerMgr_ then
    self.timerMgr_:Clear()
    self.timerMgr_ = nil
  end
  if self.memberData_ then
    self:freezeFrameCtrl(-1)
  end
end

function ActionHelper:RefreshSliderPlay(isShow, isSetPersitTime)
  if isShow then
    self:openPlayExpression()
  else
    self.expressionData_:SetCurPlayingId(-1)
    self:cancelPlayExpression(isSetPersitTime)
  end
end

function ActionHelper:updateSliderBtn()
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.btn_medium_pause, self.isUpdateSlider_)
  self.uiBinder_.Ref:SetVisible(self.uiBinder_.btn_medium_play, not self.isUpdateSlider_)
end

function ActionHelper:updateAnimSlider()
  self.isUpdateAnimSlider_ = true
  self.isUpdateSlider_ = true
  local curPlayId = 0
  if self.memberData_.baseData.isSelf then
    curPlayId = self.expressionData_:GetCurPlayingId()
  else
    curPlayId = self.memberData_.actionData.actionId
  end
  self.sumTime = self.actionData_:GetDurationSumTime(curPlayId, self.expressionData_:GetLogicExpressionType())
  local count = math.ceil(self.sumTime / 0.05)
  self.cumTime = self.uiBinder_.slider_action.value * self.sumTime
  self:updateSliderBtn()
  local iterationsNum = count
  self.updateTimer_ = self.timerMgr_:StartTimer(function()
    self.cumTime = self.cumTime + 0.05
    local pre = self.cumTime / self.sumTime
    self.uiBinder_.slider_action.value = pre
    iterationsNum = iterationsNum - 1
    if self.uiBinder_.slider_action.value > 0.98 and self.isUpdateAnimSlider_ then
      if self.isUpdateSlider_ then
        self.uiBinder_.slider_action.value = 1
      end
      if iterationsNum <= 0 then
        self:openPlayExpression()
      end
    end
  end, 0.05, count)
end

function ActionHelper:cancelPlayExpression(isSetPersitTime)
  self.isUpdateAnimSlider_ = false
  self.isUpdateSlider_ = false
  if self.updateTimer_ ~= nil then
    self.timerMgr_:StopTimer(self.updateTimer_)
  end
  self.uiBinder_.slider_action.value = 0
  if isSetPersitTime then
    if not self.memberData_.baseData.isSelf then
      Z.ZAnimActionPlayMgr:SetActionPersistTime(self:getCurModel(), -1)
      return
    end
    Z.ZAnimActionPlayMgr:SetActionPersistTime(-1)
  end
end

function ActionHelper:freezeFrameCtrl(timePer)
  local id = self.expressionData_:GetCurPlayingId()
  if not self.memberData_.baseData.isSelf then
    id = self.memberData_.actionData.actionId
  end
  if id ~= nil and 0 < id then
    if not self.memberData_.baseData.isSelf and 0 <= timePer then
      local pauseTime = self.expressionVM_.GetActionPerState(id, timePer)
      self.memberData_.actionData.actionPauseTime = pauseTime
    end
    local modelData
    if not self.memberData_.baseData.isSelf or self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
      local model = self:getCurModel()
      modelData = {ZModel = model}
    end
    self.expressionVM_.FreezeFrameCtrl(modelData, id, timePer)
  end
end

function ActionHelper:stopPlayExpression()
  self.isUpdateSlider_ = false
  self:freezeFrameCtrl(self.uiBinder_.slider_action.value)
  if self.updateTimer_ ~= nil then
    self.timerMgr_:StopTimer(self.updateTimer_)
  end
end

function ActionHelper:ResetExpression()
  self.isUpdateSlider_ = false
  self:freezeFrameCtrl(1)
  if self.updateTimer_ ~= nil then
    self.timerMgr_:StopTimer(self.updateTimer_)
  end
  if self.memberData_.baseData.isSelf and self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto then
    Z.ZAnimActionPlayMgr:ResetAction()
  else
    Z.ZAnimActionPlayMgr:ResetAction(self:getCurModel())
  end
end

function ActionHelper:restorePlayExpression()
  self:freezeFrameCtrl(-1)
  self:updateAnimSlider()
end

function ActionHelper:openPlayExpression()
  local curPlayId = 0
  if self.memberData_.baseData.isSelf then
    curPlayId = self.expressionData_:GetCurPlayingId()
  elseif self.memberData_.baseData.isActionState then
    curPlayId = self.memberData_.actionData.actionId
  else
    return
  end
  if self.updateTimer_ ~= nil then
    self.timerMgr_:StopTimer(self.updateTimer_)
  end
  self.isUpdateSlider_ = true
  self.uiBinder_.slider_action.value = 0
  if 0 < curPlayId and 0 < self.memberData_.actionData.actionPauseTime then
    local sumTime = self.actionData_:GetDurationSumTime(curPlayId, E.ExpressionType.Action)
    self.uiBinder_.slider_action.value = self.memberData_.actionData.actionPauseTime / sumTime
    self.isUpdateSlider_ = false
    return
  end
  self:updateAnimSlider()
end

function ActionHelper:getCurModel()
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return self.cameraData_:GetUnionModel()
  end
  return self.memberData_.baseData.model
end

return ActionHelper
