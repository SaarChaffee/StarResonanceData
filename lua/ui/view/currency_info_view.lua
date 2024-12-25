local UI = Z.UI
local super = require("ui.ui_subview_base")
local Currency_infoView = class("Currency_infoView", super)
local currency_loop_item_ = require("ui.component.currency.currency_loop_item")
local loopListView_ = require("ui.component.loop_list_view")

function Currency_infoView:ctor()
  self.uiBinder = nil
  super.ctor(self, "currency_info", "tips/currency_info", UI.ECacheLv.None)
end

function Currency_infoView:OnActive()
  self.uiBinder.Ref.UIComp:SetVisible(true)
  self.uiBinder.Trans:SetLocalPos(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.currencyScrollRect_ = loopListView_.new(self, self.uiBinder.loopscroll_currency, currency_loop_item_, "n_common_equip_repair")
  self.currencyScrollRect_:Init({})
end

function Currency_infoView:OnDeActive()
  self.uiBinder.Ref.UIComp:SetVisible(false)
  self.currencyScrollRect_:UnInit()
end

function Currency_infoView:OnRefresh()
  if #self.viewData.ids > 0 then
    local data = table.zunique(self.viewData.ids)
    local showData = table.zreverse(data)
    self.currencyScrollRect_:RefreshListView(showData, false)
  end
end

return Currency_infoView
