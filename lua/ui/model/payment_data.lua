local super = require("ui.model.data_base")
local PaymentData = class("PaymentData", super)

function PaymentData:ctor()
end

function PaymentData:Init()
  self.prodctsName_ = nil
  self.productions_ = {}
  if self.CancelSource == nil then
    self.CancelSource = Z.CancelSource.Rent()
  end
  self.paymentResponseEvent_ = false
end

function PaymentData:SetProdctsName(productName)
  self.prodctsName_ = productName
end

function PaymentData:GetProdctsName(productId)
  if Z.SDKLogin.GetPlatform() == E.LoginPlatformType.InnerPlatform then
    return productId
  end
  if self.prodctsName_ == nil then
    return nil
  end
  if self.prodctsName_[productId] == nil then
    return productId
  end
  return self.prodctsName_[productId]
end

function PaymentData:SetProdctsInfo(productInfo)
  self.productions_[productInfo.ID] = productInfo
end

function PaymentData:GetProdctsIdByProductName(productName)
  if self.prodctsName_ == nil then
    return productName
  end
  for productId, value in pairs(self.prodctsName_) do
    if productName == value then
      return productId
    end
  end
  return productName
end

function PaymentData:GetProdctsInfo(productId)
  return self.productions_[productId]
end

function PaymentData:GetProductName()
  return self.prodctsName_
end

function PaymentData:SetPaymentResponseEvent(flag)
  self.paymentResponseEvent_ = flag
end

function PaymentData:GetPaymentResponseEvent()
  return self.paymentResponseEvent_
end

function PaymentData:UnInit()
  self.prodctsName_ = nil
  self.productions_ = {}
  if self.CancelSource then
    self.CancelSource:Recycle()
    self.CancelSource = nil
  end
end

return PaymentData
