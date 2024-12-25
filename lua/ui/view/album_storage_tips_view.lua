local super = require("ui.ui_view_base")
local Album_storage_tipsView = class("Album_storage_tipsView", super)
local albumMainData = Z.DataMgr.Get("album_main_data")

function Album_storage_tipsView:ctor()
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "album_storage_tips")
end

function Album_storage_tipsView:OnActive()
  self:BindEvents()
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.overTimer_ = nil
  self:initComp()
end

function Album_storage_tipsView:initComp()
  self.slider_storage = self.uiBinder.slider_storage
  self.lab_progress = self.uiBinder.lab_progress
  self.group_storage = self.uiBinder.group_storage
end

function Album_storage_tipsView:OnDeActive()
end

function Album_storage_tipsView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.UpLoadSliderValue, self.AlbumUpLoadSliderValue, self)
end

function Album_storage_tipsView:AlbumUpLoadSliderValue()
  local currentNum = albumMainData.AlbumUploadCountTable.currentNum
  local targetNum = albumMainData.AlbumUploadCountTable.targetNum
  local errorNum = albumMainData.AlbumUploadCountTable.errorNum
  local preValue = currentNum / targetNum
  self.slider_storage.value = preValue
  self.lab_progress.text = math.ceil(preValue * 100) .. "%"
  self:updateTimer()
  if targetNum == currentNum + errorNum then
    if errorNum == 0 then
      Z.EventMgr:Dispatch(Z.ConstValue.Album.RefUpLoadDelSucTempPhoto)
      Z.UIMgr:CloseView("album_photo_show")
    end
    self.albumMainVM_.AlbumUpLoadEnd()
  end
end

function Album_storage_tipsView:refreshUpLoadState()
  if albumMainData.UpLoadStateType == E.CameraUpLoadStateType.UpLoading then
    self.uiBinder.Ref:SetVisible(self.group_storage, true)
    self:updateTimer()
  elseif albumMainData.UpLoadStateType == E.CameraUpLoadStateType.UpLoadSuccess then
    self.uiBinder.Ref:SetVisible(self.group_storage, false)
    self:endTimer()
  elseif albumMainData.UpLoadStateType == E.CameraUpLoadStateType.UpLoadFail or albumMainData.UpLoadStateType == E.CameraUpLoadStateType.UpLoadOverTime then
    self.uiBinder.Ref:SetVisible(self.group_storage, false)
    self:endTimer()
  end
end

function Album_storage_tipsView:updateTimer()
  if self.overTimer_ then
    self.timerMgr:StopTimer(self.overTimer_)
  end
  self.overTimer_ = self.timerMgr:StartTimer(function()
    self.albumMainVM_.AlbumUpLoadOverTimeEnd()
  end, 8)
end

function Album_storage_tipsView:endTimer()
  self.timerMgr:StopTimer(self.overTimer_)
  self.overTimer_ = nil
end

function Album_storage_tipsView:OnRefresh()
  if not self.viewData or not next(self.viewData) then
    self.slider_storage.value = 0
    self.lab_progress.text = "0%"
    albumMainData.UpLoadStateType = E.CameraUpLoadStateType.UpLoading
  end
  self:refreshUpLoadState()
end

return Album_storage_tipsView
