local currencyViewTab = {}
local LunuoItemId = Z.SystemItem.ItemCoin
local DiamondId = Z.SystemItem.ItemDiamond
local FakeDiamonId = Z.SystemItem.ItemEnergyPoint
local Vitality = E.CurrencyType.Vitality
local FakeLunuoItemId = Z.SystemItem.Bindingcoin
local ExchangeDiamondToSilvercoin = Z.Global.ExchangeDiamondToSilvercoin
local ExchangeDiamondToCoppercoin = Z.Global.ExchangeDiamondToCoppercoin
local MoneyOverflowLimit = Z.Global.MoneyOverflowLimit
local funcVM = Z.VMMgr.GetVM("gotofunc")
local switchVm = Z.VMMgr.GetVM("switch")
local getCurrencyIds = function()
  local configId = Z.SystemItem.DefaultCurrencyDisplay
  return configId
end
local getItemInfoByConfigId = function(configId)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if itemCfg then
    local typeCfg = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemCfg.Type)
    if typeCfg then
      if typeCfg.Package == E.BackPackItemPackageType.Currency then
        local package = Z.ContainerMgr.CharSerialize.itemCurrency.currencyDatas[configId]
        if package then
          return package
        end
      else
        local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[typeCfg.Package]
        if package.items then
          return package
        end
      end
    end
  end
  return nil
end
local isShowExchangeBtn = function(configId)
  if configId == DiamondId or configId == FakeDiamonId or configId == LunuoItemId or configId == Vitality or configId == FakeLunuoItemId then
    return true
  end
  if not funcVM.CheckFuncCanUse(E.FunctionID.ExChangeMoney, true) then
    return false
  else
    local functionID
    if ExchangeDiamondToSilvercoin[2] and ExchangeDiamondToSilvercoin[2][1] == configId then
      functionID = E.FunctionID.DiamondToMoney
    elseif ExchangeDiamondToCoppercoin[2] and ExchangeDiamondToCoppercoin[2][1] == configId then
      functionID = E.FunctionID.MoneyToIntegral
    end
    if functionID ~= nil and funcVM.CheckFuncCanUse(functionID, true) then
      return true
    end
  end
  return false
end
local openExChangeCurrencyView = function(configId, showDialog, trans)
  if configId == DiamondId then
    if switchVm.CheckFuncSwitch(E.FunctionID.PayFunction) then
      local shopVm = Z.VMMgr.GetVM("shop")
      if showDialog then
        Z.DialogViewDataMgr:OpenNormalDialog(Lang("IsJumpPayFunction"), function()
          shopVm.OpenShopView(E.FunctionID.PayFunction)
        end)
      else
        shopVm.OpenShopView(E.FunctionID.PayFunction)
      end
    else
      Z.TipsVM.ShowTips(1000744)
    end
  elseif configId == FakeDiamonId or configId == LunuoItemId then
    if funcVM.CheckFuncCanUse(E.FunctionID.Trade) then
      local tradeVm = Z.VMMgr.GetVM("trade")
      if configId == FakeDiamonId then
        tradeVm.OpenTradeMainView(nil, 5, 2)
      elseif configId == LunuoItemId then
        tradeVm.OpenTradeMainView(nil, 5, 1)
      end
    end
  elseif Vitality == configId then
    funcVM.GoToFunc(E.FunctionID.CraftEnergy)
  elseif funcVM.CheckFuncCanUse(E.FunctionID.ExChangeMoney, not showDialog) then
    local data = {}
    if ExchangeDiamondToSilvercoin[2] and ExchangeDiamondToSilvercoin[2][1] == configId then
      data.data = ExchangeDiamondToSilvercoin
      data.functionId = E.FunctionID.DiamondToMoney
    elseif ExchangeDiamondToCoppercoin[2] and ExchangeDiamondToCoppercoin[2][1] == configId then
      data.data = ExchangeDiamondToCoppercoin
      data.functionId = E.FunctionID.MoneyToIntegral
    end
    if data.data == nil or not funcVM.CheckFuncCanUse(data.functionId, not showDialog) then
      if trans then
        return Z.TipsVM.ShowItemTipsView(trans, configId)
      end
      if Z.UIMgr:IsActive("shop_money_changing_popup") then
        Z.UIMgr:CloseView("shop_money_changing_popup")
      end
      return
    end
    Z.UIMgr:OpenView("shop_money_changing_popup", data)
  elseif Z.UIMgr:IsActive("shop_money_changing_popup") then
    Z.UIMgr:CloseView("shop_money_changing_popup")
  end
end
local closeExChangeCurrencyView = function()
  Z.UIMgr:CloseView("shop_money_changing_popup")
end
local ret = {
  GetCurrencyIds = getCurrencyIds,
  GetItemInfoByConfigId = getItemInfoByConfigId,
  IsShowExchangeBtn = isShowExchangeBtn,
  OpenExChangeCurrencyView = openExChangeCurrencyView,
  CloseExChangeCurrencyView = closeExChangeCurrencyView
}
return ret
