local UI = Z.UI
local super = require("ui.ui_view_base")
local Camera_cloud_game_share_code_windowView = class("Camera_cloud_game_share_code_windowView", super)
local logoImg = "ui/textures/login/login_logo"

function Camera_cloud_game_share_code_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "camera_cloud_game_share_code_window")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.photoGraphTextureId_ = nil
end

function Camera_cloud_game_share_code_windowView:OnActive()
  self.uiBinder.point_check:StartCheck()
  self:EventAddAsyncListener(self.uiBinder.point_check.ContainGoEvent, function(isContain)
    if not isContain then
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end, nil, nil)
  self:initView()
  self:initBtn()
  Z.CoroUtil.create_coro_xpcall(function()
    self.photoGraphTextureId_ = self:asyncTakePhotoByRect()
  end)()
end

function Camera_cloud_game_share_code_windowView:OnDeActive()
  self.uiBinder.point_check:StopCheck()
  if self.photoGraphTextureId_ then
    Z.LuaBridge.ReleaseScreenShot(self.photoGraphTextureId_)
  end
  self.photoGraphTextureId_ = nil
  Z.LuaBridge.ReleaseScreenShot(self.textureId_)
  self.textureId_ = nil
end

function Camera_cloud_game_share_code_windowView:OnRefresh()
end

function Camera_cloud_game_share_code_windowView:initBtn()
  self:AddAsyncClick(self.uiBinder.btn_qq, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.QQ)
  end)
  self:AddAsyncClick(self.uiBinder.btn_wechat, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.WeChat)
  end)
  self:AddAsyncClick(self.uiBinder.btn_moments, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.WeChatMoment)
  end)
  self:AddAsyncClick(self.uiBinder.btn_save, function()
    self:saveImage()
  end)
end

function Camera_cloud_game_share_code_windowView:initView()
  local titlePath = self.uiBinder.preface_cache:GetString("titleImg")
  self.uiBinder.rimg_title:SetImage(titlePath)
  self.uiBinder.rimg_game:SetImage(logoImg)
  local accountData = Z.DataMgr.Get("account_data")
  self:SetUIVisible(self.uiBinder.node_share, not Z.IsPCUI and accountData.PlatformType == E.LoginPlatformType.TencentPlatform)
  if not self.viewData then
    return
  end
  self.textureId_ = self.viewData.textureId
  self.uiBinder.rimg_half:SetNativeTexture(self.textureId_)
  local rect = self.uiBinder.node_code.rect
  local colorData = Z.QrCodeUtil.GenerateQrCode(self.viewData.shareCode, rect.width, rect.height)
  if not colorData then
    return
  end
  self.uiBinder.rimg_code:SetTextureByColor32(rect.width, rect.height, colorData)
end

function Camera_cloud_game_share_code_windowView:shareImage(sharePlatform)
  if not self.photoGraphTextureId_ then
    return
  end
  Z.GameShareManager:ShareImageAutoThumb("", self.photoGraphTextureId_, sharePlatform, "", self.viewData.shareCode)
end

function Camera_cloud_game_share_code_windowView:saveImage()
  Z.CameraFrameCtrl:SaveToSystemAlbum(self.photoGraphTextureId_, function(result)
    if result then
      if Z.IsPCUI then
        local albumPath = Z.CameraFrameCtrl:GetPCAlbumPath()
        Z.TipsVM.ShowTipsLang(1000041, {val = albumPath})
      else
        Z.TipsVM.ShowTipsLang(1000036)
      end
    else
      Z.TipsVM.ShowTipsLang(1000037)
    end
  end, Z.ConstValue.PhotoShareCodeFolder)
end

function Camera_cloud_game_share_code_windowView:asyncTakePhotoByRect()
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  local rectTransform = self.uiBinder.node_root
  local offset = Vector2.New(Z.UIRoot.CurCanvasSize.x / 2, Z.UIRoot.CurCanvasSize.y / 2)
  local rectPosX = -rectTransform.rect.width / 2 + rectTransform.anchoredPosition.x + offset.x
  local rectPosY = -rectTransform.rect.height / 2 + rectTransform.anchoredPosition.y + offset.y
  local widthScale = Z.UIRoot.CurScreenSize.x / Z.UIRoot.CurCanvasSize.x
  local heightScale = Z.UIRoot.CurScreenSize.y / Z.UIRoot.CurCanvasSize.y
  local oriId = asyncCall(Z.UIRoot.CurScreenSize.x, Z.UIRoot.CurScreenSize.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri, rectPosX * widthScale, rectPosY * heightScale, rectTransform.rect.width * widthScale, rectTransform.rect.height * heightScale)
  return oriId
end

return Camera_cloud_game_share_code_windowView
