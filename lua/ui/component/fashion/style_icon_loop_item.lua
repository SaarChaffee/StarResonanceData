local super = require("ui.component.loop_grid_view_item")
local FashionStyleIconLoopItem = class("FashionStyleIconLoopItem", super)
local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
local item = require("common.item_binder")

function FashionStyleIconLoopItem:OnInit()
  self.parentView_ = self.parent.UIView
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function FashionStyleIconLoopItem:OnRefresh(data)
  self.styleData_ = data
  Z.GuideMgr:SetSteerId(self.uiBinder, E.DynamicSteerType.FashionId, self.styleData_.fashionId)
  local itemData = {}
  itemData.configId = data.fashionId
  itemData.uiBinder = self.uiBinder
  itemData.isSquareItem = true
  self.itemClass_:RefreshByData(itemData)
  local isNotEmpty = self.styleData_.fashionId > 0
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, not isNotEmpty)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_quality, isNotEmpty)
  if isNotEmpty then
    local isLock = not Z.StageMgr.GetIsInLogin() and self.styleData_.uuid == nil
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_lock, isLock)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  local curRegion = self.parentView_:GetCurRegion()
  local fashionData = Z.DataMgr.Get("fashion_data")
  local wornFashion = fashionData:GetServerFashionWear(curRegion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_use, self.styleData_.fashionId == wornFashion)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_deal_state, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_lab_bg, false)
end

function FashionStyleIconLoopItem:OnSelected(isSelected, isClick)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if isSelected then
    if isClick then
      Z.AudioMgr:Play("sys_general_frame")
    end
    self.parentView_:SelectStyle(self.styleData_)
  end
end

function FashionStyleIconLoopItem:OnPointerClick(go, eventData)
  if self.IsSelected then
    self.parentView_:UnSelectStyle()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.GM.GMFashionView, self.styleData_.fashionId)
end

function FashionStyleIconLoopItem:OnUnInit()
  self.styleData_ = nil
  self.parentView_ = nil
  self.itemClass_:UnInit()
end

function FashionStyleIconLoopItem:OnRecycle()
  self.uiBinder.rimg_icon.enabled = false
end

return FashionStyleIconLoopItem
