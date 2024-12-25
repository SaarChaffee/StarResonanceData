local super = require("ui.ui_view_base")
local Album_photo_showView = class("Album_photo_showView", super)
local Union_Temp_Album_ID = 0

function Album_photo_showView:ctor()
  self.panel = nil
  self.uiBinder = nil
  super.ctor(self, "album_photo_show")
  self.showPhotoInfo_ = {}
  self.albumMainVM_ = Z.VMMgr.GetVM("album_main")
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.snapshotVM_ = Z.VMMgr.GetVM("snapshot")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
end

function Album_photo_showView:initComp()
  self.close_btn_ = self.uiBinder.btn_close
  self.decorate_btn_ = self.uiBinder.btn_decorate
  self.save_local_btn_ = self.uiBinder.btn_cloud_save
  self.save_cloud_btn_ = self.uiBinder.btn_cloud_local
  self.delete_btn_ = self.uiBinder.btn_delete
  self.anim_node_ = self.uiBinder.anim
  self.rimg_photo_icon_ = self.uiBinder.rimg_photo_icon
  self.desc_lab_ = self.uiBinder.lab_desc
  self.time_lab_ = self.uiBinder.lab_time
  self.rimg_frame_layer_big_ = self.uiBinder.rimg_frame_layer_big
  self.rimg_frame_fill_big_ = self.uiBinder.rimg_frame_fill_big
  self.decorate_node_ = self.uiBinder.node_decorate
  self.scene_mask_ = self.uiBinder.scene_mask
  self.btn_cloud_union_ = self.uiBinder.btn_cloud_union
  self.isShowPlayerInfo_ = false
  self.isShowGameInfo_ = false
  self.scene_mask_:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
  self.uiBinder.tog_char_info:SetIsOnWithoutCallBack(false)
  self.uiBinder.tog_char_info:RemoveAllListeners()
  self.uiBinder.tog_char_info:AddListener(function(isOn)
    self:setPlayerInfo(isOn)
  end)
  self.uiBinder.tog_game_info:SetIsOnWithoutCallBack(false)
  self.uiBinder.tog_game_info:RemoveAllListeners()
  self.uiBinder.tog_game_info:AddListener(function(isOn)
    self:setGameInfo(isOn)
  end)
  self:initWaterMark()
end

function Album_photo_showView:initWaterMark()
  local shareTableRow = self.cameraVM_.GetPhotoShareRow()
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
  
  self:initPlayerInfo()
  self:setHead()
end

function Album_photo_showView:setPlayerInfo(isOn)
  self.isShowPlayerInfo_ = isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_info, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.isShowGameInfo_ or self.isShowPlayerInfo_)
end

function Album_photo_showView:setGameInfo(isOn)
  self.isShowGameInfo_ = isOn
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_game_info, isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, self.isShowGameInfo_ or self.isShowPlayerInfo_)
end

function Album_photo_showView:initBtnClick()
  self:AddClick(self.close_btn_, function()
    Z.UIMgr:CloseView("album_photo_show")
  end)
  
  function self.saveFunc_(effectUrl, effectThemUrl, decorateInfo)
    self.albumMainVM_.ReplacePhotoToTempAlbum(self.showPhotoInfo_.id, effectUrl, effectThemUrl, decorateInfo)
  end
  
  self:AddClick(self.decorate_btn_, function()
    local viewData = {
      albumType = E.AlbumType.Temporary,
      url = self.showPhotoInfo_.tempOriPhoto,
      decorateInfo = self.showPhotoInfo_.decorateData,
      saveFunc = self.saveFunc_
    }
    Z.UIMgr:OpenView("photo_editing", viewData)
  end)
  self:AddClick(self.save_cloud_btn_, function()
    self.albumMainVM_.AlbumUpLoadStart(1)
    self.albumMainData_:AddSelectedAlbumPhoto(self.showPhotoInfo_)
    local viewData = {
      albumOperationType = E.AlbumOperationType.UpLoad,
      albumId = self.showPhotoInfo_.id
    }
    self.albumMainVM_.ShowMobileAlbumView(viewData)
  end)
  self:AddClick(self.delete_btn_, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("ConfirmationDelTemp"), function()
      self.albumMainVM_.DeleteLocalPhoto(self.showPhotoInfo_)
      Z.UIMgr:CloseView("album_photo_show")
      Z.TipsVM.ShowTipsLang(1000008)
      Z.DialogViewDataMgr:CloseDialogView()
      Z.EventMgr:Dispatch(Z.ConstValue.Album.SecondaryEditTempRef)
    end)
  end)
  self:AddAsyncClick(self.btn_cloud_union_, function()
    local unionVM = Z.VMMgr.GetVM("union")
    local unionId = unionVM:GetPlayerUnionId()
    if unionId == 0 then
      logGreen("Union is null!")
    end
    self.albumMainData_:AddSelectedAlbumPhoto(self.showPhotoInfo_)
    self.albumMainVM_.AlbumUpLoadStart(1)
    self.albumMainData_.CurrentUploadSourceType = E.PlatformFuncType.UnionPhoto
    local requestData = self.albumMainVM_.InitUploadPhotoData(self.showPhotoInfo_, Union_Temp_Album_ID, E.PlatformFuncType.UnionPhoto, unionId)
    self.albumMainVM_.AsyncUploadPhotoRequestToken(requestData, self.cancelSource:CreateToken())
    self.albumMainData_.CurrentUploadPhotoCount = 0
    self.albumMainData_.TargetUploadPhotoCount = 1
    self.albumMainData_.UpLoadStateType = E.CameraUpLoadStateType.UpLoading
    self.albumMainVM_.SetIsUploadState(true)
    Z.UIMgr:OpenView("album_storage_tips")
    self:DeActive()
  end)
  self:AddAsyncClick(self.save_local_btn_, function()
    if self.isShowGameInfo_ or self.isShowPlayerInfo_ then
      self:savePhoto()
    elseif Z.CameraFrameCtrl:SaveToSystemAlbum(self.photoId_) then
      if Z.IsPCUI then
        local albumPath = Z.CameraFrameCtrl:GetPCAlbumPath()
        albumPath = string.gsub(albumPath, "/", "\\")
        Z.TipsVM.ShowTipsLang(1000041, {val = albumPath})
      else
        Z.TipsVM.ShowTipsLang(1000036)
      end
    else
      Z.TipsVM.ShowTipsLang(1000037)
    end
  end)
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
end

function Album_photo_showView:savePhoto()
  self:showOrHideBtnAndBottom(false)
  self:setRawImgSize()
  self:asyncTakePhoto()
  self.uiBinder.node_bottom:SetScale(1, 1)
  self:showOrHideBtnAndBottom(true)
  self.uiBinder.node_photo_reduction:SetSizeDelta(self.photoReductionOriSize_.width, self.photoReductionOriSize_.height)
  if self.resizeId_ then
    if Z.CameraFrameCtrl:SaveToSystemAlbum(self.resizeId_) then
      if Z.IsPCUI then
        local albumPath = Z.CameraFrameCtrl:GetPCAlbumPath()
        albumPath = string.gsub(albumPath, "/", "\\")
        Z.TipsVM.ShowTipsLang(1000041, {val = albumPath})
      else
        Z.TipsVM.ShowTipsLang(1000036)
      end
    else
      Z.TipsVM.ShowTipsLang(1000037)
    end
    Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
    self.resizeId_ = nil
  else
    Z.TipsVM.ShowTipsLang(1000037)
  end
end

function Album_photo_showView:setRawImgSize()
  local parentNodeWidth, parentNodeHeight = 0, 0
  parentNodeWidth, parentNodeHeight = self.uiBinder.Trans:GetSize(parentNodeWidth, parentNodeHeight)
  self.uiBinder.node_photo_reduction:SetSizeDelta(parentNodeWidth, parentNodeHeight)
end

function Album_photo_showView:showOrHideBtnAndBottom(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_group_btn, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom_tog, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete, isShow)
  self.uiBinder.Ref:SetVisible(self.close_btn_, isShow)
end

function Album_photo_showView:asyncTakePhoto()
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShot)
  local photoWidth, height = self.cameraVM_.GetTakePhotoSize()
  local scaleX = Z.UIRoot.CurScreenSize.x / photoWidth
  local scaleY = Z.UIRoot.CurScreenSize.y / height
  self.uiBinder.node_bottom:SetScale(scaleX, scaleY)
  local oriId = asyncCall(self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri)
  self.resizeId_ = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysViewOri, photoWidth, height)
end

function Album_photo_showView:OnActive()
  self:initComp()
  self:startAnimatedShow()
  self:initBtnClick()
  self:bindEvents()
  self:bindWatchers()
end

function Album_photo_showView:bindWatchers()
  function self.playerInfoDataFunc_(container, dirtys)
    self:initPlayerInfo()
  end
  
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:RegWatcher(self.playerInfoDataFunc_)
end

function Album_photo_showView:unBindWatchers()
  Z.ContainerMgr.CharSerialize.roleLevel.Watcher:UnregWatcher(self.playerInfoDataFunc_)
end

function Album_photo_showView:initPlayerInfo()
  self.uiBinder.lab_player_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  self.uiBinder.lab_level.text = Lang("RoleLevelText") .. Z.ContainerMgr.CharSerialize.roleLevel.level
end

function Album_photo_showView:setHead()
  Z.CoroUtil.create_coro_xpcall(function()
    local modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
    local modelHead = self.snapshotVM_.GetModelHeadPortrait(modelId)
    self.uiBinder.img_head:SetImage(modelHead)
    self.snapshotVM_.AsyncGetHttpPortraitId(Z.ContainerMgr.CharSerialize.charBase.charId, self.loadHeadCallBack_)
  end)()
end

function Album_photo_showView:OnDeActive()
  self:releaseTextures()
  self:removeEvents()
  self.saveFunc_ = nil
  self.showPhotoInfo_ = {}
  self:unBindWatchers()
  self.playerInfoDataFunc_ = nil
  self.loadHeadCallBack_ = nil
end

function Album_photo_showView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Album.PhotoEditSuccess, self.initView, self)
end

function Album_photo_showView:removeEvents()
  Z.EventMgr:Remove(Z.ConstValue.Album.PhotoEditSuccess, self.initView, self)
end

function Album_photo_showView:OnRefresh()
  self:initView()
end

function Album_photo_showView:initView()
  self:releaseTextures()
  self.showPhotoInfo_ = self.albumMainData_:GetCurrentShowPhotoData()
  if not self.showPhotoInfo_ or not next(self.showPhotoInfo_) then
    logError("Show photo data is empty!")
    return
  end
  self.photoId_ = Z.CameraFrameCtrl:ReadTextureToSystemAlbum(self.showPhotoInfo_.tempPhoto, E.NativeTextureCallToken.album_photo_show_view)
  if self.photoId_ == 0 then
    return
  end
  self.rimg_photo_icon_:SetNativeTexture(self.photoId_)
  local shotPlace = self.albumMainVM_.GetAlbumShotPlaceName(tonumber(self.showPhotoInfo_.shotPlace))
  self.desc_lab_.text = shotPlace
  self.time_lab_.text = self.showPhotoInfo_.shotTimeStr
  self.uiBinder.Ref:SetVisible(self.rimg_frame_layer_big_, false)
  self.uiBinder.Ref:SetVisible(self.rimg_frame_fill_big_, false)
  local isShowUnion = self.albumMainVM_.CheckIsShowUnion()
  self.uiBinder.Ref:SetVisible(self.btn_cloud_union_, isShowUnion)
end

function Album_photo_showView:releaseTextures()
  if self.photoId_ and self.photoId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.photoId_)
    self.photoId_ = 0
  end
  if self.resizeId_ and self.resizeId_ ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.resizeId_)
    self.resizeId_ = nil
  end
end

function Album_photo_showView:startAnimatedShow()
end

function Album_photo_showView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.anim_node_.CoroPlay)
  coro(self.anim_node_, Panda.ZUi.DOTweenAnimType.Close)
end

function Album_photo_showView:OnInputBack()
  if not self.albumMainData_.IsUpLoadState then
    Z.UIMgr:CloseView("album_photo_show")
  end
end

return Album_photo_showView
