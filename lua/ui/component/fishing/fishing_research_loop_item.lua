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
  local fishCfg_ = self.fishingData_.FishRecordDict[data].FishCfg
  self.uiBinder.rimg_icon:SetImage(fishCfg_.FishingIcon)
  self.uiBinder.lab_research.text = self.fishingData_.FishRecordDict[data].ResearchLevel
  self.uiBinder.img_ing.fillAmount = self.fishingData_.FishRecordDict[data].ResearchProgress[1]
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_uesd, self.fishingData_.QTEData.UseResearchFish == data)
  self:SelectState()
end

function FishingResearchLoopItem:Selected(isSelected)
  if isSelected then
    self.parentUIView:OnClickResearchItem(self.data)
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

function FishingResearchLoopItem:onStartAnimatedShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

return FishingResearchLoopItem
