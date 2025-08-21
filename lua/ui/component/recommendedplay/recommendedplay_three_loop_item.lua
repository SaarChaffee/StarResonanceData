local super = require("ui.component.loop_list_view_item")
local RecommendedplayThreeLoopItem = class("RecommendedplayThreeLoopItem", super)
local NoCountAlpha = 0.6

function RecommendedplayThreeLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.recommendedPlayVM_ = Z.VMMgr.GetVM("recommendedplay")
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function RecommendedplayThreeLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_off_content.text = data.Name
  self.uiBinder.lab_on_content.text = data.Name
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.recommendedPlayVM_.CheckThirdTagIsRed(data.Id))
  local count = self.recommendedPlayVM_.GetRecommendSurpluseCount(data)
  if self.IsSelected then
    if count == 0 then
      self.uiBinder.canvas_on.alpha = NoCountAlpha
    else
      self.uiBinder.canvas_on.alpha = 1
    end
  elseif count == 0 then
    self.uiBinder.canvas_off.alpha = NoCountAlpha
  else
    self.uiBinder.canvas_off.alpha = 1
  end
end

function RecommendedplayThreeLoopItem:OnSelected(isSelected)
  if isSelected then
    self.uiView_:selectThreeTag(self.data_.Id, self.Index)
    self.commonVM_.CommonDotweenPlay(self.uiBinder.anim, Z.DOTweenAnimType.Open, nil)
  else
    self.uiBinder.anim:Rewind()
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_off, not isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_on, isSelected)
  local count = self.recommendedPlayVM_.GetRecommendSurpluseCount(self.data_)
  if isSelected then
    if count == 0 then
      self.uiBinder.canvas_on.alpha = NoCountAlpha
    else
      self.uiBinder.canvas_on.alpha = 1
    end
  elseif count == 0 then
    self.uiBinder.canvas_off.alpha = NoCountAlpha
  else
    self.uiBinder.canvas_off.alpha = 1
  end
end

function RecommendedplayThreeLoopItem:OnRecycle()
end

return RecommendedplayThreeLoopItem
