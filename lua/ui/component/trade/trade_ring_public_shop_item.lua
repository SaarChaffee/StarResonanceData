local super = require("ui.component.loop_grid_view_item")
local TradePublicItem = class("TradePublicItem", super)

function TradePublicItem:ctor()
end

function TradePublicItem:OnInit()
  self.tradeData_ = Z.DataMgr.Get("trade_data")
end

function TradePublicItem:OnRefresh(data)
  self.data_ = data
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.configId)
  if itemRow then
    self.uiBinder.lab_item_name.text = itemRow.Name
    self.uiBinder.rimg_icon:SetImage(itemsVM.GetItemIcon(data.configId))
    self.uiBinder.img_bg:SetImage(Z.ConstValue.Trade.TradeItemBgPath .. itemRow.Quality)
  end
  self.uiBinder.lab_sale.text = Lang("already_prebuy")
  self.uiBinder.lab_sale_no.text = Lang("already_prebuy")
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_no_price, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_current_sale_no, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_current_sale, true)
  self.uiBinder.rimg_price:SetImage(itemsVM.GetItemIcon(self.tradeData_.DefaultItem))
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_attention, false)
  self.uiBinder.lab_sale_num.text = data.num
  self.uiBinder.lab_current_price.text = data.price
end

function TradePublicItem:OnSelected(isSelect)
  if self.IsSelected then
    self.parent.UIView:OnItemSelect(self.data_.configId)
  end
end

function TradePublicItem:OnUnInit()
end

return TradePublicItem
