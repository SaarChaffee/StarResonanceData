local UI = Z.UI
local super = require("ui.ui_view_base")
local Personalzone_mainView = class("Personalzone_mainView", super)
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local DEFINE = require("ui.model.personalzone_define")
local timelineQueue = {
  [Z.PbEnum("EGender", "GenderMale")] = 50000026,
  [Z.PbEnum("EGender", "GenderFemale")] = 50000020
}

function Personalzone_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "personalzone_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
  self.personalzoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.actionVM_ = Z.VMMgr.GetVM("action")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.playerModel_ = nil
  self.medalModels_ = {}
  self.initUILabPos_ = {}
end

function Personalzone_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SwitchGroupReflection(false)
  self.timeLineIndex_ = 0
  self.isOpen_ = true
  self:initUIEvents()
  self:initUIComp()
  self:showRoleInfo()
  self:refreshCardBg()
  self:onChangeOnlienTags(self.viewData.personalzone)
  self:showModel()
  self:showMedal()
  self:showPhoto()
  self:refreshotherBtn()
  self:binderEvents()
  self:binderRedDot()
  self.personalzoneData_:SetCurPreviewPersonalZoneData(self.viewData)
  if self.viewData and self.viewData.personalzone then
    self.uiBinder.lab_num.text = self.viewData.personalzone.fashionCollectPoint
  else
    self.uiBinder.lab_num.text = "0"
  end
  if self.initUILabPos_[1] then
    self.uiBinder.lab_photoalbum:SetAnchorPosition(self.initUILabPos_[1].photoX, self.initUILabPos_[1].photoY)
    self.uiBinder.lab_redact:SetAnchorPosition(self.initUILabPos_[1].medalX, self.initUILabPos_[1].medalY)
  else
    self.timerMgr:StartFrameTimer(function()
      local x1, y1 = Z.UnrealSceneMgr:GetGOScreenPos("photoui", self.uiBinder.node_btn_main)
      self.uiBinder.lab_photoalbum:SetAnchorPosition(x1, y1)
      local x2, y2 = Z.UnrealSceneMgr:GetGOScreenPos("medalui", self.uiBinder.node_btn_main)
      self.uiBinder.lab_redact:SetAnchorPosition(x2, y2)
      self.initUILabPos_[1] = {
        photoX = x1,
        photoY = y1,
        medalX = x2,
        medalY = y2
      }
    end, 2, 1)
  end
end

function Personalzone_mainView:OnDeActive()
  PlayerPortraitHgr.ClearActiveItem(self.portraitUnit_)
  self.timeLineIndex_ = 0
  self.isOpen_ = false
  Z.UITimelineDisplay:ClearTimeLine()
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
  Z.UIMgr:CloseView("wardrobe_collection_tips")
  self.personalzoneData_:SetCurPreviewPersonalZoneData(nil)
  self:clearMedalModels()
  self:releasePhotoTexture()
  Z.UnrealSceneMgr:ClearBlock()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unbinderEvents()
  self:unbinderRedDot()
end

function Personalzone_mainView:OnRefresh()
end

function Personalzone_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("personalzone_main")
end

function Personalzone_mainView:GetCacheData()
  local viewData = {}
  local charBase = Z.ContainerMgr.CharSerialize.charBase
  viewData.charId = Z.EntityMgr.PlayerEnt.EntId
  viewData.name = charBase.name
  viewData.gender = charBase.gender
  viewData.personalzone = Z.ContainerMgr.CharSerialize.personalZone
  viewData.id = self.personalzoneVm_.GetCurProfileImageId(DEFINE.ProfileImageType.Head)
  viewData.modelId = Z.ModelManager:GetModelIdByGenderAndSize(charBase.gender, Z.ContainerMgr.CharSerialize.charBase.bodySize)
  viewData.headFrameId = self.personalzoneVm_.GetCurProfileImageId(DEFINE.ProfileImageType.HeadFrame)
  return viewData
end

function Personalzone_mainView:OnInputBack()
  Z.UIMgr:CloseView(self.ViewConfigKey)
end

function Personalzone_mainView:initUIEvents()
  Z.UnrealSceneMgr:AddVirtEntityListener("photoTouch", function()
    self.personalzoneVm_.OpenFunctionById(E.FunctionID.PersonalzonePhoto)
  end)
  Z.UnrealSceneMgr:AddVirtEntityListener("medalTouch", function()
    self.personalzoneVm_.OpenFunctionById(E.FunctionID.PersonalzoneMedal)
  end)
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_name_redact, function()
    local playerVM = Z.VMMgr.GetVM("player")
    playerVM:OpenRenameWindow()
  end)
  self:AddAsyncClick(self.uiBinder.btn_share, function()
    self:sharePersonalZone()
  end)
  self:AddAsyncClick(self.uiBinder.btn_lab, function()
    if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.EntId then
      return
    end
    self.personalzoneVm_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneTitle)
  end)
  self:AddClick(self.uiBinder.btn_editor_tag, function()
    if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.EntId then
      local unionTagTableMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
      local onlineDay = {}
      if self.viewData.personalzone and self.viewData.personalzone.onlinePeriods then
        onlineDay = self.viewData.personalzone.onlinePeriods
      end
      local tags = {}
      if self.viewData.personalzone and self.viewData.personalzone.tags then
        tags = self.viewData.personalzone.tags
      end
      local temp = {}
      local tempindex = 0
      for _, v in ipairs(onlineDay) do
        tempindex = tempindex + 1
        temp[tempindex] = unionTagTableMgr.GetRow(v)
      end
      for _, v in ipairs(tags) do
        tempindex = tempindex + 1
        temp[tempindex] = unionTagTableMgr.GetRow(v)
      end
      if 0 < tempindex then
        local viewData = {
          tagList = temp,
          trans = self.uiBinder.rect_editor_tag,
          type = 2
        }
        self.unionVM_:OpenLabelTipsView(viewData)
      end
    else
      Z.UIMgr:OpenView("personalzone_label_popup")
    end
  end)
  self:AddClick(self.uiBinder.btn_collect, function()
    local WardrobeData = {}
    WardrobeData.parent = self.uiBinder.node_collect
    WardrobeData.personalZone = self.viewData.personalzone
    Z.UIMgr:OpenView("wardrobe_collection_tips", WardrobeData)
  end)
  self:AddClick(self.uiBinder.uibinder_head.btn_bg, function()
    if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.EntId then
      return
    end
    self.personalzoneVm_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneCard)
  end)
  self:AddAsyncClick(self.uiBinder.btn_sent_message, function()
    if not self.socialVm_.CheckCanSwitch(E.IdCardFuncId.SendMsg, false) then
      return
    end
    Z.VMMgr.GetVM("friends_main").OpenPrivateChat(self.viewData.charId)
  end)
  self:AddAsyncClick(self.uiBinder.btn_add_friend, function()
    if not self.socialVm_.CheckCanSwitch(E.IdCardFuncId.AddFriend, false) then
      return
    end
    Z.VMMgr.GetVM("friends_main").AsyncSendAddFriend(self.viewData.charId, E.FriendAddSource.EPersonalzone, self.cancelSource:CreateToken())
  end)
end

function Personalzone_mainView:initUIComp()
  self.onlineTimes_ = {}
  for i = 1, 3 do
    local index = i
    self.onlineTimes_[i] = {
      icon = self.uiBinder["img_timer_" .. index],
      bg = self.uiBinder["img_timer_bg_" .. index]
    }
  end
  self.personalityLabels_ = {}
  for i = 1, 4 do
    self.personalityLabels_[i] = {
      icon = self.uiBinder["img_personality_labels_" .. i],
      bg = self.uiBinder["img_personality_labels_bg_" .. i]
    }
  end
end

function Personalzone_mainView:binderEvents()
  Z.EventMgr:Add(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnTagsRefresh, self.onChangeOnlienTags, self)
  Z.EventMgr:Add(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnCardRefresh, self.refreshCardBg, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnSaveMedalEdit, self.showMedal, self)
  Z.EventMgr:Add(Z.ConstValue.PersonalZone.OnUnrealScenePhotoRefresh, self.showPhoto, self)
end

function Personalzone_mainView:unbinderEvents()
  Z.EventMgr:Remove(Z.ConstValue.Player.ChangeNameResultNtf, self.onChangeNameResultNtf, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnTagsRefresh, self.onChangeOnlienTags, self)
  Z.EventMgr:Remove(Z.ConstValue.ChangeRoleAvatar, self.onChangePortrait, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnTitleRefresh, self.onChangeTitle, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnCardRefresh, self.refreshCardBg, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnSaveMedalEdit, self.showMedal, self)
  Z.EventMgr:Remove(Z.ConstValue.PersonalZone.OnUnrealScenePhotoRefresh, self.showPhoto, self)
end

function Personalzone_mainView:binderRedDot()
  if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.EntId then
    return
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHead, self, self.uiBinder.com_head_item.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneHeadFrame, self, self.uiBinder.com_head_item.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneMedal, self, self.uiBinder.node_redact_red)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneCard, self, self.uiBinder.uibinder_head.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.PersonalzoneTitle, self, self.uiBinder.rect_lab)
end

function Personalzone_mainView:unbinderRedDot()
  if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.EntId then
    return
  end
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHead)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneHeadFrame)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneMedal)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneCard)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.PersonalzoneTitle)
end

function Personalzone_mainView:showModel()
  if self.playerModel_ then
    Z.UnrealSceneMgr:ClearModel(self.playerModel_)
    self.playerModel_ = nil
  end
  self.modelPos_ = Z.UnrealSceneMgr:GetTransPos("pos")
  self.modelQuaternion_ = Quaternion.Euler(Vector3.New(0, 165, 0))
  Z.CoroUtil.create_coro_xpcall(function()
    local socialVM = Z.VMMgr.GetVM("social")
    local mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeBase, 0)
    mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeFace, mask)
    mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeEquip, mask)
    mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeFashion, mask)
    mask = socialVM.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeSetting, mask)
    local socialData = socialVM.AsyncGetSocialData(mask, self.viewData.charId, self.cancelSource:CreateToken())
    Z.UITimelineDisplay:ClearTimeLine()
    self.timelineId_ = timelineQueue[socialData.basicData.gender]
    local async = Z.CoroUtil.async_to_sync(Z.UITimelineDisplay.AsyncPreLoadTimeline)
    async(Z.UITimelineDisplay, self.timelineId_, self.cancelSource:CreateToken())
    self.playerModel_ = Z.UnrealSceneMgr:GenModelByLuaSocialData(socialData)
    self.playerModel_:SetAttrGoPosition(self.modelPos_)
    self.playerModel_:SetAttrGoRotation(self.modelQuaternion_)
    self.playerModel_:SetLuaAttr(Z.ModelAttr.EModelSampleShadowBool, false)
    Z.UITimelineDisplay:BindModel(0, self.playerModel_)
    Z.UITimelineDisplay:SetGoPosByCutsceneId(self.timelineId_, self.modelPos_)
    Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(self.timelineId_, self.modelQuaternion_.x, self.modelQuaternion_.y, self.modelQuaternion_.z, self.modelQuaternion_.w)
    Z.UITimelineDisplay:Play(self.timelineId_)
  end)()
end

function Personalzone_mainView:showRoleInfo()
  local isSelf = self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_name_redact, isSelf)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_redact, isSelf)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_share, isSelf)
  self.uiBinder.lab_name.text = self.viewData.name
  if self.viewData and self.viewData.personalzone and self.viewData.personalzone.titleId ~= 0 then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.viewData.personalzone.titleId)
    if profileImageConfig and profileImageConfig.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
      self.uiBinder.lab_title.text = string.format("%s", profileImageConfig.Name)
    else
      self.uiBinder.lab_title.text = Lang("NoneTitle")
    end
  else
    self.uiBinder.lab_title.text = Lang("NoneTitle")
  end
  
  function self.viewData.func()
    if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.EntId then
      return
    end
    self.personalzoneVm_.OpenPersonalzoneRecordMain(E.FunctionID.PersonalzoneHead)
  end
  
  self.portraitUnit_ = PlayerPortraitHgr.InsertNewPortrait(self.uiBinder.com_head_item, self.viewData)
  local seasonData = Z.DataMgr.Get("season_title_data")
  local seasonTitleId = seasonData:GetCurRankInfo().curRanKStar
  if seasonTitleId and seasonTitleId ~= 0 then
    local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(seasonTitleId)
    if seasonRankConfig then
      self.uiBinder.img_armband_icon:SetImage(seasonRankConfig.IconBig)
    end
  end
end

function Personalzone_mainView:refreshotherBtn()
  local friendMainData = Z.DataMgr.Get("friend_main_data")
  local chatMainData = Z.DataMgr.Get("chat_main_data")
  local isInBlackList = chatMainData:IsInBlack(self.viewData.charId) or self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId
  local isFriend = friendMainData:IsFriendByCharId(self.viewData.charId) or self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add_friend, not isFriend)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_sent_message, not isInBlackList)
end

function Personalzone_mainView:onChangeNameResultNtf(errCode)
  if errCode == 0 and self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId then
    self.uiBinder.lab_name.text = Z.ContainerMgr.CharSerialize.charBase.name
  end
end

function Personalzone_mainView:refreshCardBg()
  local isSelf = self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId
  local cardBgId
  if isSelf then
    cardBgId = self.personalzoneVm_.GetCurProfileImageId(DEFINE.ProfileImageType.Card)
  else
    cardBgId = self.personalzoneData_:GetDefaultProfileImageConfigByType(DEFINE.ProfileImageType.Card)
    if self.viewData and self.viewData.personalzone and self.viewData.personalzone.businessCardStyleId then
      cardBgId = self.viewData.personalzone.businessCardStyleId
    end
  end
  self.personalzoneVm_.IDCardHelperBase(self.uiBinder.uibinder_head, cardBgId)
end

function Personalzone_mainView:onChangeOnlienTags(personalzoneInfo)
  self:refreshOnlineTime(personalzoneInfo)
  self:refreshPersonalityLabels(personalzoneInfo)
end

function Personalzone_mainView:onChangePortrait(avatarId, frameId)
  local viewData = {
    id = avatarId,
    modelId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value,
    charId = Z.EntityMgr.PlayerEnt.EntId,
    headFrameId = frameId
  }
  PlayerPortraitHgr.RefreshNewProtrait(self.uiBinder.com_head_item, viewData, self.portraitUnit_)
end

function Personalzone_mainView:onChangeTitle()
  if self.viewData.charId ~= Z.EntityMgr.PlayerEnt.EntId then
    return
  end
  local titleId = self.personalzoneVm_.GetCurProfileImageId(DEFINE.ProfileImageType.Title)
  if titleId and titleId ~= 0 then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(titleId)
    if profileImageConfig and profileImageConfig.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
      self.uiBinder.lab_title.text = string.format("%s\239\188\154%s", Lang("PersonalzoneTitle"), profileImageConfig.Name)
    else
      self.uiBinder.lab_title.text = string.format("%s\239\188\154%s", Lang("PersonalzoneTitle"), Lang("None"))
    end
  else
    self.uiBinder.lab_title.text = string.format("%s\239\188\154%s", Lang("PersonalzoneTitle"), Lang("None"))
  end
end

function Personalzone_mainView:refreshOnlineTime(personalzoneInfo)
  local onlineDay = {}
  if personalzoneInfo and personalzoneInfo.onlinePeriods then
    onlineDay = personalzoneInfo.onlinePeriods
  end
  local personalTagMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
  table.sort(onlineDay, function(a, b)
    local aConfig = personalTagMgr.GetRow(a)
    local bConfig = personalTagMgr.GetRow(b)
    if aConfig.ShowSort == bConfig.ShowSort then
      return aConfig.Id < bConfig.Id
    else
      return aConfig.ShowSort < bConfig.ShowSort
    end
  end)
  self.onlineTimes_[1].bg.enabled = true
  local labCount = #onlineDay
  for _, v in ipairs(self.onlineTimes_) do
    self.uiBinder.Ref:SetVisible(v.bg, false)
  end
  if 0 < labCount then
    for k, v in ipairs(self.onlineTimes_) do
      if k <= #onlineDay then
        self.uiBinder.Ref:SetVisible(v.bg, true)
        local config = personalTagMgr.GetRow(onlineDay[k])
        v.icon:SetImage(config.ShowTagRoute)
      end
    end
  elseif self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId then
    self.uiBinder.Ref:SetVisible(self.onlineTimes_[1].bg, true)
    self.onlineTimes_[1].bg.enabled = false
    self.onlineTimes_[1].icon:SetImage(DEFINE.UNSHOWTAGICON)
  end
end

function Personalzone_mainView:refreshPersonalityLabels(personalzoneInfo)
  local tags = {}
  if personalzoneInfo and personalzoneInfo.tags then
    tags = personalzoneInfo.tags
  end
  local personalTagMgr = Z.TableMgr.GetTable("UnionTagTableMgr")
  table.sort(tags, function(a, b)
    local aConfig = personalTagMgr.GetRow(a)
    local bConfig = personalTagMgr.GetRow(b)
    if aConfig.ShowSort == bConfig.ShowSort then
      return aConfig.Id < bConfig.Id
    else
      return aConfig.ShowSort < bConfig.ShowSort
    end
  end)
  self.personalityLabels_[1].bg.enabled = true
  local labCount = #tags
  for _, v in ipairs(self.personalityLabels_) do
    self.uiBinder.Ref:SetVisible(v.bg, false)
  end
  if 0 < labCount then
    for k, v in ipairs(self.personalityLabels_) do
      if k <= #tags then
        self.uiBinder.Ref:SetVisible(v.bg, true)
        local config = personalTagMgr.GetRow(tags[k])
        v.icon:SetImage(config.ShowTagRoute)
      end
    end
  elseif self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId then
    self.uiBinder.Ref:SetVisible(self.personalityLabels_[1].bg, true)
    self.personalityLabels_[1].bg.enabled = false
    self.personalityLabels_[1].icon:SetImage(DEFINE.UNSHOWTAGICON)
  end
end

function Personalzone_mainView:showMedal()
  self:clearMedalModels()
  if self.viewData and self.viewData.personalzone and self.viewData.personalzone.medals then
    Z.CoroUtil.create_coro_xpcall(function()
      local medalTableMgr = Z.TableMgr.GetTable("MedalTableMgr")
      local parentTran = Z.UnrealSceneMgr:GetGOByBinderName("medalparent").transform
      local medals = self.viewData.personalzone.medals
      for pos, id in pairs(medals) do
        if id ~= 0 then
          local config = medalTableMgr.GetRow(id)
          if config then
            local x = (pos - 1) % DEFINE.PersonalzoneMedalGridWidthCount
            local y = math.floor((pos - 1) / DEFINE.PersonalzoneMedalGridWidthCount)
            local xPos = DEFINE.PersonalzoneMedal3DArea[1][1] - x * DEFINE.PersonalzoneMedal3DGridSize - DEFINE.PersonalzoneMedalUnitSize[config.Type][1] / 2 * DEFINE.PersonalzoneMedal3DGridSize
            local yPos = DEFINE.PersonalzoneMedal3DArea[1][2] - y * DEFINE.PersonalzoneMedal3DGridSize - DEFINE.PersonalzoneMedalUnitSize[config.Type][2] / 2 * DEFINE.PersonalzoneMedal3DGridSize
            local go = Z.UnrealSceneMgr:LoadScenePrefab(Z.Global.MedalModel[config.Type][2], parentTran, Vector3.New(xPos, yPos, 0), self.cancelSource:CreateToken())
            Z.UnrealSceneMgr:ChangeLoadPrefabRotation(go, 0, 0, 0)
            Z.UnrealSceneMgr:ChangeLoadPrefabTexture(go, 0, "_Tex0_d", config.Tex, self.cancelSource:CreateToken())
            table.insert(self.medalModels_, go)
          end
        end
      end
    end)()
  end
end

function Personalzone_mainView:clearMedalModels()
  for _, v in ipairs(self.medalModels_) do
    Z.UnrealSceneMgr:ClearLoadPrefab(v)
  end
  self.medalModels_ = {}
end

function Personalzone_mainView:showPhoto()
  self:releasePhotoTexture()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.viewData and self.viewData.personalzone and self.viewData.personalzone.photos and self.viewData.personalzone.photos[1] and self.viewData.personalzone.photos[1] ~= 0 then
      local albumMainVm = Z.VMMgr.GetVM("album_main")
      local ret = albumMainVm.GetPhoto(self.viewData.charId, self.viewData.personalzone.photos[1], self.cancelSource:CreateToken())
      if ret.errCode and ret.errCode ~= 0 then
        return
      end
      local url = ""
      for _, photoValue in pairs(ret.photoGraph.images) do
        if photoValue.type == E.PictureType.ECameraRender then
          url = photoValue.cosUrl
        end
      end
      albumMainVm.AsyncGetHttpAlbumPhoto(url, E.PictureType.ECameraRender, E.NativeTextureCallToken.Personalzone_main_view, function(obj, photoId)
        self.photoTextureId = photoId
        Z.UnrealSceneMgr:ChangeBinderGOTextureById("photo", 1, "_EmissionMap", self.photoTextureId)
      end, self)
    end
  end)()
end

function Personalzone_mainView:releasePhotoTexture()
  if self.photoTextureId and self.photoTextureId ~= 0 then
    Z.UnrealSceneMgr:ChangeBinderGOTextureById("photo", 1, "_EmissionMap", -1)
    Z.UnrealSceneMgr:ReleaseBinderGOTextureById(self.photoTextureId)
  end
  self.photoTextureId = nil
end

function Personalzone_mainView:sharePersonalZone()
  local chatData_ = Z.DataMgr.Get("chat_main_data")
  chatData_:RefreshShareData("", nil, E.ChatHyperLinkType.PersonalZone)
  local draftData = {}
  draftData.msg = chatData_:GetHyperLinkShareContent()
  chatData_:SetChatDraft(draftData, E.ChatChannelType.EChannelWorld, E.ChatWindow.Main)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(E.FunctionID.MainChat)
end

return Personalzone_mainView
