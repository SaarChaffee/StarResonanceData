local super = require("ui.component.loop_grid_view_item")
local ComRewardsItem = class("ComRewardsItem", super)
local item = require("common.item_binder")

function ComRewardsItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function ComRewardsItem:OnUnInit()
  self.itemClass_:UnInit()
end

function ComRewardsItem:OnRefresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data.configId,
    uuid = data.uuid,
    lab = data.count,
    itemInfo = data.itemInfo,
    isSquareItem = true
  }
  self.itemClass_:RefreshByData(itemData)
end

return ComRewardsItem
