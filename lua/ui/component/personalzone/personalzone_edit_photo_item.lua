local super = require("ui.component.loop_list_view_item")
local PersonalzoneEditPhotoItem = class("PersonalzoneEditPhotoItem", super)

function PersonalzoneEditPhotoItem:OnInit()
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.albumMainVm_ = Z.VMMgr.GetVM("album_main")
  self.uiBinder.btn_select:AddListener(function()
    Z.AudioMgr:Play("sys_general_frame")
    self.parent.UIView:SelectId(self.data_.id)
  end)
  self:AddAsyncListener(self.uiBinder.btn_find, function()
    self.albumMainData_:SetCurrentShowPhotoData(self.data_)
    Z.UIMgr:OpenView("camera_photo_details")
  end)
end

function PersonalzoneEditPhotoItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.selected_node, self.parent.UIView:IsSelect(self.data_.id))
  Z.CoroUtil.create_coro_xpcall(function()
    self:httpPhotoGet(self.data_.thumbnailUrl)
  end)()
end

function PersonalzoneEditPhotoItem:OnUnInit()
  self:releaseNativeTextures()
end

function PersonalzoneEditPhotoItem:releaseNativeTextures()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
end

function PersonalzoneEditPhotoItem:httpPhotoGet(url)
  self.albumMainVm_.AsyncGetHttpAlbumPhoto(url, E.PictureType.ECameraThumbnail, E.NativeTextureCallToken.album_photo_item, self.parent.UIView.cancelSource, self.OnCallback, self)
end

function PersonalzoneEditPhotoItem:OnCallback(photoId)
  self:releaseNativeTextures()
  self.photoId_ = photoId
  self.uiBinder.photo_rawimg:SetNativeTexture(self.photoId_)
end

function PersonalzoneEditPhotoItem:setPhotoAuditStatus()
  if self.data_.reviewStartTime then
    if self.data_.reviewStartTime == E.PictureReviewType.Reviewing then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_state, true)
      self.uiBinder.img_state:SetImage(Z.ConstValue.Photo.StateInReview)
      self.uiBinder.lab_state.text = Lang("InReview")
    elseif self.data_.reviewStartTime == E.PictureReviewType.Fail then
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

return PersonalzoneEditPhotoItem
