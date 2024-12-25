local super = require("ui.component.loop_grid_view_item")
local ResonancePowerGetConsumeLoopItem = class("ResonancePowerGetConsumeLoopItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function ResonancePowerGetConsumeLoopItem:ctor()
end

function ResonancePowerGetConsumeLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function ResonancePowerGetConsumeLoopItem:OnRefresh(awardData_)
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
  self.itemClass_:RefreshByData(itemData)
end

function ResonancePowerGetConsumeLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return ResonancePowerGetConsumeLoopItem
