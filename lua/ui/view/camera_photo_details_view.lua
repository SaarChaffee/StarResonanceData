local super = require("ui.ui_view_base")
local Camera_photo_detailsView = class("Camera_photo_detailsView", super)
local logoImg = "ui/textures/login/login_logo"
local reportDefine = require("ui.model.report_define")
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Camera_photo_detailsView:ctor()
  self.uiBinder = nil
  super.ctor(self, "camera_photo_details")
  self.camerasysVM_ = Z.VMMgr.GetVM("camerasys")
  self.albumMainVm_ = Z.VMMgr.GetVM("album_main")
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.snapshotVM_ = Z.VMMgr.GetVM("snapshot")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.reportVm_ = Z.VMMgr.GetVM("report")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.showPhotoInfo_ = {}
end

function Camera_photo_detailsView:initWidget()
  self.return_btn_ = self.uiBinder.btn_close
  self.decorate_btn_ = self.uiBinder.btn_decorate
  self.save_cloud_btn_ = self.uiBinder.btn_cloud_local
  self.save_local_btn_ = self.uiBinder.btn_cloud_save
  self.share_cloud_btn_ = self.uiBinder.btn_cloud_share
  self.set_cloud_btn_ = self.uiBinder.btn_cloud_set
  self.delete_btn_ = self.uiBinder.btn_delete
  self.cloud_union_btn_ = self.uiBinder.btn_cloud_union
  self.temp_union_btn_ = self.uiBinder.btn_temp_union
  self.report_btn_ = self.uiBinder.btn_report
  self.uiBinder.rimg_game_name:SetImage(logoImg)
  self.rimg_photo_icon_ = self.uiBinder.rimg_photo_icon
  self.rimg_frame_layer_big_ = self.uiBinder.rimg_frame_layer_big
  self.rimg_frame_fill_big_ = self.uiBinder.rimg_frame_fill_big
  self.node_decorate_ = self.uiBinder.node_decorate
  self.node_anim_ = self.uiBinder.node_anim
  self.desc_lab_ = self.uiBinder.lab_desc
  self.time_lab_ = self.uiBinder.lab_time
end

function Camera_photo_detailsView:OnActive()
  self:initWidget()
  self:startAnimatedShow()
  self:bindEvents()
  self:AddClick(self.return_btn_, function()
    self.albumMainVm_.CloseCameraPhotoDetailsView()
  end)
  
  function self.saveFunc_(effectUrl, effectThumbUrl, decorateInfo)
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("CloudPhotoToTempAlbumCertain"), function()
      self.camerasysVM_.SaveCloudPhotoToTempAlbum(self.photoId_, effectUrl, effectThumbUrl, decorateInfo)
      Z.TipsVM.ShowTipsLang(1000038)
    end)
  end
  
  self:AddClick(self.decorate_btn_, function()
    local viewData = {
      albumType = E.AlbumType.Couldalbum,
      url = self.showPhotoInfo_.originalUrl,
      decorateInfo = self.showPhotoInfo_.renderedInfo,
      saveFunc = self.saveFunc_
    }
    Z.UIMgr:OpenView("photo_editing", viewData)
  end)
  self:AddClick(self.save_cloud_btn_, function()
    self.albumMainData_:AddSelectedAlbumPhoto(self.showPhotoInfo_)
    local viewData = {
      albumOperationType = E.AlbumOperationType.Move,
      albumId = self.showPhotoInfo_.albumId
    }
    self.albumMainVm_.ShowMobileAlbumView(viewData)
  end)
  self:AddAsyncClick(self.save_local_btn_, function()
    if self.isShowGameInfo_ or self.isShowPlayerInfo_ then
      self:savePhoto()
    else
      Z.CameraFrameCtrl:SaveToSystemAlbum(self.photoId_, function(result)
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
      end)
    end
  end)
  self:AddClick(self.share_cloud_btn_, function()
  end)
  self:AddAsyncClick(self.cloud_union_btn_, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.SharePhotoToUnion)
    if not isOn then
      return
    end
    local ret = self.albumMainVm_.AsyncCopySelfPhotoToUnionTmpAlbum(self.showPhotoInfo_.id, self.cancelSource:CreateToken())
    if ret and ret.errCode == 0 then
      Z.TipsVM.ShowTips(1000564, {val1 = 1, val2 = 0})
      Z.UIMgr:CloseView("camera_photo_details")
    else
      Z.TipsVM.ShowTips(1000565)
    end
  end)
  self:AddAsyncClick(self.temp_union_btn_, function()
    self:uploadToUnionAlbum()
  end)
  self:AddAsyncClick(self.report_btn_, function()
    local unionData = Z.DataMgr.Get("union_data")
    self.reportVm_.OpenReportPop(reportDefine.ReportScene.Photo, unionData.UnionInfo.baseInfo.Name, unionData.UnionInfo.baseInfo.Id, {
      photoId = self.showPhotoInfo_.id,
      isUnion = true
    })
  end)
  self:AddAsyncClick(self.set_cloud_btn_, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("SetAlbumcover"), function()
      if self.albumMainVm_.CheckSubTypeIsUnion() then
        self.albumMainVm_.AsyncSetUnionAlbumCover(1, self.showPhotoInfo_.id, self.cancelSource:CreateToken())
      else
        self.albumMainVm_.AsyncSetAlbumCover(self.showPhotoInfo_.albumId, self.showPhotoInfo_.id, self.cancelSource:CreateToken())
      end
    end)
  end)
  self:AddAsyncClick(self.delete_btn_, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("ConfirmationDelCloud"), function()
      self:deletePhoto()
      Z.TipsVM.ShowTipsLang(1000008)
    end)
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
  self:AddAsyncClick(self.uiBinder.btn_qq, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.QQ)
  end)
  self:AddAsyncClick(self.uiBinder.btn_wechat, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.WeChat)
  end)
  self:AddAsyncClick(self.uiBinder.btn_moments, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.WeChatMoment)
  end)
  self:AddAsyncClick(self.uiBinder.btn_apj, function()
    self:shareImage(Bokura.Plugins.Share.SharePlatform.System)
  end)
  self:initShareNode()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.Ref:SetVisible(self.rimg_frame_layer_big_, false)
  self.uiBinder.Ref:SetVisible(self.rimg_frame_fill_big_, false)
  self.isShowPlayerInfo_ = false
  self.isShowGameInfo_ = false
  self:initWaterMark()
end

function Camera_photo_detailsView:initShareNode()
  local isUnlockFunc = self.gotoFuncVM_.FuncIsOn(E.FunctionID.SDKShareCloudPhoto, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, isUnlockFunc and not Z.IsPCUI)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_abroad, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_domestic, false)
  if currentPlatform == E.LoginPlatformType.TencentPlatform then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_abroad, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_domestic, true)
  elseif currentPlatform == E.LoginPlatformType.APJPlatform then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_abroad, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_domestic, false)
  end
end

function Camera_photo_detailsView:deletePhoto()
  local token = self.cancelSource:CreateToken()
  if not self.albumMainVm_.CheckSubTypeIsUnion() then
    self.albumMainVm_.AsyncDeleteServePhoto(self.showPhotoInfo_, token)
    Z.UIMgr:CloseView("camera_photo_details")
    return
  end
  if self.albumMainData_.ContainerType == E.AlbumMainState.UnionTemporary then
    self.albumMainVm_.AsyncDeleteUnionTmpPhoto(self.showPhotoInfo_.id, token)
  else
    self.albumMainVm_.AsyncDeleteUnionPhoto(self.showPhotoInfo_.id, token)
  end
  Z.UIMgr:CloseView("camera_photo_details")
end

function Camera_photo_detailsView:bindWatchers()
  function self.playerInfoDataFunc_(container, dirtys)
    self.uiBinder.lab_level.text = Lang("RoleLevelText") .. Z.ContainerMgr.CharSerialize.roleLevel.level
  end
  
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.playerInfoDataFunc_)
end

function Camera_photo_detailsView:unBindWatchers()
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:UnregWatcher(self.playerInfoDataFunc_)
end

function Camera_photo_detailsView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.AlbumDataUpdate, self.initView, self)
end

function Camera_photo_detailsView:removeEvents()
  Z.EventMgr:Remove(Z.ConstValue.Album.AlbumDataUpdate, self.initView, self)
end

function Camera_photo_detailsView:OnDeActive()
  self.saveFunc_ = nil
  self:clearCachePhoto()
  self:removeEvents()
  self:unBindWatchers()
  self.playerInfoDataFunc_ = nil
end

function Camera_photo_detailsView:OnRefresh()
  self:initView()
end

function Camera_photo_detailsView:initView(uploadPhotoData)
  self.showPhotoInfo_ = self.albumMainData_:GetCurrentShowPhotoData()
  if not self.showPhotoInfo_ or not next(self.showPhotoInfo_) then
    logError("Cloud photo data is empty!")
    return
  end
  self.albumMainVm_.RefreshCloudAlbumShowCache(uploadPhotoData)
  self:refreshPhotoData(self.showPhotoInfo_)
  if self.albumMainVm_.CheckSubTypeIsUnion() then
    self:setUnionPlayerOperation()
  end
  local isShowUnion = self.albumMainVm_.CheckIsShowUnion()
  self.uiBinder.Ref:SetVisible(self.cloud_union_btn_, isShowUnion and self.albumMainData_.ContainerType == E.AlbumMainState.Couldalbum)
  self.uiBinder.Ref:SetVisible(self.temp_union_btn_, isShowUnion and self.albumMainData_.ContainerType == E.AlbumMainState.UnionTemporary)
  self:setImageAuditStatus()
  self.uiBinder.Ref:SetVisible(self.report_btn_, isShowUnion and self.albumMainData_.ContainerType == E.AlbumMainState.UnionCloud and self.reportVm_.IsReportOpen(true))
end

function Camera_photo_detailsView:setUnionPlayerOperation()
  self.uiBinder.Ref:SetVisible(self.decorate_btn_, false)
  self.uiBinder.Ref:SetVisible(self.share_cloud_btn_, false)
  local haveAuthority = self.albumMainVm_.CheckUnionPlayerPower(E.UnionPowerDef.EditAlbum)
  self.uiBinder.Ref:SetVisible(self.cloud_union_btn_, self.albumMainData_.ContainerType == E.AlbumMainState.UnionTemporary and haveAuthority)
  self.uiBinder.Ref:SetVisible(self.set_cloud_btn_, self.albumMainData_.ContainerType == E.AlbumMainState.UnionCloud and haveAuthority)
  self.uiBinder.Ref:SetVisible(self.delete_btn_, haveAuthority)
end

function Camera_photo_detailsView:showMobileAlbum(data)
  self.albumMainVm_.ShowMobileAlbumView(data)
end

function Camera_photo_detailsView:clearCachePhoto()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
end

function Camera_photo_detailsView:refreshPhotoData(photoData)
  self:httpPhotoGet(photoData)
  self.time_lab_.text = photoData.shotTimeStr
  local shotPlace = self.albumMainVm_.GetAlbumShotPlaceName(tonumber(photoData.shotPlaceStr))
  self.desc_lab_.text = shotPlace
end

function Camera_photo_detailsView:httpPhotoGet(photoData)
  self:clearCachePhoto()
  self.albumMainVm_.AsyncGetHttpAlbumPhoto(photoData.renderedUrl, E.PictureType.ECameraRender, E.NativeTextureCallToken.album_photo_details_view, self.cancelSource, self.OnCallback, self)
end

function Camera_photo_detailsView:OnCallback(photoId)
  self:releaseNativeTextures()
  self.photoId_ = photoId
  self.rimg_photo_icon_:SetNativeTexture(photoId)
end

function Camera_photo_detailsView:releaseNativeTextures()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
  if self.resizeId_ and self.resizeId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
    self.resizeId_ = nil
  end
end

function Camera_photo_detailsView:startAnimatedShow()
  self.node_anim_:Restart(Z.DOTweenAnimType.Open)
end

function Camera_photo_detailsView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.node_anim_.CoroPlay)
  coro(self.node_anim_, Panda.ZUi.DOTweenAnimType.Close)
end

function Camera_photo_detailsView:uploadToUnionAlbum()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.SharePhotoToUnion)
  if not isOn then
    return
  end
  self.albumMainData_:AddSelectedAlbumPhoto(self.showPhotoInfo_)
  local selectedNum = self.albumMainData_:GetSelectedAlbumNumber()
  if selectedNum <= 0 then
    Z.TipsVM.ShowTipsLang(1000027)
    return
  end
  Z.VMMgr.GetVM("album_main").AlbumUpLoadStart(selectedNum)
  local eventData = {}
  eventData.albumOperationType = E.AlbumOperationType.UnionMove
  self.albumMainVm_.ShowMobileAlbumView(eventData)
end

function Camera_photo_detailsView:setImageAuditStatus()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_state_other, false)
  if self.showPhotoInfo_.reviewStartTime then
    if self.showPhotoInfo_.reviewStartTime == E.PictureReviewType.Fail then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_state_self, true)
      self.uiBinder.img_state_self:SetImage(Z.ConstValue.Photo.StateReviewFailed)
      self.uiBinder.lab_state_self.text = Lang("ReviewFailed")
    elseif self.showPhotoInfo_.reviewStartTime == E.PictureReviewType.Reviewing then
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_state_self, true)
      self.uiBinder.img_state_self:SetImage(Z.ConstValue.Photo.StateInReview)
      self.uiBinder.lab_state_self.text = Lang("InReview")
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_state_self, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_state_self, false)
  end
end

function Camera_photo_detailsView:initWaterMark()
  local shareTableRow = self.camerasysVM_.GetPhotoShareRow()
  if not (self.albumMainData_.ContainerType ~= E.AlbumMainState.UnionTemporary and self.albumMainData_.ContainerType ~= E.AlbumMainState.UnionCloud and shareTableRow) or shareTableRow.IsSwitchHide == 1 or not self.gotoFuncVM_.FuncIsOn(E.CamerasysFuncIdType.QRCode, true) then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_code_mask, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_code_mask, true)
    local imgPath = shareTableRow.QRCode
    if string.zisEmpty(imgPath) then
      imgPath = shareTableRow.PlatformLogo
    end
    self.uiBinder.img_code:SetImage(imgPath)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_place, not self.isShowGameInfo_ and not self.isShowPlayerInfo_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom_tog, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_game_info, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_info, false)
  self.photoReductionOriSize_ = {width = 0, height = 0}
  self.photoReductionOriSize_.width, self.photoReductionOriSize_.height = self.uiBinder.node_photo_reduction:GetSize(self.photoReductionOriSize_.width, self.photoReductionOriSize_.height)
  self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  self.uiBinder.lab_level.text = Lang("RoleLevelText") .. Z.ContainerMgr.CharSerialize.roleLevel.level
  self:setHead()
end

function Camera_photo_detailsView:setPlayerNameAndLevel()
  self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  self.uiBinder.lab_level.text = Lang("RoleLevelText") .. Z.ContainerMgr.CharSerialize.roleLevel.level
end

function Camera_photo_detailsView:setPlayerInfo(isOn)
  self.isShowPlayerInfo_ = isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_info, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.isShowGameInfo_ or self.isShowPlayerInfo_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_place, not self.isShowGameInfo_ and not self.isShowPlayerInfo_)
end

function Camera_photo_detailsView:setGameInfo(isOn)
  self.isShowGameInfo_ = isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_game_info, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.isShowGameInfo_ or self.isShowPlayerInfo_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_place, not self.isShowGameInfo_ and not self.isShowPlayerInfo_)
end

function Camera_photo_detailsView:setRawImgSize()
  self.uiBinder.node_photo_reduction:SetSizeDelta(Z.UIRoot.CurCanvasSize.x, Z.UIRoot.CurCanvasSize.y)
end

function Camera_photo_detailsView:showOrHideBtnAndBottom(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_group_btn, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom_tog, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.bottom_share, isShow)
end

function Camera_photo_detailsView:asyncTakePhoto()
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShot)
  local photoWidth, height = self.cameraVM_.GetTakePhotoSize()
  local scaleX = Z.UIRoot.CurScreenSize.x / photoWidth
  local scaleY = Z.UIRoot.CurScreenSize.y / height
  self.uiBinder.node_player_info:SetScale(scaleX, scaleY)
  self.uiBinder.node_game_info:SetScale(scaleX, scaleY)
  local oriId = asyncCall(self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri)
  self.resizeId_ = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysViewOri, photoWidth, height)
end

function Camera_photo_detailsView:generatePhoto()
  self:showOrHideBtnAndBottom(false)
  self:setRawImgSize()
  self:asyncTakePhoto()
  self.uiBinder.node_player_info:SetScale(1, 1)
  self.uiBinder.node_game_info:SetScale(1, 1)
  self:showOrHideBtnAndBottom(true)
  self.uiBinder.node_photo_reduction:SetSizeDelta(self.photoReductionOriSize_.width, self.photoReductionOriSize_.height)
end

function Camera_photo_detailsView:savePhoto()
  self:generatePhoto()
  if self.resizeId_ then
    Z.CameraFrameCtrl:SaveToSystemAlbum(self.resizeId_, function(result)
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
    end)
    Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
    self.resizeId_ = nil
  else
    Z.TipsVM.ShowTipsLang(1000037)
  end
end

function Camera_photo_detailsView:shareImage(shareplatform)
  if self.isShowGameInfo_ or self.isShowPlayerInfo_ then
    self:generatePhoto()
    if self.resizeId_ then
      Z.GameShareManager:ShareImageAutoThumb("", self.resizeId_, shareplatform, "", "")
      Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
      self.resizeId_ = nil
    end
  else
    Z.GameShareManager:ShareImageAutoThumb("", self.photoId_, shareplatform, "", "")
  end
end

function Camera_photo_detailsView:setHead()
  Z.CoroUtil.create_coro_xpcall(function()
    local socialData = self.socialVm_.AsyncGetSocialData(0, Z.ContainerMgr.CharSerialize.charId, self.cancelSource:CreateToken())
    playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, socialData, nil, self.cancelSource:CreateToken())
  end)()
end

return Camera_photo_detailsView
