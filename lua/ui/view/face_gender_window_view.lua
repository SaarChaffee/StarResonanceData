local UI = Z.UI
local super = require("ui.ui_view_base")
local Face_gender_windowView = class("Face_gender_windowView", super)
local EFFECT_PATH_BG = "ui/p_fx_ui_xingbiexuanzhe_hpy"
local EFFECT_PATH_XUSHI = "ui/p_fx_ui_nieren_bg_xushi"

function Face_gender_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "face_gender_window")
  self.loginVM_ = Z.VMMgr.GetVM("login")
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.actionVM_ = Z.VMMgr.GetVM("action")
end

function Face_gender_windowView:OnActive()
  self:startAnimatedShow()
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background1", false)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background2", false)
  Z.UnrealSceneMgr:SetNodeActiveByName("modelRoot/background3", false)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SetUnrealCameraScreenXY(Vector2.New(0.5, 0.5))
  self:AddClick(self.uiBinder.btn_return, function()
    self:OnInputBack()
  end)
  self.createCount_ = 0
  self.isSelected_ = false
  self.maleModel_ = self:createModel(Z.PbEnum("EGender", "GenderMale"))
  self.femaleModel_ = self:createModel(Z.PbEnum("EGender", "GenderFemale"))
  Z.UITimelineDisplay:ClearTimeLine()
  Z.UITimelineDisplay:AsyncPreLoadTimeline(50000002, self.cancelSource:CreateToken())
  Z.UITimelineDisplay:AsyncPreLoadTimeline(50000003, self.cancelSource:CreateToken())
  Z.UITimelineDisplay:AsyncPreLoadTimeline(50000004, self.cancelSource:CreateToken())
  Z.UITimelineDisplay:BindModel(self.maleModel_)
  Z.UITimelineDisplay:BindModel(self.femaleModel_)
  Z.UITimelineDisplay:Play(50000001)
  self.uiBinder.rimg_left.onClick:AddListener(function(go, pointerData)
    self:selectGender(Z.PbEnum("EGender", "GenderMale"))
    Z.AudioMgr:Play("sfx_player_teleport_end")
  end)
  self.uiBinder.rimg_right.onClick:AddListener(function(go, pointerData)
    self:selectGender(Z.PbEnum("EGender", "GenderFemale"))
    Z.AudioMgr:Play("sfx_player_teleport_end")
  end)
  self.bgEffectUuid_ = Z.UnrealSceneMgr:CreatEffect(EFFECT_PATH_BG, "gender_select_bg")
  Z.UnrealSceneMgr:CreatEffect(EFFECT_PATH_XUSHI, "face_bg_xushi")
end

function Face_gender_windowView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  Z.UITimelineDisplay:ClearTimeLine()
  self.maleModel_ = nil
  self.femaleModel_ = nil
  self.createCount_ = nil
  self.isSelected_ = nil
  self:clearAllEffect()
end

function Face_gender_windowView:onModelLoadFinish()
  self.createCount_ = self.createCount_ + 1
  if self.createCount_ >= 2 then
    local args = {}
    
    function args.EndCallback()
    end
    
    Z.UIMgr:FadeOut(args)
  end
end

function Face_gender_windowView:useCacheFaceData()
  self.isSelected_ = true
  local isMale = self.faceData_.Gender == Z.PbEnum("EGender", "GenderMale")
  local saveModel, clearModel
  if isMale then
    saveModel = self.maleModel_
    clearModel = self.femaleModel_
  else
    saveModel = self.femaleModel_
    clearModel = self.maleModel_
  end
  Z.UITimelineDisplay:ClearTimeLine()
  Z.UnrealSceneMgr:ClearModel(clearModel)
  Z.UnrealSceneMgr:SetCacheModel(self.faceData_.FaceModelName, saveModel)
  self.faceVM_.CloseFaceGenderView()
  self.faceVM_.OpenFaceCreateView(true, true)
end

function Face_gender_windowView:createModel(gender)
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(gender, Z.PbEnum("EBodySize", "BodySizeM"))
  local model = Z.UnrealSceneMgr:GenModelByLua(nil, modelId, function(model)
    model:SetAttrGoPosition(Z.UnrealSceneMgr:GetTransPos("pos"))
    model:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, 180, 0)))
    local equipZList = self.faceVM_.GetDefaultEquipZList(gender)
    model:SetLuaAttr(Z.LocalAttr.EWearEquip, equipZList)
    local actionData = self.faceVM_.GetDefaultActionData()
    self.actionVM_:PlayAction(model, actionData)
    equipZList:Recycle()
  end, nil, function(model)
    self:onModelLoadFinish()
  end)
  return model
end

function Face_gender_windowView:selectGender(gender)
  if self.isSelected_ then
    return
  end
  self.isSelected_ = true
  self.faceData_.Gender = gender
  local isMale = gender == Z.PbEnum("EGender", "GenderMale")
  local saveModel, clearModel
  if isMale then
    saveModel = self.maleModel_
    clearModel = self.femaleModel_
  else
    saveModel = self.femaleModel_
    clearModel = self.maleModel_
  end
  Z.UITimelineDisplay:Stop()
  Z.UnrealSceneMgr:SetModelCustomShadow(self.maleModel_, false)
  Z.UnrealSceneMgr:SetModelCustomShadow(self.femaleModel_, false)
  Z.UnrealSceneMgr:ClearModel(clearModel)
  Z.UnrealSceneMgr:SetCacheModel(self.faceData_.FaceModelName, saveModel)
  self.faceVM_.OpenFaceCreateView(true)
end

function Face_gender_windowView:clearAllEffect()
  if self.bgEffectUuid_ then
    Z.UnrealSceneMgr:ClearEffect(self.bgEffectUuid_)
  end
  self.bgEffectUuid_ = nil
end

function Face_gender_windowView:OnRefresh()
end

function Face_gender_windowView:OnInputBack()
  self.loginVM_:KickOffByClient(E.KickOffClientErrCode.NormalReturn, true)
end

function Face_gender_windowView:startAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Face_gender_windowView
