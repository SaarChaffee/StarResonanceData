local UI = Z.UI
local super = require("ui.ui_subview_base")
local Album_container_temporaryView = class("Album_container_temporaryView", super)

function Album_container_temporaryView:ctor(parent)
  self.panel = nil
  self.uiBinder = nil
  super.ctor(self, "album_container_temporary", "photograph/album_container_temporary_sub", UI.ECacheLv.None, parent)
end

function Album_container_temporaryView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:startAnimatedShow()
  self:initParam()
  self:initBtnClick()
  self:BindEvents()
  self.uiBinder.total_num_lab.text = "/" .. self.albumMainData_.TemporaryPhotoMaxNum
end

function Album_container_temporaryView:initParam()
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.camerasysTabScrollRect_ = require("ui/component/loopscrollrect").new(self.uiBinder.photo_loopScroll, self, require("ui.component.album.album_photo_item"))
  self.OpenAlbumViewType = E.AlbumType.Temporary
end

function Album_container_temporaryView:initBtnClick()
  self:AddClick(self.uiBinder.multiple_btn, function()
    self:toggleMultipleState(true, E.AlbumSelectType.Select)
  end)
  self:AddClick(self.uiBinder.exit_multiple_btn, function()
    self:toggleMultipleState(false, E.AlbumSelectType.Select, true)
  end)
  self:AddAsyncClick(self.uiBinder.upload_cloud_btn, function()
    self:onUploadBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.delete_btn, function()
    self:onDeleteBtnClick()
  end)
end

function Album_container_temporaryView:onUploadBtnClick()
  local selectedNum = self.albumMainData_:GetSelectedAlbumNumber()
  if selectedNum <= 0 then
    Z.TipsVM.ShowTipsLang(1000027)
    return
  end
  Z.VMMgr.GetVM("album_main").AlbumUpLoadStart(selectedNum)
  local eventData = {}
  eventData.albumOperationType = E.AlbumOperationType.UpLoad
  self.albumMainVM_.ShowMobileAlbumView(eventData)
end

function Album_container_temporaryView:onDeleteBtnClick()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("ConfirmationDelTemp"), function()
    local delData = self.albumMainData_:GetSelectedAlbumPhoto()
    for _, value in pairs(delData) do
      self.albumMainVM_.DeleteLocalPhoto(value)
    end
    self:updateItemList()
    self:toggleMultipleState(false, E.AlbumSelectType.Select, true)
    Z.TipsVM.ShowTipsLang(1000008)
    Z.DialogViewDataMgr:CloseDialogView()
  end)
end

function Album_container_temporaryView:updateItemList()
  local photoData = self.albumMainData_:GetTemporaryAlbumPhoto()
  table.sort(photoData, function(left, right)
    if left.shotTime > right.shotTime then
      return true
    end
    return false
  end)
  self:refFuncBtn(photoData)
  self.uiBinder.layout_group_anim.GroupAnimType = Panda.ZUi.DOTweenAnimType.Open
  self:refTempPhotoCount(#photoData)
  self.camerasysTabScrollRect_:ClearCells()
  self.camerasysTabScrollRect_:SetData(photoData, true)
end

function Album_container_temporaryView:OnDeActive()
  self.camerasysTabScrollRect_:ClearSelected()
  self.camerasysTabScrollRect_:ClearCells()
  self:RemoveEvents()
  self.albumMainData_.SelectType = E.AlbumSelectType.Normal
  self.camerasysTabScrollRect_ = nil
end

function Album_container_temporaryView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.UpdateSelectNumber, self.albumUpdateSelectNumber, self)
  Z.EventMgr:Add(Z.ConstValue.Album.SecondaryEditTempRef, self.updateItemList, self)
  Z.EventMgr:Add(Z.ConstValue.Album.RefUpLoadDelSucTempPhoto, self.albumRefUpLoadDelSucTempPhoto, self)
  Z.EventMgr:Add(Z.ConstValue.Album.LocalPhotoDataUpdate, self.localPhotoDataUpdate, self)
  Z.EventMgr:Add(Z.ConstValue.Album.PhotoEditSuccess, self.updateItemList, self)
end

function Album_container_temporaryView:RemoveEvents()
  Z.EventMgr:Remove(Z.ConstValue.Album.UpdateSelectNumber, self.albumUpdateSelectNumber, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.SecondaryEditTempRef, self.updateItemList, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.RefUpLoadDelSucTempPhoto, self.albumRefUpLoadDelSucTempPhoto, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.LocalPhotoDataUpdate, self.localPhotoDataUpdate, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.PhotoEditSuccess, self.updateItemList, self)
end

function Album_container_temporaryView:toggleMultipleState(isMultiple, selectType, isResetSelectState)
  self:refreshMultipleUI(isMultiple)
  self.albumMainData_.SelectType = selectType
  self.albumMainData_:ClearSelectedAlbumPhoto()
  self:albumUpdateSelectNumber()
  self.camerasysTabScrollRect_:ClearSelected()
  if isResetSelectState then
    self.albumMainData_.SelectType = E.AlbumSelectType.Normal
  end
end

function Album_container_temporaryView:refreshMultipleUI(isMultiple, isAllCancel)
  self.uiBinder.Ref:SetVisible(self.uiBinder.multiple_btn, not isMultiple)
  self.uiBinder.Ref:SetVisible(self.uiBinder.multiple_layout_node, isMultiple)
  self.uiBinder.Ref:SetVisible(self.uiBinder.multiple_num_lab, isMultiple)
  local photoData = self.albumMainData_:GetTemporaryAlbumPhoto()
  if #photoData <= 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.multiple_btn, false)
  end
  if isAllCancel then
    self.uiBinder.Ref:SetVisible(self.uiBinder.multiple_btn, false)
  end
end

function Album_container_temporaryView:localPhotoDataUpdate()
  local photoData = self.albumMainData_:GetTemporaryAlbumPhoto()
  local localPhotoNum = #photoData
  if localPhotoNum <= 0 then
    self:refFuncBtn(photoData)
    self:refTempPhotoCount(#photoData)
    self.albumMainData_:ClearSelectedAlbumPhoto()
    self.albumMainData_.SelectType = E.AlbumSelectType.Normal
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.multiple_num_lab, false)
end

function Album_container_temporaryView:albumUpdateSelectNumber()
  local num = self.albumMainData_:GetSelectedAlbumNumber()
  local param = {val = num}
  self.uiBinder.multiple_num_lab.text = Lang("SelectPhotoNumber", param)
end

function Album_container_temporaryView:albumRefUpLoadDelSucTempPhoto()
  self:updateItemList()
  self:toggleMultipleState(false, E.AlbumSelectType.Select, true)
end

function Album_container_temporaryView:OnRefresh()
  self:updateItemList()
  self:toggleMultipleState(false, E.AlbumSelectType.Select, true)
end

function Album_container_temporaryView:refFuncBtn(photoData)
  if not photoData or not next(photoData) then
    self:refreshMultipleUI(false, true)
  else
    self:refreshMultipleUI(false)
  end
end

function Album_container_temporaryView:refTempPhotoCount(num)
  self.uiBinder.current_used_lab.text = num
  self.uiBinder.Ref:SetVisible(self.uiBinder.empty_node, num == 0)
end

function Album_container_temporaryView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Album_container_temporaryView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Panda.ZUi.DOTweenAnimType.Close)
end

return Album_container_temporaryView
