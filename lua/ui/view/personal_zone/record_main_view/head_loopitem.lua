local super = require("ui.component.loop_grid_view_item")
local PersonalZoneHead = class("PersonalZoneHead", super)
local DEFINE = require("ui.model.personalzone_define")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function PersonalZoneHead:ctor()
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
  self.charId_ = Z.ContainerMgr.CharSerialize.charId
  self.modelId_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
end

function PersonalZoneHead:OnInit()
  self.currentSelect_ = 0
  self.view_ = self.parent.UIView
  self.uiBinder.img_bg:AddListener(function()
    self.view_:SetSelect(self.data_.config.Id)
  end)
end

function PersonalZoneHead:OnUnInit()
end

function PersonalZoneHead:OnRefresh(data)
  self.data_ = data
  if self.data_.config.Type == DEFINE.ProfileImageType.Head then
    local id = self.personalZoneData_:GetDefaultProfileImageConfigByType(DEFINE.ProfileImageType.Head)
    if Z.ContainerMgr.CharSerialize.charBase and Z.ContainerMgr.CharSerialize.charBase.avatarInfo and Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarId then
      id = Z.ContainerMgr.CharSerialize.charBase.avatarInfo.avatarId
    end
    if self.data_.isAuditing then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_portrait, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_portrait, true)
      self.uiBinder.rimg_portrait:SetNativeTexture(self.data_.textureId)
    else
      local viewData = {}
      viewData.id = self.data_.config.Id
      viewData.modelId = self.modelId_
      viewData.isShowCombinationIcon = false
      viewData.isShowTalentIcon = false
      viewData.charId = self.charId_
      PlayerPortraitHgr.InsertNewPortrait(self.uiBinder, viewData)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_audit_mask, self.data_.isAuditing)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_use_bg, self.data_.config.Id == id and not self.data_.isAuditing)
  elseif self.data_.config.Type == DEFINE.ProfileImageType.HeadFrame then
    local id = self.personalZoneData_:GetDefaultProfileImageConfigByType(DEFINE.ProfileImageType.HeadFrame)
    if Z.ContainerMgr.CharSerialize.personalZone and Z.ContainerMgr.CharSerialize.personalZone.avatarFrameId and Z.ContainerMgr.CharSerialize.personalZone.avatarFrameId ~= 0 then
      id = Z.ContainerMgr.CharSerialize.personalZone.avatarFrameId
    end
    local viewData = {}
    viewData.headFrameId = self.data_.config.Id
    PlayerPortraitHgr.InsertNewPortrait(self.uiBinder, viewData)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_use_bg, self.data_.config.Id == id)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_unlocked, not self.personalZoneVM_.CheckProfileImageIsUnlock(self.data_.config.Id))
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.data_.select)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_reddot, self.personalZoneVM_.CheckSingleRedDot(self.data_.config.Id))
end

return PersonalZoneHead
