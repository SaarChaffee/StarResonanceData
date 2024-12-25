local super = require("ui.component.loopscrollrectitem")
local AwardLoopBinderItem = class("AwardLoopBinderItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function AwardLoopBinderItem:OnInit()
  self.itemClass_ = item.new(self.parent.uiView)
end

function AwardLoopBinderItem:Refresh()
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
  itemData.isShowReceive = awardData_.beGet ~= nil and awardData_.beGet
  itemData.isSquareItem = true
  itemData.PrevDropType = awardData_.PrevDropType
  self.itemClass_:Init(itemData)
end

function AwardLoopBinderItem:OnUnInit()
  self.itemClass_:UnInit()
end

return AwardLoopBinderItem
