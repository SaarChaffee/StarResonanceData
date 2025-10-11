local cjson = require("cjson")
local PaymentVm = {}
local Wait_Msg_Id = {payment_order = 331777}

function PaymentVm:GetProductionInfos(productIds, callback)
  if productIds == nil then
    return
  end
  local paymentData = Z.DataMgr.Get("payment_data")
  local currentPlatform = Z.SDKLogin.GetPlatform()
  local sdkType = Z.SDKLogin.GetSDKType()
  if currentPlatform == E.LoginPlatformType.InnerPlatform or not self:CheckPaymentEnable() then
    local shopVm = Z.VMMgr.GetVM("shop")
    local currencySymbol = shopVm.GetShopItemCurrencySymbol()
    local products = {}
    for index, value in ipairs(productIds) do
      local prodctionRow = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(tonumber(value))
      if prodctionRow then
        products[index] = {
          ID = value,
          Price = prodctionRow.Price,
          CurrencySymbol = currencySymbol,
          DisplayPrice = currencySymbol .. prodctionRow.Price
        }
      end
    end
    if callback then
      callback(products)
    end
  else
    productIds = self:trySwitchQueryId(productIds)
    Z.SDKPay.QueryProducts(productIds, function(data)
      if callback then
        local products = {}
        if data then
          for i = 0, data.Length - 1 do
            products[i + 1] = {
              ID = data[i].ID,
              Price = data[i].Price,
              CurrencySymbol = data[i].CurrencySymbol,
              DisplayPrice = data[i].DisplayPrice
            }
            if Z.GameContext.IsPC and currentPlatform == E.LoginPlatformType.APJPlatform and sdkType ~= E.LoginSDKType.APJEpic then
              products[i + 1].ID = paymentData:GetProdctsName(tonumber(data[i].ID))
            end
            paymentData:SetProdctsInfo(products[i + 1])
          end
        end
        callback(products)
      end
    end)
  end
end

function PaymentVm:trySwitchQueryId(productNames)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  local paymentData = Z.DataMgr.Get("payment_data")
  if Z.GameContext.IsPC and currentPlatform == E.LoginPlatformType.APJPlatform then
    local productIds = {}
    for index, value in pairs(productNames) do
      local productId = paymentData:GetProdctsIdByProductName(value)
      table.insert(productIds, tostring(productId))
    end
    return productIds
  end
  return productNames
end

function PaymentVm:Pay(productId, cpOrderId, serverId, extJson)
  local paymentData = Z.DataMgr.Get("payment_data")
  if not self:CheckPaymentEnable(true) then
    return
  end
  local serverProductId = paymentData:GetProdctsName(productId) or ""
  extJson = self:TrySetAPJExtJson(productId, extJson) or extJson
  cpOrderId = cpOrderId or ""
  local isAPJPlat = Z.SDKLogin.GetPlatform() == E.LoginPlatformType.APJPlatform
  if Z.IsPCUI and not isAPJPlat then
    Z.IgnoreMgr:SetInputIgnore(4294967295, true, E.EIgnoreMaskSource.EPayWebView)
    Z.InputMgr:EnableInput(false, Panda.ZGame.EInputMgrEableSource.Payment)
  end
  Z.SDKPay.Pay(serverProductId, cpOrderId, serverId, extJson, function(code, msg)
    if Z.IsPCUI and not isAPJPlat then
      Z.IgnoreMgr:SetInputIgnore(4294967295, false, E.EIgnoreMaskSource.EPayWebView)
      Z.InputMgr:EnableInput(true, Panda.ZGame.EInputMgrEableSource.Payment)
    end
    logError("\230\148\175\228\187\152\229\174\140\230\136\144, code{0}, msg:{1}", code, msg)
    if code ~= 0 then
      Z.TipsVM.ShowTips(1000753)
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      local worldProxy = require("zproxy.world_proxy")
      local vRequest = {}
      vRequest.payType = self:GetPayType()
      vRequest.extData = self:GetExtData()
      Z.MouseMgr:ResetCursor()
      local paymentData = Z.DataMgr.Get("payment_data")
      worldProxy.PaySuccess(vRequest, paymentData.CancelSource:CreateToken())
    end)()
    Z.SDKReport.ReportPurchase(tostring(productId))
  end)
end

function PaymentVm:TrySetAPJExtJson(productId, extJson)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  local isAPJPlat = currentPlatform == E.LoginPlatformType.APJPlatform and not Z.GameContext.IsPlayInMobile
  if not isAPJPlat then
    return extJson
  end
  local paymentData = Z.DataMgr.Get("payment_data")
  local prodctsName_ = paymentData:GetProdctsName(productId)
  if prodctsName_ == nil then
    return extJson
  end
  local productInfo = paymentData:GetProdctsInfo(prodctsName_)
  if productInfo == nil then
    return extJson
  end
  local paymentRow = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(productId)
  if paymentRow == nil then
    return extJson
  end
  local extJsonInfo = cjson.decode(extJson)
  extJsonInfo.priceAmount = math.floor(productInfo.Price * 100)
  extJsonInfo.priceCurrency = productInfo.CurrencyCode
  extJsonInfo.description = paymentRow.Description
  local extData = cjson.encode(extJsonInfo)
  return extData
end

function PaymentVm:CheckIsNotPayOrder()
  local count = Z.SDKPay.GetPendingPaymentTransationCount()
  return 0 < count, count
end

function PaymentVm:ProcessPendingPaymentTransaction()
  local serverData = Z.DataMgr.Get("server_data")
  local serverId = serverData:GetCurrentZoneId()
  Z.SDKPay.ProcessPendingPaymentTransaction(serverId)
end

function PaymentVm:AsyncPayment(payType, productId)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if currentPlatform == E.LoginPlatformType.InnerPlatform then
    local cmdInfo = string.zconcat("payment ", productId, ",0")
    local gmVm = Z.VMMgr.GetVM("gm")
    local gm_data = Z.DataMgr.Get("gm_data")
    gmVm.SubmitGmCmd(cmdInfo, gm_data.CancelSource)
    return
  end
  if not self:CheckPaymentEnable(true) then
    return
  end
  local worldProxy = require("zproxy.world_proxy")
  local vRequest = {}
  vRequest.payType = payType or self:GetPayType()
  vRequest.productId = productId
  vRequest.receipt = self:GetReceipt()
  vRequest.extData = self:GetExtData()
  xpcall(function()
    Z.NetWaitHelper.AddSyncMsgId(Z.ConstValue.WaitMsgMainKey.Pay, Wait_Msg_Id.payment_order)
    local paymentData = Z.DataMgr.Get("payment_data")
    local ret = worldProxy.Pay(vRequest, paymentData.CancelSource:CreateToken())
    Z.NetWaitHelper.RemoveSyncMsgId(Z.ConstValue.WaitMsgMainKey.Pay, Wait_Msg_Id.payment_order)
    if ret.errCode == 7303 then
      return
    end
    if ret.errCode ~= 0 then
      Z.TipsVM.ShowTips(ret.errCode)
      return false
    end
    local extJson = self:GetExtJson()
    if extJson == "" then
      extJson = ret.extraData
    end
    self:Pay(productId, ret.extraData, ret.serverId, extJson)
  end, function(err)
    logError("payment error:{0}", err)
    Z.NetWaitHelper.RemoveSyncMsgId(Z.ConstValue.WaitMsgMainKey.Pay, Wait_Msg_Id.payment_order)
  end)
end

function PaymentVm:AsyncActivityAction(uuid, rewardId, productId)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if currentPlatform == E.LoginPlatformType.InnerPlatform then
    local cmdInfo = string.zconcat("payment ", productId, ",0")
    local gmVm = Z.VMMgr.GetVM("gm")
    local gm_data = Z.DataMgr.Get("gm_data")
    gmVm.SubmitGmCmd(cmdInfo, gm_data.CancelSource)
    return
  end
  if not self:CheckPaymentEnable(true) then
    return
  end
  local worldProxy = require("zproxy.world_proxy")
  local request = {
    activityUuid = uuid,
    rewardId = rewardId,
    payType = self:GetPayType()
  }
  xpcall(function()
    Z.NetWaitHelper.AddSyncMsgId(Z.ConstValue.WaitMsgMainKey.Pay, Wait_Msg_Id.payment_order)
    local paymentData = Z.DataMgr.Get("payment_data")
    local ret = worldProxy.ActivityAction(request, paymentData.CancelSource:CreateToken())
    Z.NetWaitHelper.RemoveSyncMsgId(Z.ConstValue.WaitMsgMainKey.Pay, Wait_Msg_Id.payment_order)
    if ret.errCode == 7303 then
      return
    end
    if ret.errCode ~= 0 then
      Z.TipsVM.ShowTips(ret.errCode)
      return nil
    end
    local payReply = ret.payReply
    local extJson = self:GetExtJson()
    if extJson == "" then
      extJson = payReply.extraData
    end
    self:Pay(productId, payReply.extraData, payReply.serverId, extJson)
  end, function(err)
    logError("payment error:{0}", err)
    Z.NetWaitHelper.RemoveSyncMsgId(Z.ConstValue.WaitMsgMainKey.Pay, Wait_Msg_Id.payment_order)
  end)
end

function PaymentVm:AsyncQueryBalance(payType, queryType, cancelToken)
  if Z.SDKLogin.GetPlatform() ~= E.LoginPlatformType.TencentPlatform then
    return
  end
  if not self:CheckPaymentEnable() then
    return
  end
  if not Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.QueryBalance, true) then
    return
  end
  local worldProxy = require("zproxy.world_proxy")
  local vRequest = {}
  vRequest.payType = payType or self:GetPayType()
  vRequest.queryType = queryType or Z.PbEnum("EQueryBalanceType", "EQueryBalanceTypeLeft")
  vRequest.extData = self:GetExtData()
  local paymentData = Z.DataMgr.Get("payment_data")
  if cancelToken == nil then
    cancelToken = paymentData.CancelSource:CreateToken()
  end
  worldProxy.QueryBalance(vRequest, cancelToken)
end

function PaymentVm:AysncQueryProduct(payType, cancelToken)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if currentPlatform == E.LoginPlatformType.InnerPlatform then
    return
  end
  if not Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.Shop, true) then
    return
  end
  if not self:CheckPaymentEnable() then
    return
  end
  local worldProxy = require("zproxy.world_proxy")
  local vRequest = {}
  vRequest.payType = payType or self:GetPayType()
  local paymentData = Z.DataMgr.Get("payment_data")
  if cancelToken == nil then
    cancelToken = paymentData.CancelSource:CreateToken()
  end
  local ret = worldProxy.QueryProduct(vRequest, cancelToken)
  logError(table.ztostring(ret))
  if ret.errCode ~= 0 then
    return
  end
  local paymentData = Z.DataMgr.Get("payment_data")
  paymentData:SetProdctsName(ret.productInfo)
end

function PaymentVm:GetExtJson()
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if currentPlatform == E.LoginPlatformType.InnerPlatform then
    return ""
  elseif currentPlatform == E.LoginPlatformType.HaoPlayPlatform then
    return cjson.encode({
      roleid = Z.ContainerMgr.CharSerialize.charBase.charId,
      level = Z.ContainerMgr.CharSerialize.roleLevel.level
    })
  elseif currentPlatform == E.LoginPlatformType.TencentPlatform then
    return ""
  end
  return ""
end

function PaymentVm:GetExtData()
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if currentPlatform == E.LoginPlatformType.InnerPlatform then
    return ""
  elseif currentPlatform == E.LoginPlatformType.HaoPlayPlatform then
    return ""
  elseif currentPlatform == E.LoginPlatformType.TencentPlatform then
    local accountData = Z.DataMgr.Get("account_data")
    local session_id = "itopid"
    local session_type = "itop"
    local pf = Z.SDKLogin.GetAccountExtInfo("Pf") or ""
    local pfkey = Z.SDKLogin.GetAccountExtInfo("PfKey") or ""
    local offer_id = Z.SDKLogin.GetAccountExtInfo("OfferID") or ""
    local openKey = accountData.Token or ""
    local extTable = {
      session_id = session_id,
      session_type = session_type,
      pf = pf,
      pfkey = pfkey,
      offer_id = offer_id,
      openKey = openKey
    }
    local extData = cjson.encode(extTable)
    return extData
  end
  return ""
end

function PaymentVm:GetReceipt()
  return ""
end

function PaymentVm:GetPayType()
  local sdkType = Z.SDKLogin.GetSDKType()
  if sdkType == E.LoginSDKType.APJ then
    if Z.SDKDevices.RuntimeOS == E.OS.iOS then
      return Z.PbEnum("EPayType", "PayTypeApjIos")
    elseif Z.SDKDevices.RuntimeOS == E.OS.Android then
      return Z.PbEnum("EPayType", "PayTypeApjAndroid")
    elseif Z.SDKDevices.RuntimeOS == E.OS.Windows then
      return Z.PbEnum("EPayType", "PayTypeApjPc")
    end
  else
    return E.PlatformToPayType[sdkType]
  end
end

function PaymentVm:CheckPaymentEnable(showTips)
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if currentPlatform ~= E.LoginPlatformType.TencentPlatform then
    return true
  end
  local sub = "\"pay_token\":\"GAMEMATRIX"
  local channelInfo = Z.SDKLogin.GetAccountExtInfo("ChannelInfo") or ""
  if channelInfo:match(sub) then
    if showTips then
      Z.DialogViewDataMgr:OpenOKDialog(Lang("CloudGamePaymentTips"), function()
        Z.SDKDevices.SendMessageToCloudGameDevice("GAMEMATRIX : TRY_PLAY_END")
      end)
    end
    return false
  end
  return true
end

function PaymentVm:GetPaymentRow(platform, productType)
  local paymentRow = Z.TableMgr.GetTable("PaymentTableMgr").GetDatas()
  local tempData = {}
  local index = 0
  for k, v in pairs(paymentRow) do
    if v.Platform[1] == platform and v.ProductType == productType then
      index = index + 1
      tempData[index] = v
    end
  end
  return tempData
end

function PaymentVm:GetBeforeDiscountPrice(price, discount, symbol, symbolCode)
  local beforeDiscountPrice = ""
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if currentPlatform == E.LoginPlatformType.TencentPlatform or currentPlatform == E.LoginPlatformType.InnerPlatform then
    beforeDiscountPrice = symbol .. string.format("%.2f", price * discount):gsub("0+$", ""):gsub("%.$", "")
  else
    beforeDiscountPrice = string.format("%.2f", price * discount):gsub("0+$", ""):gsub("%.$", "")
    if symbolCode == "EUR" then
      beforeDiscountPrice = beforeDiscountPrice:gsub("%.", ",")
    end
  end
  return beforeDiscountPrice
end

return PaymentVm
