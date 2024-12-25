local CommonPlayerPortraitItem = class("CommonPlayerPortraitItem")
local HeroHelper = require("ui.component.hero_helper")
local DEFINE = require("ui.model.personalzone_define")

function CommonPlayerPortraitItem:ctor()
  self.snapshotVm_ = Z.VMMgr.GetVM("snapshot")
end

function CommonPlayerPortraitItem:Init(unit, viewData)
  self.viewData = viewData
  self.unit = unit
  if viewData.func then
    self.btn = self.unit.img_bg.Btn
    self.btn.AddListener(self.btn, Z.CoroUtil.create_coro_xpcall(viewData.func, nil))
  end
end

function CommonPlayerPortraitItem:InitSocialData(unit, socialData, func)
  self.socialData_ = socialData
  self.unit = unit
  if func then
    self.btn = self.unit.img_bg.Btn
    self.btn.AddListener(self.btn, Z.CoroUtil.create_coro_xpcall(func, nil))
  end
  self:Refresh()
end

function CommonPlayerPortraitItem:getProfessionIcon(professionId)
  return HeroHelper.GetProfessionNewIconGray(professionId)
end

function CommonPlayerPortraitItem:Refresh()
  if self.unit.img_label and self.unit.img_icon then
    if not self.socialData_ and not self.viewData then
      return
    end
    self.unit.img_frame:SetVisible(true)
    local personalZoneData = Z.DataMgr.Get("personal_zone_data")
    local headFrameId = personalZoneData:GetDefaultProfileImageConfigByType(DEFINE.ProfileImageType.HeadFrame)
    if self.viewData.headFrameId and self.viewData.headFrameId ~= 0 then
      headFrameId = self.viewData.headFrameId
    end
    local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(headFrameId)
    if config then
      self.unit.img_frame.Img:SetImage(config.Image)
    end
    if self.viewData and self.viewData.isShowTalentIcon == false then
      self.unit.img_label:SetVisible(false)
    else
      local professionId = 0
      if self.socialData_ and self.socialData_.professionData then
        professionId = self.socialData_.professionData.professionId
      elseif self.viewData and self.viewData.professionId then
        professionId = self.viewData.professionId
      end
      if professionId and professionId ~= 0 then
        local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
        if professionSystemTableRow then
          self.unit.img_icon.Img:SetImage(professionSystemTableRow.Icon)
          self.unit.img_label:SetVisible(true)
        else
          self.unit.img_label:SetVisible(false)
        end
      else
        self.unit.img_label:SetVisible(false)
      end
    end
  end
end

function CommonPlayerPortraitItem:GetSnapshot(charId, callBackFunc)
  Z.CoroUtil.create_coro_xpcall(function()
    self.snapshotVm_.AsyncGetHttpPortraitId(charId, callBackFunc)
  end, function(err)
    callBackFunc(charId, 0)
  end)()
end

function CommonPlayerPortraitItem:GetSnapshotBySocialData(charId, SocialData, callBackFunc)
  Z.CoroUtil.create_coro_xpcall(function()
    self.snapshotVm_.AsyncGetHttpPortraitIdByAvatarInfo(charId, SocialData, callBackFunc)
  end, function(err)
    callBackFunc(charId, 0)
  end)()
end

function CommonPlayerPortraitItem:SetModelPortrait(modelId)
  local path = self.snapshotVm_.GetModelHeadPortrait(modelId)
  if path == nil or self.unit == nil then
    return
  end
  self.unit.img_portrait:SetVisible(true)
  self.unit.rimg_portrait:SetVisible(false)
  self.unit.img_portrait.Img:SetImage(path)
end

function CommonPlayerPortraitItem:SetImgPortrait(headId)
  if not headId then
    self.unit.img_portrait:SetVisible(false)
    self.unit.rimg_portrait:SetVisible(false)
    return
  end
  local path = self.snapshotVm_.GetConfigHeadProtrait(headId)
  if path == nil or self.unit == nil then
    return
  end
  self.unit.img_portrait:SetVisible(true)
  self.unit.rimg_portrait:SetVisible(false)
  self.unit.img_portrait.Img:SetImage(path)
end

function CommonPlayerPortraitItem:GetLocalHeadPortrait(charId, modelId)
  local path = self.snapshotVm_.GetInternalHeadPortrait(charId, modelId)
  if type(path) == "number" then
    self:SetRimgPortrait(path)
  else
    self:SetModelPortrait(modelId)
  end
end

function CommonPlayerPortraitItem:SetRimgPortrait(headId)
  if self.unit == nil then
    return
  end
  self.unit.img_portrait:SetVisible(false)
  self.unit.rimg_portrait:SetVisible(true)
  self.unit.rimg_portrait.RImg:SetNativeTexture(headId)
end

function CommonPlayerPortraitItem:UnInit()
end

return CommonPlayerPortraitItem
