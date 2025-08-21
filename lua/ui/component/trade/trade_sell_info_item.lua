local super = require("ui.component.loop_list_view_item")
local TradeSellItemInfo = class("TradeSellItemInfo", super)

function TradeSellItemInfo:ctor()
end

function TradeSellItemInfo:OnInit()
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
end

function TradeSellItemInfo:OnRefresh(data)
  self.uiBinder.lab_diamond_num.text = data.num
  self.uiBinder.lab_exchange_rate_num.text = data.rate
  if self.itemSellTimer_ then
    self.parent.UIView.timerMgr:StopTimer(self.itemSellTimer_)
    self.itemSellTimer_ = nil
  end
  local now = Z.TimeTools.Now() / 1000
  local delta = math.floor(data.endTime - now)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, true)
  if delta <= 0 then
    self.uiBinder.lab_time.text = Lang("timeout")
  else
    self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(delta, true)
    self.itemSellTimer_ = self.parent.UIView.timerMgr:StartTimer(function()
      delta = delta - 1
      self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(delta, true)
      if delta <= 0 then
        self.uiBinder.Ref:SetVisible(self.uiBinder.lab_time, false)
      end
    end, 1, delta + 1)
  end
  self.parent.UIView:AddAsyncClick(self.uiBinder.btn_shelf, function()
    self.tradeVm_:AsyncExchangeSaleTake(data.guid, self.parent.UIView.cancelSource:CreateToken())
  end)
end

function TradeSellItemInfo:OnSelected(isSelect)
end

function TradeSellItemInfo:OnUnInit()
  if self.itemSellTimer_ then
    self.parent.UIView.timerMgr:StopTimer(self.itemSellTimer_)
    self.itemSellTimer_ = nil
  end
end

return TradeSellItemInfo
