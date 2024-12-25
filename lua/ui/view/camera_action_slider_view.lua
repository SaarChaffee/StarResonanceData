local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_action_sliderView = class("Camera_action_sliderView", super)
local actionData = Z.DataMgr.Get("action_data")
local data = Z.DataMgr.Get("camerasys_data")

function Camera_action_sliderView:ctor(parent)
  self.panel = nil
  super.ctor(self, "camera_action_slider", "photograph/camera_action_slider", UI.ECacheLv.None)
  self.parent_ = parent
  self.expressionData_ = Z.DataMgr.Get("expression_data")
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
  self:UnBindEntityLuaAttrWatcher(self.playerStateWatcher)
  Z.EventMgr:Remove(Z.ConstValue.Camera.ExpressionPlaySlider, self.refrehSliderPlay, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.ActionReset, self.resetExpression, self)
end

function Camera_action_sliderView:updatePosEvent()
  self.expressionData_:SetCurPlayingId(-1)
  self:refrehSliderPlay(false, true)
end

function Camera_action_sliderView:updateStateEvent()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if 0 < stateId then
    self:updatePosEvent()
  end
end

function Camera_action_sliderView:BindLuaAttrWatchers()
  Z.EventMgr:Add(Z.ConstValue.Camera.ExpressionPlaySlider, self.refrehSliderPlay, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.ActionReset, self.resetExpression, self)
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerPosWatcher = Z.DIServiceMgr.PlayerAttrComponentWatcherService:OnAttrVirtualPosChanged(function()
      self:updatePosEvent()
    end)
    self.playerStateWatcher = self:BindEntityLuaAttrWatcher({
      Z.AttrCreator.ToIndex(Z.LocalAttr.EAttrState)
    }, Z.EntityMgr.PlayerEnt, self.updateStateEvent)
  end
end

function Camera_action_sliderView:refrehSliderPlay(isShow, isSetPersitTime)
  if isShow then
    self:openPlayExpression()
  else
    self:cancelPlayExpression(isSetPersitTime)
  end
end

function Camera_action_sliderView:updateSliderBtn()
  self.panel.btn_pause:SetVisible(self.isUpdateSlider_)
  self.panel.btn_play:SetVisible(not self.isUpdateSlider_)
end

function Camera_action_sliderView:addListenerActionSlider()
  self.panel.slider_action.Slider.value = 0
  self.panel.slider_action.Slider:AddListener(function()
    if not self.isUpdateSlider_ and self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
      self:freezeFrameCtrl(self.panel.slider_action.Slider.value)
    end
  end)
  self.panel.slider_action.EventTrigger.onDown:AddListener(function()
    if self.isUpdateSlider_ then
      self.isUpdateSlider_ = false
      self:freezeFrameCtrl(0)
      if self.updateTimer_ ~= nil then
        self.timerMgr:StopTimer(self.updateTimer_)
      end
      if self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
        self:freezeFrameCtrl(self.panel.slider_action.Slider.value)
      end
      self:updateSliderBtn()
    end
  end)
  self:updateSliderBtn()
  self.panel.btn_play.Btn:AddListener(function()
    if self.panel.slider_action.Slider.value > 0.98 then
      self:freezeFrameCtrl(-1)
      self.expressionVm_.ExpressionSinglePlay(self.viewData)
      self:openPlayExpression()
    else
      self:restorePlayExpression()
    end
    self:updateSliderBtn()
  end)
  self.panel.btn_pause.Btn:AddListener(function()
    self:stopPlayExpression()
    self:updateSliderBtn()
  end)
end

function Camera_action_sliderView:updateAnimSlider()
  self.isUpdateAnimSlider_ = true
  self.isUpdateSlider_ = true
  self.sumTime = actionData:GetDurationSumTime(self.expressionData_:GetCurPlayingId(), self.expressionData_:GetLogicExpressionType())
  local count = math.ceil(self.sumTime / 0.05)
  self.cumTime = self.panel.slider_action.Slider.value * self.sumTime
  self:updateSliderBtn()
  self.updateTimer_ = self.timerMgr:StartTimer(function()
    self.cumTime = self.cumTime + 0.05
    local pre = self.cumTime / self.sumTime
    self.panel.slider_action.Slider.value = pre
    if self.panel.slider_action.Slider.value > 0.98 and self.isUpdateAnimSlider_ then
      if self.isUpdateSlider_ then
        self.panel.slider_action.Slider.value = 1
      end
      self:stopPlayExpression()
      self:updateSliderBtn()
    end
  end, 0.05, count)
end

function Camera_action_sliderView:cancelPlayExpression(isSetPersitTime)
  self.isUpdateAnimSlider_ = false
  self.isUpdateSlider_ = false
  if self.updateTimer_ ~= nil then
    self.timerMgr:StopTimer(self.updateTimer_)
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
    self.expressionVm_.FreezeFrameCtrl(self.viewData, id, timePer)
  end
end

function Camera_action_sliderView:stopPlayExpression()
  self.isUpdateSlider_ = false
  if self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
    self:freezeFrameCtrl(self.panel.slider_action.Slider.value)
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
end

function Camera_action_sliderView:restorePlayExpression()
  self:freezeFrameCtrl(-1)
  self:updateAnimSlider()
end

function Camera_action_sliderView:openPlayExpression()
  if self.expressionData_:GetLogicExpressionType() == E.ExpressionType.Action then
    if self.updateTimer_ ~= nil then
      self.timerMgr:StopTimer(self.updateTimer_)
    end
    self.isUpdateSlider_ = true
    self.panel.slider_action.Slider.value = 0
    self:updateAnimSlider()
  end
end

return Camera_action_sliderView
