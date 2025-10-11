local UI = Z.UI
local super = require("ui.ui_view_base")
local Camerasys_main_pcView = class("Camerasys_main_pcView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local camerasys_team_edit_tpl_ = require("ui/component/camerasys/camerasys_team_edit_tpl")
local mainui_skill_slot_obj = require("ui.player_ctrl_btns.mainui_skill_slot_obj")
local inputKeyDescComp = require("input.input_key_desc_comp")
local ActionHelper = require("camera_action.action_helper")
local Enum_EPhoto
local bigFilterPath = "ui/textures/photograph/"
local PHOTO_SIZE = {
  ThumbSize = {Width = 512, Height = 288},
  HeadSize = {Width = 300, Height = 300},
  BodySize = {Width = 468, Height = 774}
}

function Camerasys_main_pcView:ctor()
  self.uiBinder = nil
  super.ctor(self, "camerasys_main_pc")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.decorateData_ = Z.DataMgr.Get("decorate_add_data")
  self.albumMainData_ = Z.DataMgr.Get("album_main_data")
  self.expressionData_ = Z.DataMgr.Get("expression_data")
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.posInfoList_ = {}
  self.photoTaskId_ = 0
  self.decorateAddView_ = require("ui/view/decorate_add_view").new(self)
  self.fighterBtnView_ = require("ui/view/fighterbtns_view").new(self)
  self.menuContainerAction_ = require("ui/view/camera_menu_container_action_sub_pc_view").new(self)
  self.menuContainerFilter_ = require("ui/view/camera_menu_container_filter_sub_pc_view").new(self)
  self.menuContainerFrame_ = require("ui/view/camera_menu_container_frame_sub_pc_view").new(self)
  self.menuContainerShotSet_ = require("ui/view/camera_menu_container_shotset_sub_pc_view").new(self)
  self.menuContainerScheme_ = require("ui/view/camera_menu_container_scheme_sub_pc_view").new(self)
  self.menuContainerShow_ = require("ui/view/camera_menu_container_show_sub_pc_view").new(self)
  self.menuContainerSticker_ = require("ui/view/camera_menu_container_sticker_sub_pc_view").new(self)
  self.menuContainerMovieScreen_ = require("ui/view/camera_menu_container_moviescreen_sub_pc_view").new(self)
  self.menuContainerText_ = require("ui/view/camera_menu_container_text_sub_pc_view").new(self)
  self.menuContainerUnionBg_ = require("ui/view/camera_menu_container_union_bg_pc_view").new(self)
  self.menuContainerFishing_ = require("ui/view/camera_menu_container_action_fishing_sub_pc_view").new(self)
end

function Camerasys_main_pcView:OnActive()
  self:onStartAnimShow()
  self:initParam()
  self:bindEvents()
  self:initView()
  self:bindLuaAttrWatchers()
  self.isShowGamepadPoint_ = false
end

function Camerasys_main_pcView:initParam()
  self.memberData_ = {}
  self.viewNodeIsShow_ = true
  self.isSkillIgnore_ = true
  self.isTogIgnore_ = false
  self.isPlayerBloodBarIgnore_ = false
  self.mainuiSkillSlotObjs_ = {}
  self.memberLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.loop_member, camerasys_team_edit_tpl_, "camerasys_team_edit_tpl")
  self.memberLoopScrollRect_:Init({})
  self.isOpenTeamPanel_ = false
  self.isOpenLeftSettingPanel_ = true
  self.isOpenUnionPanel_ = true
  self.cameraFunctionUnit_ = {}
  self.albumPhotoIds_ = {}
  self.cameraSystemPcFunctionType_ = E.CameraSystemFunctionType.Camera
  self.leftLimitTime_ = 0
  self.rightLimitTime_ = 0
  self.rotationStep_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.PlayerRotation)
  self.expressionData_.OpenSourceType = E.ExpressionOpenSourceType.Camera
  self.isUnRealSceneIgnore_ = false
  Z.UnrealSceneMgr:ShowUnrealScene()
  self.IsPreFaceMode_ = Z.IsPreFaceMode
  self.isFashionState_ = self.cameraVM_.CheckIsFashionState()
  self.cloudGameShareContent_ = self.viewData
  self.curActiveSubView_ = nil
  self.inputKeyDescComps_ = {}
  for k, v in pairs(E.CameraSysInputKey) do
    self.inputKeyDescComps_[v] = inputKeyDescComp.new()
    self.inputKeyDescComps_[v]:SetOnRefreshCb(function()
      self:rebuildInputKeyDesc()
    end)
  end
  self.subFuncViewList_ = {
    [E.CameraSystemSubFunctionType.CommonAction] = self.menuContainerAction_,
    [E.CameraSystemSubFunctionType.LoopAction] = self.menuContainerAction_,
    [E.CameraSystemSubFunctionType.Emote] = self.menuContainerAction_,
    [E.CameraSystemSubFunctionType.Frame] = self.menuContainerFrame_,
    [E.CameraSystemSubFunctionType.Sticker] = self.menuContainerSticker_,
    [E.CameraSystemSubFunctionType.Text] = self.menuContainerText_,
    [E.CameraSystemSubFunctionType.ShotSet] = self.menuContainerMovieScreen_,
    [E.CameraSystemSubFunctionType.Filter] = self.menuContainerFilter_,
    [E.CameraSystemSubFunctionType.Show] = self.menuContainerShow_,
    [E.CameraSystemSubFunctionType.Scheme] = self.menuContainerScheme_,
    [E.CameraSystemSubFunctionType.UnionBg] = self.menuContainerUnionBg_,
    [E.CameraSystemSubFunctionType.Fishing] = self.menuContainerFishing_
  }
end

function Camerasys_main_pcView:resetModelLookAt()
  if self.cameraVM_.CheckIsFashionState() then
    return
  end
  Z.ModelHelper.ResetLookAtIKParam(Z.EntityMgr.PlayerEnt.Model)
  Z.EntityMgr.PlayerEnt.Model:SetLuaAttrLookAtEyeOpen(false)
  Z.ModelHelper.SetLookAtTransform(Z.EntityMgr.PlayerEnt.Model, nil)
  self.cameraVM_.SetHeadLookAt(false)
end

function Camerasys_main_pcView:setFreeLookAt(isOn, isHead)
  if isHead then
    self.uiBinder.head_trans_drag.position = Vector3.zero
    if isOn then
      self:updateFaceFramePos()
    end
  else
    self.uiBinder.eyes_trans_drag.position = Vector3.zero
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.eyes_trans_drag, self.cameraData_.IsEyeFollow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.head_trans_drag, self.cameraData_.IsHeadFollow)
  if self.cameraData_.IsEyeFollow == false and self.cameraData_.IsHeadFollow == false then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, true)
  end
end

function Camerasys_main_pcView:OnDeActive()
  if self.isShowGamepadPoint_ then
    self.isShowGamepadPoint_ = false
    Z.MouseMgr:SetMouseVisibleSource(Panda.ZInput.EMouseLockSource.TakePhoto, self.isShowGamepadPoint_)
    if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick and Z.IgnoreMgr:IsIgnore(Panda.ZGame.EIgnoreType.InputMask, Panda.ZGame.EInputMask.Move:ToInt()) then
      Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 5, false)
    end
  end
  Z.AudioMgr:Play("UI_Menu_QuickInstruction_Close")
  for k, v in pairs(self.inputKeyDescComps_) do
    if v then
      v:UnInit()
    end
  end
  self.inputKeyDescComps_ = {}
  self.cameraData_:ClearFaceModelInfo()
  self.cameraData_:SetSettingViewSecondaryLogicIndex(-1)
  self:resetCameraPostProcessing()
  self.firstLevelTabUiBinder_ = {}
  if #self.albumPhotoIds_ ~= 0 then
    for k, v in ipairs(self.albumPhotoIds_) do
      Z.LuaBridge.ReleaseScreenShot(v)
    end
    self.albumPhotoIds_ = {}
  end
  for k, v in pairs(self.subFuncViewList_) do
    if v.IsActive then
      v:DeActive()
    end
  end
  self:removeUnit()
  if self.curActiveSubView_ then
    self.curActiveSubView_:DeActive()
  end
  self.curActiveSubView_ = nil
  self:resetModelLookAt()
  if not self.isSkillIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2883584, false)
  else
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2884640, false)
  end
  self.decorateAddView_:DeActive()
  self.fighterBtnView_:DeActive()
  self:unBindEvents()
  self:UnBindEntityLuaAttrWatcher(self.buffWatcher)
  if self.cameraData_.IsHideCameraMember then
    Z.CameraFrameCtrl:SetEntityShow(E.CameraSystemShowEntityType.CameraTeamMember, true)
    self.cameraData_.IsHideCameraMember = false
  end
  self.cameraMemberVM_:SaveMemberListData()
  self.cameraMemberData_:ClearMemberModel()
  self.cameraMemberData_.MemberListData = {}
  self.cameraMemberVM_:ExitCameraView()
  if self.isPlayerBloodBarIgnore_ then
    Z.IgnoreMgr:SetBattleUIIgnore(Panda.ZGame.EBattleUIMask.Blood, false, Panda.ZGame.EIgnoreMaskSource.EUIView)
    self.isPlayerBloodBarIgnore_ = false
  end
  self:resetUnionMode()
  self.cameraVM_.IsUpdateWeatherByServer(true)
  self.cameraData_:ResetHeadAndEyesFollow()
  Z.LuaBridge.SetHudSwitch(true)
  self.cameraVM_.ResetEntityVisible()
  self:resetPhotoTaskInfo()
  if self.playerPosWatcher ~= nil then
    self.playerPosWatcher:Dispose()
    self.playerPosWatcher = nil
  end
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
  self.buffWatcher = nil
  self.onDragFunc_ = nil
  self.onBeginDragFunc_ = nil
  self.onEndDragFunc_ = nil
  self.cameraData_.ActiveItem = nil
  self.cameraData_.CameraSchemeSelectId = -1
  self.decorateData_:SetDecoreateNum(0)
  self.decorateData_:ClearDecorateData()
  Z.CameraFrameCtrl:ResetCameraInitialParameters(self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto)
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncSetPersonalState(E.PersonalizationStatus.EStatusPhoto, true)
  end)()
  if self.memberLoopScrollRect_ then
    self.memberLoopScrollRect_:UnInit()
    self.memberLoopScrollRect_ = nil
  end
  if self.cameraData_.IsHideSelfModel then
    Z.CameraFrameCtrl:SetEntityShow(E.CameraSystemShowEntityType.Oneself, true)
    self.cameraData_.IsHideSelfModel = false
  end
  self.cameraData_:ResetCameraSetting()
  self:clearSkillBinder()
  if not self.viewNodeIsShow_ then
    self:showOrHideView(true)
  end
  if Z.EntityMgr.PlayerEnt then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    if stateId == Z.PbEnum("EActorState", "ActorStateAction") then
      Z.ZAnimActionPlayMgr:ResetAction()
    end
  end
end

function Camerasys_main_pcView:resetCameraPostProcessing()
  self.cameraData_.IsDepthTag = false
  self.cameraData_.IsFocusTag = false
  self.cameraData_.WorldTime = -1
end

function Camerasys_main_pcView:clearSkillBinder()
  for _, value in ipairs(self.mainuiSkillSlotObjs_) do
    value:DeActive()
  end
  self.mainuiSkillSlotObjs_ = {}
end

function Camerasys_main_pcView:removeUnit()
  if self.cameraFunctionUnit_ then
    for k, v in pairs(self.cameraFunctionUnit_) do
      self:RemoveUiUnit(v.name)
    end
    self.cameraFunctionUnit_ = {}
  end
end

function Camerasys_main_pcView:OnRefresh()
end

function Camerasys_main_pcView:OnMountsTrigger()
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
    return false
  end
  local mainUIVM = Z.VMMgr.GetVM("mainui")
  mainUIVM.GotoMainUIFunc(E.FunctionID.VehicleRide)
end

function Camerasys_main_pcView:initView()
  Z.AudioMgr:Play("UI_Button_Camera")
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 2884640, true)
  self:setAlbumBtn()
  Z.CameraFrameCtrl:RecordCameraInitialParameters()
  self:initUI()
  self:initBtn()
  self.decorateData_:InitMoviescreenData()
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncSetPersonalState(E.PersonalizationStatus.EStatusPhoto, false)
  end)()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initCameraMember()
  end)()
end

function Camerasys_main_pcView:initUI()
  self.decorateAddView_:Active(nil, self.uiBinder.node_decorate)
  if not self.isFashionState_ then
    self.fighterBtnView_:Active(nil, self.uiBinder.node_joystick)
    self.fighterBtnView_:SetPlayerStateNodeIsShow(false)
    self.fighterBtnView_:Hide()
  end
  self:setRightPanelVisible(true)
  self.firstLevelTabUiBinder_ = {
    [E.CameraSystemFunctionType.Camera] = self.uiBinder.tog_camera,
    [E.CameraSystemFunctionType.Action] = self.uiBinder.tog_action,
    [E.CameraSystemFunctionType.Setting] = self.uiBinder.tog_setting,
    [E.CameraSystemFunctionType.Decorations] = self.uiBinder.tog_filter
  }
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_decorate, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_photograph_frame, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_left, self.isOpenLeftSettingPanel_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_unlock, self.cameraData_.IsOfficialPhotoTask)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, false)
  if self.cameraData_.HeadImgOriSize then
    self.uiBinder.rimg_frame_head:SetSizeDelta(self.cameraData_.HeadImgOriSize.x, self.cameraData_.HeadImgOriSize.y)
  end
  if self.cameraData_.BodyImgOriSize then
    self.uiBinder.rimg_frame_systemic:SetSizeDelta(self.cameraData_.BodyImgOriSize.x, self.cameraData_.BodyImgOriSize.y)
  end
  if self.cameraData_.HeadImgOriPos then
    self.uiBinder.rimg_frame_head.anchoredPosition = self.cameraData_.HeadImgOriPos
  end
  if self.cameraData_.BodyImgOriPos then
    self.uiBinder.rimg_frame_systemic.anchoredPosition = self.cameraData_.BodyImgOriPos
  end
  self:setUnionMode()
  self:refreshResonanceSkill()
  self:initLandscapePhotoMode()
  self:setKeyboardShortcuts()
end

function Camerasys_main_pcView:initBtn()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self.uiBinder.tog_default:RemoveAllListeners()
  self.uiBinder.tog_self:RemoveAllListeners()
  self.uiBinder.tog_ar:RemoveAllListeners()
  self.uiBinder.tog_default.isOn = false
  self.uiBinder.tog_default:AddListener(function(isOn)
    if isOn and self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto then
      self:setPatternType(E.TakePhotoSate.Default)
    end
  end)
  self.uiBinder.tog_self.isOn = false
  self.uiBinder.tog_self:AddListener(function(isOn)
    if isOn then
      self:setPatternType(E.TakePhotoSate.SelfPhoto)
    end
  end)
  self.uiBinder.tog_ar.isOn = false
  self.uiBinder.tog_ar:AddListener(function(isOn)
    if isOn then
      if not UnityEngine.SystemInfo.supportsGyroscope then
        Z.TipsVM.ShowTipsLang(1000055)
      end
      self:setPatternType(E.TakePhotoSate.AR)
    end
  end)
  self.uiBinder.tog_battle:RemoveAllListeners()
  self.uiBinder.tog_battle.isOn = false
  self.uiBinder.tog_battle:AddListener(function(isOn)
    if isOn then
      if self.cameraVM_.BanSkill() then
        self.uiBinder.tog_battle:SetIsOnWithoutCallBack(false)
        self.uiBinder.tog_default.isOn = true
        Z.TipsVM.ShowTipsLang(1000043)
        return
      end
      if self.cameraData_.CameraPatternType ~= E.TakePhotoSate.Battle then
        self:setPatternType(E.TakePhotoSate.Battle)
      end
    end
  end)
  self:AddClick(self.uiBinder.btn_arrow_left, function()
    self:setPlayerRotation(true)
  end)
  self:AddClick(self.uiBinder.btn_arrow_right, function()
    self:setPlayerRotation(false)
  end)
  self:EventAddAsyncListener(self.uiBinder.btn_arrow_left.OnLongPressUpdateEvent, function(deltaTime)
    if self.leftLimitTime_ >= 0.03 then
      self:setPlayerRotation(true)
      self.leftLimitTime_ = 0
    else
      self.leftLimitTime_ = self.leftLimitTime_ + deltaTime
    end
  end)
  self:EventAddAsyncListener(self.uiBinder.btn_arrow_right.OnLongPressUpdateEvent, function(deltaTime)
    if self.rightLimitTime_ >= 0.03 then
      self:setPlayerRotation(false)
      self.rightLimitTime_ = 0
    else
      self.rightLimitTime_ = self.rightLimitTime_ + deltaTime
    end
  end)
  self:AddClick(self.uiBinder.btn_album, function()
    Z.UIMgr:OpenView("album_main", E.AlbumOpenSource.Album)
  end)
  self:AddClick(self.uiBinder.btn_add, function()
    Z.UIMgr:OpenView("camera_invited_photo_popup")
  end)
  self.uiBinder.tog_disband_team:RemoveAllListeners()
  self.uiBinder.tog_disband_team:AddListener(function(isOn)
    self.cameraMemberVM_:SetDisbandTeam(isOn)
  end)
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
  self.uiBinder.event_trigger_frame_systemic.onBeginDrag:RemoveAllListeners()
  self.uiBinder.event_trigger_frame_systemic.onBeginDrag:AddListener(function(go, pointerData)
    self:calculateUnionMaskDragLimit()
  end)
  self.uiBinder.event_trigger_frame_head.onBeginDrag:RemoveAllListeners()
  self.uiBinder.event_trigger_frame_head.onBeginDrag:AddListener(function(go, pointerData)
    self:calculateUnionMaskDragLimit()
  end)
  self.uiBinder.event_trigger_frame_systemic.onDrag:RemoveAllListeners()
  self.uiBinder.event_trigger_frame_systemic.onDrag:AddListener(function(go, pointerData)
    self:unionImgMove(self.uiBinder.img_body_mask, self.uiBinder.rimg_frame_systemic, pointerData)
  end)
  self.uiBinder.event_trigger_frame_head.onDrag:RemoveAllListeners()
  self.uiBinder.event_trigger_frame_head.onDrag:AddListener(function(go, pointerData)
    self:unionImgMove(self.uiBinder.img_head_mask, self.uiBinder.rimg_frame_head, pointerData)
  end)
  self:AddClick(self.uiBinder.btn_camera_team_edit, function()
    self:setRightPanelVisible(not self.isOpenTeamPanel_)
  end)
  self:AddClick(self.uiBinder.btn_sys_camera, function()
    self:setLeftSettingPanelVisible()
  end)
  self:AddClick(self.uiBinder.btn_union_member, function()
    self:setUnionPanelVisible(not self.isOpenUnionPanel_)
  end)
  self.uiBinder.tog_action:RemoveAllListeners()
  self.uiBinder.tog_camera:RemoveAllListeners()
  self.uiBinder.tog_setting:RemoveAllListeners()
  self.uiBinder.tog_action:SetIsOnWithoutNotify(false)
  self.uiBinder.tog_camera:SetIsOnWithoutNotify(false)
  self.uiBinder.tog_setting:SetIsOnWithoutNotify(false)
  self.uiBinder.tog_action:AddListener(function(isOn)
    if isOn then
      Z.CoroUtil.create_coro_xpcall(function()
        self:loadLeftFunctionBtn(E.CameraSystemFunctionType.Action)
      end)()
    end
  end)
  self.uiBinder.tog_camera:AddListener(function(isOn)
    if isOn then
      Z.CoroUtil.create_coro_xpcall(function()
        self:loadLeftFunctionBtn(E.CameraSystemFunctionType.Camera)
      end)()
    end
  end)
  self.uiBinder.tog_setting:AddListener(function(isOn)
    if isOn then
      Z.CoroUtil.create_coro_xpcall(function()
        self:loadLeftFunctionBtn(E.CameraSystemFunctionType.Setting)
      end)()
    end
  end)
  self.uiBinder.tog_filter:RemoveAllListeners()
  self.uiBinder.tog_filter:SetIsOnWithoutNotify(false)
  self.uiBinder.tog_filter:AddListener(function(isOn)
    if isOn then
      Z.CoroUtil.create_coro_xpcall(function()
        self:loadLeftFunctionBtn(E.CameraSystemFunctionType.Decorations)
      end)()
    end
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
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self:setPatternType(E.TakePhotoSate.UnionTakePhoto)
    return
  end
  self.uiBinder.tog_camera.isOn = true
  self.uiBinder.tog_camera:SetIsOnWithoutNotify(true)
  self.uiBinder.tog_default.isOn = true
  self:loadLeftFunctionBtn(E.CameraSystemFunctionType.Camera)
  local isDisbandTeam = self.cameraMemberData_.IsDisbandTeam
  self.uiBinder.tog_disband_team.IsOn = isDisbandTeam
end

function Camerasys_main_pcView:setAlbumBtn()
  local photoData = self.albumMainData_:GetTemporaryAlbumPhoto()
  if photoData == nil or #photoData == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_photo, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_photo, true)
  for i = 1, 3 do
    local data = photoData[i]
    if not data then
      self.uiBinder["rimg_photo_" .. i]:ClearNativeTexture()
      self.uiBinder["rimg_photo_" .. i]:SetColor(Color.black)
    else
      self.uiBinder["rimg_photo_" .. i]:SetColor(Color.white)
      self:getLocalPhoto(i, data.tempThumbPhoto)
    end
  end
end

function Camerasys_main_pcView:getLocalPhoto(k, path)
  local photoId = Z.CameraFrameCtrl:ReadTextureToSystemAlbum(path, E.NativeTextureCallToken.CamerasysView)
  if photoId == 0 then
    return
  end
  table.insert(self.albumPhotoIds_, photoId)
  self.uiBinder["rimg_photo_" .. k]:SetNativeTexture(photoId)
end

function Camerasys_main_pcView:setPatternType(patternType)
  local valueData = {
    nowType = self.cameraData_.CameraPatternType,
    targetType = E.TakePhotoSate.Default
  }
  if patternType == E.TakePhotoSate.Default or patternType == E.TakePhotoSate.Battle then
    self.cameraData_.CameraPatternType = patternType
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    self:updateCameraPattern()
    local tipsConfigId = patternType == E.TakePhotoSate.Battle and 1000044 or 1000013
    Z.TipsVM.ShowTipsLang(tipsConfigId)
    if patternType == E.TakePhotoSate.Battle then
      self.fighterBtnView_:Show()
    else
      self.fighterBtnView_:Hide()
    end
    self:refreshFightView(patternType)
  elseif patternType == E.TakePhotoSate.SelfPhoto then
    if not self.cameraVM_.IsEnterSelfPhoto() then
      Z.TipsVM.ShowTipsLang(1000016)
      self.uiBinder.tog_default.isOn = true
      return
    end
    valueData.targetType = E.TakePhotoSate.SelfPhoto
    self.cameraData_.CameraPatternType = E.TakePhotoSate.SelfPhoto
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    self:updateCameraPattern()
    Z.TipsVM.ShowTipsLang(1000015)
    self.fighterBtnView_:Hide()
  elseif patternType == E.TakePhotoSate.AR then
    valueData.targetType = E.TakePhotoSate.AR
    self.cameraData_.CameraPatternType = E.TakePhotoSate.AR
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeChange, valueData)
    self:updateCameraPattern()
    Z.TipsVM.ShowTipsLang(1000014)
    self.fighterBtnView_:Hide()
  elseif patternType == E.TakePhotoSate.UnionTakePhoto then
    self:updateCameraPattern()
    self.fighterBtnView_:Hide()
  end
  self.cameraVM_.SetCameraFov()
  self:onCameraPatternChanged()
end

function Camerasys_main_pcView:refreshFightView(patternType)
  if patternType == E.TakePhotoSate.Default then
    if not self.isSkillIgnore_ then
      Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 1056, true)
      self.isSkillIgnore_ = true
    end
  elseif patternType == E.TakePhotoSate.Battle and self.isSkillIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 1056, false)
    self.isSkillIgnore_ = false
  end
end

function Camerasys_main_pcView:updateCameraPattern()
  local showData
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.Default or self.cameraData_.CameraPatternType == E.TakePhotoSate.Battle then
    showData = self.cameraData_:GetShowEntityData()
    self.cameraVM_.SetShowEntity(showData)
  elseif self.cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    showData = self.cameraData_:GetShowEntitySelfPhotoData()
    self.cameraVM_.SetShowEntity(showData)
  elseif self.cameraData_.CameraPatternType == E.TakePhotoSate.AR then
    showData = self.cameraData_:GetShowEntityARData()
    self.cameraVM_.SetShowEntity(showData)
  elseif self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self:setUnrealSceneState()
  end
  local oneSelfHideState = self.cameraData_.CameraPatternType ~= E.TakePhotoSate.AR
  if not self.cameraVM_.CheckIsFashionState() then
    Z.CameraFrameCtrl:SetEntityShow(E.CameraSystemShowEntityType.Oneself, oneSelfHideState)
  end
  self.cameraData_.IsHideSelfModel = not oneSelfHideState
  local cameraStateType = self.cameraVM_.ConversionTakePhotoType(self.cameraData_.CameraPatternType)
  Z.CameraFrameCtrl:SetPhotoType(cameraStateType)
  self.cameraVM_.SetCameraPatternShotSet()
end

function Camerasys_main_pcView:bindLuaAttrWatchers()
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

function Camerasys_main_pcView:updatePosEvent()
  if not self.cameraData_.IsFocusTag and self.cameraData_.IsDepthTag then
    local x, y, z = self.cameraVM_.GetPlayerPos()
    Z.CameraFrameCtrl:SetFocusTargetPos(x, y, z)
  end
  self:getNearestPointInfo()
end

function Camerasys_main_pcView:onBuffChange()
  local isBanSkill = self.cameraVM_.BanSkill()
  if isBanSkill and self.cameraData_.CameraPatternType == E.TakePhotoSate.Battle then
    self:setPatternType(E.TakePhotoSate.Default)
  end
end

function Camerasys_main_pcView:updateActorStateEvent()
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.PlayerStateChanged)
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    if stateId == Z.PbEnum("EActorState", "ActorStateDefault") then
      local canSwitchStateList = {
        Z.PbEnum("EMoveType", "MoveIdle"),
        Z.PbEnum("EMoveType", "MoveWalk"),
        Z.PbEnum("EMoveType", "MoveRun")
      }
      local moveType = Z.EntityMgr.PlayerEnt:GetLuaAttrVirtualMoveType()
      for k, v in pairs(canSwitchStateList) do
        if v ~= moveType then
          self.uiBinder.tog_default.isOn = true
        end
      end
    elseif stateId == Z.PbEnum("EActorState", "ActorStateSelfPhoto") or Z.EntityMgr.PlayerEnt.IsRiding == true then
    else
      self.uiBinder.tog_default.isOn = true
    end
  end
  if stateId == Z.PbEnum("EActorState", "ActorStateDead") or stateId == Z.PbEnum("EActorState", "ActorStateResurrection") then
    Z.UIMgr:CloseView(self.viewConfigKey)
  end
end

function Camerasys_main_pcView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateSet, self.cameraDecorateSet, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateLayerSet, self.camerasysDecorateLayerSet, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.SwitchPatternTypeEvent, self.switchPatternTypeEvent, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.SetFreeLookAt, self.setFreeLookAt, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.TakePhoto, self.takePhoto, self)
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionBtnState, self.refreshResonanceSkill, self)
  Z.EventMgr:Add(Z.ConstValue.CameraMember.CameraMemberListUpdate, self.refreshMemberLoop, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.SaveLocalPhoto, self.setAlbumBtn, self)
  Z.EventMgr:Add(Z.ConstValue.CameraMember.CameraMemberDataUpdate, self.updateMemberData, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.PhotoPcLeftViewShowOrHide, self.setLeftSettingPanelVisible, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.PhotoPcRightViewShowOrHide, self.setRightPanelIsShow, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.PhotoViewShowOrHide, self.photoViewShowOrHide, self)
  Z.EventMgr:Add(Z.ConstValue.Expression.ClickAction, self.onActionPlay, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.ActionReset, self.resetAction, self)
  Z.EventMgr:Add(Z.ConstValue.FaceAttrChange, self.onFaceAttrChange, self)
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.onDeViceTypeChange, self)
end

function Camerasys_main_pcView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateSet, self.cameraDecorateSet, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateLayerSet, self.camerasysDecorateLayerSet, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.SwitchPatternTypeEvent, self.switchPatternTypeEvent, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.SetFreeLookAt, self.setFreeLookAt, self)
  Z.EventMgr:Remove(Z.ConstValue.RefreshFunctionBtnState, self.refreshResonanceSkill, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.TakePhoto, self.takePhoto, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.PhotoViewShowOrHide, self.photoViewShowOrHide, self)
  Z.EventMgr:Remove(Z.ConstValue.CameraMember.CameraMemberListUpdate, self.refreshMemberLoop, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.SaveLocalPhoto, self.setAlbumBtn, self)
  Z.EventMgr:Remove(Z.ConstValue.CameraMember.CameraMemberDataUpdate, self.updateMemberData, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.PhotoPcLeftViewShowOrHide, self.setLeftSettingPanelVisible, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.PhotoPcRightViewShowOrHide, self.setRightPanelIsShow, self)
  Z.EventMgr:Remove(Z.ConstValue.Expression.ClickAction, self.onActionPlay, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.ActionReset, self.resetAction, self)
  Z.EventMgr:Remove(Z.ConstValue.FaceAttrChange, self.onFaceAttrChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Device.DeviceTypeChange, self.onDeViceTypeChange, self)
end

function Camerasys_main_pcView:photoViewShowOrHide()
  if self.cameraData_.IsOfficialPhotoTask or self.isFashionState_ then
    return
  end
  self:showOrHideView(not self.viewNodeIsShow_)
end

function Camerasys_main_pcView:showOrHideView(isShow)
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_union_right, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_left, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_up, isShow)
    self.viewNodeIsShow_ = isShow
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_member_right, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_left, isShow)
  self.uiBinder.node_function.Ref.UIComp:SetVisible(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_up, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_joystick, isShow)
  if isShow == false then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, isShow)
  else
    local shouldShowDrag = self.cameraData_.IsEyeFollow or self.cameraData_.IsHeadFollow
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, shouldShowDrag)
  end
  self.viewNodeIsShow_ = isShow
end

function Camerasys_main_pcView:setTakePhotoNodeVisible(isShow)
  if self.cameraData_.IsOfficialPhotoTask then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_joystick, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_member_right, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_pattern, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_pattern_right, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_move_key, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_hide_key, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_translation_key, false)
    self.uiBinder.node_function.Ref.UIComp:SetVisible(false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_left, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_unlock, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, isShow)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_pattern_left, isShow)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_left, isShow)
  self.uiBinder.node_function.Ref.UIComp:SetVisible(isShow and self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_up, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_joystick, isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_member_right, isShow and self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_union_right, isShow and self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, isShow and self.cameraVM_.CheckIsFashionState())
end

function Camerasys_main_pcView:takePhoto()
  local focusViewConfigKey = Z.UIMgr:GetFocusViewConfigKey()
  if focusViewConfigKey == nil or focusViewConfigKey ~= self.viewConfigKey then
    return
  end
  self:setTakePhotoNodeVisible(false)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
  Z.UIRoot:SetClickEffectIsShow(false)
  self.cameraVM_.ShowOrHideNoticePopView(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  Z.CoroUtil.create_coro_xpcall(function()
    local oriId = self:asyncTakePhoto()
    if not oriId or oriId == 0 then
      self:resetUI()
      return
    end
    if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
      if self.isFashionState_ then
        self:handleFashion(oriId)
      else
        self:handleUnrealScene(oriId)
      end
    else
      self:handleNormalScene(oriId)
    end
    self:resetUI()
  end)()
  if self:shouldFinishPhotoTask() then
    self:executePhotoTaskCompletion()
  end
  self:trackCameraPattern()
  self:setMultiPlayerPhotoTargetFinish()
end

function Camerasys_main_pcView:trackCameraPattern()
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(E.GoalType.CameraPatternType, E.CameraTargetStage[self.cameraData_.CameraPatternType])
end

function Camerasys_main_pcView:asyncTakePhoto()
  Z.AudioMgr:Play("sys_camera_photo")
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return self:asyncTakePhotoByRect()
  else
    self.cameraVM_.SendShotTLog()
    return self:asyncGetOriPhoto()
  end
end

function Camerasys_main_pcView:asyncTakePhotoByRect()
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.AllDecorateVisible, false)
  local frameLBV = self.uiBinder.Ref:GetUIComp(self.uiBinder.rimg_frame_layer_big).IsVisible
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
  local frameFBV = self.uiBinder.Ref:GetUIComp(self.uiBinder.rimg_frame_fill_big).IsVisible
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, false)
  local rectTransform = self.uiBinder.rimg_frame_systemic
  if self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
    rectTransform = self.uiBinder.rimg_frame_head
  end
  local offset = Vector2.New(Z.UIRoot.CurCanvasSize.x / 2, Z.UIRoot.CurCanvasSize.y / 2)
  local rectPosX = -rectTransform.rect.width / 2 + rectTransform.anchoredPosition.x + offset.x
  local rectPosY = -rectTransform.rect.height / 2 + rectTransform.anchoredPosition.y + offset.y
  local widthScale = Z.UIRoot.CurScreenSize.x / Z.UIRoot.CurCanvasSize.x
  local heightScale = Z.UIRoot.CurScreenSize.y / Z.UIRoot.CurCanvasSize.y
  local oriId = asyncCall(Z.UIRoot.CurScreenSize.x, Z.UIRoot.CurScreenSize.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysViewOri, rectPosX * widthScale, rectPosY * heightScale, rectTransform.rect.width * widthScale, rectTransform.rect.height * heightScale)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.AllDecorateVisible, true)
  local data = self.decorateData_:GetMoviescreenData()
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
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Body or self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Fashion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Head)
  return oriId
end

function Camerasys_main_pcView:asyncGetOriPhoto()
  Z.CameraFrameCtrl:ReductionFrameData()
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.AllDecorateVisible, false)
  local frameLBV = self.uiBinder.Ref:GetUIComp(self.uiBinder.rimg_frame_layer_big).IsVisible
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_layer_big, false)
  local frameFBV = self.uiBinder.Ref:GetUIComp(self.uiBinder.rimg_frame_fill_big).IsVisible
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_frame_fill_big, false)
  local photoWidth, photoHeight = self.cameraVM_.GetTakePhotoSize()
  local rect = self:getScreenshotRect(photoWidth, photoHeight)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  local oriId = asyncCall(Z.UIRoot.CurScreenSize.x, Z.UIRoot.CurScreenSize.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysView, rect.x, rect.y, photoWidth, photoHeight)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.AllDecorateVisible, true)
  local data = self.decorateData_:GetMoviescreenData()
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

function Camerasys_main_pcView:checkCameraTarget()
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
  local resArray = Z.LuaBridge.CheckEntityShowInCameraByConfigId(entityTypeArray, entityConfigIdArray, self.uiBinder.node_scenicspor_photo_far)
  if resArray then
    for index = 0, resArray.Length - 1 do
      if resArray[index] and checkList[keys[index + 1]].func then
        checkList[keys[index + 1]].func()
      end
    end
  end
end

function Camerasys_main_pcView:setMultiPlayerPhotoTargetFinish()
  local memberDatas = self.cameraMemberData_:AssemblyMemberListData(true)
  local memberCnt = table.zcount(memberDatas)
  if 1 < memberCnt then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.TargetMultiPlayerPhoto, memberCnt)
  end
end

function Camerasys_main_pcView:resetUI()
  Z.UIRoot:SetClickEffectIsShow(true)
  self.cameraVM_.ShowOrHideNoticePopView(true)
  self:setTakePhotoNodeVisible(true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, self.cameraData_.IsFreeFollow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_qrcode, false)
end

function Camerasys_main_pcView:handleNormalScene(oriId)
  local photoWidth, photoHeight = self.cameraVM_.GetTakePhotoSize()
  local rect = self:getScreenshotRect(photoWidth, photoHeight)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.TakeScreenShotByAspectWithRect)
  local effectId = asyncCall(Z.UIRoot.CurScreenSize.x, Z.UIRoot.CurScreenSize.y, self.cancelSource:CreateToken(), E.NativeTextureCallToken.CamerasysView, rect.x, rect.y, photoWidth, photoHeight)
  if photoWidth > Z.UIRoot.DESIGNSIZE_WIDTH or photoHeight > Z.UIRoot.DESIGNSIZE_HEIGHT then
    oriId, effectId = self:getResizeTexture(oriId, effectId)
  end
  local thumbId = Z.LuaBridge.ResizeTextureSizeForAlbum(effectId, E.NativeTextureCallToken.CamerasysView, PHOTO_SIZE.ThumbSize.Width, PHOTO_SIZE.ThumbSize.Height)
  self.cameraData_:SetMainCameraPhotoData(oriId, effectId, thumbId)
  self.cameraVM_.OpenCameraPhotoMain(self.cloudGameShareContent_)
end

function Camerasys_main_pcView:getScreenshotRect(photoWidth, photoHeight)
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

function Camerasys_main_pcView:getResizeTexture(oriId, effectId, photoWidth, photoHeight)
  local designWidth = Z.UIRoot.DESIGNSIZE_WIDTH
  local designHeight = Z.UIRoot.DESIGNSIZE_HEIGHT
  local resizeOriId = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysView, designWidth, designHeight)
  local resizeEffectId = Z.LuaBridge.ResizeTextureSizeForAlbum(effectId, E.NativeTextureCallToken.CamerasysView, designWidth, designHeight)
  Z.LuaBridge.ReleaseScreenShot(oriId)
  Z.LuaBridge.ReleaseScreenShot(effectId)
  return resizeOriId, resizeEffectId
end

function Camerasys_main_pcView:switchPatternTypeEvent(patternType)
  if self.cameraData_.CameraPatternType ~= patternType then
    self:setPatternType(patternType)
  end
end

function Camerasys_main_pcView:cameraDecorateSet(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_decorate, true)
  local dec_ = require("ui/view/camera_decorate_controller_item").new()
  dec_:Active(data, self.uiBinder.node_item)
end

function Camerasys_main_pcView:camerasysDecorateLayerSet(valueData)
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

function Camerasys_main_pcView:camerasysHurtEvent()
  if self.cameraData_.CameraPatternType ~= E.TakePhotoSate.SelfPhoto then
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
  if stateId == Z.PbEnum("EActorState", "ActorStateSelfPhoto") then
    self.uiBinder.tog_default.isOn = true
  end
end

function Camerasys_main_pcView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.Mounts then
    self:OnMountsTrigger()
  elseif inputActionEventData.ActionId == Z.InputActionIds.PhotoGamepadPointVisible then
    self.isShowGamepadPoint_ = not self.isShowGamepadPoint_
    Z.MouseMgr:SetMouseVisibleSource(Panda.ZInput.EMouseLockSource.TakePhoto, self.isShowGamepadPoint_)
    self:onPhotoGamepadPointVisibleTrigger()
  end
end

function Camerasys_main_pcView:onDeViceTypeChange(...)
  self:onPhotoGamepadPointVisibleTrigger()
end

function Camerasys_main_pcView:onPhotoGamepadPointVisibleTrigger()
  if Enum_EPhoto == nil then
    Enum_EPhoto = Panda.ZGame.EIgnoreMaskSource.EPhoto:ToInt()
  end
  if Z.InputMgr.InputDeviceType == Panda.ZInput.EInputDeviceType.Joystick then
    if self.isShowGamepadPoint_ ~= Z.IgnoreMgr:IsIgnore(Panda.ZGame.EIgnoreType.InputMask, Panda.ZGame.EInputMask.Move:ToInt()) then
      Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 5, self.isShowGamepadPoint_)
    end
  elseif self.isShowGamepadPoint_ and Z.IgnoreMgr:IsIgnore(Panda.ZGame.EIgnoreType.InputMask, Panda.ZGame.EInputMask.Move:ToInt()) then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 5, false)
  end
end

function Camerasys_main_pcView:resetCameraPostProcessing()
  self.cameraData_.IsDepthTag = false
  self.cameraData_.IsFocusTag = false
  self.cameraData_.WorldTime = -1
end

function Camerasys_main_pcView:initUnionUnrealData()
  self.cameraData_.BodyImgOriSize = {x = 0, y = 0}
  self.cameraData_.HeadImgOriSize = {x = 0, y = 0}
  self.cameraData_.BodyImgOriPos = {x = 0, y = 0}
  self.cameraData_.HeadImgOriPos = {x = 0, y = 0}
  self.cameraData_.BodyImgOriSize.x, self.cameraData_.BodyImgOriSize.y = self.uiBinder.rimg_frame_systemic:GetSize(self.cameraData_.BodyImgOriSize.x, self.cameraData_.BodyImgOriSize.y)
  self.cameraData_.HeadImgOriSize.x, self.cameraData_.HeadImgOriSize.y = self.uiBinder.rimg_frame_head:GetSize(self.cameraData_.HeadImgOriSize.x, self.cameraData_.HeadImgOriSize.y)
  self.cameraData_.BodyImgOriPos.x, self.cameraData_.BodyImgOriPos.y = self.uiBinder.rimg_frame_systemic:GetAnchorPosition(self.cameraData_.BodyImgOriPos.x, self.cameraData_.BodyImgOriPos.y)
  self.cameraData_.HeadImgOriPos.x, self.cameraData_.HeadImgOriPos.y = self.uiBinder.rimg_frame_head:GetAnchorPosition(self.cameraData_.HeadImgOriPos.x, self.cameraData_.HeadImgOriPos.y)
end

function Camerasys_main_pcView:onHeadLookAtImageDrag(eventData)
  if self.cameraMemberData_.HeadLock then
    return
  end
  local transDragWidth, transDragHeight = 0, 0
  transDragWidth, transDragHeight = self.uiBinder.head_trans_drag:GetAnchorPosition(transDragWidth, transDragHeight)
  local posX, posY = self.cameraVM_.PosKeepBounds(transDragWidth + eventData.delta.x, transDragHeight + eventData.delta.y)
  self.uiBinder.head_trans_drag:SetAnchorPosition(posX, posY)
  self:coordinateTransformation(true)
end

function Camerasys_main_pcView:onEyesLookAtImageDrag(eventData)
  if self.cameraMemberData_.EyesLock then
    return
  end
  local transDragWidth, transDragHeight = 0, 0
  transDragWidth, transDragHeight = self.uiBinder.eyes_trans_drag:GetAnchorPosition(transDragWidth, transDragHeight)
  local posX, posY = self.cameraVM_.PosKeepBounds(transDragWidth + eventData.delta.x, transDragHeight + eventData.delta.y)
  self.uiBinder.eyes_trans_drag:SetAnchorPosition(posX, posY)
  self:coordinateTransformation(false)
end

function Camerasys_main_pcView:coordinateTransformation(isHead)
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

function Camerasys_main_pcView:updateFaceFramePos()
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

function Camerasys_main_pcView:initCameraMember()
  if self.cameraData_.IsOfficialPhotoTask or self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return
  end
  Z.CameraFrameCtrl:SetEntityShow(E.CameraSystemShowEntityType.CameraTeamMember, false)
  self.cameraData_.IsHideCameraMember = true
  local socialVM = Z.VMMgr.GetVM("social")
  local myCharId = Z.ContainerMgr.CharSerialize.charId
  local mySocialData = socialVM.AsyncGetHeadAndHeadFrameInfo(myCharId, self.cancelSource:CreateToken())
  self.cameraMemberVM_:AddMemberToList(myCharId, mySocialData, true)
  if self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto and not self.cameraData_.IsOfficialPhotoTask then
    self.cameraVM_.InitSelfLookAtCamera()
    self:refreshMemberLoop()
  end
  local memberListData = self.cameraMemberVM_:GetLocalMemberListData()
  if not memberListData then
    return
  end
  for k, v in pairs(memberListData) do
    local socialData = socialVM.AsyncGetHeadAndHeadFrameInfo(v, self.cancelSource:CreateToken())
    self.cameraMemberVM_:AddMemberToList(v, socialData)
  end
  if table.zcount(memberListData) > 0 then
    self:refreshMemberLoop()
    self:setRightPanelVisible(true)
  end
end

function Camerasys_main_pcView:updateMemberData(loopIndex, charId)
  local memberData = self.cameraMemberData_:GetMemberDataByCharId(charId)
  if not memberData then
    return
  end
  local memberInfo = {info = memberData, isShowRefreshBtn = true}
  self.memberLoopScrollRect_:RefreshDataByIndex(loopIndex, memberInfo)
  self.memberLoopScrollRect_:RefreshItemByItemIndex(loopIndex)
end

function Camerasys_main_pcView:refreshMemberLoop()
  self.memberData_ = self.cameraMemberData_:AssemblyMemberListData(true)
  self.memberLoopScrollRect_:RefreshListView(self.memberData_)
  self:setMemberLimitText()
end

function Camerasys_main_pcView:setRightPanelIsShow(isVisible)
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self:setUnionPanelVisible(isVisible)
  else
    self:setRightPanelVisible(isVisible)
  end
end

function Camerasys_main_pcView:setRightPanelVisible(isVisible)
  if self.cameraData_.IsOfficialPhotoTask or self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return
  end
  local viewIsShow = isVisible
  if isVisible == nil then
    viewIsShow = not self.isOpenTeamPanel_
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_member, viewIsShow)
  self.isOpenTeamPanel_ = viewIsShow
  if viewIsShow then
    self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_1)
  else
    self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_3)
  end
end

function Camerasys_main_pcView:setMemberLimitText()
  local cur = #self.memberData_
  local limit = Z.IsPCUI and Z.Global.PhotographTeamMemberLimit[1] or Z.Global.PhotographTeamMemberLimit[2]
  self.uiBinder.lab_blessing_item.text = Lang("PhotoTeamMemberCount", {val1 = cur, val2 = limit})
end

function Camerasys_main_pcView:setKeyboardShortcuts()
  self.inputKeyDescComps_[E.CameraSysInputKey.Move]:Init(E.CameraSysInputKey.Move, self.uiBinder.uibinder_move, self.cameraVM_.GetKeyDescByKeyId(E.CameraSysInputKey.Move))
  self.inputKeyDescComps_[E.CameraSysInputKey.Translation]:Init(E.CameraSysInputKey.Translation, self.uiBinder.uibinder_translation, self.cameraVM_.GetKeyDescByKeyId(E.CameraSysInputKey.Translation))
  self.inputKeyDescComps_[E.CameraSysInputKey.Hide]:Init(E.CameraSysInputKey.Hide, self.uiBinder.uibinder_hide, self.cameraVM_.GetKeyDescByKeyId(E.CameraSysInputKey.Hide))
  self.inputKeyDescComps_[E.CameraSysInputKey.Shot]:Init(E.CameraSysInputKey.Shot, self.uiBinder.uibinder_shot, self.cameraVM_.GetKeyDescByKeyId(E.CameraSysInputKey.Shot))
  self.inputKeyDescComps_[E.CameraSysInputKey.LeftPanel]:Init(E.CameraSysInputKey.LeftPanel, self.uiBinder.uibinder_left_panel_btn)
  self.inputKeyDescComps_[E.CameraSysInputKey.rightPanel]:Init(E.CameraSysInputKey.rightPanel, self.uiBinder.uibinder_right_panel_btn)
  self.inputKeyDescComps_[E.CameraSysInputKey.ESC]:Init(E.CameraSysInputKey.ESC, self.uiBinder.uibinder_esc)
end

function Camerasys_main_pcView:rebuildInputKeyDesc()
  if not self.uiBinder then
    return
  end
  local preferred = self.uiBinder.uibinder_move.lab_key.preferredWidth
  self.uiBinder.uibinder_move.Trans:SetWidth(preferred)
  preferred = self.uiBinder.uibinder_translation.lab_key.preferredWidth
  self.uiBinder.uibinder_translation.Trans:SetWidth(preferred)
  preferred = self.uiBinder.uibinder_hide.lab_key.preferredWidth
  self.uiBinder.uibinder_hide.Trans:SetWidth(preferred)
  preferred = self.uiBinder.uibinder_shot.lab_key.preferredWidth
  self.uiBinder.uibinder_shot.Trans:SetWidth(preferred)
  self.uiBinder.layout_bottom:ForceRebuildLayoutImmediate()
end

function Camerasys_main_pcView:refreshResonanceSkill()
  if not Z.IsPCUI or self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto or self.cameraData_.IsOfficialPhotoTask then
    return
  end
  local isFuncOpen = self.funcVM_.FuncIsOn(E.FunctionID.VehicleRide, true)
  self.uiBinder.node_function.Ref:SetVisible(self.uiBinder.node_function.group_mount, isFuncOpen)
  local keyId = self.cameraVM_.GetKeyIdAndDescByFuncId(E.FunctionID.VehicleRide)
  if keyId then
    if self.inputKeyDescComps_[keyId] == nil then
      self.inputKeyDescComps_[keyId] = inputKeyDescComp.new()
    end
    self.inputKeyDescComps_[keyId]:Init(keyId, self.uiBinder.node_function.com_icon_key)
  end
  local resonanceBinders = {
    [1] = self.uiBinder.node_function.resonance_left,
    [2] = self.uiBinder.node_function.resonance_right
  }
  local resonanceRoot = {
    [1] = self.uiBinder.node_function.group_skill_extra_1,
    [2] = self.uiBinder.node_function.group_skill_extra_2
  }
  for i = 1, 2 do
    if self.mainuiSkillSlotObjs_[i] == nil then
      self.mainuiSkillSlotObjs_[i] = mainui_skill_slot_obj.new(100 + i, resonanceBinders[i], resonanceRoot[i], self)
    end
    self.mainuiSkillSlotObjs_[i]:Active()
  end
end

function Camerasys_main_pcView:setLeftSettingPanelVisible()
  if self.cameraData_.IsOfficialPhotoTask then
    return
  end
  self.isOpenLeftSettingPanel_ = not self.isOpenLeftSettingPanel_
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_left, self.isOpenLeftSettingPanel_)
  if self.isOpenLeftSettingPanel_ then
    self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_0)
  else
    self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_2)
  end
end

function Camerasys_main_pcView:onCameraPatternChanged()
  local firstLevelTabData = self.cameraVM_.GetFirstLevelTabData()
  for k, v in ipairs(firstLevelTabData) do
    self.firstLevelTabUiBinder_[v.id].interactable = v.isShow
  end
  if self.firstLevelTabUiBinder_[self.cameraSystemPcFunctionType_].interactable == false then
    self:setFirstLevelTabIsOn()
  else
    Z.CoroUtil.create_coro_xpcall(function()
      self:loadLeftFunctionBtn(self.cameraSystemPcFunctionType_)
    end)()
  end
end

function Camerasys_main_pcView:setFirstLevelTabIsOn()
  local keys = {}
  for k, v in pairs(self.firstLevelTabUiBinder_) do
    table.insert(keys, k)
  end
  table.sort(keys)
  for _, k in ipairs(keys) do
    if self.firstLevelTabUiBinder_[k] and self.firstLevelTabUiBinder_[k].interactable == true then
      if self.firstLevelTabUiBinder_[k].isOn == true then
        Z.CoroUtil.create_coro_xpcall(function()
          self:loadLeftFunctionBtn(k)
        end)()
        break
      end
      self.firstLevelTabUiBinder_[k].isOn = true
      break
    end
  end
end

function Camerasys_main_pcView:loadLeftFunctionBtn(cameraFunctionType)
  self:removeUnit()
  self.cameraSystemPcFunctionType_ = cameraFunctionType
  if cameraFunctionType == E.CameraSystemFunctionType.Camera then
    if self.curActiveSubView_ then
      self.curActiveSubView_:DeActive()
    end
    self.menuContainerShotSet_:Active(nil, self.uiBinder.node_sub)
    self.curActiveSubView_ = self.menuContainerShotSet_
    return
  end
  local tabData = self.cameraVM_.GetPcFunctionData(cameraFunctionType)
  if not tabData or table.zcount(tabData) == 0 then
    return
  end
  local path = self.uiBinder.prefab_cache:GetString("expression_tog_tpl")
  if string.zisEmpty(path) then
    return
  end
  for k, v in ipairs(tabData) do
    local name = "expression_tog_tpl_" .. k
    local togTabTplBinder = self:AsyncLoadUiUnit(path, name, self.uiBinder.node_sys_tog_two, self.cancelSource:CreateToken())
    self:initTabTog(togTabTplBinder, v)
    table.insert(self.cameraFunctionUnit_, {
      name = name,
      item = togTabTplBinder,
      data = v
    })
  end
  self.cameraFunctionUnit_[1].item.tog_function:SetIsOnWithoutCallBack(true)
  self:initSettingSubView(self.cameraFunctionUnit_[1].data.Id)
end

function Camerasys_main_pcView:initTabTog(item, data)
  if not item or not data then
    return
  end
  item.tog_function.group = self.uiBinder.group_sys_tog_two
  item.img_icon_on:SetImage(data.Icon)
  item.img_icon_off:SetImage(data.Icon)
  item.tog_function:SetIsOnWithoutCallBack(false)
  item.tog_function:AddListener(function(isOn)
    if isOn then
      self:initSettingSubView(data.Id)
    end
  end)
end

function Camerasys_main_pcView:initSettingSubView(subFuncType)
  if self.subFuncViewList_[subFuncType] then
    if self.curActiveSubView_ then
      self.curActiveSubView_:DeActive()
    end
    self.cameraData_:SetSettingViewSecondaryLogicIndex(subFuncType)
    self.cameraVM_.SetCameraActionDisplayExpressionType(subFuncType)
    self.subFuncViewList_[subFuncType]:Active(nil, self.uiBinder.node_sub)
    self.curActiveSubView_ = self.subFuncViewList_[subFuncType]
  end
end

function Camerasys_main_pcView:setUnionMode()
  if self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto then
    return
  end
  local keyName = "cameraFocusBody"
  if self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
    keyName = "cameraFocusHead"
  end
  local zoomRange = Z.Global.Photograph_BusinessCardCameraOffsetRangeA
  if self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
    zoomRange = Z.Global.Photograph_BusinessCardCameraOffsetRangeB
  end
  self.uiBinder.node_union_action.alpha = 0.5
  self.uiBinder.node_union_action.interactable = false
  Z.UnrealSceneMgr:InitSceneCamera(true)
  Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(zoomRange[1], zoomRange[2])
  if not self.isFashionState_ then
    local modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
    local modelPinchHeight = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelPinchHeight).Value
    local modelOffset = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(modelId)
    local heightOffset = self.cameraVM_.GetHeightOffSet(modelPinchHeight)
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset(keyName, Vector3.New(modelOffset.x, modelOffset.y + heightOffset, 0))
  end
  self:calculateUnionMaskDragLimit()
  self.unionBgGO_ = Z.UnrealSceneMgr:GetGOByBinderName("UnionBg")
  self.unrealSkyBoxGo_ = Z.UnrealSceneMgr:GetGOByBinderName("skyBox")
  self:setUnionPanelVisible(true)
  self.unionBgGO_:SetActive(true)
  self.unrealSkyBoxGo_:SetActive(false)
  Z.CameraFrameCtrl:SetUnionCameraBgTile(self.unionBgGO_)
  local unionBgCfg = self.cameraData_:GetUnionBgCfg()
  Z.CameraFrameCtrl:SetGOTexture(self.unionBgGO_, unionBgCfg[1].Res)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_share, self.isFashionState_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_generate_qr_code, not self.IsPreFaceMode_)
  if self.isFashionState_ then
    self:initFaceModel()
  else
    self:createUnionPlayerModel()
  end
  local name = self.isFashionState_ and Lang("Self") or Z.ContainerMgr.CharSerialize.charBase.name
  self.uiBinder.binder_team_edit_tpl.lab_char_name.text = name
  self.uiBinder.binder_team_edit_tpl.Ref:SetVisible(self.uiBinder.binder_team_edit_tpl.btn_medium_play, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, not self.isFashionState_)
  if self.isFashionState_ then
    self.uiBinder.binder_team_edit_tpl.Ref:SetVisible(self.uiBinder.binder_team_edit_tpl.img_newbie, false)
  else
    local isNewbie = Z.VMMgr.GetVM("player"):IsShowNewbie(Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrIsNewbie")).Value)
    self.uiBinder.binder_team_edit_tpl.Ref:SetVisible(self.uiBinder.binder_team_edit_tpl.img_newbie, isNewbie)
  end
  self.actionHelper_ = ActionHelper.new(self)
  local myCharId = self.isFashionState_ and 0 or Z.ContainerMgr.CharSerialize.charId
  local memberListData = self.cameraMemberData_:InitMemberData(myCharId, nil, true)
  memberListData.baseData.model = self.playerModel_
  local actionData = {
    memberListData = memberListData,
    uiBinder = self.uiBinder.binder_team_edit_tpl
  }
  self.actionHelper_:Init(actionData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_union_right, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_member_right, false)
end

function Camerasys_main_pcView:setUnrealSceneState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_translation_key, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_up_show, false)
  self.uiBinder.node_function.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_drag, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, false)
  self:initUnionUnrealData()
  if not self.isUnRealSceneIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 12582924, true)
    self.isUnRealSceneIgnore_ = true
  end
  local rootCanvas = Z.UIRoot.RootCanvas.transform
  local rate = 0.00925926 / rootCanvas.localScale.x
  local width, height
  if self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Body or self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Fashion then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_body_mask, true)
    width, height = self.cameraVM_.GetUnionSelectBoxSize(self.cameraData_.BodyImgOriSize, rate, true)
    self.uiBinder.rimg_frame_systemic:SetWidth(width)
    self.uiBinder.rimg_frame_systemic:SetHeight(height)
    self.cameraVM_.SetImgAreaClip(self.uiBinder.img_body_mask, self.uiBinder.rimg_frame_systemic)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_head_mask, true)
    width, height = self.cameraVM_.GetUnionSelectBoxSize(self.cameraData_.HeadImgOriSize, rate)
    self.uiBinder.rimg_frame_head:SetWidth(width)
    self.uiBinder.rimg_frame_head:SetHeight(height)
    self.cameraVM_.SetImgAreaClip(self.uiBinder.img_head_mask, self.uiBinder.rimg_frame_head)
  end
end

function Camerasys_main_pcView:createUnionPlayerModel()
  self.playerModel_ = Z.UnrealSceneMgr:GetCachePlayerModel(function(model)
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
    model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
    Z.UIMgr:FadeOut()
  end, nil, false)
  self.cameraData_:SetUnionModel(self.playerModel_)
end

function Camerasys_main_pcView:setUnionPanelVisible(isVisible)
  if self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto then
    return
  end
  local viewIsShow = isVisible
  if isVisible == nil then
    viewIsShow = not self.isOpenUnionPanel_
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_union_member, viewIsShow)
  self.isOpenUnionPanel_ = viewIsShow
  if viewIsShow then
    self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_4)
  else
    self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Tween_5)
  end
end

function Camerasys_main_pcView:calculateUnionMaskDragLimit()
  local headTrans = self.uiBinder.trans_body_mask
  if self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Head then
    headTrans = self.uiBinder.trans_head_mask
  end
  self.unionDragLimitMax_ = Vector2.New(headTrans.rect.width * 0.5, headTrans.rect.height * 0.5)
  self.unionDragLimitMin_ = Vector2.New(-headTrans.rect.width * 0.5, -headTrans.rect.height * 0.5)
end

function Camerasys_main_pcView:handleUnrealScene(oriId)
  local imgData = {}
  if not oriId or oriId == 0 then
    return
  end
  local isBody = self.cameraData_.UnrealSceneModeSubType == E.UnionCameraSubType.Body
  local width = isBody and PHOTO_SIZE.BodySize.Width or PHOTO_SIZE.HeadSize.Width
  local height = isBody and PHOTO_SIZE.BodySize.Height or PHOTO_SIZE.HeadSize.Height
  local resizePhotoId = Z.LuaBridge.ResizeTextureSizeForAlbum(oriId, E.NativeTextureCallToken.CamerasysView, width, height)
  imgData.snapType = isBody and E.PictureType.EProfileHalfBody or E.PictureType.EProfileSnapShot
  imgData.textureId = resizePhotoId
  if isBody then
    self.cameraVM_.OpenIdCardView(self.cancelSource:CreateToken(), imgData)
  else
    self.cameraVM_.OpenHeadView(imgData)
  end
  Z.LuaBridge.ReleaseScreenShot(oriId)
end

function Camerasys_main_pcView:resetUnionMode()
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
    self.cameraData_:SetUnionModel(nil)
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
  if self.isUnRealSceneIgnore_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 12582924, false)
    self.isUnRealSceneIgnore_ = false
  end
  if self.actionHelper_ then
    self.actionHelper_:UnInit()
    self.actionHelper_ = nil
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_union_right, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_member_right, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_translation_key, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_up_show, true)
  self.uiBinder.node_function.Ref.UIComp:SetVisible(true)
end

function Camerasys_main_pcView:unionImgMove(maskImg, moveNode, pointerData)
  local pos = moveNode.anchoredPosition
  local movePosX = pos.x + pointerData.delta.x
  local movePosY = pos.y + pointerData.delta.y
  local moveNodeWidth, moveNodeHeight = 0, 0
  moveNodeWidth, moveNodeHeight = moveNode:GetSize(moveNodeWidth, moveNodeHeight)
  local posX, posY = self.cameraVM_.UnionClipPositionKeepBounds(movePosX, movePosY, self.unionDragLimitMax_, self.unionDragLimitMin_, moveNodeWidth, moveNodeHeight)
  moveNode:SetAnchorPosition(posX, posY)
  self.cameraVM_.SetImgAreaClip(maskImg, moveNode)
end

function Camerasys_main_pcView:UpdateAfterVisibleChanged(visible)
  Z.UIConfig[self.viewConfigKey].IsUnrealScene = self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto
  super.UpdateAfterVisibleChanged(self, visible)
end

function Camerasys_main_pcView:setPlayerRotation(isLeft)
  if not self.playerModel_ then
    return
  end
  local curRotation = self.cameraVM_.GetModelDefaultRotation(self.playerModel_)
  local rotationY = isLeft and curRotation + self.rotationStep_ or curRotation - self.rotationStep_
  local newRotation = Quaternion.Euler(Vector3.New(0, rotationY, 0))
  self.playerModel_:SetAttrGoRotation(newRotation)
end

function Camerasys_main_pcView:onActionPlay(actionCfgId)
  if self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto or not self.actionHelper_ then
    return
  end
  self.uiBinder.node_union_action.alpha = 1
  self.uiBinder.node_union_action.interactable = true
  self.actionHelper_:Refresh()
end

function Camerasys_main_pcView:resetAction()
  if self.actionHelper_ and self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self.uiBinder.node_union_action.alpha = 0.5
    self.uiBinder.node_union_action.interactable = false
    self.actionHelper_:ResetExpression()
    self.uiBinder.binder_team_edit_tpl.slider_action.value = 0
  end
end

function Camerasys_main_pcView:CustomClose()
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(0.2, 1.2)
    Z.UnrealSceneMgr:CloseUnrealScene("camerasys")
  end
  self.cameraData_.CameraPatternType = E.TakePhotoSate.Default
end

function Camerasys_main_pcView:initLandscapePhotoMode()
  if not self.cameraData_.IsOfficialPhotoTask then
    return
  end
  self:setTakePhotoNodeVisible(true)
  self:checkPhotoTask()
end

function Camerasys_main_pcView:checkPhotoTask()
  self.posInfoList_ = Z.PhotoQuestMgr:GetPhotoTask()
  self.photoConditionUnits_ = {}
  self.photoConditionUnitsFlag_ = {}
  if self.cameraData_.IsOfficialPhotoTask then
    self.photoTaskId_ = self.cameraData_.PhotoTaskId
    self:refreshPhotoTaskInfo()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_scenicspor_photo_far, false)
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
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_scenicspor_photo_far, true)
        TempV3.x = pointInfo.data.Position[1]
        TempV3.y = pointInfo.data.Position[2]
        TempV3.z = pointInfo.data.Position[3]
        local show, pos = ZTransformUtility.WorldToLocalPointInRectangle(TempV3, self.uiBinder.node_scenicspor_photo_far, false, nil)
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
        self.uiBinder.Ref:SetVisible(self.uiBinder.node_scenicspor_photo_far, false)
      end
      self:refreshPhotoTaskInfo()
    end, 0.01, -1)
  end
end

function Camerasys_main_pcView:shouldFinishPhotoTask()
  if self.photoTaskId_ and self.photoTaskId_ ~= 0 then
    if self.cameraData_.IsOfficialPhotoTask then
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

function Camerasys_main_pcView:executePhotoTaskCompletion()
  if self.posInfoList_[self.photoTaskId_] and self.posInfoList_[self.photoTaskId_].func then
    self.posInfoList_[self.photoTaskId_].func()
  end
end

function Camerasys_main_pcView:refreshPhotoTaskInfo()
  if self.photoTaskId_ == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_unlock, false)
  else
    local photoTaskBase = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(self.photoTaskId_)
    if photoTaskBase == nil then
      return
    end
    local conditionRoot = self.uiBinder.node_quest_item
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
      end
    end)()
  end
end

function Camerasys_main_pcView:getNearestPointInfo()
  if self.cameraData_.IsOfficialPhotoTask then
    return
  end
  self.photoTaskId_, self.nearestDistance_ = Z.PhotoQuestMgr:GetNearestPhotoTaskId(self.posInfoList_)
end

function Camerasys_main_pcView:resetPhotoTaskInfo()
  if not self.cameraData_.IsOfficialPhotoTask then
    return
  end
  self.cameraData_.IsOfficialPhotoTask = false
  self.cameraData_.PhotoTaskId = 0
  local photoConfig = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(self.photoTaskId_)
  if photoConfig then
    local idList = ZUtil.Pool.Collections.ZList_int.Rent()
    Z.CameraMgr:CameraInvokeByList(E.CameraState.Position, false, idList)
    ZUtil.Pool.Collections.ZList_int.Return(idList)
  end
  self:resetPhotoTaskUI()
end

function Camerasys_main_pcView:resetPhotoTaskUI()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_joystick, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_member_right, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_move_key, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_hide_key, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_camera_translation_key, true)
  self.uiBinder.node_function.Ref.UIComp:SetVisible(true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_left, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_close, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_unlock, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, not self.isFashionState_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_pattern, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_pattern_right, true)
end

function Camerasys_main_pcView:onStartAnimShow()
  self.uiBinder.anim_do:Restart(Z.DOTweenAnimType.Open)
end

function Camerasys_main_pcView:initFaceModel()
  local faceData = Z.DataMgr.Get("face_data")
  local gender = faceData:GetPlayerGender()
  local bodySize = faceData:GetPlayerBodySize()
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(gender, bodySize)
  self.cameraData_:SetFaceModelInfo(gender, bodySize, modelId)
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
      self.cameraData_:SetUnionModel(self.playerModel_)
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
    self.cameraData_:SetUnionModel(self.playerModel_)
    Z.UIMgr:FadeOut()
  end
end

function Camerasys_main_pcView:onFaceAttrChange(attrType, ...)
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

function Camerasys_main_pcView:setModelAttr(funcName, ...)
  local arg = {
    ...
  }
  if self.playerModel_ then
    self.playerModel_[funcName](self.playerModel_, table.unpack(arg))
  end
end

function Camerasys_main_pcView:handleFashion(oriId)
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

return Camerasys_main_pcView
