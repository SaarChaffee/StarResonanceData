local UI = Z.UI
local super = require("ui.ui_view_base")
local Personalzone_obtained_popupView = class("Personalzone_obtained_popupView", super)
local DEFINE = require("ui.model.personalzone_define")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Personalzone_obtained_popupView:ctor()
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "personalzone_obtained_popup")
  self.personalZoneVM_ = Z.VMMgr.GetVM("personal_zone")
  self.personalZoneData_ = Z.DataMgr.Get("personal_zone_data")
end

function Personalzone_obtained_popupView:OnActive()
  self.modelId_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.ModelAttr.EModelID).Value
  self.uiBinder.scenemask_bg:SetSceneMaskByKey(self.SceneMaskKey)
  self.uiBinder.presscheck:StartCheck()
  self:EventAddAsyncListener(self.uiBinder.presscheck.ContainGoEvent, function(isContain)
    if not isContain then
      Z.UIMgr:CloseView(self.viewConfigKey)
    end
  end, nil, nil)
  local functionId = 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_title_name, false)
  self.uiBinder.com_head_51_item.Ref.UIComp:SetVisible(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_medal, false)
  if self.viewData.type == DEFINE.ProfileImageType.Medal then
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_medal, true)
    local medalConfig = Z.TableMgr.GetTable("MedalTableMgr").GetRow(self.viewData.id)
    self.uiBinder.rimg_medal:SetImage(medalConfig.Image)
    self.uiBinder.rimg_bg:SetHeight(360)
    self.uiBinder.lab_title.fontSize = 60
    functionId = E.FunctionID.PersonalzoneMedal
  elseif self.viewData.type == DEFINE.ProfileImageType.Head then
    self.uiBinder.com_head_51_item.Ref.UIComp:SetVisible(true)
    local viewData = {}
    viewData.id = self.viewData.id
    viewData.modelId = self.modelId_
    viewData.isShowCombinationIcon = false
    viewData.isShowTalentIcon = false
    PlayerPortraitHgr.InsertNewPortrait(self.uiBinder.com_head_51_item, viewData)
    self.uiBinder.rimg_bg:SetHeight(360)
    self.uiBinder.lab_title.fontSize = 60
    functionId = E.FunctionID.PersonalzoneHead
  elseif self.viewData.type == DEFINE.ProfileImageType.HeadFrame then
    self.uiBinder.com_head_51_item.Ref.UIComp:SetVisible(true)
    local viewData = {}
    viewData.headFrameId = self.viewData.id
    PlayerPortraitHgr.InsertNewPortrait(self.uiBinder.com_head_51_item, viewData)
    self.uiBinder.rimg_bg:SetHeight(360)
    self.uiBinder.lab_title.fontSize = 60
    functionId = E.FunctionID.PersonalzoneHeadFrame
  elseif self.viewData.type == DEFINE.ProfileImageType.Card then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.viewData.id)
    if profileImageConfig then
      self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_idcard, true)
      self.uiBinder.rimg_idcard:SetImage(profileImageConfig.Image2)
    end
    self.uiBinder.rimg_bg:SetHeight(360)
    self.uiBinder.lab_title.fontSize = 60
    functionId = E.FunctionID.PersonalzoneCard
  elseif self.viewData.type == DEFINE.ProfileImageType.Title then
    local profileImageConfig = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(self.viewData.id)
    if profileImageConfig then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_title_name, true)
      self.uiBinder.lab_title_name.text = profileImageConfig.Name
    end
    self.uiBinder.rimg_bg:SetHeight(100)
    self.uiBinder.lab_title.fontSize = 30
    functionId = E.FunctionID.PersonalzoneTitle
  end
  local funcRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(functionId)
  if funcRow then
    self.uiBinder.lab_title.text = funcRow.Name
  else
    self.uiBinder.lab_title.text = ""
  end
end

function Personalzone_obtained_popupView:OnDeActive()
  self.uiBinder.presscheck:StopCheck()
end

function Personalzone_obtained_popupView:OnRefresh()
end

return Personalzone_obtained_popupView
