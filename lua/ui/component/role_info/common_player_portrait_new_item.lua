local CommonPlayerPortraitNewItem = class("CommonPlayerPortraitNewItem")
local DEFINE = require("ui.model.personalzone_define")

function CommonPlayerPortraitNewItem:ctor()
  self.snapshotVm_ = Z.VMMgr.GetVM("snapshot")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
end

function CommonPlayerPortraitNewItem:Init(uiBinder, viewData)
  self.socialData = nil
  self.viewData = viewData
  self.uiBinder = uiBinder
  self.token_ = viewData.token
  if viewData.func then
    self.uiBinder.img_bg:AddListener(Z.CoroUtil.create_coro_xpcall(viewData.func, nil))
  end
end

function CommonPlayerPortraitNewItem:UnInit()
  self.socialData = nil
  self.viewData = nil
  self.uiBinder = nil
end

function CommonPlayerPortraitNewItem:InitSocialData(uiBinder, socialData, func, token)
  self.socialData = socialData
  self.uiBinder = uiBinder
  self.token_ = token
  if func then
    self.uiBinder.img_bg:AddListener(Z.CoroUtil.create_coro_xpcall(func, nil))
  end
  self:Refresh()
end

function CommonPlayerPortraitNewItem:Refresh()
  if self.uiBinder.img_label and self.uiBinder.img_icon then
    if not self.socialData and not self.viewData then
      return
    end
    if self.viewData then
      self:SetHeadFrame(self.viewData.headFrameId)
    end
    if self.socialData then
      if self.socialData and self.socialData.avatarInfo and self.socialData.avatarInfo.avatarId ~= 0 and self.socialData.avatarInfo.avatarId ~= 1 then
        self:SetImgPortrait(self.socialData.avatarInfo.avatarId)
      elseif self.socialData and self.socialData.basicData then
        local socialVm = Z.VMMgr.GetVM("social")
        local modelId = socialVm.GetModelId(self.socialData)
        self:SetModelPortrait(modelId)
      end
      local headFrameId
      if self.socialData.avatarInfo and self.socialData.avatarInfo.avatarFrameId then
        headFrameId = self.socialData.avatarInfo.avatarFrameId
      end
      self:SetHeadFrame(headFrameId)
    end
    if self.viewData and self.viewData.isShowTalentIcon == false then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_label, false)
    else
      local professionId = 0
      if self.socialData and self.socialData.professionData then
        professionId = self.socialData.professionData.professionId
      elseif self.viewData and self.viewData.professionId then
        professionId = self.viewData.professionId
      end
      if professionId and professionId ~= 0 then
        local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
        if professionSystemTableRow then
          self.uiBinder.img_icon:SetImage(professionSystemTableRow.Icon)
          self.uiBinder.img_icon:SetColorByHex(professionSystemTableRow.TalentColor)
          self.uiBinder.Ref:SetVisible(self.uiBinder.img_label, true)
        end
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.img_label, false)
      end
    end
  end
end

function CommonPlayerPortraitNewItem:GetSnapshot(charId, callBackFunc)
  Z.CoroUtil.create_coro_xpcall(function()
    self.snapshotVm_.AsyncGetHttpPortraitId(charId, callBackFunc)
  end, function(err)
    callBackFunc(charId, 0)
  end)()
end

function CommonPlayerPortraitNewItem:GetSnapshotBySocialData(charId, SocialData, callBackFunc)
  Z.CoroUtil.create_coro_xpcall(function()
    self.snapshotVm_.AsyncGetHttpPortraitIdByAvatarInfo(charId, SocialData, callBackFunc)
  end, function(err)
    callBackFunc(charId, 0)
  end)()
end

function CommonPlayerPortraitNewItem:GetLocalHeadPortrait(charId, modelId)
  local path = self.snapshotVm_.GetInternalHeadPortrait(charId, modelId)
  if type(path) == "number" then
    self:SetRimgPortrait(path)
  else
    self:SetModelPortrait(modelId)
  end
end

function CommonPlayerPortraitNewItem:SetModelPortrait(modelId)
  local path = self.snapshotVm_.GetModelHeadPortrait(modelId)
  if not (path ~= nil and self.uiBinder ~= nil and self.token_) or Z.CancelSource.IsCanceled(self.token_) then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_portrait, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_portrait, false)
  self.uiBinder.img_portrait:SetImage(path)
end

function CommonPlayerPortraitNewItem:SetHeadPicture(headPath)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_portrait, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_portrait, false)
  self.uiBinder.img_portrait:SetImage(headPath)
end

function CommonPlayerPortraitNewItem:SetImgPortrait(headId)
  if self.uiBinder == nil or self.token_ == nil then
    return
  end
  if not headId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_portrait, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_portrait, false)
    return
  end
  local path = self.snapshotVm_.GetConfigHeadProtrait(headId)
  if path == nil or self.uiBinder == nil or Z.CancelSource.IsCanceled(self.token_) then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_portrait, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_portrait, false)
  self.uiBinder.img_portrait:SetImage(path)
end

function CommonPlayerPortraitNewItem:SetRimgPortrait(headId)
  if not (self.uiBinder ~= nil and self.token_) or Z.CancelSource.IsCanceled(self.token_) then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_portrait, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_portrait, true)
  self.uiBinder.rimg_portrait:SetNativeTexture(headId)
end

function CommonPlayerPortraitNewItem:SetHeadFrame(headFrameId)
  if not (self.uiBinder ~= nil and self.uiBinder.img_frame and self.token_) or Z.CancelSource.IsCanceled(self.token_) then
    return
  end
  local personalZoneData = Z.DataMgr.Get("personal_zone_data")
  local tempHeadFrameId = personalZoneData:GetDefaultProfileImageConfigByType(DEFINE.ProfileImageType.HeadFrame)
  if headFrameId and headFrameId ~= 0 then
    tempHeadFrameId = headFrameId
  end
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(tempHeadFrameId)
  if config then
    self.uiBinder.img_frame:SetImage(config.Image)
  end
end

return CommonPlayerPortraitNewItem
