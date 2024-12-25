local super = require("ui.component.loop_list_view_item")
local TradeConsignmentRecordItem = class("TradeConsignmentRecordItem", super)

function TradeConsignmentRecordItem:ctor()
end

function TradeConsignmentRecordItem:OnInit()
  self.tradeData_ = Z.DataMgr.Get("trade_data")
end

function TradeConsignmentRecordItem:OnRefresh(data)
  self.uiBinder.lab_digit_left.text = data.serverData.num
  self.uiBinder.lab_digit_right.text = data.serverData.money
  self.uiBinder.lab_exchange_rate_num.text = data.serverData.rate
  local timeData = Z.TimeTools.Tp2YMDHMS(data.serverData.time)
  self.uiBinder.lab_time.text = string.format("%s/%s/%s %02d:%02d", timeData.year, timeData.month, timeData.day, timeData.hour, timeData.min)
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemsVM = Z.VMMgr.GetVM("items")
  if data.isLeft then
    self.uiBinder.img_left_line:SetColorByHex("#FFB0B0")
    local fakeDiamondRow = itemTableMgr.GetRow(self.tradeData_.FakeDiamondItem)
    if fakeDiamondRow then
      self.uiBinder.rimg_gold_left:SetImage(itemsVM.GetItemIcon(self.tradeData_.FakeDiamondItem))
    end
  else
    self.uiBinder.img_left_line:SetColorByHex("#D5F8AA")
    local diamondRow = itemTableMgr.GetRow(self.tradeData_.DiamondItem)
    if diamondRow then
      self.uiBinder.rimg_gold_left:SetImage(itemsVM.GetItemIcon(self.tradeData_.DiamondItem))
    end
  end
  local costItemRow = itemTableMgr.GetRow(self.tradeData_.DefaultItem)
  if costItemRow then
    self.uiBinder.rimg_gold_right:SetImage(itemsVM.GetItemIcon(self.tradeData_.DefaultItem))
  end
end

function TradeConsignmentRecordItem:OnUnInit()
end

return TradeConsignmentRecordItem
