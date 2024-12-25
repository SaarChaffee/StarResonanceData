local super = require("ui.ui_view_base")
local CamerasysView = class("CamerasysView", super)
local cameraData = Z.DataMgr.Get("camerasys_data")
local albumMainData = Z.DataMgr.Get("album_main_data")
local bigFilterPath = "ui/textures/photograph/"
local decorateData = Z.DataMgr.Get("decorate_add_data")
local CameraViewHideType = {All = 0, ShotHideControlUi = 1}
local THUMB_WIDTH = 512
local THUMB_HEIGHT = 288

function CamerasysView:ctor()
  self.panel = nil
  self.uiBinder = nil
  super.ctor(self, "camerasys")
  self.settingSubView_ = require("ui/view/camerasys_right_sub_view").new(self)
  self.joystickView_ = require("ui/view/zjoystick_view").new()
  self.decorateAddView_ = require("ui/view/decorate_add_view").new(self)
  self.posInfoList_ = {}
  self.photoTaskId_ = 0
  self.decorateModelFuncId_ = 102013
  self.isUpdateAnimSlider_ = false
  self.switchVM_ = Z.VMMgr.GetVM("switch")
  self.cameraVm = Z.VMMgr.GetVM("camerasys")
  self.expressionVm_ = Z.VMMgr.GetVM("expression")
  self.viewNodeIsShow_ = true
  self.cameraTypeActiveTog_ = nil
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function CamerasysView:OnActive()
  Z.AudioMgr:Play("UI_Button_Camera")
  self.viewNodeIsShow_ = true
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2884640, true)
  self.isTogIgnore_ = false
  self.isUnRealSceneIgnore_ = false
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
  self:initView()
  self:initBtn()
  self:addListenerPhotoShow()
  self:addListenerFuncBtn()
  self:addListenerCameraPatternTog()
  self:addListenerFovSlider()
  self:checkPhotoTask()
  self.isDefaultFov_ = true
  self.isARFov_ = true
  self.isSelfFov_ = true
  self.isChangeScheme_ = false
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncSetPersonalState(E.PersonalizationStatus.EStatusPhoto, false)
  end)()
  self:BindLuaAttrWatchers()
  self:BindEvents()
  self:RegisterInputActions()
  Z.ModelHelper.SetLookAtIKParam(Z.EntityMgr.PlayerEnt.Model, 1)
  Z.EntityMgr.PlayerEnt.Model:SetLuaAttr(Z.ModelAttr.EModelForceLook, true)
  if cameraData.CameraPatternType == E.CameraState.UnrealScene then
    local keyName = "cameraFocusHead"
    if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Body then
      keyName = "cameraFocusBody"
    end
    local modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
    local modelOffset = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(modelId)
    local modelPinchHeight = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelPinchHeight).Value
    local heightOffset = self.cameraVm.GetHeightOffSet(modelPinchHeight)
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset(keyName, Vector3.New(modelOffset.x, modelOffset.y + heightOffset, 0))
    self:calculateUnionMaskDragLimit(true)
  end
  self:setDefaultCameraShortcuts()
end

function CamerasysView:calculateUnionMaskDragLimit(isDelay)
  Z.CoroUtil.create_coro_xpcall(function()
    if isDelay then
      Z.Delay(0.7, self.cancelSource:CreateToken())
    end
    local max, min = self.cameraVm.GetUnionBgBoundsLimit(self.unionBgGO_)
    local headTrans = self.uiBinder.trans_body_mask
    if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
      headTrans = self.uiBinder.trans_head_mask
    end
    local isOk, localMax = ZTransformUtility.ScreenPointToLocalPointInRectangle(headTrans, Vector2.New(max.x, max.y), nil)
    local isOk, localMin = ZTransformUtility.ScreenPointToLocalPointInRectangle(headTrans, Vector2.New(min.x, min.y), nil)
    self.unionDragLimitMax_ = localMax
    self.unionDragLimitMin_ = localMin
  end)()
end

function CamerasysView:initView()
  if not Z.IsPCUI and cameraData.CameraPatternType ~= E.CameraState.UnrealScene then
    self.joystickView_:Active(nil, self.uiBinder.node_joystick)
  end
  self.decorateAddView_:Active(nil, self.uiBinder.node_decorate)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_decorate, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photograph_frame, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rayimg_btn, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, cameraData.CameraPatternType == E.CameraState.Default)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_rotation, cameraData.CameraPatternType == E.CameraState.Default or cameraData.CameraPatternType == E.CameraState.UnrealScene)
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
  if cameraData.CameraPatternType == E.CameraState.UnrealScene then
    local zoomRange = Z.Global.Photograph_BusinessCardCameraOffsetRangeA
    if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
      zoomRange = Z.Global.Photograph_BusinessCardCameraOffsetRangeB
    end
    Z.UnrealSceneMgr:InitSceneCamera(true)
    Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(zoomRange[1], zoomRange[2])
    self.unionBgGO_ = Z.UnrealSceneMgr:GetGOByBinderName("UnionBg")
    self.unionBgGO_:SetActive(true)
    self:createPlayerModel()
  end
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
  self.uiBinder.btn_jump.onDown:AddListener(function()
    Z.PlayerInputController:Jump(true)
  end)
  self.uiBinder.btn_jump.onUp:AddListener(function()
    Z.PlayerInputController:Jump(false)
  end)
  self.uiBinder.event_trigger_drag.onDrag:RemoveAllListeners()
  self.uiBinder.event_trigger_drag.onDrag:AddListener(function(go, eventData)
    self:onLookAtImageDrag(eventData)
  end)
  self.uiBinder.event_trigger_drag.onEndDrag:RemoveAllListeners()
  self.uiBinder.event_trigger_drag.onEndDrag:AddListener(function(go, eventData)
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
end

function CamerasysView:setPlayerMoveIgnore(isOn)
  if cameraData.IsOfficialPhotoTask then
    return
  end
  if cameraData.CameraPatternType == E.CameraState.Default then
    Z.CameraFrameCtrl.IsCameraIgnoreMove = isOn
    self.uiBinder.node_shortcut_key_move.alpha = isOn and 1 or 0.5
  end
  self.isTogIgnore_ = isOn
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
    Z.UIMgr:CloseView("camerasys")
  end)
end

function CamerasysView:takePhoto()
  if cameraData.IsBlockTakePhotoAction then
    return
  end
  self:setNodeVisible(false, CameraViewHideType.ShotHideControlUi)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
  self:hideButtonsWhenTakingPhotos(false)
  Z.UIRoot:SetClickEffectIsShow(false)
  self.cameraVm.ShowOrHideNoticePopView(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  local eventData = {}
  eventData.type = E.DecorateLayerType.CamerasysType
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.TextSizeGet, eventData)
  Z.CoroUtil.create_coro_xpcall(function()
    local oriId
    if cameraData.CameraPatternType == E.CameraState.UnrealScene then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, false)
      oriId = self:asyncTakePhotoByRect()
    else
      oriId = self:asyncGetOriPhoto()
      self.cameraVm.SendShotTLog()
    end
    if cameraData.CameraPatternType == E.CameraState.UnrealScene then
      local imgData = {textureId = oriId}
      if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Body then
        imgData.snapType = E.PictureType.EProfileHalfBody
        self.cameraVm.OpenIdCardView(self.cancelSource:CreateToken(), imgData)
      else
        imgData.snapType = E.PictureType.EProfileSnapShot
        self.cameraVm.OpenHeadView(imgData)
      end
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, true)
    else
      local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShot)
      local effectId = asyncCall(self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysView)
      local thumbId = Z.LuaBridge.ResizeTextureSizeForAlbum(effectId, E.NativeTextureCallToken.CamerasysView, THUMB_WIDTH, THUMB_HEIGHT)
      cameraData:SetMainCameraPhotoData(oriId, effectId, thumbId)
      self.cameraVm.OpenCameraPhotoMain()
    end
    Z.UIRoot:SetClickEffectIsShow(true)
    self.cameraVm.ShowOrHideNoticePopView(true)
    self:setNodeVisible(true, CameraViewHideType.ShotHideControlUi)
    self:hideButtonsWhenTakingPhotos(true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, cameraData.IsFreeFollow)
  end)()
  if self.photoTaskId_ and self.photoTaskId_ ~= 0 then
    local setGoalFinish = false
    if cameraData.IsOfficialPhotoTask then
      setGoalFinish = true
    else
      local photoConfig = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(self.photoTaskId_)
      if self.inCamera_ and photoConfig and self.nearestDistance_ > photoConfig.DistanceTake.X and self.nearestDistance_ < photoConfig.DistanceTake.Y then
        for _, value in ipairs(photoConfig.TargetId) do
          if not Z.PhotoQuestMgr:CheckPhotoQuestConditions(value) then
            break
          end
        end
        setGoalFinish = true
      end
    end
    if setGoalFinish and self.posInfoList_[self.photoTaskId_] and self.posInfoList_[self.photoTaskId_].func then
      self.posInfoList_[self.photoTaskId_].func()
    end
  end
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(E.GoalType.CameraPatternType, E.CameraTargetStage[cameraData.CameraPatternType])
  if cameraData.CameraPatternType == E.CameraState.Default or cameraData.CameraPatternType == E.CameraState.AR then
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
  if not isShow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, false)
  else
    self.uiBinder.tog_btn_hide_hud.isOn = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_btn_show_hud, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_btn_hide_btn, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, true)
  end
end

function CamerasysView:setNodeVisible(isShow, hideType)
  if cameraData.IsOfficialPhotoTask then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all_active, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_album_container, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_top_right_icon, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_slider_zoom_root, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_rotation, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shot, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_camera_btn_return, isShow)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shot, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_all_active, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_album_container, isShow)
  if isShow == false then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, isShow)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, cameraData.IsFreeFollow)
  end
  if cameraData.CameraPatternType == E.CameraState.Default then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, isShow)
  end
  if hideType == CameraViewHideType.All then
    self.viewNodeIsShow_ = isShow
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_trans, isShow)
  end
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
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Body)
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
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShot)
  local oriId = asyncCall(self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri)
  local photoWidth, photoHeight = self.cameraVm.GetTakePhotoSize()
  local resizeOriId = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysViewOri, photoWidth, photoHeight)
  Z.LuaBridge.ReleaseScreenShot(oriId)
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
  return resizeOriId
end

function CamerasysView:addListenerFuncBtn()
  local isSettingSwitch = self.switchVM_.CheckFuncSwitch(self.decorateModelFuncId_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_decorate, isSettingSwitch)
  self:AddClick(self.uiBinder.tog_btn_action, function()
    cameraData:SetTopTagIndex(E.CamerasysTopType.Action)
    self:openSettingContainerAnim()
  end)
  self:AddClick(self.uiBinder.tog_btn_decorate, function()
    cameraData:SetTopTagIndex(E.CamerasysTopType.Decorate)
    self:openSettingContainerAnim()
  end)
  self:AddClick(self.uiBinder.tog_btn_setting, function()
    cameraData:SetTopTagIndex(E.CamerasysTopType.Setting)
    self:openSettingContainerAnim()
  end)
end

function CamerasysView:addListenerCameraPatternTog()
  self.uiBinder.tog_album_icon_full_view:RemoveAllListeners()
  self.uiBinder.tog_album_icon_standard:RemoveAllListeners()
  self.uiBinder.tog_album_icon_ar:RemoveAllListeners()
  self.uiBinder.tog_album_icon_full_view.group = self.uiBinder.anim_btn_group2
  self.uiBinder.tog_album_icon_standard.group = self.uiBinder.anim_btn_group2
  self.uiBinder.tog_album_icon_ar.group = self.uiBinder.anim_btn_group2
  self:AddAsyncClick(self.uiBinder.tog_album_icon_full_view, function()
    if self.uiBinder.tog_album_icon_full_view.isOn and cameraData.CameraPatternType ~= E.CameraState.Default then
      self:setPatternType(E.CameraState.Default)
    end
  end)
  self:AddAsyncClick(self.uiBinder.tog_album_icon_standard, function()
    if self.uiBinder.tog_album_icon_standard.isOn and cameraData.CameraPatternType ~= E.CameraState.SelfPhoto then
      self:setPatternType(E.CameraState.SelfPhoto)
    end
  end)
  self:AddAsyncClick(self.uiBinder.tog_album_icon_ar, function()
    if self.uiBinder.tog_album_icon_ar.isOn and cameraData.CameraPatternType ~= E.CameraState.AR then
      self:setPatternType(E.CameraState.AR)
    end
  end)
  self.uiBinder.tog_album_icon_full_view.isOn = true
end

function CamerasysView:setPatternType(patternType)
  if patternType == E.CameraState.Default then
    local nowType = cameraData.CameraPatternType
    local valueData = {}
    valueData.nowType = cameraData.CameraPatternType
    valueData.targetType = E.CameraState.Default
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    cameraData.CameraPatternType = E.CameraState.Default
    self:changeCameraTypeAnim(nowType)
    self:updateCameraPattern()
    self.cameraTypeActiveTog_ = self.uiBinder.tog_album_icon_full_view
    local tbData_zoom = cameraData:GetCameraFOVRange()
    self.uiBinder.slider_zoom.value = self.cameraVm.GetRangePerc(tbData_zoom, self.isDefaultFov_)
    Z.TipsVM.ShowTipsLang(1000013)
    self.isDefaultFov_ = false
  elseif patternType == E.CameraState.SelfPhoto then
    if not self.cameraVm.IsEnterSelfPhoto() then
      Z.TipsVM.ShowTipsLang(1000016)
      if self.cameraTypeActiveTog_ then
        self.cameraTypeActiveTog_.isOn = true
      end
      return
    end
    local nowType = cameraData.CameraPatternType
    local valueData = {}
    valueData.nowType = cameraData.CameraPatternType
    valueData.targetType = E.CameraState.SelfPhoto
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    cameraData.CameraPatternType = E.CameraState.SelfPhoto
    self:changeCameraTypeAnim(nowType)
    self:updateCameraPattern()
    self.cameraTypeActiveTog_ = self.uiBinder.tog_album_icon_standard
    local tbData_zoom = cameraData:GetCameraFOVSelfRange()
    self.uiBinder.slider_zoom.value = self.cameraVm.GetRangePerc(tbData_zoom, self.isARFov_)
    Z.TipsVM.ShowTipsLang(1000015)
    self.isARFov_ = false
  elseif patternType == E.CameraState.AR then
    local nowType = cameraData.CameraPatternType
    local valueData = {}
    valueData.nowType = cameraData.CameraPatternType
    valueData.targetType = E.CameraState.AR
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    cameraData.CameraPatternType = E.CameraState.AR
    self:changeCameraTypeAnim(nowType)
    self:updateCameraPattern()
    self.cameraTypeActiveTog_ = self.uiBinder.tog_album_icon_ar
    local tbData_zoom = cameraData:GetCameraFOVARRange()
    self.uiBinder.slider_zoom.value = self.cameraVm.GetRangePerc(tbData_zoom, self.isSelfFov_)
    Z.TipsVM.ShowTipsLang(1000014)
    self.isSelfFov_ = false
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, patternType == E.CameraState.Default)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_player_rotation, patternType == E.CameraState.Default or patternType == E.CameraState.UnrealScene)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, patternType == E.CameraState.Default)
  self:setDefaultCameraShortcuts()
end

function CamerasysView:updateCameraPattern()
  local showData
  if cameraData.CameraPatternType == E.CameraState.Default then
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_action, true)
    showData = cameraData:GetShowEntityData()
    self:setShowEntity(showData)
  elseif cameraData.CameraPatternType == E.CameraState.SelfPhoto then
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_action, true)
    showData = cameraData:GetShowEntitySelfPhotoData()
    self:setShowEntity(showData)
  elseif cameraData.CameraPatternType == E.CameraState.AR then
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_action, false)
    showData = cameraData:GetShowEntityARData()
    self:setShowEntity(showData)
  elseif cameraData.CameraPatternType == E.CameraState.UnrealScene then
    self:setUnrealSceneState()
  end
  local oneSelfHideState = cameraData.CameraPatternType ~= E.CameraState.AR
  Z.CameraFrameCtrl:SetEntityShow(E.CamerasysShowEntityType.Oneself, oneSelfHideState)
  cameraData.IsHideSelfModel = not oneSelfHideState
  Z.CameraFrameCtrl:SetPhotoType(cameraData.CameraPatternType)
  self.cameraVm.SetCameraPatternShotSet()
  if not self.isChangeScheme_ then
    cameraData:InitTagIndex()
    return
  end
end

function CamerasysView:setDefaultCameraShortcuts()
  local isDefaultMode = cameraData.CameraPatternType == E.CameraState.Default
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, not Z.IsPCUI)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_mobile, not Z.IsPCUI)
  if isDefaultMode and Z.IsPCUI then
    self:setPlayerMoveIgnore(true)
    self.uiBinder.tog_ignore:SetIsOnWithoutCallBack(true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_shortcut_key, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_move_shortcuts, cameraData.IsOfficialPhotoTask == false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_free_shortcuts, cameraData.IsOfficialPhotoTask == false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab_shortcuts, cameraData.IsOfficialPhotoTask == false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_hide_shortcuts, cameraData.IsOfficialPhotoTask == false)
  else
    if self.isTogIgnore_ then
      self:setPlayerMoveIgnore(false)
      self.uiBinder.tog_ignore:SetIsOnWithoutCallBack(false)
    end
    Z.CameraFrameCtrl.IsCameraIgnoreMove = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_shortcut_key, Z.IsPCUI)
    if Z.IsPCUI then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_move_shortcuts, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_free_shortcuts, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_tab_shortcuts, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_hide_shortcuts, cameraData.IsOfficialPhotoTask == false)
    end
  end
end

function CamerasysView:setUnrealSceneState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_action, true)
  local showData = cameraData:GetShowEntityData()
  self:setShowEntity(showData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_ignore, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album_entrance, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_decorate, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_slider_zoom_root, false)
  self:initUnionUnrealData()
  if not self.isUnRealSceneIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 12582924, true)
    self.isUnRealSceneIgnore_ = true
  end
  local rootCanvas = Z.UIRoot.RootCanvas.transform
  local rate = 0.00925926 / rootCanvas.localScale.x
  if cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Body then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, true)
    self.uiBinder.rimg_frame_systemic:SetWidth(cameraData.BodyImgOriSize.x * rate)
    self.uiBinder.rimg_frame_systemic:SetHeight(cameraData.BodyImgOriSize.y * rate)
    self:setImgAreaClip(self.uiBinder.img_body_mask, self.uiBinder.rimg_frame_systemic)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, true)
    self.uiBinder.rimg_frame_head:SetWidth(cameraData.HeadImgOriSize.x * rate)
    self.uiBinder.rimg_frame_head:SetHeight(cameraData.HeadImgOriSize.y * rate)
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
  if cameraData.CameraPatternType == E.CameraState.Default or cameraData.CameraPatternType == E.CameraState.UnrealScene then
    tbData_zoom = cameraData:GetCameraFOVRange()
  elseif cameraData.CameraPatternType == E.CameraState.SelfPhoto then
    tbData_zoom = cameraData:GetCameraFOVSelfRange()
  elseif cameraData.CameraPatternType == E.CameraState.AR then
    tbData_zoom = cameraData:GetCameraFOVARRange()
  end
  self.uiBinder.slider_zoom:RemoveAllListeners()
  self.uiBinder.slider_zoom.value = self.cameraVm.GetRangePerc(tbData_zoom, true)
  Z.CameraFrameCtrl:SetCameraSize(tbData_zoom.define)
  self.uiBinder.slider_zoom:AddListener(function(val)
    local zoom
    if cameraData.CameraPatternType == E.CameraState.Default or cameraData.CameraPatternType == E.CameraState.UnrealScene then
      zoom = cameraData:GetCameraFOVRange()
    elseif cameraData.CameraPatternType == E.CameraState.SelfPhoto then
      zoom = cameraData:GetCameraFOVSelfRange()
    elseif cameraData.CameraPatternType == E.CameraState.AR then
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
  local model = Z.EntityMgr.MainEnt.Model
  if cameraData.CameraPatternType == E.CameraState.UnrealScene then
    model = self.playerModel_
  end
  self.rotationOffset_ = self.cameraVm.GetModelDefaultRotation(model)
  local normalizedValue = self.cameraVm.GetRotationSliderValueNormalized(self.rotationOffset_)
  self.uiBinder.slider_rotation:RemoveAllListeners()
  self.uiBinder.slider_rotation.value = normalizedValue
  self.uiBinder.lab_rotation_num.text = math.floor(normalizedValue)
  self.uiBinder.slider_rotation:AddListener(function()
    if cameraData.CameraPatternType == E.CameraState.UnrealScene then
      self:setPlayerRotation(self.playerModel_)
    else
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
  if cameraData.CameraPatternType == E.CameraState.UnrealScene then
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

function CamerasysView:OnDeActive()
  if self.unionBgGO_ then
    self.unionBgGO_:SetActive(false)
    self.unionBgGO_ = nil
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
  self:UnRegisterInputActions()
  self:UnBindEvents()
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
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2884640, false)
  self.joystickView_:DeActive()
  self.decorateAddView_:DeActive()
  self.settingSubView_:DeActive()
  if self.playerPosWatcher ~= nil then
    self.playerPosWatcher:Dispose()
    self.playerPosWatcher = nil
  end
  self:UnBindEntityLuaAttrWatcher(self.playerActorStateWatcher)
  self.playerActorStateWatcher = nil
  self.uiBinder.img_photo_rocker_bg:RemoveAllListeners()
  self.onDragFunc_ = nil
  self.onBeginDragFunc_ = nil
  self.onEndDragFunc_ = nil
  cameraData.ActiveItem = nil
  cameraData.CameraSchemeSelectId = -1
  decorateData:SetDecoreateNum(0)
  decorateData:ClearDecorateData()
  Z.CameraFrameCtrl.IsCameraIgnoreMove = false
  Z.CameraFrameCtrl:ResetCameraInitialParameters()
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncSetPersonalState(E.PersonalizationStatus.EStatusPhoto, true)
  end)()
  if cameraData.IsHideSelfModel then
    Z.CameraFrameCtrl:SetEntityShow(E.CamerasysShowEntityType.Oneself, true)
    cameraData.IsHideSelfModel = false
  end
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
end

function CamerasysView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.UpdateSettingView, self.updateNodeScrollView, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.ViewShow, self.camerasysViewShow, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateSet, self.camerasysDecorateSet, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateLayerSet, self.camerasysDecorateLayerSet, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.HurtEvent, self.camerasysHurtEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.PatternTypeEvent, self.camerasysPatternTypeEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.SwitchPatternTypeEvent, self.switchPatternTypeEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.SetFreeLookAt, self.setFreeLookAt, self)
  if Z.IsPCUI then
    Z.EventMgr:Add(Z.ConstValue.Camera.TakePhoto, self.takePhoto, self)
    Z.EventMgr:Add(Z.ConstValue.Camera.PhotoViewShowOrHide, self.photoViewShowOrHide, self)
    Z.EventMgr:Add(Z.ConstValue.Camera.PhotoPlayerMoveShield, self.photoPlayerMoveShield, self)
  end
  
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

function CamerasysView:photoPlayerMoveShield()
  if cameraData.CameraPatternType ~= E.CameraState.Default then
    return
  end
  self:setPlayerMoveIgnore(not self.isTogIgnore_)
end

function CamerasysView:setFreeLookAt(isOn)
  self.uiBinder.trans_drag.position = Vector3.zero
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, isOn)
  if isOn then
    Z.EntityMgr.PlayerEnt.Model:SetLuaAttr(Z.ModelAttr.EModelForceLook, true)
    self:updateFaceFramePos()
  else
    Z.ModelHelper.ResetLookAtIKParam(Z.EntityMgr.PlayerEnt.Model)
    Z.EntityMgr.PlayerEnt.Model:SetLuaAttr(Z.ModelAttr.EModelForceLook, false)
    Z.ModelHelper.SetLookAtTransform(Z.EntityMgr.PlayerEnt.Model, nil)
  end
end

function CamerasysView:updateFaceFramePos()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_face_frame, true)
  local headPos = Z.EntityMgr.PlayerEnt.Model:GetHeadPosition()
  local screenPosition = Z.CameraMgr.MainCamera:WorldToScreenPoint(headPos)
  local _, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(self.uiBinder.node_drag, screenPosition, nil)
  self.uiBinder.node_face_frame:SetAnchorPosition(uiPos.x, uiPos.y + 30)
end

function CamerasysView:camerasysPatternTypeEvent(patternType)
  self.isChangeScheme_ = true
  if patternType == E.CameraState.Default then
    self.uiBinder.tog_album_icon_full_view.isOn = true
  elseif patternType == E.CameraState.SelfPhoto then
    self.uiBinder.tog_album_icon_standard.isOn = true
  elseif patternType == E.CameraState.AR then
    self.uiBinder.tog_album_icon_ar.isOn = true
  end
end

function CamerasysView:camerasysHurtEvent()
  if cameraData.CameraPatternType ~= E.CameraState.SelfPhoto then
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if stateId == Z.PbEnum("EActorState", "ActorStateSelfPhoto") then
    self.uiBinder.tog_album_icon_full_view.isOn = true
  end
end

function CamerasysView:camerasysDecorateLayerSet(valueData)
  local splData = string.split(valueData.Res, "=")
  local icon = splData[1]
  local frameType = tonumber(splData[2])
  local path = string.format("%s%s", bigFilterPath, icon)
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

function CamerasysView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.UpdateSettingView, self.updateNodeScrollView, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.ViewShow, self.camerasysViewShow, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateSet, self.camerasysDecorateSet, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateLayerSet, self.camerasysDecorateLayerSet, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.HurtEvent, self.camerasysHurtEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.PatternTypeEvent, self.camerasysPatternTypeEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.SwitchPatternTypeEvent, self.switchPatternTypeEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.SetFreeLookAt, self.setFreeLookAt, self)
  if Z.IsPCUI then
    Z.EventMgr:Remove(Z.ConstValue.Camera.TakePhoto, self.takePhoto, self)
    Z.EventMgr:Remove(Z.ConstValue.Camera.PhotoViewShowOrHide, self.photoViewShowOrHide, self)
    Z.EventMgr:Remove(Z.ConstValue.Camera.PhotoPlayerMoveShield, self.photoPlayerMoveShield, self)
  end
end

function CamerasysView:setRightFuncShow(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.tog_btn_hide_hud, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shot, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_top_right_icon, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group2, isShow)
  if cameraData.CameraPatternType == E.CameraState.UnrealScene then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album_entrance, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, isShow and not Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.Jump))
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_photo_rocker_bg, isShow and cameraData.CameraPatternType == E.CameraState.Default)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_album_entrance, isShow)
  end
end

function CamerasysView:BindLuaAttrWatchers()
  if Z.EntityMgr.PlayerEnt ~= nil then
    self.playerPosWatcher = Z.DIServiceMgr.PlayerAttrComponentWatcherService:OnAttrVirtualPosChanged(function()
      self:updatePosEvent()
    end)
    self.playerActorStateWatcher = self:BindEntityLuaAttrWatcher({
      Z.LocalAttr.EAttrState
    }, Z.EntityMgr.PlayerEnt, self.updateActorStateEvent, true)
  end
end

function CamerasysView:updateActorStateEvent()
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EAttrState).Value
  if cameraData.CameraPatternType == E.CameraState.SelfPhoto then
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
    self:setFocusTargetPos(playerPos_.x, playerPos_.y, playerPos_.z)
  end
  local expressionData = Z.DataMgr.Get("expression_data")
  expressionData:ClearCurPlayData()
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

function CamerasysView:changeCameraTypeAnim(nowType)
  if nowType == E.CameraState.Default then
    if cameraData.CameraPatternType == E.CameraState.SelfPhoto then
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_2)
    elseif cameraData.CameraPatternType == E.CameraState.AR then
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_3)
    end
  elseif nowType == E.CameraState.SelfPhoto then
    if cameraData.CameraPatternType == E.CameraState.Default then
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
    elseif cameraData.CameraPatternType == E.CameraState.AR then
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_1)
    end
  elseif nowType == E.CameraState.AR then
    if cameraData.CameraPatternType == E.CameraState.SelfPhoto then
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_4)
    elseif cameraData.CameraPatternType == E.CameraState.Default then
      self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_5)
    end
  end
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
  if cameraData.IsOfficialPhotoTask then
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
    Z.UIMgr:CloseView("camerasys")
  end
end

function CamerasysView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Photograph)
end

function CamerasysView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Photograph)
end

function CamerasysView:setRightPanelVisible(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shot, isShow)
  if cameraData.CameraPatternType == E.CameraState.UnrealScene then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.anim_btn_group, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_jump, isShow)
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

function CamerasysView:onLookAtImageDrag(eventData)
  local transDragWidth, transDragHeight = 0, 0
  transDragWidth, transDragHeight = self.uiBinder.trans_drag:GetAnchorPosition(transDragWidth, transDragHeight)
  local posX, posY = self.cameraVm.PosKeepBounds(transDragWidth + eventData.delta.x, transDragHeight + eventData.delta.y)
  self.uiBinder.trans_drag:SetAnchorPosition(posX, posY)
  self:coordinateTransformation(posX, posY)
end

function CamerasysView:coordinateTransformation()
  local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.uiBinder.trans_drag.position)
  local playerPos = Z.EntityMgr.PlayerEnt.Model:GetAttrGoPosition()
  local newScreenPos = Vector3.New(screenPosition.x, screenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, playerPos))
  local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos)
  local localPosition = Z.ModelHelper.WorldPosToLocal(Z.EntityMgr.PlayerEnt.Model, worldPosition)
  localPosition.z = 0.2
  Z.ModelHelper.SetLookAtPos(Z.EntityMgr.PlayerEnt.Model, localPosition, false)
  self:updateFaceFramePos()
end

function CamerasysView:CustomClose()
  if cameraData.CameraPatternType == E.CameraState.UnrealScene then
    Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(0.2, 1.2)
    Z.UnrealSceneMgr:CloseUnrealScene("camerasys")
  end
  cameraData.CameraPatternType = E.CameraState.Default
end

function CamerasysView:UpdateAfterVisibleChanged(visible)
  Z.UIConfig[self.viewConfigKey].IsUnrealScene = cameraData.CameraPatternType == E.CameraState.UnrealScene
  super.UpdateAfterVisibleChanged(self, visible)
end

return CamerasysView
