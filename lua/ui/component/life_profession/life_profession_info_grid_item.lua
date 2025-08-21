local super = require("ui.component.loop_grid_view_item")
local LifeProfessionInfoGridItem = class("LifeProfessionInfoGridItem", super)
local item = require("common.item_binder")

function LifeProfessionInfoGridItem:ctor()
  self.lifeProfessionVm_ = Z.VMMgr.GetVM("life_profession")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function LifeProfessionInfoGridItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function LifeProfessionInfoGridItem:OnRefresh(data)
  self.lifeType = data.lifeType
  self.data = data
  self.itemClass_:HideUi()
  local configData
  local icon = ""
  if self.lifeType == E.ELifeProfessionMainType.Collection then
    configData = Z.TableMgr.GetRow("LifeCollectListTableMgr", data.productId)
    icon = configData.Icon
  else
    configData = Z.TableMgr.GetRow("LifeProductionListTableMgr", data.productId)
    icon = self.itemsVm_.GetItemIcon(configData.RelatedItemId)
  end
  local quality = configData.Quality
  self.itemClass_:setQuality(Z.ConstValue.Item.SquareItemQualityPath .. quality)
  self.itemClass_:SetIcon(icon)
  self.itemClass_:SetSelected(self.IsSelected)
  local isProductionUnlocked = self.lifeProfessionVm_.IsProductUnlocked(configData.LifeProId, configData.Id, self.parentUIView.isConsume)
  self.itemClass_:SetImgLockState(not isProductionUnlocked)
  local isProductionHasCost = self.lifeProfessionVm_.IsProductHasCost(configData.LifeProId, configData.Id)
  if self.parentUIView.isConsume ~= nil then
    self.itemClass_:SetImgTradeState(isProductionHasCost and self.parentUIView.isConsume)
  else
    self.itemClass_:SetImgTradeState(isProductionHasCost)
  end
end

function LifeProfessionInfoGridItem:OnUnInit()
  self.itemClass_:UnInit()
end

function LifeProfessionInfoGridItem:OnSelected(isSelected, isClick)
  if isSelected then
    self.parentUIView:OnSelectItem(self.data)
  end
  self.itemClass_:SetSelected(isSelected)
end

return LifeProfessionInfoGridItem
