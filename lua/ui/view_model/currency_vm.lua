local currencyViewTab = {}
local LunuoItemId = Z.SystemItem.ItemCoin
local DiamondId = Z.SystemItem.ItemDiamond
local FakeDiamonId = Z.SystemItem.ItemEnergyPoint
local Vitality = E.CurrencyType.Vitality
local ExchangeDiamondToSilvercoin = Z.Global.ExchangeDiamondToSilvercoin
local ExchangeDiamondToCoppercoin = Z.Global.ExchangeDiamondToCoppercoin
local MoneyOverflowLimit = Z.Global.MoneyOverflowLimit
local funcVM = Z.VMMgr.GetVM("gotofunc")
local switchVm = Z.VMMgr.GetVM("switch")
local openCurrencyView = function(ids, parentTrans, view)
  local viewData = {ids = ids}
  if currencyViewTab[view] == nil then
    currencyViewTab[view] = require("ui/view/currency_info_view").new()
  end
  currencyViewTab[view]:Active(viewData, parentTrans)
end
local openCurrencyNoAddView = function(ids, parentTrans, view)
  local viewData = {ids = ids}
  if currencyViewTab[view] == nil then
    currencyViewTab[view] = require("ui/view/currency_info_noadd_view").new()
  end
  currencyViewTab[view]:Active(viewData, parentTrans)
end
local closeCurrencyView = function(view)
  local currencyView = currencyViewTab[view]
  if currencyView == nil then
    return
  end
  currencyViewTab[view]:DeActive()
  currencyViewTab[view] = nil
end
local getCurrencyIds = function()
  local configId = Z.SystemItem.DefaultCurrencyDisplay
  return configId
end
local getItemInfoByConfigId = function(configId)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if itemCfg then
    local typeCfg = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemCfg.Type)
    if typeCfg then
      local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[typeCfg.Package]
      if package.items then
        return package
      end
    end
  end
  return nil
end
local numberCurrencyToStr = function(count)
  local str = tostring(count)
  local revStr = string.reverse(str)
  local t = {}
  local len = string.len(revStr)
  for i = 1, len do
    local char = string.sub(revStr, i, i)
    table.insert(t, 1, char)
    if i % 3 == 0 and i < len then
      table.insert(t, 1, ",")
    end
  end
  return table.concat(t)
end
local isShowExchangeBtn = function(configId)
  if configId == DiamondId or configId == FakeDiamonId or configId == LunuoItemId or configId == Vitality then
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
          Z.DialogViewDataMgr:CloseDialogView()
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
  NumberCurrencyToStr = numberCurrencyToStr,
  OpenCurrencyView = openCurrencyView,
  OpenCurrencyNoAddView = openCurrencyNoAddView,
  CloseCurrencyView = closeCurrencyView,
  IsShowExchangeBtn = isShowExchangeBtn,
  OpenExChangeCurrencyView = openExChangeCurrencyView,
  CloseExChangeCurrencyView = closeExChangeCurrencyView
}
return ret
