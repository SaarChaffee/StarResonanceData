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
end

function Face_createView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera(true)
  if self.faceData_.Gender == 0 then
    self.faceData_.Gender = Z.PbEnum("EGender", "GenderFemale")
  end
  if self.faceData_.BodySize == 0 then
    self.faceData_.BodySize = Z.PbEnum("EBodySize", "BodySizeS")
  end
  self.faceData_.FaceState = E.FaceDataState.Create
  self.gender_ = self.faceData_.Gender
  self.size_ = self.faceData_.BodySize
  Z.UITimelineDisplay:ClearTimeLine()
  Z.UnrealSceneMgr:ClearModelByName(self.faceData_.FaceModelName)
  self:onStartAnimShow()
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
    self:refreshPlayerModel(true)
  end)
  self.uiBinder.tog_girl:AddListener(function()
    self.gender_ = Z.PbEnum("EGender", "GenderFemale")
    self:refreshPlayerModel(true)
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
    self:refreshPlayerModel(true)
  end)
  for sizeEnum, tabData in pairs(BodySizeTabDataDict) do
    local togNode = self.uiBinder[tabData.NodeName]
    togNode:RemoveAllListeners()
    togNode:SetIsOnWithoutCallBack(sizeEnum == self.size_)
    togNode.group = self.uiBinder.togs_size
    togNode:AddListener(function(isOn)
      if isOn and self.size_ ~= sizeEnum then
        self.size_ = sizeEnum
        self:refreshPlayerModel(true)
      end
    end)
  end
  self.uiBinder.rayimg_unrealscene_drag.onDrag:AddListener(function(go, eventData)
    self:onModelDrag(eventData)
  end)
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self.createCount_ = 0
  self:preloadModel()
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
      Z.UnrealSceneMgr:GenModelByLua(nil, modelId, function(model)
        model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
        model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, Z.ConstValue.FaceGenderRotation[i], 0)))
        local equipZList = self.faceVM_.GetDefaultEquipZList(i)
        model:SetLuaAttr(Z.LocalAttr.EWearEquip, equipZList)
        equipZList:Recycle()
        local actionData = self.faceVM_.GetDefaultActionData()
        model:SetLuaAttrLookAtEnable(true)
        self.actionVM_:PlayAction(model, actionData)
      end, modelCacheName, function(model)
        model:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_INVISIBLE)
        self.loadModels_[i][j] = model
        local fashionVm = Z.VMMgr.GetVM("fashion")
        fashionVm.SetModelAutoLookatCamera(model)
        self:onModelLoadFinish()
      end)
    end
  end
  Z.UITimelineDisplay:AsyncPreLoadTimeline(Z.ConstValue.FaceGenderTimelineId[1], self.cancelSource:CreateToken())
  Z.UITimelineDisplay:AsyncPreLoadTimeline(Z.ConstValue.FaceGenderTimelineId[2], self.cancelSource:CreateToken())
  Z.UITimelineDisplay:AsyncPreLoadTimeline(Z.ConstValue.FaceGenderTimelineIdEffect[1], self.cancelSource:CreateToken())
  Z.UITimelineDisplay:AsyncPreLoadTimeline(Z.ConstValue.FaceGenderTimelineIdEffect[2], self.cancelSource:CreateToken())
end

function Face_createView:onModelLoadFinish()
  self.createCount_ = self.createCount_ + 1
  if self.createCount_ >= 6 then
    self:refreshPlayerModel(false)
    self.offset_ = Z.UnrealSceneMgr:GetLookAtOffsetByModelId(self.modelId_)
    Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(0.5, 0.5))
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset("faceGenderSelectEnter", Vector3.New(0, self.offset_.y, 0))
    local args = {}
    
    function args.EndCallback()
      self:checkCacheFaceData()
    end
    
    Z.UIMgr:FadeOut(args)
  end
end

function Face_createView:refreshPlayerModel(needEffectTimeline)
  self.modelId_ = Z.ModelManager:GetModelIdByGenderAndSize(self.gender_, self.size_)
  self.faceData_.FaceModelName = string.zconcat(self.faceData_.FaceDefaultModelName, "_", self.gender_, "_", self.size_)
  if self.playerModel_ then
    self.playerModel_:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_INVISIBLE)
  end
  self.playerModel_ = self.loadModels_[self.gender_][self.size_]
  if self.playerModel_ then
    self.playerModel_:SetAttrGoLayer(Panda.Utility.ZLayerUtils.LAYER_UNREALSCENE)
  end
  self.faceData_.Height = self.playerModel_:GetAttrGoHeight()
  Z.UnrealSceneMgr:SetModelCustomShadow(self.playerModel_, true)
  Z.UITimelineDisplay:ClearTimeLine()
  Z.UITimelineDisplay:BindModel(0, self.playerModel_)
  if needEffectTimeline then
    self.curTimelineId_ = Z.ConstValue.FaceGenderTimelineIdEffect[self.gender_]
  else
    self.curTimelineId_ = Z.ConstValue.FaceGenderTimelineId[self.gender_]
  end
  self.curRotation_ = Z.ConstValue.FaceGenderRotation[self.gender_]
  Z.UITimelineDisplay:Play(self.curTimelineId_)
  self:refreshRotation()
end

function Face_createView:checkCacheFaceData()
  if self.viewData == nil or not self.viewData.checkFaceDataCache then
    return
  end
  self.viewData.checkFaceDataCache = false
  if Z.IsPreFaceMode then
    self:checkCloudGameCacheFaceData()
  else
    self:checkAccountCacheFaceData()
  end
end

function Face_createView:checkCloudGameCacheFaceData()
  local appScheme = Z.LuaBridge.GetAppScheme()
  local res = string.split(appScheme, "_")
  if #res < 2 then
    return
  end
  if Z.FaceShareHelper.IsFaceShareScheme(res[1]) then
    return
  end
  local faceShareCode = res[2]
  if not Z.FaceShareHelper.IsFaceShareCode(faceShareCode) then
    return
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("faceGenderUseCacheFaceData"), function()
    Z.FaceShareHelper.UseFaceShareCode(faceShareCode, true, true)
    self.faceVM_.OpenFaceSystemView(true)
  end)
end

function Face_createView:checkAccountCacheFaceData()
  if not Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Account, self.faceData_.FaceCacheData) then
    return
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("faceGenderUseCacheFaceData"), function()
    self:useCacheFaceData()
    self.faceVM_.OpenFaceSystemView(true)
  end, function()
    Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Account, self.faceData_.FaceCacheData)
  end)
end

function Face_createView:useCacheFaceData()
  local faceStringData = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Account, self.faceData_.FaceCacheData, "")
  if faceStringData == "" then
    return
  end
  local gender, bodySize, height = self.faceVM_.GetGenderBodySizeByFaceDataString(faceStringData)
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(gender, bodySize)
  self.modelId_ = modelId
  self.gender_ = gender
  self.size_ = bodySize
  self.faceData_.ModelId = modelId
  self.faceData_.Gender = gender
  self.faceData_.BodySize = bodySize
  self.faceData_.Height = height
  self:initFaceData()
  local faceData = self.faceVM_.FaceDataStringToTable(faceStringData)
  self.faceVM_.UseFashionLuaDataWithDefaultValue(faceData, true)
  self:refreshPlayerModel(false)
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
  for i = Z.PbEnum("EGender", "GenderMale"), Z.PbEnum("EGender", "GenderFemale") do
    for j = Z.PbEnum("EBodySize", "BodySizeS"), Z.PbEnum("EBodySize", "BodySizeL") do
      if self.loadModels_[i] and self.loadModels_[i][j] then
        Z.UnrealSceneMgr:ClearModel(self.loadModels_[i][j])
      end
    end
  end
  self.loadModels_ = nil
end

function Face_createView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Face_createView:OnInputBack()
  local playerData = Z.DataMgr.Get("player_data")
  if playerData.CharDataList and #playerData.CharDataList > 0 then
    Z.UIMgr:CloseView(self.viewConfigKey)
  else
    self.loginVM_:KickOffByClient(E.KickOffClientErrCode.NormalReturn, true)
  end
end

function Face_createView:onModelDrag(eventData)
  if not self.curRotation_ then
    return
  end
  self.curRotation_ = self.curRotation_ - eventData.delta.x * Z.ConstValue.ModelRotationScaleValue
  self:refreshRotation()
end

function Face_createView:refreshRotation()
  local quaternion = Quaternion.Euler(Vector3.New(0, self.curRotation_, 0))
  Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.curTimelineId_, quaternion.x, quaternion.y, quaternion.z, quaternion.w)
end

function Face_createView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Face_createView
