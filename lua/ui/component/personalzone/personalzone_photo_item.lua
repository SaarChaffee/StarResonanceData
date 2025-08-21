local PersonalzonePhotoItem = class("PersonalzonePhotoItem")

function PersonalzonePhotoItem:ctor(parent)
  self.parentView_ = parent
  self.albumMainVm_ = Z.VMMgr.GetVM("album_main")
end

function PersonalzonePhotoItem:Init(uiBinder)
  self.uiBinder_ = uiBinder
  self.uiBinder_.img_icon.enabled = false
end

function PersonalzonePhotoItem:AsyncRefreshPhotoId(charId, getPhotoId)
  if self.getPhotoId_ and self.getPhotoId_ == getPhotoId then
    return
  end
  self.getPhotoId_ = getPhotoId
  self.uiBinder_.img_icon.enabled = false
  if getPhotoId then
    local ret = self.albumMainVm_.GetPhoto(charId, getPhotoId, self.parentView_.cancelSource:CreateToken())
    if ret.errCode and ret.errCode ~= 0 then
      return
    end
    local url
    for _, photoValue in pairs(ret.photoGraph.images) do
      if photoValue.type == E.PictureType.ECameraThumbnail then
        url = photoValue.cosUrl
        break
      end
    end
    if url then
      self.albumMainVm_.AsyncGetHttpAlbumPhoto(url, E.PictureType.ECameraThumbnail, E.NativeTextureCallToken.album_photo_item, self.parentView_.cancelSource, self.onCallback, self)
    end
  end
end

function PersonalzonePhotoItem:UnInit()
  self:releaseNativeTextures()
  self.getPhotoId_ = nil
end

function PersonalzonePhotoItem:onCallback(photoId)
  self:releaseNativeTextures()
  self.photoId_ = photoId
  self.uiBinder_.img_icon.enabled = true
  self.uiBinder_.img_icon:SetNativeTexture(self.photoId_)
end

function PersonalzonePhotoItem:releaseNativeTextures()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
end

return PersonalzonePhotoItem
