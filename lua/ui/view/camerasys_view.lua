local super = require("ui.ui_view_base")
local CamerasysView = class("CamerasysView", super)
local cameraData = Z.DataMgr.Get("camerasys_data")
local albumMainData = Z.DataMgr.Get("album_main_data")
local bigFilterPath = "ui/textures/photograph/"
local decorateData = Z.DataMgr.Get("decorate_add_data")
local CameraViewHideType = {All = 0, ShotHideControlUi = 1}
local PHOTO_SIZE = {
  ThumbSize = {Width = 512, Height = 288},
  HeadSize = {Width = 300, Height = 300},
  BodySize = {Width = 468, Height = 774}
}

function CamerasysView:ctor()
  self.uiBinder = nil
  super.ctor(self, "camerasys", nil)
  self.settingSubView_ = require("ui/view/camerasys_right_sub_mobile_view").new(self)
  self.joystickView_ = require("ui/view/zjoystick_view").new()
  self.decorateAddView_ = require("ui/view/decorate_add_view").new(self)
  self.fighterBtnView_ = require("ui/view/fighterbtns_view").new(self)
  self.blessingSubView_ = require("ui/view/camera_blessing_sub_view").new(self)
  self.cameraActionSlider_ = require("ui/view/camera_action_slider_view").new(self)
  self.posInfoList_ = {}
  self.photoTaskId_ = 0
  self.decorateModelFuncId_ = 102013
  self.isUpdateAnimSlider_ = false
  self.switchVM_ = Z.VMMgr.GetVM("switch")
  self.cameraVm = Z.VMMgr.GetVM("camerasys")
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.viewNodeIsShow_ = true
  self.cameraTypeActiveTog_ = nil
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.faceVM_ = Z.VMMgr.GetVM("face")
end

function CamerasysView:OnActive()
  Z.AudioMgr:Play("UI_Button_Camera")
  self.viewNodeIsShow_ = true
  self.IsPreFaceMode_ = Z.IsPreFaceMode
  self.isFashionState_ = self.cameraVm.CheckIsFashionState()
  self.cloudGameShareContent_ = self.viewData
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2884640, true)
  self.isSkillIgnore_ = true
  self.isTogIgnore_ = false
  self.isPlayerBloodBarIgnore_ = false
  self.isUnRealSceneIgnore_ = false
  self.tempAngle_ = cameraData:GetCameraAngleRange()
  Z.UnrealSceneMgr:ShowUnrealScene()
  if cameraData.IsOfficialPhotoTask then
    self:Hide()
    self.timerMgr:StartTimer(function()
      self:Show()
      self:setNodeVisible(true, CameraViewHideType.ShotHideControlUi)
    end, Z.Global.PhotoCameraChangeTime, 1)
  else
    self:Show()
  end
  Z.CameraFrameCtrl:RecordCameraInitialParameters()
  self.rotationOffset_ = 0
  self:bindEvents()
  self:initView()
  self:initBtn()
  self:addListenerPhotoShow()
  self:addListenerFuncBtn()
  self:addListenerCameraPatternTog()
  self:addListenerFovSlider()
  self:checkPhotoTask()
  self.cameraMemberData_:SetSelectMemberCharId(Z.ContainerMgr.CharSerialize.charId)
  self.isChangeScheme_ = false
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncSetPersonalState(E.PersonalizationStatus.EStatusPhoto, false)
  end)()
  self:bindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt and Z.EntityMgr.PlayerEnt.Model then
    Z.ModelHelper.SetLookAtIKParam(Z.EntityMgr.PlayerEnt.Model, 1)
    Z.EntityMgr.PlayerEnt.Model:SetLuaAttrLookAtEyeOpen(true)
    if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
      local keyName = "cameraFocusBody"
      if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
        keyName = "cameraFocusHead"
      end
      local modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
      local modelOffset = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(modelId)
      local modelPinchHeight = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelPinchHeight).Value
      local heightOffset = self.cameraVm.GetHeightOffSet(modelPinchHeight)
      Z.UnrealSceneMgr:DoCameraAnimLookAtOffset(keyName, Vector3.New(modelOffset.x, modelOffset.y + heightOffset, 0))
      self:calculateUnionMaskDragLimit()
    end
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:initCameraMember()
  end)()
end

function CamerasysView:initCameraMember()
  if cameraData.IsOfficialPhotoTask or cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return
  end
  Z.CameraFrameCtrl:SetEntityShow(E.CameraSystemShowEntityType.CameraTeamMember, false)
  cameraData.IsHideCameraMember = true
  local socialVM = Z.VMMgr.GetVM("social")
  local myCharId = Z.ContainerMgr.CharSerialize.charId
  local mySocialData = socialVM.AsyncGetHeadAndHeadFrameInfo(myCharId, self.cancelSource:CreateToken())
  self.cameraMemberVM_:AddMemberToList(myCharId, mySocialData, true)
  self.uiBinder.lab_switch_name.text = mySocialData.basicData.name
  self.cameraVm.InitSelfLookAtCamera()
  local memberListData = self.cameraMemberVM_:GetLocalMemberListData()
  if not memberListData then
    return
  end
  for k, v in pairs(memberListData) do
    local socialData = socialVM.AsyncGetHeadAndHeadFrameInfo(v, self.cancelSource:CreateToken())
    self.cameraMemberVM_:AddMemberToList(v, socialData)
  end
  if table.zcount(memberListData) > 0 then
    self.blessingSubView_:Active(nil, self.uiBinder.node_left_info)
    self:setLeftNodeIsShow(false)
  end
end

function CamerasysView:calculateUnionMaskDragLimit()
  local headTrans = self.uiBinder.trans_body_mask
  if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
    headTrans = self.uiBinder.trans_head_mask
  end
  self.unionDragLimitMax_ = Vector2.New(headTrans.rect.width * 0.5, headTrans.rect.height * 0.5)
  self.unionDragLimitMin_ = Vector2.New(-headTrans.rect.width * 0.5, -headTrans.rect.height * 0.5)
end

function CamerasysView:initView()
  local isUnionTakePhotoState = cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto
  self.decorateAddView_:Active(nil, self.uiBinder.node_decorate)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, false)
  if not isUnionTakePhotoState then
    self.joystickView_:Active(nil, self.uiBinder.node_joystick)
  end
  if self.isFashionState_ then
    self:calculateUnionMaskDragLimit()
  end
  if cameraData.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto then
    self.fighterBtnView_:Active(nil, self.uiBinder.node_joystick)
    self.fighterBtnView_:SetPlayerStateNodeIsShow(false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_action_slider, false)
  Z.IgnoreMgr:SetBattleUIIgnore(Panda.ZGame.EBattleUIMask.Blood, true, Panda.ZGame.EIgnoreMaskSource.EUIView)
  self.isPlayerBloodBarIgnore_ = true
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_lens_rotation, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_decorate, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photograph_frame, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_joystick, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shot, not self.isFashionState_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, not self.isFashionState_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rayimg_btn, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  self.uiBinder.slider_angle.value = self.cameraVm.GetRangePerc(self.tempAngle_, true)
  self.uiBinder.slider_angle:AddListener(function(value)
    self.tempAngle_.value = self.cameraVm.GetRangeValue(value, self.tempAngle_)
    Z.CameraFrameCtrl:SetAngle(self.tempAngle_.value)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_rotation, cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
  if cameraData.HeadImgOriSize then
    self.uiBinder.rimg_frame_head:SetSizeDelta(cameraData.HeadImgOriSize.x, cameraData.HeadImgOriSize.y)
  end
  if cameraData.BodyImgOriSize then
    self.uiBinder.rimg_frame_systemic:SetSizeDelta(cameraData.BodyImgOriSize.x, cameraData.BodyImgOriSize.y)
  end
  if cameraData.HeadImgOriPos then
    self.uiBinder.rimg_frame_head.anchoredPosition = cameraData.HeadImgOriPos
  end
  if cameraData.BodyImgOriPos then
    self.uiBinder.rimg_frame_systemic.anchoredPosition = cameraData.BodyImgOriPos
  end
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    local zoomRange = Z.Global.Photograph_BusinessCardCameraOffsetRangeA
    if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
      zoomRange = Z.Global.Photograph_BusinessCardCameraOffsetRangeB
    end
    Z.UnrealSceneMgr:InitSceneCamera(true)
    Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(zoomRange[1], zoomRange[2])
    self.unionBgGO_ = Z.UnrealSceneMgr:GetGOByBinderName("UnionBg")
    self.unionBgGO_:SetActive(true)
    self.unrealSkyBoxGo_ = Z.UnrealSceneMgr:GetGOByBinderName("skyBox")
    self.unrealSkyBoxGo_:SetActive(false)
    Z.CameraFrameCtrl:SetUnionCameraBgTile(self.unionBgGO_)
    local unionBgCfg = cameraData:GetUnionBgCfg()
    if unionBgCfg then
      Z.CameraFrameCtrl:SetGOTexture(self.unionBgGO_, unionBgCfg[1].Res)
    end
    if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Fashion then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_generate_qr_code, not self.IsPreFaceMode_)
      self:initFaceModel()
    else
      self:createPlayerModel()
    end
  end
  local sliderViewData = {
    OpenSourceType = E.ExpressionOpenSourceType.Camera
  }
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    sliderViewData.ZModel = self.playerModel_
  end
  self.cameraActionSlider_:Active(sliderViewData, self.uiBinder.node_action_slider)
end

function CamerasysView:createPlayerModel()
  Z.CoroUtil.create_coro_xpcall(function()
    self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
      model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
      model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
      Z.UIMgr:FadeOut()
    end, nil, false)
  end)()
end

function CamerasysView:initBtn()
  self.uiBinder.head_event_trigger_drag.onDrag:RemoveAllListeners()
  self.uiBinder.head_event_trigger_drag.onDrag:AddListener(function(go, eventData)
    self:onHeadLookAtImageDrag(eventData)
  end)
  self.uiBinder.eyes_event_trigger_drag.onDrag:RemoveAllListeners()
  self.uiBinder.eyes_event_trigger_drag.onDrag:AddListener(function(go, eventData)
    self:onEyesLookAtImageDrag(eventData)
  end)
  self.uiBinder.head_event_trigger_drag.onEndDrag:RemoveAllListeners()
  self.uiBinder.head_event_trigger_drag.onEndDrag:AddListener(function(go, eventData)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_face_frame, false)
  end)
  self.uiBinder.eyes_event_trigger_drag.onEndDrag:RemoveAllListeners()
  self.uiBinder.eyes_event_trigger_drag.onEndDrag:AddListener(function(go, eventData)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_face_frame, false)
  end)
  self:AddClick(self.uiBinder.btn_album_entrance, function()
    Z.UIMgr:OpenView("album_main", E.AlbumOpenSource.Album)
  end)
  self.uiBinder.tog_btn_hide_hud:AddListener(function(isOn)
    self:setNodeVisible(not isOn, CameraViewHideType.All)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, not isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_btn_show_hud, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_btn_hide_btn, not isOn)
    if isOn then
      self.uiBinder.Ref:SetVisible(self.uiBinder.rayimg_btn, true)
    end
  end)
  self.uiBinder.tog_ignore:AddListener(function(isOn)
    self:setPlayerMoveIgnore(isOn)
  end)
  self.uiBinder.tog_ignore:SetIsOnWithoutCallBack(self.isTogIgnore_)
  self:AddClick(self.uiBinder.rayimg_btn, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shot, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_btn_show_hud, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rayimg_btn, false)
  end)
  self.uiBinder.event_trigger_frame_systemic.onBeginDrag:AddListener(function(go, pointerData)
    self:calculateUnionMaskDragLimit()
  end)
  self.uiBinder.event_trigger_frame_head.onBeginDrag:AddListener(function(go, pointerData)
    self:calculateUnionMaskDragLimit()
  end)
  self.uiBinder.event_trigger_frame_systemic.onDrag:AddListener(function(go, pointerData)
    self:unionImgMove(self.uiBinder.img_body_mask, self.uiBinder.rimg_frame_systemic, pointerData)
  end)
  self.uiBinder.event_trigger_frame_head.onDrag:AddListener(function(go, pointerData)
    self:unionImgMove(self.uiBinder.img_head_mask, self.uiBinder.rimg_frame_head, pointerData)
  end)
  self:AddClick(self.uiBinder.btn_switch, function()
    self.blessingSubView_:Active(nil, self.uiBinder.node_left_info)
    self:setLeftNodeIsShow(false)
  end)
  self:AddClick(self.uiBinder.btn_picture_sharing, function()
    self:takePhoto()
  end)
  self:AddClick(self.uiBinder.btn_generate_qr_code, function()
    if string.zisEmpty(self.cloudGameShareContent_) then
      return
    end
    Z.LuaBridge.SystemCopy(self.cloudGameShareContent_)
    Z.TipsVM.ShowTips(120016)
  end)
end

function CamerasysView:setLeftNodeIsShow(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_left, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_mobile, isShow)
end

function CamerasysView:setPlayerMoveIgnore(isOn)
  if cameraData.IsOfficialPhotoTask then
    return
  end
  self.isTogIgnore_ = isOn
  local canShowByCameraPattern = cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.CameraPatternType == E.TakePhotoSate.Battle
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, isOn and canShowByCameraPattern)
  self.uiBinder.Ref:SetVisible(self.uiBinder.slider_angle, isOn and canShowByCameraPattern)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_joystick, not isOn)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 25165848, isOn)
end

function CamerasysView:unionImgMove(maskImg, moveNode, pointerData)
  local pos = moveNode.anchoredPosition
  local movePosX = pos.x + pointerData.delta.x
  local movePosY = pos.y + pointerData.delta.y
  local moveNodeWidth, moveNodeHeight = 0, 0
  moveNodeWidth, moveNodeHeight = moveNode:GetSize(moveNodeWidth, moveNodeHeight)
  local posX, posY = self.cameraVm.UnionClipPositionKeepBounds(movePosX, movePosY, self.unionDragLimitMax_, self.unionDragLimitMin_, moveNodeWidth, moveNodeHeight)
  moveNode:SetAnchorPosition(posX, posY)
  self:setImgAreaClip(maskImg, moveNode)
end

function CamerasysView:addListenerPhotoShow()
  self:AddClick(self.uiBinder.btn_shot, function()
    self:takePhoto()
  end)
  self:AddClick(self.uiBinder.cont_camera_btn_return, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
end

function CamerasysView:takePhoto()
  local focusViewConfigKey = Z.UIMgr:GetFocusViewConfigKey()
  if focusViewConfigKey == nil or focusViewConfigKey ~= self.viewConfigKey then
    return
  end
  self:setNodeVisible(false, CameraViewHideType.All)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
  self:hideButtonsWhenTakingPhotos(false)
  Z.UIRoot:SetClickEffectIsShow(false)
  self.cameraVm.ShowOrHideNoticePopView(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_camera_btn_return, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_unlock_bg, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shot, false)
  Z.CoroUtil.create_coro_xpcall(function()
    local oriId = self:asyncTakePhoto()
    if not oriId or oriId == 0 then
      self:resetUI()
      return
    end
    if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
      if cameraData.UnrealSceneModeSubType ~= E.UnionCameraSubType.Fashion then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, false)
        self:handleUnrealScene(oriId)
      else
        self:setBlessingViewIsShow(false)
        self:handleFashion(oriId)
        self:setBlessingViewIsShow(true)
      end
    else
      self:setBlessingViewIsShow(false)
      self:handleNormalScene(oriId)
      self:setBlessingViewIsShow(true)
    end
    self:resetUI()
  end)()
  if self:shouldFinishPhotoTask() then
    self:executePhotoTaskCompletion()
  end
  self:trackCameraPattern()
  self:setMultiPlayerPhotoTargetFinish()
end

function CamerasysView:setMultiPlayerPhotoTargetFinish()
  local memberDatas = self.cameraMemberData_:AssemblyMemberListData(true)
  local memberCnt = table.zcount(memberDatas)
  if 1 < memberCnt then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.TargetMultiPlayerPhoto, memberCnt)
  end
end

function CamerasysView:asyncTakePhoto()
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return self:asyncTakePhotoByRect()
  else
    self.cameraVm.SendShotTLog()
    return self:asyncGetOriPhoto()
  end
end

function CamerasysView:handleUnrealScene(oriId)
  local imgData = {}
  if not oriId or oriId == 0 then
    return
  end
  local isBody = cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Body
  local width = isBody and PHOTO_SIZE.BodySize.Width or PHOTO_SIZE.HeadSize.Width
  local height = isBody and PHOTO_SIZE.BodySize.Height or PHOTO_SIZE.HeadSize.Height
  local resizePhotoId = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysView, width, height)
  imgData.snapType = isBody and E.PictureType.EProfileHalfBody or E.PictureType.EProfileSnapShot
  imgData.textureId = resizePhotoId
  if isBody then
    self.cameraVm.OpenIdCardView(self.cancelSource:CreateToken(), imgData)
  else
    self.cameraVm.OpenHeadView(imgData)
  end
  Z.LuaBridge.ReleaseScreenShot(oriId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, true)
end

function CamerasysView:handleFashion(oriId)
  local imgData = {}
  if not oriId or oriId == 0 then
    return
  end
  local width = PHOTO_SIZE.BodySize.Width
  local height = PHOTO_SIZE.BodySize.Height
  local resizePhotoId = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysView, width, height)
  imgData.snapType = E.PictureType.EProfileHalfBody
  imgData.textureId = resizePhotoId
  imgData.shareCode = self.cloudGameShareContent_
  local viewConfigKey = self.IsPreFaceMode_ and "camera_cloud_game_share" or "camera_cloud_game_share_code_window"
  Z.UIMgr:OpenView(viewConfigKey, imgData)
  Z.LuaBridge.ReleaseScreenShot(oriId)
end

function CamerasysView:handleNormalScene(oriId)
  local photoWidth, photoHeight = self.cameraVm.GetTakePhotoSize()
  local rect = self:getScreenshotRect(photoWidth, photoHeight)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  local effectId = asyncCall(Z.UIRoot.CurScreenSize.x, Z.UIRoot.CurScreenSize.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysView, rect.x, rect.y, photoWidth, photoHeight)
  if photoWidth > Z.UIRoot.DESIGNSIZE_WIDTH or photoHeight > Z.UIRoot.DESIGNSIZE_HEIGHT then
    oriId, effectId = self:getResizeTexture(oriId, effectId)
  end
  local thumbId = Z.LuaBridge.ResizeTextureSizeForAlbum(effectId, E.NativeTextureCallToken.CamerasysView, PHOTO_SIZE.ThumbSize.Width, PHOTO_SIZE.ThumbSize.Height)
  cameraData:SetMainCameraPhotoData(oriId, effectId, thumbId)
  self.cameraVm.OpenCameraPhotoMain(self.cloudGameShareContent_)
end

function CamerasysView:getResizeTexture(oriId, effectId, photoWidth, photoHeight)
  local designWidth = Z.UIRoot.DESIGNSIZE_WIDTH
  local designHeight = Z.UIRoot.DESIGNSIZE_HEIGHT
  local resizeOriId = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysView, designWidth, designHeight)
  local resizeEffectId = Z.LuaBridge.ResizeTextureSizeForAlbum(effectId, E.NativeTextureCallToken.CamerasysView, designWidth, designHeight)
  Z.LuaBridge.ReleaseScreenShot(oriId)
  Z.LuaBridge.ReleaseScreenShot(effectId)
  return resizeOriId, resizeEffectId
end

function CamerasysView:getScreenshotRect(photoWidth, photoHeight)
  local offset = Vector2.New(Z.UIRoot.CurScreenSize.x / 2, Z.UIRoot.CurScreenSize.y / 2)
  local normalScreenSize = Z.UIRoot.DESIGNSIZE_WIDTH / Z.UIRoot.DESIGNSIZE_HEIGHT
  local screenSize = Z.UIRoot.CurScreenSize.x / Z.UIRoot.CurScreenSize.y
  local rectPosX, rectPosY = 0, 0
  if normalScreenSize <= screenSize then
    rectPosX = -photoWidth / 2 + offset.x
  else
    rectPosY = -photoHeight / 2 + offset.y
  end
  return Vector2.New(rectPosX, rectPosY)
end

function CamerasysView:resetUI()
  Z.UIRoot:SetClickEffectIsShow(true)
  self.cameraVm.ShowOrHideNoticePopView(true)
  self:setNodeVisible(true, CameraViewHideType.All)
  self:hideButtonsWhenTakingPhotos(true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, cameraData.IsFreeFollow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_camera_btn_return, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_unlock_bg, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shot, not self.isFashionState_)
end

function CamerasysView:shouldFinishPhotoTask()
  if self.photoTaskId_ and self.photoTaskId_ ~= 0 then
    if cameraData.IsOfficialPhotoTask then
      return true
    end
    local photoConfig = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(self.photoTaskId_)
    if self.inCamera_ and photoConfig and self.nearestDistance_ > photoConfig.DistanceTake.X and self.nearestDistance_ < photoConfig.DistanceTake.Y then
      for _, value in ipairs(photoConfig.TargetId) do
        if not Z.PhotoQuestMgr:CheckPhotoQuestConditions(value) then
          return false
        end
      end
      return true
    end
  end
  return false
end

function CamerasysView:executePhotoTaskCompletion()
  if self.posInfoList_[self.photoTaskId_] and self.posInfoList_[self.photoTaskId_].func then
    self.posInfoList_[self.photoTaskId_].func()
  end
end

function CamerasysView:trackCameraPattern()
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(E.GoalType.CameraPatternType, E.CameraTargetStage[cameraData.CameraPatternType])
  if cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.CameraPatternType == E.TakePhotoSate.AR then
    self:checkCameraTarget()
  end
end

function CamerasysView:checkCameraTarget()
  local exploreMonsterVM = Z.VMMgr.GetVM("explore_monster")
  local checkList = exploreMonsterVM.GetMonsterCameraTarget()
  if table.zcount(checkList) <= 0 then
    return
  end
  local entityTypeArray = {}
  local entityConfigIdArray = {}
  local keys = {}
  for k, v in pairs(checkList) do
    local data = v.data
    table.insert(entityTypeArray, data.entityType)
    table.insert(entityConfigIdArray, data.configId)
    table.insert(keys, k)
  end
  local resArray = Z.LuaBridge.CheckEntityShowInCameraByConfigId(entityTypeArray, entityConfigIdArray, self.uiBinder.cont_scenicspor_photo_far)
  if resArray then
    for index = 0, resArray.Length - 1 do
      if resArray[index] and checkList[keys[index + 1]].func then
        checkList[keys[index + 1]].func()
      end
    end
  end
end

function CamerasysView:hideButtonsWhenTakingPhotos(isShow)
  if cameraData.IsOfficialPhotoTask or self.isFashionState_ then
    return
  end
  if not isShow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, false)
  else
    self.uiBinder.tog_btn_hide_hud.isOn = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_btn_show_hud, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_btn_hide_btn, true)
  end
end

function CamerasysView:setNodeVisible(isShow, hideType)
  if cameraData.IsOfficialPhotoTask then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all_active, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_album_container, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_top_right_icon, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_slider_zoom_root, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_rotation, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_joystick, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_member, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.slider_angle, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_camera_btn_return, isShow)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_all_active, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_album_container, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, isShow)
  if isShow == false then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, isShow)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, cameraData.IsFreeFollow)
  end
  if cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.CameraPatternType == E.TakePhotoSate.Battle then
    self.uiBinder.Ref:SetVisible(self.uiBinder.slider_angle, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_lens_rotation, isShow and self.isTogIgnore_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, isShow and self.isTogIgnore_)
  end
  if hideType == CameraViewHideType.All then
    self.viewNodeIsShow_ = isShow
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, isShow)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, isShow and self.isFashionState_)
end

function CamerasysView:asyncTakePhotoByRect()
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.AllDecorateVisible, false)
  local frameLBV = self.uiBinder.Ref:GetUIComp(self.uiBinder.rimg_frame_layer_big).IsVisible
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
  local frameFBV = self.uiBinder.Ref:GetUIComp(self.uiBinder.rimg_frame_fill_big).IsVisible
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, false)
  local rectTransform = self.uiBinder.rimg_frame_systemic
  if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
    rectTransform = self.uiBinder.rimg_frame_head
  end
  local offset = Vector2.New(Z.UIRoot.CurCanvasSize.x / 2, Z.UIRoot.CurCanvasSize.y / 2)
  local rectPosX = -rectTransform.rect.width / 2 + rectTransform.anchoredPosition.x + offset.x
  local rectPosY = -rectTransform.rect.height / 2 + rectTransform.anchoredPosition.y + offset.y
  local widthScale = Z.UIRoot.CurScreenSize.x / Z.UIRoot.CurCanvasSize.x
  local heightScale = Z.UIRoot.CurScreenSize.y / Z.UIRoot.CurCanvasSize.y
  local oriId = asyncCall(Z.UIRoot.CurScreenSize.x, Z.UIRoot.CurScreenSize.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri, rectPosX * widthScale, rectPosY * heightScale, rectTransform.rect.width * widthScale, rectTransform.rect.height * heightScale)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.AllDecorateVisible, true)
  local data = decorateData:GetMoviescreenData()
  Z.CameraFrameCtrl:SetExposure(data.exposure)
  Z.CameraFrameCtrl:SetContrast(data.contrast)
  Z.CameraFrameCtrl:SetSaturation(data.saturation)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, frameLBV)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, frameFBV)
  if data.filterData == "" then
    Z.CameraFrameCtrl:SetDefineFilterAsync()
  else
    Z.CameraFrameCtrl:SetFilterAsync(data.filterData)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Body or cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Fashion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Head)
  return oriId
end

function CamerasysView:asyncGetOriPhoto()
  Z.CameraFrameCtrl:ReductionFrameData()
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.AllDecorateVisible, false)
  local frameLBV = self.uiBinder.Ref:GetUIComp(self.uiBinder.rimg_frame_layer_big).IsVisible
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
  local frameFBV = self.uiBinder.Ref:GetUIComp(self.uiBinder.rimg_frame_fill_big).IsVisible
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  local photoWidth, photoHeight = self.cameraVm.GetTakePhotoSize()
  local rect = self:getScreenshotRect(photoWidth, photoHeight)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  local oriId = asyncCall(Z.UIRoot.CurScreenSize.x, Z.UIRoot.CurScreenSize.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysView, rect.x, rect.y, photoWidth, photoHeight)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.AllDecorateVisible, true)
  local data = decorateData:GetMoviescreenData()
  Z.CameraFrameCtrl:SetExposure(data.exposure)
  Z.CameraFrameCtrl:SetContrast(data.contrast)
  Z.CameraFrameCtrl:SetSaturation(data.saturation)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, frameLBV)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, frameFBV)
  if data.filterData == "" then
    Z.CameraFrameCtrl:SetDefineFilterAsync()
  else
    Z.CameraFrameCtrl:SetFilterAsync(data.filterData)
  end
  return oriId
end

function CamerasysView:addListenerFuncBtn()
  self:AddClick(self.uiBinder.btn_setting, function()
    cameraData:SetTopTagIndex(E.CamerasysTopType.Setting)
    cameraData:SetSettingViewSecondaryLogicIndex(-1)
    self:openSettingContainerAnim()
  end)
  self:AddClick(self.uiBinder.btn_action, function()
    cameraData:SetTopTagIndex(E.CamerasysTopType.Action)
    cameraData:SetSettingViewSecondaryLogicIndex(E.CameraSystemSubFunctionType.CommonAction)
    self:openSettingContainerAnim()
  end)
  self:AddClick(self.uiBinder.btn_filter, function()
    cameraData:SetTopTagIndex(E.CamerasysTopType.Decorate)
    cameraData:SetSettingViewSecondaryLogicIndex(-1)
    self:openSettingContainerAnim()
  end)
  self:AddClick(self.uiBinder.btn_gaze, function()
    cameraData:SetTopTagIndex(E.CamerasysTopType.Action)
    cameraData:SetSettingViewSecondaryLogicIndex(E.CameraSystemSubFunctionType.LookAt)
    self:openSettingContainerAnim()
  end)
end

function CamerasysView:addListenerCameraPatternTog()
  self.uiBinder.tog_album_icon_full_view:RemoveAllListeners()
  self.uiBinder.tog_album_icon_standard:RemoveAllListeners()
  self.uiBinder.tog_album_icon_ar:RemoveAllListeners()
  self.uiBinder.tog_album_icon_battle:RemoveAllListeners()
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self:setPatternType(E.TakePhotoSate.UnionTakePhoto)
    return
  end
  self.uiBinder.tog_album_icon_battle.group = self.uiBinder.anim_btn_group2
  self.uiBinder.tog_album_icon_full_view.group = self.uiBinder.anim_btn_group2
  self.uiBinder.tog_album_icon_standard.group = self.uiBinder.anim_btn_group2
  self.uiBinder.tog_album_icon_ar.group = self.uiBinder.anim_btn_group2
  self.uiBinder.tog_album_icon_full_view:AddListener(function(isOn)
    if isOn and cameraData.CameraPatternType ~= E.TakePhotoSate.Default then
      self:setPatternType(E.TakePhotoSate.Default)
    end
  end)
  self.uiBinder.tog_album_icon_standard:AddListener(function(isOn)
    if isOn and cameraData.CameraPatternType ~= E.TakePhotoSate.SelfPhoto then
      self:setPatternType(E.TakePhotoSate.SelfPhoto)
    end
  end)
  self.uiBinder.tog_album_icon_ar:AddListener(function(isOn)
    if isOn and cameraData.CameraPatternType ~= E.TakePhotoSate.AR then
      if not UnityEngine.SystemInfo.supportsGyroscope then
        Z.TipsVM.ShowTipsLang(1000055)
      end
      self:setPatternType(E.TakePhotoSate.AR)
    end
  end)
  self.uiBinder.tog_album_icon_battle:AddListener(function(isOn)
    if isOn then
      if self.cameraVm.BanSkill() then
        self.uiBinder.tog_album_icon_battle:SetIsOnWithoutCallBack(false)
        self.uiBinder.tog_album_icon_full_view.isOn = true
        Z.TipsVM.ShowTipsLang(1000043)
        return
      end
      if cameraData.CameraPatternType ~= E.TakePhotoSate.Battle then
        self:setPatternType(E.TakePhotoSate.Battle)
      end
    end
  end)
  self.uiBinder.tog_album_icon_full_view.isOn = true
end

function CamerasysView:setPatternType(patternType)
  self.uiBinder.slider_zoom.value = 0
  if patternType == E.TakePhotoSate.Default or patternType == E.TakePhotoSate.Battle then
    local valueData = {}
    valueData.nowType = cameraData.CameraPatternType
    valueData.targetType = E.TakePhotoSate.Default
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    cameraData.CameraPatternType = patternType
    self:updateCameraPattern()
    local tipsConfigId = 1000013
    self.cameraTypeActiveTog_ = self.uiBinder.tog_album_icon_full_view
    if patternType == E.TakePhotoSate.Battle then
      tipsConfigId = 1000044
      self.cameraTypeActiveTog_ = self.uiBinder.tog_album_icon_battle
    end
    local tbData_zoom = cameraData:GetCameraFOVRange()
    self.uiBinder.slider_zoom.value = self.cameraVm.GetRangePerc(tbData_zoom, true)
    Z.TipsVM.ShowTipsLang(tipsConfigId)
    self.fighterBtnView_:Show()
    self:refreshFightView(patternType)
  elseif patternType == E.TakePhotoSate.SelfPhoto then
    if not self.cameraVm.IsEnterSelfPhoto() then
      Z.TipsVM.ShowTipsLang(1000016)
      if self.cameraTypeActiveTog_ then
        self.cameraTypeActiveTog_.isOn = true
      end
      return
    end
    local valueData = {}
    valueData.nowType = cameraData.CameraPatternType
    valueData.targetType = E.TakePhotoSate.SelfPhoto
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    cameraData.CameraPatternType = E.TakePhotoSate.SelfPhoto
    self:updateCameraPattern()
    self.cameraTypeActiveTog_ = self.uiBinder.tog_album_icon_standard
    local tbData_zoom = cameraData:GetCameraFOVSelfRange()
    self.uiBinder.slider_zoom.value = self.cameraVm.GetRangePerc(tbData_zoom, true)
    Z.TipsVM.ShowTipsLang(1000015)
    self.fighterBtnView_:Hide()
  elseif patternType == E.TakePhotoSate.AR then
    local valueData = {}
    valueData.nowType = cameraData.CameraPatternType
    valueData.targetType = E.TakePhotoSate.AR
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    cameraData.CameraPatternType = E.TakePhotoSate.AR
    self:updateCameraPattern()
    self.cameraTypeActiveTog_ = self.uiBinder.tog_album_icon_ar
    local tbData_zoom = cameraData:GetCameraFOVARRange()
    self.uiBinder.slider_zoom.value = self.cameraVm.GetRangePerc(tbData_zoom, true)
    Z.TipsVM.ShowTipsLang(1000014)
    self.fighterBtnView_:Hide()
  elseif patternType == E.TakePhotoSate.UnionTakePhoto then
    self:updateCameraPattern()
    self.fighterBtnView_:Hide()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, patternType ~= E.TakePhotoSate.UnionTakePhoto)
  self.uiBinder.Ref:SetVisible(self.uiBinder.slider_angle, (patternType == E.TakePhotoSate.Default or patternType == E.TakePhotoSate.Battle) and self.isTogIgnore_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, (patternType == E.TakePhotoSate.Default or patternType == E.TakePhotoSate.Battle) and self.isTogIgnore_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_rotation, patternType == E.TakePhotoSate.Default or patternType == E.TakePhotoSate.UnionTakePhoto)
  local isShowLookAt = patternType == E.TakePhotoSate.Default and patternType == E.TakePhotoSate.Battle
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_gaze, isShowLookAt)
  self:refreshLeftFunctionBtn()
end

function CamerasysView:refreshLeftFunctionBtn()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_setting, self.cameraVm.CheckMobileUiShowState(cameraData.MobileMainViewBtnEnum.Setting))
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album_entrance, self.cameraVm.CheckMobileUiShowState(cameraData.MobileMainViewBtnEnum.Album))
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_action, self.cameraVm.CheckMobileUiShowState(cameraData.MobileMainViewBtnEnum.Action))
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_filter, self.cameraVm.CheckMobileUiShowState(cameraData.MobileMainViewBtnEnum.Decoration))
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_gaze, self.cameraVm.CheckMobileUiShowState(cameraData.MobileMainViewBtnEnum.LookAt))
end

function CamerasysView:refreshFightView(patternType)
  if patternType == E.TakePhotoSate.Default then
    self.fighterBtnView_:ForceChangeSkillPanel(false)
    if not self.isSkillIgnore_ then
      Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 1056, true)
      self.isSkillIgnore_ = true
    end
  elseif patternType == E.TakePhotoSate.Battle then
    self.fighterBtnView_:ForceChangeSkillPanel(true)
    if self.isSkillIgnore_ then
      Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 1056, false)
      self.isSkillIgnore_ = false
    end
  end
end

function CamerasysView:updateCameraPattern()
  local showData
  if cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.CameraPatternType == E.TakePhotoSate.Battle then
    showData = cameraData:GetShowEntityData()
    self:setShowEntity(showData)
  elseif cameraData.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    showData = cameraData:GetShowEntitySelfPhotoData()
    self:setShowEntity(showData)
  elseif cameraData.CameraPatternType == E.TakePhotoSate.AR then
    showData = cameraData:GetShowEntityARData()
    self:setShowEntity(showData)
  elseif cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self:setUnrealSceneState()
  end
  if cameraData.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto then
    local oneSelfHideState = cameraData.CameraPatternType ~= E.TakePhotoSate.AR
    Z.CameraFrameCtrl:SetEntityShow(E.CameraSystemShowEntityType.Oneself, oneSelfHideState)
    cameraData.IsHideSelfModel = not oneSelfHideState
  end
  local cameraStateType = self.cameraVm.ConversionTakePhotoType(cameraData.CameraPatternType)
  Z.CameraFrameCtrl:SetPhotoType(cameraStateType)
  self.cameraVm.SetCameraPatternShotSet()
  if not self.isChangeScheme_ then
    cameraData:InitTagIndex()
    return
  end
end

function CamerasysView:setUnrealSceneState()
  local showData = cameraData:GetShowEntityData()
  self:setShowEntity(showData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.slider_angle, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album_entrance, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_slider_zoom_root, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_member, false)
  self:initUnionUnrealData()
  if not self.isUnRealSceneIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 12582924, true)
    self.isUnRealSceneIgnore_ = true
  end
  local rootCanvas = Z.UIRoot.RootCanvas.transform
  local rate = 0.00925926 / rootCanvas.localScale.x
  local width, height
  if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Body or cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Fashion then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, true)
    width, height = self.cameraVm.GetUnionSelectBoxSize(cameraData.BodyImgOriSize, rate, true)
    self.uiBinder.rimg_frame_systemic:SetWidth(width)
    self.uiBinder.rimg_frame_systemic:SetHeight(height)
    self:setImgAreaClip(self.uiBinder.img_body_mask, self.uiBinder.rimg_frame_systemic)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, true)
    width, height = self.cameraVm.GetUnionSelectBoxSize(cameraData.HeadImgOriSize, rate)
    self.uiBinder.rimg_frame_head:SetWidth(width)
    self.uiBinder.rimg_frame_head:SetHeight(height)
    self:setImgAreaClip(self.uiBinder.img_head_mask, self.uiBinder.rimg_frame_head)
  end
end

function CamerasysView:initUnionUnrealData()
  cameraData.BodyImgOriSize = {x = 0, y = 0}
  cameraData.HeadImgOriSize = {x = 0, y = 0}
  cameraData.BodyImgOriPos = {x = 0, y = 0}
  cameraData.HeadImgOriPos = {x = 0, y = 0}
  cameraData.BodyImgOriSize.x, cameraData.BodyImgOriSize.y = self.uiBinder.rimg_frame_systemic:GetSize(cameraData.BodyImgOriSize.x, cameraData.BodyImgOriSize.y)
  cameraData.HeadImgOriSize.x, cameraData.HeadImgOriSize.y = self.uiBinder.rimg_frame_head:GetSize(cameraData.HeadImgOriSize.x, cameraData.HeadImgOriSize.y)
  cameraData.BodyImgOriPos.x, cameraData.BodyImgOriPos.y = self.uiBinder.rimg_frame_systemic:GetAnchorPosition(cameraData.BodyImgOriPos.x, cameraData.BodyImgOriPos.y)
  cameraData.HeadImgOriPos.x, cameraData.HeadImgOriPos.y = self.uiBinder.rimg_frame_head:GetAnchorPosition(cameraData.HeadImgOriPos.x, cameraData.HeadImgOriPos.y)
end

function CamerasysView:setImgAreaClip(maskImg, imgNode)
  if not maskImg then
    return
  end
  local imgNodeLocalPos = imgNode.localPosition
  local offset = Vector2.New(Z.UIRoot.CurCanvasSize.x / 2, Z.UIRoot.CurCanvasSize.y / 2)
  local rectLeftPosX = (offset.x - imgNode.rect.width / 2 + imgNodeLocalPos.x) / (offset.x * 2)
  local rectLeftPosY = (offset.y - imgNode.rect.height / 2 + imgNodeLocalPos.y) / (offset.y * 2)
  local rectRightPosX = (offset.x + imgNode.rect.width / 2 + imgNodeLocalPos.x) / (offset.x * 2)
  local rectRightPosY = (offset.y + imgNode.rect.height / 2 + imgNodeLocalPos.y) / (offset.y * 2)
  local area = Vector4.New(rectLeftPosX, rectLeftPosY, rectRightPosX, rectRightPosY)
  maskImg:SetAreaClip(area)
end

function CamerasysView:setShowEntity(showData)
  local showEntity = {}
  local allData = cameraData.ShowEntityAllCfg
  for key, value in pairs(allData) do
    local temp = {}
    temp.type = value.type
    temp.state = value.state
    showEntity[temp.type] = temp
  end
  for key, value in pairs(showData) do
    if showEntity[value.type] then
      showEntity[value.type].state = value.state
    end
  end
end

function CamerasysView:addListenerFovSlider()
  local tbData_zoom
  if cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    tbData_zoom = cameraData:GetCameraFOVRange()
  elseif cameraData.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    tbData_zoom = cameraData:GetCameraFOVSelfRange()
  elseif cameraData.CameraPatternType == E.TakePhotoSate.AR then
    tbData_zoom = cameraData:GetCameraFOVARRange()
  end
  self.uiBinder.slider_zoom:RemoveAllListeners()
  self.uiBinder.slider_zoom.value = self.cameraVm.GetRangePerc(tbData_zoom, true)
  Z.CameraFrameCtrl:SetCameraSize(tbData_zoom.define)
  self.uiBinder.slider_zoom:AddListener(function(val)
    local zoom
    if cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto or cameraData.CameraPatternType == E.TakePhotoSate.Battle then
      zoom = cameraData:GetCameraFOVRange()
    elseif cameraData.CameraPatternType == E.TakePhotoSate.SelfPhoto then
      zoom = cameraData:GetCameraFOVSelfRange()
    elseif cameraData.CameraPatternType == E.TakePhotoSate.AR then
      zoom = cameraData:GetCameraFOVARRange()
    end
    zoom.value = self.cameraVm.GetRangeValue(val, zoom)
    Z.CameraFrameCtrl:SetCameraSize(zoom.value)
  end)
  self.uiBinder.btn_zoom_in:AddListener(function()
    if self.uiBinder.slider_zoom.value + 0.1 > 1 then
      self.uiBinder.slider_zoom.value = 1
    else
      self.uiBinder.slider_zoom.value = self.uiBinder.slider_zoom.value + 0.1
    end
  end)
  self.uiBinder.btn_zoom_out:AddListener(function()
    if self.uiBinder.slider_zoom.value - 0.1 < 0 then
      self.uiBinder.slider_zoom.value = 0
    else
      self.uiBinder.slider_zoom.value = self.uiBinder.slider_zoom.value - 0.1
    end
  end)
  local model
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    model = self.playerModel_
  else
    model = Z.EntityMgr.MainEnt.Model
  end
  self.rotationOffset_ = self.cameraVm.GetModelDefaultRotation(model)
  local normalizedValue = self.cameraVm.GetRotationSliderValueNormalized(self.rotationOffset_)
  self.uiBinder.slider_rotation:RemoveAllListeners()
  self.uiBinder.slider_rotation.value = normalizedValue
  self.uiBinder.lab_rotation_num.text = math.floor(normalizedValue)
  self.uiBinder.slider_rotation:AddListener(function()
    if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
      self:setPlayerRotation(self.playerModel_)
    else
      local curSelectMemberData = self.cameraMemberData_:GetSelectMemberData()
      if not curSelectMemberData.baseData.isSelf then
        self:setPlayerRotation(curSelectMemberData.baseData.model)
        return
      end
      local val = self.uiBinder.slider_rotation.value
      self.uiBinder.lab_rotation_num.text = math.floor(val)
      Z.LuaBridge.SetEntityRotation(Z.EntityMgr.MainEnt, Quaternion.Euler(Vector3.New(0, val + self.rotationOffset_, 0)))
    end
  end)
end

function CamerasysView:updateNodeScrollView()
  if self.settingSubView_.IsActive then
    self.settingSubView_:Show()
  end
  self:setRightPanelVisible(false)
  self:setRightFuncShow(false)
  local rightViewData = {
    OpenSourceType = E.ExpressionOpenSourceType.Camera
  }
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    rightViewData.ZModel = self.playerModel_
  end
  self.settingSubView_:Active(rightViewData, self.uiBinder.node_setting_trans)
end

function CamerasysView:camerasysViewShow()
  self:Show()
end

function CamerasysView:camerasysDecorateSet(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_decorate, true)
  local dec_ = require("ui/view/camera_decorate_controller_item").new()
  dec_:Active(data, self.uiBinder.node_item)
end

function CamerasysView:resetModelLookAt()
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  Z.ModelHelper.ResetLookAtIKParam(Z.EntityMgr.PlayerEnt.Model)
  Z.EntityMgr.PlayerEnt.Model:SetLuaAttrLookAtEyeOpen(false)
  Z.ModelHelper.SetLookAtTransform(Z.EntityMgr.PlayerEnt.Model, nil)
  if cameraData.IsControlEveryOne then
    local selectMemberData = self.cameraMemberVM_:AssembledLookAtMemberData()
    for k, v in pairs(selectMemberData) do
      local model = v.baseData.model
      Z.ModelHelper.ResetLookAtIKParam(model)
      model:SetLuaAttrLookAtEyeOpen(false)
      Z.ModelHelper.SetLookAtTransform(model, nil)
    end
  end
end

function CamerasysView:OnDeActive()
  self:resetModelLookAt()
  self.cameraMemberData_:SetSelectMemberCharId(0)
  if Z.EntityMgr.PlayerEnt then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    if stateId == Z.PbEnum("EActorState", "ActorStateAction") then
      Z.ZAnimActionPlayMgr:ResetAction()
    end
  end
  cameraData:ClearFaceModelInfo()
  if cameraData.IsHideCameraMember then
    Z.CameraFrameCtrl:SetEntityShow(E.CameraSystemShowEntityType.CameraTeamMember, true)
    cameraData.IsHideCameraMember = false
  end
  self.cameraMemberVM_:SaveMemberListData()
  self.cameraMemberData_:ClearMemberModel()
  self.cameraMemberData_.MemberListData = {}
  if self.isPlayerBloodBarIgnore_ then
    Z.IgnoreMgr:SetBattleUIIgnore(Panda.ZGame.EBattleUIMask.Blood, false, Panda.ZGame.EIgnoreMaskSource.EUIView)
    self.isPlayerBloodBarIgnore_ = false
  end
  if self.unionBgGO_ then
    self.unionBgGO_:SetActive(false)
    self.unionBgGO_ = nil
  end
  if self.unrealSkyBoxGo_ then
    self.unrealSkyBoxGo_:SetActive(true)
    self.unrealSkyBoxGo_ = nil
  end
  if self.unionDragLimitMax_ then
    self.unionDragLimitMax_ = nil
  end
  if self.unionDragLimitMin_ then
    self.unionDragLimitMin_ = nil
  end
  if self.isTogIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 25165848, false)
    self.isTogIgnore_ = false
  end
  if self.isUnRealSceneIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 12582924, false)
    self.isUnRealSceneIgnore_ = false
  end
  self:setNodeVisible(true, CameraViewHideType.All)
  self.cameraVm.IsUpdateWeatherByServer(true)
  self.cameraVm.SetHeadLookAt(false)
  cameraData.IsDecorateAddViewSliderShow = false
  self:hideButtonsWhenTakingPhotos(true)
  cameraData:SetIsSchemeParamUpdated(false)
  cameraData:ResetHeadAndEyesFollow()
  Z.LuaBridge.SetHudSwitch(true)
  cameraData.CameraSchemeSelectIndex = 0
  self:unBindEvents()
  self.cameraVm.ResetEntityVisible()
  if cameraData.IsOfficialPhotoTask then
    cameraData.IsOfficialPhotoTask = false
    cameraData.PhotoTaskId = 0
    local photoConfig = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(self.photoTaskId_)
    if photoConfig then
      local idList = ZUtil.Pool.Collections.ZList_int.Rent()
      Z.CameraMgr:CameraInvokeByList(E.CameraState.Position, false, idList)
      ZUtil.Pool.Collections.ZList_int.Return(idList)
    end
  end
  if not self.isSkillIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2883584, false)
  else
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2884640, false)
  end
  self.fighterBtnView_:DeActive()
  self.joystickView_:DeActive()
  self.decorateAddView_:DeActive()
  self.settingSubView_:DeActive()
  self.blessingSubView_:DeActive()
  self.cameraActionSlider_:DeActive()
  if self.playerPosWatcher ~= nil then
    self.playerPosWatcher:Dispose()
    self.playerPosWatcher = nil
  end
  self:UnBindEntityLuaAttrWatcher(self.buffWatcher)
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  self.buffWatcher = nil
  self.uiBinder.img_photo_rocker_bg:RemoveAllListeners()
  self.onDragFunc_ = nil
  self.onBeginDragFunc_ = nil
  self.onEndDragFunc_ = nil
  cameraData.ActiveItem = nil
  cameraData.CameraSchemeSelectId = -1
  decorateData:SetDecoreateNum(0)
  decorateData:ClearDecorateData()
  Z.CameraFrameCtrl:ResetCameraInitialParameters(cameraData.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto)
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncSetPersonalState(E.PersonalizationStatus.EStatusPhoto, true)
  end)()
  if cameraData.IsHideSelfModel then
    Z.CameraFrameCtrl:SetEntityShow(E.CameraSystemShowEntityType.Oneself, true)
    cameraData.IsHideSelfModel = false
  end
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
end

function CamerasysView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.UpdateSettingView, self.updateNodeScrollView, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.ViewShow, self.camerasysViewShow, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateSet, self.camerasysDecorateSet, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateLayerSet, self.camerasysDecorateLayerSet, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.HurtEvent, self.camerasysHurtEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.PatternTypeEvent, self.camerasysPatternTypeEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.SwitchPatternTypeEvent, self.switchPatternTypeEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.SetFreeLookAt, self.setFreeLookAt, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.ExpressionPlaySlider, self.SetActionSliderTransVisible, self)
  Z.EventMgr:Add(Z.ConstValue.CameraMember.SelectCameraMemberChanged, self.onSelectMemberChanged, self)
  Z.EventMgr:Add(Z.ConstValue.FaceAttrChange, self.onFaceAttrChange, self)
  
  function self.onDragFunc_(val)
    Z.CameraFrameCtrl:SetCameraOffsetByJoystick(val)
  end
  
  function self.onBeginDragFunc_()
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photograph_frame, true)
  end
  
  function self.onEndDragFunc_()
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photograph_frame, false)
  end
  
  self.uiBinder.img_photo_rocker_bg:AddListener(self.onDragFunc_, self.onBeginDragFunc_, self.onEndDragFunc_)
end

function CamerasysView:switchPatternTypeEvent(patternType)
  if cameraData.CameraPatternType ~= patternType then
    self:setPatternType(patternType)
  end
end

function CamerasysView:photoViewShowOrHide()
  self:setNodeVisible(not self.viewNodeIsShow_, CameraViewHideType.All)
end

function CamerasysView:setFreeLookAt(isOn, isHead)
  if isHead then
    self.uiBinder.head_trans_drag.position = Vector3.zero
    if isOn then
      self:updateFaceFramePos()
    end
  else
    self.uiBinder.eyes_trans_drag.position = Vector3.zero
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.eyes_trans_drag, cameraData.IsEyeFollow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.head_trans_drag, cameraData.IsHeadFollow)
  if cameraData.IsEyeFollow == false and cameraData.IsHeadFollow == false then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, true)
  end
end

function CamerasysView:updateFaceFramePos()
  if cameraData.IsControlEveryOne == true then
    return
  end
  local selectMemberData = self.cameraMemberData_:GetSelectMemberData()
  local model = selectMemberData.baseData.model
  if not model then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_face_frame, true)
  local headPos = model:GetHeadPosition()
  local screenPosition = Z.CameraMgr.MainCamera:WorldToScreenPoint(headPos)
  local _, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.node_drag, screenPosition, nil)
  self.uiBinder.node_face_frame:SetAnchorPosition(uiPos.x, uiPos.y + 30)
end

function CamerasysView:camerasysPatternTypeEvent(patternType)
  self.isChangeScheme_ = true
  if patternType == E.TakePhotoSate.Default then
    self.uiBinder.tog_album_icon_full_view.isOn = true
  elseif patternType == E.TakePhotoSate.SelfPhoto then
    self.uiBinder.tog_album_icon_standard.isOn = true
  elseif patternType == E.TakePhotoSate.AR then
    self.uiBinder.tog_album_icon_ar.isOn = true
  elseif patternType == E.TakePhotoSate.Battle then
    self.uiBinder.tog_album_icon_battle.isOn = true
  end
end

function CamerasysView:camerasysHurtEvent()
  if cameraData.CameraPatternType ~= E.TakePhotoSate.SelfPhoto then
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
  if stateId == Z.PbEnum("EActorState", "ActorStateSelfPhoto") then
    self.uiBinder.tog_album_icon_full_view.isOn = true
  end
end

function CamerasysView:camerasysDecorateLayerSet(valueData)
  local frameType = valueData.Parameter
  local path = string.format("%s%s", bigFilterPath, valueData.Res)
  if frameType == E.CameraFrameType.None then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  elseif frameType == E.CameraFrameType.Normal then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
    self.uiBinder.rimg_frame_layer_big:SetImage(path)
  elseif frameType == E.CameraFrameType.FillBlack then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, true)
    self.uiBinder.rimg_frame_fill_big:SetImage(path)
  end
end

function CamerasysView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.UpdateSettingView, self.updateNodeScrollView, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.ViewShow, self.camerasysViewShow, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateSet, self.camerasysDecorateSet, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateLayerSet, self.camerasysDecorateLayerSet, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.HurtEvent, self.camerasysHurtEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.PatternTypeEvent, self.camerasysPatternTypeEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.SwitchPatternTypeEvent, self.switchPatternTypeEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.SetFreeLookAt, self.setFreeLookAt, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.ExpressionPlaySlider, self.SetActionSliderTransVisible, self)
  Z.EventMgr:Remove(Z.ConstValue.CameraMember.SelectCameraMemberChanged, self.onSelectMemberChanged, self)
  Z.EventMgr:Remove(Z.ConstValue.FaceAttrChange, self.onFaceAttrChange, self)
end

function CamerasysView:setRightFuncShow(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, isShow and not self.isFashionState_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_top_right_icon, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group2, isShow)
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.slider_angle, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album_entrance, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, isShow and cameraData.CameraPatternType == E.TakePhotoSate.Default and self.isTogIgnore_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_lens_rotation, isShow and cameraData.CameraPatternType == E.TakePhotoSate.Default and self.isTogIgnore_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.slider_angle, isShow and self.isTogIgnore_ and (cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.patternType == E.TakePhotoSate.Battle))
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album_entrance, isShow)
  end
end

function CamerasysView:bindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerPosWatcher = Z.DIServiceMgr.PlayerAttrComponentWatcherService:OnAttrVirtualPosChanged(function()
      self:updatePosEvent()
    end)
    self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
      self:updateActorStateEvent()
    end)
    self.buffWatcher = self:BindEntityLuaAttrWatcher({
      Z.LocalAttr.ENowBuffList
    }, Z.EntityMgr.PlayerEnt, self.onBuffChange, true)
  end
end

function CamerasysView:onBuffChange()
  local isBanSkill = self.cameraVm.BanSkill()
  if isBanSkill and cameraData.CameraPatternType == E.TakePhotoSate.Battle then
    self:setPatternType(E.TakePhotoSate.Default)
  end
end

function CamerasysView:updateActorStateEvent()
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if cameraData.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    if stateId == Z.PbEnum("EActorState", "ActorStateDefault") then
      local canSwitchStateList = {
        Z.PbEnum("EMoveType", "MoveIdle"),
        Z.PbEnum("EMoveType", "MoveWalk"),
        Z.PbEnum("EMoveType", "MoveRun")
      }
      local moveType = Z.EntityMgr.PlayerEnt:GetLuaAttrVirtualMoveType()
      for k, v in pairs(canSwitchStateList) do
        if v ~= moveType then
          self.uiBinder.tog_album_icon_full_view.isOn = true
        end
      end
    elseif stateId == Z.PbEnum("EActorState", "ActorStateSelfPhoto") or Z.EntityMgr.PlayerEnt.IsRiding == true then
    else
      self.uiBinder.tog_album_icon_full_view.isOn = true
    end
  end
  if stateId == Z.PbEnum("EActorState", "ActorStateDead") or stateId == Z.PbEnum("EActorState", "ActorStateResurrection") then
    Z.UIMgr:CloseView("camerasys")
  end
end

function CamerasysView:updatePosEvent()
  if not cameraData.IsFocusTag and cameraData.IsDepthTag then
    local playerPos_ = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos()
    local x, y, z = playerPos_.x, playerPos_.y, playerPos_.z
    self:setFocusTargetPos(x, y, z)
  end
  self:getNearestPointInfo()
end

function CamerasysView:setFocusTargetPos(x, y, z)
  Z.CameraFrameCtrl:SetFocusTargetPos(x, y, z)
end

function CamerasysView:OnRefresh()
  cameraData:InitDirty()
  self:updateCameraPattern()
  self.cameraTypeActiveTog_ = self.uiBinder.tog_album_icon_full_view
  decorateData:InitMoviescreenData()
  self:setRightFuncShow(true)
end

function CamerasysView:OnShow()
end

function CamerasysView:startAnimatedHide()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_4)
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim, Panda.ZUi.DOTweenAnimType.Close)
end

function CamerasysView:openSettingContainerAnim()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, true)
  self.uiBinder.node_setting_anim:Restart(Z.DOTweenAnimType.Open)
  self:updateNodeScrollView()
end

function CamerasysView:closeSettingContainerAnim()
  self.uiBinder.node_setting_anim:Restart(Z.DOTweenAnimType.Close)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, false)
end

function CamerasysView:checkPhotoTask()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_slider_zoom_root, not cameraData.IsOfficialPhotoTask)
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group, not cameraData.IsOfficialPhotoTask)
  self.posInfoList_ = Z.PhotoQuestMgr:GetPhotoTask()
  self.photoConditionUnits_ = {}
  self.photoConditionUnitsFlag_ = {}
  if cameraData.IsOfficialPhotoTask then
    self.photoTaskId_ = cameraData.PhotoTaskId
    self:refreshPhotoTaskInfo()
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_scenicspor_photo_far, false)
    self.timerMgr:StartTimer(function()
      self:refreshPhotoTaskInfo()
    end, 0.01, -1)
  else
    local TempV3 = Vector3.New(0, 0, 0)
    self:getNearestPointInfo()
    self:refreshPhotoTaskInfo()
    self.timerMgr:StartTimer(function()
      local pointInfo = self.posInfoList_[self.photoTaskId_]
      if pointInfo and pointInfo.data then
        self.uiBinder.Ref:SetVisible(self.uiBinder.cont_scenicspor_photo_far, true)
        TempV3.x = pointInfo.data.Position[1]
        TempV3.y = pointInfo.data.Position[2]
        TempV3.z = pointInfo.data.Position[3]
        local show, pos = ZTransformUtility.WorldToLocalPointInRectangle(TempV3, self.uiBinder.cont_scenicspor_photo_far, false, nil)
        if not show then
          self.inCamera_ = false
          self.uiBinder.Ref:SetVisible(self.uiBinder.group_tip_root, false)
          return
        else
          self.inCamera_ = true
          self.uiBinder.Ref:SetVisible(self.uiBinder.group_tip_root, true)
        end
        self.uiBinder.group_tip_root:SetAnchorPosition(pos.x, pos.y)
        local photoConfig = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(self.photoTaskId_)
        if photoConfig then
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_scenicspor_photo, true)
          if self.nearestDistance_ > photoConfig.DistanceTake.Y then
            self.uiBinder.img_scenicspor_photo:SetImage(GetLoadAssetPath("scenicspor_photo_far"))
            self.uiBinder.Ref:SetVisible(self.uiBinder.lab_far, true)
            self.uiBinder.lab_far.text = Lang("too_far")
          elseif self.nearestDistance_ < photoConfig.DistanceTake.X then
            self.uiBinder.img_scenicspor_photo:SetImage(GetLoadAssetPath("scenicspor_photo_far"))
            self.uiBinder.Ref:SetVisible(self.uiBinder.lab_far, true)
            self.uiBinder.lab_far.text = Lang("too_near")
          else
            self.uiBinder.img_scenicspor_photo:SetImage(GetLoadAssetPath("scenicspor_photo_normal"))
            self.uiBinder.Ref:SetVisible(self.uiBinder.lab_far, false)
          end
        else
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_scenicspor_photo, false)
          self.uiBinder.Ref:SetVisible(self.uiBinder.lab_far, false)
        end
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.cont_scenicspor_photo_far, false)
      end
      self:refreshPhotoTaskInfo()
    end, 0.01, -1)
  end
end

function CamerasysView:refreshPhotoTaskInfo()
  if self.photoTaskId_ == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_unlock, false)
  else
    local photoTaskBase = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(self.photoTaskId_)
    if photoTaskBase == nil then
      return
    end
    local conditionRoot = self.uiBinder.node_quest_unlock_item
    Z.CoroUtil.create_coro_xpcall(function()
      if #photoTaskBase.TargetId == 0 then
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_unlock, false)
      else
        for index, value in ipairs(photoTaskBase.TargetId) do
          local photoTargetBase = Z.TableMgr.GetTable("PhotoTargetTableMgr").GetRow(value)
          if photoTargetBase then
            if self.photoConditionUnits_[index] == nil and not self.photoConditionUnitsFlag_[index] then
              local name = string.format("condition_%s", index)
              self.photoConditionUnitsFlag_[index] = true
              self.photoConditionUnits_[index] = self:AsyncLoadUiUnit(self.uiBinder.prefab_cache:GetString("conditionUnit"), name, conditionRoot)
            end
            local unit = self.photoConditionUnits_[index]
            if unit then
              local finishCount = Z.PhotoQuestMgr:GetPhotoQuestFinishNum(value)
              unit.group_target_photo:SetParent(unit.Trans)
              unit.group_target_photo:SetAsFirstSibling()
              local finish = finishCount >= photoTargetBase.Num
              unit.Ref:SetVisible(unit.img_target_photo_completed, finish)
              unit.Ref:SetVisible(unit.img_target_photo, not finish)
              local colorTag = E.TextStyleTag.White
              if finish then
                colorTag = E.TextStyleTag.MapTextFinish
              end
              unit.lab_num.text = Z.RichTextHelper.ApplyStyleTag(finishCount .. "/" .. photoTargetBase.Num, colorTag)
              unit.lab_target_desc.text = Z.RichTextHelper.ApplyStyleTag(photoTargetBase.Des, colorTag)
              unit.Ref.UIComp:SetVisible(true)
            end
          end
        end
        for i = #photoTaskBase.TargetId + 1, #self.photoConditionUnits_ do
          self.photoConditionUnits_[i]:SetVisible(false)
        end
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_unlock, true)
      end
    end)()
  end
end

function CamerasysView:getNearestPointInfo()
  if cameraData.IsOfficialPhotoTask or cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return
  end
  local lastPhotoTaskId = self.photoTaskId_
  self.photoTaskId_, self.nearestDistance_ = Z.PhotoQuestMgr:GetNearestPhotoTaskId(self.posInfoList_)
  if lastPhotoTaskId ~= self.photoTaskId_ then
    self.isChangeNearest = true
  end
end

function CamerasysView:OnInputBack()
  if not albumMainData.IsUpLoadState then
    Z.UIMgr:CloseView(self.viewConfigKey)
  end
end

function CamerasysView:OnMountsTrigger()
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
    return false
  end
  local mainUIVM = Z.VMMgr.GetVM("mainui")
  mainUIVM.GotoMainUIFunc(E.FunctionID.VehicleRide)
end

function CamerasysView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.actionId == Z.RewiredActionsConst.Mounts then
    self:OnMountsTrigger()
  end
end

function CamerasysView:setRightPanelVisible(isShow)
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group, isShow and not cameraData.IsOfficialPhotoTask)
  end
end

function CamerasysView:setPlayerRotation(model)
  if not model then
    return
  end
  local val = self.uiBinder.slider_rotation.value
  self.uiBinder.lab_rotation_num.text = math.floor(val)
  model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, val + self.rotationOffset_, 0)))
end

function CamerasysView:onHeadLookAtImageDrag(eventData)
  if self.cameraMemberData_.HeadLock then
    return
  end
  local transDragWidth, transDragHeight = 0, 0
  transDragWidth, transDragHeight = self.uiBinder.head_trans_drag:GetAnchorPosition(transDragWidth, transDragHeight)
  local posX, posY = self.cameraVm.PosKeepBounds(transDragWidth + eventData.delta.x, transDragHeight + eventData.delta.y)
  self.uiBinder.head_trans_drag:SetAnchorPosition(posX, posY)
  self:coordinateTransformation(true)
end

function CamerasysView:onEyesLookAtImageDrag(eventData)
  if self.cameraMemberData_.EyesLock then
    return
  end
  local transDragWidth, transDragHeight = 0, 0
  transDragWidth, transDragHeight = self.uiBinder.eyes_trans_drag:GetAnchorPosition(transDragWidth, transDragHeight)
  local posX, posY = self.cameraVm.PosKeepBounds(transDragWidth + eventData.delta.x, transDragHeight + eventData.delta.y)
  self.uiBinder.eyes_trans_drag:SetAnchorPosition(posX, posY)
  self:coordinateTransformation(false)
end

function CamerasysView:coordinateTransformation(isHead)
  local selectMemberData = self.cameraMemberData_:GetSelectMemberData()
  local model = selectMemberData.baseData.model
  if not model then
    return
  end
  local position = isHead and self.uiBinder.head_trans_drag.position or self.uiBinder.eyes_trans_drag.position
  local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(position)
  local playerPos = model:GetAttrGoPosition()
  local newScreenPos = Vector3.New(screenPosition.x, screenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, playerPos))
  local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos)
  local localPosition = Z.ModelHelper.LuaWorldPosToLocal(Z.EntityMgr.PlayerEnt.Model, worldPosition)
  localPosition.z = 0.2
  if isHead then
    selectMemberData.lookAtData.headCurPos = localPosition
  else
    selectMemberData.lookAtData.eyesCurPos = localPosition
  end
  Z.ModelHelper.SetLookAtPos(model, localPosition, isHead)
  self:updateFaceFramePos()
end

function CamerasysView:CustomClose()
  if cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(0.2, 1.2)
    Z.UnrealSceneMgr:CloseUnrealScene("camerasys")
  end
  cameraData.CameraPatternType = E.TakePhotoSate.Default
end

function CamerasysView:onSelectMemberChanged()
  local selectMemberData = self.cameraMemberData_:GetSelectMemberData()
  if not selectMemberData then
    return
  end
  self.uiBinder.lab_switch_name.text = selectMemberData.socialData.basicData.name
  self:refreshLeftFunctionBtn()
end

function CamerasysView:UpdateAfterVisibleChanged(visible)
  Z.UIConfig[self.viewConfigKey].IsUnrealScene = cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto
  super.UpdateAfterVisibleChanged(self, visible)
end

function CamerasysView:SetActionSliderTransVisible(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_action_slider, isShow)
end

function CamerasysView:RefreshActionSlider(model, memberData, isShow)
  if not memberData then
    return
  end
  local expressionData = Z.DataMgr.Get("expression_data")
  if memberData.baseData.isSelf then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    local isActionState = stateId == Z.PbEnum("EActorState", "ActorStateAction")
    local actionId = Z.EntityMgr.PlayerEnt.Model:GetLuaAttrActionInfoActionId()
    expressionData:SetCurPlayingId(actionId)
    self.cameraActionSlider_:Active({
      OpenSourceType = E.ExpressionOpenSourceType.Camera,
      ZModel = nil
    }, self.uiBinder.node_action_slider)
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ExpressionPlaySlider, isActionState)
    return
  end
  if self.cameraActionSlider_ and self.cameraActionSlider_.IsActive then
    self.cameraActionSlider_:Show()
  end
  self.cameraActionSlider_:Active({
    OpenSourceType = E.ExpressionOpenSourceType.Camera,
    ZModel = model
  }, self.uiBinder.node_action_slider)
  if not isShow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_action_slider, false)
  else
    expressionData:SetLogicExpressionType(E.ExpressionType.Action)
    expressionData:SetCurPlayingId(memberData.actionData.actionId)
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.ExpressionPlaySlider, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_action_slider, true)
  end
  if self.settingSubView_.IsActive and self.settingSubView_.IsVisible then
    self.settingSubView_:SetActionSliderIsShow(memberData.baseData.isSelf)
  end
end

function CamerasysView:setBlessingViewIsShow(isShow)
  if self.blessingSubView_ and self.blessingSubView_.IsActive then
    if isShow then
      self.blessingSubView_:Show()
    else
      self.blessingSubView_:Hide()
    end
  end
end

function CamerasysView:getKeyIdAndDescByFuncId(funcId)
  local keyTbl = Z.TableMgr.GetTable("SetKeyboardTableMgr")
  for keyId, row in pairs(keyTbl.GetDatas()) do
    if row.KeyboardDes == 2 and row.FunctionId == funcId then
      return keyId, row.SetDes
    end
  end
end

function CamerasysView:initFaceModel()
  local faceData = Z.DataMgr.Get("face_data")
  local gender = faceData:GetPlayerGender()
  local bodySize = faceData:GetPlayerBodySize()
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(gender, bodySize)
  cameraData:SetFaceModelInfo(gender, bodySize, modelId)
  self.playerModel_ = Z.UnrealSceneMgr:GetCacheModel(faceData.FaceModelName)
  if not self.playerModel_ then
    Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
      model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
      local equipZList = self.faceVM_.GetDefaultEquipZList(gender)
      model:SetLuaAttr(Z.LocalAttr.EWearEquip, equipZList)
      equipZList:Recycle()
      model:SetLuaAttrLookAtEnable(true)
    end, function(model)
      self.playerModel_ = model
      Z.UIMgr:FadeOut()
      local attrVM = Z.VMMgr.GetVM("face_attr")
      attrVM.UpdateAllFaceAttr()
    end)
  else
    self.playerModel_:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
    self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
    self.playerModel_:SetLuaAttr(Z.ModelAttr.EModelRenderInvisible, false)
    Z.ModelHelper.SetRenderLayerMaskByRenderType(self.playerModel_, Z.ZRenderingLayerUtils.RENDERING_LAYER_MASK_DEFAULT, Z.ModelRenderMask.All)
    self.playerModel_:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_UNREALSCENE)
    Z.UIMgr:FadeOut()
  end
end

function CamerasysView:onFaceAttrChange(attrType, ...)
  if not self.playerModel_ then
    return
  end
  local arg = {
    ...
  }
  if attrType == Z.ModelAttr.EModelCHairGradient then
    self:setModelAttr("SetLuaHairGradientAttr", table.unpack(arg))
  elseif attrType == Z.ModelAttr.EModelHairWearId then
    self:setModelAttr("SetLuaIntAttr", attrType, table.unpack(arg))
  elseif attrType == Z.ModelAttr.EModelPinchHeight then
    self:setModelAttr("SetLuaAttr", attrType, table.unpack(arg))
  else
    self:setModelAttr("SetLuaAttr", attrType, table.unpack(arg))
  end
end

function CamerasysView:setModelAttr(funcName, ...)
  local arg = {
    ...
  }
  if self.playerModel_ then
    self.playerModel_[funcName](self.playerModel_, table.unpack(arg))
  end
end

return CamerasysView
