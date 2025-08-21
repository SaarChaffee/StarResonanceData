local super = require("ui.component.loop_list_view_item")
local FashionSecondItem = class("FashionSecondItem", super)

function FashionSecondItem:OnInit()
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.settingVM_ = Z.VMMgr.GetVM("fashion_setting")
  self.uiBinder.btn_visable:AddListener(function()
    self.settingVM_.SetSingleFashionRegionIsHide(self.data_.region, not self.isHide_)
  end)
end

function FashionSecondItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.img_icon:SetImage(data.icon)
  self:refreshBtnVisable()
  self:refreshItemData(data.region)
  self:refreshRegionVisable()
  self:refreshEmptyState()
  self:refreshSecondRed()
end

function FashionSecondItem:refreshItemData(region)
  local data = self.fashionData_:GetWear(region)
  if data and data.fashionId and data.fashionId > 0 then
    local itemsVm_ = Z.VMMgr.GetVM("items")
    self.uiBinder.rimg_icon:SetImage(itemsVm_.GetItemIcon(data.fashionId))
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon, true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function FashionSecondItem:refreshRegionVisable()
  local regionDict = self.settingVM_.GetCurFashionSettingRegionDict()
  self.isHide_ = regionDict[self.data_.region] == 2
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, not self.isHide_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_off, self.isHide_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_conceal, self.isHide_)
end

function FashionSecondItem:refreshEmptyState()
  if self.fashionData_.HideRegionList[self.data_.region] then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, false)
  end
end

function FashionSecondItem:refreshSecondRed()
  self.regionRed_ = string.zconcat(Z.ConstValue.Fashion.FashionRegionRed, self.data_.region)
  Z.RedPointMgr.LoadRedDotItem(self.regionRed_, self.parent.UIView, self.uiBinder.node_red)
  self.region2Red_ = string.zconcat(Z.ConstValue.Fashion.FashionRegionRed, 2, self.data_.region)
  Z.RedPointMgr.LoadRedDotItem(self.region2Red_, self.parent.UIView, self.uiBinder.node_red)
end

function FashionSecondItem:OnSelected(isSelected, isClick)
  if isSelected then
    self.parent.UIView:OnSwitchRegion(self.data_.region)
  end
  self:refreshBtnVisable()
  Z.RedPointMgr.OnClickRedDot(self.regionRed_)
  Z.RedPointMgr.OnClickRedDot(self.region2Red_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function FashionSecondItem:refreshBtnVisable()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_visable, self.IsSelected and not Z.StageMgr.GetIsInLogin())
end

function FashionSecondItem:OnUnInit()
  Z.RedPointMgr.RemoveNodeItem(self.regionRed_)
  Z.RedPointMgr.RemoveNodeItem(self.region2Red_)
end

function FashionSecondItem:OnRecycle()
  Z.RedPointMgr.RemoveNodeItem(self.regionRed_)
  Z.RedPointMgr.RemoveNodeItem(self.region2Red_)
end

return FashionSecondItem
