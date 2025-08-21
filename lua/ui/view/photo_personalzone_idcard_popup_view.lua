local UI = Z.UI
local super = require("ui.ui_view_base")
local Photo_personalzone_idcard_popupView = class("Photo_personalzone_idcard_popupView", super)
local DEFINE = require("ui.model.personalzone_define")

function Photo_personalzone_idcard_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "photo_personal_idcard_popup")
  self.personalzoneVm_ = Z.VMMgr.GetVM("personal_zone")
end

function Photo_personalzone_idcard_popupView:OnActive()
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.uiBinder.scenemask:SetSceneMaskByKey(Z.UI.ESceneMaskKey.Default)
  self:initUiComp()
  self:initBtn()
  self:bindEvent()
  self:setHeadImg()
  self:initView()
end

function Photo_personalzone_idcard_popupView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Camera.HeadUpLoadSuccess, self.headUpLoadSuccess, self)
end

function Photo_personalzone_idcard_popupView:headUpLoadSuccess()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

function Photo_personalzone_idcard_popupView:initUiComp()
  self.onlineTimes_ = {}
  for i = 1, 3 do
    local index = i
    self.onlineTimes_[i] = {
      icon = self.uiBinder.binder_bg["img_timer_" .. index],
      bg = self.uiBinder.binder_bg["img_timer_bg_" .. index]
    }
  end
  self.personalityLabels_ = {}
  for i = 1, 4 do
    self.personalityLabels_[i] = {
      icon = self.uiBinder.binder_bg["img_personality_labels_" .. i],
      bg = self.uiBinder.binder_bg["img_personality_labels_bg_" .. i]
    }
  end
end

function Photo_personalzone_idcard_popupView:initBtn()
  self:AddClick(self.uiBinder.btn_abandonuploading, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("BusinessCardUploadTips"), function()
      Z.UIMgr:CloseView(self.viewConfigKey)
    end)
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirmupload, function()
    if not self.viewData then
      return
    end
    self.cameraVM_.GetHeadOrBodyPhotoToken(self.viewData.textureId, self.viewData.snapType)
  end)
end

function Photo_personalzone_idcard_popupView:initView()
  local name = Z.ContainerMgr.CharSerialize.charBase.name
  self.uiBinder.binder_bg.lab_name.text = name
  local personalZone = Z.ContainerMgr.CharSerialize.personalZone
  local collectionVM = Z.VMMgr.GetVM("collection")
  self.uiBinder.binder_bg.lab_num.text = collectionVM.GetFashionCollectionPoints()
  self:refreshOnlineTime(personalZone)
  self:refreshPersonalityLabels(personalZone)
  self:showRoleInfo()
end

function Photo_personalzone_idcard_popupView:setHeadImg()
  self.uiBinder.binder_head.rimg_portrait:SetNativeTexture(self.viewData.textureId)
end

function Photo_personalzone_idcard_popupView:refreshOnlineTime(personalzoneInfo)
  if not personalzoneInfo then
    return
  end
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
    self.uiBinder.binder_bg.Ref:SetVisible(v.bg, false)
  end
  if 0 < labCount then
    for k, v in ipairs(self.onlineTimes_) do
      if k <= #onlineDay then
        self.uiBinder.binder_bg.Ref:SetVisible(v.bg, true)
        local config = personalTagMgr.GetRow(onlineDay[k])
        v.icon:SetImage(config.ShowTagRoute)
      end
    end
  elseif self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId then
    self.uiBinder.binder_bg.Ref:SetVisible(self.onlineTimes_[1].bg, true)
    self.onlineTimes_[1].bg.enabled = false
    self.onlineTimes_[1].icon:SetImage(DEFINE.UNSHOWTAGICON)
  end
end

function Photo_personalzone_idcard_popupView:refreshPersonalityLabels(personalzoneInfo)
  if not personalzoneInfo then
    return
  end
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
    self.uiBinder.binder_bg.Ref:SetVisible(v.bg, false)
  end
  if 0 < labCount then
    for k, v in ipairs(self.personalityLabels_) do
      if k <= #tags then
        self.uiBinder.binder_bg.Ref:SetVisible(v.bg, true)
        local config = personalTagMgr.GetRow(tags[k])
        v.icon:SetImage(config.ShowTagRoute)
      end
    end
  elseif self.viewData.charId == Z.EntityMgr.PlayerEnt.EntId then
    self.uiBinder.binder_bg.Ref:SetVisible(self.personalityLabels_[1].bg, true)
    self.personalityLabels_[1].bg.enabled = false
    self.personalityLabels_[1].icon:SetImage(DEFINE.UNSHOWTAGICON)
  end
end

function Photo_personalzone_idcard_popupView:OnRefresh()
end

function Photo_personalzone_idcard_popupView:OnDeActive()
  self:releaseTmpTextures()
end

function Photo_personalzone_idcard_popupView:releaseTmpTextures()
  if self.viewData.textureId and self.viewData.textureId ~= 0 then
    Z.LuaBridge.ReleaseScreenShot(self.viewData.textureId)
    self.viewData.textureId = 0
  end
end

function Photo_personalzone_idcard_popupView:showRoleInfo()
  local personalZone = Z.ContainerMgr.CharSerialize.personalZone
  if personalZone and personalZone.titleId ~= 0 then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(personalZone.titleId)
    if profileImageConfig and profileImageConfig.Unlock ~= DEFINE.ProfileImageUnlockType.DefaultUnlock then
      self.uiBinder.lab_title.text = string.format("%s\239\188\154%s", Lang("PersonalzoneTitle"), profileImageConfig.Name)
    else
      self.uiBinder.lab_title.text = string.format("%s\239\188\154%s", Lang("PersonalzoneTitle"), Lang("None"))
    end
  else
    self.uiBinder.lab_title.text = string.format("%s\239\188\154%s", Lang("PersonalzoneTitle"), Lang("None"))
  end
  local seasonData = Z.DataMgr.Get("season_title_data")
  local seasonTitleId = seasonData:GetCurRankInfo().curRanKStar
  if seasonTitleId and seasonTitleId ~= 0 then
    local seasonRankConfig = Z.TableMgr.GetTable("SeasonRankTableMgr").GetRow(seasonTitleId)
    if seasonRankConfig then
      self.uiBinder.img_armband_icon:SetImage(seasonRankConfig.IconBig)
    end
  end
end

return Photo_personalzone_idcard_popupView
