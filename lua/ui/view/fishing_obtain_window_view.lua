local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_obtain_windowView = class("Fishing_obtain_windowView", super)

function Fishing_obtain_windowView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fishing_obtain_window")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingSettingData_ = Z.DataMgr.Get("fishing_setting_data")
end

function Fishing_obtain_windowView:OnActive()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self:AddClick(self.uiBinder.btn_go, function()
    self.fishingVM_.EnterFishingState()
    Z.UIMgr:CloseView("fishing_obtain_window")
    self.fishingVM_.FishingSuccessShowEnd()
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    self.fishingVM_.QuitFishingState(self.cancelSource:CreateToken())
    Z.UIMgr:CloseView("fishing_obtain_window")
  end)
  self.fishingVM_.ResetEntityAndUIVisible(true)
  Z.AudioMgr:Play("UI_Event_Fishing_NewTip")
end

function Fishing_obtain_windowView:refreshUI()
  local typeCfg_ = Z.TableMgr.GetTable("FishingTypeTableMgr").GetRow(self.fishingData_.TargetFish.FishInfo.Type)
  local showLength_ = self.fishingData_.TargetFish.Size > 0 and typeCfg_.Infoshow == 1
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_length, showLength_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unit, showLength_)
  self.uiBinder.lab_length.text = string.format("%.2f", self.fishingData_.TargetFish.Size / 100)
  self.uiBinder.lab_name.text = self.fishingData_.TargetFish.FishInfo.Name
  self.uiBinder.rimg_fish:SetImage(self.fishingData_.TargetFish.FishInfo.FishingIcon)
  self.uiBinder.Ref.UIComp:SetVisible(true)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  if self.fishingData_.ShowLevelUp then
    self.fishingVM_.OpenFishingLevelUpTip()
    self.fishingData_.ShowLevelUp = false
  end
  local newRecord_ = typeCfg_.Infoshow == 1 and self.fishingData_.TargetFish.Size > 0 and self.fishingData_.TargetFish.Size > self.fishingData_.TargetFish.OldSizeRecord
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newrecord, newRecord_)
  local newUnLock_ = self.fishingData_.TargetFish.OldSizeRecord == -1
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_new, newUnLock_)
  if self.fishingData_.TargetFish.FishInfo.Quality == E.FishingQuality.Normal then
    self.uiBinder.lab_rarity.text = Lang("FishingIllustratedNormal")
  elseif self.fishingData_.TargetFish.FishInfo.Quality == E.FishingQuality.Rare then
    self.uiBinder.lab_rarity.text = Lang("FishingIllustratedRare")
  elseif self.fishingData_.TargetFish.FishInfo.Quality == E.FishingQuality.Myth then
    self.uiBinder.lab_rarity.text = Lang("FishingIllustratedMyth")
  end
  self.uiBinder.img_rarity:SetImage(self.fishingData_.IllQualityPathDict_[self.fishingData_.TargetFish.FishInfo.Quality])
  local fishCfg = Z.TableMgr.GetTable("FishingTableMgr").GetRow(self.fishingData_.TargetFish.FishInfo.FishId)
  local curStar = self.fishingData_.GetStarBySize(self.fishingData_.TargetFish.Size / 100, fishCfg)
  self:updateStarUI(typeCfg_.Infoshow == 1, curStar)
end

function Fishing_obtain_windowView:updateStarUI(show, star)
  self.uiBinder.node_star.Ref.UIComp:SetVisible(show)
  if show then
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_01, 1 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_02, 2 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_03, 3 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_04, 4 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_05, 5 <= star)
  end
end

function Fishing_obtain_windowView:OnDeActive()
  Z.UITimelineDisplay:ClearTimeLine()
  self.fishingVM_.ResetEntityAndUIVisible()
end

function Fishing_obtain_windowView:OnRefresh()
  self.uiBinder.Ref.UIComp:SetVisible(false)
  self:playFishingSuccessTimeLine()
  self.fishingData_.IgnoreInputBack = true
end

function Fishing_obtain_windowView:playFishingSuccessTimeLine()
  local cutId = 50200101
  local weaponState = self.fishingSettingData_:GetEntityTypeState(E.CamerasysShowEntityType.WeaponsAppearance)
  local weaponHideState = -1
  if weaponState then
    weaponHideState = 0
  else
    weaponHideState = 1
  end
  Z.UITimelineDisplay:SetWeaponsHideState(weaponHideState)
  Z.UITimelineDisplay:AsyncPreLoadTimeline(cutId, self.cancelSource:CreateToken(), function()
    Z.UITimelineDisplay:Play(cutId)
    Z.UITimelineDisplay:SetGoPosByCutsceneId(cutId, Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos())
    local quaternion_ = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualRot()
    Z.UITimelineDisplay:SetGoQuaternionByCutsceneId(cutId, quaternion_.x, quaternion_.y, quaternion_.z, quaternion_.w)
    self:refreshUI()
    self.fishingData_.IgnoreInputBack = false
  end)
end

function Fishing_obtain_windowView:OnInputBack()
  if not self.fishingData_.IgnoreInputBack and self.IsResponseInput then
    self.fishingVM_.QuitFishingState(self.cancelSource:CreateToken())
    Z.UIMgr:CloseView("fishing_obtain_window")
  end
end

function Fishing_obtain_windowView:setCameraOffsetByPlayerHeight(timelineController)
end

return Fishing_obtain_windowView
