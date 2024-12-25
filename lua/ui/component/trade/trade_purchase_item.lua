local super = require("ui.component.loop_grid_view_item")
local TradePurchaseItem = class("TradePurchaseItem", super)
local item = require("common.item_binder")

function TradePurchaseItem:ctor()
end

function TradePurchaseItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function TradePurchaseItem:OnRefresh(data)
end

function TradePurchaseItem:OnSelected(isSelect)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  if self.IsSelected then
    self.parent.UIView:OnPurchaseSelect(self.data_)
  end
end

function TradePurchaseItem:OnUnInit()
  self.itemClass_:UnInit()
end

return TradePurchaseItem
