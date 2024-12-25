local UI = Z.UI
local super = require("ui.ui_view_base")
local Face_createView = class("Face_createView", super)
local BodySizeTabDataDict = {
  [Z.PbEnum("EBodySize", "BodySizeS")] = {NodeName = "tog_s"},
  [Z.PbEnum("EBodySize", "BodySizeM")] = {NodeName = "tog_m"},
  [Z.PbEnum("EBodySize", "BodySizeL")] = {NodeName = "tog_l"}
}

function Face_createView:ctor()
  self.uiBinder = nil
  super.ctor(self, "face_create")
  self.loginVM_ = Z.VMMgr.GetVM("login")
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.actionVM_ = Z.VMMgr.GetVM("action")
  self.init_ = true
end

function Face_createView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera(true)
  if self.faceData_.Gender == 0 then
    self.faceData_.Gender = Z.PbEnum("EGender", "GenderMale")
  end
  if self.faceData_.BodySize == 0 then
    self.faceData_.BodySize = Z.PbEnum("EBodySize", "BodySizeM")
  end
  self.faceData_.FaceState = E.FaceDataState.Create
  self.gender_ = self.faceData_.Gender
  self.size_ = self.faceData_.BodySize
  Z.UnrealSceneMgr:ClearModelByName(self.faceData_.FaceModelName)
  self:onStartAnimShow()
  self.curRotation_ = 180
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_gender_switch, false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background1", false)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background2", false)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background3", false)
  self.uiBinder.tog_boy:RemoveAllListeners()
  self.uiBinder.tog_girl:RemoveAllListeners()
  self.uiBinder.tog_boy:SetIsOnWithoutCallBack(self.gender_ == 1)
  self.uiBinder.tog_girl:SetIsOnWithoutCallBack(self.gender_ == 2)
  self.uiBinder.tog_boy.group = self.uiBinder.togs_gender
  self.uiBinder.tog_girl.group = self.uiBinder.togs_gender
  self.uiBinder.tog_boy:AddListener(function()
    self.gender_ = Z.PbEnum("EGender", "GenderMale")
    self:refreshPlayerModel()
  end)
  self.uiBinder.tog_girl:AddListener(function()
    self.gender_ = Z.PbEnum("EGender", "GenderFemale")
    self:refreshPlayerModel()
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    self:OnInputBack()
  end)
  self:AddClick(self.uiBinder.btn_next, function()
    self.faceData_.ModelId = self.modelId_
    self.faceData_.Gender = self.gender_
    self.faceData_.BodySize = self.size_
    self:initFaceData()
    self.faceVM_.OpenFaceSystemView(true)
  end)
  self:AddClick(self.uiBinder.btn_gender_switch, function()
    if self.gender_ ~= Z.PbEnum("EGender", "GenderFemale") then
      self.gender_ = Z.PbEnum("EGender", "GenderFemale")
    else
      self.gender_ = Z.PbEnum("EGender", "GenderMale")
    end
    self:refreshPlayerModel()
  end)
  for sizeEnum, tabData in pairs(BodySizeTabDataDict) do
    local togNode = self.uiBinder[tabData.NodeName]
    togNode:RemoveAllListeners()
    togNode:SetIsOnWithoutCallBack(sizeEnum == self.size_)
    togNode.group = self.uiBinder.togs_size
    togNode:AddListener(function(isOn)
      if isOn and self.size_ ~= sizeEnum then
        self.size_ = sizeEnum
        self:refreshPlayerModel()
      end
    end)
  end
  self.uiBinder.rayimg_unrealscene_drag.onDrag:AddListener(function(go, eventData)
    self:onModelDrag(eventData)
  end)
  Z.UITimelineDisplay:ClearTimeLine()
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self.createCount_ = 0
  if self.init_ then
    self.init_ = false
    self:preloadModel()
  else
    self:onModelLoadFinish(true)
  end
end

function Face_createView:preloadModel()
  self.loadModels_ = {}
  for i = Z.PbEnum("EGender", "GenderMale"), Z.PbEnum("EGender", "GenderFemale") do
    for j = Z.PbEnum("EBodySize", "BodySizeS"), Z.PbEnum("EBodySize", "BodySizeL") do
      local modelId = Z.ModelManager:GetModelIdByGenderAndSize(i, j)
      local modelCacheName = string.zconcat(self.faceData_.FaceDefaultModelName, "_", i, "_", j)
      if self.loadModels_[i] == nil then
        self.loadModels_[i] = {}
      end
      self.loadModels_[i][j] = Z.UnrealSceneMgr:GenModelByLua(self.loadModels_[i][j], modelId, function(model)
        model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
        model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
        local equipZList = self.faceVM_.GetDefaultEquipZList(i)
        model:SetLuaAttr(Z.LocalAttr.EWearEquip, equipZList)
        equipZList:Recycle()
        local actionData = self.faceVM_.GetDefaultActionData()
        self.actionVM_:PlayAction(model, actionData)
      end, modelCacheName, function(model)
        model:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_INVISIBLE)
        self:onModelLoadFinish()
      end)
    end
  end
end

function Face_createView:onModelLoadFinish(notPreLoad)
  self.createCount_ = self.createCount_ + 1
  if self.createCount_ >= 6 or notPreLoad then
    self:refreshPlayerModel()
    self.offset_ = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(self.modelId_)
    Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(0.5, 0.5))
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceFocusBody", Vector3.New(0, self.offset_.y, 0))
    local args = {}
    
    function args.EndCallback()
      self:checkCacheFaceData()
    end
    
    Z.UIMgr:FadeOut(args)
  end
end

function Face_createView:refreshPlayerModel()
  Z.UITimelineDisplay:ClearTimeLine()
  self.curRotation_ = 180
  self.modelId_ = Z.ModelManager:GetModelIdByGenderAndSize(self.gender_, self.size_)
  local cacheName = string.zconcat(self.faceData_.FaceDefaultModelName, "_", self.gender_, "_", self.size_)
  self.faceData_.FaceModelName = cacheName
  if self.playerModel_ then
    self.playerModel_:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_INVISIBLE)
  end
  self.playerModel_ = Z.UnrealSceneMgr:GetCacheModel(self.faceData_.FaceModelName)
  if self.playerModel_ then
    self.playerModel_:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_UNREALSCENE)
    self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
  else
    self.playerModel_ = Z.UnrealSceneMgr:GenModelByLua(nil, self.modelId_, function(model)
      model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
      model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
      local equipZList = self.faceVM_.GetDefaultEquipZList(self.gender_)
      model:SetLuaAttr(Z.LocalAttr.EWearEquip, equipZList)
      equipZList:Recycle()
      local actionData = self.faceVM_.GetDefaultActionData()
      self.actionVM_:PlayAction(model, actionData)
    end, self.faceData_.FaceModelName)
  end
  self.faceData_.Height = self.playerModel_:GetAttrGoHeight()
  Z.LuaBridge.ClearFSR3RenderPass()
  Z.UnrealSceneMgr:SetModelCustomShadow(self.playerModel_, true)
  Z.UITimelineDisplay:BindModel(self.playerModel_)
  Z.UITimelineDisplay:Play(50000004)
end

function Face_createView:checkCacheFaceData()
  local data = Z.DataMgr.Get("player_data")
  if self.faceData_.CanUseCacheFaceData and self.faceData_.CacheFaceDataAccountName == data.AccountName then
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("faceGenderUseCacheFaceData"), function()
      Z.DialogViewDataMgr:CloseDialogView()
      self.faceVM_.OpenFaceSystemView(true)
    end, function()
      Z.DialogViewDataMgr:CloseDialogView()
      self.faceData_:ResetFaceCacheValue()
    end)
  else
    self.faceData_:ResetFaceCacheValue()
  end
end

function Face_createView:initFaceData()
  self.faceData_:InitFaceOption()
  local templateVM = Z.VMMgr.GetVM("face_template")
  templateVM.UpdateFaceInitOptionDictByModelId()
  templateVM.UpdateOptionDictByModelId(self.modelId_, false)
end

function Face_createView:OnDeActive()
  self.createCount_ = 0
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.UITimelineDisplay:ClearTimeLine()
  self.playerModel_ = nil
end

function Face_createView:OnInputBack()
  self.loginVM_:KickOffByClient(E.KickOffClientErrCode.NormalReturn, true)
end

function Face_createView:onModelDrag(eventData)
  if not self.playerModel_ then
    return
  end
  self.curRotation_ = self.curRotation_ - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  self.playerModel_:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, self.curRotation_, 0)))
end

function Face_createView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Face_createView
