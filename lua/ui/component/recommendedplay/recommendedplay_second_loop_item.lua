local super = require("ui.component.loop_list_view_item")
local RecommendedplaySecondLoopItem = class("RecommendedplaySecondLoopItem", super)

function RecommendedplaySecondLoopItem:OnInit()
  self.recommendedPlayVM_ = Z.VMMgr.GetVM("recommendedplay")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.nodeTog_ = self.uiBinder.node_tog
  self.uiView_ = self.parent.UIView
end

function RecommendedplaySecondLoopItem:OnRefresh(data)
  self.data_ = data
  self.nodeTog_.lab_on_name.text = data.Name
  self.nodeTog_.lab_on_content.text = data.AwardDes
  self.nodeTog_.lab_off_name.text = data.Name
  self.nodeTog_.lab_off_content.text = data.AwardDes
  if data.TagPic and data.TagPic ~= 0 then
    self.nodeTog_.Ref:SetVisible(self.nodeTog_.img_tag, true)
    self.nodeTog_.lab_time.text = data.ActTag
  else
    self.nodeTog_.Ref:SetVisible(self.nodeTog_.img_tag, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, self.recommendedPlayVM_.CheckSecondTagIsRed(data.Id))
  local isSelected = self.uiView_:GetSecondSelectedId() == self.data_.Id
  self.nodeTog_.Ref:SetVisible(self.nodeTog_.node_off, not isSelected)
  self.nodeTog_.Ref:SetVisible(self.nodeTog_.node_on, isSelected)
  local count = self.recommendedPlayVM_.GetRecommendSurpluseCount(data)
  if count == 0 then
    self.nodeTog_.Ref:SetVisible(self.nodeTog_.img_mask_get, true)
  else
    self.nodeTog_.Ref:SetVisible(self.nodeTog_.img_mask_get, false)
  end
  if isSelected then
    self.commonVM_.CommonDotweenPlay(self.nodeTog_.anim, Z.DOTweenAnimType.Open, nil)
  else
    self.nodeTog_.anim:Complete(Z.DOTweenAnimType.Open)
  end
end

function RecommendedplaySecondLoopItem:OnSelected(isSelected)
  local isSel = self.uiView_:GetSecondSelectedId() == self.data_.Id
  if isSel then
    if isSelected then
      self.uiView_:SelectedThirdItem()
    end
    return
  end
  self.nodeTog_.Ref:SetVisible(self.nodeTog_.node_off, not isSelected)
  self.nodeTog_.Ref:SetVisible(self.nodeTog_.node_on, isSelected)
  if isSelected then
    self.uiView_:selectSecondTag(self.data_.Id)
  end
end

function RecommendedplaySecondLoopItem:OnRecycle()
end

return RecommendedplaySecondLoopItem
