local super = require("ui.component.loop_grid_view_item")
local SeasonShopWearItem = class("SeasonShopWearItem", super)
local item = require("common.item_binder")

function SeasonShopWearItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.uiBinder.btn_minus:AddListener(function()
    self.parent.UIView:RemoveWear(self.data_)
  end)
end

function SeasonShopWearItem:OnUnInit()
  self.itemClass_:UnInit()
end

function SeasonShopWearItem:OnRefresh(data)
  self.data_ = data
  local itemData = {}
  itemData.configId = data.mallItemRow.ItemId
  itemData.uiBinder = self.uiBinder
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isSquareItem = true
  self.itemClass_:Init(itemData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_minus, true)
end

return SeasonShopWearItem
