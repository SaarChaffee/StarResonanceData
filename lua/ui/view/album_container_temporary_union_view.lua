local UI = Z.UI
local super = require("ui.ui_subview_base")
local Album_container_union_temporaryView = class("Album_container_union_temporaryView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local album_photo_item = require("ui.component.album.album_photo_item")

function Album_container_union_temporaryView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "album_container_union_temporary", "photograph/album_container_temporary_union_sub", UI.ECacheLv.None, parent)
end

function Album_container_union_temporaryView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:startAnimatedShow()
  self:initParam()
  self:initComp()
  self:initBtnClick()
  self:BindEvents()
end

function Album_container_union_temporaryView:initParam()
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.OpenAlbumViewType = E.AlbumType.UnionTemporary
end

function Album_container_union_temporaryView:initComp()
  self.multiple_btn_ = self.uiBinder.multiple_btn
  self.exit_multiple_btn_ = self.uiBinder.exit_multiple_btn
  self.delete_btn_ = self.uiBinder.delete_btn
  self.share_btn_ = self.uiBinder.upload_cloud_btn
  self.anim_ = self.uiBinder.anim
  self.photo_loopScroll_ = self.uiBinder.photo_loopScroll
  self.layout_group_anim_ = self.uiBinder.layout_group_anim
  self.empty_node_ = self.uiBinder.empty_node
  self.cameraTabScrollRect_ = loopScrollRect.new(self.photo_loopScroll_, self, album_photo_item)
end

function Album_container_union_temporaryView:initBtnClick()
  self:AddClick(self.multiple_btn_, function()
    self:toggleMultipleState(true, E.AlbumSelectType.Select)
  end)
  self:AddClick(self.exit_multiple_btn_, function()
    self:toggleMultipleState(false, E.AlbumSelectType.Select, true)
  end)
  self:AddAsyncClick(self.delete_btn_, function()
    self:onDeleteBtnClick()
  end)
  self:AddAsyncClick(self.share_btn_, function()
    self:onUploadBtnClick()
  end)
end

function Album_container_union_temporaryView:onUploadBtnClick()
  local selectedNum = self.albumMainData_:GetSelectedAlbumNumber()
  if selectedNum <= 0 then
    Z.TipsVM.ShowTipsLang(1000027)
    return
  end
  Z.VMMgr.GetVM("album_main").AlbumUpLoadStart(selectedNum)
  local eventData = {}
  eventData.albumOperationType = E.AlbumOperationType.UnionMove
  self.albumMainVM_.ShowMobileAlbumView(eventData)
end

function Album_container_union_temporaryView:onDeleteBtnClick()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("ConfirmationDelTemp"), function()
    local delData = self.albumMainData_:GetSelectedAlbumPhoto()
    for _, value in pairs(delData) do
      self.albumMainVM_.AsyncDeleteUnionTmpPhoto(value.id, self.cancelSource:CreateToken())
    end
    self:updateItemList()
    self:toggleMultipleState(false, E.AlbumSelectType.Select, true)
    Z.TipsVM.ShowTipsLang(1000008)
    Z.DialogViewDataMgr:CloseDialogView()
  end)
end

function Album_container_union_temporaryView:updateItemList()
  Z.CoroUtil.create_coro_xpcall(function()
    local photoData = self.albumMainVM_.AsyncGetUnionTmpAlbumPhotos(self.cancelSource:CreateToken())
    if not photoData or not next(photoData) then
      self:refTempPhotoCount(0)
      self.cameraTabScrollRect_:ClearCells()
      return
    end
    self:refFuncBtn(photoData)
    self.layout_group_anim_.GroupAnimType = Panda.ZUi.DOTweenAnimType.Open
    self:refTempPhotoCount(#photoData)
    self.cameraTabScrollRect_:ClearCells()
    self.cameraTabScrollRect_:SetData(photoData, true)
  end)()
end

function Album_container_union_temporaryView:OnDeActive()
  self.cameraTabScrollRect_:ClearSelected()
  self.cameraTabScrollRect_:ClearCells()
  self:RemoveEvents()
  self.albumMainData_.SelectType = E.AlbumSelectType.Normal
  self.cameraTabScrollRect_ = nil
end

function Album_container_union_temporaryView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.UpdateSelectNumber, self.albumUpdateSelectNumber, self)
  Z.EventMgr:Add(Z.ConstValue.Album.SecondaryEditTempRef, self.updateItemList, self)
  Z.EventMgr:Add(Z.ConstValue.Album.RefUpLoadDelSucTempPhoto, self.albumRefUpLoadDelSucTempPhoto, self)
  Z.EventMgr:Add(Z.ConstValue.Album.LocalPhotoDataUpdate, self.localPhotoDataUpdate, self)
  Z.EventMgr:Add(Z.ConstValue.Album.PhotoEditSuccess, self.updateItemList, self)
end

function Album_container_union_temporaryView:RemoveEvents()
  Z.EventMgr:Remove(Z.ConstValue.Album.UpdateSelectNumber, self.albumUpdateSelectNumber, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.SecondaryEditTempRef, self.updateItemList, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.RefUpLoadDelSucTempPhoto, self.albumRefUpLoadDelSucTempPhoto, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.LocalPhotoDataUpdate, self.localPhotoDataUpdate, self)
  Z.EventMgr:Remove(Z.ConstValue.Album.PhotoEditSuccess, self.updateItemList, self)
end

function Album_container_union_temporaryView:toggleMultipleState(isMultiple, selectType, isResetSelectState)
  self:refreshMultipleUI(isMultiple)
  self.albumMainData_.SelectType = selectType
  self.albumMainData_:ClearSelectedAlbumPhoto()
  self:albumUpdateSelectNumber()
  self.cameraTabScrollRect_:ClearSelected()
  if isResetSelectState then
    self.albumMainData_.SelectType = E.AlbumSelectType.Normal
  end
end

function Album_container_union_temporaryView:refreshMultipleUI(isMultiple, isAllCancel)
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

function Album_container_union_temporaryView:localPhotoDataUpdate()
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

function Album_container_union_temporaryView:albumUpdateSelectNumber()
  local num = self.albumMainData_:GetSelectedAlbumNumber()
  local param = {val = num}
  self.uiBinder.multiple_num_lab.text = Lang("SelectPhotoNumber", param)
end

function Album_container_union_temporaryView:albumRefUpLoadDelSucTempPhoto()
  self:updateItemList()
  self:toggleMultipleState(false, E.AlbumSelectType.Select, true)
end

function Album_container_union_temporaryView:OnRefresh()
  self:updateItemList()
  self:toggleMultipleState(false, E.AlbumSelectType.Select, true)
end

function Album_container_union_temporaryView:refFuncBtn(photoData)
  if not (photoData and next(photoData)) or not self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.EditAlbum) then
    self:refreshMultipleUI(false, true)
  else
    self:refreshMultipleUI(false)
  end
end

function Album_container_union_temporaryView:refTempPhotoCount(num)
  local textValue = {
    val1 = num,
    val2 = Z.Global.UnionPhotoAlbumTemporaryNumLimit
  }
  self.uiBinder.lab_capacity.text = Lang("PhotoAlbumCapacityUnion", textValue)
  self.uiBinder.Ref:SetVisible(self.empty_node_, num == 0)
end

function Album_container_union_temporaryView:startAnimatedShow()
end

function Album_container_union_temporaryView:startAnimatedHide()
end

return Album_container_union_temporaryView
