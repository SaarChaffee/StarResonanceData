local super = require("ui.component.loop_grid_view_item")
local FishingResearchLoopItem = class("FishingResearchLoopItem", super)

function FishingResearchLoopItem:ctor()
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
end

function FishingResearchLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
end

function FishingResearchLoopItem:OnRefresh(data)
  self.data = data
  self.isUnLock_ = self.fishingData_.FishRecordDict[data].FishRecord ~= nil
  self.firstFlag_ = self.isUnLock_ and self.fishingData_.FishRecordDict[data].FishRecord.firstFlag
  local showNormal_ = self.isUnLock_ and self.firstFlag_
  local fishCfg_ = self.fishingData_.FishRecordDict[data].FishCfg
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, showNormal_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_blue, showNormal_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, showNormal_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, showNormal_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_dot, not self.firstFlag_ and self.isUnLock_)
  self.uiBinder.node_star.Ref.UIComp:SetVisible(showNormal_)
  self.uiBinder.rimg_mark:SetImage(fishCfg_.FishingIcon)
  if showNormal_ then
    self.uiBinder.rimg_icon:SetImage(fishCfg_.FishingIcon)
    self.uiBinder.img_blue:SetImage(fishCfg_.FishingShadowIcon)
    local fishingTypeRow_ = Z.TableMgr.GetTable("FishingTypeTableMgr").GetRow(fishCfg_.Type)
    self.uiBinder.img_icon:SetImage(fishingTypeRow_.FishingTypeIcon)
    local typeCfg_ = Z.TableMgr.GetTable("FishingTypeTableMgr").GetRow(fishCfg_.Type)
    self:updateStarUI(typeCfg_.Infoshow == 1, self.fishingData_.FishRecordDict[data].Star)
  end
  self:SelectState()
end

function FishingResearchLoopItem:updateStarUI(show, star)
  self.uiBinder.node_star.Ref.UIComp:SetVisible(show)
  if show then
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_01, 1 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_02, 2 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_03, 3 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_04, 4 <= star)
    self.uiBinder.node_star.Ref:SetVisible(self.uiBinder.node_star.img_star_05, 5 <= star)
  end
end

function FishingResearchLoopItem:Selected(isSelected)
  if isSelected then
    self.parentUIView:OnClickIllustratedItem(self.data)
  end
  self:SelectState()
end

function FishingResearchLoopItem:SelectState()
  local isSelected = self.IsSelected
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  self:onStartAnimatedShow()
end

function FishingResearchLoopItem:OnSelected(isSelected)
  local curData = self:GetCurData()
  if curData == nil then
    return
  end
  self.data = curData
  self:Selected(isSelected)
end

function FishingResearchLoopItem:OnUnInit()
end

function FishingResearchLoopItem:OnPointerClick(go, eventData)
  if self.isUnLock_ and not self.firstFlag_ then
    self.parentUIView:OnClickIllustratedItemUnLock(self.data)
  end
end

function FishingResearchLoopItem:onStartAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

function FishingResearchLoopItem:OnRecycle()
  self.uiBinder.rimg_icon.enabled = false
  self.uiBinder.rimg_mark.enabled = false
end

return FishingResearchLoopItem
