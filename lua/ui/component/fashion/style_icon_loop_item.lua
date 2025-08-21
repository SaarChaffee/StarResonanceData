local super = require("ui.component.loop_grid_view_item")
local FashionStyleIconLoopItem = class("FashionStyleIconLoopItem", super)
local item = require("common.item_binder")

function FashionStyleIconLoopItem:OnInit()
  self.parentView_ = self.parent.UIView
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.fashionRed_ = require("rednode.fashion_red")
end

function FashionStyleIconLoopItem:OnRefresh(data)
  self.styleData_ = data
  Z.GuideMgr:SetSteerId(self.uiBinder, E.DynamicSteerType.FashionId, self.styleData_.fashionId)
  local itemData = {
    configId = data.fashionId,
    uiBinder = self.uiBinder,
    isSquareItem = true
  }
  self.itemClass_:RefreshByData(itemData)
  local isNotEmpty = self.styleData_.fashionId > 0 and not self.styleData_.isEmpty
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, not isNotEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_quality, isNotEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_icon, isNotEmpty)
  if isNotEmpty then
    local isLock = not Z.StageMgr.GetIsInLogin() and not self.styleData_.isUnlock
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, isLock)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  local curRegion = self.parentView_:GetCurRegion()
  local wornFashion = self.fashionData_:GetServerFashionWear(curRegion)
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.uisteer, E.DynamicSteerType.FashionItemIndex, curRegion .. "=" .. self.Index)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, self.styleData_.fashionId == wornFashion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_deal_state, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lab_bg, false)
  local customRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemUnlock, self.styleData_.fashionId)
  local redState = Z.RedPointMgr.GetRedState(customRed)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, redState)
  self:refreshStyleItemRed()
end

function FashionStyleIconLoopItem:refreshStyleItemRed()
  if not self.styleData_ or self.styleData_.fashionId == 0 then
    return
  end
  self.regionRed_ = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemRed, self.styleData_.fashionId)
  Z.RedPointMgr.LoadRedDotItem(self.regionRed_, self.parent.UIView, self.uiBinder.Trans)
  self.region2Red_ = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemRed, 2, self.styleData_.fashionId)
  Z.RedPointMgr.LoadRedDotItem(self.region2Red_, self.parent.UIView, self.uiBinder.Trans)
end

function FashionStyleIconLoopItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    self.parentView_:SelectStyle(self.styleData_, isClick)
    local customRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemUnlock, self.styleData_.fashionId)
    local redState = Z.RedPointMgr.GetRedState(customRed)
    if redState then
      self.fashionRed_.RemoveWeaponSkinRed(self.styleData_.fashionId)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_reddot, false)
  end
end

function FashionStyleIconLoopItem:OnPointerClick(go, eventData)
  if self.IsSelected then
    self.parentView_:UnSelectStyle()
  end
  Z.RedPointMgr.OnClickRedDot(self.regionRed_)
  Z.RedPointMgr.UpdateNodeCount(self.regionRed_, 0)
  Z.RedPointMgr.RefreshRedNodeState(self.regionRed_)
  Z.RedPointMgr.OnClickRedDot(self.region2Red_)
  Z.EventMgr:Dispatch(Z.ConstValue.GM.GMFashionView, self.styleData_.fashionId)
end

function FashionStyleIconLoopItem:OnUnInit()
  self.styleData_ = nil
  self.parentView_ = nil
  self.itemClass_:UnInit()
  Z.RedPointMgr.RemoveNodeItem(self.regionRed_)
  Z.RedPointMgr.RemoveNodeItem(self.region2Red_)
end

function FashionStyleIconLoopItem:OnRecycle()
  self.uiBinder.rimg_icon.enabled = false
  Z.RedPointMgr.RemoveNodeItem(self.regionRed_)
  Z.RedPointMgr.RemoveNodeItem(self.region2Red_)
end

return FashionStyleIconLoopItem
