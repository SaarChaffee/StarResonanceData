local super = require("ui.component.loop_grid_view_item")
local ResonancePowerDecomposeConsumeLoopItem = class("ResonancePowerDecomposeConsumeLoopItem", super)
local item = require("common.item_binder")

function ResonancePowerDecomposeConsumeLoopItem:ctor()
end

function ResonancePowerDecomposeConsumeLoopItem:OnInit()
  self.parentUIView = self.parent.UIView
  self.itemClass_ = item.new(self.parentUIView)
end

function ResonancePowerDecomposeConsumeLoopItem:OnRefresh(data)
  self.data = data
  local index = self.Index + 1
  if not data then
    logError("EquipItemsLoopItem data is nil,index is " .. index)
    return
  end
  self:SetCanSelect(false)
  self.uuid_ = data.itemUuid
  self.configId = data.configId
  self:setui()
end

function ResonancePowerDecomposeConsumeLoopItem:setui()
  self.itemClass_:Init({
    uiBinder = self.uiBinder,
    configId = self.configId,
    uuid = self.uuid_,
    isClickOpenTips = true,
    isShowOne = false
  })
end

return ResonancePowerDecomposeConsumeLoopItem
