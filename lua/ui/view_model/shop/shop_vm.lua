local ShopVm = {}
local worldProxy = require("zproxy.world_proxy")
local shopRedClass = require("rednode.shop_red")
local eShopTypeItemCfg = {
  [E.EShopType.Shop] = "MallItemTableMgr",
  [E.EShopType.SeasonShop] = "SeasonShopItemTableMgr"
}

function ShopVm.OpenShopView(funcId1, funcId2, configId)
  local gotoVm = Z.VMMgr.GetVM("gotofunc")
  local funcOpen = gotoVm.CheckFuncCanUse(E.FunctionID.Shop, false)
  if not funcOpen then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local shopData = Z.DataMgr.Get("shop_data")
    local seasonVm = Z.VMMgr.GetVM("season_shop")
    local shopItemData = seasonVm.AsyncGetShopData(shopData.CancelSource, 0)
    if table.zcount(shopItemData) == 0 then
      Z.TipsVM.ShowTips(1000749)
      return
    end
    local param = {
      funcId1 = funcId1,
      funcId2 = funcId2,
      configId = configId,
      shopItemData = shopItemData
    }
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Store, "shop_window", function()
      Z.UIMgr:OpenView("shop_window", param)
    end)
  end)()
end

function ShopVm.CloseShopView()
  Z.UIMgr:CloseView("shop_window")
end

function ShopVm.GetPayTable()
  local showData = Z.DataMgr.Get("shop_data")
  return showData.PayFunctionTableDatas
end

function ShopVm.GetShopItemTable(functionId)
  local showData = Z.DataMgr.Get("shop_data")
  local tbl = {}
  for key, mallCfgData in pairs(showData.MallItemTableDatas) do
    if mallCfgData.FunctionId == functionId then
      table.insert(tbl, mallCfgData)
    end
  end
  table.sort(tbl, function(a, b)
    if a.Sort == b.Sort then
      return a.Id < b.Id
    end
    return a.Sort < b.Sort
  end)
  return tbl
end

function ShopVm.GetShopTabIndexByFunctionId(functionId, shopItemList)
  for index, value in ipairs(shopItemList) do
    if value.fristLevelTabData.FunctionId == functionId then
      return index
    end
  end
end

function ShopVm.GetShopTabTable(shopDatas)
  local mallTable = Z.TableMgr.GetTable("MallTableMgr")
  local switchVm = Z.VMMgr.GetVM("switch")
  local shopTabList = {}
  local twoTabList = {}
  local onwTabList = {}
  for index, value in ipairs(shopDatas) do
    local mallCfgData = mallTable.GetRow(value.Id)
    if mallCfgData and switchVm.CheckFuncSwitch(mallCfgData.FunctionId) then
      local mallId = mallCfgData.HasFatherType ~= 0 and mallCfgData.HasFatherType or mallCfgData.Id
      if onwTabList[mallId] == nil then
        table.insert(shopTabList, {
          fristLevelTabData = mallTable.GetRow(mallId)
        })
        onwTabList[mallId] = true
      end
      if mallCfgData.HasFatherType ~= 0 then
        if twoTabList[mallId] == nil then
          twoTabList[mallId] = {}
        end
        table.insert(twoTabList[mallId], mallCfgData)
      end
    end
  end
  for index, shopTabData in ipairs(shopTabList) do
    if shopTabData.secondaryTabList == nil then
      shopTabData.secondaryTabList = {}
    end
    if twoTabList[shopTabData.fristLevelTabData.Id] then
      shopTabData.secondaryTabList = twoTabList[shopTabData.fristLevelTabData.Id]
    end
  end
  local functionCfg = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(E.FunctionID.PayFunction)
  if functionCfg and switchVm.CheckFuncSwitch(E.FunctionID.PayFunction) then
    table.insert(shopTabList, {
      fristLevelTabData = mallTable.GetRow(E.MallType.ERecharge),
      secondaryTabList = {}
    })
  end
  local shopData = Z.DataMgr.Get("shop_data")
  shopData:SetShopItemList(shopTabList)
  return shopTabList
end

function ShopVm.AsyncPayment(id)
  local vRequest = {}
  vRequest.orderGuid = ""
  vRequest.paymentId = id
  worldProxy.Payment(vRequest)
end

function ShopVm.AsyncExchangeCurrency(functionId, useCount)
  worldProxy.ExchangeCurrency(functionId, useCount)
end

function ShopVm.AsyncSetShopItemRed(itemId, shopType)
  local request = {shopType = shopType, itemId = itemId}
  local seasonShopData = Z.DataMgr.Get("season_shop_data")
  local ret = worldProxy.GetShopItemCanBuy(request, seasonShopData.CancelSource:CreateToken())
  if ret and ret.errCode == 0 then
    if ret.canBuy then
      shopRedClass.AddNewRed(itemId, shopType)
    else
      shopRedClass.RemoveRed(itemId)
    end
  end
end

function ShopVm.SetMallItemRed()
  ShopVm.SetShopItemRed(E.EShopType.Shop)
  ShopVm.SetShopItemRed(E.EShopType.SeasonShop)
end

function ShopVm.SetShopItemRed(shopType)
  local showData = Z.DataMgr.Get("shop_data")
  local freeMallItemTab = {}
  local cfg = showData.EShopTypeItemCfg[shopType]
  for _, data in pairs(cfg) do
    for id, num in pairs(data.Cost) do
      if num == 0 then
        table.insert(freeMallItemTab, data)
        break
      end
    end
  end
  if 0 < #freeMallItemTab then
    Z.CoroUtil.create_coro_xpcall(function()
      for _, mallItemData in ipairs(freeMallItemTab) do
        ShopVm.AsyncSetShopItemRed(mallItemData.Id, shopType)
      end
    end)()
  end
end

function ShopVm.BuyCallFunc(vRequest)
  if vRequest.errorCode == 0 then
    local paymentCfg = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(vRequest.paymentId)
    if paymentCfg then
      if paymentCfg.MailId == 0 then
        local awardTab = {}
        if paymentCfg.AwardId ~= 0 then
          local awardVm = Z.VMMgr.GetVM("awardpreview")
          local award = awardVm.GetAllAwardPreListByIds(paymentCfg.AwardId)
          for key, value in ipairs(award) do
            table.insert(awardTab, {
              configId = value.awardId,
              count = value.awardNum
            })
          end
        end
        for key, value in pairs(paymentCfg.Items) do
          table.insert(awardTab, {
            configId = value[1],
            count = value[2]
          })
        end
        if 0 < #awardTab then
          local itemShowVm = Z.VMMgr.GetVM("item_show")
          itemShowVm.OpenItemShowView(awardTab)
        end
      else
        Z.TipsVM.ShowTipsLang(1000728)
      end
    end
  else
    Z.TipsVM.ShowTips(vRequest.errorCode)
  end
end

function ShopVm.AsyncRefreshShop(shopId, isAuto, cancelToken)
  local request = {}
  request.shopId = shopId
  request.isSystemAuto = isAuto
  local reply = worldProxy.RefreshShop(request, cancelToken)
  return reply
end

function ShopVm.InitCfgData()
  local mallTab = {}
  local seasonTab = {}
  for key, cfgData in pairs(Z.TableMgr.GetTable("MallTableMgr").GetDatas()) do
    mallTab[cfgData.FunctionId] = cfgData
  end
  for key, cfgData in pairs(Z.TableMgr.GetTable("SeasonShopTableMgr").GetDatas()) do
    seasonTab[cfgData.FunctionId] = cfgData
  end
  local showData = Z.DataMgr.Get("shop_data")
  showData.MallTableDatas = mallTab
  showData.SeasonShopTableDatas = seasonTab
end

return ShopVm
