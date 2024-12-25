local super = require("ui.component.loop_grid_view_item")
local RecycleLoopPreviewItem = class("RecycleLoopPreviewItem", super)
local itemBinder = require("common.item_binder")

function RecycleLoopPreviewItem:OnInit()
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function RecycleLoopPreviewItem:OnRefresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    uuid = data.itemUuid,
    configId = data.configId,
    lab = data.count,
    isBind = true
  }
  self.itemBinder_:RefreshByData(itemData)
end

function RecycleLoopPreviewItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return RecycleLoopPreviewItem
