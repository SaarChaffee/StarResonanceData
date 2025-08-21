local super = require("ui.component.loop_grid_view_item")
local TradeRingNoticeItem = class("TradeRingNoticeItem", super)
local item = require("common.item_binder")

function TradeRingNoticeItem:ctor()
end

function TradeRingNoticeItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function TradeRingNoticeItem:OnRefresh(data)
  local itemData = {}
  itemData.uiBinder = self.uiBinder.binder_item
  itemData.configId = data.itemInfo.configId
  itemData.labType = E.ItemLabType.Num
  itemData.lab = data.num
  itemData.itemInfo = data.itemInfo
  itemData.isSquareItem = true
  self.itemClass_:Init(itemData)
  local stallItemInfo = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(data.itemInfo.configId)
  local sellItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.itemInfo.configId)
  self.uiBinder.lab_income_num.text = data.price
  if stallItemInfo then
    local costItemId = stallItemInfo.Currency
    self.uiBinder.lab_name.text = sellItemRow.Name
    local itemInfo = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItemId)
    if itemInfo then
      self.uiBinder.rimg_income_icon:SetImage(itemInfo.Icon)
    end
  end
  if self.itemSellTimer_ then
    self.timerMgr:StopTimer(self.itemSellTimer_)
    self.itemSellTimer_ = nil
  end
  local now = Z.TimeTools.Now() / 1000
  local delta = math.floor(data.noticeTime - now)
  if now > data.noticeTime then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_purchase_time, false)
  else
    local delta = math.floor(data.noticeTime - now)
    self.uiBinder.lab_purchase_time.text = Z.TimeFormatTools.FormatToDHMS(delta)
    self.itemSellTimer_ = self.parent.UIView.timerMgr:StartTimer(function()
      delta = delta - 1
      self.uiBinder.lab_purchase_time.text = Z.TimeFormatTools.FormatToDHMS(delta)
      if delta <= 0 then
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_purchase_time, false)
      end
    end, 1, delta + 1)
  end
end

function TradeRingNoticeItem:OnUnInit()
  self.itemClass_:UnInit()
  if self.itemSellTimer_ then
    self.parent.UIView.timerMgr:StopTimer(self.itemSellTimer_)
    self.itemSellTimer_ = nil
  end
end

return TradeRingNoticeItem
