local super = require("ui.component.loopscrollrectitem")
local AlbumPhotoItem = class("AlbumPhotoItem", super)

function AlbumPhotoItem:ctor()
  self.uiBinder = nil
end

function AlbumPhotoItem:OnInit()
  self.uiBinder.anim_node:Restart(Z.DOTweenAnimType.Open)
  self.isFrist_ = true
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
end

function AlbumPhotoItem:Refresh()
  self.isSelected_ = false
  self.albumType_ = E.AlbumType.Couldalbum
  local index = self.component.Index + 1
  self.itemData_ = self.parent:GetDataByIndex(index)
  self:CheckIndexData(self.itemData_.id)
  self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, self.isSelected_)
  if self.itemData_.tempThumbPhoto then
    self.albumType_ = E.AlbumType.Temporary
    self:localPhotoGet(self.itemData_.tempThumbPhoto)
  else
    self:httpPhotoGet(self.itemData_.thumbnailUrl)
  end
  self:setPhotoAuditStatus()
end

function AlbumPhotoItem:setPhotoAuditStatus()
  if self.itemData_.reviewStartTime then
    if self.itemData_.reviewStartTime == E.PictureReviewType.Reviewing then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, true)
      self.uiBinder.img_state:SetImage(Z.ConstValue.Photo.StateInReview)
      self.uiBinder.lab_state.text = Lang("InReview")
    elseif self.itemData_.reviewStartTime == E.PictureReviewType.Fail then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, true)
      self.uiBinder.img_state:SetImage(Z.ConstValue.Photo.StateReviewFailed)
      self.uiBinder.lab_state.text = Lang("ReviewFailed")
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, false)
  end
end

function AlbumPhotoItem:localPhotoGet(path)
  self.photoId_ = Z.CameraFrameCtrl:ReadTextureToSystemAlbum(path, E.NativeTextureCallToken.album_photo_item)
  if self.photoId_ == 0 then
    return
  end
  self.uiBinder.photo_rawimg:SetNativeTexture(self.photoId_)
end

function AlbumPhotoItem:httpPhotoGet(url)
  self.albumMainVM_.AsyncGetHttpAlbumPhoto(url, E.PictureType.ECameraThumbnail, E.NativeTextureCallToken.album_photo_item, self.parent.uiView.cancelSource, self.OnCallback, self)
end

function AlbumPhotoItem:OnCallback(photoId)
  self:releaseNativeTextures()
  self.photoId_ = photoId
  self.uiBinder.photo_rawimg:SetNativeTexture(self.photoId_)
end

function AlbumPhotoItem:Selected(isSelected)
  if self.albumMainData_.SelectType == E.AlbumSelectType.Normal then
    if not isSelected then
      return
    end
    self.albumMainData_:SetCurrentShowPhotoData(self.itemData_)
    if self.parent.uiView.OpenAlbumViewType == E.AlbumType.Couldalbum or self.parent.uiView.OpenAlbumViewType == E.AlbumType.UnionTemporary or self.parent.uiView.OpenAlbumViewType == E.AlbumType.UnionCloud then
      Z.UIMgr:OpenView("camera_photo_details")
    elseif self.parent.uiView.OpenAlbumViewType == E.AlbumType.Temporary then
      Z.UIMgr:OpenView("album_photo_show")
    end
  elseif self.albumMainData_.SelectType == E.AlbumSelectType.Select then
    self:onItemSelect(isSelected)
  end
end

function AlbumPhotoItem:OnReset()
  self:releaseNativeTextures()
end

function AlbumPhotoItem:CheckIndexData(selectAlbumPhotoId)
  if type(self.parent.uiView.viewData) == "table" and self.parent.uiView.viewData.source and self.parent.uiView.viewData.source == E.AlbumOpenSource.Union then
    if self.albumMainData_.SelectedUnionAlbumPhoto and selectAlbumPhotoId == self.albumMainData_.SelectedUnionAlbumPhoto.id then
      self.parent:SetSelected(self.component.Index)
      return true
    end
  elseif type(self.parent.uiView.viewData) == "table" and self.parent.uiView.viewData.source and self.parent.uiView.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
    if next(self.albumMainData_.SelectedUnionElectronicScreen) and self.albumMainVM_.CheckUnionElectronicScreen(selectAlbumPhotoId) then
      self.parent:SetSelected(self.component.Index)
      return true
    end
  else
    local selectedAlbumData = self.albumMainData_:GetSelectedAlbumPhoto()
    if next(selectedAlbumData) and selectedAlbumData[selectAlbumPhotoId] then
      return true
    end
  end
  return false
end

function AlbumPhotoItem:releaseNativeTextures()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
end

function AlbumPhotoItem:updateSelectedMask()
  self.isSelected_ = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, self.isSelected_)
end

function AlbumPhotoItem:OnUnInit()
  self:releaseNativeTextures()
end

function AlbumPhotoItem:OnBeforePlayAnim()
end

function AlbumPhotoItem:onItemSelect(isSelected)
  self.isSelected_ = isSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, self.isSelected_)
  if self.isSelected_ then
    local selectedNum = self.albumMainData_:GetSelectedAlbumNumber()
    if selectedNum >= Z.Global.PhotoAlbumUploadMaxAmount then
      Z.TipsVM.ShowTips(1000052)
      self.parent:SetUnSelected(self.component.Index)
      return
    end
    if type(self.parent.uiView.viewData) == "table" and self.parent.uiView.viewData.source then
      if self.parent.uiView.viewData.source == E.AlbumOpenSource.Union then
        if not self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetCover) then
          self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, false)
          return
        end
        if self.albumMainData_.SelectedUnionAlbumPhoto then
          self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, false)
          Z.TipsVM.ShowTipsLang(1000570)
          return
        end
        self.albumMainData_.SelectedUnionAlbumPhoto = self.itemData_
      elseif self.parent.uiView.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
        if not self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetEScreenPhoto) then
          self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, false)
          return
        end
        local unionVM = Z.VMMgr.GetVM("union")
        local unionScreenNum = unionVM:GetUnionScreenNum(self.albumMainData_.EScreenId)
        if not self.albumMainData_.SelectedUnionElectronicScreen[self.itemData_.id] and unionScreenNum <= table.zcount(self.albumMainData_.SelectedUnionElectronicScreen) then
          self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, false)
          Z.TipsVM.ShowTipsLang(1000570)
          return
        end
        self.albumMainData_:AddUnionElectronicScreenSelectedPhoto(self.itemData_.id)
      end
    end
    self.albumMainData_:AddSelectedAlbumPhoto(self.itemData_)
  else
    if type(self.parent.uiView.viewData) == "table" and self.parent.uiView.viewData.source then
      if self.parent.uiView.viewData.source == E.AlbumOpenSource.Union then
        if not self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetCover) then
          self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, false)
          return
        end
        self.albumMainData_.SelectedUnionAlbumPhoto = nil
      elseif self.parent.uiView.viewData.source == E.AlbumOpenSource.UnionElectronicScreen then
        if not self.albumMainVM_.CheckUnionPlayerPower(E.UnionPowerDef.SetEScreenPhoto) then
          self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, false)
          return
        end
        self.albumMainData_:DeleteUnionElectronicScreenSelectedPhoto(self.itemData_.id)
      end
    end
    self.albumMainData_:DeleteSelectedAlbumPhoto(self.itemData_.id)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Album.UpdateSelectNumber)
end

return AlbumPhotoItem
