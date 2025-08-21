local super = require("ui.ui_view_base")
local Face_systemView = class("Face_systemView", super)
local leftRightBodyPath = "ui/textures/face/face_boy_adorn_right"
local leftRightGrilPath = "ui/textures/face/face_gril_adorn_left"
local ESecondTab = {
  FaceShape = 301,
  Eyebrow = 302,
  Eye = 303,
  Eyelash = 304,
  Pupil = 305,
  Nose = 306,
  Mouth = 307,
  Beard = 308,
  Eyeshadow = 401,
  Lipstick = 402,
  Feature1 = 403,
  Feature2 = 404,
  Tooth = 405
}
E.FaceShareType = {
  AutoShare = 1,
  Share = 2,
  Input = 3
}
local FirstTabDataDict = {
  [E.FaceFirstTab.HotPhoto] = {
    NodeName = "binder_tog_template",
    FieldName = "hotPhoto",
    IsFocus = true,
    DefaultSecondTab = nil,
    SecondTabGroupName = nil
  },
  [E.FaceFirstTab.Body] = {
    NodeName = "binder_tog_body",
    FieldName = "body",
    IsFocus = false,
    DefaultSecondTab = nil,
    SecondTabGroupName = nil
  },
  [E.FaceFirstTab.Hair] = {
    NodeName = "binder_tog_hair",
    FieldName = "hair",
    IsFocus = true,
    DefaultSecondTab = nil,
    SecondTabGroupName = nil
  },
  [E.FaceFirstTab.Face] = {
    NodeName = "binder_tog_face",
    FieldName = nil,
    IsFocus = true,
    DefaultSecondTab = ESecondTab.FaceShape,
    SecondTabGroupName = "group_tab2_face"
  },
  [E.FaceFirstTab.Makeup] = {
    NodeName = "binder_tog_makeup",
    FieldName = nil,
    IsFocus = true,
    DefaultSecondTab = ESecondTab.Eyeshadow,
    SecondTabGroupName = "group_tab2_makeup"
  }
}
local SecondTabDataDict = {
  [ESecondTab.FaceShape] = {
    NodeName = "node_face_shape_tab",
    FieldName = "faceShape"
  },
  [ESecondTab.Eyebrow] = {
    NodeName = "node_eyebrow_tab",
    FieldName = "eyebrow"
  },
  [ESecondTab.Eye] = {
    NodeName = "node_eye_tab",
    FieldName = "eye"
  },
  [ESecondTab.Eyelash] = {
    NodeName = "node_eyelash_tab",
    FieldName = "eyelash"
  },
  [ESecondTab.Pupil] = {
    NodeName = "node_pupil_tab",
    FieldName = "pupil"
  },
  [ESecondTab.Nose] = {
    NodeName = "node_nose_tab",
    FieldName = "nose"
  },
  [ESecondTab.Mouth] = {
    NodeName = "node_mouth_tab",
    FieldName = "mouth"
  },
  [ESecondTab.Beard] = {
    NodeName = "node_beard_tab",
    FieldName = "beard"
  },
  [ESecondTab.Tooth] = {
    NodeName = "node_tooth_tab",
    FieldName = "tooth"
  },
  [ESecondTab.Eyeshadow] = {
    NodeName = "node_eyeshadow_tab",
    FieldName = "eyeshadow"
  },
  [ESecondTab.Lipstick] = {
    NodeName = "node_lipstick_tab",
    FieldName = "lipstick"
  },
  [ESecondTab.Feature1] = {
    NodeName = "node_feature1_tab",
    FieldName = "featureOne"
  },
  [ESecondTab.Feature2] = {
    NodeName = "node_feature2_tab",
    FieldName = "featureTwo"
  }
}
local modelPositionParam = {
  [1] = {
    [1] = {
      [1] = {
        x = 0.08,
        y = -0.63,
        z = -3.33
      },
      [2] = {
        x = 0.25,
        y = -0.15,
        z = -1.72
      },
      [3] = {
        x = -0.365,
        y = -0.26,
        z = -2
      }
    },
    [2] = {
      [1] = {
        x = 0.05,
        y = -0.86,
        z = -3.38
      },
      [2] = {
        x = 0.24,
        y = -0.39,
        z = -1.79
      },
      [3] = {
        x = -0.36,
        y = -0.5,
        z = -2.05
      }
    },
    [3] = {
      [1] = {
        x = 0.05,
        y = -0.9,
        z = -3.35
      },
      [2] = {
        x = 0.24,
        y = -0.43,
        z = -1.79
      },
      [3] = {
        x = -0.37,
        y = -0.54,
        z = -2
      }
    }
  },
  [2] = {
    [1] = {
      [1] = {
        x = 0.03,
        y = -0.615,
        z = -3.35
      },
      [2] = {
        x = 0.3,
        y = -0.155,
        z = -1.85
      },
      [3] = {
        x = -0.365,
        y = -0.215,
        z = -2
      }
    },
    [2] = {
      [1] = {
        x = 0.025,
        y = -0.77,
        z = -3.38
      },
      [2] = {
        x = 0.3,
        y = -0.31,
        z = -1.85
      },
      [3] = {
        x = -0.36,
        y = -0.375,
        z = -2.05
      }
    },
    [3] = {
      [1] = {
        x = 0.03,
        y = -0.82,
        z = -3.35
      },
      [2] = {
        x = 0.31,
        y = -0.35,
        z = -1.79
      },
      [3] = {
        x = -0.36,
        y = -0.42,
        z = -2.05
      }
    }
  }
}
local ModelClipDataClass = Panda.ZGame.ModelClipData

function Face_systemView:ctor()
  self.uiBinder = nil
  super.ctor(self, "face_system")
  self:createSubView()
end

function Face_systemView:createSubView()
  self.hotPhotoView_ = require("ui/view/menu_hotphoto_view").new(self)
  self.bodyView_ = require("ui/view/menu_body_view").new(self)
  self.hairView_ = require("ui/view/menu_hair_view").new(self)
  self.faceShapeView_ = require("ui/view/menu_face_shape_view").new(self)
  self.eyebrowView_ = require("ui/view/menu_eyebrow_view").new(self)
  self.eyeView_ = require("ui/view/menu_eye_view").new(self)
  self.eyelashView_ = require("ui/view/menu_eyelash_view").new(self)
  self.pupilView_ = require("ui/view/menu_pupil_view").new(self)
  self.noseView_ = require("ui/view/menu_nose_view").new(self)
  self.mouthView_ = require("ui/view/menu_mouth_view").new(self)
  self.beardView_ = require("ui/view/menu_beard_view").new(self)
  self.toothView_ = require("ui/view/menu_tooth_view").new(self)
  self.eyeshadowView_ = require("ui/view/menu_eyeshadow_view").new(self)
  self.lipstickView_ = require("ui/view/menu_lipstick_view").new(self)
  self.featureOneView_ = require("ui/view/menu_feature_view").new(self, 1)
  self.featureTwoView_ = require("ui/view/menu_feature_view").new(self, 2)
end

function Face_systemView:SetScrollContent(trans)
  self.uiBinder.scrollview_menu:ClearAll()
  self.uiBinder.scrollview_menu.content = trans
  self.uiBinder.scrollview_menu:RefreshContentEvent()
  self.uiBinder.scrollview_menu:Init()
end

function Face_systemView:SetFocus(isOnHead)
  self.uiBinder.tog_focus.isOn = isOnHead
end

function Face_systemView:OnActive()
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.actionVM_ = Z.VMMgr.GetVM("action")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self:startAnimatedShow()
  Z.UnrealSceneMgr:InitSceneCamera(true)
  Z.PlayerInputController.IsCheckZoomClickingUI = false
  Z.PlayerInputController:SetCameraStretchIgnoreCheckUI(true)
  Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(0.25, 0.91)
  Z.UnrealSceneMgr:SetZoomAutoChangeLookAtZoomRange(0.88, 0.25)
  self.offset_ = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(self.faceData_:GetPlayerModelId())
  Z.UnrealSceneMgr:SetZoomAutoChangeLookAtByOffset(self.offset_.x, self.offset_.y)
  Z.UnrealSceneMgr:SetAutoChangeLook(true)
  if self.viewData and self.viewData.screenX then
    local loop = 0
    self.timerMgr:StartTimer(function()
      loop = loop + 1
      local x = 0.5 - 0.01 * loop
      Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(x, 0.5))
    end, 0.01, 10)
  else
    Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(0.4, 0.5))
  end
  if self.viewData then
    self.needCacheModel_ = self.viewData.needCacheModel
  else
    self.needCacheModel_ = false
  end
  self.isRequestCreating_ = false
  self.firstTabDict_ = FirstTabDataDict
  self.secondTabDict_ = SecondTabDataDict
  self.actionIndex_ = 1
  self.curTimelineId_ = nil
  self:AddClick(self.uiBinder.btn_close, function()
    self:OnInputBack()
  end)
  self.preloadModelCount_ = 0
  self:refreshCurRotation()
  self:onScreenResolutionChange()
  self:initFaceData()
  self:initModel()
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self:initTabSelect()
  self:initOperateBtn()
  self:preLoadTimeline()
  self:updateFaceOperationBtnState()
  self:AddClick(self.uiBinder.btn_random, function()
    self:onClickRandom()
  end)
  self:AddClick(self.uiBinder.btn_revert, function()
    self:onClickRevert()
  end)
  self:AddAsyncClick(self.uiBinder.btn_finish, function()
    self.faceData_.Height = self.playerModel_:GetAttrGoHeight()
    self:onClickFinish()
  end)
  self:AddClick(self.uiBinder.btn_fashion, function()
    self:refreshModelEmote(0)
    self:showModel(self.playerModel_)
    self:hideModel(self.playerModel1_)
    self:hideModel(self.playerModel2_)
    self:hideModel(self.playerModel3_)
    self.needCacheModel_ = true
    local vm = Z.VMMgr.GetVM("fashion")
    vm.OpenFashionFaceView()
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    local vm = Z.VMMgr.GetVM("face")
    vm.ReturnEditorOperation()
    self:updateFaceOperationBtnState()
  end)
  self:AddClick(self.uiBinder.btn_move, function()
    local vm = Z.VMMgr.GetVM("face")
    vm.MoveEditorOperation()
    self:updateFaceOperationBtnState()
  end)
  self.uiBinder.togs_tab2.AllowSwitchOff = true
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_tab2_face, self.curFirstTab_ and self.curFirstTab_ == E.FaceFirstTab.Face)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_tab2_makeup, self.curFirstTab_ and self.curFirstTab_ == E.FaceFirstTab.Makeup)
  self:initTabFunction()
  self:initBg()
  self.uiBinder.rayimg_unrealscene_drag.onDrag:AddListener(function(go, eventData)
    if Z.TouchManager.TouchCount > 1 then
      return
    end
    self:onModelDrag(eventData)
  end)
  self:AddAsyncClick(self.uiBinder.btn_save_file, function()
    self:onClickSaveFaceDataFile()
  end)
  self:AddAsyncClick(self.uiBinder.btn_load_file, function()
    self:onClickLoadFaceDataFile()
  end)
  self:checkCloudGameBtnIsShow()
  self:BindEvents()
end

function Face_systemView:checkCloudGameBtnIsShow()
  self:SetUIVisible(self.uiBinder.btn_save_file, not Z.IsPreFaceMode)
  self:SetUIVisible(self.uiBinder.btn_load_file, true)
  self.uiBinder.lab_content.text = Z.IsPreFaceMode and Lang("Pass") or Lang("ConfirmImage")
end

function Face_systemView:OnRefresh()
  local attrVM = Z.VMMgr.GetVM("face_attr")
  attrVM.UpdateAllFaceAttr()
end

function Face_systemView:initTabFunction()
  for firstTab, firstTabData in pairs(FirstTabDataDict) do
    local togNode = self.uiBinder[firstTabData.NodeName]
    togNode.tog_tab_select:RemoveAllListeners()
    togNode.tog_tab_select.isOn = firstTab == self.curFirstTab_
    togNode.tog_tab_select.group = self.uiBinder.togs_tab1
    togNode.tog_tab_select:AddListener(function(isOn)
      local commonVM_ = Z.VMMgr.GetVM("common")
      commonVM_.CommonPlayTogAnim(togNode.anim_tog, self.cancelSource:CreateToken())
      if not self.uiBinder then
        return
      end
      local secondTabGroupNode = self.uiBinder[firstTabData.SecondTabGroupName]
      if secondTabGroupNode then
        self.uiBinder.Ref:SetVisible(secondTabGroupNode, isOn)
      end
      if isOn and self.curFirstTab_ ~= firstTab then
        self:switchFirstTab(firstTab)
        if firstTab == 4 then
          self:startTabPlaySelectAnim()
        elseif firstTab == 3 then
          self:startTab4PlaySelectAnim()
        end
        self:startPlaySelectAnim()
        if firstTabData.IsFocus and self.isShowOneModel_ then
          self.isShowOneModel_ = false
          self.isFocus_ = true
          self.isThreeModel_ = false
          self:changeFocus(self.isFocus_)
          self.uiBinder.tog_focus:SetIsOnWithoutCallBack(false)
        elseif self.isFocus_ ~= firstTabData.IsFocus then
          self.isFocus_ = firstTabData.IsFocus
          self.isThreeModel_ = false
          self:changeFocus(self.isFocus_)
          self.uiBinder.tog_focus:SetIsOnWithoutCallBack(false)
        end
        self.uiBinder.togs_tab2:SetAllTogglesOff()
        local fieldName = firstTabData.FieldName
        if fieldName then
          self.uiBinder.togs_tab2.AllowSwitchOff = true
          self.curSecondTab_ = nil
          self.curSecondDefaultTab_ = nil
          self:switchShowView(self[string.zconcat(fieldName, "View_")])
        else
          self.uiBinder.togs_tab2.AllowSwitchOff = false
          self.curSecondDefaultTab_ = firstTabData.DefaultSecondTab
          local secondTabCont = self.uiBinder[SecondTabDataDict[self.curSecondDefaultTab_].NodeName]
          secondTabCont.tog_tab.isOn = true
        end
        self:checkTimelineAction()
        self:refreshTogActionVisable()
        if firstTab == E.FaceFirstTab.Hair then
          Z.RedPointMgr.OnClickRedDot(E.RedType.FaceEditorHair)
        end
      end
    end)
  end
  for secondTab, secondTabData in pairs(SecondTabDataDict) do
    local togNode = self.uiBinder[secondTabData.NodeName]
    togNode.tog_tab:RemoveAllListeners()
    togNode.tog_tab.isOn = self.curSecondTab_ and self.curSecondTab_ == secondTab
    togNode.tog_tab.group = self.uiBinder.togs_tab2
    togNode.eff_two_tog:SetEffectGoVisible(false)
    togNode.tog_tab:AddListener(function(isOn)
      togNode.tog_tab_select_anim:Restart(Z.DOTweenAnimType.Open)
      togNode.eff_two_tog:SetEffectGoVisible(isOn)
      if isOn and self.curSecondTab_ ~= secondTab then
        self.curSecondTab_ = secondTab
        self:startPlaySelectAnim()
        local fieldName = secondTabData.FieldName
        self:switchShowView(self[string.zconcat(fieldName, "View_")])
      end
      if isOn and secondTab == ESecondTab.Tooth then
        if self.playerModel_ then
          self:refreshModelEmote(34)
        end
      elseif self.playerModel_ then
        self:refreshModelEmote(0)
      end
    end)
  end
end

function Face_systemView:initBg()
  local gender = self.faceData_:GetPlayerGender()
  local bodySize = self.faceData_:GetPlayerBodySize()
  local isShowBeard = gender == Z.PbEnum("EGender", "GenderMale") and (bodySize == Z.PbEnum("EBodySize", "BodySizeM") or bodySize == Z.PbEnum("EBodySize", "BodySizeL"))
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_beard_tab_ref, isShowBeard)
  if self.faceData_:GetPlayerGender() == Z.PbEnum("EGender", "GenderMale") then
    self.uiBinder.rimg_left:SetImage(leftRightBodyPath)
  else
    self.uiBinder.rimg_left:SetImage(leftRightGrilPath)
  end
end

function Face_systemView:onModelDrag(eventData)
  self.curRotation_ = self.curRotation_ - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  if self.curTimelineId_ then
    local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
    Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.curTimelineId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
  elseif self.playerModel_ then
    self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
  end
end

function Face_systemView:refreshCurRotation()
  if Z.StageMgr.GetIsInGameScene() then
    self.curRotation_ = 180
  else
    self.curRotation_ = Z.ConstValue.FaceGenderRotation[self.faceData_:GetPlayerGender()]
  end
end

function Face_systemView:switchShowView(toView)
  if self.curShowView_ == toView then
    return
  end
  if self.curShowView_ then
    self.curShowView_:DeActive()
  end
  self.curShowView_ = toView
  if self.curShowView_ then
    self.uiBinder.node_viewport:SetAnchorPosition(0, 0)
    self.curShowView_:Active(nil, self.uiBinder.node_viewport)
  end
end

function Face_systemView:initFaceData()
end

function Face_systemView:initModel()
  self.playerModel_ = Z.UnrealSceneMgr:GetCacheModel(self.faceData_.FaceModelName)
  if not self.playerModel_ then
    local modelId = Z.ModelManager:GetModelIdByGenderAndSize(self.faceData_.Gender, self.faceData_.BodySize)
    self.playerModel_ = Z.UnrealSceneMgr:GenModelByLua(self.playerModel_, modelId, function(model)
      model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
      local equipZList = self.faceVM_.GetDefaultEquipZList(self.faceData_.Gender)
      model:SetLuaAttr(Z.LocalAttr.EWearEquip, equipZList)
      equipZList:Recycle()
      local actionData = self.faceVM_.GetDefaultActionData()
      self.actionVM_:PlayAction(model, actionData)
      model:SetLuaAttrLookAtEnable(true)
    end, self.faceData_.FaceModelName, function(model)
      self:PreloadModel(model)
      self:OnFinishMainModelLoad(model)
      local fashionVm = Z.VMMgr.GetVM("fashion")
      fashionVm.SetModelAutoLookatCamera(model)
    end)
  else
    self:PreloadModel(self.playerModel_)
    Z.UnrealSceneMgr:SetModelCustomShadow(self.playerModel_, false)
    self:OnFinishMainModelLoad(self.playerModel_)
  end
end

function Face_systemView:OnFinishMainModelLoad(model)
  if self.isThreeModel_ then
    self:hideModel(model)
  else
    self:showModel(model)
  end
end

function Face_systemView:PreloadModel(model)
  self:playerTimeline(Z.ConstValue.FaceGenderTimelineId[self.faceData_:GetPlayerGender()], model)
  if not self.playerModel1_ then
    self.playerModel1_ = Z.UnrealSceneMgr:CloneModelByLua(self.playerModel1_, model, function(model)
      model:SetAttrGoPosition(self:getModelPosition(1))
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(-10, -170, 0)))
      self:hidePartModel(model)
      local zList = ZUtil.Pool.Collections.ZList_Panda_ZGame_ModelClipData.Rent()
      zList:Add(ModelClipDataClass.New(Vector4.New(0.1416, 0, 1, 1), Z.ModelRenderMask.Hair))
      zList:Add(ModelClipDataClass.New(Vector4.New(0.1416, 0, 1, 1), Z.ModelRenderMask.HeadWear))
      zList:Add(ModelClipDataClass.New(Vector4.New(0.1416, 0.332, 0.6152, 1), Z.ModelRenderMask.BODY))
      zList:Add(ModelClipDataClass.New(Vector4.New(1, 1, 1, 1), Z.ModelRenderMask.Back))
      zList:Add(ModelClipDataClass.New(Vector4.New(1, 1, 1, 1), Z.ModelRenderMask.Tail))
      model:SetLuaAttr(Z.ModelAttr.EModelClipData, zList)
      model:SetLuaAttr(Z.ModelAttr.EModelFashionEffectEnable, false)
      zList:Recycle()
      self:setModelEmotion(model, 701)
    end, nil, function(model)
      self:OnFinishModelLoad(model)
    end)
    self.playerModel1_:SetLuaAnimBase(Z.AnimBaseData.Rent("show_07"))
  end
  if not self.playerModel2_ then
    self.playerModel2_ = Z.UnrealSceneMgr:CloneModelByLua(self.playerModel2_, model, function(model)
      model:SetAttrGoPosition(self:getModelPosition(2))
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 140, 0)))
      self:hidePartModel(model)
      local zList = ZUtil.Pool.Collections.ZList_Panda_ZGame_ModelClipData.Rent()
      zList:Add(ModelClipDataClass.New(Vector4.New(0.6398, 0, 1, 1), Z.ModelRenderMask.Hair))
      zList:Add(ModelClipDataClass.New(Vector4.New(0.6398, 0, 1, 1), Z.ModelRenderMask.HeadWear))
      zList:Add(ModelClipDataClass.New(Vector4.New(0.6398, 0.451, 0.6, 1), Z.ModelRenderMask.BODY))
      zList:Add(ModelClipDataClass.New(Vector4.New(1, 1, 1, 1), Z.ModelRenderMask.Back))
      zList:Add(ModelClipDataClass.New(Vector4.New(1, 1, 1, 1), Z.ModelRenderMask.Tail))
      model:SetLuaAttr(Z.ModelAttr.EModelClipData, zList)
      model:SetLuaAttr(Z.ModelAttr.EModelFashionEffectEnable, false)
      zList:Recycle()
      self:setModelEmotion(model, 702)
    end, nil, function(model)
      self:OnFinishModelLoad(model)
    end)
    self.playerModel2_:SetLuaAnimBase(Z.AnimBaseData.Rent("show_06"))
  end
  if not self.playerModel3_ then
    self.playerModel3_ = Z.UnrealSceneMgr:CloneModelByLua(self.playerModel3_, model, function(model)
      model:SetAttrGoPosition(self:getModelPosition(3))
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, -155.3, 0)))
      self:hidePartModel(model)
      local zList = ZUtil.Pool.Collections.ZList_Panda_ZGame_ModelClipData.Rent()
      zList:Add(ModelClipDataClass.New(Vector4.New(0.5657, 0, 1, 1), Z.ModelRenderMask.Hair))
      zList:Add(ModelClipDataClass.New(Vector4.New(0.5657, 0, 1, 1), Z.ModelRenderMask.HeadWear))
      zList:Add(ModelClipDataClass.New(Vector4.New(0.5657, 0.1578, 0.3298, 1), Z.ModelRenderMask.BODY))
      zList:Add(ModelClipDataClass.New(Vector4.New(1, 1, 1, 1), Z.ModelRenderMask.Back))
      zList:Add(ModelClipDataClass.New(Vector4.New(1, 1, 1, 1), Z.ModelRenderMask.Tail))
      model:SetLuaAttr(Z.ModelAttr.EModelClipData, zList)
      model:SetLuaAttr(Z.ModelAttr.EModelFashionEffectEnable, false)
      zList:Recycle()
      self:setModelEmotion(model, 700)
    end, nil, function(model)
      self:OnFinishModelLoad(model)
    end)
    self.playerModel3_:SetLuaAnimBase(Z.AnimBaseData.Rent("show_05"))
  end
end

function Face_systemView:hidePartModel(model)
  model:SetLuaAttr(Z.ModelAttr.EModelPinchHeight, 0)
  model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
  model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
end

function Face_systemView:OnFinishModelLoad(model)
  if self.isThreeModel_ then
    self:showModel(model)
  else
    self:hideModel(model)
  end
  self.preloadModelCount_ = self.preloadModelCount_ + 1
  if self.preloadModelCount_ >= 3 then
    self:onScreenResolutionChange()
  end
end

function Face_systemView:showModel(playerModel)
  if not playerModel then
    return
  end
  playerModel:SetLuaAttr(Z.ModelAttr.EModelRenderInvisible, false)
  Z.ModelHelper.SetRenderLayerMaskByRenderType(playerModel, Z.ZRenderingLayerUtils.RENDERING_LAYER_MASK_DEFAULT, Z.ModelRenderMask.All)
end

function Face_systemView:hideModel(playerModel)
  if not playerModel then
    return
  end
  playerModel:SetLuaAttr(Z.ModelAttr.EModelRenderInvisible, true)
  Z.ModelHelper.SetRenderLayerMaskByRenderType(playerModel, Z.ZRenderingLayerUtils.RENDERING_LAYER_MASK_INVISIBLE, Z.ModelRenderMask.All)
end

function Face_systemView:initTabSelect()
  self.curFirstTab_ = E.FaceFirstTab.HotPhoto
  self.curSecondTab_ = nil
  self.curShowView_ = self.hotPhotoView_
  self.uiBinder.node_viewport:SetAnchorPosition(0, 0)
  self.hotPhotoView_:Active(nil, self.uiBinder.node_viewport)
end

function Face_systemView:initOperateBtn()
  local actionData = self.faceVM_.GetDefaultActionData()
  self.actionVM_:PlayAction(self.playerModel_, actionData)
  self.uiBinder.tog_focus:RemoveAllListeners()
  self.uiBinder.tog_focus.isOn = true
  self.isFocus_ = true
  self.isThreeModel_ = true
  self.isShowOneModel_ = true
  self:changeFocus(true, true)
  self.uiBinder.tog_focus:AddListener(function(isOn)
    if isOn then
      self.isThreeModel_ = true
      self:changeFocus(true)
    else
      self.isThreeModel_ = false
      self:changeFocus(self.isFocus_)
    end
  end)
  self:initExpressionTog(self.uiBinder.tog_action, self.uiBinder.togs_action_option_press, function()
    self:loadActionOptions()
  end)
  self:initWearHideTog()
end

function Face_systemView:changeFocus(isOnHead, isFirstOpen)
  Z.CoroUtil.create_coro_xpcall(function()
    if self.curCameraAnim_ == 1 then
      Z.CameraMgr:StopRunningCameraTemplate(4081)
      Z.CameraMgr:StopRunningCameraTemplate(4082)
      Z.CameraMgr:StopRunningCameraTemplate(4083)
      Z.CameraMgr:StopRunningCameraTemplate(4084)
      Z.CameraMgr:StopRunningCameraTemplate(4085)
    elseif self.curCameraAnim_ == 2 then
      Z.CameraMgr:StopRunningCameraTemplate(4036)
      Z.CameraMgr:StopRunningCameraTemplate(4037)
      Z.CameraMgr:StopRunningCameraTemplate(4038)
      Z.CameraMgr:StopRunningCameraTemplate(4034)
      Z.CameraMgr:StopRunningCameraTemplate(4040)
    elseif self.curCameraAnim_ == 3 then
      Z.CameraMgr:StopRunningCameraTemplate(4036)
      Z.CameraMgr:StopRunningCameraTemplate(4037)
      Z.CameraMgr:StopRunningCameraTemplate(4038)
      Z.CameraMgr:StopRunningCameraTemplate(4039)
      Z.CameraMgr:StopRunningCameraTemplate(4040)
    end
    self.curCameraAnim_ = nil
    Z.UnrealSceneMgr:SetAutoChangeLook(not self.isThreeModel_)
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
    local delayChangeModel = false
    if isOnHead then
      if self.isThreeModel_ then
        Z.UnrealSceneMgr:DoCameraAnim("faceThreeHead")
        delayChangeModel = self.curCameraAnim_ ~= 1
        self.curCameraAnim_ = 1
        self:hideModel(self.playerModel_)
      else
        Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceHead", Vector3.New(0, self.offset_.y, 0))
        self.curCameraAnim_ = 2
      end
      self.uiBinder.tog_action.isOn = false
    else
      Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceBody", Vector3.New(0, self.offset_.y, 0))
      self.curCameraAnim_ = 3
      if self.playerModel_ then
        self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
      end
    end
    if isFirstOpen then
      Z.UIMgr:FadeOut()
    end
    self:asyncChangeModelShow(delayChangeModel)
  end)()
  self:refreshTogActionVisable()
end

function Face_systemView:asyncChangeModelShow(delayChangeModel)
  if delayChangeModel then
    Z.Delay(0.05, ZUtil.ZCancelSource.NeverCancelToken)
  end
  if self.inputMask_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, self.inputMask_, false)
    self.inputMask_ = nil
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_left, not self.isThreeModel_)
  if self.isThreeModel_ then
    local gender = self.faceData_:GetPlayerGender()
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background1", false)
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background2", gender == 2)
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background3", gender == 1)
    self:hideModel(self.playerModel_)
    self:showModel(self.playerModel1_)
    self:showModel(self.playerModel2_)
    self:showModel(self.playerModel3_)
    self.inputMask_ = 4294967295
    self.uiBinder.Ref:SetVisible(self.uiBinder.rayimg_unrealscene_drag, false)
  else
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background1", true)
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background2", false)
    Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background3", false)
    self:showModel(self.playerModel_)
    self:hideModel(self.playerModel1_)
    self:hideModel(self.playerModel2_)
    self:hideModel(self.playerModel3_)
    self.inputMask_ = 4294967293
    self.uiBinder.Ref:SetVisible(self.uiBinder.rayimg_unrealscene_drag, true)
  end
  Z.PlayerInputController.InputTouchCheckOverUICount = 1
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, self.inputMask_, true)
end

function Face_systemView:setModelEmotion(model, emotionId)
  if 0 < emotionId then
    model:SetLuaAttrEmoteInfo(emotionId, -1, true)
  else
    model:SetLuaAttrEmoteInfo(0)
  end
end

function Face_systemView:initExpressionTog(togNode, groupNode, onFunc)
  self.uiBinder.Ref:SetVisible(groupNode, false)
  groupNode.ContainGoEvent:AddListener(function(isInSide)
    if not isInSide then
      togNode.isOn = false
    end
  end)
  togNode.isOn = false
  togNode:AddListener(function(isOn)
    self.uiBinder.Ref:SetVisible(groupNode, isOn)
    if isOn then
      onFunc()
      groupNode:StartCheck()
    else
      self:clearActionUnit()
      groupNode:StopCheck()
    end
  end)
end

function Face_systemView:refreshModelEmote(emoteId)
  Z.ModelHelper.PlayFacialByEmoteId(self.playerModel_, emoteId)
end

function Face_systemView:loadActionOptions()
  Z.CoroUtil.create_coro_xpcall(function()
    if not self.actionList_ then
      self.actionList_ = {}
    end
    self:asyncLoadActionBtn(1, function()
      self:playDefaultTimeline()
    end)
    for i = 1, #self.timelineInfoList_ do
      local timelineId = self.timelineInfoList_[i][1]
      local emoteId = self.timelineInfoList_[i][2]
      self:asyncLoadActionBtn(i + 1, function()
        self.actionIndex_ = i + 1
        self:refreshModelEmote(emoteId)
        self:playerTimeline(timelineId, self.playerModel_)
      end)
    end
    self.units[string.zconcat("action", self.actionIndex_)].tog_digit:SetIsOnWithoutCallBack(true)
  end)()
end

function Face_systemView:checkTimelineAction()
  if self.curSecondDefaultTab_ ~= ESecondTab.FaceShape then
    return
  end
  self:playDefaultTimeline()
end

function Face_systemView:refreshTogActionVisable()
  if self.isThreeModel_ or self.curSecondDefaultTab_ == ESecondTab.FaceShape then
    self.uiBinder.tog_action.isOn = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_action, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.tog_action, true)
  end
end

function Face_systemView:playDefaultTimeline()
  self.actionIndex_ = 1
  local timelineId = Z.ConstValue.FaceGenderTimelineId[self.faceData_:GetPlayerGender()]
  if self.curTimelineId_ == timelineId then
    return
  end
  self:refreshModelEmote(0)
  self:playerTimeline(timelineId, self.playerModel_)
end

function Face_systemView:playerTimeline(timelineId, model)
  Z.UITimelineDisplay:Stop()
  Z.UITimelineDisplay:BindModel(0, model)
  if table.zcontains(Z.ConstValue.FaceGenderTimelineId, timelineId) then
    Z.ModelHelper.SetLookAtTransform(model, Z.CameraMgr.MainCamTrans, true)
  else
    Z.ModelHelper.ResetLookAt(model, true)
  end
  Z.UITimelineDisplay:Play(timelineId)
  self.curTimelineId_ = timelineId
  local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.curTimelineId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
end

function Face_systemView:asyncLoadActionBtn(index, func)
  local digitTogPath = Z.IsPCUI and "ui/prefabs/face/face_digit_tog_item_tpl_pc" or "ui/prefabs/face/face_digit_tog_item_tpl"
  local unit = self:AsyncLoadUiUnit(digitTogPath, string.zconcat("action", index), self.uiBinder.togs_action_option_ref)
  unit.lab_digit_on.text = index
  unit.lab_digit_off.text = index
  unit.tog_digit.isOn = false
  unit.tog_digit.group = self.uiBinder.togs_action_option
  unit.tog_digit:AddListener(function(isOn)
    if isOn then
      func()
    end
  end)
  self.actionList_[string.zconcat("action", index)] = unit
end

function Face_systemView:preLoadTimeline()
  self.timelineInfoList_ = {}
  if self.faceData_.Gender == Z.PbEnum("EGender", "GenderMale") then
    self.timelineInfoList_ = Z.Global.RoleEditorShowActionM
  else
    self.timelineInfoList_ = Z.Global.RoleEditorShowActionF
  end
  for _, timelineInfo in ipairs(self.timelineInfoList_) do
    local timelineId = timelineInfo[1]
    if timelineId then
      Z.UITimelineDisplay:AsyncPreLoadTimeline(timelineId, self.cancelSource:CreateToken())
    end
  end
  local gender = self.faceData_:GetPlayerGender()
  Z.UITimelineDisplay:AsyncPreLoadTimeline(Z.ConstValue.FaceGenderTimelineId[gender], self.cancelSource:CreateToken())
  Z.UITimelineDisplay:AsyncPreLoadTimeline(Z.ConstValue.FaceGenderTimelineIdEffect[gender], self.cancelSource:CreateToken())
end

function Face_systemView:updateFaceOperationBtnState()
  self.uiBinder.btn_move.IsDisabled = not self.faceData_:IsShowMoveOperation()
  self.uiBinder.btn_return.IsDisabled = not self.faceData_:IsShowReturnOperation()
end

function Face_systemView:onScreenResolutionChange()
  local rootCanvas = Z.UIRoot.RootCanvas.transform
  local rate = math.floor(rootCanvas.localScale.x * 100000) / 100000 / 0.00925
  local width = math.floor(Z.UIRoot.RootCanvas.transform.rect.width * 100) / 100
  local height = math.floor(Z.UIRoot.RootCanvas.transform.rect.height * 100) / 100
  if 1.7777777777777777 <= width / height then
    self.scale_ = height / 1080 * rate
  else
    self.scale_ = width / 1920 * rate
  end
  Z.UnrealSceneMgr:SetNodeScale("modelRoot/background2", 0.265, 0.265, 1)
  Z.UnrealSceneMgr:SetNodeScale("modelRoot/background3", 0.265, 0.265, 1)
  Z.UnrealSceneMgr:SetNodeLocalPosition("modelRoot/background2", -0.07, 0.8, 1)
  Z.UnrealSceneMgr:SetNodeLocalPosition("modelRoot/background3", -0.07, 0.8, 1)
  if self.playerModel1_ then
    self.playerModel1_:SetAttrGoPosition(self:getModelPosition(1))
  end
  if self.playerModel2_ then
    self.playerModel2_:SetAttrGoPosition(self:getModelPosition(2))
  end
  if self.playerModel3_ then
    self.playerModel3_:SetAttrGoPosition(self:getModelPosition(3))
  end
end

function Face_systemView:getModelPosition(modelIndex)
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  local gender = self.faceData_:GetPlayerGender()
  local size = self.faceData_:GetPlayerBodySize()
  local position = modelPositionParam[gender][size]
  return Vector3.New(position[modelIndex].x + pos.x, position[modelIndex].y + pos.y, position[modelIndex].z * self.scale_ + pos.z)
end

function Face_systemView:initWearHideTog()
  self.uiBinder.tog_wear.isOn = false
  self.uiBinder.tog_wear:AddListener(function(isHideWear)
    local settingStr = ""
    if isHideWear then
      local regionDict = {}
      for _, region in pairs(E.FashionRegion) do
        regionDict[region] = 2
      end
      local settingVM = Z.VMMgr.GetVM("fashion_setting")
      settingStr = settingVM.RegionDictToSettingStr(regionDict)
    else
      settingStr = self:getCurFashionSettingStr()
    end
    if self.playerModel_ then
      self.playerModel_:SetLuaAttr(Z.LocalAttr.EWearSetting, settingStr)
    end
    if self.playerModel1_ then
      self.playerModel1_:SetLuaAttr(Z.LocalAttr.EWearSetting, settingStr)
    end
    if self.playerModel2_ then
      self.playerModel2_:SetLuaAttr(Z.LocalAttr.EWearSetting, settingStr)
    end
    if self.playerModel3_ then
      self.playerModel3_:SetLuaAttr(Z.LocalAttr.EWearSetting, settingStr)
    end
  end)
end

function Face_systemView:getCurFashionSettingStr()
  local regionDict = {}
  for _, region in pairs(E.FashionRegion) do
    regionDict[region] = 1
  end
  local settingVM = Z.VMMgr.GetVM("fashion_setting")
  local settingStr = settingVM.RegionDictToSettingStr(regionDict)
  return settingStr
end

function Face_systemView:OnClearTimeLine()
end

function Face_systemView:clearActionUnit()
  if self.actionList_ then
    for unitName, unit in pairs(self.actionList_) do
      unit.tog_digit.group = nil
      unit.tog_digit:RemoveAllListeners()
      self:RemoveUiUnit(unitName)
    end
  end
  self.actionList_ = nil
end

function Face_systemView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Face_systemView:OnDeActive()
  if self.inputMask_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, self.inputMask_, false)
    self.inputMask_ = nil
  end
  self.uiBinder.tog_action:RemoveAllListeners()
  self:clearActionUnit()
  Z.PlayerInputController.InputTouchCheckOverUICount = 0
  self.preloadModelCount_ = 0
  self.isFocus_ = nil
  self.isShowOneModel_ = nil
  self:RemoveEvents()
  Z.PlayerInputController.IsCheckZoomClickingUI = true
  Z.PlayerInputController:SetCameraStretchIgnoreCheckUI(false)
  Z.UITimelineDisplay:ClearTimeLine()
  self:OnClearTimeLine()
  Z.UnrealSceneMgr:SetAutoChangeLook(false)
  Z.UnrealSceneMgr:RestUnrealSceneCameraZoomRange()
  Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(0.4, 0.5))
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background1", false)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background2", false)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background3", false)
  self.curFirstTab_ = nil
  self.curShowView_ = nil
  if not self.needCacheModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
  end
  self.playerModel_ = nil
  Z.UnrealSceneMgr:ClearModel(self.playerModel1_)
  self.playerModel1_ = nil
  Z.UnrealSceneMgr:ClearModel(self.playerModel2_)
  self.playerModel2_ = nil
  Z.UnrealSceneMgr:ClearModel(self.playerModel3_)
  self.playerModel3_ = nil
  self.hotPhotoView_:DeActive()
  self.bodyView_:DeActive()
  self.hairView_:DeActive()
  self.faceShapeView_:DeActive()
  self.eyebrowView_:DeActive()
  self.eyeView_:DeActive()
  self.eyelashView_:DeActive()
  self.pupilView_:DeActive()
  self.noseView_:DeActive()
  self.mouthView_:DeActive()
  self.beardView_:DeActive()
  self.toothView_:DeActive()
  self.eyeshadowView_:DeActive()
  self.lipstickView_:DeActive()
  self.featureOneView_:DeActive()
  self.featureTwoView_:DeActive()
  self.faceData_:ResetFaceEditorList()
end

function Face_systemView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FaceAttrChange, self.onFaceAttrChange, self)
  Z.EventMgr:Add(Z.ConstValue.FaceOptionAllChange, self.onFaceOptionAllChange, self)
  Z.EventMgr:Add(Z.ConstValue.Face.FaceRefreshOperationBtnState, self.updateFaceOperationBtnState, self)
  Z.EventMgr:Add(Z.ConstValue.Screen.UIResolutionChange, self.onScreenResolutionChange, self)
end

function Face_systemView:RemoveEvents()
  Z.EventMgr:Remove(Z.ConstValue.FaceAttrChange, self.onFaceAttrChange, self)
  Z.EventMgr:Remove(Z.ConstValue.FaceOptionAllChange, self.onFaceOptionAllChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Face.FaceRefreshOperationBtnState, self.updateFaceOperationBtnState, self)
  Z.EventMgr:Remove(Z.ConstValue.Screen.UIResolutionChange, self.onScreenResolutionChange, self)
end

function Face_systemView:onFaceAttrChange(attrType, ...)
  if not self.playerModel_ then
    return
  end
  local arg = {
    ...
  }
  if attrType == Z.ModelAttr.EModelCHairGradient then
    self:setAllModelAttr("SetLuaHairGradientAttr", table.unpack(arg))
  elseif attrType == Z.ModelAttr.EModelHairWearId then
    self:setAllModelAttr("SetLuaIntAttr", attrType, table.unpack(arg))
  elseif attrType == Z.ModelAttr.EModelPinchHeight then
    self:setModelAttr("SetLuaAttr", attrType, table.unpack(arg))
  else
    self:setAllModelAttr("SetLuaAttr", attrType, table.unpack(arg))
  end
end

function Face_systemView:setModelAttr(funcName, ...)
  local arg = {
    ...
  }
  if self.playerModel_ then
    self.playerModel_[funcName](self.playerModel_, table.unpack(arg))
  end
end

function Face_systemView:setAllModelAttr(funcName, ...)
  local arg = {
    ...
  }
  if self.playerModel_ then
    self.playerModel_[funcName](self.playerModel_, table.unpack(arg))
  end
  if self.playerModel1_ then
    self.playerModel1_[funcName](self.playerModel1_, table.unpack(arg))
  end
  if self.playerModel2_ then
    self.playerModel2_[funcName](self.playerModel2_, table.unpack(arg))
  end
  if self.playerModel3_ then
    self.playerModel3_[funcName](self.playerModel3_, table.unpack(arg))
  end
end

function Face_systemView:onFaceOptionAllChange()
  local attrVM = Z.VMMgr.GetVM("face_attr")
  attrVM.UpdateAllFaceAttr()
end

function Face_systemView:switchFirstTab(tab)
  self.curFirstTab_ = tab
end

function Face_systemView:OnInputBack()
  self.needCacheModel_ = false
  self.faceVM_.CloseFaceSystemView()
end

function Face_systemView:onClickRandom()
  if Z.SDKDevices.IsCloudGame then
    self:faceRandom()
    return
  end
  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("DescFaceRandomConfirm"), function()
    self:faceRandom()
  end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.FaceRandomPrompt)
end

function Face_systemView:faceRandom()
  local randomVM = Z.VMMgr.GetVM("face_random")
  self:refreshCurRotation()
  self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
  self.faceVM_.RecordFaceEditorCommand()
  randomVM.RandomFace()
  self:playRandomTimeLine()
  self.faceVM_.CacheFaceData()
end

function Face_systemView:playRandomTimeLine()
  self.actionIndex_ = 1
  self:refreshModelEmote(0)
  self:playerTimeline(Z.ConstValue.FaceGenderTimelineIdEffect[self.faceData_:GetPlayerGender()], self.playerModel_)
  if self.curShowView_ == self.hotPhotoView_ then
    self.hotPhotoView_:ClearSelect()
  end
end

function Face_systemView:onClickRevert()
  if not self.faceVM_.IsAttrChange() then
    return
  end
  if Z.SDKDevices.IsCloudGame then
    self:revertFace()
    return
  end
  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("RevertFaceData"), function()
    self:revertFace()
  end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.ConfirmRevertFaceData)
end

function Face_systemView:revertFace()
  self.faceVM_.RecordFaceEditorCommand()
  local templateVM = Z.VMMgr.GetVM("face_template")
  templateVM.UpdateOptionDictByModelId(self.faceData_.ModelId)
  self.faceVM_.CacheFaceData()
end

function Face_systemView:refreshCameraFocus(value)
  self.offset_ = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(self.faceData_:GetPlayerModelId())
  local scale = self.faceVM_.GetLookAtOffsetScale(E.ELookAtScaleType.BodyHeight)
  Z.UnrealSceneMgr:SetZoomAutoChangeLookAtByOffset(self.offset_.x + value / scale, self.offset_.y)
end

function Face_systemView:onClickSaveFaceDataFile()
  local shareCode = Z.FaceShareHelper.CreateFaceShareCode()
  self.cameraVM_.OpenCameraViewByUnrealWithFaceData(shareCode)
end

function Face_systemView:onClickLoadFaceDataFile()
  self.faceVM_.OpenFaceShareView(E.FaceShareType.Input)
end

function Face_systemView:onClickFinish()
  self:refreshModelEmote(0)
  if Z.IsPreFaceMode then
    self:onClickSaveFaceDataFile()
  else
    self.needCacheModel_ = false
    local professionVm = Z.VMMgr.GetVM("profession")
    professionVm.OpenProfessionSelectView(true)
  end
end

function Face_systemView:startPlaySelectAnim()
  self.uiBinder.node_content:Rewind(Z.DOTweenAnimType.Tween_3)
  self.uiBinder.node_content:Restart(Z.DOTweenAnimType.Tween_3)
end

function Face_systemView:startTabPlaySelectAnim()
  self.uiBinder.node_content:Restart(Z.DOTweenAnimType.Tween_2)
end

function Face_systemView:startTab4PlaySelectAnim()
  self.uiBinder.node_content:Restart(Z.DOTweenAnimType.Tween_4)
end

function Face_systemView:startAnimatedShow()
  self.uiBinder.node_content:Rewind(Z.DOTweenAnimType.Open)
  self.uiBinder.node_content:Restart(Z.DOTweenAnimType.Open)
end

function Face_systemView:startAnimatedHide()
  self.uiBinder.node_content:Rewind(Z.DOTweenAnimType.Close)
  self.uiBinder.node_content:Restart(Z.DOTweenAnimType.Close)
end

function Face_systemView:GetCacheData()
  local viewData = {
    needCacheModel = self.needCacheModel_
  }
  return viewData
end

return Face_systemView
