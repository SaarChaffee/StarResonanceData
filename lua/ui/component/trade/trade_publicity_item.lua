local super = require("ui.component.loop_grid_view_item")
local TradePublicityItem = class("TradePublicityItem", super)

function TradePublicityItem:ctor()
end

function TradePublicityItem:OnInit()
end

function TradePublicityItem:OnRefresh(data)
  self.data_ = data
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.id)
  if itemRow then
    self.uiBinder.lab_item_name.text = itemRow.Name
    local itemsVM = Z.VMMgr.GetVM("items")
    self.uiBinder.rimg_icon:SetImage(itemsVM.GetItemIcon(data.id))
    self.uiBinder.img_bg:SetImage(Z.ConstValue.Trade.TradeItemBgPath .. itemRow.Quality)
  end
  self.uiBinder.lab_sale.text = Lang("in_sell")
  self.uiBinder.lab_sale_no.text = Lang("in_sell")
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_no_price, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_current_sale_no, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_current_sale, true)
  local stallItemRow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(data.id)
  if stallItemRow then
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(stallItemRow.Currency)
    if itemRow then
      local itemsVM = Z.VMMgr.GetVM("items")
      self.uiBinder.rimg_price:SetImage(itemsVM.GetItemIcon(stallItemRow.Currency))
    end
  end
  self.uiBinder.lab_sale_num.text = data.num
  self.uiBinder.lab_current_price.text = data.price
end

function TradePublicityItem:OnSelected(isSelect)
  if self.IsSelected then
    self.parent.UIView:OnItemSelect(self.data_.id)
  end
end

function TradePublicityItem:OnUnInit()
  self.itemClass_:UnInit()
end

return TradePublicityItem
