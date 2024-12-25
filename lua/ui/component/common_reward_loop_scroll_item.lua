local super = require("ui.component.loopscrollrectitem")
local CommonRewardLoopScrollItem = class("CommonRewardLoopScrollItem", super)
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
local itemBinder = require("common.item_binder")

function CommonRewardLoopScrollItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemBinder_ = itemBinder.new(self.parent.uiView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function CommonRewardLoopScrollItem:Refresh()
  local index_ = self.component.Index + 1
  local awardData_ = self.parent:GetDataByIndex(index_)
  if awardData_ == nil then
    return
  end
  local itemData = {}
  itemData.configId = awardData_.awardId
  itemData.uiBinder = self.uiBinder
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(awardData_)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = awardData_.received
  itemData.isSquareItem = true
  itemData.PrevDropType = awardData_.PrevDropType
  self.itemBinder_:Init(itemData)
end

function CommonRewardLoopScrollItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return CommonRewardLoopScrollItem
