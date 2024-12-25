local super = require("ui.component.loop_list_view_item")
local PayLoopItem = class("PayLoopItem", super)

function PayLoopItem:ctor()
  self.shopVm_ = Z.VMMgr.GetVM("shop")
end

function PayLoopItem:OnInit()
  self:AddAsyncListener(self.uiBinder.btn, function()
    if self.paymentId_ then
      self.shopVm_.AsyncPayment(self.paymentId_)
    end
  end)
end

function PayLoopItem:OnUnInit()
end

function PayLoopItem:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_name.text = self.data_.Name
  self.uiBinder.rimg_icon:SetImage(self.data_.Icon)
  local payData = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(self.data_.PaymentId[1])
  if payData then
    self.paymentId_ = self.data_.PaymentId[1]
    local payStr = ""
    for _, v in pairs(Z.Global.PaymentSignal) do
      if v[1] == payData.Currency then
        payStr = v[2]
        break
      end
    end
    self.uiBinder.lab_price.text = payStr .. payData.Price
  end
end

return PayLoopItem
