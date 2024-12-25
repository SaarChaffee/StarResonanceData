local super = require("ui.model.data_base")
local ShopData = class("ShopData", super)

function ShopData:ctor()
  super.ctor(self)
end

function ShopData:Init()
  self.shopItemlist_ = nil
  self.MallTableDatas = {}
  self.SeasonShopTableDatas = {}
  self:InitCfgData()
  self.CancelSource = Z.CancelSource.Rent()
end

function ShopData:InitCfgData()
  self.MallItemTableDatas = Z.TableMgr.GetTable("MallItemTableMgr").GetDatas()
  self.SeasonShopItemTableDatas = Z.TableMgr.GetTable("SeasonShopItemTableMgr").GetDatas()
  self.PayFunctionTableDatas = Z.TableMgr.GetTable("PayFunctionTableMgr").GetDatas()
  self.EShopTypeItemCfg = {
    [E.EShopType.Shop] = self.MallItemTableDatas,
    [E.EShopType.SeasonShop] = self.SeasonShopItemTableDatas
  }
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
  self.CancelSource:Recycle()
end

return ShopData
