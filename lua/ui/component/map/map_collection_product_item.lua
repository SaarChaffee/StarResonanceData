local super = require("ui.component.loop_list_view_item")
local MapCollectionProductItem = class("MapCollectionProductItem", super)
local itemBinder = require("common.item_binder")

function MapCollectionProductItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function MapCollectionProductItem:OnRefresh(data)
  local awardData_ = data.data
  local itemData = {}
  itemData.configId = awardData_.awardId
  itemData.uiBinder = self.uiBinder
  itemData.labType, itemData.lab = self.awardPreviewVM_.GetPreviewShowNum(awardData_)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = awardData_.beGet ~= nil and awardData_.beGet
  itemData.isSquareItem = true
  itemData.PrevDropType = data.isExtra and E.AwardPrevDropType.Probability or awardData_.PrevDropType
  itemData.ShowTag = data.isExtra
  self.itemBinder_:RefreshByData(itemData)
  self.itemBinder_:SetImgLockState(not data.isUnlocked)
end

function MapCollectionProductItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return MapCollectionProductItem
