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
  self.curLoadingType_ = nil
  self.loadingData_ = Z.DataMgr.Get("loading_data")
end

function UILoadingView:OnActive()
  Z.InputMgr:EnableInput(false, Panda.ZGame.EInputMgrEableSource.Loading)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:bindEvents()
  self:InitComp()
end

function UILoadingView:OnDeActive()
  self:unBindEvents()
  self:UnInitComp()
  self.curLoadingType_ = nil
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.InputMgr:EnableInput(true, Panda.ZGame.EInputMgrEableSource.Loading)
  self.ViewConfig.IsFullScreen = false
end

function UILoadingView:bindEvents()
end

function UILoadingView:unBindEvents()
end

function UILoadingView:OnRefresh()
  self:CheckLoadingType()
end

function UILoadingView:InitComp()
  if self.viewData == E.LoadingType.Progress then
    Z.AudioMgr:Play("Loading_On")
  end
  if self.viewData ~= E.LoadingType.NoEffect then
    if self.uiBinder.rimg_bg.texture == nil then
      self.uiBinder.rimg_bg:SetColor(Color.black)
      self.uiBinder.rimg_bg:SetImageWithCallback(self.loadingData_:GetRandomBg(), function()
        if not self.IsActive or not self.uiBinder then
          return
        end
        self.uiBinder.rimg_bg:SetColor(Color.white)
      end)
    else
      self.uiBinder.rimg_bg:SetColor(Color.white)
    end
    local title, content = self.loadingData_:GetRandomLabel()
    self.uiBinder.lab_title.text = title
    self.uiBinder.lab_content.text = content
    self.uiBinder.aspect_fitter_progress:SetFullRect()
    self.uiBinder.aspect_fitter_white:SetFullRect()
    self.uiBinder.aspect_fitter_black:SetFullRect()
  end
end

function UILoadingView:UnInitComp()
  if self.viewData == E.LoadingType.Progress then
    Z.AudioMgr:Play("Loading_Off")
  end
  self.uiBinder.rimg_bg:SetImage(self.loadingData_:GetRandomBg())
  self.uiBinder.anim_light:PlayLoop("Stop")
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

function UILoadingView:fadeInWhiteAnim(callback)
  self.uiBinder.canvas_group_white.alpha = 0
  self.uiBinder.dotween_white:DoCanvasGroup(1, 0.2, false, callback)
end

function UILoadingView:fadeInBlackAnim(callback)
  self.uiBinder.canvas_group_black.alpha = 0
  self.uiBinder.dotween_black:DoCanvasGroup(1, 0.2, false, callback)
end

return UILoadingView
