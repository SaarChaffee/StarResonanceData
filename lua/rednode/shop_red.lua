local ShopRed = {}
local shopItemRedTab = {}
ShopRed.package = {}
local itemCfgName = {
  [E.EShopType.Shop] = "MallItemTableMgr",
  [E.EShopType.SeasonShop] = "SeasonShopItemTableMgr"
}
local MallTableDatas = {}
local MallItemTableDatas = {}
local SeasonShopTableDatas = {}
local SeasonShopItemTableDatas = {}
local eShopTypeItemCfg = {
  [E.EShopType.Shop] = {cfg = MallTableDatas, itemCfg = MallItemTableDatas},
  [E.EShopType.SeasonShop] = {cfg = SeasonShopTableDatas, itemCfg = SeasonShopItemTableDatas}
}

function ShopRed.initCfgData()
  MallTableDatas = Z.TableMgr.GetTable("MallTableMgr").GetDatas()
  MallItemTableDatas = Z.TableMgr.GetTable("MallItemTableMgr").GetDatas()
  SeasonShopTableDatas = Z.TableMgr.GetTable("SeasonShopTableMgr").GetDatas()
  SeasonShopItemTableDatas = Z.TableMgr.GetTable("SeasonShopItemTableMgr").GetDatas()
end

local mysteriousRow

function ShopRed.Init()
  ShopRed.initCfgData()
  for key, mallCfgData in pairs(MallTableDatas) do
    local nodeId = E.RedType.Shop .. E.RedType.ShopOneTab .. mallCfgData.Id
    if mallCfgData.HasFatherType == 0 then
      Z.RedPointMgr.AddChildNodeData(E.RedType.Shop, E.RedType.ShopOneTab, nodeId)
    else
      local childRedId = string.zconcat(E.RedType.Shop, E.RedType.ShopOneTab, mallCfgData.HasFatherType)
      Z.RedPointMgr.AddChildNodeData(E.RedType.Shop, E.RedType.ShopOneTab, childRedId)
      Z.RedPointMgr.AddChildNodeData(childRedId, E.RedType.ShopTwoTab, E.RedType.Shop .. E.RedType.ShopTwoTab .. mallCfgData.Id)
    end
  end
  for i, data in pairs(SeasonShopTableDatas) do
    local childRedId = string.zconcat(E.RedType.SeasonShop, E.RedType.SeasonShopOneTab, data.Id)
    Z.RedPointMgr.AddChildNodeData(E.RedType.SeasonShop, E.RedType.SeasonShopOneTab, childRedId)
  end
end

function ShopRed.AddNewRed(mallItemId, shopType)
  local mallItemCfgData = Z.TableMgr.GetTable(itemCfgName[shopType]).GetRow(mallItemId)
  if mallItemCfgData then
    local mallCfgData
    for key, cfgData in pairs(eShopTypeItemCfg[shopType].cfg) do
      if cfgData.FunctionId == mallItemCfgData.FunctionId then
        mallCfgData = cfgData
        break
      end
    end
    if mallCfgData then
      local parentId, childRedNodeId
      if shopType == E.EShopType.Shop then
        if mallCfgData.HasFatherType == 0 then
          parentId = E.RedType.Shop .. E.RedType.ShopOneTab .. mallCfgData.Id
          childRedNodeId = parentId .. E.RedType.ShopItem .. mallItemId
          Z.RedPointMgr.AddChildNodeData(parentId, E.RedType.ShopItem, childRedNodeId)
        else
          parentId = string.zconcat(E.RedType.Shop, E.RedType.ShopTwoTab, mallCfgData.Id)
          childRedNodeId = parentId .. E.RedType.ShopItem .. mallItemId
          Z.RedPointMgr.AddChildNodeData(parentId, E.RedType.ShopItem, childRedNodeId)
        end
      elseif shopType == E.EShopType.SeasonShop then
        parentId = E.RedType.SeasonShop .. E.RedType.SeasonShopOneTab .. mallCfgData.Id
        childRedNodeId = parentId .. E.RedType.SeasonShopItem .. mallItemId
        Z.RedPointMgr.AddChildNodeData(parentId, E.RedType.SeasonShopItem, childRedNodeId)
      end
      shopItemRedTab[mallItemId] = childRedNodeId
      Z.RedPointMgr.RefreshServerNodeCount(childRedNodeId, 1)
    end
  end
end

function ShopRed.refresShopRed()
end

function ShopRed.GetMallItemRedNameByMallItemId(mallItemId)
  return shopItemRedTab[mallItemId]
end

function ShopRed.RemoveRed(mallItemId)
  if shopItemRedTab[mallItemId] then
    Z.RedPointMgr.RefreshServerNodeCount(shopItemRedTab[mallItemId], 0)
    shopItemRedTab[mallItemId] = nil
  end
end

function ShopRed.ShopRefreshListChange()
  if not mysteriousRow then
    for i, row in pairs(MallTableDatas) do
      if row.FunctionId == E.FunctionID.MysteriousShop then
        mysteriousRow = row
        break
      end
    end
  end
  if not mysteriousRow then
    return
  end
  local isNeedRefresh = false
  if mysteriousRow.MallManualRefresh ~= 0 then
    if 0 < table.zcount(Z.ContainerMgr.CharSerialize.shopData.refreshList) then
      for shopId, refreshList in pairs(Z.ContainerMgr.CharSerialize.shopData.refreshList) do
        if shopId == mysteriousRow.Id then
          local refreshCount = table.zcount(refreshList.timestamp)
          if 0 < refreshCount then
            do
              local lastRefreshTime = refreshList.timestamp[refreshCount]
              local startTime = Z.TimeTools.GetStartTimeByTimerId(mysteriousRow.RefreshIntervalType)
              if lastRefreshTime < startTime / 1000 then
                isNeedRefresh = true
              end
            end
            break
          end
          isNeedRefresh = true
          break
        end
      end
    else
      isNeedRefresh = true
    end
  end
  local redNum = 0
  if isNeedRefresh then
    local lastTime = Z.LocalUserDataMgr.GetLong("BKL_REDDOTRED" .. E.RedType.MysteriousShopRed, 0, 0, true)
    if lastTime ~= 0 then
      local isSameDay = Z.TimeTools.CheckIsSameDay(lastTime, math.floor(Z.ServerTime:GetServerTime() / 1000))
      if not isSameDay then
        redNum = 1
      end
    else
      redNum = 1
    end
  end
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.MysteriousShopRed, redNum)
end

return ShopRed
