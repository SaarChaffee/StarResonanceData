local super = require("ui.component.loop_grid_view_item")
local LifeManufacturePreviewItem = class("LifeManufacturePreviewItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function LifeManufacturePreviewItem:ctor()
  self.lifeProfessionVm_ = Z.VMMgr.GetVM("life_profession")
  self.lifeProfessionData_ = Z.DataMgr.Get("life_profession_data")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function LifeManufacturePreviewItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClass_ = item.new(self.parent.UIView)
end

function LifeManufacturePreviewItem:OnRefresh(data)
  if data == nil then
    return
  end
  local itemData = {}
  itemData.configId = data.awardId
  itemData.uiBinder = self.uiBinder.item
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(data)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = data.beGet ~= nil and data.beGet
  itemData.isSquareItem = true
  itemData.PrevDropType = data.PrevDropType
  self.itemClass_:Init(itemData)
end

function LifeManufacturePreviewItem:OnUnInit()
  self.itemClass_:UnInit()
end

return LifeManufacturePreviewItem
