local super = require("ui.component.loopscrollrectitem")
local AlbumNewlybuildItem = class("AlbumNewlybuildItem", super)
local albumMainData = Z.DataMgr.Get("album_main_data")

function AlbumNewlybuildItem:ctor()
end

function AlbumNewlybuildItem:OnInit()
end

function AlbumNewlybuildItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  if not (self.data_ and next(self.data_)) or self.data_.albumId == -1 then
    return
  end
  self.uiBinder.lab_album_name.text = self.data_.name
  self.num = #self.data_.photoIds
  self.uiBinder.lab_album_quantity.text = self.num .. Lang("PhotoNum")
  self:refreshIcon()
end

function AlbumNewlybuildItem:refreshIcon()
  local cover = albumMainData:GetAlbumCover(self.data_.albumId)
  if not cover or not next(cover) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_mask, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_temp_bg, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_mask, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_temp_bg, false)
    Z.VMMgr.GetVM("album_main").AsyncGetHttpAlbumPhoto(cover.cosUrl, E.PictureType.ECameraThumbnail, E.NativeTextureCallToken.alnum_newlybuild_item, self.OnCallback, self)
  end
end

function AlbumNewlybuildItem:OnPointerClick(go, eventData)
  local eventData = {}
  eventData.id = self.data_.albumId
  eventData.num = self.num
  self.parent.uiView:SelectedItemEvent(eventData)
end

function AlbumNewlybuildItem:OnReset()
  self:releaseNativeTextures()
end

function AlbumNewlybuildItem:OnUnInit()
  self:releaseNativeTextures()
end

function AlbumNewlybuildItem:OnCallback(photoId)
  self:releaseNativeTextures()
  self.photoId = photoId
  self.uiBinder.rimg_photo:SetNativeTexture(photoId)
end

function AlbumNewlybuildItem:releaseNativeTextures()
  if self.photoId and self.photoId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId)
    self.photoId = 0
  end
end

return AlbumNewlybuildItem
