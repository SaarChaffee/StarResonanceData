local UI = Z.UI
local super = require("ui.ui_view_base")
local PerosonalzonePhotoShowView = class("PerosonalzonePhotoShowView", super)
local DEFINE = require("ui.model.personalzone_define")

function PerosonalzonePhotoShowView:ctor()
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "personalzone_photo_show")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.albumMainVm_ = Z.VMMgr.GetVM("album_main")
  self.photoIndex_ = 0
  self.photoCount_ = 0
  self.lastPhotoIndex_ = 0
  self.isChange_ = false
end

function PerosonalzonePhotoShowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("personalzone_photo_show")
  end)
  self:AddAsyncClick(self.uiBinder.btn_editor, function()
    self.personalzoneData_:InitShowPhotoData()
    Z.UIMgr:OpenView("album_main", E.AlbumOpenSource.Personal)
  end)
  self:AddAsyncClick(self.uiBinder.btn_left, function()
    self.photoIndex_ = self.photoIndex_ - 1
    self.photoIndex_ = math.max(self.photoIndex_, 0)
    self:refreshRimgAndBtns()
  end)
  self:AddAsyncClick(self.uiBinder.btn_right, function()
    self.photoIndex_ = self.photoIndex_ + 1
    self.photoIndex_ = math.min(self.photoIndex_, DEFINE.ShowPhotoMaxCount)
    self:refreshRimgAndBtns()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId)
  self.photoIndex_ = 1
  self.photoNativeTextureId_ = {}
  self.isChange_ = false
  self:resetPhotosData()
  self:refreshRimgAndBtns()
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnPhotoRefresh, self.refreshAllPhotos, self)
end

function PerosonalzonePhotoShowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  self:releaseAllPhotos()
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnPhotoRefresh, self.refreshAllPhotos, self)
  if self.isChange_ then
    Z.EventMgr:Dispatch(Z.ConstValue.PersonalZone.OnUnrealScenePhotoRefresh)
  end
end

function PerosonalzonePhotoShowView:releaseAllPhotos()
  for _, photoId in pairs(self.photoNativeTextureId_) do
    if photoId ~= 0 then
      Z.LuaBridge.ReleaseScreenShot(photoId)
    end
  end
  self.photoNativeTextureId_ = {}
end

function PerosonalzonePhotoShowView:refreshAllPhotos()
  self.isChange_ = true
  self.viewData.photos = Z.ContainerMgr.CharSerialize.personalZone.photos
  self:resetPhotosData()
  self:releaseAllPhotos()
  self:refreshRimgAndBtns()
end

function PerosonalzonePhotoShowView:resetPhotosData()
  self.showPhotos_ = {}
  self.photoCount_ = 0
  self.lastPhotoIndex_ = 0
  for i = 1, DEFINE.ShowPhotoMaxCount do
    local photo = self.viewData.photos[i]
    if photo and 0 < photo then
      self.showPhotos_[i] = photo
      self.photoCount_ = self.photoCount_ + 1
      self.lastPhotoIndex_ = i
    end
  end
end

function PerosonalzonePhotoShowView:refreshRimgAndBtns()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_left, self.photoIndex_ > 1)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_right, self.photoIndex_ < self.lastPhotoIndex_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_cover, self.photoIndex_ == 1 and self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId)
  if self.photoNativeTextureId_[self.photoIndex_] and self.photoNativeTextureId_[self.photoIndex_] > 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photo, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_no_bg, false)
    self.uiBinder.rimg_photo:SetNativeTexture(self.photoNativeTextureId_[self.photoIndex_])
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photo, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_no_bg, true)
    if self.showPhotos_[self.photoIndex_] and self.showPhotos_[self.photoIndex_] ~= 0 then
      Z.CoroUtil.create_coro_xpcall(function()
        local ret = self.albumMainVm_.GetPhoto(self.viewData.charId, self.showPhotos_[self.photoIndex_], self.cancelSource:CreateToken())
        if ret.errCode and ret.errCode ~= 0 then
          return
        end
        local url = ""
        for _, photoValue in pairs(ret.photoGraph.images) do
          if photoValue.type == E.PictureType.ECameraRender then
            url = photoValue.cosUrl
          end
        end
        self:httpRequestPhoto(self.photoIndex_, url, self.showPhotos_[self.photoIndex_])
      end)()
    end
  end
end

function PerosonalzonePhotoShowView:httpRequestPhoto(index, url, photoId)
  self.albumMainVm_.AsyncGetHttpAlbumPhoto(url, E.PictureType.ECameraRender, E.NativeTextureCallToken.Personalzone_photo_show_view, function(obj, photoId)
    self.photoNativeTextureId_[index] = photoId
    if index == self.photoIndex_ then
      self.uiBinder.rimg_photo:SetNativeTexture(self.photoNativeTextureId_[self.photoIndex_])
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photo, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_no_bg, false)
    end
  end, self)
end

return PerosonalzonePhotoShowView
