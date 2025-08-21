local super = require("ui.model.data_base")
local ShopData = class("ShopData", super)

function ShopData:ctor()
  super.ctor(self)
end

function ShopData:Init()
  self.shopItemlist_ = nil
  self.MallTableDatas = {}
  self.firstPayInfo_ = {}
  self.ladderPayInfo_ = {}
  self.ShopQualityLab = {
    [0] = Color.New(0.4196078431372549, 0.4196078431372549, 0.4196078431372549, 1),
    [1] = Color.New(0.3333333333333333, 0.4823529411764706, 0.42745098039215684, 1),
    [2] = Color.New(0.3333333333333333, 0.37254901960784315, 0.4823529411764706, 1),
    [3] = Color.New(0.40784313725490196, 0.3333333333333333, 0.4823529411764706, 1),
    [4] = Color.New(0.5019607843137255, 0.39215686274509803, 0.2627450980392157, 1),
    [5] = Color.New(0.5607843137254902, 0.33725490196078434, 0.23921568627450981, 1)
  }
  self:InitShopBuyItemInfoList()
  self:InitCostList()
  self:InitCfgData()
  self.CancelSource = Z.CancelSource.Rent()
end

function ShopData:InitCfgData()
  self.MallItemTableDatas = Z.TableMgr.GetTable("MallItemTableMgr").GetDatas()
  self.PayFunctionTableDatas = Z.TableMgr.GetTable("PayFunctionTableMgr").GetDatas()
  self:initProfessionList()
  self:initShopCouponsData()
end

function ShopData:OnLanguageChange()
  self:InitCfgData()
end

function ShopData:SetShopItemList(shopItemList)
  self.shopItemlist_ = shopItemList
end

function ShopData:GetShopItemList()
  return self.shopItemlist_
end

function ShopData:Clear()
  self.shopItemlist_ = nil
end

function ShopData:UnInit()
  self.shopItemlist_ = nil
  self.firstPayInfo_ = {}
  self.ladderPayInfo_ = {}
  self.CancelSource:Recycle()
end

function ShopData:SetShopItemFirstInfo(firstPayInfo, ladderPayInfo)
  self.firstPayInfo_ = {}
  for _, value in ipairs(firstPayInfo) do
    self.firstPayInfo_[value] = true
  end
  self.ladderPayInfo_ = ladderPayInfo
end

function ShopData:GetShopItemFirstInfo(productId)
  return self.firstPayInfo_[productId]
end

function ShopData:GetShopItemLadderInfo(productId)
  return self.ladderPayInfo_[productId]
end

function ShopData:initProfessionList()
  self.professionList_ = {}
  for _, professionRow in pairs(Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()) do
    if professionRow.IsOpen then
      self.professionList_[#self.professionList_ + 1] = professionRow
    end
  end
end

function ShopData:GetProfessionList()
  return self.professionList_
end

function ShopData:initShopCouponsData()
  self.shopCouponsData_ = {
    MallList = {},
    MallItemList = {}
  }
  for _, data in pairs(Z.TableMgr.GetTable("MallCouponsTableMgr").GetDatas()) do
    if data.EffectiveType == E.MallCouponsEffectiveType.MallTableId then
      for i = 1, #data.EffectiveTypeParameter do
        local shopFunctionId = data.EffectiveTypeParameter[i]
        if not self.shopCouponsData_.MallList[shopFunctionId] then
          self.shopCouponsData_.MallList[shopFunctionId] = {}
        end
        table.insert(self.shopCouponsData_.MallList[shopFunctionId], data)
      end
    elseif data.EffectiveType == E.MallCouponsEffectiveType.MallItemTableId then
      for i = 1, #data.EffectiveTypeParameter do
        local mallItemTableId = data.EffectiveTypeParameter[i]
        if not self.shopCouponsData_.MallItemList[mallItemTableId] then
          self.shopCouponsData_.MallItemList[mallItemTableId] = {}
        end
        table.insert(self.shopCouponsData_.MallItemList[mallItemTableId], data)
      end
    end
  end
end

function ShopData:GetShopCouponsDataByMallItemTable(mallItemRow)
  local couponsList = {}
  local mallList = self.shopCouponsData_.MallList[mallItemRow.FunctionId]
  if mallList then
    for _, value in pairs(mallList) do
      couponsList[value.Id] = value
    end
  end
  local mallItemList = self.shopCouponsData_.MallItemList[mallItemRow.Id]
  if mallItemList then
    for _, value in pairs(mallItemList) do
      couponsList[value.Id] = value
    end
  end
  return couponsList
end

function ShopData:ChangeShopBuyItemCoupons(itemId, couponsList)
  for _, mallItemData in pairs(self.ShopBuyItemInfoList) do
    for _, value in pairs(mallItemData) do
      if value.mallItemRow.Id == itemId then
        value.couponsList = couponsList
        break
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.FashionShopChangeCoupon)
end

function ShopData:InitShopBuyItemInfoList()
  self:ClearShopBuyItemInfoList()
  self.ShopIsShowDetail = true
  self.ShopIsShowWear = true
end

function ShopData:GetShopBuyItemInfoListCount()
  local num = 0
  for _, mallData in pairs(self.ShopBuyItemInfoList) do
    num = num + table.zcount(mallData)
  end
  return num
end

function ShopData:GetShopBuyItemWeaponFashionId()
  for _, mallData in pairs(self.ShopBuyItemInfoList) do
    for _, data in pairs(mallData) do
      if data.mallItemRow and data.data.weaponSkinId then
        return data.data.weaponSkinId
      end
    end
  end
end

function ShopData:AddShopBuyItem(mallId, mallPagetabId, shopItem)
  if not self.ShopBuyItemInfoList[mallId] then
    self.ShopBuyItemInfoList[mallId] = {}
  end
  self.ShopBuyItemInfoList[mallId][mallPagetabId] = shopItem
end

function ShopData:RemoveShopBuyItemByMallId(mallId, mallPagetabId)
  if mallPagetabId then
    if not self.ShopBuyItemInfoList[mallId] then
      return
    end
    self.ShopBuyItemInfoList[mallId][mallPagetabId] = nil
  else
    self.ShopBuyItemInfoList[mallId] = nil
  end
end

function ShopData:RemoveShopWearItem(mallItemId)
  local removeK = {}
  for k, v in pairs(self.ShopWearDict) do
    if v.showWearData and v.showWearData.data and v.showWearData.data.itemId == mallItemId then
      removeK[#removeK + 1] = k
    end
  end
  for i = 1, #removeK do
    self.ShopWearDict[removeK[i]] = nil
  end
end

function ShopData:RemoveShopBuyItemByMallItemId(mallItemId)
  for mallId, mallData in pairs(self.ShopBuyItemInfoList) do
    for tabId, data in pairs(mallData) do
      if data.mallItemRow and data.mallItemRow.Id == mallItemId then
        self.ShopBuyItemInfoList[mallId][tabId] = nil
        break
      end
    end
  end
end

function ShopData:ClearShopBuyItemInfoList()
  self.ShopBuyItemInfoList = {}
  self.ShopWearDict = {}
  self:InitCostList()
end

function ShopData:InitCostList()
  self.ShopCostList = {
    {
      costId = 0,
      costValue = 0,
      originalValue = 0
    },
    {
      costId = 0,
      costValue = 0,
      originalValue = 0
    }
  }
end

return ShopData
