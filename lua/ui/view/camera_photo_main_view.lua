local super = require("ui.ui_view_base")
local Camera_photo_mainView = class("Camera_photo_mainView", super)

function Camera_photo_mainView:ctor(parent)
  self.panel = nil
  self.uiBinder = nil
  super.ctor(self, "camera_photo_main")
  self.camerasysVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.snapshotVM_ = Z.VMMgr.GetVM("snapshot")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
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
    elseif self:savePhotograph() then
      if Z.IsPCUI then
        local albumPath = Z.CameraFrameCtrl:GetPCAlbumPath()
        albumPath = string.gsub(albumPath, "/", "\\")
        Z.TipsVM.ShowTipsLang(1000041, {val = albumPath})
      else
        Z.TipsVM.ShowTipsLang(1000036)
      end
      self.camerasysVM_.CloseCameraPhotoMain()
    else
      Z.TipsVM.ShowTipsLang(1000037)
    end
  end)
  self:AddClick(self.btn_share_, function()
    Z.TipsVM.ShowTipsLang(130004)
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
  self:initWaterMark()
end

function Camera_photo_mainView:OnActive()
  self.cameraData_.IsBlockTakePhotoAction = true
  self:intiComp()
  self:initBtnClick()
  self:startAnimatedShow()
  self:bindWatchers()
  self.scene_mask_:SetSceneMaskByKey(self.SceneMaskKey)
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
  self.loadHeadCallBack_ = nil
  self.cameraData_.IsBlockTakePhotoAction = false
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

function Camera_photo_mainView:savePhotograph()
  return Z.CameraFrameCtrl:SaveToSystemAlbum(self.cachedNativeTextureEffectId)
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
  
  function self.loadHeadCallBack_(charId, textureId)
    if textureId == 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_head, false)
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_head, true)
    self.uiBinder.rimg_head:SetNativeTexture(textureId)
  end
  
  self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  self.uiBinder.lab_lv.text = Lang("RoleLevelText") .. Z.ContainerMgr.CharSerialize.roleLevel.level
  self:setHead()
end

function Camera_photo_mainView:setPlayerInfo(isOn)
  self.isShowPlayerInfo_ = isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_info, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.isShowGameInfo_ or self.isShowPlayerInfo_)
end

function Camera_photo_mainView:setGameInfo(isOn)
  self.isShowGameInfo_ = isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_game_info, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.isShowGameInfo_ or self.isShowPlayerInfo_)
end

function Camera_photo_mainView:setRawImgSize()
  local parentNodeWidth, parentNodeHeight = 0, 0
  parentNodeWidth, parentNodeHeight = self.uiBinder.Trans:GetSize(parentNodeWidth, parentNodeHeight)
  self.uiBinder.node_photo_reduction:SetSizeDelta(parentNodeWidth, parentNodeHeight)
end

function Camera_photo_mainView:showOrHideBtnAndBottom(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_group_btn, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom_tog, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, isShow)
end

function Camera_photo_mainView:asyncTakePhoto()
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShot)
  local photoWidth, height = self.camerasysVM_.GetTakePhotoSize()
  local scaleX = Z.UIRoot.CurScreenSize.x / photoWidth
  local scaleY = Z.UIRoot.CurScreenSize.y / height
  self.uiBinder.node_bottom:SetScale(scaleX, scaleY)
  local oriId = asyncCall(self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri)
  self.resizeId_ = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysViewOri, photoWidth, height)
end

function Camera_photo_mainView:savePhoto()
  local textureId = self.cachedNativeTextureEffectId
  if self.isShowGameInfo_ or self.isShowPlayerInfo_ then
    self:showOrHideBtnAndBottom(false)
    self:setRawImgSize()
    self:asyncTakePhoto()
    self.uiBinder.node_bottom:SetScale(1, 1)
    self:showOrHideBtnAndBottom(true)
    self.uiBinder.node_photo_reduction:SetSizeDelta(self.photoReductionOriSize_.width, self.photoReductionOriSize_.height)
    textureId = self.resizeId_
  end
  if Z.CameraFrameCtrl:SaveToSystemAlbum(textureId) then
    if Z.IsPCUI then
      local albumPath = Z.CameraFrameCtrl:GetPCAlbumPath()
      albumPath = string.gsub(albumPath, "/", "\\")
      Z.TipsVM.ShowTipsLang(1000041, {val = albumPath})
    else
      Z.TipsVM.ShowTipsLang(1000036)
    end
    self.camerasysVM_.CloseCameraPhotoMain()
  else
    Z.TipsVM.ShowTipsLang(1000037)
  end
  if self.resizeId_ then
    Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
    self.resizeId_ = nil
  end
end

function Camera_photo_mainView:setHead()
  Z.CoroUtil.create_coro_xpcall(function()
    local modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
    local modelHead = self.snapshotVM_.GetModelHeadPortrait(modelId)
    self.uiBinder.img_head:SetImage(modelHead)
    self.snapshotVM_.AsyncGetHttpPortraitId(Z.ContainerMgr.CharSerialize.charBase.charId, self.loadHeadCallBack_)
  end)()
end

return Camera_photo_mainView
