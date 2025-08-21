local super = require("ui.component.loop_list_view_item")
local TradeRingSellBuyItem = class("TradeRingSellBuyItem", super)
local item = require("common.item_binder")

function TradeRingSellBuyItem:ctor()
end

function TradeRingSellBuyItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function TradeRingSellBuyItem:OnRefresh(data)
  local itemData = {}
  itemData.uiBinder = self.uiBinder.binder_item
  itemData.configId = data.serverData.configId
  itemData.labType = E.ItemLabType.Num
  itemData.lab = data.serverData.num
  itemData.itemInfo = data.serverData.itemInfo
  itemData.isHidecoolDown = true
  itemData.isSquareItem = true
  self.itemClass_:Init(itemData)
  local stallItemInfo = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(data.serverData.configId)
  local sellItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.serverData.configId)
  self.uiBinder.lab_digit.text = data.serverData.price
  if stallItemInfo then
    local costItemId = stallItemInfo.Currency
    self.uiBinder.lab_name.text = sellItemRow.Name
    local itemInfo = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItemId)
    if itemInfo then
      self.uiBinder.rimg_gold:SetImage(itemInfo.Icon)
    end
  end
  local timeData = Z.TimeFormatTools.Tp2YMDHMS(data.serverData.time)
  self.uiBinder.lab_time.text = string.format("%s/%s/%s %02d:%02d", timeData.year, timeData.month, timeData.day, timeData.hour, timeData.min)
  if data.isLeft then
    self.uiBinder.img_left_line:SetColorByHex("#FFB0B0")
  else
    self.uiBinder.img_left_line:SetColorByHex("#D5F8AA")
  end
  if data.serverData.preResult == E.ExchangePreItemResult.ExchangePreItemResultFail then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_advance, true)
    self.uiBinder.lab_result.text = Z.RichTextHelper.ApplyStyleTag(Lang("exchange_pre_fail"), E.TextStyleTag.PreBuyFail)
  elseif data.serverData.preResult == E.ExchangePreItemResult.ExchangePreItemResultNone then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_advance, false)
  elseif data.serverData.preResult == E.ExchangePreItemResult.ExchangePreItemResultSuccess then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_advance, true)
    self.uiBinder.lab_result.text = Z.RichTextHelper.ApplyStyleTag(Lang("exchange_pre_success"), E.TextStyleTag.PreBuySuccess)
  end
end

function TradeRingSellBuyItem:OnUnInit()
  self.itemClass_:UnInit()
end

return TradeRingSellBuyItem
