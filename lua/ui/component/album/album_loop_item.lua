local super = require("ui.component.loopscrollrectitem")
local AlbumLoopItem = class("AlbumLoopItem", super)
local albumMainData = Z.DataMgr.Get("album_main_data")
local album_main_vm = Z.VMMgr.GetVM("album_main")

function AlbumLoopItem:ctor()
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.accessRights_ = nil
  self.photoNumber_ = nil
  self.photoName_ = nil
  self.photoId = 0
end

function AlbumLoopItem:OnInit()
  self:initComp()
  self:AddAsyncClick(self.deleteBtn_, function()
    self:onDeleteBtnClick()
  end)
  Z.EventMgr:Add(Z.ConstValue.Album.DelState, self.albumDelState, self)
  self.uiBinder.anim_node:Restart(Z.DOTweenAnimType.Open)
end

function AlbumLoopItem:onDeleteBtnClick()
  if self.isCreateItem_ or self.data_.albumId == 0 then
    return
  end
  local onConfirm = function()
    local cancelSource = Z.CancelSource.Rent()
    if self.albumMainVM_.CheckSubTypeIsUnion() then
      album_main_vm.AsyncDeleteUnionAlbum(self.data_.albumId, cancelSource:CreateToken())
    else
      album_main_vm.AsyncDeleteAlbum(self.data_.albumId, cancelSource:CreateToken())
    end
    cancelSource:Recycle()
    Z.TipsVM.ShowTipsLang(1000005)
    Z.EventMgr:Dispatch(Z.ConstValue.Album.MainViewRef)
    Z.DialogViewDataMgr:CloseDialogView()
  end
  local param = {
    album = {
      name = self.photoName_
    }
  }
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("ConfirmationDelAlbum", param), onConfirm)
end

function AlbumLoopItem:initComp()
  self.deleteBtn_ = self.uiBinder.delete_btn
  self.ruleLab_ = self.uiBinder.rule_lab
  self.albumNameLab_ = self.uiBinder.album_name_lab
  self.numLab_ = self.uiBinder.num_lab
  self.photoRimg_ = self.uiBinder.cover_rImg
  self.photoMask_ = self.uiBinder.photo_mask_node
  self.emptyRimg_ = self.uiBinder.empty_node
  self.lockIcon_ = self.uiBinder.lock_icon_node
  self.maxLab_ = self.uiBinder.num_max_lab
  self.uiBinder.Ref:SetVisible(self.numLab_, albumMainData.AlbumSelectType == E.AlbumSelectType.Select)
end

function AlbumLoopItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  self.isCreateItem_ = false
  self:refreshAlbumInfo()
  self.uiBinder.Ref:SetVisible(self.deleteBtn_, albumMainData.AlbumSelectType == E.AlbumSelectType.Select)
  self:refreshIcon()
end

function AlbumLoopItem:refreshIcon()
  local cover = albumMainData:GetAlbumCover(self.data_.albumId)
  local isShowEmpty = false
  if cover and next(cover) then
    isShowEmpty = false
    album_main_vm.AsyncGetHttpAlbumPhoto(cover.cosUrl, E.PictureType.ECameraThumbnail, E.NativeTextureCallToken.album_loop_item, self.OnCallback, self)
  else
    isShowEmpty = true
  end
  self.uiBinder.Ref:SetVisible(self.emptyRimg_, isShowEmpty)
  self.uiBinder.Ref:SetVisible(self.photoMask_, not isShowEmpty)
  self:setImageAuditStatus()
end

function AlbumLoopItem:albumDelState(albumSelectType)
  if albumMainData.AlbumSelectType == E.AlbumSelectType.Normal or self.data_.albumId == 0 then
    self.uiBinder.Ref:SetVisible(self.deleteBtn_, false)
  else
    self.uiBinder.Ref:SetVisible(self.deleteBtn_, true)
  end
end

function AlbumLoopItem:refreshAlbumInfo()
  if not self.data_ or not next(self.data_) then
    return
  end
  self.uiBinder.Ref:SetVisible(self.lockIcon_, self.data_.access ~= E.AlbumJurisdictionType.All)
  if self.data_.access == E.AlbumJurisdictionType.All then
    self.ruleLab_.text = Lang("JurisdictionTypeAll")
  elseif self.data_.access == E.AlbumJurisdictionType.Friend then
    self.ruleLab_.text = Lang("JurisdictionTypeFriend")
  elseif self.data_.access == E.AlbumJurisdictionType.Self then
    self.ruleLab_.text = Lang("JurisdictionTypeSelf")
  elseif self.data_.access == E.AlbumJurisdictionType.Union then
    self.ruleLab_.text = Lang("JurisdictionTypeUnion")
  end
  if self.data_.name == "" then
    self.albumNameLab_.text = albumMainData.CloudAlbumName
    self.photoName_ = albumMainData.CloudAlbumName
  else
    self.albumNameLab_.text = self.data_.name
    self.photoName_ = self.data_.name
  end
  local maxNum = self.albumMainVM_.GetAlbumMaxNum()
  self.maxLab_.text = #self.data_.photoIds .. "/" .. maxNum
end

function AlbumLoopItem:OnPointerClick(go, eventData)
  if albumMainData.AlbumSelectType == E.AlbumSelectType.Normal then
    if albumMainData.IsMoveAlbum then
      self:movePhotoToAlbum()
      albumMainData.IsMoveAlbum = false
      return
    end
    if self.isCreateItem_ then
      local allAlbumsData = albumMainData:GetAlbumAllData()
      if #allAlbumsData > albumMainData.AlbumMaxNum then
        Z.TipsVM.ShowTipsLang(1000003)
        return
      end
      self.albumMainVM_.ShowAlbumCreatePopupView(E.AlbumPopupType.Create)
    elseif self.parent.uiView.viewData == E.AlbumOpenSource.Personal and self.data_.access ~= E.AlbumJurisdictionType.All then
    else
      Z.UIMgr:OpenView("camera_photo_album_window", {
        albumShowInfo = self.data_,
        source = self.parent.uiView.viewData
      })
    end
  end
end

function AlbumLoopItem:movePhotoToAlbum()
  local photos = albumMainData:GetSelectedAlbumPhoto()
  for _, photo in pairs(photos) do
    Z.CoroUtil.create_coro_xpcall(function()
      local cancelSource = Z.CancelSource.Rent()
      if self.albumMainVm_.CheckSubTypeIsUnion() then
        album_main_vm.AsyncMovePhotoToUnionAlbum(photo.id, self.data_.albumId, cancelSource:CreateToken(), self.OnCallback, self)
      else
        album_main_vm.AsyncMovePhotoOtherAlbum(photo.id, self.data_.albumId, cancelSource:CreateToken(), self.OnCallback, self)
      end
      cancelSource:Recycle()
    end)()
  end
  local data = {}
  data.type = E.AlbumMainState.Couldalbum
  Z.EventMgr:Dispatch(Z.ConstValue.Album.MainViewRef, data)
  albumMainData.SelectType = E.AlbumSelectType.Normal
  Z.TipsVM.ShowTipsLang(1000009)
  albumMainData:ClearSelectedAlbumPhoto()
end

function AlbumLoopItem:OnBeforePlayAnim()
  self.uiBinder.anim_node.OnPlay:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.Trans, true)
  end)
  local groupAnimComp = self.parent:GetContainerGroupAnimComp()
  if groupAnimComp then
    groupAnimComp:AddTweenContainer(self.uiBinder.anim_node)
    self.uiBinder.Ref:SetVisible(self.uiBinder.Trans, false)
  end
end

function AlbumLoopItem:OnReset()
  self:releaseNativeTextures()
end

function AlbumLoopItem:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Album.DelState, self.albumDelState, self)
  albumMainData.AlbumSelectType = E.AlbumSelectType.Normal
  self:releaseNativeTextures()
end

function AlbumLoopItem:OnCallback(photoId)
  self:releaseNativeTextures()
  self.photoId = photoId
  self.photoRimg_:SetNativeTexture(photoId)
end

function AlbumLoopItem:releaseNativeTextures()
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
end

function AlbumLoopItem:setImageAuditStatus()
  if not self.data_.coverThumbnailInfo or not self.data_.coverThumbnailInfo.reviewStartTime then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, false)
    logGreen("\230\178\161\229\136\183\230\150\176coverThumbnailInfo")
    return
  end
  if self.data_.coverThumbnailInfo.reviewStartTime == E.PictureReviewType.Fail then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, true)
    self.uiBinder.img_state:SetImage(Z.ConstValue.Photo.StateReviewFailed)
    self.uiBinder.lab_state.text = Lang("ReviewFailed")
  elseif self.data_.coverThumbnailInfo.reviewStartTime == E.PictureReviewType.Reviewing then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, true)
    self.uiBinder.img_state:SetImage(Z.ConstValue.Photo.StateInReview)
    self.uiBinder.lab_state.text = Lang("InReview")
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, false)
  end
end

return AlbumLoopItem
