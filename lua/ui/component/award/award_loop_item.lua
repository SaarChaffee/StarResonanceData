local super = require("ui.component.loopscrollrectitem")
local AwardLoopItem = class("AwardLoopItem", super)
local item = require("common.item")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function AwardLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.uiView)
end

function AwardLoopItem:Refresh()
  local index_ = self.component.Index + 1
  local awardData_ = self.parent:GetDataByIndex(index_)
  if awardData_ == nil then
    return
  end
  local itemData = {}
  itemData.configId = awardData_.awardId
  itemData.unit = self.unit
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(awardData_)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = awardData_.beGet ~= nil and awardData_.beGet
  itemData.isSquareItem = true
  itemData.PrevDropType = awardData_.PrevDropType
  self.itemClass_:Init(itemData)
  self.itemClass_:SetRedDot(false)
end

function AwardLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return AwardLoopItem
