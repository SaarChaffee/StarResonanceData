local GameShareManager = class("GameShareManager")
local TEMPSHAREIMAGEPATH = "tempshare"
local TEMPSHAREIMAGE = "tempshareimage"
local TEMPSHARETHUMBNAIL = "tempsharethumbnail"
local THUMB_WIDTH = 256
local THUMB_HEIGHT = 144

function GameShareManager:ctor()
  self.isInit_ = false
  self.shareChannel_ = {}
end

function GameShareManager:OpenShareView()
end

function GameShareManager:HideShareView()
end

function GameShareManager:GetShareChannel()
  if not self.isInit_ then
    local channels = Z.SDKShare.SupportSharePlatforms
    for i = 0, channels.Length - 1 do
      self.shareChannel_[i + 1] = channels[i]
    end
    self.isInit_ = true
  end
  return self.shareChannel_
end

function GameShareManager:ShareLink(title, link, shareplatform, thumb, des, extra)
  local thumbPath = ""
  if thumb then
    if type(thumb) == "string" then
      thumbPath = thumb
    elseif type(thumb) == "number" then
      local texture = Z.SDKShare.GetTextureById(thumb)
      thumbPath = Z.SDKShare.SaveImageToLocal(TEMPSHAREIMAGEPATH, TEMPSHARETHUMBNAIL, texture)
    else
      thumbPath = Z.SDKShare.SaveImageToLocal(TEMPSHAREIMAGEPATH, TEMPSHARETHUMBNAIL, thumb)
    end
  end
  Z.SDKShare.ShareLink(title, link, shareplatform, thumbPath, des, extra)
end

function GameShareManager:ShareImage(title, shareimage, shareplatform, thumb, des, extra)
  local shareImagePath
  if shareimage then
    if type(shareimage) == "string" then
      shareImagePath = shareimage
    elseif type(shareimage) == "number" then
      local texture = Z.SDKShare.GetTextureById(shareimage)
      shareImagePath = Z.SDKShare.SaveImageToLocal(TEMPSHAREIMAGEPATH, TEMPSHAREIMAGE, texture)
    else
      shareImagePath = Z.SDKShare.SaveImageToLocal(TEMPSHAREIMAGEPATH, TEMPSHAREIMAGE, shareimage)
    end
  end
  local thumbPath
  if thumb then
    if type(thumb) == "string" then
      thumbPath = thumb
    elseif type(thumb) == "number" then
      local texture = Z.SDKShare.GetTextureById(thumb)
      thumbPath = Z.SDKShare.SaveImageToLocal(TEMPSHAREIMAGEPATH, TEMPSHARETHUMBNAIL, texture)
    else
      thumbPath = Z.SDKShare.SaveImageToLocal(TEMPSHAREIMAGEPATH, TEMPSHARETHUMBNAIL, thumb)
    end
  end
  Z.SDKShare.ShareImage(title, shareImagePath, shareplatform, thumbPath, des, extra)
end

function GameShareManager:ShareImageAutoThumb(title, shareimage, shareplatform, des, extra)
  local shareTexture = Z.SDKShare.GetTextureById(shareimage)
  local shareImagePath = Z.SDKShare.SaveImageToLocal(TEMPSHAREIMAGEPATH, TEMPSHAREIMAGE, shareTexture)
  local thumb = Z.LuaBridge.ResizeTextureSizeForAlbum(shareimage, E.NativeTextureCallToken.GameShare, THUMB_WIDTH, THUMB_HEIGHT)
  local thumbTexture = Z.SDKShare.GetTextureById(thumb)
  local thumbPath = Z.SDKShare.SaveImageToLocal(TEMPSHAREIMAGEPATH, TEMPSHARETHUMBNAIL, thumbTexture)
  Z.SDKShare.ShareImage(title, shareImagePath, shareplatform, thumbPath, des, extra)
end

return GameShareManager
