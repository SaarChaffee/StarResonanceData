local super = require("ui.component.loop_list_view_item")
local TradeShopItem = class("TradeShopItem", super)
local item = require("common.item_binder")

function TradeShopItem:ctor()
end

function TradeShopItem:OnInit()
end

function TradeShopItem:OnRefresh(data)
  self.itemRow_ = data
  self.uiBinder.lab_name.text = Z.RichTextHelper.ApplyStyleTag(data.Name, "ItemQuality_" .. data.Quality)
end

function TradeShopItem:OnSelected(isSelect)
  if isSelect then
    self.parent.UIView:OnSearchItem(self.itemRow_.Id)
  end
end

function TradeShopItem:OnUnInit()
end

return TradeShopItem
