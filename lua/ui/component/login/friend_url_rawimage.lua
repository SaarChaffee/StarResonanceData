local FriendUrlRawImage = class("FriendUrlRawImage")

function FriendUrlRawImage:ctor(parentView, parentUIBinder, rawImage)
  self.albumMainVm_ = Z.VMMgr.GetVM("album_main")
  self.parentView_ = parentView
  self.parentUIBinder_ = parentUIBinder
  self.rawImage_ = rawImage
  self.photoId_ = nil
end

function FriendUrlRawImage:Init(url)
  self.parentUIBinder_.Ref:SetVisible(self.rawImage_, false)
  self:httpGetHeadRimage(url)
end

function FriendUrlRawImage:UnInit()
  self:clearCachePhoto()
end

function FriendUrlRawImage:httpGetHeadRimage(url)
  self:clearCachePhoto()
  Z.CoroUtil.create_coro_xpcall(function()
    self.photoId_ = self.albumMainVm_.AsynHttpCachePhoto(url)
    self.rawImage_:SetNativeTexture(self.photoId_)
    self.parentUIBinder_.Ref:SetVisible(self.rawImage_, true)
  end)()
end

function FriendUrlRawImage:clearCachePhoto()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
end

return FriendUrlRawImage
