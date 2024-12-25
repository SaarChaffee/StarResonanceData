local super = require("ui.ui_view_base")
local UILoadingView = class("UILoadingView", super)
E.LoadingType = {
  Progress = 0,
  Black = 1,
  White = 2,
  NoEffect = 3
}

function UILoadingView:ctor()
  super.ctor(self, "loading_window")
  self.uiBinder = nil
  self.loadingVM_ = Z.VMMgr.GetVM("loading")
  self.loadingData_ = Z.DataMgr.Get("loading_data")
  self.curLoadingType_ = nil
end

function UILoadingView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:bindEvents()
  self:InitComp()
end

function UILoadingView:OnDeActive()
  self:unBindEvents()
  self:UnInitComp()
  self.curLoadingType_ = nil
  self.loadingData_:SetTargetProgress(0)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.ViewConfig.IsFullScreen = false
end

function UILoadingView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Loading.UpdateLoadingProgress, self.updateProgressAnim, self)
end

function UILoadingView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Loading.UpdateLoadingProgress, self.updateProgressAnim, self)
end

function UILoadingView:OnRefresh()
  self:CheckLoadingType()
end

function UILoadingView:InitComp()
  if self.viewData == E.LoadingType.Progress then
    Z.AudioMgr:Play("Loading_On")
  end
  self.uiBinder.img_fillmount_temp.fillAmount = 0
  self.uiBinder.rimg_list:SwitchTexture()
  self.uiBinder.aspect_fitter_progress:SetFullRect()
  self.uiBinder.aspect_fitter_white:SetFullRect()
  self.uiBinder.aspect_fitter_black:SetFullRect()
end

function UILoadingView:UnInitComp()
  if self.viewData == E.LoadingType.Progress then
    Z.AudioMgr:Play("Loading_Off")
  end
  self.uiBinder.rimg_list:LoadNextTexture()
  self.uiBinder.anim_light:PlayLoop("Stop")
  self.uiBinder.dotween_progress:ClearAll()
  self.uiBinder.dotween_white:ClearAll()
  self.uiBinder.dotween_black:ClearAll()
end

function UILoadingView:CheckLoadingType()
  local loadingType = E.LoadingType.Progress
  if self.viewData then
    loadingType = self.viewData
  else
    loadingType = E.LoadingType.Progress
  end
  if self.curLoadingType_ == nil then
    self.curLoadingType_ = loadingType
    self:RefreshLoadingByType()
  elseif self.curLoadingType_ == E.LoadingType.NoEffect or loadingType == E.LoadingType.Progress then
    self.curLoadingType_ = loadingType
    self:RefreshLoadingByType()
  end
end

function UILoadingView:RefreshLoadingByType()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_progress, self.curLoadingType_ == E.LoadingType.Progress)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_white, self.curLoadingType_ == E.LoadingType.White)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_black, self.curLoadingType_ == E.LoadingType.Black)
  if self.curLoadingType_ == E.LoadingType.Progress then
    self.uiBinder.anim_light:PlayLoop("loading")
    self:updateProgressAnim()
    self.ViewConfig.IsFullScreen = true
    Z.UIMgr:UpdateCameraState()
  elseif self.curLoadingType_ == E.LoadingType.White then
    self:fadeInWhiteAnim(function()
      self.ViewConfig.IsFullScreen = true
      Z.UIMgr:UpdateCameraState()
    end)
  elseif self.curLoadingType_ == E.LoadingType.Black then
    self:fadeInBlackAnim(function()
      self.ViewConfig.IsFullScreen = true
      Z.UIMgr:UpdateCameraState()
    end)
  end
end

function UILoadingView:checkProgressComplete(curProgress)
  if Mathf.Approximately(curProgress, 1) then
    self.uiBinder.dotween_progress:ClearAll()
    self.timerMgr:StartTimer(function()
      self.loadingVM_.CloseUILoading()
    end, 0.2)
    return
  end
end

function UILoadingView:updateProgressAnim()
  local curProgress = self.uiBinder.img_fillmount_temp.fillAmount
  local targetProgress = math.max(curProgress, self.loadingData_:GetTargetProgress())
  self:checkProgressComplete(curProgress)
  self.uiBinder.dotween_progress:DoFloat(curProgress, targetProgress, 1, function(value)
    self.uiBinder.img_fillmount_temp.fillAmount = value
    self:checkProgressComplete(value)
  end)
end

function UILoadingView:fadeInWhiteAnim(callback)
  self.uiBinder.canvas_group_white.alpha = 0
  self.uiBinder.dotween_white:DoCanvasGroup(1, 0.2, false, callback)
end

function UILoadingView:fadeInBlackAnim(callback)
  self.uiBinder.canvas_group_black.alpha = 0
  self.uiBinder.dotween_black:DoCanvasGroup(1, 0.2, false, callback)
end

return UILoadingView
