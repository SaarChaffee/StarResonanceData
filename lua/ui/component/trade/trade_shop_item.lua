local super = require("ui.component.loop_grid_view_item")
local TradeShopItem = class("TradeShopItem", super)

function TradeShopItem:ctor()
end

function TradeShopItem:OnInit()
  self.parent.UIView:AddAsyncClick(self.uiBinder.btn_attention, function()
    self.parent.UIView:OnShopAttentionItem(self.data_)
  end)
  self.tradeData_ = Z.DataMgr.Get("trade_data")
  Z.EventMgr:Add(Z.ConstValue.Trade.TradeItemFocusChange, self.OnFocusChange, self)
end

function TradeShopItem:OnRefresh(data)
  self.data_ = data
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.config.ItemID)
  if itemRow then
    self.uiBinder.lab_item_name.text = itemRow.Name
    self.uiBinder.rimg_icon:SetImage(itemsVM.GetItemIcon(data.config.ItemID))
    self.uiBinder.img_bg:SetImage(Z.ConstValue.Trade.TradeItemBgPath .. itemRow.Quality)
  end
  if self.parent.UIView.isNotice_ then
    self.uiBinder.lab_sale.text = Lang("in_publicity")
    self.uiBinder.lab_sale_no.text = Lang("in_publicity")
  else
    self.uiBinder.lab_sale.text = Lang("in_sell")
    self.uiBinder.lab_sale_no.text = Lang("in_sell")
  end
  if data.serverData and data.serverData.num > 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_no_price, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_current_sale_no, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_current_sale, true)
    self.uiBinder.rimg_price:SetImage(itemsVM.GetItemIcon(data.config.Currency))
    if data.serverData.num > self.tradeData_.showMaxNun then
      self.uiBinder.lab_sale_num.text = self.tradeData_.showMaxNun .. "+"
    else
      self.uiBinder.lab_sale_num.text = data.serverData.num
    end
    self.uiBinder.lab_current_price.text = data.serverData.minPrice
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_no_price, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_bottom, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_current_sale_no, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_current_sale, false)
    self.uiBinder.lab_sale_num_no.text = 0
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, data.serverData and data.serverData.isCare)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_attention, true)
end

function TradeShopItem:OnFocusChange(configId, isCare)
  if self.data_.config.ItemID ~= configId then
    return
  end
  if self.data_.serverData then
    self.data_.serverData.isCare = isCare
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isCare)
end

function TradeShopItem:OnSelected(isSelect)
  if self.IsSelected then
    if self.data_.serverData == nil or self.data_.serverData.num <= 0 then
      Z.TipsVM.ShowTips(1000802)
      return
    end
    self.parent.UIView:OnShopSellItemSelect(self.data_)
  end
end

function TradeShopItem:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Trade.TradeItemFocusChange, self.OnFocusChange, self)
end

function TradeShopItem:OnRecycle()
  self.uiBinder.rimg_icon.enabled = false
  self.uiBinder.rimg_price.enabled = false
end

return TradeShopItem
