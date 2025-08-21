local super = require("ui.ui_view_base")
local Camera_photo_mainView = class("Camera_photo_mainView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local logoImg = "ui/textures/login/login_logo"

function Camera_photo_mainView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_photo_main")
  self.camerasysVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.snapshotVM_ = Z.VMMgr.GetVM("snapshot")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.socialVm_ = Z.VMMgr.GetVM("social")
end

function Camera_photo_mainView:intiComp()
  self.btn_close_ = self.uiBinder.btn_close
  self.btn_save_ = self.uiBinder.btn_save
  self.btn_share_ = self.uiBinder.btn_share
  self.rimg_photo_ = self.uiBinder.rimg_photo
  self.img_bg_photo_frame_ = self.uiBinder.img_bg_photo_frame
  self.node_anim_ = self.uiBinder.node_anim
  self.btn_temporary_ = self.uiBinder.btn_temporary
  self.scene_mask_ = self.uiBinder.scene_mask
  self.isShowPlayerInfo_ = false
  self.isShowGameInfo_ = false
  self.uiBinder.rimg_game_name:SetImage(logoImg)
  self.uiBinder.rimg_game_name_1:SetImage(logoImg)
end

function Camera_photo_mainView:initBtnClick()
  self:AddClick(self.btn_close_, function()
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ViewShow)
    self.camerasysVM_.CloseCameraPhotoMain()
  end)
  self:AddClick(self.btn_temporary_, function()
    self.camerasysVM_.SavePhotoToTempAlbum(self.cachedNativeTextureOriId, self.cachedNativeTextureEffectId, self.cachedNativeTextureThumbId)
    Z.TipsVM.ShowTipsLang(1000001)
    self.camerasysVM_.CloseCameraPhotoMain()
  end)
  self:AddAsyncClick(self.btn_save_, function()
    if self.isShowGameInfo_ or self.isShowPlayerInfo_ then
      self:savePhoto()
    else
      Z.CameraFrameCtrl:SaveToSystemAlbum(self.cachedNativeTextureEffectId, function(result)
        if result then
          if Z.IsPCUI then
            local albumPath = Z.CameraFrameCtrl:GetPCAlbumPath()
            Z.TipsVM.ShowTipsLang(1000041, {val = albumPath})
          else
            Z.TipsVM.ShowTipsLang(1000036)
          end
          self.camerasysVM_.CloseCameraPhotoMain()
        else
          Z.TipsVM.ShowTipsLang(1000037)
        end
      end)
    end
  end)
  self:AddClick(self.btn_share_, function()
    Z.TipsVM.ShowTipsLang(130004)
  end)
  self:AddAsyncClick(self.uiBinder.btn_qq, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.QQ)
  end)
  self:AddAsyncClick(self.uiBinder.btn_wechat, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.WeChat)
  end)
  self:AddAsyncClick(self.uiBinder.btn_moments, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.WeChatMoment)
  end)
  self.uiBinder.tog_player:SetIsOnWithoutCallBack(false)
  self.uiBinder.tog_player:RemoveAllListeners()
  self.uiBinder.tog_player:AddListener(function(isOn)
    self:setPlayerInfo(isOn)
  end)
  self.uiBinder.tog_game:SetIsOnWithoutCallBack(false)
  self.uiBinder.tog_game:RemoveAllListeners()
  self.uiBinder.tog_game:AddListener(function(isOn)
    self:setGameInfo(isOn)
  end)
  self:AddClick(self.uiBinder.btn_copy, function()
    if not self.viewData then
      return
    end
    Z.LuaBridge.SystemCopy(self.viewData)
    Z.TipsVM.ShowTips(120016)
  end)
  self:initWaterMark()
end

function Camera_photo_mainView:OnActive()
  self:initParam()
  self:intiComp()
  self:initBtnClick()
  self:startAnimatedShow()
  self:bindWatchers()
  self.scene_mask_:SetSceneMaskByKey(self.SceneMaskKey)
  self:showOrHideBtnAndBottom(true)
  local isUnlockFunc = self.gotoFuncVM_.FuncIsOn(E.FunctionID.SDKShareLocalPhoto, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, isUnlockFunc and not Z.IsPCUI)
end

function Camera_photo_mainView:initParam()
  self.designWidth_ = Z.UIRoot.DESIGNSIZE_WIDTH
  self.designHeight_ = Z.UIRoot.DESIGNSIZE_HEIGHT
  self.curSceenSize_ = Z.UIRoot.CurScreenSize
end

function Camera_photo_mainView:bindWatchers()
  function self.playerInfoDataFunc_(container, dirtys)
    self.uiBinder.lab_level.text = Lang("RoleLevelText") .. Z.ContainerMgr.CharSerialize.roleLevel.level
  end
  
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.playerInfoDataFunc_)
end

function Camera_photo_mainView:unBindWatchers()
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:UnregWatcher(self.playerInfoDataFunc_)
end

function Camera_photo_mainView:OnDeActive()
  self:releaseTmpTextures()
  self:unBindWatchers()
  self.playerInfoDataFunc_ = nil
end

function Camera_photo_mainView:OnRefresh()
  local mainPhotoData = self.cameraData_:GetMainCameraPhotoData()
  if mainPhotoData and next(mainPhotoData) then
    self:setNativeTexture(mainPhotoData.oriId, mainPhotoData.effectId, mainPhotoData.thumbId)
  end
end

function Camera_photo_mainView:setNativeTexture(oriId, effectId, thumbId)
  self.cachedNativeTextureOriId = oriId
  self.cachedNativeTextureEffectId = effectId
  self.cachedNativeTextureThumbId = thumbId
  self.rimg_photo_:SetNativeTexture(effectId)
end

function Camera_photo_mainView:releaseTmpTextures()
  if self.cachedNativeTextureOriId and self.cachedNativeTextureOriId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.cachedNativeTextureOriId)
    self.cachedNativeTextureOriId = 0
  end
  if self.cachedNativeTextureThumbId and self.cachedNativeTextureThumbId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.cachedNativeTextureThumbId)
    self.cachedNativeTextureThumbId = 0
  end
  if self.cachedNativeTextureEffectId and self.cachedNativeTextureEffectId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.cachedNativeTextureEffectId)
    self.cachedNativeTextureEffectId = 0
  end
  if self.resizeId_ and self.resizeId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
    self.resizeId_ = nil
  end
  self.cameraData_:ResetMainCameraPhotoData()
end

function Camera_photo_mainView:startAnimatedShow()
  self.node_anim_:PlayOnce("anim_camera_photo_main_open")
end

function Camera_photo_mainView:initWaterMark()
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return
  end
  local shareTableRow = self.camerasysVM_.GetPhotoShareRow()
  if not shareTableRow or shareTableRow.IsSwitchHide == 1 or not self.gotoFuncVM_.FuncIsOn(E.CamerasysFuncIdType.QRCode, true) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_code_mask, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_code_mask, true)
    local imgPath = shareTableRow.QRCode
    if string.zisEmpty(imgPath) then
      imgPath = shareTableRow.PlatformLogo
    end
    self.uiBinder.img_code:SetImage(imgPath)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom_tog, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_game_info, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_info, false)
  self.photoReductionOriSize_ = {width = 0, height = 0}
  self.photoReductionOriSize_.width, self.photoReductionOriSize_.height = self.uiBinder.node_photo_reduction:GetSize(self.photoReductionOriSize_.width, self.photoReductionOriSize_.height)
  self:setPlayerNameAndLevel()
  self:setHead()
end

function Camera_photo_mainView:setPlayerNameAndLevel()
  self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  self.uiBinder.lab_lv.text = Lang("RoleLevelText") .. Z.ContainerMgr.CharSerialize.roleLevel.level
end

function Camera_photo_mainView:setPlayerInfo(isOn)
  self.isShowPlayerInfo_ = isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_info, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.isShowGameInfo_ or self.isShowPlayerInfo_)
  if isOn then
    self:setPlayerNameAndLevel()
    self:setHead()
  end
end

function Camera_photo_mainView:setGameInfo(isOn)
  self.isShowGameInfo_ = isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_game_info, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.isShowGameInfo_ or self.isShowPlayerInfo_)
end

function Camera_photo_mainView:setRawImgSize()
  self.uiBinder.node_photo_reduction:SetSizeDelta(self.designWidth_, self.designHeight_)
end

function Camera_photo_mainView:showOrHideBtnAndBottom(isShow)
  local isFashionState = self.camerasysVM_.CheckIsFashionState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_group_btn, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom_tog, isShow and not isFashionState)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_share, isShow and isFashionState)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.bottom_share, isShow)
end

function Camera_photo_mainView:asyncTakePhoto()
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  local photoWidth, height = self.camerasysVM_.GetTakePhotoSize()
  local rect = self:getScreenshotRect(photoWidth, height)
  local scaleX = photoWidth / self.designWidth_
  local scaleY = height / self.designHeight_
  self.uiBinder.node_player_info:SetScale(scaleX, scaleY)
  self.uiBinder.node_game_info:SetScale(scaleX, scaleY)
  self.resizeId_ = asyncCall(self.curSceenSize_.x, self.curSceenSize_.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri, rect.x, rect.y, photoWidth, height)
  if photoWidth > self.designWidth_ or height > self.designHeight_ then
    self.resizeId_ = Z.LuaBridge.ResizeTextureSizeForAlbum(self.resizeId_, E.NativeTextureCallToken.CamerasysViewOri, self.designWidth_, self.designHeight_)
  end
end

function Camera_photo_mainView:getScreenshotRect(photoWidth, photoHeight)
  local offset = Vector2.New(self.curSceenSize_.x / 2, self.curSceenSize_.y / 2)
  local normalScreenSize = self.designWidth_ / self.designHeight_
  local screenSize = self.curSceenSize_.x / self.curSceenSize_.y
  local rectPosX, rectPosY = 0, 0
  if normalScreenSize <= screenSize then
    rectPosX = -photoWidth / 2 + offset.x
  else
    rectPosY = -photoHeight / 2 + offset.y
  end
  return Vector2.New(rectPosX, rectPosY)
end

function Camera_photo_mainView:generatePhoto()
  self:showOrHideBtnAndBottom(false)
  self:setRawImgSize()
  self:asyncTakePhoto()
  self.uiBinder.node_player_info:SetScale(1, 1)
  self.uiBinder.node_game_info:SetScale(1, 1)
  self:showOrHideBtnAndBottom(true)
  self.uiBinder.node_photo_reduction:SetSizeDelta(self.photoReductionOriSize_.width, self.photoReductionOriSize_.height)
  return self.resizeId_
end

function Camera_photo_mainView:savePhoto()
  local textureId = self.cachedNativeTextureEffectId
  if self.isShowGameInfo_ or self.isShowPlayerInfo_ then
    textureId = self:generatePhoto()
  end
  Z.CameraFrameCtrl:SaveToSystemAlbum(textureId, function(result)
    if result then
      if Z.IsPCUI then
        local albumPath = Z.CameraFrameCtrl:GetPCAlbumPath()
        Z.TipsVM.ShowTipsLang(1000041, {val = albumPath})
      else
        Z.TipsVM.ShowTipsLang(1000036)
      end
      self.camerasysVM_.CloseCameraPhotoMain()
    else
      Z.TipsVM.ShowTipsLang(1000037)
    end
  end)
  if self.resizeId_ then
    Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
    self.resizeId_ = nil
  end
end

function Camera_photo_mainView:setHead()
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVm_.AsyncGetSocialData(0, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
    playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, socialData, nil, self.cancelSource:CreateToken())
  end)()
end

function Camera_photo_mainView:shareImage(shareplatform)
  if self.isShowGameInfo_ or self.isShowPlayerInfo_ then
    self:generatePhoto()
    if self.resizeId_ then
      Z.GameShareManager:ShareImageAutoThumb("", self.resizeId_, shareplatform, "", "")
      Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
      self.resizeId_ = nil
    end
  else
    Z.GameShareManager:ShareImageAutoThumb("", self.cachedNativeTextureEffectId, shareplatform, "", "")
  end
end

return Camera_photo_mainView
