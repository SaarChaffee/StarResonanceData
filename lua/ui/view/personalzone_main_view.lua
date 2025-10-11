local UI = Z.UI
local super = require("ui.ui_view_base")
local Personalzone_mainView = class("Personalzone_mainView", super)
local PersonalZoneDefine = require("ui.model.personalzone_define")
local timelineQueue = {
  [Z.PbEnum("EGender", "GenderMale")] = 50000026,
  [Z.PbEnum("EGender", "GenderFemale")] = 50000020
}
local modelQuaternion = Quaternion.Euler(Vector3.New(0, 126, 0))

function Personalzone_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "personalzone_main")
  self.rightGroupSubView_ = require("ui/view/personalzone_idcard_sub_view").new(self)
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.viewData = nil
  self.referenceHeight = Z.TableMgr.GetTable("ModelTableMgr").GetRow(100002).GoData[1]
end

function Personalzone_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SwitchGroupReflection(true)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(2087)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  local functionConfig = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.Personalzone)
  if functionConfig then
    self.uiBinder.lab_title.text = functionConfig.Name
  end
  local collectionVM = Z.VMMgr.GetVM("collection")
  local viewData
  if self.viewData and self.viewData.charId ~= Z.EntityMgr.PlayerEnt.CharId then
    local seasonData = Z.DataMgr.Get("season_data")
    viewData = {
      editorType = PersonalZoneDefine.IdCardEditorType.None,
      charId = self.viewData.charId,
      onlinePeriods = self.viewData.personalZone ~= nil and self.viewData.personalZone.onlinePeriods or {},
      tags = self.viewData.personalZone ~= nil and self.viewData.personalZone.tags or {},
      name = self.viewData.basicData.name,
      avatarId = self.viewData.avatarInfo.avatarId,
      avatarFrameId = self.viewData.avatarInfo and self.viewData.avatarInfo.avatarFrameId or nil,
      modelId = self.socialVm_.GetModelId(self.viewData),
      seasonTitleId = self.viewData.seasonRank == nil and 0 or self.viewData.seasonRank[seasonData.CurSeasonId],
      titleId = self.viewData.personalZone ~= nil and self.viewData.personalZone.titleId or 0,
      fashionCollectPoint = collectionVM.GetFashionCollectionPoints(self.viewData),
      photos = self.viewData.personalZone ~= nil and self.viewData.personalZone.photosWall or {},
      medals = self.viewData.personalZone ~= nil and self.viewData.personalZone.medals or {},
      subFuncs = {
        [1] = E.FunctionID.PersonalzoneMedal,
        [2] = E.FunctionID.PersonalzonePhoto
      },
      bg = self.viewData.personalZone ~= nil and self.viewData.personalZone.themeId or 0,
      isNewbie = Z.VMMgr.GetVM("player"):IsShowNewbie(self.viewData.basicData.isNewbie),
      masterModeDungeonData = self.viewData.masterModeDungeonData ~= nil and {
        isShow = self.viewData.masterModeDungeonData.isShow,
        score = self.viewData.masterModeDungeonData.seasonScore
      } or nil
    }
  else
    local charSerialize = Z.ContainerMgr.CharSerialize
    local seasonData = Z.DataMgr.Get("season_title_data")
    local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
    viewData = {
      editorType = PersonalZoneDefine.IdCardEditorType.None,
      charId = charSerialize.charBase.charId,
      onlinePeriods = charSerialize.personalZone ~= nil and charSerialize.personalZone.onlinePeriods or {},
      tags = charSerialize.personalZone ~= nil and charSerialize.personalZone.tags or {},
      name = charSerialize.charBase.name,
      avatarId = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.Head),
      avatarFrameId = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.HeadFrame),
      modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value,
      seasonTitleId = seasonData:GetCurRankInfo().curRanKStar,
      titleId = charSerialize.personalZone ~= nil and charSerialize.personalZone.titleId or 0,
      fashionCollectPoint = collectionVM.GetFashionCollectionPoints(),
      photos = charSerialize.personalZone ~= nil and charSerialize.personalZone.photosWall or {},
      medals = charSerialize.personalZone ~= nil and charSerialize.personalZone.medals or {},
      subFuncs = {
        [1] = E.FunctionID.PersonalzoneMedal,
        [2] = E.FunctionID.PersonalzonePhoto
      },
      bg = self.personalzoneVm_.GetCurProfileImageId(PersonalZoneDefine.ProfileImageType.PersonalzoneBg),
      isNewbie = Z.VMMgr.GetVM("player"):IsShowNewbie(Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrIsNewbie")).Value),
      masterModeDungeonData = {
        isShow = charSerialize.masterModeDungeonInfo.isShow,
        score = Z.VMMgr.GetVM("hero_dungeon_main").GetPlayerSeasonMasterDungeonScore(seasonId)
      }
    }
  end
  self.rightGroupSubView_:Active(viewData, self.uiBinder.node_sub)
  self:showModel()
  Z.CoroUtil.create_coro_xpcall(function()
    local id = viewData.bg == 0 and self.personalZoneData_:GetDefaultProfileImageConfigByType(PersonalZoneDefine.ProfileImageType.PersonalzoneBg) or viewData.bg
    local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(id)
    if config then
      Z.UnrealSceneMgr:ChangeBinderGOTexture("sky", 0, "_MainTex", config.Image2, self.cancelSource:CreateToken())
    end
  end)()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Personalzone_mainView:OnDeActive()
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
  Z.UITimelineDisplay:ClearTimeLine()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.rightGroupSubView_:DeActive()
end

function Personalzone_mainView:OnRefresh()
end

function Personalzone_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.viewConfigKey)
end

function Personalzone_mainView:showModel()
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local socialVM = Z.VMMgr.GetVM("social")
    local mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeBase, 0)
    mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeFace, mask)
    mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeEquip, mask)
    mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeFashion, mask)
    mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeSetting, mask)
    local socialData
    if self.viewData then
      socialData = socialVM.AsyncGetSocialData(mask, self.viewData.charId, self.cancelSource:CreateToken())
    else
      socialData = socialVM.AsyncGetSocialData(mask, Z.ContainerMgr.CharSerialize.charBase.charId, self.cancelSource:CreateToken())
    end
    Z.UITimelineDisplay:ClearTimeLine()
    self.timelineId_ = timelineQueue[socialData.basicData.gender]
    local async = Z.CoroUtil.async_to_sync(Z.UITimelineDisplay.AsyncPreLoadTimeline)
    async(Z.UITimelineDisplay, self.timelineId_, self.cancelSource:CreateToken())
    self.playerModel_ = Z.UnrealSceneMgr:GenModelByLuaSocialData(socialData)
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
    self:calcModelPos(socialData.faceData.height)
    self.playerModel_:SetAttrGoPosition(self.modelPos_)
    self.playerModel_:SetAttrGoRotation(modelQuaternion)
    self.playerModel_:SetLuaAttr(Z.ModelAttr.EModelSampleShadowBool, false)
    Z.UITimelineDisplay:BindModel(0, self.playerModel_)
    Z.UITimelineDisplay:SetGoPosByCutsceneId(self.timelineId_, self.modelPos_)
    Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.timelineId_, modelQuaternion.x, modelQuaternion.y, modelQuaternion.z, modelQuaternion.w)
    Z.UITimelineDisplay:Play(self.timelineId_)
  end)()
end

function Personalzone_mainView:calcModelPos(height)
  local pos = Z.UnrealSceneMgr:GetTransPos("pos")
  local screenToWroldPosition = Z.UIRoot.UICam:WorldToScreenPoint(self.uiBinder.model_node.position)
  local wolrdPos = Vector3.New(screenToWroldPosition.x, screenToWroldPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, pos))
  local modelPos = Z.CameraMgr.MainCamera:ScreenToWorldPoint(wolrdPos)
  self.modelPos_ = Vector3.New(modelPos.x, modelPos.y - height * 2 / 3, modelPos.z)
end

return Personalzone_mainView
