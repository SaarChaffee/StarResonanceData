local super = require("ui.component.loop_list_view_item")
local UnionTaskRewardItem = class("UnionTaskRewardItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function UnionTaskRewardItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function UnionTaskRewardItem:OnRefresh(data)
  if data == nil then
    return
  end
  local awardData_ = data.PreviewData
  local itemData = {}
  itemData.configId = awardData_.awardId
  itemData.uiBinder = self.uiBinder
  itemData.labType = data.labType
  itemData.lab = data.lab
  itemData.isShowZero = true
  itemData.isShowOne = true
  itemData.isSquareItem = true
  itemData.PrevDropType = awardData_.PrevDropType
  self.itemClass_:Init(itemData)
end

function UnionTaskRewardItem:OnUnInit()
  self.itemClass_:UnInit()
end

return UnionTaskRewardItem
