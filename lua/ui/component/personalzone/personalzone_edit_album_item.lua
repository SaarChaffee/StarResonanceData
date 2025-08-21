local super = require("ui.component.loop_list_view_item")
local PersonalzoneEditAlbumItem = class("PersonalzoneEditAlbumItem", super)

function PersonalzoneEditAlbumItem:OnInit()
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.albumMainVm_ = Z.VMMgr.GetVM("album_main")
  self:AddAsyncListener(self.uiBinder.delete_btn, function()
    local onConfirm = function()
      local cancelSource = Z.CancelSource.Rent()
      self.albumMainVm_.AsyncDeleteAlbum(self.data_.albumId, cancelSource:CreateToken())
      cancelSource:Recycle()
      Z.TipsVM.ShowTipsLang(1000005)
      Z.EventMgr:Dispatch(Z.ConstValue.Album.MainViewRef)
    end
    local name = ""
    if self.data_.name == "" then
      name = self.albumMainData_.CloudAlbumName
    else
      name = self.data_.name
    end
    local param = {
      album = {name = name}
    }
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("ConfirmationDelAlbum", param), onConfirm)
  end)
end

function PersonalzoneEditAlbumItem:OnRefresh(data)
  self.data_ = data
  Z.CoroUtil.create_coro_xpcall(function()
    self:refreshIcon()
    self:setImageAuditStatus()
    self.uiBinder.rule_lab.text = Lang("JurisdictionTypeAll")
    if self.data_.name == "" then
      self.uiBinder.album_name_lab.text = self.albumMainData_.CloudAlbumName
    else
      self.uiBinder.album_name_lab.text = self.data_.name
    end
    local maxNum = self.albumMainVm_.GetAlbumMaxNum()
    self.uiBinder.num_max_lab.text = #self.data_.photoIds .. "/" .. maxNum
  end)()
end

function PersonalzoneEditAlbumItem:OnUnInit()
  self:releaseNativeTextures()
end

function PersonalzoneEditAlbumItem:OnSelected(isSelected, isClick)
  if isClick then
    Z.AudioMgr:Play("sys_general_frame")
  end
  if isSelected then
    self.parent.UIView:SelectAlbum(self.data_.albumId)
  end
end

function PersonalzoneEditAlbumItem:releaseNativeTextures()
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
end

function PersonalzoneEditAlbumItem:OnCallback(photoId)
  self:releaseNativeTextures()
  self.photoId = photoId
  self.uiBinder.cover_rImg:SetNativeTexture(photoId)
end

function PersonalzoneEditAlbumItem:refreshIcon()
  local cover = self.albumMainData_:GetAlbumCover(self.data_.albumId)
  local isShowEmpty = false
  if cover and next(cover) then
    isShowEmpty = false
    self.albumMainVm_.AsyncGetHttpAlbumPhoto(cover.cosUrl, E.PictureType.ECameraThumbnail, E.NativeTextureCallToken.album_loop_item, self.parent.UIView.cancelSource, self.OnCallback, self)
  else
    isShowEmpty = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.empty_node, isShowEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.photo_mask_node, not isShowEmpty)
end

function PersonalzoneEditAlbumItem:setImageAuditStatus()
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

return PersonalzoneEditAlbumItem
